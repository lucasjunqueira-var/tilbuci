/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.narrative;

/** OPENFL **/
import com.tilbuci.player.MovieArea;
import openfl.events.MouseEvent;
import com.tilbuci.display.PictureImage;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class DialogueLineNarrative extends Sprite {

    public var ok:Bool = false;

    public var text:String;

    public var audio:String = '';

    public var character:String = '';

    public var asset:String = '';

    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    public function clone():DialogueLineNarrative {
        return (new DialogueLineNarrative(this.toObject()));
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'text')) {
            this.text = Reflect.field(data, 'text');
            this.audio = Reflect.field(data, 'audio');
            this.character = Reflect.field(data, 'character');
            this.asset = Reflect.field(data, 'asset');
            this.ok = true;
            return (true);
        } else {
            return (false);
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.text = null;
        this.audio = null;
        this.character = null;
        this.asset = null;
    }

    public function toObject():Dynamic {
        return({
            text: this.text, 
            audio: this.audio, 
            character: this.character, 
            asset: this.asset, 
        });
    }
}