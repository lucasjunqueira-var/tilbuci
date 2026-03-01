echo "Installing Electron..."
cp package.ori package.json
npm install --save-dev electron
echo "Installing Electron Forge..."
npm install --save-dev @electron-forge/cli
echo "Configuring Electron Forge..."
npx electron-forge import
echo "Installing icon manager..."
npm install --save-dev electron-icon-maker
echo "Adjusting Forge configuration..."
node adjust-forge.mjs
echo "Finished!"