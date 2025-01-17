/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;

import feathers.core.FeathersControl;
import openfl.Assets;
import openfl.display.Bitmap;
import feathers.events.TriggerEvent;
import feathers.controls.Label;
import feathers.controls.Header;
import feathers.layout.AnchorLayout;
import feathers.controls.Panel;
import feathers.skins.RectangleSkin;

import com.tilbuci.ui.base.InterfaceFactory;

class DropDownPanel extends Panel {

    public var ui:InterfaceFactory;

    public var callbacks:Array<Dynamic> = [ ];

    private var _open:Bool = false;

    private var _content:FeathersControl;

    public function new(tt:String, wd:Float) {
        super();
        this.ui = new InterfaceFactory();

        this.layout = new AnchorLayout();

        var skin:RectangleSkin = new RectangleSkin();
        skin.fill = SolidColor(0x666666);
        this.backgroundSkin = skin;

        var lb:Label = new Label();
        lb.text = tt;

        var hd:Header = new Header();
        hd.leftView = lb;
        hd.rightView = this.ui.createIconButton('toggle', toggle, new Bitmap(Assets.getBitmapData('iconPlus')));
        this.header = hd;
        

        this.width = wd;
    }

    public function toggle(evt:TriggerEvent = null):Void {
        var bmp:Bitmap;
        if (this._open) {
            bmp = new Bitmap(Assets.getBitmapData('iconPlus'));
            this.removeChildren();
        } else {
            bmp = new Bitmap(Assets.getBitmapData('iconMinus'));
            if (this._content != null) this.addChild(this._content);
        }
        bmp.smoothing = true;
        bmp.width = bmp.height = 20;
        this.ui.buttons['toggle'].icon = bmp;
        this._open = !this._open;
    }

    public function reloadContent(data:Map<String, Dynamic> = null):Void {

    }

    public function updateContent(data:Map<String, Dynamic> = null):Void {

    }

    public function setWd(wd:Float):Void {
        this.width = wd;
        if (this._content != null) this._content.width = wd;
    }

}