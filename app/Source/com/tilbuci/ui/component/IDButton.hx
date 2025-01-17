/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;

/** FEATHERS UI **/
import openfl.events.MouseEvent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import feathers.events.TriggerEvent;
import feathers.controls.Button;

class IDButton extends Button {

    /**
        the button ID
    **/
    public var btid:String;

    public var autoResize:Bool = true;

    /**
        trigger action
    **/
    private var _ac:Dynamic = null;

    public function new(id:String = '', ac:Dynamic = null, label:String = null, icon:BitmapData = null, autoR:Bool = true) {
        super();
        this.btid = id;
        this.autoResize = autoR;
        if (label != null) this.text = label;
        if (icon != null) {
            var bmp:Bitmap = new Bitmap(icon);
            bmp.smoothing = true;
            bmp.width = bmp.height = 20;
            this.icon = bmp;
        }
        if (ac != null) {
            this.addEventListener(MouseEvent.CLICK, ac);
            this._ac = ac;
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        if (this._ac != null) {
            //this.removeEventListener(TriggerEvent.TRIGGER, this._ac);
            this.removeEventListener(MouseEvent.CLICK, this._ac);
        }
        this._ac = null;
        this.btid = null;
    }

}