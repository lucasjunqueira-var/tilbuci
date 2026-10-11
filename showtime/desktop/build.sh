#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# TilBuci Showtime (desktop) - build (Linux / macOS)
#
# Equivalent to "npm run build:linux" or "npm run build:mac": generates both the
# x64 and the arm64 unpacked builds for the current platform using the locally
# installed electron-builder.
#
# Output folders:
#   macOS: dist/mac            and dist/mac-arm64
#   Linux: dist/linux-unpacked and dist/linux-arm64-unpacked
#
# Note: electron-builder rebuilds the native serialport module for each target
# architecture, so after the build node_modules/@serialport/bindings-cpp
# /build/Release holds the binding of the last built architecture (arm64).
# Because node-gyp-build checks that folder before the prebuilt binaries, that
# leftover breaks local "npm start" / "./test.sh" runs. The script therefore
# validates the binding when the build finishes and removes the leftover, so
# the correct prebuilt binary is used again.
#
# Usage:
#   ./build.sh                builds the current platform for x64 and arm64
#   ./build.sh <arguments>    forwards the arguments to electron-builder,
#                             e.g. ./build.sh --mac --x64
#
# Run "chmod +x build.sh" once to make it executable.
# ---------------------------------------------------------------------------

set -o pipefail

# Always operate from the folder that contains this script.
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1

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

# electron-builder arguments used when none is given
default_build_args() {
    case "$(uname -s)" in
        Darwin*) printf '%s\n' "--mac --x64 --arm64" ;;
        Linux*)  printf '%s\n' "--linux --x64 --arm64" ;;
        *)       printf '%s\n' "--x64 --arm64" ;;
    esac
}

# Unpacked output folders of the current platform
output_dirs() {
    case "$(uname -s)" in
        Darwin*) printf '%s\n' "dist/mac" "dist/mac-arm64" ;;
        Linux*)  printf '%s\n' "dist/linux-unpacked" "dist/linux-arm64-unpacked" ;;
    esac
}

# True when the native serialport binding can be loaded on this machine
binding_loads() {
    node -e "require('node-gyp-build')(require('path').join(process.cwd(),'node_modules','@serialport','bindings-cpp'))" >/dev/null 2>&1
}

echo "============================================================"
echo " TilBuci Showtime - desktop build"
echo "============================================================"
echo

# ---------------------------------------------------------------------------
# 1. Node.js availability
# ---------------------------------------------------------------------------
if ! command -v node >/dev/null 2>&1; then
    die "Node.js was not found in PATH. Install Node.js 18 or newer and try again."
fi

# ---------------------------------------------------------------------------
# 2. Dependencies
# ---------------------------------------------------------------------------
if [ ! -d "node_modules/electron-builder" ]; then
    echo "[setup] node_modules is missing, installing dependencies..."
    if ! npm install; then
        die "\"npm install\" failed."
    fi
fi

# ---------------------------------------------------------------------------
# 3. Build arguments
# ---------------------------------------------------------------------------
if [ "$#" -gt 0 ]; then
    build_args="$*"
else
    build_args=$(default_build_args)
fi

# ---------------------------------------------------------------------------
# 4. Clean the previous outputs
# ---------------------------------------------------------------------------
# A build interrupted while renaming its output leaves an intermediate
# "<target>.tmp" folder behind. Outputs and leftovers are removed so the new
# build starts from a clean state.
for dir in $(output_dirs); do
    if [ -d "$dir" ]; then
        echo "[setup] removing previous output: $dir"
        rm -rf "$dir"
    fi
done

for tmp in dist/*.tmp; do
    [ -e "$tmp" ] || continue
    echo "[setup] removing leftover intermediate output: $tmp"
    rm -rf "$tmp"
done

# ---------------------------------------------------------------------------
# 5. Build
# ---------------------------------------------------------------------------
echo
echo "[build] electron-builder $build_args"
echo "[build] the first run downloads the Electron binaries, this may take a while."
echo

# shellcheck disable=SC2086
./node_modules/.bin/electron-builder $build_args
build_result=$?

echo
if [ "$build_result" -ne 0 ]; then
    echo "[error] the build failed with exit code $build_result."
    echo "[error] review the output above for the reason."
    echo "[hint]  file lock errors such as \"EBUSY\" or \"permission denied\" are"
    echo "[hint]  usually caused by something using the dist folder. Close it and"
    echo "[hint]  run build.sh again."
    pause
    exit "$build_result"
fi

# ---------------------------------------------------------------------------
# 6. Restore the native binding for local development
# ---------------------------------------------------------------------------
# The native module now matches the last built architecture. If it no longer
# loads on this machine, it is removed so the prebuilt binary is used again.
if ! binding_loads; then
    echo "[setup] restoring the native serialport binding for local runs..."
    if [ -d "node_modules/@serialport/bindings-cpp/build" ]; then
        rm -rf "node_modules/@serialport/bindings-cpp/build"
    fi

    if binding_loads; then
        echo "[setup] native binding restored."
    else
        echo "[warn]  could not restore the native binding. Run test.sh, or \"npm ci\","
        echo "[warn]  before running \"npm start\"."
    fi
fi

echo "[done] build finished successfully."
for dir in $(output_dirs); do
    if [ -d "$dir" ]; then
        echo "[done] output: $dir"
    fi
done
echo "[done] the packaged application is inside the output folder above."
echo "[done] it stores its data in the user's Documents/TBShowtime folder."
echo
pause
