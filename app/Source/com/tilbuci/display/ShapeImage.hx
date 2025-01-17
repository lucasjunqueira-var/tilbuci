/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.display;

/** HAXE **/
import haxe.Timer;

/** OPENFL **/
import openfl.display.Shape;
import openfl.geom.Rectangle;

/** TILBUCI **/
import com.tilbuci.statictools.StringStatic;

class ShapeImage extends BaseImage {

    /**
        the shape object
    **/
    private var _shape:Shape;

    /**
        load timer (do delay tye media loaded event a little)
    **/
    private var _loadTimer:Timer;

    public function new(ol:Dynamic) {
        super('shape', false, ol);
        this._shape = new Shape();
        this.addChild(this._shape);
    }

    /**
        Loads a shape definition.
        @param  txt the text to display
    **/
    public function load(txt:String):Void {
        var ok:Bool = true;
        this._shape.rotation = 0;
        this._shape.x = 0;
        this._shape.y = 0;
        this._shape.graphics.clear();
        var json:Dynamic = StringStatic.jsonParse(txt);
        if (json == false) {
            ok = false;
        } else {
            if (Reflect.hasField(json, 'type') && Reflect.hasField(json, 'color') && Reflect.hasField(json, 'alpha') && Reflect.hasField(json, 'border') && Reflect.hasField(json, 'bdcolor') && Reflect.hasField(json, 'bdalpha') && Reflect.hasField(json, 'rotation')) {
                this._shape.graphics.beginFill(0, 0);
                this._shape.graphics.drawRect(0, 0, 256, 256);
                this._shape.graphics.endFill();
                this._shape.graphics.beginFill(Std.parseInt(Reflect.field(json, 'color')), Reflect.field(json, 'alpha'));
                if (Reflect.field(json, 'border') > 0) {
                    this._shape.graphics.lineStyle(Reflect.field(json, 'border'), Std.parseInt(Reflect.field(json, 'bdcolor')), Reflect.field(json, 'bdalpha'));
                } else {
                    json.border = 0.2;
                    this._shape.graphics.lineStyle(0.2, Std.parseInt(Reflect.field(json, 'color')), Reflect.field(json, 'alpha'));
                }
                switch (Reflect.field(json, 'type')) {
                    case 'circle':
                        this._shape.graphics.drawCircle(128, 128, (128 - (2 * Reflect.field(json, 'border'))));
                        ok = true;
                    case 'square':
                        this._shape.graphics.drawRect((Reflect.field(json, 'border') / 2), (Reflect.field(json, 'border') / 2), (256 - (2 * Reflect.field(json, 'border'))), (256 - (2 * Reflect.field(json, 'border'))));
                        ok = true;
                    case 'triangle':
                        this._shape.graphics.moveTo(128, 0);
                        this._shape.graphics.lineTo((256 - (Reflect.field(json, 'border') / 2)), 220);
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), 220);
                        this._shape.graphics.lineTo(128, 0);
                        ok = true;
                    case 'isoscelestriangle':
                        this._shape.graphics.moveTo(128, (Reflect.field(json, 'border') / 2));
                        this._shape.graphics.lineTo((256 - (Reflect.field(json, 'border') / 2)), (256 - (Reflect.field(json, 'border') / 2)));
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), (256 - (Reflect.field(json, 'border') / 2)));
                        this._shape.graphics.lineTo(128, (Reflect.field(json, 'border') / 2));
                        ok = true;
                    case 'righttriangle':
                        this._shape.graphics.moveTo((Reflect.field(json, 'border') / 2), (Reflect.field(json, 'border') / 2));
                        this._shape.graphics.lineTo((256 - (Reflect.field(json, 'border') / 2)), (256 - (Reflect.field(json, 'border') / 2)));
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), (256 - (Reflect.field(json, 'border') / 2)));
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), (Reflect.field(json, 'border') / 2));
                        ok = true;
                    case 'pentagon':
                        this._shape.graphics.moveTo(128, (Reflect.field(json, 'border') / 2));
                        this._shape.graphics.lineTo((256 - (Reflect.field(json, 'border') / 2)), 98);
                        this._shape.graphics.lineTo(206, (256 - (Reflect.field(json, 'border') / 2)));
                        this._shape.graphics.lineTo(50, (256 - (Reflect.field(json, 'border') / 2)));
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), 98);
                        this._shape.graphics.lineTo(128, (Reflect.field(json, 'border') / 2));
                        ok = true;
                    case 'hexagon':
                        this._shape.graphics.moveTo(65, 0);
                        this._shape.graphics.lineTo(191, 0);
                        this._shape.graphics.lineTo((256 - (Reflect.field(json, 'border') / 2)), 108);
                        this._shape.graphics.lineTo(191, 216);
                        this._shape.graphics.lineTo(65, 216);
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), 108);
                        this._shape.graphics.lineTo(65, 0);
                        ok = true;
                    case 'heptagon':
                        this._shape.graphics.moveTo(128, 3);
                        this._shape.graphics.lineTo(228, 54);
                        this._shape.graphics.lineTo((256 - (Reflect.field(json, 'border') / 2)), 165);
                        this._shape.graphics.lineTo(183, 253);
                        this._shape.graphics.lineTo(73, 253);
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), 165);
                        this._shape.graphics.lineTo(28, 54);
                        this._shape.graphics.lineTo(128, 3);
                        ok = true;
                    case 'octagon':
                        this._shape.graphics.moveTo(75, (Reflect.field(json, 'border') / 2));
                        this._shape.graphics.lineTo(181, (Reflect.field(json, 'border') / 2));
                        this._shape.graphics.lineTo((256 - (Reflect.field(json, 'border') / 2)), 75);
                        this._shape.graphics.lineTo((256 - (Reflect.field(json, 'border') / 2)), 181);
                        this._shape.graphics.lineTo(181, (256 - (Reflect.field(json, 'border') / 2)));
                        this._shape.graphics.lineTo(75, (256 - (Reflect.field(json, 'border') / 2)));
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), 181);
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), 75);
                        this._shape.graphics.lineTo(75, (Reflect.field(json, 'border') / 2));
                        ok = true;
                    case 'eneagon':
                        this._shape.graphics.moveTo(128, 3);
                        this._shape.graphics.lineTo(210, 34);
                        this._shape.graphics.lineTo((256 - (Reflect.field(json, 'border') / 2)), 110);
                        this._shape.graphics.lineTo(239, 196);
                        this._shape.graphics.lineTo(173, 253);
                        this._shape.graphics.lineTo(83, 253);
                        this._shape.graphics.lineTo(17, 196);
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), 110);
                        this._shape.graphics.lineTo(46, 34);
                        this._shape.graphics.lineTo(128, 3);
                        ok = true;
                    case 'decagon':
                        this._shape.graphics.moveTo(87, 6);
                        this._shape.graphics.lineTo(169, 6);
                        this._shape.graphics.lineTo(231, 53);
                        this._shape.graphics.lineTo((256 - (Reflect.field(json, 'border') / 2)), 128);
                        this._shape.graphics.lineTo(231, 203);
                        this._shape.graphics.lineTo(169, 250);
                        this._shape.graphics.lineTo(87, 250);
                        this._shape.graphics.lineTo(25, 203);
                        this._shape.graphics.lineTo((Reflect.field(json, 'border') / 2), 128);
                        this._shape.graphics.lineTo(25, 53);
                        this._shape.graphics.lineTo(87, 6);
                        ok = true;
                    default:
                        ok = false;
                }
                this._shape.graphics.endFill();
                this._shape.rotation = Reflect.field(json, 'rotation');
                var bounds:Rectangle = this._shape.getBounds(this);
                this._shape.x = -bounds.x;
                this._shape.y = -bounds.y;
                this.oWidth = bounds.width;
                this.oHeight = bounds.height;
            } else {
                ok = false;
            }
        }
        if (this._loadTimer != null) {
            try { this._loadTimer.stop(); } catch (e) { }
            this._loadTimer = null;
        }
        this._loadTimer = new Timer(100);
        if (ok) {
            //this._shape.cacheAsBitmap = true;
            this._loadTimer.run = this.onOk;
        } else {
            this._loadTimer.run = this.onError;
        }
    }


    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
        if (this._loadTimer != null) {
            try { this._loadTimer.stop(); } catch (e) { }
            this._loadTimer = null;
        }
        this._shape.graphics.clear();
        this._shape = null;
    }

    /**
        Shape drawn.
    **/
    private function onOk():Void {
        if (this._loadTimer != null) {
            try { this._loadTimer.stop(); } catch (e) { }
            this._loadTimer = null;
        }
        this._onLoad(true);
    }

    /**
        Error on shape description.
    **/
    private function onError():Void {
        if (this._loadTimer != null) {
            try { this._loadTimer.stop(); } catch (e) { }
            this._loadTimer = null;
        }
        this._onLoad(false);
    }
}

typedef ShapeDesc = {
    var type:String;
    var color:String; 
    var alpha:Float;
    var border:Int;
    var bdcolor:String;
    var bdalpha:Float;
    var rotation:Int;
}