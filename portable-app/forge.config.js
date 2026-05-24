/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
 module.exports = {
  packagerConfig: {
    asar: false, 
    icon: 'images/tilbuciIcon'
  },
  makers: [
    {
      name: '@electron-forge/maker-squirrel',
      config: {
        name: 'TilBuci'
      }
    }, 
    {
      "name": "@electron-forge/maker-dmg",
      "config": {
        "format": "ULFO", 
        icon: 'images/tilbuciIcon.icns'
      }
    },
    {
      name: '@electron-forge/maker-deb',
        config: {
          options: {
            icon: 'images/tilbuciIcon.png'
          }
      }
    }
  ]
};
