/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import com.tilbuci.player.MovieArea;
import com.tilbuci.display.PictureImage;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class BackgroundContraption extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var landscape:String;

    public var portrait:String;

    private var _landscape:PictureImage;

    private var _portrait:PictureImage;

    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    public function create(bts:Array<String>, ac:Dynamic):Sprite {
        if (this.ok) {
            this.removeChildren();   
        }
        return (this);
    }

    public function remove():Void {
        this.removeChildren();
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function clone():BackgroundContraption {
        return (new BackgroundContraption(this.toObject()));
    }

    public function getCover():BackgroundContraption {
        this.removeChildren();
        if (GlobalPlayer.area.pOrientation == MovieArea.HORIENTATION) {
            if (this._landscape != null) {
                this._landscape.width = GlobalPlayer.mdata.screen.big;
                this._landscape.height = GlobalPlayer.mdata.screen.small;
                this.addChild(this._landscape);
            } else {
                this._portrait.width = GlobalPlayer.mdata.screen.big;
                this._portrait.height = GlobalPlayer.mdata.screen.small;
                this.addChild(this._portrait);
            }
        } else {
            if (this._portrait != null) {
                this._portrait.width = GlobalPlayer.mdata.screen.small;
                this._portrait.height = GlobalPlayer.mdata.screen.big;
                this.addChild(this._portrait);
            } else {
                this._landscape.width = GlobalPlayer.mdata.screen.small;
                this._landscape.height = GlobalPlayer.mdata.screen.big;
                this.addChild(this._landscape);
            }
        }
        return (this);
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'portrait')) {
                this.portrait = Reflect.field(data, 'portrait');
                if (this.portrait != '') {
                    this._portrait = new PictureImage(this.onPicLoad);
                    this._portrait.visible = true;
                }
            } else {
                this.portrait = '';
            }
            if (Reflect.hasField(data, 'landscape')) {
                this.landscape = Reflect.field(data, 'landscape');
                if (this.landscape != '') {
                    this._landscape = new PictureImage(this.onPicLoad);
                    this._landscape.visible = true;
                }
            } else {
                this.landscape = '';
            }
            if ((this.landscape != '') || (this.portrait != '')) {
                if (this._landscape != null) this._landscape.load(this.landscape);
                if (this._portrait != null) this._portrait.load(this.portrait);
                this.mouseEnabled = false;
                this.mouseChildren = false;
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    private function onPicLoad(ok:Bool):Void {
        if (GlobalPlayer.area.pOrientation == MovieArea.HORIENTATION) {
            if (this._landscape != null) {
                this._landscape.width = GlobalPlayer.mdata.screen.big;
                this._landscape.height = GlobalPlayer.mdata.screen.small;
            } else {
                this._portrait.width = GlobalPlayer.mdata.screen.big;
                this._portrait.height = GlobalPlayer.mdata.screen.small;
            }
        } else {
            if (this._portrait != null) {
                this._portrait.width = GlobalPlayer.mdata.screen.small;
                this._portrait.height = GlobalPlayer.mdata.screen.big;
            } else {
                this._landscape.width = GlobalPlayer.mdata.screen.small;
                this._landscape.height = GlobalPlayer.mdata.screen.big;
            }
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        if (this._landscape != null) this._landscape.kill();
        if (this._portrait != null) this._portrait.kill();
        this._landscape = null;
        this._portrait = null;
        this.landscape = null;
        this.portrait = null;
        this.id = null;
    }

    public function toObject():Dynamic {
        return({
            id: this.id, 
            landscape: this.landscape, 
            portrait: this.portrait, 
        });
    }
}