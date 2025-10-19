/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package com.tilbuci.player;

/** OPENFL **/
import com.tilbuci.display.PictureImage;
import haxe.Timer;
import com.tilbuci.data.GlobalPlayer;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

class Target extends Sprite {

    public var timer:Timer;

    public var lastInstOver:String = '';

    public var targetX:Float = 0;
    public var targetY:Float = 0;

    private var _bmp:Bitmap;

    private var _tgname:String = '';

    private var _custom:PictureImage;

    private var _inst1len:Int = 0;
    private var _inst2len:Int = 0;
    private var _inst3len:Int = 0;

    private var _lastname:String = 'xxx';

    public function new() {
        super();
        this.visible = false;
        GlobalPlayer.usingTarget = 0;
        this._custom = new PictureImage(onLoad);
        this.clear();
    }

    public function clear():Void {
        this.removeChildren();
        this._tgname = '';
        this._lastname = 'xxx';
        this._inst1len = this._inst2len = this._inst3len = 0;
        if (this._bmp != null) {
            this._bmp.bitmapData.dispose();
        }
        this._bmp = new Bitmap(Assets.getBitmapData('icTarget'));
        this._bmp.x = -(this._bmp.width / 2);
        this._bmp.y = -(this._bmp.height / 2);
        this.addChild(this._bmp);
    }

    public function load(nm:String):Bool {
        if (GlobalPlayer.contraptions.targets.exists(nm)) {
            if (GlobalPlayer.contraptions.targets[nm].ok) {
                this.clear();
                this._tgname = nm;
                this._lastname = '';
                this._custom.load(GlobalPlayer.contraptions.targets[nm].defaultp);
                if (GlobalPlayer.contraptions.targets[nm].inst1name != '') this._inst1len = GlobalPlayer.contraptions.targets[nm].inst1name.length;
                if (GlobalPlayer.contraptions.targets[nm].inst2name != '') this._inst2len = GlobalPlayer.contraptions.targets[nm].inst2name.length;
                if (GlobalPlayer.contraptions.targets[nm].inst3name != '') this._inst3len = GlobalPlayer.contraptions.targets[nm].inst3name.length;
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    public function setGraphic(nm:String):Void {
        if ((this._tgname != '') && (nm != this._lastname)) {
            this._lastname = nm;
            if (nm == '') {
                if (this._custom.lastMedia != GlobalPlayer.contraptions.targets[this._tgname].defaultp) this._custom.load(GlobalPlayer.contraptions.targets[this._tgname].defaultp);
            } else if ((nm == '_menu_') && (GlobalPlayer.contraptions.targets[this._tgname].menus != '')) {
                this._custom.load(GlobalPlayer.contraptions.targets[this._tgname].menus);
            } else if ((nm == '_interface_') && (GlobalPlayer.contraptions.targets[this._tgname].interf != '')) {
                this._custom.load(GlobalPlayer.contraptions.targets[this._tgname].interf);
            } else {
                if ((this._inst1len > 0) && (nm.substr(0, this._inst1len) == GlobalPlayer.contraptions.targets[this._tgname].inst1name)) {
                    if (this._custom.lastMedia != GlobalPlayer.contraptions.targets[this._tgname].inst1) this._custom.load(GlobalPlayer.contraptions.targets[this._tgname].inst1);
                } else if ((this._inst2len > 0) && (nm.substr(0, this._inst2len) == GlobalPlayer.contraptions.targets[this._tgname].inst2name)) {
                    if (this._custom.lastMedia != GlobalPlayer.contraptions.targets[this._tgname].inst2) this._custom.load(GlobalPlayer.contraptions.targets[this._tgname].inst2);
                } else if ((this._inst3len > 0) && (nm.substr(0, this._inst3len) == GlobalPlayer.contraptions.targets[this._tgname].inst3name)) {
                    if (this._custom.lastMedia != GlobalPlayer.contraptions.targets[this._tgname].inst3) this._custom.load(GlobalPlayer.contraptions.targets[this._tgname].inst3);
                } else {
                    if (this._custom.lastMedia != GlobalPlayer.contraptions.targets[this._tgname].defaultp) this._custom.load(GlobalPlayer.contraptions.targets[this._tgname].defaultp);
                }
            }
        }
    }

    public function show():Void {
        this.targetX = this.x = GlobalPlayer.area.aWidth / 2;
        this.targetY = this.y = GlobalPlayer.area.aHeight / 2;
        this.visible = true;
        GlobalPlayer.usingTarget = Math.round(GlobalPlayer.area.aWidth / 64);
        if ((GlobalPlayer.area.aHeight / 64) < GlobalPlayer.usingTarget) GlobalPlayer.usingTarget = Math.round(GlobalPlayer.area.aHeight / 64);
    }

    public function hide() {
        GlobalPlayer.usingTarget = 0;
        this.visible = false;
    }

    private function onLoad(ok):Void {
        if (!ok) {
            this.clear();
        } else {
            this.removeChildren();
            this._custom.visible = true;
            this._custom.x = -(this._custom.width / 2);
            this._custom.y = -(this._custom.height / 2);
            this.addChild(this._custom);
        }
    }

}