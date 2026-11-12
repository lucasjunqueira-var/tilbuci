#!/usr/bin/env bash
# Shared helpers for the TilBuci container entrypoint and update tool.
# This file is meant to be sourced, it does not execute anything on its own.

# Default paths (overridable through the environment).
TILBUCI_ROOT="${TILBUCI_ROOT:-/var/www/tilbuci}"
TILBUCI_PUBLIC="${TILBUCI_PUBLIC:-${TILBUCI_ROOT}/public_html}"
TILBUCI_INSTALLER="${TILBUCI_INSTALLER:-/opt/tilbuci-installer}"
TILBUCI_DATA_DIR="${TILBUCI_DATA_DIR:-/data}"

TILBUCI_MYSQL_SOCKET="${TILBUCI_MYSQL_SOCKET:-/run/mysqld/mysqld.sock}"

log() {
    echo "[tilbuci] $*"
}

# Create the base directories inside the persistent volume.
ensure_base_dirs() {
    mkdir -p "${TILBUCI_DATA_DIR}"/{app,movie,font,sites,pwa,mysql}
    mkdir -p "${TILBUCI_ROOT}/app" "${TILBUCI_PUBLIC}/app"
    mkdir -p /run/mysqld
}

# Copy the pristine installer back into the public web root.
# The TilBuci installer deletes its own files after a successful run, so this
# is required before every install or update.
restore_installer() {
    if [ -d "${TILBUCI_INSTALLER}" ]; then
        cp -a "${TILBUCI_INSTALLER}"/. "${TILBUCI_PUBLIC}"/
    fi
}

# Symlink the persistent directories into the public web root.
# Applied on every boot so that it survives image updates that overwrite files.
apply_dir_symlinks() {
    ln -sfn "${TILBUCI_DATA_DIR}/movie" "${TILBUCI_PUBLIC}/movie"
    ln -sfn "${TILBUCI_DATA_DIR}/font"  "${TILBUCI_PUBLIC}/font"
    ln -sfn "${TILBUCI_DATA_DIR}/sites" "${TILBUCI_PUBLIC}/sites"
    ln -sfn "${TILBUCI_DATA_DIR}/pwa"   "${TILBUCI_PUBLIC}/pwa"
}

# Adopt the persistent files into /data and replace them with symlinks.
# Must run AFTER a successful installation (or on a boot where the install
# marker already exists), because the installer decides between "new install"
# and "update" by checking whether app/Config.php exists.
preserve_files() {
    _adopt() {
        local real="$1" data="$2"
        if [ -e "${real}" ] && [ ! -L "${real}" ]; then
            cp -a "${real}" "${data}" 2>/dev/null || true
        fi
        rm -f "${real}"
        [ -e "${data}" ] || : > "${data}"
        ln -sfn "${data}" "${real}"
    }

    _adopt "${TILBUCI_ROOT}/app/Config.php"     "${TILBUCI_DATA_DIR}/app/Config.php"
    _adopt "${TILBUCI_PUBLIC}/app/player.json"  "${TILBUCI_DATA_DIR}/app/player.json"
    _adopt "${TILBUCI_PUBLIC}/app/editor.json"  "${TILBUCI_DATA_DIR}/app/editor.json"
}

# Restore ownership of the persistent data to the web server user.
fix_permissions() {
    chown -R www-data:www-data \
        "${TILBUCI_DATA_DIR}/app" \
        "${TILBUCI_DATA_DIR}/movie" \
        "${TILBUCI_DATA_DIR}/font" \
        "${TILBUCI_DATA_DIR}/sites" \
        "${TILBUCI_DATA_DIR}/pwa" 2>/dev/null || true
    chown -R www-data:www-data "${TILBUCI_ROOT}" 2>/dev/null || true
}

# Remove the installer (setup.php and the setup/ folder) from the public root
# once installed or updated, unless the user explicitly asked to keep it for
# debugging. The ws/ folder is part of TilBuci and is never touched here.
cleanup_setup_entry() {
    if [ "${TILBUCI_KEEP_SETUP:-false}" != "true" ]; then
        rm -f "${TILBUCI_PUBLIC}/setup.php"
        rm -rf "${TILBUCI_PUBLIC}/setup"
    fi
}

# Synchronize the public base URL stored in Config.php/player.json/editor.json
# with the desired URL (TILBUCI_URL). The container cannot discover the host
# port by itself, so the public URL must be provided; when it is empty this is
# a no-op and the existing value is preserved.
apply_base_url() {
    local desired="${TILBUCI_URL:-}"
    [ -z "${desired}" ] && return 0
    case "${desired}" in
        */) ;;
        *) desired="${desired}/" ;;
    esac

    local current=""
    if [ -s "${TILBUCI_ROOT}/app/Config.php" ]; then
        current="$(php -r 'include $argv[1]; echo isset($gconf["path"]) ? $gconf["path"] : "";' \
            "${TILBUCI_ROOT}/app/Config.php" 2>/dev/null || true)"
    fi

    if [ "${desired}" != "${current}" ]; then
        log "Setting base URL to ${desired} (was: ${current:-<none>})"
        php /usr/local/bin/tilbuci-set-url.php "${desired}" \
            || log "WARNING: could not update the base URL."
    fi
}

# Read the installed database version. Empty when the database (or the config
# table) is not available yet.
installed_db_version() {
    local out=""
    if [ -S "${TILBUCI_MYSQL_SOCKET}" ]; then
        out="$(mysql --socket="${TILBUCI_MYSQL_SOCKET}" -u root -N -B \
            -e "SELECT cf_value FROM config WHERE cf_key='dbVersion' LIMIT 1;" \
            "${TILBUCI_DB_NAME:-tilbuci}" 2>/dev/null || true)"
    fi
    printf '%s' "${out}"
}

# Read the version advertised by the bundled installer (setup.php).
installer_version() {
    local file="${TILBUCI_INSTALLER}/setup.php"
    if [ ! -f "${file}" ]; then
        printf ''
        return 0
    fi
    sed -n "s/.*'num'[[:space:]]*=>[[:space:]]*\([0-9][0-9]*\).*/\1/p" "${file}" | head -n1
}

# Dump the database to /data/backups before a migration.
backup_database() {
    if [ ! -S "${TILBUCI_MYSQL_SOCKET}" ]; then
        return 0
    fi
    local dir="${TILBUCI_DATA_DIR}/backups"
    mkdir -p "${dir}"
    local stamp file
    stamp="$(date +%Y%m%d%H%M%S)"
    file="${dir}/pre-update-${1:-unknown}-${stamp}.sql"
    if mariadb-dump --socket="${TILBUCI_MYSQL_SOCKET}" -u root \
        "${TILBUCI_DB_NAME:-tilbuci}" > "${file}" 2>/dev/null; then
        log "Database backup written to ${file}"
    else
        log "WARNING: could not back up the database."
    fi
}

# Ensure the application files are present and up to date.
#
# The application files (from part1/part2/part3.zip) are NOT persistent: they
# live only inside the container filesystem. This function:
#   - re-extracts them when they are missing (container recreated); and
#   - runs a full update (database migration + files) when the version stored
#     in the database is older than the bundled installer version, after
#     backing up the database.
# The persisted configuration is preserved across the operation.
ensure_application_files() {
    local files_present=0
    if [ -f "${TILBUCI_PUBLIC}/editor/index.php" ]; then
        files_present=1
    fi

    local current installer action=""
    current="$(installed_db_version)"
    installer="$(installer_version)"

    # Only compare when both values are numeric.
    case "${current}" in ''|*[!0-9]*) current="" ;; esac
    case "${installer}" in ''|*[!0-9]*) installer="" ;; esac

    if [ -n "${current}" ] && [ -n "${installer}" ] \
        && [ "${current}" -lt "${installer}" ] \
        && [ "${TILBUCI_AUTO_UPDATE:-true}" = "true" ]; then
        action="3"
        log "TilBuci update available: database ${current} -> installer ${installer}."
    elif [ "${files_present}" -eq 0 ]; then
        action="4"
        log "Application files not found; restoring them from the installer..."
    else
        return 0
    fi

    restore_installer

    if [ "${action}" = "3" ]; then
        backup_database "${current}"
    fi

    # Back up the persisted configuration around the operation.
    local backup="${TILBUCI_DATA_DIR}/.restore"
    mkdir -p "${backup}"
    if [ -f "${TILBUCI_DATA_DIR}/app/Config.php" ]; then
        cp -a "${TILBUCI_DATA_DIR}/app/Config.php" "${backup}/Config.php"
    fi
    if [ -f "${TILBUCI_DATA_DIR}/app/player.json" ]; then
        cp -a "${TILBUCI_DATA_DIR}/app/player.json" "${backup}/player.json"
    fi
    if [ -f "${TILBUCI_DATA_DIR}/app/editor.json" ]; then
        cp -a "${TILBUCI_DATA_DIR}/app/editor.json" "${backup}/editor.json"
    fi

    # Materialize real files so the installer can read the configuration.
    mkdir -p "${TILBUCI_ROOT}/app" "${TILBUCI_PUBLIC}/app"
    rm -f "${TILBUCI_ROOT}/app/Config.php" \
          "${TILBUCI_PUBLIC}/app/player.json" \
          "${TILBUCI_PUBLIC}/app/editor.json"
    if [ -f "${backup}/Config.php" ]; then
        cp -a "${backup}/Config.php" "${TILBUCI_ROOT}/app/Config.php"
    fi
    if [ -f "${backup}/player.json" ]; then
        cp -a "${backup}/player.json" "${TILBUCI_PUBLIC}/app/player.json"
    fi
    if [ -f "${backup}/editor.json" ]; then
        cp -a "${backup}/editor.json" "${TILBUCI_PUBLIC}/app/editor.json"
    fi

    local args=(--action="${action}" "--url=${TILBUCI_URL:-http://localhost/}")
    if [ "${action}" = "3" ]; then
        args+=(--current="${current}")
    fi
    php /usr/local/bin/tilbuci-install.php "${args[@]}" \
        || log "WARNING: the installer reported an error (action ${action})."

    # Restore the persisted configuration and drop the temporary real files.
    rm -f "${TILBUCI_ROOT}/app/Config.php" \
          "${TILBUCI_PUBLIC}/app/player.json" \
          "${TILBUCI_PUBLIC}/app/editor.json"
    if [ -f "${backup}/Config.php" ]; then
        cp -a "${backup}/Config.php" "${TILBUCI_DATA_DIR}/app/Config.php"
    fi
    if [ -f "${backup}/player.json" ]; then
        cp -a "${backup}/player.json" "${TILBUCI_DATA_DIR}/app/player.json"
    fi
    if [ -f "${backup}/editor.json" ]; then
        cp -a "${backup}/editor.json" "${TILBUCI_DATA_DIR}/app/editor.json"
    fi
    rm -rf "${backup}"

    cleanup_setup_entry
    if [ "${action}" = "3" ]; then
        log "Update finished."
    else
        log "Application files restored."
    fi
}

# True when TilBuci is already installed (marker present or a saved Config.php).
is_installed() {
    [ -f "${TILBUCI_DATA_DIR}/.tilbuci-installed" ] || [ -s "${TILBUCI_DATA_DIR}/app/Config.php" ]
}

# First-run helper: make the application root load the installer with the
# docker flag (setup.php?docker=true), so the first visit to the address
# completes the installation from the browser.
ensure_setup_redirect() {
    if [ -f "${TILBUCI_PUBLIC}/setup.php" ]; then
        cat > "${TILBUCI_PUBLIC}/index.php" <<'PHP'
<?php
// Temporary first-run redirect (replaced by the installer and removed
// automatically once the installation is complete).
header('Location: setup.php?docker=true');
echo 'Redirecting to the TilBuci installer...';
PHP
        chown www-data:www-data "${TILBUCI_PUBLIC}/index.php" 2>/dev/null || true
    fi
}
