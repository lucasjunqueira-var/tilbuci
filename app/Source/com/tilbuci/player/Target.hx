/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package com.tilbuci.player;

/** OPENFL **/
import com.tilbuci.data.GlobalPlayer;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class Target extends Sprite {

    private var _bmp:Bitmap;

    public function new() {
        super();
        this.visible = false;
        GlobalPlayer.usingTarget = 0;
        this.clear();
    }

    public function clear():Void {
        this.removeChildren();
        if (this._bmp != null) {
            this._bmp.bitmapData.dispose();
        }
        this._bmp = new Bitmap(Assets.getBitmapData('icTarget'));
        this._bmp.x = -(this._bmp.width / 2);
        this._bmp.y = -(this._bmp.height / 2);
        this.addChild(this._bmp);
    }

    public function show():Void {
        this.x = GlobalPlayer.area.aWidth / 2;
        this.y = GlobalPlayer.area.aHeight / 2;
        this.visible = true;
        GlobalPlayer.usingTarget = Math.round(GlobalPlayer.area.aWidth / 75);
        if ((GlobalPlayer.area.aHeight / 50) < GlobalPlayer.usingTarget) GlobalPlayer.usingTarget = Math.round(GlobalPlayer.area.aHeight / 75);
    }

    public function hide() {
        GlobalPlayer.usingTarget = 0;
        this.visible = false;
    }

}