echo "Installing Capacitor..."
cp package.ori package.json
npm install @capacitor/cli @capacitor/core
echo "Installing status bar plugin..."
npm install @capacitor/status-bar
echo "Installing file system plugin..."
npm install @capacitor/filesystem
echo "Installing navigation bar plugin..."
npm install @squareetlabs/capacitor-navigation-bar
echo "Installing app plugin..."
npm install @capacitor/app
echo "Installing assets handler..."
npm install @capacitor/assets --save-dev
echo "Installing kiosk mode support..."
npm npm install @capgo/capacitor-android-kiosk
echo "Preparing Android environment..."
npm install @capacitor/android
echo "Adding the Android platform..."
npx cap add android
echo "App setup process completed successfully!"