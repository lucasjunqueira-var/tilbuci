package com.tilbuci.ui.component;

/** FEATHERS UI **/
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import feathers.events.TriggerEvent;
import feathers.controls.Button;

class IDButton extends Button {

    /**
        the button ID
    **/
    public var btid:String;

    /**
        trigger action
    **/
    private var _ac:Dynamic = null;

    public function new(id:String = '', ac:Dynamic = null, label:String = null, icon:BitmapData = null) {
        super();
        this.btid = id;
        if (label != null) this.text = label;
        if (icon != null) {
            var bmp:Bitmap = new Bitmap(icon);
            bmp.smoothing = true;
            bmp.width = bmp.height = 20;
            this.icon = bmp;
        }
        if (ac != null) {
            this.addEventListener(TriggerEvent.TRIGGER, ac);
            this._ac = ac;
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        if (this._ac != null) {
            this.removeEventListener(TriggerEvent.TRIGGER, this._ac);
        }
        this._ac = null;
        this.btid = null;
    }

}