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

class DialogueNarrative extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var navprev:String = '';

    public var navnext:String = '';

    public var navend:String = '';

    public var insttext:String = '';

    public var instname:String = '';

    public var instexpr:String = '';

    public var lines:Array<DialogueLineNarrative> = [ ];

    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    public function clone():DialogueNarrative {
        return (new DialogueNarrative(this.toObject()));
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'navprev')) this.navprev = Reflect.field(data, 'navprev');
            if (Reflect.hasField(data, 'navnext')) this.navnext = Reflect.field(data, 'navnext');
            if (Reflect.hasField(data, 'navend')) this.navend = Reflect.field(data, 'navend');
            if (Reflect.hasField(data, 'insttext')) this.insttext = Reflect.field(data, 'insttext');
            if (Reflect.hasField(data, 'instname')) this.instname = Reflect.field(data, 'instname');
            if (Reflect.hasField(data, 'instexpr')) this.instexpr = Reflect.field(data, 'instexpr');
            if (Reflect.hasField(data, 'lines')) {
                var line = Reflect.field(data, 'lines');
                for (k in Reflect.fields(line)) {
                    var ln:DialogueLineNarrative = new DialogueLineNarrative();
                    if (ln.load(Reflect.field(line, k))) {
                        this.lines.push(ln);
                    }
                }
            }
            this.ok = true;
            return (true);
        } else {
            return (false);
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.id = null;
        while (this.lines.length > 0) {
            this.lines.shift().kill();
        }
        this.lines = null;
        this.navprev = null;
        this.navnext = null;
        this.navend = null;
        this.insttext = null;
        this.instname = null;
        this.instexpr = null;
    }

    public function toObject():Dynamic {
        var lineobj:Array<Dynamic> = [ ];
        for (k in this.lines) lineobj.push(k.toObject());
        return({
            id: this.id, 
            lines: lineobj, 
            navprev: this.navprev, 
            navnext: this.navnext, 
            navend: this.navend, 
            insttext: this.insttext, 
            instname: this.instname, 
            instexpr: this.instexpr, 
        });
    }

    public function numLines():Int {
        return (this.lines.length);
    }
}