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

    /** Indicates whether the character data has been successfully loaded. */
    public var ok:Bool = false;

    /** Unique identifier for the character. */
    public var id:String;

    /** Display name of the character. */
    public var chname:String;

    /** Descriptive text about the character. */
    public var about:String;

    /** Name of the graphic collection containing character assets. */
    public var collection:String;

    /**
     * Creates a new CharacterNarrative, optionally loading data from a Dynamic object.
     * @param data Optional Dynamic object containing id, chname, about, collection.
     */
    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    /**
     * Creates a deep copy of this character.
     * @return A new CharacterNarrative instance with identical data.
     */
    public function clone():CharacterNarrative {
        return (new CharacterNarrative(this.toObject()));
    }

    /**
     * Loads character data from a Dynamic object.
     * Required fields: id, chname, about, collection.
     * @param data Dynamic object containing the character data.
     * @return True if loading succeeded, false otherwise.
     */
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

    /**
     * Removes the character from the display list and cleans up resources.
     */
    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.id = null;
        this.chname = null;
        this.about = null;
        this.collection = null;
    }

    /**
     * Exports the character data as a Dynamic object suitable for serialization.
     * @return Dynamic object with fields id, chname, about, collection.
     */
    public function toObject():Dynamic {
        return({
            id: this.id,
            chname: this.chname,
            about: this.about,
            collection: this.collection,
        });
    }
}