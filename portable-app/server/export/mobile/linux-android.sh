echo "Preparing icon..."
npx capacitor-assets generate --android
echo "Synchronizing content..."
npx cap sync android
echo "Starting Android Studio..."
npx cap open android