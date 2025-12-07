/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
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

class BattleContraption extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var font:String = 'sans';

    public var fontcolor:String = '0xffffff';

    public var fontsize:Int = 20;

    public var horizontal:String = '';

    public var vertical:String = '';

    public var close:String = '';

    public var attrbg:String = '';

    public var attributes:Array<String> = [ ];

    private var _hbitmap:PictureImage;

    private var _vbitmap:PictureImage;

    private var _cbitmap:PictureImage;

    private var _abitmap:PictureImage;

    private var _closeac:Dynamic = null;

    private var _player:BattleCard;

    private var _opponent:BattleCard;    

    public function new() {
        super();
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
            this._cbitmap.y = 0;
            this.addChild(this._cbitmap); 
            this._closeac = closeac; 
            if (this._player == null) this._player = new BattleCard();
            if (this._opponent == null) this._opponent = new BattleCard();
        }
        return (this);
    }

    public function draw():Void {
        /*for (r in this._rows) r.setText(this.font, this.fontsize, StringStatic.colorInt(this.fontcolor));
        
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
        }*/
    }

    public function checkCollision(obj:Sprite):Bool {
        var found:Bool = false;
        /*if (this.ok) {
            found = this._cbitmap.hitTestObject(obj);
            if (found) {
                this.onClose();
            } else {
                if (!found) found = this._rows[0].checkCollision(obj);
                if (!found) found = this._rows[1].checkCollision(obj);
                if (!found) found = this._rows[2].checkCollision(obj);
            }
        }*/
        return (found);
    }

    public function checkOver(obj:Sprite):Bool {
        var found:Bool = false;
        /*if (this.ok) {
            found = this._cbitmap.hitTestObject(obj);
            if (!found) found = this._rows[0].checkOver(obj);
            if (!found) found = this._rows[1].checkOver(obj);
            if (!found) found = this._rows[2].checkOver(obj);
        }*/
        return (found);
    }

    public function remove():Void {
        this.removeChildren();
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function clone():BattleContraption {
        var mn:BattleContraption = new BattleContraption();
        mn.load({
            id: this.id, 
            font: this.font, 
            fontcolor: this.fontcolor, 
            fontsize: this.fontsize, 
            horizontal: this.horizontal, 
            vertical: this.vertical, 
            close: this.close, 
            attrbg: this.attrbg, 
            attributes: this.attributes, 
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
            if (Reflect.hasField(data, 'attrbg')) this.attrbg = Reflect.field(data, 'attrbg');
                else this.attrbg = '';
            if (Reflect.hasField(data, 'attributes')) {
                var atr:Array<String> = cast Reflect.field(data, 'attributes');
                if (atr == null) {
                    this.attributes = [ ];
                } else {
                    this.attributes = atr;
                }
            } else {
                this.attributes = [ ];
            }
            this.fontcolor = StringStatic.colorHex(this.fontcolor, '#FFFFFF');

            if ((this.close == '') || (this.attrbg == '')) {
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

    public function loadGraphics():Void {
        this.ok = false;
        this._cbitmap.load(this.close);
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
        if (this._abitmap != null) this._abitmap.kill();
        this._abitmap = null;
        while (this.attributes.length > 0) this.attributes.shift();
        this.attributes = null;
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
            attrbg: this.attrbg, 
            attributes: this.attributes, 
        });
    }

    public function bsClose():Void {
        this.onCloseOut(null);
        this.removeChildren();
        if (this._closeac != null) {
            GlobalPlayer.parser.run(this._closeac, true);
            this._closeac = null;
        }
    }

    public function btAtrWidth():Float {
        if (this.ok) {
            return (this._abitmap.oWidth);
        } else {
            return (0);
        }
    }

    public function btAtrHeight():Float {
        if (this.ok) {
            return (this._abitmap.oHeight);
        } else {
            return (0);
        }
    }

    private function onBTLoad(ok:Bool):Void {
        this.ok = ok;
        if (ok) {
            if (this._abitmap == null) this._abitmap = new PictureImage(onAttrLoad);
            this._abitmap.load(this.attrbg);
        }
    }

    private function onAttrLoad(ok:Bool):Void {
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
        GlobalPlayer.parser.run('[ { "ac": "battle.close", "param": [ ] } ]');
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

class BattleCard extends Sprite {

    public var graphic:PictureImage;

    public var attributes:Array<AttributeButton>;

    public function new() {
        super();
        this.graphic = new PictureImage(onPic);
        for (i in 0...5) this.attributes.push(new AttributeButton(i));
    }

    public function draw(cardid:String):Void {
        this.removeChildren();
        if (GlobalPlayer.narrative.cards.exists(cardid)) {
            for (a in this.attributes) a.visible = false;
            for (i in 0...GlobalPlayer.contraptions.bs['bs'].attributes.length) {
                this.attributes[i].draw(i, GlobalPlayer.narrative.cards[cardid].cardattributes[i]);
            }
            this.graphic.load(GlobalPlayer.narrative.cards[cardid].cardgraphic);
        }
    }

    private function onPic(ok:Bool):Void {
        this.graphic.width = this.graphic.height = GlobalPlayer.contraptions.bs['bs'].btAtrWidth();
        this.graphic.x = this.graphic.y = 0;
        this.graphic.visible = true;
        this.addChild(this.graphic);

        for (i in 0...this.attributes.length) {
            if (this.attributes[i].visible) {
                this.attributes[i].x = 0;
                this.attributes[i].y = this.graphic.height + GlobalPlayer.contraptions.bs['bs'].btAtrHeight() + (i * 2 * GlobalPlayer.contraptions.bs['bs'].btAtrHeight());
                this.addChild(attributes[i]);
            }
        }
    }

}

class AttributeButton extends Sprite {

    public var id:Int;

    public var graphic:PictureImage;

    public var text:TextField;

    public function new(id:Int) {
        super();
        this.id = id;
        this.graphic = new PictureImage(onPic);
        this.text = new TextField();
        this.addChild(this.graphic);
        this.addChild(this.text);
        this.mouseChildren = false;
    }

    public function draw(attr:Int, val:Int) {
        this.visible = true;
        this.text.defaultTextFormat = new TextFormat(GlobalPlayer.contraptions.bs['bs'].font, 
            GlobalPlayer.contraptions.bs['bs'].fontsize,
            StringStatic.colorInt(GlobalPlayer.contraptions.bs['bs'].fontcolor), 
            null, null, null, null, null, 'center');
        this.text.text = GlobalPlayer.parser.parseString(GlobalPlayer.contraptions.bs['bs'].attributes[attr]) + ' (' + val + ')';
        if (this.graphic.lastMedia != GlobalPlayer.contraptions.bs['bs'].attrbg) {
            this.graphic.load(GlobalPlayer.contraptions.bs['bs'].attrbg);
        } else {
            this.onPic(true);
        }
    }

    private function onPic(ok:Bool):Void {
        this.graphic.visible = true;
        this.graphic.width = this.text.width = this.graphic.oWidth;
        this.graphic.height = this.graphic.oHeight;
        this.text.height = this.text.textHeight + 4;
        this.text.y = (this.graphic.oHeight - this.text.height) / 2;
        this.text.visible = true;
    }
}