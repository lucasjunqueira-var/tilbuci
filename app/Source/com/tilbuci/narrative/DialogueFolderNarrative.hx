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

class DialogueFolderNarrative extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var code:String = '';

    public var diags:Map<String, DialogueNarrative> = [ ];

    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    public function clone():DialogueFolderNarrative {
        return (new DialogueFolderNarrative(this.toObject()));
    }

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

    public function numDiags():Int {
        return(Lambda.count(this.diags));
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.id = null;
        for (k in this.diags.keys()) {
            this.diags[k].kill();
            this.diags.remove(k);
        }
        this.diags = null;
    }

    public function idObject():Dynamic {
        return({
            id: this.id, 
            code: this.code, 
        });
    }

    public function toObject():Dynamic {
        var diagobj:Array<Dynamic> = [ ];
        for (k in this.diags) diagobj.push(k.toObject());
        return({
            id: this.id, 
            code: this.code, 
            diags: diagobj
        });
    }
}