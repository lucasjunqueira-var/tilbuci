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

    /** Map of character IDs to CharacterNarrative objects. */
    public var chars:Map<String, CharacterNarrative> = [ ];

    /** Map of dialogue folder IDs to DialogueFolderNarrative objects. */
    public var dialogues:Map<String, DialogueFolderNarrative> = [ ];
    /** AudioImage instance for playing dialogue speech. */
    public var diagSpeech:AudioImage;

    /** Map of inventory item IDs to InvItemNarrative objects. */
    public var items:Map<String, InvItemNarrative> = [ ];
    /** Array of key item IDs (max 4). */
    public var keyItems:Array<String> = [ ];
    /** Names of consumable items (max 8). */
    public var consItNames:Array<String> = [ ];
    /** Amounts corresponding to consumable items in consItNames. */
    public var consItAmounts:Array<Int> = [ ];

    /** Map of battle card IDs to BattleCardNarrative objects. */
    public var cards:Map<String, BattleCardNarrative> = [ ];

    /**
     * Creates a new Narrative instance and initializes the dialogue speech audio.
     */
    public function new() {
        this.diagSpeech = new AudioImage(onSpeechLoad, onSpeechEnd);
    }

    /**
     * Clears all narrative data: characters, dialogues, items, battle cards, and inventory arrays.
     * Calls kill() on each object to clean up resources.
     */
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

    /**
     * Clears all dialogue contents if the player is in PLAYER mode.
     * This is used to free memory when dialogues are no longer needed.
     */
    public function clearDialogues():Void {
        if (GlobalPlayer.mode == Player.MODE_PLAYER) {
            for(diag in this.dialogues) {
                diag.clear();
            }
        }
    }

    /**
     * Adds an item ID to the key items list if it exists in the items map and there is space (max 4).
     * @param id The inventory item ID to add as a key item.
     */
    public function addKeyItem(id:String):Void {
        if (this.keyItems.length < 4) {
            if (this.items.exists(id)) {
                if (!this.keyItems.contains(id)) {
                    this.keyItems.push(id);
                }
            }
        }
    }

    /**
     * Removes an item ID from the key items list if it exists.
     * @param id The inventory item ID to remove.
     */
    public function removeKeyItem(id:String):Void {
        if (this.items.exists(id)) {
            var indx:Int = this.keyItems.indexOf(id);
            if (indx > -1) {
                this.keyItems.splice(indx, 1);
            }
        }
    }

    /**
     * Clears all key items from the list.
     */
    public function clearKeyItems():Void {
        while (this.keyItems.length > 0) this.keyItems.shift();
    }

    /**
     * Checks whether a given item ID is present in the key items list.
     * @param id The inventory item ID to check.
     * @return True if the item exists in the items map and is a key item, false otherwise.
     */
    public function hasKeyItem(id:String):Bool {
        if (this.items.exists(id)) {
            return (this.keyItems.contains(id));
        } else {
            return (false);
        }
    }

    /**
     * Adds a consumable item to the inventory, or increases its amount if already present.
     * Maximum of 8 distinct consumable items.
     * @param name The name of the consumable item.
     * @param amount The quantity to add.
     */
    public function addConsumableItem(name:String, amount:Int):Void {
        if (this.consItNames.contains(name)) {
            var pos:Int = this.consItNames.indexOf(name);
            this.consItAmounts[pos] += amount;
        } else if (this.consItNames.length < 8) {
            this.consItNames.push(name);
            this.consItAmounts.push(amount);
        }
    }

    /**
     * Removes a consumable item entirely from the inventory.
     * @param name The name of the consumable item to remove.
     */
    public function removeConsumableItem(name:String):Void {
        if (this.consItNames.contains(name)) {
            var pos:Int = this.consItNames.indexOf(name);
            this.consItNames.splice(pos, 1);
            this.consItAmounts.splice(pos, 1);
        }
    }

    /**
     * Consumes one unit of a consumable item, decreasing its amount.
     * If the amount reaches zero, the item is removed from the inventory.
     * @param name The name of the consumable item to consume.
     */
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

    /**
     * Clears all consumable items from the inventory.
     */
    public function clearConsumableItems():Void {
        while (this.consItNames.length > 0) this.consItNames.shift();
        while (this.consItAmounts.length > 0) this.consItAmounts.shift();
    }

    /**
     * Returns the current amount of a consumable item.
     * @param name The name of the consumable item.
     * @return The amount held, or 0 if the item is not in the inventory.
     */
    public function consumableAmount(name:String):Int {
        if (this.consItNames.contains(name)) {
            var pos:Int = this.consItNames.indexOf(name);
            return (this.consItAmounts[pos]);
        } else {
            return (0);
        }
    }

    /**
     * Serializes the current key items and consumable items into a JSON string.
     * @return JSON string with keys: k (key items), c (consumable names), a (consumable amounts).
     */
    public function currentItems():String {
        return(StringStatic.jsonStringify({
            k: this.keyItems,
            c: this.consItNames,
            a: this.consItAmounts,
        }));
    }

    /**
     * Loads key items and consumable items from a JSON string.
     * @param str JSON string with fields k, c, a.
     * @return True if parsing succeeded and data was loaded, false otherwise.
     */
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

    /**
     * Serializes only the key items into a JSON string.
     * @return JSON string with key k (array of key item IDs).
     */
    public function currentKeyItems():String {
        return(StringStatic.jsonStringify({
            k: this.keyItems,
        }));
    }

    /**
     * Loads key items from a JSON string.
     * @param str JSON string with field k (array of key item IDs).
     * @return True if parsing succeeded and data was loaded, false otherwise.
     */
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

    /**
     * Serializes only the consumable items into a JSON string.
     * @return JSON string with keys c (consumable names) and a (consumable amounts).
     */
    public function currentConsItems():String {
        return(StringStatic.jsonStringify({
            c: this.consItNames,
            a: this.consItAmounts,
        }));
    }

    /**
     * Loads consumable items from a JSON string.
     * @param str JSON string with fields c and a.
     * @return True if parsing succeeded and data was loaded, false otherwise.
     */
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

    /**
     * Exports all narrative data (characters, dialogues, items, battle cards) as a JSON string.
     * The returned JSON includes separate arrays for each entity type.
     * @return JSON string representing the complete narrative state.
     */
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

    /**
     * Callback triggered when dialogue speech audio finishes loading.
     * @param ok Unused parameter (legacy).
     */
    private function onSpeechLoad(ok:Void):Void {
        this.diagSpeech.play();
    }

    /**
     * Callback triggered when dialogue speech audio playback ends.
     */
    private function onSpeechEnd():Void {
        this.diagSpeech.stop();
    }

}