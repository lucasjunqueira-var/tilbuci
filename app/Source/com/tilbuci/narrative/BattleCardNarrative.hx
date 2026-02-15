/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.narrative;

class BattleCardNarrative {

    /** Indicates whether the card data has been successfully loaded. */
    public var ok:Bool = false;

    /** Display name of the battle card. */
    public var cardname:String;

    /** Graphic asset identifier for the card. */
    public var cardgraphic:String;

    /** Array of integer attributes (typically 5 values) defining card stats. */
    public var cardattributes:Array<Int>;

    /**
     * Creates a new BattleCardNarrative, optionally loading data from a Dynamic object.
     * @param data Optional Dynamic object containing cardname, cardgraphic, cardattributes.
     */
    public function new(data:Dynamic = null) {
        if (data != null) this.load(data);
    }

    /**
     * Creates a deep copy of this battle card.
     * @return A new BattleCardNarrative instance with identical data.
     */
    public function clone():BattleCardNarrative {
        return (new BattleCardNarrative(this.toObject()));
    }

    /**
     * Loads card data from a Dynamic object.
     * Required fields: cardname, cardgraphic, cardattributes.
     * @param data Dynamic object containing the card data.
     * @return True if loading succeeded, false otherwise.
     */
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

    /**
     * Cleans up resources and nullifies references.
     */
    public function kill():Void {
        this.cardname = null;
        this.cardgraphic = null;
        while (this.cardattributes.length > 0) this.cardattributes.shift();
        this.cardattributes = null;
    }

    /**
     * Exports the card data as a Dynamic object suitable for serialization.
     * @return Dynamic object with fields cardname, cardgraphic, cardattributes.
     */
    public function toObject():Dynamic {
        return({
            cardname: this.cardname,
            cardgraphic: this.cardgraphic,
            cardattributes: this.cardattributes,
        });
    }
}