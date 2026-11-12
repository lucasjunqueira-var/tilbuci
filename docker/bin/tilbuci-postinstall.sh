#!/usr/bin/env bash
#
# First-run completion watcher.
#
# When the container starts for the first time, the installation is completed
# from the browser through setup.php?docker=true. This helper waits for the
# installer to write its configuration, then persists those files into the
# volume, removes the installer and marks the installation as done.
#
# It runs under supervisord and exits immediately when already installed.
#
set -euo pipefail

# shellcheck source=/dev/null
source /usr/local/bin/tilbuci-common.sh

MARKER="${TILBUCI_DATA_DIR}/.tilbuci-installed"

if is_installed; then
    exit 0
fi

log "Waiting for the browser-based installation to complete..."
for _ in $(seq 1 3600); do
    if [ -s "${TILBUCI_ROOT}/app/Config.php" ] \
        && [ -s "${TILBUCI_PUBLIC}/app/player.json" ] \
        && [ -s "${TILBUCI_PUBLIC}/app/editor.json" ]; then
        break
    fi
    sleep 2
done

if [ ! -s "${TILBUCI_ROOT}/app/Config.php" ]; then
    log "No installation detected yet; restart the container to try again."
    exit 0
fi

# Give the installer a moment to finish writing the remaining files.
sleep 2

preserve_files
apply_dir_symlinks
fix_permissions

# Remove the temporary first-run redirect if the application did not replace it.
if [ -f "${TILBUCI_PUBLIC}/index.php" ] \
    && grep -q 'setup.php?docker=true' "${TILBUCI_PUBLIC}/index.php" 2>/dev/null; then
    rm -f "${TILBUCI_PUBLIC}/index.php"
fi

cleanup_setup_entry
touch "${MARKER}"
log "First-run installation completed and persisted."
exit 0
