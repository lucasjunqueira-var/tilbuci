/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
import openfl.text.TextFormat;
import com.tilbuci.display.SpritemapImage;
import openfl.text.TextField;
import com.tilbuci.display.BaseImage;
import openfl.filters.GlowFilter;
import com.tilbuci.player.MovieArea;
import openfl.events.MouseEvent;
import com.tilbuci.display.PictureImage;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class InterfaceContraption extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var elem:Array<InterfaceElem> = [ ];

    private var _created:Bool = false;

    private var _graphics:Map<String, BaseImage> = [ ];

    private var _smap:SpritemapImage;

    private var _text:TextField;

    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    public function start():Bool {
        if (this.ok) {
            if (!this._created) {
                for (el in this.elem) {
                    var pi:PictureImage;
                    var opt:Array<String>;
                    var imnum:Int = 1;
                    switch (el.type) {
                        case 'background':
                            if (el.file != '') {
                                pi = new PictureImage();
                                pi.load(el.file);
                                pi.visible = true;
                                this._graphics['background'] = pi;
                            }
                        case 'spritemap':
                            opt = el.options.split(';');
                            if (opt.length == 2) {
                                this._smap = new SpritemapImage();
                                this._smap.frames = Std.parseInt(opt[0]);
                                this._smap.frtime = Std.parseInt(opt[1]);
                                this._smap.playOnLoad = false;
                                this._smap.load(el.file);
                                this._smap.visible = true;
                                this._smap.x = el.x;
                                this._smap.y = el.y;
                                if (el.action != '') {
                                    this._smap.extraInfo.push(el.action);
                                    this._smap.addEventListener(MouseEvent.CLICK, onClick);
                                    this._smap.addEventListener(MouseEvent.MOUSE_OVER, onOver);
                                    this._smap.addEventListener(MouseEvent.MOUSE_OUT, onOut);
                                }
                                this._graphics['spritemap'] = this._smap;
                            }
                        case 'text':
                            opt = el.options.split(';');
                            if (opt.length == 7) {
                                this._text = new TextField();
                                this._text.selectable = false;
                                this._text.mouseEnabled = false;
                                this._text.x = el.x;
                                this._text.y = el.y;
                                this._text.width = Std.parseInt(opt[0]);
                                var format:TextFormat = new TextFormat(opt[1], Std.parseInt(opt[2]), StringStatic.colorInt(opt[3]), (opt[4] == 'true'), (opt[5] == 'true'), null, null,  null, opt[6]);
                                this._text.defaultTextFormat = format;
                                this._text.height = Std.parseInt(opt[2]) + 12;
                            }
                        default:
                            if (el.file != '') {
                                pi = new PictureImage();
                                pi.x = el.x;
                                pi.y = el.y;
                                if (el.action != '') {
                                    pi.extraInfo.push(el.action);
                                    pi.addEventListener(MouseEvent.CLICK, onClick);
                                    pi.addEventListener(MouseEvent.MOUSE_OVER, onOver);
                                    pi.addEventListener(MouseEvent.MOUSE_OUT, onOut);
                                }
                                pi.load(el.file);
                                pi.visible = true;
                                this._graphics['im'+imnum] = pi;
                                imnum++;
                            }
                    }
                }
                if (this._graphics.exists('background')) this.addChild(this._graphics['background']);
                for (k in this._graphics.keys()) {
                    if (k != 'background') this.addChild(this._graphics[k]);
                }
                if (this._text != null) this.addChild(this._text);
            }
            this._created = true;
            return (true);
        } else {
            return (false);
        }
    }

    public function remove():Void {
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function clone():InterfaceContraption {
        return (new InterfaceContraption(this.toObject()));
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        while (this.elem.length > 0) this.elem.shift();
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'elem')) {
                var delem:Dynamic = Reflect.field(data, 'elem');
                for (el in Reflect.fields(delem)) {
                    var inel:InterfaceElem = Reflect.field(delem, el);
                    this.elem.push(inel);
                }
                this.ok = true;
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.id = null;
        while (this.elem.length > 0) this.elem.shift();
        this.elem = null;
        this._text = null;
        this._smap = null;
        for (k in this._graphics.keys()) {
            if (this._graphics[k].hasEventListener(MouseEvent.CLICK)) {
                this._graphics[k].removeEventListener(MouseEvent.CLICK, onClick);
                this._graphics[k].removeEventListener(MouseEvent.MOUSE_OVER, onOver);
                this._graphics[k].removeEventListener(MouseEvent.MOUSE_OUT, onOut);
            }
            this._graphics[k].kill();
            this._graphics.remove(k);
        }
        this._graphics = null;
    }

    public function toObject():Dynamic {
        return({
            id: this.id, 
            elem: this.elem, 
        });
    }

    public function setText(tx:String):Bool {
        if (this._text == null) {
            return (false);
        } else {
            this._text.text = tx;
            return (true);
        }
    }

    public function setMapFrame(fr:Int):Bool {
        if (this._smap == null) {
            return (false);
        } else {
            return (this._smap.setFrame(fr));
        }
    }

    public function pauseMap():Bool {
        if (this._smap == null) {
            return (false);
        } else {
            this._smap.pause();
            return (true);
        }
    }

    public function playMap():Bool {
        if (this._smap == null) {
            return (false);
        } else {
            this._smap.play();
            return (true);
        }
    }

    private function onClick(evt:MouseEvent):Void {
        this.onOut(evt);
        var img:BaseImage = cast evt.target;
        if (img.extraInfo.length > 0) {
            if (GlobalPlayer.mvActions.exists(GlobalPlayer.parser.parseString(img.extraInfo[0]))) {
                GlobalPlayer.parser.run(GlobalPlayer.mvActions[GlobalPlayer.parser.parseString(img.extraInfo[0])]);
            }
        }
    }

    private function onOver(evt:MouseEvent):Void {
        var img:BaseImage = cast evt.target;
        if (GlobalPlayer.mdata.highlight != '') {
            img.filters = [
                new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
            ];
        }
    }

    private function onOut(evt:MouseEvent):Void {
        var img:BaseImage = cast evt.target;
        img.filters = [ ];
    }
}

typedef InterfaceElem = {
    var type:String;
    var file:String;
    var action:String;
    var x:Int;
    var y:Int;
    var options:String;
}