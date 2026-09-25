#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# TilBuci Showtime (desktop) - test launcher (Linux / macOS)
#
# Prepares the environment and starts the Electron application in test mode.
# Usage: ./test.sh   (run "chmod +x test.sh" once to make it executable)
# ---------------------------------------------------------------------------

set -o pipefail

# Always operate from the folder that contains this script.
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1

PORT=8080

# Wait for the user only when running interactively, so the script can also be
# used from other scripts or CI jobs.
pause() {
    if [ -t 0 ]; then
        read -r -p "Press Enter to close..." _
    fi
}

die() {
    echo "[error] $1"
    pause
    exit 1
}

# Resolve the folder Electron uses for app.getPath('documents')
showtime_data_dir() {
    local docs="" entry="" xdg_config="$HOME/.config/user-dirs.dirs"

    case "$(uname -s)" in
        Darwin*)
            docs="$HOME/Documents"
            ;;
        Linux*)
            # Electron follows the XDG user directories configuration on Linux.
            if [ -f "$xdg_config" ]; then
                entry=$(grep -m1 '^XDG_DOCUMENTS_DIR=' "$xdg_config" 2>/dev/null | cut -d'"' -f2)
                if [ -n "$entry" ]; then
                    # expand the $HOME placeholder used by the XDG configuration
                    entry=${entry//\$HOME/$HOME}
                    docs="$entry"
                fi
            fi
            [ -n "$docs" ] || docs="$HOME/Documents"
            ;;
        *)
            docs="$HOME/Documents"
            ;;
    esac

    printf '%s/TBShowtime\n' "$docs"
}

# True when something is already listening on the local server port
port_busy() {
    if command -v lsof >/dev/null 2>&1; then
        lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1
        return $?
    fi
    # Fallback that only needs Node.js
    node -e "const s=require('net').connect({port:$PORT,host:'127.0.0.1'});s.on('connect',()=>{s.destroy();process.exit(0)});s.on('error',()=>process.exit(1));"
    return $?
}

# Terminate whatever is listening on the local server port
close_running_instance() {
    if ! command -v lsof >/dev/null 2>&1; then
        echo "[warn] lsof is not available, please close the running instance manually."
        return
    fi

    local pids pid
    # sort -u drops the duplicates reported for IPv4 and IPv6
    pids=$(lsof -t -nP -iTCP:"$PORT" -sTCP:LISTEN 2>/dev/null | sort -u)
    if [ -z "$pids" ]; then
        echo "[warn] could not identify the process holding port $PORT."
        return
    fi

    for pid in $pids; do
        kill -TERM "$pid" 2>/dev/null || true
    done
    sleep 1

    pids=$(lsof -t -nP -iTCP:"$PORT" -sTCP:LISTEN 2>/dev/null | sort -u)
    for pid in $pids; do
        kill -9 "$pid" 2>/dev/null || true
    done

    echo "[setup] previous instance closed."
}

echo "============================================================"
echo " TilBuci Showtime - desktop test"
echo "============================================================"
echo

# ---------------------------------------------------------------------------
# 1. Node.js availability
# ---------------------------------------------------------------------------
if ! command -v node >/dev/null 2>&1; then
    die "Node.js was not found in PATH. Install Node.js 18 or newer and try again."
fi

# ---------------------------------------------------------------------------
# 2. Environment sanitizing
# ---------------------------------------------------------------------------
# The VS Code integrated terminal exports ELECTRON_RUN_AS_NODE=1. With that
# variable set, Electron starts as plain Node and the application fails with
# "Cannot read properties of undefined (reading 'whenReady')".
unset ELECTRON_RUN_AS_NODE

# ---------------------------------------------------------------------------
# 3. Dependencies
# ---------------------------------------------------------------------------
if [ ! -d "node_modules/electron" ]; then
    echo "[setup] node_modules is missing, installing dependencies..."
    if ! npm install; then
        die "\"npm install\" failed."
    fi
fi

# ---------------------------------------------------------------------------
# 4. Native serialport binding
# ---------------------------------------------------------------------------
# node-gyp-build looks inside node_modules/@serialport/bindings-cpp/build/Release
# BEFORE the prebuilt binaries in the "prebuilds" folder. A leftover local build
# made for another architecture therefore shadows the matching prebuild and
# loading fails. When the binding cannot be loaded, the stale local build is
# removed so the prebuilt binary is used instead.
binding_loads() {
    node -e "require('node-gyp-build')(require('path').join(process.cwd(),'node_modules','@serialport','bindings-cpp'))" >/dev/null 2>&1
}

if ! binding_loads; then
    echo "[setup] serialport native binding failed to load."
    if [ -d "node_modules/@serialport/bindings-cpp/build" ]; then
        echo "[setup] removing the stale local build, using prebuilt binaries instead..."
        rm -rf "node_modules/@serialport/bindings-cpp/build"
    fi

    if ! binding_loads; then
        die "the serialport native binding still cannot be loaded. Run a clean reinstall with \"npm ci\" and try again."
    fi
fi

# ---------------------------------------------------------------------------
# 5. Local server port
# ---------------------------------------------------------------------------
# The application serves its content on http://localhost:PORT, so a second
# instance cannot bind the port. A running instance is closed on request.
if port_busy; then
    echo "[warn] port $PORT is already in use, another instance may be running."
    printf "Close the running instance and continue? [Y/N] "
    read -r answer
    case "$answer" in
        [Yy]*) close_running_instance ;;
    esac
fi

# ---------------------------------------------------------------------------
# 6. Run the application
# ---------------------------------------------------------------------------
echo
echo "[run] content:   http://localhost:$PORT"
echo "[run] settings:  http://localhost:$PORT/config/config.html"
echo "[run] local data: $(showtime_data_dir)"
echo "[run] test REST routes: http://localhost:$PORT/api/name, /api/setval, /api/getval"
echo "[run] leave kiosk mode by clicking the top-left corner 5 times (accesskey AAAAA)"
echo "[run] starting the application..."
echo

npm start

echo
echo "[run] the application has exited."
pause
