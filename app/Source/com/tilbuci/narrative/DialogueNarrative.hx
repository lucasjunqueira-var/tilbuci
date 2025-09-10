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

    public var current:Int = 0;

    public var lines:Array<DialogueLineNarrative> = [ ];

    private var _lastcol:String = '';
    private var _lastast:String = '';

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

    public function next():Void {
        this.current++;
        if (this.current >= this.lines.length) this.current = this.lines.length - 1;
        this.show(this.current);
    }

    public function previous():Void {
        this.current--;
        if (this.current < 0) this.current = 0;
        this.show(this.current);
    }

    public function last():Void {
        this.current = this.lines.length - 1;
        this.show(this.current);
    }

    public function first():Void {
        this.current = 0;
        this.show(this.current);
    }

    public function show(line:Int = -1):Void {
        if (line >= 0) this.current = line;
        if (this.current >= this.lines.length) this.current = 0;
        // line text
        if ((this.insttext != null) && (this.insttext != '')) GlobalPlayer.area.setText(this.insttext, this.lines[this.current].text);
        // previous button
        if ((this.navprev != null) && (this.navprev != '')) {
            if (this.current == 0) {
                GlobalPlayer.area.setVisible(this.navprev, false);
            } else {
                GlobalPlayer.area.setVisible(this.navprev, true);
            }
        }
        // next button
        if ((this.navnext != null) && (this.navnext != '')) {
            if (this.current >= (this.lines.length - 1)) {
                GlobalPlayer.area.setVisible(this.navnext, false);
            } else {
                GlobalPlayer.area.setVisible(this.navnext, true);
            }
        }
        // end button
        if ((this.navend != null) && (this.navend != '')) {
            if (this.current >= (this.lines.length - 1)) {
                GlobalPlayer.area.setVisible(this.navend, true);
            } else {
                GlobalPlayer.area.setVisible(this.navend, false);
            }
        }
        // character name
        if ((this.instname != null) && (this.instname != '')) {
            if (this.lines[this.current].character == '') {
                GlobalPlayer.area.setText(this.instname, '');
            } else {
                if (GlobalPlayer.narrative.chars.exists(this.lines[this.current].character)) {
                    GlobalPlayer.area.setText(this.instname, GlobalPlayer.narrative.chars[this.lines[this.current].character].chname);
                } else {
                    GlobalPlayer.area.setText(this.instname, '');
                }
            }
        }
        // character expression
        if ((this.instexpr != null) && (this.instexpr != '')) {
            if (this.lines[this.current].asset == '') {
                GlobalPlayer.area.setVisible(this.instexpr, false);
            } else {
                if (GlobalPlayer.narrative.chars.exists(this.lines[this.current].character)) {
                    if (GlobalPlayer.movie.collections.exists(GlobalPlayer.narrative.chars[this.lines[this.current].character].collection)) {
                        if ((this._lastcol != GlobalPlayer.narrative.chars[this.lines[this.current].character].collection) && (this._lastast != this.lines[this.current].asset)) {
                            GlobalPlayer.area.loadCollectionAsset(this.instexpr, GlobalPlayer.narrative.chars[this.lines[this.current].character].collection, this.lines[this.current].asset);
                        }
                        this._lastcol = GlobalPlayer.narrative.chars[this.lines[this.current].character].collection;
                        this._lastast = this.lines[this.current].asset;
                        GlobalPlayer.area.setVisible(this.instexpr, true);
                    } else {
                        GlobalPlayer.area.setVisible(this.instexpr, false);
                    }
                } else {
                    GlobalPlayer.area.setVisible(this.instexpr, false);
                }
            }
        }
        // speech
        if (this.lines[this.current].audio == '') {
            GlobalPlayer.narrative.diagSpeech.stop();
        } else {
            GlobalPlayer.narrative.diagSpeech.load(this.lines[this.current].audio);
        }
    }

    public function close():Void {
        if ((this.navprev != null) && (this.navprev != '')) GlobalPlayer.area.releaseProperty(this.navprev, 'visible');
        if ((this.navnext != null) && (this.navnext != '')) GlobalPlayer.area.releaseProperty(this.navnext, 'visible');
        if ((this.navend != null) && (this.navend != '')) GlobalPlayer.area.releaseProperty(this.navend, 'visible');
        if ((this.instexpr != null) && (this.instexpr != '')) GlobalPlayer.area.releaseProperty(this.instexpr, 'visible');
        GlobalPlayer.narrative.diagSpeech.stop();
        this._lastast = this._lastcol = '';
    }
}