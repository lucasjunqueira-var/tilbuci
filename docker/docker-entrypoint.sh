#!/usr/bin/env bash
#
# TilBuci container entrypoint.
#
# Responsibilities:
#   1. Prepare the persistent volume and the MariaDB data directory.
#   2. Provision the database and the internal user.
#   3. On the very first run, ask only for the admin e-mail and the install
#      mode (or read them from the environment) and run the installer headless.
#   4. Re-apply the persistence symlinks and hand over to supervisord.
#
set -euo pipefail

# shellcheck source=/dev/null
source /usr/local/bin/tilbuci-common.sh

DB_NAME="${TILBUCI_DB_NAME:-tilbuci}"
DB_USER="${TILBUCI_DB_USER:-tilbuci}"
# Default database password, used when TILBUCI_DB_PASSWORD is not provided and
# no password was stored yet. Override with TILBUCI_DB_PASSWORD in production.
DB_PASS="${TILBUCI_DB_PASSWORD:-}"
DB_PASS_DEFAULT="S3nh4Dogg0"
MARKER="${TILBUCI_DATA_DIR}/.tilbuci-installed"
PASS_FILE="${TILBUCI_DATA_DIR}/.db_password"

TMP_PID=""
cleanup_tmp_db() {
    if [ -n "${TMP_PID}" ] && kill -0 "${TMP_PID}" 2>/dev/null; then
        mysqladmin --socket="${TILBUCI_MYSQL_SOCKET}" -u root shutdown >/dev/null 2>&1 \
            || kill "${TMP_PID}" >/dev/null 2>&1 || true
        wait "${TMP_PID}" 2>/dev/null || true
    fi
    TMP_PID=""
}

# ---------------------------------------------------------------------------
# 1. Base directories and permissions
# ---------------------------------------------------------------------------
ensure_base_dirs
chown -R mysql:mysql "${TILBUCI_DATA_DIR}/mysql" 2>/dev/null || true
chown mysql:mysql /run/mysqld 2>/dev/null || true

# ---------------------------------------------------------------------------
# 2. Database password (default: S3nh4Dogg0; overridable and persisted)
# ---------------------------------------------------------------------------
if [ -z "${DB_PASS}" ]; then
    if [ -f "${PASS_FILE}" ]; then
        DB_PASS="$(cat "${PASS_FILE}")"
    else
        DB_PASS="${DB_PASS_DEFAULT}"
        printf '%s' "${DB_PASS}" > "${PASS_FILE}"
        chmod 600 "${PASS_FILE}"
    fi
fi

# ---------------------------------------------------------------------------
# 3. Initialize the MariaDB data directory when empty
# ---------------------------------------------------------------------------
if [ ! -d "${TILBUCI_DATA_DIR}/mysql/mysql" ]; then
    log "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir="${TILBUCI_DATA_DIR}/mysql" >/dev/null
fi

# ---------------------------------------------------------------------------
# 4. Persistence: link the media folders into the public root right away so
#    files created by the installer run land inside the volume.
# ---------------------------------------------------------------------------
mkdir -p "${TILBUCI_PUBLIC}"
apply_dir_symlinks

# ---------------------------------------------------------------------------
# 5. Start a temporary MariaDB server for provisioning and installation
# ---------------------------------------------------------------------------
log "Starting temporary MariaDB server..."
mariadbd --user=mysql \
    --datadir="${TILBUCI_DATA_DIR}/mysql" \
    --socket="${TILBUCI_MYSQL_SOCKET}" \
    --bind-address=127.0.0.1 >/dev/null 2>&1 &
TMP_PID=$!
trap cleanup_tmp_db EXIT

for _ in $(seq 1 60); do
    [ -S "${TILBUCI_MYSQL_SOCKET}" ] && break
    sleep 1
done
if [ ! -S "${TILBUCI_MYSQL_SOCKET}" ]; then
    log "ERROR: MariaDB did not start (socket ${TILBUCI_MYSQL_SOCKET} not found)."
    exit 1
fi

# ---------------------------------------------------------------------------
# 6. Provision database and internal user (idempotent)
# ---------------------------------------------------------------------------
log "Ensuring database '${DB_NAME}' and user '${DB_USER}'..."
mysql --socket="${TILBUCI_MYSQL_SOCKET}" -u root <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

# ---------------------------------------------------------------------------
# 7. First run (browser-driven) vs existing installation
#
# On the first run nothing is asked at startup: the container starts exactly
# like subsequent runs and the application root redirects to the installer
# (setup.php?docker=true). A helper running under supervisord detects the
# completed installation, persists the configuration and removes the installer.
# Updates keep the previous behaviour (see ensure_application_files).
# ---------------------------------------------------------------------------
if is_installed; then
    log "Existing installation detected."
    restore_installer
    cleanup_setup_entry
    # The application files are not persistent; restore them when missing
    # (e.g. after the container is recreated with an existing volume).
    ensure_application_files
    preserve_files
    apply_dir_symlinks
    fix_permissions
    [ -f "${MARKER}" ] || touch "${MARKER}"
else
    log "First run detected: the installer will run from the browser."
    restore_installer
    apply_dir_symlinks
    ensure_setup_redirect
    # The installer runs as the web server user (www-data), so the tree must be
    # writable by it before Apache starts.
    fix_permissions
    log "Open the application address to finish the installation (setup.php?docker=true)."
fi

# ---------------------------------------------------------------------------
# 8. Keep the stored base URL in sync, then hand over to supervisord
# ---------------------------------------------------------------------------
if is_installed; then
    apply_base_url
fi
cleanup_tmp_db
trap - EXIT

log "Handing over to supervisord."
exec "$@"
