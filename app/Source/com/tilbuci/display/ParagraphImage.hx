/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.display;

/** HAXE **/
import haxe.Timer;

/** OPENFL **/
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.TextFormatAlign;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;

class ParagraphImage extends BaseImage {

    /**
        the text display
    **/
    private var _text:TextField;

    /**
        text formatting data
    **/
    private var _format:TextFormat;

    /**
        load timer (do delay tye media loaded event a little)
    **/
    private var _loadTimer:Timer;

    /**
        current scroll position
    **/
    private var _scrollPos:Int = 0;

    public function new(ol:Dynamic) {
        super('paragraph', false, ol);
        this._text = new TextField();
        this._text.selectable = false;
        this._format = new TextFormat();
        this._format.align = TextFormatAlign.LEFT;
        this._text.defaultTextFormat = this._format;
        this._text.wordWrap = true;
        this._text.multiline = true;
        //this._text.embedFonts = true;
        //this._text.cacheAsBitmap = true;
        this.addChild(this._text);
    }

    /**
        Sets the text format.
        @param  font    the font name
        @param  size    font size (pt)
        @param  color   text color (hex string)
        @param  bold    text bold?
        @param  italic  text italic?
        @param  leading space among lines
        @param  spacing space among chars
        @param  bg  background color (empty string for no bg)
        @param  align   text alignment
    **/
    public function setFormat(font:String, size:Int, color:String, bold:Bool, italic:Bool, leading:Int, spacing:Float, bg:String, align:String):Void {
        this._format.font = font;
        this._format.size = size;
        this._format.color = Std.parseInt(color);
        this._format.bold = bold;
        this._format.italic = italic;
        this._format.leading = leading;
        this._format.letterSpacing = spacing;
        switch (align) {
            case 'right':
                this._format.align = TextFormatAlign.RIGHT;
            case 'center':
                this._format.align = TextFormatAlign.CENTER;
            case 'justify':
                this._format.align = TextFormatAlign.JUSTIFY;
            default:
                this._format.align = TextFormatAlign.LEFT;
        }
        this._text.defaultTextFormat = this._format;
        if (bg == '') {
            this._text.background = false;
        } else {
            this._text.backgroundColor = Std.parseInt(bg);
            this._text.background = true;
        }
    }

    /**
        Gets this instance current float properties.
        @param  name    the property name
        @return the property value or 0 if not supported
    **/
    public function getProp(name:String):Float {
        switch (name) {
            case 'fontSize': return (this._format.size * 1.0);
            case 'fontLeading': return (this._format.leading * 1.0);
            case 'fontSpacing': return (this._format.letterSpacing * 1.0);
            default: return (0);
        }
    }

    /**
        Gets this instance current bool properties.
        @param  name    the property name
        @return the property value or false if not supported
    **/
    public function getBoolProp(name:String):Bool {
        switch (name) {
            case 'fontBold': return (this._format.bold);
            case 'fontItalic': return (this._format.italic);
            default: return (false);
        }
    }

    /**
        Gets this instance current string properties.
        @param  name    the property name
        @return the property value or empty string if not supported
    **/
    public function getStringlProp(name:String):String {
        switch (name) {
            case 'font': return (this._format.font);
            case 'fontColor': return ('0x' + StringTools.hex(this._format.color));
            default: return ('');
        }
    }

    /**
        Sets the text field actual size.
        @param  wd  the field width
        @param  ht' the field height
    **/
    public function setTextSize(wd:Float, ht:Float):Void {
        this._text.width = this.oWidth = wd;
        this._text.height = this.oHeight = ht;
        this._text.scrollV = this._scrollPos;
    }

    /**
        Scrolls a text.
        @param  val    scroll direction
    **/
    public function textScroll(val:Int):Void {
        switch (val) {
            case 1:
                if (this._scrollPos < this._text.maxScrollV) this._scrollPos = this._text.scrollV = this._scrollPos + 1;
            case -1:
                if (this._scrollPos > 0) this._scrollPos = this._text.scrollV = this._scrollPos - 1;
            case 0:
                this._scrollPos = this._text.scrollV = 0;
            case 2:
                this._scrollPos = this._text.scrollV = this._text.maxScrollV;
        }
    }

    /**
        Sets the current text.
        @param  txt the new text
    **/
    public function setText(txt:String):Void {
        txt = GlobalPlayer.parser.parseString(txt);
        this._text.text = txt;
        this._scrollPos = this._text.scrollV = 0;
    }

    /**
        Gets the current text.
        @return the current text
    **/
    public function getText():String {
        return (this._text.text);
    }

    /**
        Loads a text string.
        @param  txt the text do display
    **/
    public function load(txt:String):Void {
        txt = GlobalPlayer.parser.parseString(txt);
        this._lastMedia = txt;
        this._text.text = txt;
        this._text.scrollV = this._scrollPos = 0;
        if (this._loadTimer != null) {
            try { this._loadTimer.stop(); } catch (e) { }
            this._loadTimer = null;
        }
        this._loadTimer = new Timer(100);
        this._loadTimer.run = this.onOk;
    }


    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
        if (this._loadTimer != null) {
            try { this._loadTimer.stop(); } catch (e) { }
            this._loadTimer = null;
        }
        this._text = null;
        this._format = null;
    }

    /**
        Text loaded.
    **/
    private function onOk():Void {
        if (this._loadTimer != null) {
            try { this._loadTimer.stop(); } catch (e) { }
            this._loadTimer = null;
        }
        this.oWidth = this._text.width;
        this.oHeight = this._text.height;
        this._onLoad(true);
    }
}