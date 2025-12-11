/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import haxe.Timer;
import com.tilbuci.statictools.SpriteStatic;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
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

    public var card:String = '';

    public var attrbg:String = '';

    public var attributes:Array<String> = [ ];

    private var _hbitmap:PictureImage;

    private var _vbitmap:PictureImage;

    private var _cbitmap:PictureImage;

    private var _abitmap:PictureImage;

    private var _onloose:Dynamic = null;

    private var _onwin:Dynamic = null;

    private var _player:BattleCard;

    private var _playerCurent:CurrentCards;

    private var _opponent:BattleCard;

    private var _opponentCurent:CurrentCards;

    private var _pcards:Array<String>;

    private var _ocards:Array<String>;

    private var _cardsize:Point;

    private var _playerData:BattleData;

    private var _opponentData:BattleData;

    private var _won:Bool = false;

    private var _timer:Timer;

    public function new() {
        super();
        this._playerData = new BattleData();
        this._opponentData = new BattleData();
    }

    private function compare(num:Int):Void {
        if (this._timer == null) {
            var valP:Int = this._playerData.getValue(num);
            var valO:Int = this._opponentData.getValue(num);
            if (valP < valO) {
                SpriteStatic.shake(this._player, 0.5, 5);
                SpriteStatic.quickJump(this._opponent, 0.5, 30);
                this._opponent.showAttrVal(num);
                this._timer = new Timer(500);
                this._timer.run = this.onLoose;
            } else if (valP > valO) {
                SpriteStatic.quickJump(this._player, 0.5, 30);
                SpriteStatic.shake(this._opponent, 0.5, 5);
                this._timer = new Timer(500);
                this._timer.run = this.onWin;
            } else {
                SpriteStatic.shake(this._player, 0.5, 5);
                SpriteStatic.shake(this._opponent, 0.5, 5);
                this._opponent.showAttrVal(num);
            }
        }
    }

    private function onLoose():Void {
        try { this._timer.stop(); } catch (e) { }
        this._timer = null;
        var index:Int = this._playerData.current + 1;
        this._playerCurent.updateDisplay(index);
        if (index >= this._pcards.length) {
            this._won = false;
            this.onClose();
        } else {
            this._playerData.loadCard(this._pcards[index], index);
            this._player.draw(this._pcards[index]);
        }
    }

    private function onWin():Void {
        try { this._timer.stop(); } catch (e) { }
        this._timer = null;
        var index:Int = this._opponentData.current + 1;
        this._opponentCurent.updateDisplay(index);
        if (index >= this._ocards.length) {
            this._won = true;
            this.onClose();
        } else {
            this._opponentData.loadCard(this._ocards[index], index);
            this._opponent.draw(this._ocards[index]);
        }
    }

    public function setAttributes(pl:Bool, attr:Int, gain:Int, add:Int, rem:Int):Void {
        if (attr < 0) attr = 0;
        if (attr > 4) attr = 4;
        if (pl) {
            this._playerData.setAttr(attr, gain, add, rem);
        } else {
            this._opponentData.setAttr(attr, gain, add, rem);
        }
    }

    public function create(win:Dynamic, loose:Dynamic, pcards:Array<String>, ocards:Array<String>):Sprite {
        this.removeChildren();
        this._cbitmap.visible = true;
        this._hbitmap.visible = this._vbitmap.visible = false;
        if (this.ok) {
            if (this._player == null) this._player = new BattleCard(this.draw, true, this.compare, this._playerData);
            if (this._opponent == null) this._opponent = new BattleCard(this.draw, false, null, this._opponentData);
            this._pcards = pcards;
            this._ocards = ocards;

            this._playerData.loadCard(pcards[0], 0);
            this._opponentData.loadCard(ocards[0], 0);

            this._player.draw(this._pcards[0]);
            this._opponent.draw(this._ocards[0]);

            if (this._playerCurent == null) this._playerCurent = new CurrentCards(this.draw);
            if (this._opponentCurent == null) this._opponentCurent = new CurrentCards(this.draw);
            this._playerCurent.draw(this._pcards);
            this._opponentCurent.draw(this._ocards);

            if (GlobalPlayer.area.pOrientation == MovieArea.HORIENTATION) {
                this.addChild(this._hbitmap);
                this._hbitmap.x = this._hbitmap.y = 0;
                this._hbitmap.width = GlobalPlayer.mdata.screen.big;
                this._hbitmap.height = GlobalPlayer.mdata.screen.small;
                this._cbitmap.x = this._hbitmap.width - this._cbitmap.width;
                this._hbitmap.visible = true;
                this._player.x = this._cbitmap.width;
                this._player.y = this._cbitmap.height;
                this._opponent.x = (this._hbitmap.width / 2) + (this._cbitmap.width / 2);
                this._opponent.y = this._cbitmap.height;
                this._playerCurent.x = this._player.x;
                this._opponentCurent.x = this._opponent.x;
                this._playerCurent.y = GlobalPlayer.mdata.screen.small - (this.btAtrHeight() * 1.5);
                this._opponentCurent.y = GlobalPlayer.mdata.screen.small - (this.btAtrHeight() * 1.5);
                this._cardsize = new Point(
                    (GlobalPlayer.mdata.screen.big / 2) - (1.5 * this._cbitmap.width), 
                    GlobalPlayer.mdata.screen.small - this._cbitmap.height - (this.btAtrHeight() * 2)
                );
            } else {
                this.addChild(this._vbitmap);
                this._vbitmap.x = this._vbitmap.y = 0;
                this._vbitmap.width = GlobalPlayer.mdata.screen.small;
                this._vbitmap.height = GlobalPlayer.mdata.screen.big;
                this._cbitmap.x = this._vbitmap.width - this._cbitmap.width;
                this._vbitmap.visible = true;
                this._player.x = this._cbitmap.width;
                this._player.y = this._cbitmap.height;
                this._opponent.x = this._cbitmap.width;
                this._opponent.y = (this._vbitmap.height / 2) + (this._cbitmap.height / 2);
                this._playerCurent.x = this._player.x;
                this._opponentCurent.x = this._opponent.x;
                this._playerCurent.y = (this._vbitmap.height / 2) - (this.btAtrHeight() * 0.5);
                this._opponentCurent.y = this._vbitmap.height - (this.btAtrHeight() * 1.5);
                this._cardsize = new Point(
                    this._vbitmap.width - (2 * this._cbitmap.width), 
                    (this._vbitmap.height / 2) - (this._cbitmap.height / 2) - (this.btAtrHeight() * 2)
                );

            }
            this._cbitmap.y = 0;
            this.addChild(this._cbitmap); 
            this.addChild(this._player);
            this.addChild(this._opponent);
            this.addChild(this._playerCurent);
            this.addChild(this._opponentCurent);
            this._onloose = loose; 
            this._onwin = win; 
            this._won = false;
        }
        return (this);
    }

    public function draw():Void {
        this._player.width = this._cardsize.x;
        this._player.scaleY = this._player.scaleX;
        if (this._player.height > this._cardsize.y) {
            this._player.height = this._cardsize.y;
            this._player.scaleX = this._player.scaleY;
        }
        this._opponent.width = this._cardsize.x;
        this._opponent.scaleY = this._opponent.scaleX;
        if (this._opponent.height > this._cardsize.y) {
            this._opponent.height = this._cardsize.y;
            this._opponent.scaleX = this._opponent.scaleY;
        }
        if (GlobalPlayer.area.pOrientation == MovieArea.HORIENTATION) {
            this._player.x = this._cbitmap.width + ((this._cardsize.x - this._player.width) / 2);
            this._player.y = this._cbitmap.height + ((this._cardsize.y - this._player.height) / 2);
            this._opponent.x = (this._hbitmap.width / 2) + (this._cbitmap.width / 2) + ((this._cardsize.x - this._opponent.width) / 2);
            this._opponent.y = this._cbitmap.height + ((this._cardsize.y - this._opponent.height) / 2);
        } else {
            this._player.x = this._cbitmap.width + ((this._cardsize.x - this._player.width) / 2);
            this._opponent.x = this._cbitmap.width + ((this._cardsize.x - this._opponent.width) / 2);
            this._player.y = this._cbitmap.height + ((this._cardsize.y - this._player.height) / 2);
            this._opponent.y = ((this._vbitmap.height / 2) + (this._cbitmap.height / 2)) + ((this._cardsize.y - this._opponent.height) / 2);
        }

        /*if (this._playerCurent.width > (this._player.width - (2 * this.btAtrHeight()))) {
            this._playerCurent.width = this._player.width - (2 * this.btAtrHeight());
            this._playerCurent.scaleY = this._playerCurent.scaleX;
        }
        if (this._opponentCurent.width > (this._opponent.width - (2 * this.btAtrHeight()))) {
            this._opponentCurent.width = this._opponent.width - (2 * this.btAtrHeight());
            this._opponentCurent.scaleY = this._opponentCurent.scaleX;
        }*/
        this._playerCurent.x = this._player.x + ((this._player.width - this._playerCurent.width) / 2);
        this._opponentCurent.x = this._opponent.x + ((this._opponent.width - this._opponentCurent.width) / 2);
    }

    public function checkCollision(obj:Sprite):Bool {
        var found:Bool = false;
        if (this.ok) {
            found = this._cbitmap.hitTestObject(obj);
            if (found) {
                this.onClose();
            } else {
                found = this._player.checkCollision(obj);
            }
        }
        return (found);
    }

    public function checkOver(obj:Sprite):Bool {
        var found:Bool = false;
        if (this.ok) {
            found = this._cbitmap.hitTestObject(obj);
            if (!found) found = this._player.checkOver(obj);
        }
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
            card: this.card, 
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
            if (Reflect.hasField(data, 'card')) this.card = Reflect.field(data, 'card');
                else this.card = '';
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
        this._player.kill();
        this._player = null;
        this._opponent.kill();
        this._opponent = null;
        this._playerCurent.kill();
        this._playerCurent = null;
        this._opponentCurent.kill();
        this._opponentCurent = null;
        while (this._pcards.length > 0) this._pcards.shift();
        this._pcards = null;
        while (this._ocards.length > 0) this._ocards.shift();
        this._ocards = null;
        this._onwin = null;
        this._onloose = null;
        this._playerData.kill();
        this._opponentData.kill();
        this._playerData = null;
        this._opponentData = null;
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
            card: this.card, 
        });
    }

    public function bsClose():Void {
        this.onCloseOut(null);
        this.removeChildren();
        if (this._won) {
            this._won = false;
            if (this._onwin != null) GlobalPlayer.parser.run(this._onwin, true);
        } else {
            if (this._onloose != null) GlobalPlayer.parser.run(this._onloose, true);
        }
        this._onloose = null;
        this._onwin = null;
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

    public var attributes:Array<AttributeButton> = [ ];

    public var background:PictureImage;

    private var _holder:Sprite;

    private var _draw:Dynamic;

    private var _player:Bool = false;

    private var _data:BattleData;

    private var _totalAttr:Int = 5;

    public function new(draw:Dynamic, pl:Bool, cp:Dynamic, data:BattleData) {
        super();
        if (GlobalPlayer.contraptions.bs.exists('bs') && (GlobalPlayer.contraptions.bs['bs'].card != ''))  {
            this._totalAttr = 0;
            for (i in GlobalPlayer.contraptions.bs['bs'].attributes) {
                if (i != '') this._totalAttr++;
            }
        }
        this._holder = new Sprite();
        this.graphic = new PictureImage(onPic);
        this.background = new PictureImage(onBg);
        for (i in 0...5) this.attributes.push(new AttributeButton(i, pl, cp));
        if (GlobalPlayer.contraptions.bs.exists('bs') && (GlobalPlayer.contraptions.bs['bs'].card != '')) {
            this.background.load(GlobalPlayer.contraptions.bs['bs'].card);
        }
        this._draw = draw;
        this._player = pl;
        this._data = data;
    }

    public function draw(cardid:String):Void {
        this.removeChildren();
        if (GlobalPlayer.narrative.cards.exists(cardid)) {
            for (a in this.attributes) a.visible = false;
            for (i in 0...GlobalPlayer.contraptions.bs['bs'].attributes.length) {
                this.attributes[i].draw(i, this._data.getValue(i, true), this._data.add[i], this._data.rem[i]);
            }
            this.graphic.load(GlobalPlayer.narrative.cards[cardid].cardgraphic);
            if (this.background.lastMedia != GlobalPlayer.contraptions.bs['bs'].card) {
                this.background.load(GlobalPlayer.contraptions.bs['bs'].card);
            }
        }
    }

    public function showAttrVal(num:Int):Void {
        this.attributes[num].showValue(this._data.getValue(num, true), this._data.add[num], this._data.rem[num]);
    }

    public function kill():Void {
        this.removeChildren();
        this._holder.removeChildren();
        this.graphic.kill();
        this.graphic = null;
        this.background.kill();
        this.background = null;
        while (this.attributes.length > 0) this.attributes.shift().kill();
        this.attributes = null;
        this._draw = null;
        this._data = null;
    }

    public function checkOver(obj:Sprite):Bool {
        var found:Bool = false;
        for (at in this.attributes) {
            if (!found) if (obj.hitTestObject(at)) found = true;
        }
        return (found);
    }

    public function checkCollision(obj:Sprite):Bool {
        var found:Bool = false;
        for (at in this.attributes) {
            if (!found) {
                if (obj.hitTestObject(at)) {
                    found = true;
                    at.onClick();
                }
            }
        }
        return (found);
    }

    private function onPic(ok:Bool):Void {
        this._holder.removeChildren();
        this.graphic.width = this.graphic.height = GlobalPlayer.contraptions.bs['bs'].btAtrHeight() * 3;
        this.graphic.x = (GlobalPlayer.contraptions.bs['bs'].btAtrWidth() - this.graphic.width) / 2;
        this.graphic.y = 0;
        this.graphic.visible = true;
        this._holder.addChild(this.graphic);

        for (i in 0...this.attributes.length) {
            if (this.attributes[i].visible) {
                this.attributes[i].x = 0;
                this.attributes[i].y = this.graphic.height + (GlobalPlayer.contraptions.bs['bs'].btAtrHeight() / 2) + (i * GlobalPlayer.contraptions.bs['bs'].btAtrHeight() / this._totalAttr) + (i * GlobalPlayer.contraptions.bs['bs'].btAtrHeight());
                this._holder.addChild(attributes[i]);
            }
        }

        this.place();
    }

    private function onBg(ok:Bool):Void {
        this.background.width = this.background.oWidth;
        this.background.height = this.background.oHeight;
        this.background.visible = true;
        this.place();
    }

    private function place():Void {
        this.removeChildren();
        this.background.width = this.background.oWidth;
        this.background.height = this.background.oHeight;
        this.background.x = this.background.y = 0;

        this._holder.width = this.background.width - (2 * GlobalPlayer.contraptions.bs['bs'].btAtrHeight() / this._totalAttr);
        this._holder.scaleY = this._holder.scaleX;
        if (this._holder.height > (this.background.height - (2 * GlobalPlayer.contraptions.bs['bs'].btAtrHeight() / this._totalAttr))) {
            this._holder.height = this.background.height - (2 * GlobalPlayer.contraptions.bs['bs'].btAtrHeight() / this._totalAttr);
            this._holder.scaleX = this._holder.scaleY;
        }
        this._holder.x = (this.background.width - this._holder.width) / 2;
        this._holder.y = (this.background.height - this._holder.height) / 2;

        this.addChild(this.background);
        this.addChild(this._holder);
        this._draw();
    }

}

class AttributeButton extends Sprite {

    public var id:Int;

    public var graphic:PictureImage;

    public var text:TextField;

    public var value:TextField;

    private var _player:Bool = false;

    private var _compare:Dynamic;

    public function new(id:Int, pl:Bool, cp:Dynamic) {
        super();
        this.id = id;
        this._player = pl;
        this._compare = cp;
        this.graphic = new PictureImage(onPic);
        this.text = new TextField();
        this.value = new TextField();
        this.addChild(this.graphic);
        this.addChild(this.text);
        this.addChild(this.value);

        this.mouseChildren = false;
        if (GlobalPlayer.contraptions.bs.exists('bs') && (GlobalPlayer.contraptions.bs['bs'].attrbg) != '') {
            this.graphic.load(GlobalPlayer.contraptions.bs['bs'].attrbg);
        }
        if (pl) {
            this.addEventListener(MouseEvent.CLICK, onClick);
            this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
            this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
        }
    }

    public function showValue(val:Int, add:Int, rem:Int):Void {
        if ((add == 0) && (rem == 0)) {
            this.value.text = val + '';
        } else {
            if (rem != 0) {
                this.value.text = (val - rem) + ' ... ';
            } else {
                this.value.text = val + ' ... ';
            }
            if (add != 0) {
                this.value.text += (val + add) + '';
            } else {
                this.value.text += val + '';
            }
        }
    }

    public function draw(attr:Int, val:Int, add:Int, rem:Int):Void {
        this.visible = true;
        this.text.defaultTextFormat = new TextFormat(GlobalPlayer.contraptions.bs['bs'].font, 
            GlobalPlayer.contraptions.bs['bs'].fontsize,
            StringStatic.colorInt(GlobalPlayer.contraptions.bs['bs'].fontcolor), 
            null, null, null, null, null, 'left');
        this.value.defaultTextFormat = new TextFormat(GlobalPlayer.contraptions.bs['bs'].font, 
            GlobalPlayer.contraptions.bs['bs'].fontsize,
            StringStatic.colorInt(GlobalPlayer.contraptions.bs['bs'].fontcolor), 
            null, null, null, null, null, 'right');
        if (this._player) {
            this.text.text = GlobalPlayer.parser.parseString(GlobalPlayer.contraptions.bs['bs'].attributes[attr]);
            if ((add == 0) && (rem == 0)) {
                this.value.text = val + '';
            } else {
                if (rem != 0) {
                    this.value.text = (val - rem) + ' ... ';
                } else {
                    this.value.text = val + ' ... ';
                }
                if (add != 0) {
                    this.value.text += (val + add) + '';
                } else {
                    this.value.text += val + '';
                }
            }

        } else {
            this.text.text = GlobalPlayer.parser.parseString(GlobalPlayer.contraptions.bs['bs'].attributes[attr]);
            this.value.text = '?';
        }
        if (this.graphic.lastMedia != GlobalPlayer.contraptions.bs['bs'].attrbg) {
            this.graphic.load(GlobalPlayer.contraptions.bs['bs'].attrbg);
        } else {
            this.onPic(true);
        }
    }

    public function kill():Void {
        this.removeChildren();
        if (this._player) {
            this.removeEventListener(MouseEvent.CLICK, onClick);
            this.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
            this.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
        }
        this.text = null;
        this.value = null;
        this.graphic.kill();
        this.graphic = null;
        this._compare = null;
    }

    private function onPic(ok:Bool):Void {
        this.graphic.visible = true;
        this.graphic.width = this.graphic.oWidth;
        this.graphic.height = this.graphic.oHeight;
        this.text.height = this.text.textHeight + 4;
        this.text.y = (this.graphic.oHeight - this.text.height) / 2;
        this.text.visible = true;
        this.value.height = this.value.textHeight + 4;
        this.value.y = (this.graphic.oHeight - this.value.height) / 2;
        this.value.visible = true;
        this.text.width = this.value.width = this.graphic.width - this.graphic.height;
        this.text.x = this.value.x = this.graphic.height / 2;
    }

    public function onClick(evt:MouseEvent = null):Void {
        this._compare(this.id);
    }

    private function onOver(evt:MouseEvent):Void {
        if (GlobalPlayer.cursorVisible) if ((GlobalPlayer.mode != Player.MODE_EDITOR) && (GlobalPlayer.mdata.highlightInt != null) && !GlobalPlayer.isMobile()) {
            this.filters = [
                new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
            ];
        }
    }

    private function onOut(evt:MouseEvent):Void {
        this.filters = [ ];
    }
}

class CurrentCards extends Sprite {

    public var cards:Array<PictureImage> = [ ];

    private var _draw:Dynamic;

    public function new(draw:Dynamic) {
        super();
        this.mouseEnabled = false;
        for (i in 0...5) {
            this.cards.push(new PictureImage(onCard));
        }
        this._draw = draw;
    }

    public function updateDisplay(current:Int):Void {
        for (i in 0...this.cards.length) {
            if (i >= current) {
                this.cards[i].alpha = 1;
            } else {
                this.cards[i].alpha = 0.25;
            }
        }
    }

    public function draw(list:Array<String>):Void {
        this.removeChildren();
        for (c in this.cards) {
            c.visible = false;
            c.unload();
        }
        for (i in 0...list.length) {
            if (i < this.cards.length) {
                if (GlobalPlayer.narrative.cards.exists(list[i])) {
                    this.cards[i].load(GlobalPlayer.narrative.cards[list[i]].cardgraphic);
                    this.cards[i].alpha = 1;
                }
            }
            
        }
    }

    public function kill():Void {
        this.removeChildren();
        while (this.cards.length > 0) this.cards.shift().kill();
        this.cards = null;
        this._draw = null;
    }

    private function onCard(ok:Bool):Void {
        this.removeChildren();
        for (i in 0...this.cards.length) {
            if (this.cards[i].mediaLoaded) {
                this.cards[i].width = this.cards[i].height = (GlobalPlayer.contraptions.bs['bs'].btAtrHeight() / 2);
                this.cards[i].y = 0;
                this.cards[i].x = i * ((GlobalPlayer.contraptions.bs['bs'].btAtrHeight() / 2) + (0.5 * GlobalPlayer.contraptions.bs['bs'].btAtrHeight() / 3));
                this.cards[i].visible = true;
                this.addChild(this.cards[i]);
            }
        }
        this._draw();
    }

}

class BattleData {

    public var current:Int = -1;

    public var attr:Array<Int> = [ 0, 0, 0, 0, 0 ];

    public var gain:Array<Int> = [ 0, 0, 0, 0, 0 ];

    public var add:Array<Int> = [ 0, 0, 0, 0, 0 ];

    public var rem:Array<Int> = [ 0, 0, 0, 0, 0 ];

    public function new() {

    }

    public function clear():Void {
        this.current = 0;
    }

    public function loadCard(name:String, index:Int):Void {
        trace ('load card', name, GlobalPlayer.narrative.cards[name].cardattributes);
        if (GlobalPlayer.narrative.cards.exists(name)) {
            while (this.attr.length > 0) this.attr.shift();
            for (i in GlobalPlayer.narrative.cards[name].cardattributes) {
                this.attr.push(i);
            }
            this.current = index;
        }
    }

    public function setAttr(attr:Int, gain:Int, add:Int, rem:Int):Void {
        this.gain[attr] = gain;
        this.add[attr] = add;
        this.rem[attr] = rem;
    }

    public function getValue(attr:Int, base:Bool = false):Int {
        trace ('get value', attr, this.attr[attr], this.gain[attr], this.add[attr], this.rem[attr]);
        if (base) {
            return (this.attr[attr] + this.gain[attr]);
        } else {
            return (this.attr[attr] + this.gain[attr] + Std.int(Math.random() * this.add[attr]) - Std.int(Math.random() * this.rem[attr]));
        }
    }

    public function kill():Void {
        while (this.attr.length > 0) this.attr.shift();
        while (this.gain.length > 0) this.gain.shift();
        while (this.add.length > 0) this.add.shift();
        while (this.rem.length > 0) this.rem.shift();
        this.attr = null;
        this.gain = null;
        this.add = null;
        this.rem = null;
    }

}