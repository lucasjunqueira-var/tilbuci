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

    /** Indicates whether the dialogue data has been successfully loaded. */
    public var ok:Bool = false;

    /** Unique identifier for the dialogue. */
    public var id:String;

    /** Instance name of the 'previous' navigation button. */
    public var navprev:String = '';

    /** Instance name of the 'next' navigation button. */
    public var navnext:String = '';

    /** Instance name of the 'end' navigation button. */
    public var navend:String = '';

    /** Instance name of the text display for dialogue lines. */
    public var insttext:String = '';

    /** Instance name of the character name display. */
    public var instname:String = '';

    /** Instance name of the character expression graphic. */
    public var instexpr:String = '';

    /** Index of the currently displayed line within the lines array. */
    public var current:Int = 0;

    /** Array of DialogueLineNarrative objects representing each line of the dialogue. */
    public var lines:Array<DialogueLineNarrative> = [ ];

    /** Private cache of the last loaded character collection. */
    private var _lastcol:String = '';
    /** Private cache of the last loaded asset identifier. */
    private var _lastast:String = '';

    /**
     * Creates a new DialogueNarrative, optionally loading data from a Dynamic object.
     * @param data Optional Dynamic object containing id, navprev, navnext, navend, insttext, instname, instexpr, lines.
     */
    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    /**
     * Creates a deep copy of this dialogue.
     * @return A new DialogueNarrative instance with identical data.
     */
    public function clone():DialogueNarrative {
        return (new DialogueNarrative(this.toObject()));
    }

    /**
     * Loads dialogue data from a Dynamic object.
     * Required field: id. Optional fields: navprev, navnext, navend, insttext, instname, instexpr, lines.
     * @param data Dynamic object containing the dialogue data.
     * @return True if loading succeeded, false otherwise.
     */
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

    /**
     * Removes the dialogue from the display list and cleans up all contained lines.
     */
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

    /**
     * Exports the dialogue data as a Dynamic object suitable for serialization.
     * @return Dynamic object with fields id, lines, navprev, navnext, navend, insttext, instname, instexpr.
     */
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

    /**
     * Returns the number of lines in this dialogue.
     * @return Count of lines.
     */
    public function numLines():Int {
        return (this.lines.length);
    }

    /**
     * Advances to the next line (if any) and updates the display.
     */
    public function next():Void {
        this.current++;
        if (this.current >= this.lines.length) this.current = this.lines.length - 1;
        this.show(this.current);
    }

    /**
     * Goes back to the previous line (if any) and updates the display.
     */
    public function previous():Void {
        this.current--;
        if (this.current < 0) this.current = 0;
        this.show(this.current);
    }

    /**
     * Jumps to the last line and updates the display.
     */
    public function last():Void {
        this.current = this.lines.length - 1;
        this.show(this.current);
    }

    /**
     * Jumps to the first line and updates the display.
     */
    public function first():Void {
        this.current = 0;
        this.show(this.current);
    }

    /**
     * Displays a specific line (or the current line) and updates all UI elements.
     * This includes setting text, toggling navigation buttons, loading character graphics, and playing audio.
     * @param line Optional line index to show. If negative, the current line is used.
     */
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

    /**
     * Closes the dialogue, releasing UI property bindings and stopping speech audio.
     */
    public function close():Void {
        if ((this.navprev != null) && (this.navprev != '')) GlobalPlayer.area.releaseProperty(this.navprev, 'visible');
        if ((this.navnext != null) && (this.navnext != '')) GlobalPlayer.area.releaseProperty(this.navnext, 'visible');
        if ((this.navend != null) && (this.navend != '')) GlobalPlayer.area.releaseProperty(this.navend, 'visible');
        if ((this.instexpr != null) && (this.instexpr != '')) GlobalPlayer.area.releaseProperty(this.instexpr, 'visible');
        GlobalPlayer.narrative.diagSpeech.stop();
        this._lastast = this._lastcol = '';
    }
}