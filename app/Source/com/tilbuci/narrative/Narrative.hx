/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.narrative;

import com.tilbuci.display.AudioImage;
import com.tilbuci.player.MovieArea;
import openfl.events.MouseEvent;
import com.tilbuci.display.InstanceImage;
import com.tilbuci.display.VideoImage;
import com.tilbuci.display.PictureImage;
import com.tilbuci.display.SpritemapImage;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class Narrative {

    // characters
    public var chars:Map<String, CharacterNarrative> = [ ];

    // dialogues
    public var dialogues:Map<String, DialogueFolderNarrative> = [ ];
    public var diagSpeech:AudioImage;

    // inventory items
    public var items:Map<String, InvItemNarrative> = [ ];
    public var keyItems:Array<String> = [ ];
    public var consItNames:Array<String> = [ ];
    public var consItAmounts:Array<Int> = [ ];

    // battle cards
    public var cards:Map<String, BattleCardNarrative> = [ ];

    public function new() {
        this.diagSpeech = new AudioImage(onSpeechLoad, onSpeechEnd);
    }

    public function clear():Void {
        for (k in this.chars.keys()) {
            this.chars[k].kill();
            this.chars.remove(k);
        }
        for (k in this.dialogues.keys()) {
            this.dialogues[k].kill();
            this.dialogues.remove(k);
        }
        for (k in this.items.keys()) {
            this.items[k].kill();
            this.items.remove(k);
        }
        for (k in this.cards.keys()) {
            this.cards[k].kill();
            this.cards.remove(k);
        }
        while (this.keyItems.length > 0) this.keyItems.shift();
        while (this.consItNames.length > 0) this.consItNames.shift();
        while (this.consItAmounts.length > 0) this.consItAmounts.shift();
    }

    public function clearDialogues():Void {
        if (GlobalPlayer.mode == Player.MODE_PLAYER) {
            for(diag in this.dialogues) {
                diag.clear();
            }
        }
    }

    public function addKeyItem(id:String):Void {
        if (this.keyItems.length < 4) {
            if (this.items.exists(id)) {
                if (!this.keyItems.contains(id)) {
                    this.keyItems.push(id);
                }
            }
        }
    }

    public function removeKeyItem(id:String):Void {
        if (this.items.exists(id)) {
            var indx:Int = this.keyItems.indexOf(id);
            if (indx > -1) {
                this.keyItems.splice(indx, 1);
            }
        }
    }

    public function clearKeyItems():Void {
        while (this.keyItems.length > 0) this.keyItems.shift();
    }

    public function hasKeyItem(id:String):Bool {
        if (this.items.exists(id)) {
            return (this.keyItems.contains(id));
        } else {
            return (false);
        }
    }

    public function addConsumableItem(name:String, amount:Int):Void {
        if (this.consItNames.contains(name)) {
            var pos:Int = this.consItNames.indexOf(name);
            this.consItAmounts[pos] += amount;
        } else if (this.consItNames.length < 8) {
            this.consItNames.push(name);
            this.consItAmounts.push(amount);
        }
    }

    public function removeConsumableItem(name:String):Void {
        if (this.consItNames.contains(name)) {
            var pos:Int = this.consItNames.indexOf(name);
            this.consItNames.splice(pos, 1);
            this.consItAmounts.splice(pos, 1);
        }
    }

    public function consumeItem(name:String):Void {
        if (this.consItNames.contains(name)) {
            var pos:Int = this.consItNames.indexOf(name);
            this.consItAmounts[pos] -= 1;
            if (this.consItAmounts[pos]<= 0) {
                this.consItNames.splice(pos, 1);
                this.consItAmounts.splice(pos, 1);
            }
        }
    }

    public function clearConsumableItems():Void {
        while (this.consItNames.length > 0) this.consItNames.shift();
        while (this.consItAmounts.length > 0) this.consItAmounts.shift();
    }

    public function consumableAmount(name:String):Int {
        if (this.consItNames.contains(name)) {
            var pos:Int = this.consItNames.indexOf(name);
            return (this.consItAmounts[pos]);
        } else {
            return (0);
        }
    }

    public function currentItems():String {
        return(StringStatic.jsonStringify({
            k: this.keyItems, 
            c: this.consItNames, 
            a: this.consItAmounts, 
        }));
    }

    public function loadItems(str:String):Bool {
        var json:Dynamic = StringStatic.jsonParse(str);
        if (json == false) {
            return (false);
        } else {
            if (Reflect.hasField(json, 'k') && Reflect.hasField(json, 'c') && Reflect.hasField(json, 'a')) {
                var kAr:Array<String> = cast Reflect.field(json, 'k');
                var cAr:Array<String> = cast Reflect.field(json, 'c');
                var aAr:Array<Int> = cast Reflect.field(json, 'a');
                if ((kAr != null) && (cAr != null) && (aAr != null)) {
                    this.keyItems = kAr;
                    this.consItNames = cAr;
                    this.consItAmounts = aAr;
                    return (true);
                } else {
                    return (false);
                }
            } else {
                return (false);
            }
        }
    }

    public function currentKeyItems():String {
        return(StringStatic.jsonStringify({
            k: this.keyItems, 
        }));
    }

    public function loadKeyItems(str:String):Bool {
        var json:Dynamic = StringStatic.jsonParse(str);
        if (json == false) {
            return (false);
        } else {
            if (Reflect.hasField(json, 'k')) {
                var kAr:Array<String> = cast Reflect.field(json, 'k');
                if (kAr != null) {
                    this.keyItems = kAr;
                    return (true);
                } else {
                    return (false);
                }
            } else {
                return (false);
            }
        }
    }

    public function currentConsItems():String {
        return(StringStatic.jsonStringify({
            c: this.consItNames, 
            a: this.consItAmounts, 
        }));
    }

    public function loadConsItems(str:String):Bool {
        var json:Dynamic = StringStatic.jsonParse(str);
        if (json == false) {
            return (false);
        } else {
            if (Reflect.hasField(json, 'c') && Reflect.hasField(json, 'a')) {
                var cAr:Array<String> = cast Reflect.field(json, 'c');
                var aAr:Array<Int> = cast Reflect.field(json, 'a');
                if ((cAr != null) && (aAr != null)) {
                    this.consItNames = cAr;
                    this.consItAmounts = aAr;
                    return (true);
                } else {
                    return (false);
                }
            } else {
                return (false);
            }
        }
    }

    public function getData():String {
        var data:Map<String, Array<Dynamic>> = [ ];
        data['chars'] = new Array<Dynamic>();
        for (k in this.chars) {
            data['chars'].push(k.toObject());
        }
        data['dialogues'] = new Array<Dynamic>();
        data['diagcontent'] = new Array<Dynamic>();
        for (k in this.dialogues) {
            data['dialogues'].push(k.idObject());
            if (k.numDiags() > 0) data['diagcontent'].push(k.toObject());
        }
        data['items'] = new Array<Dynamic>();
        for (k in this.items) {
            data['items'].push(k.toObject());
        }
        data['cards'] = new Array<Dynamic>();
        for (k in this.cards) {
            data['cards'].push(k.toObject());
        }
        return(StringStatic.jsonStringify(data));
    }

    private function onSpeechLoad(ok:Void):Void {
        this.diagSpeech.play();
    }

    private function onSpeechEnd():Void {
        this.diagSpeech.stop();
    }

}