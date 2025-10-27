/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextField;
import openfl.geom.Point;
import com.tilbuci.display.PictureImage;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.statictools.StringStatic;
import openfl.display.Sprite;

class MessagesContraption extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var font:String = 'sans';

    public var fontcolor:String = '0xffffff';

    public var fontsize:Int = 20;

    public var background:String = '';

    public var buton:Array<String> = [ '', '', ''];

    public var gap:Int = 10;

    private var _bgbitmap:PictureImage = null;

    private var _btbitmap:Array<PictureImage> = [ null, null, null ];

    private var _buttons:Array<ContraptionButton> = [ ];

    private var _text:TextField;

    private var _ac:Dynamic;

    public function new() {
        super();
    }

    public function create(msg:String, bts:Array<String>, ac:Dynamic):Sprite {
        if (this.ok) {
            this.removeChildren();

            this._bgbitmap.visible = true;
            this.addChild(this._bgbitmap);

            trace ('adicionar texto', msg);
            this._text = new TextField();
            this._text.width = this._bgbitmap.width - (this.gap * 2);
            this._text.height = this._bgbitmap.height - (this.gap * 2);
            this._text.x = this._text.y = this.gap;
            this._text.defaultTextFormat = new TextFormat(this.font, this.fontsize, StringStatic.colorInt(this.fontcolor), null, null, null, null, null, TextFormatAlign.CENTER);
            this._text.multiline = true;
            this._text.wordWrap = true;
            this._text.text = msg;
            this._text.visible = true;
            this._text.selectable = false;
            this.addChild(this._text);

            while (bts.length > 3) bts.pop();
            while (this._buttons.length > 0) this._buttons.shift().kill();
            for (i in 0...bts.length) {
                var cb:ContraptionButton = new ContraptionButton(Std.string(i), this.onClick, this.buton[i], bts[i], this.font, this.fontsize, StringStatic.colorInt(this.fontcolor));
                cb.x = (this._bgbitmap.width - this._btbitmap[i].width) / 2;
                if (i == 0) {
                    cb.y = this._bgbitmap.height - this.gap - this._btbitmap[0].height;
                    this._text.height -= (this.gap + this._btbitmap[0].height);
                } else if (i == 1) {
                    cb.y = this._bgbitmap.height - this.gap - this._btbitmap[0].height - this.gap - this._btbitmap[1].height;
                    this._text.height -= (this.gap + this._btbitmap[1].height);
                } else if (i == 2) {
                    cb.y = this._bgbitmap.height - this.gap - this._btbitmap[0].height - this.gap - this._btbitmap[1].height - this.gap - this._btbitmap[2].height;
                    this._text.height -= (this.gap + this._btbitmap[2].height);
                }
                this._buttons.push(cb);
                this.addChild(cb);
            }

            this._ac = ac;
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
                        this._ac(bt.value);
                    }
                }
            }
        }
        return (found);
    }

    public function remove():Void {
        this.removeChildren();
        this._text = null;
        this._ac = null;
        while (this._buttons.length > 0) this._buttons.shift().kill();
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function clone():MessagesContraption {
        var mn:MessagesContraption = new MessagesContraption();
        mn.load({
            id: this.id, 
            font: this.font, 
            fontcolor: this.fontcolor, 
            fontsize: this.fontsize, 
            background: this.background, 
            gap: this.gap, 
            buton0: this.buton[0], 
            buton1: this.buton[1], 
            buton2: this.buton[2]
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
            if (Reflect.hasField(data, 'fontsize')) {
                this.fontsize = Reflect.field(data, 'fontsize');
            } else {
                this.fontsize = 20;
            }
            if (Reflect.hasField(data, 'gap')) {
                this.gap = Reflect.field(data, 'gap');
            } else {
                this.gap = 10;
            }
            if (Reflect.hasField(data, 'background')) {
                this.background = Reflect.field(data, 'background');
            } else {
                this.background = '';
            }
            if (Reflect.hasField(data, 'buton0') && Reflect.hasField(data, 'buton1') && Reflect.hasField(data, 'buton2')) {
                this.buton = [ Reflect.field(data, 'buton0'), Reflect.field(data, 'buton1'), Reflect.field(data, 'buton2') ];
            } else {
                this.buton = [ '', '', '' ];
            }
            if (this.buton[1] == '') this.buton[1] = this.buton[0];
            if (this.buton[2] == '') this.buton[2] = this.buton[0];
            this.fontcolor = StringStatic.colorHex(this.fontcolor, '#FFFFFF');
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
        this.id = this.font = this.fontcolor = this.background = null;
        while (this.buton.length > 0) this.buton.shift();
        this.buton = null;
        this._bgbitmap.kill();
        this._bgbitmap = null;
        while (this._btbitmap.length > 0) {
            this._btbitmap.shift().kill();
        }
        this._btbitmap = null;
        this._ac = null;
        while (this._buttons.length > 0) this._buttons.shift().kill();
        this._buttons = null;
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function toObject():Dynamic {
        return({
            id: this.id, 
            font: this.font, 
            fontcolor: this.fontcolor, 
            fontsize: this.fontsize, 
            background: this.background, 
            gap: this.gap, 
            buton0: this.buton[0], 
            buton1: this.buton[1], 
            buton2: this.buton[2]
        });
    }

    private function onBGLoad(ok:Bool):Void {
        if (ok) {
            if (this._btbitmap[0] == null) this._btbitmap[0] = new PictureImage(onBTLoad0);
            this._btbitmap[0].load(this.buton[0]);
        } else {
            this.ok = false;
        }
    }

    private function onBTLoad0(ok:Bool):Void {
        if (ok) {
            this._btbitmap[0].width = this._btbitmap[0].oWidth;
            this._btbitmap[0].height = this._btbitmap[0].oHeight;
            this.ok = true;
            if (this._btbitmap[1] == null) this._btbitmap[1] = new PictureImage(onBTLoad1);
            if (this._btbitmap[2] == null) this._btbitmap[2] = new PictureImage(onBTLoad2);
            this._btbitmap[1].load(this.buton[1]);
            this._btbitmap[2].load(this.buton[2]);
        }
    }

    private function onBTLoad1(ok:Bool):Void {
        if (ok) {
            this._btbitmap[1].width = this._btbitmap[1].oWidth;
            this._btbitmap[1].height = this._btbitmap[1].oHeight;
        } else {
            this.ok = false;
        }
    }

    private function onBTLoad2(ok:Bool):Void {
        if (ok) {
            this._btbitmap[2].width = this._btbitmap[2].oWidth;
            this._btbitmap[2].height = this._btbitmap[2].oHeight;
        } else {
            this.ok = false;
        }
    }

    private function onClick(val:String):Void {
        this._ac(val);
    }
}