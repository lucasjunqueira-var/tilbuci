echo "Preparing icons..."
mkdir -p icons
./node_modules/.bin/electron-icon-maker --input=favicon.png --output=./
cp -R ./icons/mac/* icons
cp -R ./icons/win/* icons
cp -R ./icons/png/* icons
echo "Creating desktop app..."
npx electron-forge package --arch x64
npx electron-forge package --arch arm64
open ./out
echo "Your app was created at the out folder for both Intel (x64) and Silicon (arm64) platforms."