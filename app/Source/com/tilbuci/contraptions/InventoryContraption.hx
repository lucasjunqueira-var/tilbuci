/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import com.tilbuci.statictools.SpriteStatic;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.filters.GlowFilter;
import com.tilbuci.player.MovieArea;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import com.tilbuci.display.PictureImage;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.statictools.StringStatic;
import openfl.display.Sprite;

class InventoryContraption extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var font:String = 'sans';

    public var fontcolor:String = '0xffffff';

    public var fontsize:Int = 20;

    public var horizontal:String = '';

    public var vertical:String = '';

    public var close:String = '';

    public var mode:String = 'a';

    private var _hbitmap:PictureImage;

    private var _vbitmap:PictureImage;

    private var _cbitmap:PictureImage;

    private var _closeac:Dynamic = null;

    private var _rows:Array<InvItemRow> = [ ];

    public function new() {
        super();
        for (i in 0...3) {
            var rw:InvItemRow = new InvItemRow(this.draw);
            this._rows.push(rw);
        }
    }

    public function create(closeac:Dynamic = null):Sprite {
        this.removeChildren();
        this._cbitmap.visible = true;
        this._hbitmap.visible = this._vbitmap.visible = false;
        if (this.ok) {
            if (GlobalPlayer.area.pOrientation == MovieArea.HORIENTATION) {
                this.addChild(this._hbitmap);
                this._hbitmap.x = this._hbitmap.y = 0;
                this._hbitmap.width = GlobalPlayer.mdata.screen.big;
                this._hbitmap.height = GlobalPlayer.mdata.screen.small;
                this._cbitmap.x = this._hbitmap.width - this._cbitmap.width;
                this._hbitmap.visible = true;
            } else {
                this.addChild(this._vbitmap);
                this._vbitmap.x = this._vbitmap.y = 0;
                this._vbitmap.width = GlobalPlayer.mdata.screen.small;
                this._vbitmap.height = GlobalPlayer.mdata.screen.big;
                this._cbitmap.x = this._vbitmap.width - this._cbitmap.width;
                this._vbitmap.visible = true;
            }
            for (r in this._rows) this.addChild(r);
            this._cbitmap.y = 0;
            this.addChild(this._cbitmap); 
            this._closeac = closeac; 
        }
        return (this);
    }

    public function draw():Void {
        for (r in this._rows) r.setText(this.font, this.fontsize, StringStatic.colorInt(this.fontcolor));
        
        this._rows[0].setData(GlobalPlayer.narrative.keyItems);
        var cons1names:Array<String> = [ ];
        var cons1amounts:Array<Int> = [ ];
        var cons2names:Array<String> = [ ];
        var cons2amounts:Array<Int> = [ ];
        if (GlobalPlayer.narrative.consItNames.length > 0) {
            for (i in 0...4) {
                if (GlobalPlayer.narrative.consItNames.length > i) {
                    cons1names.push(GlobalPlayer.narrative.consItNames[i]);
                    cons1amounts.push(GlobalPlayer.narrative.consItAmounts[i]);
                }
            }
        }
        if (GlobalPlayer.narrative.consItNames.length > 4) {
            for (i in 4...8) {
                if (GlobalPlayer.narrative.consItNames.length > i) {
                    cons2names.push(GlobalPlayer.narrative.consItNames[i]);
                    cons2amounts.push(GlobalPlayer.narrative.consItAmounts[i]);
                }
            }
        }
        this._rows[1].setData(cons1names, cons1amounts);
        this._rows[2].setData(cons2names, cons2amounts);

        var areax:Float = 0;
        var areay:Float = 0;
        var rowref:Float = 0;
        if (this._hbitmap.visible) {
            areax = this._hbitmap.width - (2 * this._cbitmap.width);
            areay = this._hbitmap.height - (2 * this._cbitmap.height);
            rowref = areay / 5;
            if (this.mode == 'k') {
                this._rows[0].x = this._cbitmap.width;
                this._rows[0].y = this._cbitmap.height + (rowref * 2);
                this._rows[0].draw('h', areax, rowref);
                this._rows[1].visible = this._rows[2].visible = false;
            } else if (this.mode == 'c') {
                this._rows[1].x = this._rows[2].x = this._cbitmap.width;
                this._rows[1].y = this._cbitmap.height + (rowref);
                this._rows[2].y = this._cbitmap.height + (rowref * 3);
                this._rows[1].draw('h', areax, rowref);
                this._rows[2].draw('h', areax, rowref);
                this._rows[0].visible = false;
            } else {
                for (r in 0...this._rows.length) {
                    this._rows[r].x = this._cbitmap.width;
                    this._rows[r].y = this._cbitmap.height + (r * rowref * 2);
                    this._rows[r].draw('h', areax, rowref);
                }
            }
        } else {
            areax = this._vbitmap.width - (2 * this._cbitmap.width);
            areay = this._vbitmap.height - (2 * this._cbitmap.height);
            rowref = areax / 5;
            if (this.mode == 'k') {
                this._rows[0].y = this._cbitmap.height;
                this._rows[0].x = this._cbitmap.width + (rowref * 2);
                this._rows[0].draw('v', areay, rowref);
                this._rows[1].visible = this._rows[2].visible = false;
            } else if (this.mode == 'c') {
                this._rows[1].y = this._rows[2].y = this._cbitmap.height;
                this._rows[1].x = this._cbitmap.width + (rowref);
                this._rows[2].x = this._cbitmap.width + (rowref * 3);
                this._rows[1].draw('v', areay, rowref);
                this._rows[2].draw('v', areay, rowref);
                this._rows[0].visible = false;
            } else {
                for (r in 0...this._rows.length) {
                    this._rows[r].y = this._cbitmap.height;
                    this._rows[r].x = this._cbitmap.width + (r * rowref * 2);
                    this._rows[r].draw('v', areay, rowref);
                }
            }
        }
    }

    public function checkCollision(obj:Sprite):Bool {
        var found:Bool = false;
        if (this.ok) {
            found = this._cbitmap.hitTestObject(obj);
            if (found) {
                this.onClose();
            } else {
                if (!found) found = this._rows[0].checkCollision(obj);
                if (!found) found = this._rows[1].checkCollision(obj);
                if (!found) found = this._rows[2].checkCollision(obj);
            }
        }
        return (found);
    }

    public function checkOver(obj:Sprite):Bool {
        var found:Bool = false;
        if (this.ok) {
            found = this._cbitmap.hitTestObject(obj);
            if (!found) found = this._rows[0].checkOver(obj);
            if (!found) found = this._rows[1].checkOver(obj);
            if (!found) found = this._rows[2].checkOver(obj);
        }
        return (found);
    }

    public function remove():Void {
        this.removeChildren();
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function clone():InventoryContraption {
        var mn:InventoryContraption = new InventoryContraption();
        mn.load({
            id: this.id, 
            font: this.font, 
            fontcolor: this.fontcolor, 
            fontsize: this.fontsize, 
            horizontal: this.horizontal, 
            vertical: this.vertical, 
            close: this.close, 
            mode: this.mode, 
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
            if (Reflect.hasField(data, 'vertical')) this.vertical = Reflect.field(data, 'vertical');
                else this.vertical = '';
            if (Reflect.hasField(data, 'horizontal')) this.horizontal = Reflect.field(data, 'horizontal');
                else this.horizontal = '';
            if (Reflect.hasField(data, 'close')) this.close = Reflect.field(data, 'close');
                else this.close = '';
            if (Reflect.hasField(data, 'mode')) this.mode = Reflect.field(data, 'mode');
                else this.mode = 'a';
            this.fontcolor = StringStatic.colorHex(this.fontcolor, '#FFFFFF');

            if (this.close == '') {
                return (false);
            } else if ((this.horizontal == '') && (this.vertical == '')) {
                return (false);
            } else {
                if (this.horizontal == '') this.horizontal = this.vertical;
                if (this.vertical == '') this.vertical = this.horizontal;
            }
            if (this._cbitmap == null) this._cbitmap = new PictureImage(onBTLoad);
            this._cbitmap.load(this.close);
            return (true);
        } else {
            return (false);
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.id = this.font = this.fontcolor = this.horizontal = this.vertical = this.close = null;
        if (this.parent != null) this.parent.removeChild(this);
        if (this._cbitmap != null) {
            if (this._cbitmap.hasEventListener(MouseEvent.CLICK)) {
                this._cbitmap.removeEventListener(MouseEvent.CLICK, onClose);
                this._cbitmap.removeEventListener(MouseEvent.MOUSE_OVER, onCloseOver);
                this._cbitmap.removeEventListener(MouseEvent.MOUSE_OUT, onCloseOut);
            }
            this._cbitmap.kill();
        }
        this._cbitmap = null;
        if (this._hbitmap != null) this._hbitmap.kill();
        this._hbitmap = null;
        if (this._vbitmap != null) this._vbitmap.kill();
        this._vbitmap = null;
        while (this._rows.length > 0) this._rows.shift().kill();
        this._rows = null;
    }

    public function toObject():Dynamic {
        return({
            id: this.id, 
            font: this.font, 
            fontcolor: this.fontcolor, 
            fontsize: this.fontsize, 
            horizontal: this.horizontal, 
            vertical: this.vertical, 
            close: this.close, 
            mode: this.mode, 
        });
    }

    public function invClose():Void {
        this.onCloseOut(null);
        this.removeChildren();
        if (this._closeac != null) {
            GlobalPlayer.parser.run(this._closeac, true);
            this._closeac = null;
        }
    }

    private function onBTLoad(ok:Bool):Void {
        this.ok = ok;
        if (ok) {
            if (this._hbitmap == null) this._hbitmap = new PictureImage(onBgLoad);
            this._hbitmap.load(this.horizontal);
            if (this._vbitmap == null) this._vbitmap = new PictureImage(onBgLoad);
            this._vbitmap.load(this.vertical);
            this._cbitmap.addEventListener(MouseEvent.CLICK, onClose);
            this._cbitmap.addEventListener(MouseEvent.MOUSE_OVER, onCloseOver);
            this._cbitmap.addEventListener(MouseEvent.MOUSE_OUT, onCloseOut);
        }
    }

    private function onBgLoad(ok:Bool):Void {
        if (!ok) this.ok = false;
    }

    private function onClose(evt:MouseEvent = null):Void {
        GlobalPlayer.parser.run('[ { "ac": "inventory.close", "param": [ ] } ]');
    }

    private function onCloseOver(evt:MouseEvent = null):Void {
        if (GlobalPlayer.cursorVisible) if ((GlobalPlayer.mode != Player.MODE_EDITOR) && (GlobalPlayer.mdata.highlightInt != null) && !GlobalPlayer.isMobile()) {
            this._cbitmap.filters = [
                new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
            ];
        }
    }

    private function onCloseOut(evt:MouseEvent = null):Void {
        this._cbitmap.filters = [ ];
    }
}

class InvItemRow extends Sprite {

    public var boxes:Array<PictureImage> = [ ];

    private var _texts:Array<TextField> = [ ];

    private var _size:Float = 0;

    private var _draw:Dynamic = null;

    public function new(dr) {
        super();
        this.visible = false;
        this._draw = dr;
        for (i in 0...4) {
            var box:PictureImage = new PictureImage(onBox);
            box.extraInfo.push('');
            box.addEventListener(MouseEvent.CLICK, onBoxClick);
            box.addEventListener(MouseEvent.MOUSE_OVER, onBoxOver);
            box.addEventListener(MouseEvent.MOUSE_OUT, onBoxOut);
            this.addChild(box);
            this.boxes.push(box);
            var text:TextField = new TextField();
            text.visible = false;
            this.addChild(text);
            this._texts.push(text);
        }
    }

    public function setData(names:Array<String>, amounts:Array<Int> = null):Void {
        this.visible = false;
        if (amounts == null) amounts = [ 0, 0, 0, 0 ];
        for (i in 0...this.boxes.length) {
            this.boxes[i].visible = false;
            this.boxes[i].extraInfo[0] = '';
            this.boxes[i].extraInfo[1] = Std.string(i);
            this.boxes[i].unload();
            this._texts[i].visible = false;
            this._texts[i].text = '';
        }
        for (i in 0...names.length) {
            if (i < 4) {
                if (GlobalPlayer.narrative.items.exists(names[i])) {
                    this.boxes[i].extraInfo[0] = names[i];
                    this.boxes[i].load(GlobalPlayer.narrative.items[names[i]].itgraphic);
                    if (amounts[i] != 0) this._texts[i].text = Std.string(amounts[i]);
                }
            }
        }
    }

    public function draw(orientation:String, size:Float, iconsize:Float):Void {
        this._size = iconsize;
        var spacer:Float = size / 9;
        for (i in 0...this.boxes.length) {
            boxes[i].width = boxes[i].height = this._size;
            if (orientation == 'h') {
                boxes[i].y = 0;
                boxes[i].x = spacer + (i * 2 * spacer);
            } else {
                boxes[i].x = 0;
                boxes[i].y = spacer + (i * 2 * spacer);
            }
        }
    }

    public function onBox(ok:Bool):Void {
        for (i in 0...this.boxes.length) {
            this.boxes[i].visible = this.boxes[i].mediaLoaded;
            if (this.boxes[i].mediaLoaded) {
                this.visible = true;
                this.boxes[i].width = this.boxes[i].height = this._size;
                if (this._texts[i].text != '') {
                    this._texts[i].width = this._size;
                    this._texts[i].x = this.boxes[i].x;
                    this._texts[i].y = this.boxes[i].y + this._size + 5;
                    this._texts[i].visible = true;
                }
            }
        }
    }

    public function kill():Void {
        this.removeChildren();
        while (this.boxes.length > 0) {
            this.boxes[0].removeEventListener(MouseEvent.CLICK, onBoxClick);
            this.boxes[0].removeEventListener(MouseEvent.MOUSE_OVER, onBoxOver);
            this.boxes[0].removeEventListener(MouseEvent.MOUSE_OUT, onBoxOut);
            this.boxes.shift().kill();
        }
        this.boxes = null;
        while (this._texts.length > 0) this._texts.shift();
        this._texts = null;
        this._draw = null;
    }

    public function setText(font:String, size:Int, color:Int):Void {
        for (t in this._texts) {
            t.defaultTextFormat = new TextFormat(font, size, color, null, null, null, null, null, 'center');
        }
    }

    public function checkCollision(obj:Sprite):Bool {
        var found:Bool = false;
        for (b in this.boxes) {
            if (!found && b.visible) {
                if (b.hitTestObject(obj)) {
                    if (GlobalPlayer.narrative.items.exists(b.extraInfo[0])) {
                        if (GlobalPlayer.narrative.items[b.extraInfo[0]].itaction != '') {
                            found = true;
                            var ac:String = GlobalPlayer.narrative.items[b.extraInfo[0]].itaction;
                            if (this._texts[Std.parseInt(b.extraInfo[1])].text != '') {
                                GlobalPlayer.narrative.consumeItem(b.extraInfo[0]);
                                this._draw();
                            }
                            SpriteStatic.quickJump(b, 0.3, 5);
                            GlobalPlayer.parser.run(ac);
                        }
                    }
                }
            }
        }
        return (found);
    }

    public function checkOver(obj:Sprite):Bool {
        var found:Bool = false;
        for (b in this.boxes) {
            if (!found && b.visible) {
                if (b.hitTestObject(obj)) {
                    if (GlobalPlayer.narrative.items.exists(b.extraInfo[0])) {
                        if (GlobalPlayer.narrative.items[b.extraInfo[0]].itaction != '') {
                            found = true;
                        }
                    }
                }
            }
        }
        return (found);
    }

    private function onBoxClick(evt:MouseEvent):Void {
        var box:PictureImage = cast evt.target;
        if (GlobalPlayer.narrative.items.exists(box.extraInfo[0])) {
            if (GlobalPlayer.narrative.items[box.extraInfo[0]].itaction != '') {
                var ac:String = GlobalPlayer.narrative.items[box.extraInfo[0]].itaction;
                if (this._texts[Std.parseInt(box.extraInfo[1])].text != '') {
                    GlobalPlayer.narrative.consumeItem(box.extraInfo[0]);
                    this._draw();
                }
                SpriteStatic.quickJump(box, 0.3, 5);
                GlobalPlayer.parser.run(ac);
            }
        }
    }

    private function onBoxOver(evt:MouseEvent):Void {
        if (GlobalPlayer.cursorVisible) if ((GlobalPlayer.mode != Player.MODE_EDITOR) && (GlobalPlayer.mdata.highlightInt != null) && !GlobalPlayer.isMobile()) {
            var box:PictureImage = cast evt.target;
            if (GlobalPlayer.narrative.items.exists(box.extraInfo[0])) {
                if (GlobalPlayer.narrative.items[box.extraInfo[0]].itaction != '') {
                    box.filters = [
                        new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
                    ];
                }
            }
        }
    }

    private function onBoxOut(evt:MouseEvent):Void {
        var box:PictureImage = cast evt.target;
        box.filters = [ ];
    }

}