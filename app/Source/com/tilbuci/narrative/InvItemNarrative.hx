/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.narrative;

class InvItemNarrative {

    public var ok:Bool = false;

    public var itname:String;

    public var ittype:String;

    public var itgraphic:String;

    public var itaction:String;

    public function new(data:Dynamic = null) {
        if (data != null) this.load(data);
    }

    public function clone():InvItemNarrative {
        return (new InvItemNarrative(this.toObject()));
    }

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

    public function kill():Void {
        this.itname = null;
        this.ittype = null;
        this.itgraphic = null;
        this.itaction = null;
    }

    public function toObject():Dynamic {
        return({
            itname: this.itname, 
            ittype: this.ittype,
            itgraphic: this.itgraphic, 
            itaction: this.itaction, 
        });
    }
}