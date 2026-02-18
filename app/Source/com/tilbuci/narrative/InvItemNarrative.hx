/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.narrative;

class InvItemNarrative {

    /** Indicates whether the item data has been successfully loaded. */
    public var ok:Bool = false;

    /** Display name of the inventory item. */
    public var itname:String;

    /** Type of the item (e.g., 'key', 'consumable', 'equipment'). */
    public var ittype:String;

    /** Graphic asset identifier for the item. */
    public var itgraphic:String;

    /** Action identifier associated with using the item. */
    public var itaction:String;

    /**
     * Creates a new InvItemNarrative, optionally loading data from a Dynamic object.
     * @param data Optional Dynamic object containing itname, ittype, itgraphic, itaction.
     */
    public function new(data:Dynamic = null) {
        if (data != null) this.load(data);
    }

    /**
     * Creates a deep copy of this inventory item.
     * @return A new InvItemNarrative instance with identical data.
     */
    public function clone():InvItemNarrative {
        return (new InvItemNarrative(this.toObject()));
    }

    /**
     * Loads item data from a Dynamic object.
     * Required fields: itname, ittype, itgraphic, itaction.
     * @param data Dynamic object containing the item data.
     * @return True if loading succeeded, false otherwise.
     */
    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'itname') && Reflect.hasField(data, 'ittype') && Reflect.hasField(data, 'itgraphic') && Reflect.hasField(data, 'itaction')) {
            this.itname = Reflect.field(data, 'itname');
            this.ittype = Reflect.field(data, 'ittype');
            this.itgraphic = Reflect.field(data, 'itgraphic');
            this.itaction = Reflect.field(data, 'itaction');
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
        this.itname = null;
        this.ittype = null;
        this.itgraphic = null;
        this.itaction = null;
    }

    /**
     * Exports the item data as a Dynamic object suitable for serialization.
     * @return Dynamic object with fields itname, ittype, itgraphic, itaction.
     */
    public function toObject():Dynamic {
        return({
            itname: this.itname,
            ittype: this.ittype,
            itgraphic: this.itgraphic,
            itaction: this.itaction,
        });
    }
}