/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import com.tilbuci.display.AudioImage;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class SoundContraption extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var media:String;

    private var _sound:AudioImage;

    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    public function clone():SoundContraption {
        return (new SoundContraption(this.toObject()));
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'media')) {
                this.media = Reflect.field(data, 'media');
                this._sound = new AudioImage(onLoad, onEnd);
                this.ok = true;
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    public function kill():Void {
        if (this._sound != null) {
            this._sound.stop();
            this._sound.kill();
        }
        this.media = null;
    }

    public function toObject():Dynamic {
        return({
            id: this.id, 
            media: this.media
        });
    }

    public function play():Void {
        if (this._sound != null) {
            if (this._sound.lastMedia != this.media) {
                this._sound.load(this.media);
            } else {
                this._sound.play();
            }
        }
    }

    public function pause():Void {
        if (this._sound != null) this._sound.pause();
    }

    public function stop():Void {
        if (this._sound != null) this._sound.stop();
    }

    public function volume(vol:Int):Void {
        if (vol > 100) vol = 100;
            else if (vol < 0) vol = 0;
            if (this._sound != null) this._sound.iterateSound(vol/100);
    }

    private function onLoad(ok:Void):Void {
        // start playing
        this._sound.play();
    }

    private function onEnd():Void {
        // loop
        // this._sound.play();
    }
}