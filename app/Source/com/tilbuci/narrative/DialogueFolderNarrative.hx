/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.narrative;

/** OPENFL **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.player.MovieArea;
import openfl.events.MouseEvent;
import com.tilbuci.display.PictureImage;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class DialogueFolderNarrative extends Sprite {

    /** Indicates whether the folder data has been successfully loaded. */
    public var ok:Bool = false;

    /** Unique identifier for the dialogue folder. */
    public var id:String;

    /** Code used to fetch the folder's content from the server. */
    public var code:String = '';

    /** Flag indicating whether the folder's dialogue content has been loaded. */
    public var loaded:Bool = false;

    /** Map of dialogue IDs to DialogueNarrative objects belonging to this folder. */
    public var diags:Map<String, DialogueNarrative> = [ ];

    /** Private callback reference used during asynchronous content loading. */
    private var _callback:Dynamic;

    /**
     * Creates a new DialogueFolderNarrative, optionally loading data from a Dynamic object.
     * @param data Optional Dynamic object containing id, code, and diags.
     */
    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    /**
     * Creates a deep copy of this dialogue folder.
     * @return A new DialogueFolderNarrative instance with identical data.
     */
    public function clone():DialogueFolderNarrative {
        return (new DialogueFolderNarrative(this.toObject()));
    }

    /**
     * Loads folder data from a Dynamic object.
     * Required field: id. Optional fields: code, diags.
     * @param data Dynamic object containing the folder data.
     * @return True if loading succeeded, false otherwise.
     */
    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'code')) this.code = Reflect.field(data, 'code');
            for (k in this.diags.keys()) {
                this.diags[k].kill();
                this.diags.remove(k);
            }
            if (Reflect.hasField(data, 'diags')) {
                var diag = Reflect.field(data, 'diags');
                for (k in Reflect.fields(diag)) {
                    var dn:DialogueNarrative = new DialogueNarrative();
                    if (dn.load(Reflect.field(diag, k))) {
                        this.diags[dn.id] = dn;
                    }
                }
            }
            this.ok = true;
            return (true);
        } else {
            return (false);
        }
    }

    /**
     * Clears all dialogues from this folder, calling kill() on each.
     */
    public function clear():Void {
        if (this.ok) {
            for (k in this.diags.keys()) {
                this.diags[k].kill();
                this.diags.remove(k);
            }
            this.diags = [ ];
        }
    }

    /**
     * Asynchronously loads the folder's dialogue content from the server.
     * @param callback Function to be called with a Boolean success parameter.
     * @return True if the loading process was initiated, false otherwise.
     */
    public function loadContents(callback:Dynamic):Bool {
        if (this.ok) {
            GlobalPlayer.narrative.clearDialogues();
            this._callback = callback;
            if (GlobalPlayer.nocache) {
                new DataLoader(true, (GlobalPlayer.base + 'movie/' + GlobalPlayer.movie.mvId + '.movie/media/dialogues/' + this.code + '.json'), 'GET', [ 'rand' => Date.now().getTime() ], DataLoader.MODEJSON, onContents);
            } else {
                new DataLoader(true, (GlobalPlayer.base + 'movie/' + GlobalPlayer.movie.mvId + '.movie/media/dialogues/' + this.code + '.json'), 'GET', [ ], DataLoader.MODEJSON, onContents);
            }
            return (true);
        } else {
            return (false);
        }
    }

    /**
     * Private callback invoked when the server response arrives.
     * @param ok Whether the HTTP request succeeded.
     * @param ld The DataLoader instance containing the response.
     */
    private function onContents(ok:Bool, ld:DataLoader = null):Void {
        if (ok) {
            if (this.load(ld.json)) {
                this._callback(true);
            } else {
                this._callback(false);
            }
        } else {
            this._callback(false);
        }
    }

    /**
     * Returns the number of dialogues in this folder.
     * @return Count of dialogues.
     */
    public function numDiags():Int {
        return(Lambda.count(this.diags));
    }

    /**
     * Removes the folder from the display list and cleans up all contained dialogues.
     */
    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.id = null;
        for (k in this.diags.keys()) {
            this.diags[k].kill();
            this.diags.remove(k);
        }
        this.diags = null;
        this._callback = null;
    }

    /**
     * Exports a lightweight representation of the folder (id, code, loaded) for serialization.
     * @return Dynamic object with fields id, code, loaded.
     */
    public function idObject():Dynamic {
        return({
            id: this.id,
            code: this.code,
            loaded: this.loaded,
        });
    }

    /**
     * Exports the complete folder data, including all dialogues, as a Dynamic object.
     * @return Dynamic object with fields id, code, loaded, diags.
     */
    public function toObject():Dynamic {
        var diagobj:Array<Dynamic> = [ ];
        for (k in this.diags) diagobj.push(k.toObject());
        return({
            id: this.id,
            code: this.code,
            loaded: this.loaded,
            diags: diagobj
        });
    }
}