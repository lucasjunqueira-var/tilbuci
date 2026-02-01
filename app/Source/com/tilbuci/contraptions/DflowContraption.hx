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

class DflowContraption extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var font:String = 'sans';

    public var fontcolor:String = '0xffffff';

    public var fontsize:Int = 20;

    public var buton:String = '';

    public var position:String = 'center';

    public var gap:Int = 10;

    public var menuSize:Point = new Point();

    private var _btbitmap:PictureImage;

    private var _btsize:Point;

    private var _buttons:Array<ContraptionButton> = [ ];

    private var _options:Array<Array<String>> = [ ];

    public function new() {
        super();
    }

    public function create(bts:Array<Array<String>>):Sprite {
        if (this.ok) {
            this.removeChildren();
            while (this._buttons.length > 0) this._buttons.shift().kill();
            this._options = bts;
            var iused:Int = 0;
            for (i in 0...bts.length) {
                if ((bts[i][0] != '') && (bts[i][1] != '')) {
                    var cb:ContraptionButton = new ContraptionButton(Std.string(i), this.onClick, this.buton, bts[i][0], this.font, this.fontsize, StringStatic.colorInt(this.fontcolor));
                    cb.x = 0;
                    cb.y = (this.gap + this._btsize.y) * iused;
                    this._buttons.push(cb);
                    this.addChild(cb);
                    iused++;
                }
            }
            this.menuSize.x = this._btsize.x;
            this.menuSize.y = (this._buttons.length * this._btsize.y) + (this.gap * (this._buttons.length - 1));
        }
        return (this);
    }

    public function checkCollision(obj:Sprite):Bool {
        var found:Bool = false;
        if (this.ok) {
            for (k in this._buttons) {
                var bt:ContraptionButton = cast k;
                if (bt != null) {
                    if (obj.hitTestObject(bt)) {
                        found = true;
                        this.onClick(bt.value);
                    }
                }
            }
        }
        return (found);
    }

    public function remove():Void {
        this.removeChildren();
        while (this._buttons.length > 0) this._buttons.shift().kill();
        this._options = [ ];
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function clone():DflowContraption {
        var mn:DflowContraption = new DflowContraption();
        mn.load({
            id: this.id, 
            font: this.font, 
            fontcolor: this.fontcolor, 
            fontsize: this.fontsize, 
            buton: this.buton, 
            position: this.position, 
            gap: this.gap, 
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
            if (Reflect.hasField(data, 'buton')) this.buton = Reflect.field(data, 'buton');
                else this.buton = '';
            if (Reflect.hasField(data, 'gap')) this.gap = Reflect.field(data, 'gap');
                else this.gap = 10;
            if (Reflect.hasField(data, 'position')) this.position = Reflect.field(data, 'position');
                else this.position = 'center';

            if (this.font == null) this.font = 'sans';
            if (this.fontcolor == null) this.fontcolor = '0xffffff';
            if (this.fontsize == null) this.fontsize = 20;
            if (this.buton == null) this.buton = '';
            if (this.gap == null) this.gap = 10;
            if (this.position == null) this.position = 'center';

            this.fontcolor = StringStatic.colorHex(this.fontcolor, '#FFFFFF');
            if (this._btbitmap == null) this._btbitmap = new PictureImage(onBTLoad);
            this._btbitmap.load(this.buton);
            return (true);
        } else {
            return (false);
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.id = this.font = this.fontcolor = this.buton = this.position = null;
        while (this._buttons.length > 0) this._buttons.shift().kill();
        this._buttons = null;
        this._options = null;
        this.menuSize = null;
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function toObject():Dynamic {
        return({
            id: this.id, 
            font: this.font, 
            fontcolor: this.fontcolor, 
            fontsize: this.fontsize, 
            buton: this.buton, 
            position: this.position, 
            gap: this.gap
        });
    }

    private function onBTLoad(ok:Bool):Void {
        this.ok = ok;
        if (ok) {
            this._btsize = new Point(this._btbitmap.oWidth, this._btbitmap.oHeight);
        }
    }

    private function onClick(val:String):Void {
        if (this._options[Std.parseInt(val)][1] != '') {
            GlobalPlayer.parser.run('{"ac":"scene.load","param":["' + this._options[Std.parseInt(val)][1] + '"]}');
        }
        this.remove();
    }
}