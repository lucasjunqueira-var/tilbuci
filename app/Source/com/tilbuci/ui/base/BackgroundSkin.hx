/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.base;

/** FEATHERS UI **/
import feathers.skins.RectangleSkin;

/**
    Default interface background skin.
**/
class BackgroundSkin extends RectangleSkin {

    public function new(color:Int = 0x666666) {
        super();
        this.fill = SolidColor(color);
    }

}