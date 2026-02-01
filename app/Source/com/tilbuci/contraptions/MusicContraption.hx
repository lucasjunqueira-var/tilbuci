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

class MusicContraption extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var media:String;

    private var _music:AudioImage;

    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    public function clone():MusicContraption {
        return (new MusicContraption(this.toObject()));
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'media')) {
                this.media = Reflect.field(data, 'media');
                if (this.media == null) this.media = '';
                this._music = new AudioImage(onLoad, onEnd);
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
        if (this._music != null) {
            this._music.stop();
            this._music.kill();
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
        if (this._music != null) {
            if (this._music.lastMedia != this.media) {
                this._music.load(this.media);
            } else {
                this._music.play();
            }
        }
    }

    public function pause():Void {
        if (this._music != null) this._music.pause();
    }

    public function stop():Void {
        if (this._music != null) this._music.stop();
    }

    public function volume(vol:Int):Void {
        if (vol > 100) vol = 100;
            else if (vol < 0) vol = 0;
            if (this._music != null) this._music.iterateSound(vol/100);
    }

    private function onLoad(ok:Void):Void {
        // start playing
        this._music.play();
    }

    private function onEnd():Void {
        // loop
        this._music.play();
    }
}