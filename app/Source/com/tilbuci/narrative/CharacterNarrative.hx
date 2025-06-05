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

class CharacterNarrative extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var chname:String;

    public var about:String;

    public var collection:String;

    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    public function clone():CharacterNarrative {
        return (new CharacterNarrative(this.toObject()));
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'id') && Reflect.hasField(data, 'chname') && Reflect.hasField(data, 'about') && Reflect.hasField(data, 'collection')) {
            this.id = Reflect.field(data, 'id');
            this.chname = Reflect.field(data, 'chname');
            this.about = Reflect.field(data, 'about');
            this.collection = Reflect.field(data, 'collection');
            this.ok = true;
            return (true);
        } else {
            return (false);
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.id = null;
        this.chname = null;
        this.about = null;
        this.collection = null;
    }

    public function toObject():Dynamic {
        return({
            id: this.id, 
            chname: this.chname,
            about: this.about, 
            collection: this.collection, 
        });
    }
}