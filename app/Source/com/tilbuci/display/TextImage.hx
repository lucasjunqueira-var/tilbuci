/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.display;

/** OPENFL **/
import openfl.text.TextLineMetrics;
import haxe.Timer;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormatAlign;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;

class TextImage extends BaseImage {

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

    public function new(ol:Dynamic) {
        super('text', false, ol);
        this._text = new TextField();
        this._text.selectable = false;
        this._format = new TextFormat();
        this._format.align = TextFormatAlign.LEFT;
        this._text.defaultTextFormat = this._format;
        this._text.wordWrap = false;
        this._text.multiline = false;
        this._text.embedFonts = true;
        this._text.cacheAsBitmap = true;
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
    **/
    public function setFormat(font:String, size:Int, color:String, bold:Bool, italic:Bool, leading:Int, spacing:Float, bg:String):Void {
        this._format.font = font;
        this._format.size = size;
        this._format.color = Std.parseInt(color);
        this._format.bold = bold;
        this._format.italic = italic;
        this._format.leading = leading;
        this._format.letterSpacing = spacing;
        this._text.defaultTextFormat = this._format;
        if (bg == '') {
            this._text.background = false;
        } else {
            this._text.backgroundColor = Std.parseInt(bg);
            this._text.background = true;
        }
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
        txt = txt.split("\r").join("");
        txt = GlobalPlayer.parser.parseString(txt);

        // fix for text field autosize issue
        var wd:Float = 0;
        this._format.align = TextFormatAlign.LEFT;
        this._text.autoSize = TextFieldAutoSize.LEFT;
        for (i in 0...txt.length) {
            this._text.text = txt.charAt(i).toUpperCase();
            var metrics:TextLineMetrics = this._text.getLineMetrics(0);
            wd += metrics.width;
        }

        // setting text
        this._format.align = TextFormatAlign.CENTER;
        this._text.autoSize = TextFieldAutoSize.NONE;
        this._text.width = wd - (txt.length * 0.4);
        this._text.text = txt;
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