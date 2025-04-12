/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import openfl.geom.Point;
import com.tilbuci.display.PictureImage;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.statictools.StringStatic;
import openfl.display.Sprite;

class MenuContraption extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var mode:String = 'v';

    public var font:String = 'sans';

    public var fontcolor:String = '0xffffff';

    public var fontsize:Int = 20;

    public var background:String = '';

    public var buton:String = '';

    public var bgcolor:String = '0x000000';

    public var bgalpha:Float = 0;

    private var _bgbitmap:PictureImage;

    private var _btbitmap:PictureImage;

    private var _btsize:Point;

    private var _buttons:Array<ContraptionButton> = [ ];

    private var _ac:Dynamic;

    public function new() {
        super();
    }

    public function create(bts:Array<String>, ac:Dynamic):Sprite {
        if (this.ok) {
            this.removeChildren();
            this._bgbitmap.visible = true;
            this.addChild(this._bgbitmap);
            while (this._buttons.length > 0) this._buttons.shift().kill();
            for (i in 0...bts.length) {
                this._buttons.push(new ContraptionButton(Std.string(i), this.onClick, this.buton, bts[i], this.font, this.fontsize, StringStatic.colorInt(this.fontcolor)));
            }
            var px:Float = (this._bgbitmap.oWidth - this._btsize.x) / 2;
            var gap:Float = (this._bgbitmap.oHeight - (this._btsize.y * this._buttons.length)) / (this._buttons.length + 1);
            if (gap < 0) gap = 5;
            for (i in 0...this._buttons.length) {
                this._buttons[i].x = px;
                this._buttons[i].y = ((i + 1) * gap)  + (i * this._btsize.y);
                this.addChild(this._buttons[i]);
            }
            this._ac = ac;
        }
        return (this);
    }

    public function remove():Void {
        this.removeChildren();
        this._ac = null;
        while (this._buttons.length > 0) this._buttons.shift().kill();
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function clone():MenuContraption {
        var mn:MenuContraption = new MenuContraption();
        mn.load({
            id: this.id, 
            mode: this.mode,
            font: this.font, 
            fontcolor: this.fontcolor, 
            fontsize: this.fontsize, 
            background: this.background, 
            buton: this.buton, 
            bgcolor: this.bgcolor, 
            bgalpha: this.bgalpha
        });
        return (mn);
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'font')) this.font = Reflect.field(data, 'font');
                else this.font = 'sans';
            if (Reflect.hasField(data, 'fontcolor')) this.fontcolor = Reflect.field(data, 'fontcolor');
                else this.fontcolor = '0xffffff';
            if (Reflect.hasField(data, 'fontsize')) this.fontsize = Reflect.field(data, 'fontsize');
                else this.fontsize = 20;
            if (Reflect.hasField(data, 'background')) this.background = Reflect.field(data, 'background');
                else this.background = '';
            if (Reflect.hasField(data, 'buton')) this.buton = Reflect.field(data, 'buton');
                else this.buton = '';
            if (Reflect.hasField(data, 'bgcolor')) this.bgcolor = Reflect.field(data, 'bgcolor');
                else this.bgcolor = '0x000000';
            if (Reflect.hasField(data, 'bgalpha')) this.bgalpha = Reflect.field(data, 'bgalpha');
                else this.bgalpha = 0;
            if (Reflect.hasField(data, 'mode')) this.mode = Reflect.field(data, 'mode');
                else this.mode = 'v';
            this.fontcolor = StringStatic.colorHex(this.fontcolor, '#FFFFFF');
            this.bgcolor = StringStatic.colorHex(this.bgcolor, '#000000');

            if (this._bgbitmap == null) this._bgbitmap = new PictureImage(onBGLoad);
            this._bgbitmap.load(this.background);

            return (true);
        } else {
            return (false);
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.id = this.font = this.fontcolor = this.background = this.buton = this.bgcolor = this.mode = null;
        if (this._bgbitmap != null) {
            this._bgbitmap.kill();
            this._bgbitmap = null;
        }
        this._ac = null;
        while (this._buttons.length > 0) this._buttons.shift().kill();
        this._buttons = null;
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function toObject():Dynamic {
        return({
            id: this.id, 
            mode: this.mode,
            font: this.font, 
            fontcolor: this.fontcolor, 
            fontsize: this.fontsize, 
            background: this.background, 
            buton: this.buton, 
            bgcolor: this.bgcolor, 
            bgalpha: this.bgalpha
        });
    }

    private function onBGLoad(ok:Bool):Void {
        if (ok) {
            if (this._btbitmap == null) this._btbitmap = new PictureImage(onBTLoad);
            this._btbitmap.load(this.buton);
        }
    }

    private function onBTLoad(ok:Bool):Void {
        this.ok = ok;
        if (ok) {
            this._btsize = new Point(this._btbitmap.oWidth, this._btbitmap.oHeight);
        }
    }

    private function onClick(val:String):Void {
        this._ac(val);
    }
}