This is your Apache Cordova project. It can be used to create Android and iOS/iPadOS apps. The "[APPID]" folder contains the entire project that should be used for its first generation. If you have already generated apps from your movie using Apache Cordova, avoid using this export method: instead, generate only the update files and copy them to the "www" folder of your project. Avoid saving your Apache Cordova project on a folder with spaces of special characters on path/name.

To begin, install Apache Cordova on your computer following the instructions found at https://cordova.apache.org/#getstarted - in short, install node.js/npm (https://nodejs.org/) and run the command "npm install -g cordova".

Then, using your system's terminal, access the project folder. Use the command "cordova run browser" to test the results in your browser.

To build Android apps, follow the Apache Cordova setup steps found here: https://cordova.apache.org/docs/en/12.x/guide/platforms/android/index.html (this only needs to be done the first time you build an Android app).

After that, run the "cordova platform add android" command in your terminal to enable Android apk export. Use the "cordova build android" command to produce the file.

The process for building apps for iOS/iPadOS is similar, but should always be done on macOS computers. First, follow the setup instructions at https://cordova.apache.org/docs/en/12.x/guide/platforms/ios/index.html (again, this process only needs to be done the first time you build an iOS app).

After that, run the "cordova platform add ios" command. The process for building and distributing your app is described in the previous link.

There are several ways to customize your app, such as defining platform-specific icons (https://cordova.apache.org/docs/en/12.x/config_ref/images.html).