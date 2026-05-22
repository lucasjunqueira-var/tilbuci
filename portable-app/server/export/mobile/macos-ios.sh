#!/bin/zsh
echo "Preparing icon..."
npx capacitor-assets generate --ios
echo "Synchronizing content..."
npx cap sync ios
echo "Starting XCode..."
npx cap open ios