/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import com.tilbuci.data.GlobalPlayer;

class TargetContraption {

    public var ok = false;

    public var id:String = '';

    public var defaultp:String = '';

    public var menus:String = '';

    public var interf:String = '';

    public var inst1:String = '';
    public var inst1name:String = '';

    public var inst2:String = '';
    public var inst2name:String = '';

    public var inst3:String = '';
    public var inst3name:String = '';

    public function new(data:Dynamic = null) {
        if (data != null) this.load(data);
    }

    public function clone():TargetContraption {
        return (new TargetContraption(this.toObject()));
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'defaultp')) {
                this.defaultp = Reflect.field(data, 'defaultp');
                if (Reflect.hasField(data, 'menus')) this.menus = Reflect.field(data, 'menus');
                if (Reflect.hasField(data, 'interf')) this.interf = Reflect.field(data, 'interf');
                if (Reflect.hasField(data, 'inst1')) this.inst1 = Reflect.field(data, 'inst1');
                if (Reflect.hasField(data, 'inst1name')) this.inst1name = Reflect.field(data, 'inst1name');
                if (Reflect.hasField(data, 'inst2')) this.inst2 = Reflect.field(data, 'inst2');
                if (Reflect.hasField(data, 'inst2name')) this.inst2name = Reflect.field(data, 'inst2name');
                if (Reflect.hasField(data, 'inst3')) this.inst3 = Reflect.field(data, 'inst3');
                if (Reflect.hasField(data, 'inst3name')) this.inst3name = Reflect.field(data, 'inst3name');
                this.ok = true;
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    public function kill():Void {
        this.ok = false;
        this.id = null;
        this.defaultp = null;
        this.menus = null;
        this.interf = null;
        this.inst1 = null;
        this.inst1name = null;
        this.inst2 = null;
        this.inst2name = null;
        this.inst3 = null;
        this.inst3name = null;
    }

    public function toObject():Dynamic {
        return({
            id: this.id, 
            defaultp: this.defaultp, 
            menus: this.menus, 
            interf: this.interf, 
            inst1: this.inst1, 
            inst1name: this.inst1name, 
            inst2: this.inst2, 
            inst2name: this.inst2name, 
            inst3: this.inst3, 
            inst3name: this.inst3name, 
        });
    }
}