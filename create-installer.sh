#!/bin/bash

set -e  # Exit on any error

echo "========================================="
echo "TilBuci Installer Creation Script"
echo "========================================="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required commands
if ! command_exists zip; then
    echo "ERROR: 'zip' command is required but not installed."
    echo "Please install zip (e.g., 'sudo apt install zip' or 'brew install zip') and try again."
    exit 1
fi

if ! command_exists java; then
    echo "WARNING: Java is not installed. Minification step will fail."
    echo "You may install Java (OpenJDK) before running this script."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Step 1: creating the full Javascript file
echo "Step 1: Creating the full Javascript file..."
if [ -f "deploy-full.sh" ]; then
    ./deploy-full.sh
else
    echo "ERROR: deploy-full.sh not found in current directory."
    exit 1
fi

# Step 2: creating the runtime files
echo "Step 2: Creating the runtime files..."
if [ -f "deploy-runtime.sh" ]; then
    ./deploy-runtime.sh
else
    echo "ERROR: deploy-runtime.sh not found in current directory."
    exit 1
fi

# Step 3: minification
echo "Step 3: Minifying Javascript files..."
if [ -f "minimize-js.sh" ]; then
    ./minimize-js.sh
else
    echo "ERROR: minimize-js.sh not found in current directory."
    exit 1
fi

# Step 4: removing old files
echo "Step 4: Removing old part zip files..."
PART_DIR="./setup/setup"
if [ -d "$PART_DIR" ]; then
    rm -f "$PART_DIR/part1.zip" "$PART_DIR/part2.zip" "$PART_DIR/part3.zip"
    echo "Old part zip files removed."
else
    echo "WARNING: $PART_DIR does not exist. Creating it."
    mkdir -p "$PART_DIR"
fi

# Step 5: creating part1.zip
echo "Step 5: Creating part1.zip..."
cd server || { echo "ERROR: server directory not found."; exit 1; }
PART1_ZIP="../setup/setup/part1.zip"
# Remove existing zip if any
rm -f "$PART1_ZIP"
# Create zip with specified contents, excluding certain file types
zip -r "$PART1_ZIP" \
    app/ \
    -x "app/Config.php" \
    -x "app/Config - example.php" \
    -x "*.pdf" -x "*.zip" -x "*.psd" -x "*.kra"
# Add events/events.txt
if [ -f "events/events.txt" ]; then
    zip -r "$PART1_ZIP" events/events.txt
else
    echo "WARNING: events/events.txt not found, skipping."
fi
# Add export folders
for folder in desktop iframe mobile publish pwa runtimes site; do
    if [ -d "export/$folder" ]; then
        zip -r "$PART1_ZIP" "export/$folder"
    else
        echo "WARNING: export/$folder not found, skipping."
    fi
done
# Add language/langDefault.json
if [ -f "language/langDefault.json" ]; then
    zip -r "$PART1_ZIP" language/langDefault.json
else
    echo "WARNING: language/langDefault.json not found, skipping."
fi
cd ..
echo "part1.zip created."

# Step 6: creating part2.zip
echo "Step 6: Creating part2.zip..."
cd server/public_html || { echo "ERROR: server/public_html directory not found."; exit 1; }
PART2_ZIP="../../setup/setup/part2.zip"
rm -f "$PART2_ZIP"
# Add app folder excluding certain files
zip -r "$PART2_ZIP" \
    app/ \
    -x "app/editor.json" \
    -x "app/player.json" \
    -x "app/editor - example.json" \
    -x "app/player - example.json" \
    -x "*.pdf" -x "*.zip" -x "*.psd" -x "*.kra"
# Add download/index.php
if [ -f "download/index.php" ]; then
    zip -r "$PART2_ZIP" download/index.php
else
    echo "WARNING: download/index.php not found, skipping."
fi
# Add editor/index.php
if [ -f "editor/index.php" ]; then
    zip -r "$PART2_ZIP" editor/index.php
else
    echo "WARNING: editor/index.php not found, skipping."
fi
# Add specific font files
for font in averiaserifgwf.woff2 liberationserif.woff2 librasans.woff2 roboto.woff2; do
    if [ -f "font/$font" ]; then
        zip -r "$PART2_ZIP" "font/$font"
    else
        echo "WARNING: font/$font not found, skipping."
    fi
done
# Add movie/movie.txt
if [ -f "movie/movie.txt" ]; then
    zip -r "$PART2_ZIP" movie/movie.txt
else
    echo "WARNING: movie/movie.txt not found, skipping."
fi
# Add ws/index.php and ws/launcher.php
if [ -f "ws/index.php" ]; then
    zip -r "$PART2_ZIP" ws/index.php
fi
if [ -f "ws/launcher.php" ]; then
    zip -r "$PART2_ZIP" ws/launcher.php
fi
# Add license.txt
if [ -f "license.txt" ]; then
    zip -r "$PART2_ZIP" license.txt
else
    echo "WARNING: license.txt not found, skipping."
fi
cd ../..
echo "part2.zip created."

# Step 7: creating part3.zip
echo "Step 7: Creating part3.zip..."
cd server/public_html || { echo "ERROR: server/public_html directory not found."; exit 1; }
PART3_ZIP="../../setup/setup/part3.zip"
rm -f "$PART3_ZIP"
# Add index.php and VisitorTerms.txt
if [ -f "index.php" ]; then
    zip -r "$PART3_ZIP" index.php
else
    echo "WARNING: index.php not found, skipping."
fi
if [ -f "VisitorTerms.txt" ]; then
    zip -r "$PART3_ZIP" VisitorTerms.txt
else
    echo "WARNING: VisitorTerms.txt not found, skipping."
fi
cd ../..
echo "part3.zip created."

# Step 8: finishing the installer
echo "Step 8: Finishing the installer..."
cd setup || { echo "ERROR: setup directory not found."; exit 1; }
FINAL_ZIP="TilBuci_webinstall_update_NEW.zip"
# Delete old zip if exists
rm -f "$FINAL_ZIP"
# Create new zip with contents of setup folder, README.txt, setup.php
zip -r "$FINAL_ZIP" setup/ README.txt setup.php
echo "$FINAL_ZIP created."
cd ..

echo "========================================="
echo "TilBuci installer creation completed!"
echo "The final installer is at: setup/TilBuci_webinstall_update_NEW.zip"
echo "========================================="