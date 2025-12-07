/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.narrative;

class BattleCardNarrative {

    public var ok:Bool = false;

    public var cardname:String;

    public var cardgraphic:String;

    public var cardattributes:Array<Int>;

    public function new(data:Dynamic = null) {
        if (data != null) this.load(data);
    }

    public function clone():BattleCardNarrative {
        return (new BattleCardNarrative(this.toObject()));
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'cardname') && Reflect.hasField(data, 'cardgraphic') && Reflect.hasField(data, 'cardattributes')) {
            this.cardname = Reflect.field(data, 'cardname');
            this.cardgraphic = Reflect.field(data, 'cardgraphic');
            this.cardattributes = cast Reflect.field(data, 'cardattributes');
            if (this.cardattributes == null) this.cardattributes = [ 0, 0, 0, 0, 0 ];
            this.ok = true;
            return (true);
        } else {
            return (false);
        }
    }

    public function kill():Void {
        this.cardname = null;
        this.cardgraphic = null;
        while (this.cardattributes.length > 0) this.cardattributes.shift();
        this.cardattributes = null;
    }

    public function toObject():Dynamic {
        return({
            cardname: this.cardname, 
            cardgraphic: this.cardgraphic,
            cardattributes: this.cardattributes, 
        });
    }
}