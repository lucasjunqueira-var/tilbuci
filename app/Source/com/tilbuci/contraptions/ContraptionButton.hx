/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import openfl.filters.GlowFilter;
import com.tilbuci.data.GlobalPlayer;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextFormat;
import openfl.text.TextField;
import com.tilbuci.display.PictureImage;
import openfl.display.Sprite;
import openfl.text.TextFormatAlign;

class ContraptionButton extends Sprite {

    private var _img:PictureImage;

    private var _text:TextField;

    public var value:String;

    private var _ac:Dynamic;

    public function new(val:String, action:Dynamic, image:String, text:String, font:String, ftsize:Int, ftcolor:Int) {
        super();

        this.value = val;
        this._ac = action;

        if ((GlobalPlayer.mdata.highlightInt != null) && !GlobalPlayer.isMobile()) {
            this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        }

        this._img = new PictureImage(onLoad);
        this._img.load(image);
        this.addChild(this._img);
        this._img.visible = true;

        this._text = new TextField();
        this._text.defaultTextFormat = new TextFormat(font, ftsize, ftcolor, null, null, null, null, null, TextFormatAlign.CENTER);
        this._text.multiline = false;
        this._text.wordWrap = false;
        this._text.text = text;
        this._text.visible = false;
        this._text.selectable = false;
        this.addChild(this._text);

        this.mouseChildren = false;

        this.addEventListener(MouseEvent.CLICK, onClick);
    }

    public function kill():Void {
        this.removeChildren();
        if (this.hasEventListener(MouseEvent.MOUSE_OVER)) {
            this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        }
        this.removeEventListener(MouseEvent.CLICK, onClick);
        this._img.kill();
        this._img = null;
        this._text = null;
        this.value = null;
        this._ac = null;
    }

    private function onLoad(ok:Bool):Void {
        if (ok) {
            this._text.width = this._img.oWidth;
            this._text.height = this._text.textHeight + 4;
            this._text.y = (this._img.oHeight - this._text.height) / 2;
            this._text.visible = true;
        }
    }

    private function onMouseOver(evt:Event):Void {
        if (GlobalPlayer.cursorVisible) this.filters = [
            new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
        ];
    }

    private function onMouseOut(evt:Event):Void {
        this.filters = [ ];
    }

    private function onClick(evt:Event):Void {
        this.filters = [ ];
        this._ac(this.value);
    }

}