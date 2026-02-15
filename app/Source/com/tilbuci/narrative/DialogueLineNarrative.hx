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

    /** Indicates whether the line data has been successfully loaded. */
    public var ok:Bool = false;

    /** The spoken text of the dialogue line. */
    public var text:String;

    /** Optional audio file identifier for voice‑over. */
    public var audio:String = '';

    /** Character ID speaking this line. */
    public var character:String = '';

    /** Graphic asset identifier for character expression. */
    public var asset:String = '';

    /**
     * Creates a new DialogueLineNarrative, optionally loading data from a Dynamic object.
     * @param data Optional Dynamic object containing text, audio, character, asset.
     */
    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    /**
     * Creates a deep copy of this dialogue line.
     * @return A new DialogueLineNarrative instance with identical data.
     */
    public function clone():DialogueLineNarrative {
        return (new DialogueLineNarrative(this.toObject()));
    }

    /**
     * Loads line data from a Dynamic object.
     * Required field: text. Optional fields: audio, character, asset.
     * @param data Dynamic object containing the line data.
     * @return True if loading succeeded, false otherwise.
     */
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

    /**
     * Removes the line from the display list and cleans up resources.
     */
    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.text = null;
        this.audio = null;
        this.character = null;
        this.asset = null;
    }

    /**
     * Exports the line data as a Dynamic object suitable for serialization.
     * @return Dynamic object with fields text, audio, character, asset.
     */
    public function toObject():Dynamic {
        return({
            text: this.text,
            audio: this.audio,
            character: this.character,
            asset: this.asset,
        });
    }
}