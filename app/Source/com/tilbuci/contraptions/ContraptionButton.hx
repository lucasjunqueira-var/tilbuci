package com.tilbuci.contraptions;

/** OPENFL **/
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextFormat;
import openfl.text.TextField;
import com.tilbuci.display.PictureImage;
import openfl.display.Sprite;
import openfl.text.TextFormatAlign;

class ContraptionButton extends Sprite {

    private var _img:PictureImage;

    private var _over:PictureImage;

    private var _text:TextField;

    private var _value:String;

    private var _ac:Dynamic;

    public function new(val:String, action:Dynamic, image:String, text:String, font:String, ftsize:Int, ftcolor:Int, over:String = null) {
        super();

        this._value = val;
        this._ac = action;

        if ((over != null) && (over != '')) {
            this._over = new PictureImage();
            this._over.load(over);
            this.addChild(this._over);
            this._over.visible = false;
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
        if (this._over != null) {
            this._over.kill();
            this._over = null;
        }
        this._value = null;
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
        this._over.width = this._img.width;
        this._over.height = this._img.height;
        this._img.visible = false;
        this._over.visible = true;
    }

    private function onMouseOut(evt:Event):Void {
        this._img.visible = true;
        this._over.visible = false;
    }

    private function onClick(evt:Event):Void {
        this._ac(this._value);
    }

}