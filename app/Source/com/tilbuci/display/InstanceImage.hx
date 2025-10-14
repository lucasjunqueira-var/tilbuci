/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.display;

/** OPENFL **/
import openfl.filters.GlowFilter;
import openfl.Assets;
import openfl.display.Bitmap;
import com.tilbuci.data.Global;
import openfl.filters.DropShadowFilter;
import openfl.filters.BlurFilter;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.display.LineScaleMode;
import openfl.display.JointStyle;
import openfl.filters.BitmapFilter;
import openfl.display.BlendMode;

/** ACTUATE **/
import motion.Actuate;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.def.InstanceData;

class InstanceImage extends Sprite {

    /**
        instance name
    **/
    private var _name:String;

    /**
        image display
    **/
    private var _display:Sprite;

    /**
        image mask
    **/
    private var _mask:Shape;

    /**
        first all purpose image
    **/
    private var _im1:TilBuciImage;

    /**
        second all purpose image
    **/
    private var _im2:TilBuciImage;

    /**
        current image
    **/
    private var _imCurrent:TilBuciImage;

    /**
        hidden image
    **/
    private var _imOther:TilBuciImage;

    /**
        current image number
    **/
    private var _current:Int = 1;

    /**
        instance data
    **/
    private var _data:InstanceData;

    /**
        size transform multiplier
    **/
    private var _multSize:Point;

    /**
        image displauy description
    **/
    private var _desc:InstanceDesc;

    /**
        currently loaded path
    **/
    private var _path:String = '';

    /**
        last applied width
    **/
    private var _lastW:Float;

    /**
        last applied height
    **/
    private var _lastH:Float;

    /**
        loaded collection name
    **/
    private var _collection:String = '';

    /**
        loaded asset name
    **/
    private var _asset:String = '';

    /**
        keep this instance for the next keyframe?
    **/
    public var keep:Bool = true;

    /**
        first image content load?
    **/
    private var _firstLoad:Bool = true;

    /**
        starts playign media after loading?
    **/
    private var _playOnLoad:Bool = true;

    /**
        set properties
    **/
    private var _set:ImageSet;

    /**
        currenlly just changing the asset (not entire instance information)?
    **/
    private var _changeAsset:String = '';

    /**
        dragging image?
    **/
    private var _dragging:Bool = false;

    /**
        action to call on instance select
    **/
    private var _onSelect:Dynamic;

    /**
        instance selected?
    **/
    public var selected:Bool = false;

    /**
        currently playing?
    **/
    public var playing(get, null):Bool;
    private function get_playing():Bool { return (this._imCurrent.playing); }

    /**
        current type
    **/
    public var currentType(get, null):String;
    private function get_currentType():String { return (this._imCurrent.currentType); }

    /**
        current media
    **/
    public var currentMedia(get, null):String;
    private function get_currentMedia():String { return (this._imCurrent.currentMedia); }

    /**
        display width
    **/
    public var displayWidth(get, null):Float;
    private function get_displayWidth():Float {
        if (GlobalPlayer.orientation == 'horizontal') {
            return(this._data.horizontal.width);
        } else {
            return(this._data.vertical.width);
        }
    }

    /**
        display height
    **/
    public var displayHeight(get, null):Float;
    private function get_displayHeight():Float {
        if (GlobalPlayer.orientation == 'horizontal') {
            return(this._data.horizontal.height);
        } else {
            return(this._data.vertical.height);
        }
    }

    /**
        current transition
    **/
    public var transition(get, null):String;
    private function get_transition():String {
        if (GlobalPlayer.movie.collections.exists(this._collection)) {
            return (GlobalPlayer.movie.collections[this._collection].transition);
        } else {
            return ('');
        }
    }

    override public function get_width():Float {
        if (this._mask != null) {
            return (this._mask.width);
        } else {
            return (super.width);
        }
    }

    override public function get_height():Float {
        if (this._mask != null) {
            return (this._mask.height);
        } else {
            return (super.height);
        }
    }

    override public function set_width(to:Float):Float {
        if (this._mask != null) {
            this._mask.width = to;
            this._im1.width = to;
            this._im2.width = to;
        } else {
            //super.width = to;
        }
        return (to);
    }

    override public function set_height(to:Float):Float {
        if (this._mask != null) {
            this._mask.height = to;
            this._im1.height = to;
            this._im2.height = to;
        } else {
            //super.height = to;
        }
        return (to);
    }

    public function new(nm:String, onSel:Dynamic) {
        super();
        this._name = nm;
        this._onSelect = onSel;

        // set display
        this._display = new Sprite();
        this._mask = new Shape();
        this._mask.graphics.beginFill(0);
        this._mask.graphics.drawRect(0, 0, 64, 64);
        this._mask.graphics.endFill();
        this.addChild(this._display);
        this.addChild(this._mask);
        this._display.mask = this._mask;

        // add images
        this._im1 = new TilBuciImage(this.onLoad, nm, this.onTimedAc);
        this._im2 = new TilBuciImage(this.onLoad, nm, this.onTimedAc);
        this._imCurrent = this._im1;
        this._imOther = this._im2;
        this._current = 1;
        this._display.addChild(this._im1);
        this._display.addChild(this._im2);

        // place
        this._multSize = new Point(1, 1);
        if (GlobalPlayer.mdata.origin != 'none') {
            this.alpha = 0;
        }
        this.rotation = 0;
        if (GlobalPlayer.movie.data.screen.type == 'landscape') {
            this.x = GlobalPlayer.mdata.screen.big / 2;
            this.y = GlobalPlayer.mdata.screen.small / 2;
        } else if (GlobalPlayer.movie.data.screen.type == 'portrait') { 
            this.x = GlobalPlayer.mdata.screen.small / 2;
            this.y = GlobalPlayer.mdata.screen.big / 2;
        } else {
            if (GlobalPlayer.orientation == 'horizontal') {
                this.x = GlobalPlayer.mdata.screen.big / 2;
                this.y = GlobalPlayer.mdata.screen.small / 2;
            } else {
                this.x = GlobalPlayer.mdata.screen.small / 2;
                this.y = GlobalPlayer.mdata.screen.big / 2;
            }
        }
        this._lastH = this._lastW = this.width = this.height = 10;

        // set properties
        this._set = new ImageSet();

        // interaction
        this.addEventListener(MouseEvent.CLICK, onClick);
        this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    }

    public function changeId(oldid:String, newid:String):Bool {
        if (this._name == oldid) {
            this._name = newid;
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Loads information about the instance state.
        @param  inf instance data information
        @return was the instance loaded?
    **/
    public function load(inf:InstanceData):Bool {
        if (inf.ok) {
            if (GlobalPlayer.movie.collections.exists(inf.collection)) {
                if (GlobalPlayer.movie.collections[inf.collection].ok && GlobalPlayer.movie.collections[inf.collection].assets.exists(inf.asset)) {
                    this._data = inf;
                    //var pth:String = inf.collection + '/' + inf.asset + '@' + GlobalPlayer.multiply;
                    var pth:String = GlobalPlayer.movie.collections[inf.collection].assets[inf.asset].file['@'+GlobalPlayer.multiply];
                    if (pth == this._path) {
                        return (true);
                    } else {
                        this._path = pth;
                        this._playOnLoad = inf.playOnLoad;
                        if (this._imOther.load(inf)) {
                            this._collection = inf.collection;
                            this._asset = inf.asset;
                            this._imCurrent.stopTimer();
                            return (true);
                        } else {
                            this.visible = false;
                            return (false);
                        }
                    }
                } else {
                    this.visible = false;
                    return (false);
                }
            } else {
                this.visible = false;
                return (false);
            }
        } else {
            this.visible = false;
            return (false);
        }
    }

    /**
        Gets this instance current float properties.
        @param  name    the property name
        @return the property value or 0 if not supported
    **/
    public function getProp(name:String):Float {
        switch (name) {
            case 'x': return (this._desc.x);
            case 'y': return (this._desc.y);
            case 'width': return (this._desc.width);
            case 'height': return (this._desc.height);
            case 'alpha': return (this._desc.alpha);
            case 'order': return (this._desc.order);
            case 'rotation': return (this._desc.rotation);
            case 'colorAlpha': return (this._desc.colorAlpha);
            case 'volume': return (this._desc.volume);
            case 'pan': return (this._desc.pan);
            case 'fontSize': return (this._imCurrent.getProp('fontSize'));
            case 'fontLeading': return (this._imCurrent.getProp('fontLeading'));
            case 'fontSpacing': return (this._imCurrent.getProp('fontSpacing'));
            default: return (0);
        }
    }

    /**
        Gets this instance current bool properties.
        @param  name    the property name
        @return the property value or false if not supported
    **/
    public function getBoolProp(name:String):Bool {
        switch (name) {
            case 'fontBold': return (this._imCurrent.getBoolProp('fontBold'));
            case 'fontItalic': return (this._imCurrent.getBoolProp('fontItalic'));
            case 'visible': return (this.visible);
            default: return (false);
        }
    }

    /**
        Gets this instance current string properties.
        @param  name    the property name
        @return the property value or empty string if not supported
    **/
    public function getStringProp(name:String):String {
        switch (name) {
            case 'color': return (this._desc.color);
            case 'text': return (this._imCurrent.getStringProp('text'));
            case 'font': return (this._imCurrent.getStringProp('font'));
            case 'fontColor': return (this._imCurrent.getStringProp('fontColor'));
            default: return ('');
        }
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.removeEventListener(MouseEvent.CLICK, onClick);
        this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        this.removeChildren();
        this._display.mask = null;
        this._display.removeChildren();
        this._display = null;
        this._mask.graphics.clear();
        this._mask = null;
        this._imCurrent = null;
        this._imOther = null;
        this._im1.kill();
        this._im1 = null;
        this._im2.kill();
        this._im2 = null;
        this._data = null;
        this._multSize = null;
        this._desc = null;
        this._path = null;
        this._set.kill();
        this._set = null;
        this._collection = null;
        this._asset = null;
        this._changeAsset = null;
        this._onSelect = null;
    }

    /**
        Interpolates object properties to the current keyframe positions.
    **/
    public function place():Void {
        Actuate.stop(this, null, false, false);
        if (this.keep && (this._data != null)) {
            // setting received values
            this._set.load(this._data.horizontal, this._data.vertical);
            if (GlobalPlayer.movie.data.screen.type == 'landscape') {
                this._desc = this._set.horizontal;
            } else if (GlobalPlayer.movie.data.screen.type == 'portrait') { 
                this._desc = this._set.vertical;
            } else {
                if (GlobalPlayer.orientation == 'horizontal') this._desc = this._set.horizontal;
                    else this._desc = this._set.vertical;
            }
            this._lastW = this._multSize.x * this._desc.width;
            this._lastH = this._multSize.y * this._desc.height;
            // set text properties
            this._imCurrent.formatText(
                this._desc.textFont, 
                this._desc.textSize, 
                this._desc.textColor, 
                this._desc.textBold, 
                this._desc.textItalic, 
                this._desc.textLeading, 
                this._desc.textSpacing, 
                this._desc.textBackground, 
                this._desc.textAlign
            );
            this._imCurrent.setTextSize(this._desc.width, this._desc.height);
            // simple property transformations
            Actuate.tween(this, GlobalPlayer.mdata.time, {
                x: this._desc.x, 
                y: this._desc.y, 
                width: this._multSize.x * this._desc.width, 
                height: this._multSize.y * this._desc.height,
                alpha: this._desc.alpha, 
                rotation: this._desc.rotation
            }).smartRotation().autoVisible(false);

            // sound and color transformations
            Actuate.transform(this, GlobalPlayer.mdata.time).color(Std.parseInt(this._desc.color), this._desc.colorAlpha);
            this._imOther.stopSound();
            this._imCurrent.stopSound();
            this._imCurrent.iterateSound(this._desc.volume, this._desc.pan);
            // checking current filters
            var ft:Array<BitmapFilter> = new Array<BitmapFilter>();
            if (this._desc.dropshadow.length == 8) {
                ft.push(new DropShadowFilter(
                    Std.parseInt(this._desc.dropshadow[0]), 
                    Std.parseFloat(this._desc.dropshadow[1]), 
                    Std.parseInt(this._desc.dropshadow[2]), 
                    Std.parseFloat(this._desc.dropshadow[3]), 
                    Std.parseFloat(this._desc.dropshadow[4]), 
                    Std.parseFloat(this._desc.dropshadow[5]), 
                    Std.parseFloat(this._desc.dropshadow[6]), 
                    1, 
                    this._desc.dropshadow[7] == '1'
                ));
            }
            if (this._desc.blur.length == 2) {
                ft.push(new BlurFilter(
                    Std.parseFloat(this._desc.blur[0]), 
                    Std.parseFloat(this._desc.blur[1])
                ));
            }
            if (this._desc.glow.length == 5) {
                ft.push(new GlowFilter(
                    Std.parseInt(this._desc.glow[0]), // color
                    Std.parseFloat(this._desc.glow[1]), // alpha
                    Std.parseInt(this._desc.glow[2]), // blurx
                    Std.parseInt(this._desc.glow[2]), // blury
                    Std.parseInt(this._desc.glow[3]), // strength
                    1, // quality
                    this._desc.glow[4] == '1' // inner
                ));
            }
            this.filters = ft;
            // blend mode
            switch (this._desc.blend) {
                case 'add': this.blendMode = BlendMode.ADD;
                case 'difference': this.blendMode = BlendMode.DIFFERENCE;
                case 'invert': this.blendMode = BlendMode.INVERT;
                case 'multiply': this.blendMode = BlendMode.MULTIPLY;
                case 'screen': this.blendMode = BlendMode.SCREEN;
                case 'subtract': this.blendMode = BlendMode.SUBTRACT;
                default: this.blendMode = BlendMode.NORMAL;
            }
            // editor?
            if (GlobalPlayer.mode == Player.MODE_EDITOR) {
                Actuate.stop(this, null, true);
            }
            // image visibility
            this.visible = this._desc.visible;
        } else {
            // remove instance
            var endX:Float = this.x;
            var endY:Float = this.y;
            var endW:Float = this.width;
            var endH:Float = this.height;
            var endAlpha:Float = this.alpha;
            var screenW:Int;
            var screenH:Int;
            if (GlobalPlayer.movie.data.screen.type == 'landscape') {
                screenW = GlobalPlayer.mdata.screen.big;
                screenH = GlobalPlayer.mdata.screen.small;
            } else if (GlobalPlayer.movie.data.screen.type == 'portrait') { 
                screenH = GlobalPlayer.mdata.screen.big;
                screenW = GlobalPlayer.mdata.screen.small;
            } else {
                if (GlobalPlayer.orientation == 'horizontal') {
                    screenW = GlobalPlayer.mdata.screen.big;
                    screenH = GlobalPlayer.mdata.screen.small;
                } else {
                    screenH = GlobalPlayer.mdata.screen.big;
                    screenW = GlobalPlayer.mdata.screen.small;
                }
            }
            switch (GlobalPlayer.mdata.origin) {
                case 'none':
                    this.alpha = 0;
                    endAlpha = 0;
                case 'alpha':
                    endAlpha = 0;
                case 'top':
                    endY = screenH + 10;
                case 'topkeep':
                    endY = screenH + 10 + this.y;
                case 'bottom':
                    endY = -10 - this.height;
                case 'bottomkeep':
                    endY = -10 - screenH + this.y;
                case 'left':
                    endX = screenW + 10;
                case 'leftkeep':
                    endX = screenW + 10 + this.x;
                case 'right':
                    endX = -10 -this.width;
                case 'rightkeep':
                    endX = -10 -screenW + this.x;
                default:
                    endW = 1;
                    endH = 1;
                    endX = screenW / 2;
                    endY = screenH / 2;
                    endAlpha = 0;
            }
            Actuate.tween(this, GlobalPlayer.mdata.time, {
                x: endX, 
                y: endY, 
                width: endW, 
                height: endH,
                alpha: endAlpha
            }).autoVisible(false);
            this.pause();
        }

        if (this._desc != null) this.parent.swapChildrenAt(this.parent.getChildIndex(this), this._desc.order);
    }

    /**
        Sets the paragraph type textes size.
        @param  w   new width
        @param  h   new height
    **/
    public function setTextSize(w:Float, h:Float):Void {
        this._imCurrent.setTextSize(w, h);
        this._imOther.setTextSize(w, h);
        this._mask.width = this._im1.width = this._im2.width;
        this._mask.height = this._im1.height = this._im2.height;
    }

    /**
        Sets the text format.
        @param  font    the font name
        @param  size    font size (pt)
        @param  color   text color (hex string)
        @param  bold    text bold?
        @param  italic  text italic?
        @param  leading space among lines
        @param  spacing space among chars
        @param  bg  text backgound color (empty string for none)
        @param  align   text align
    **/
    public function formatText(font:String, size:Int, color:String, bold:Bool, italic:Bool, leading:Int, spacing:Float, bg:String, align:String):Void {
        this._imCurrent.formatText(font, size, color, bold, italic, leading, spacing, bg, align);
        this._imOther.formatText(font, size, color, bold, italic, leading, spacing, bg, align);
    }

    /**
        Gets the current image order ID.
        @return the order
    **/
    public function getOrder():Int {
        var ord:Int = 0;
        if (Global.displayType == 'portrait') {
            ord = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical.order;
        } else {
            ord = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal.order;
        }
        return (ord);
    }

    /**
        Sets this image order id on display.
        @param  to  new order value
        @param  updateDisplay   also update the dislay?
    **/
    public function setOrder(to:Int, updDisplay:Bool = true):Void {
        if (Global.displayType == 'portrait') {
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical.order = to;
        } else {
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal.order = to;
        }
        if (updDisplay) this.parent.swapChildrenAt(this.parent.getChildIndex(this), to);
    }

    /**
        Loads the next asset on collection.
    **/
    public function next():Void {
        var next:Int = this._imCurrent.assetOrder + 1;
        if (next >= GlobalPlayer.movie.collections[this._collection].assetOrder.length) next = 0;
        this._imCurrent.stopTimer();
        this._changeAsset = 'next';
        this._imOther.loadAsset(GlobalPlayer.movie.collections[this._collection].assets[GlobalPlayer.movie.collections[this._collection].assetOrder[next]]);
    }

    /**
        Loads the previous asset on collection.
    **/
    public function previous():Void {
        var prev:Int = this._imCurrent.assetOrder - 1;
        if (prev < 0) prev = GlobalPlayer.movie.collections[this._collection].assetOrder.length - 1;
        this._imCurrent.stopTimer();
        this._changeAsset = 'previous';
        this._imOther.loadAsset(GlobalPlayer.movie.collections[this._collection].assets[GlobalPlayer.movie.collections[this._collection].assetOrder[prev]]);
    }

    /**
        Loads an asset from the current colletcion.
        @param  name    the asset name
        @return was the asset found?
    **/
    public function loadAsset(name:String):Bool {
        if (GlobalPlayer.movie.collections[this._collection].assets.exists(name)) {
            this._imCurrent.stopTimer();
            this._changeAsset = 'set';
            this._imOther.loadAsset(GlobalPlayer.movie.collections[this._collection].assets[name]);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Loads an asset from the a colletcion.
        @param  col the collection name
        @param  ast the asset name
        @return was the asset found?
    **/
    public function loadCollectionAsset(col:String, ast:String):Bool {
        if (GlobalPlayer.movie.collections.exists(col)) {
            if (GlobalPlayer.movie.collections[col].assets.exists(ast)) {
                this._imCurrent.stopTimer();
                this._changeAsset = 'set';
                this._imOther.loadAsset(GlobalPlayer.movie.collections[col].assets[ast]);
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    /**
        Plays/pauses the image.
    **/
    public function playPause():Void {
        this._imCurrent.playPause();
        this._playOnLoad = this._imCurrent.playing;
    }

    /**
        Plays the image.
    **/
    public function play():Void {
        this._playOnLoad = true;
        this._imCurrent.play();
    }

    /**
        Pauses the image.
    **/
    public function pause():Void {
        this._playOnLoad = false;
        this._imCurrent.pause();
    }

    /**
        Stops the image.
    **/
    public function stop():Void {
        this._playOnLoad = false;
        this._imCurrent.stop();
        this._imOther.stop();
    }

    /**
        Gets the current playback time.
        @return the current playback time in seconds
    **/
    public function getTime():Int {
        return (this._imCurrent.getTime());
    }

    /**
        Sets the media playback position.
        @param  time    the time to jump to (seconds)
    **/
    public function seek(time:Int):Void {
        this._imCurrent.seek(time);
    }

    public function updateFrames(fr:Int, tm:Int):Void {
        this._imCurrent.updateFrames(fr, tm);
    }

    /**
        Fixes a property value.
        @param  prop    the property name
        @param  h   value for horizontal display
        @param  v   value for vertical display
    **/
    public function fixProp(prop:String, h:Dynamic, v:Dynamic):Void {
        this._set.fixProp(prop, h, v);
    }

    /**
        Scrolls a text.
        @param  val    scroll direction
    **/
    public function textScroll(val:Int):Void {
        this._imCurrent.textScroll(val);
    }

    /**
        Sets a paragraph text.
        @param  txt the new text
    **/
    public function setText(txt:String):Void {
        this._imCurrent.setText(txt);
        this._imOther.setText(txt);
    }

    /**
        Releases a fixed property value.
        @param  prop    the property name
    **/
    public function releaseProp(prop:String):Void {
        this._set.releaseProp(prop);
    }

    /**
        Releases all set properties.
    **/
    public function releaseAll():Void {
        this._set.releaseAll();
    }

    /**
        Gets the current media original width.
        @return the original width
    **/
    public function oWidth():Float {
        if (this._imCurrent != null) {
            return (this._imCurrent.oWidth());
        } else {
            return (0);
        }
    }

    /**
        Gets the current media original height.
        @return the original height
    **/
    public function oHeight():Float {
        if (this._imCurrent != null) {
            return (this._imCurrent.oHeight());
        } else {
            return (0);
        }
    }

    /**
        A new content was just loaded.
        @param  ok  content really loaded?
    **/
    private function onLoad(ok:Bool):Void {
        if (ok) {
            // setting image size
            this._im1.width = this._im2.width = (GlobalPlayer.mdata.screen.big / 2) * GlobalPlayer.multiply;
            this._im1.height = this._im2.height = (GlobalPlayer.mdata.screen.big / 2) * GlobalPlayer.multiply;

            // swap content
            this._imCurrent.stop();
            if (this._current == 1) {
                this._current = 2;
                this._imCurrent = this._im2;
                this._imOther = this._im1;
            } else {
                this._current = 1;
                this._imCurrent = this._im1;
                this._imOther = this._im2;
            }
            // content transition
            Actuate.stop(this._imCurrent);
            Actuate.stop(this._imOther);
            var trans:String = GlobalPlayer.movie.collections[this._data.collection].transition;
            if (this._changeAsset == 'previous') {
                switch (trans) {
                    case 'right': trans = 'left';
                    case 'left': trans = 'right';
                    case 'top': trans = 'bottom';
                    case 'bottom': trans = 'top';
                }
            }
            switch (trans) {
                case 'alpha':
                    this._multSize.x = this._multSize.y = 1;
                    this._imCurrent.x = this._imOther.x = this._imCurrent.y = this._imOther.y = 0;
                    this._imCurrent.alpha = 0;
                    this._imOther.alpha = 1;
                    Actuate.tween(this._imCurrent, GlobalPlayer.movie.collections[this._data.collection].time, { alpha: 1 });
                    Actuate.tween(this._imOther, GlobalPlayer.movie.collections[this._data.collection].time, { alpha: 0 });
                case 'right':
                    this._multSize.x = 1;//2;
                    this._multSize.y = 1;
                    this._imCurrent.x = this._imCurrent.width;
                    this._imOther.x = 0;
                    this._imCurrent.y = this._imOther.y = 0;
                    this._imCurrent.alpha = 1;
                    this._imOther.alpha = 1;
                    Actuate.tween(this._imCurrent, GlobalPlayer.movie.collections[this._data.collection].time, { x: 0 });
                    Actuate.tween(this._imOther, GlobalPlayer.movie.collections[this._data.collection].time, { x: -this._imCurrent.width });
                case 'left':
                    this._multSize.x = 1;//2;
                    this._multSize.y = 1;
                    this._imCurrent.x = -this._imCurrent.width;
                    this._imOther.x = 0;
                    this._imCurrent.y = this._imOther.y = 0;
                    this._imCurrent.alpha = 1;
                    this._imOther.alpha = 1;
                    Actuate.tween(this._imCurrent, GlobalPlayer.movie.collections[this._data.collection].time, { x: 0 });
                    Actuate.tween(this._imOther, GlobalPlayer.movie.collections[this._data.collection].time, { x: this._imCurrent.width });
                case 'top':
                    this._multSize.x = 1;
                    this._multSize.y = 1;//2;
                    this._imCurrent.y = -this._imCurrent.height;
                    this._imOther.y = 0;
                    this._imCurrent.x = this._imOther.x = 0;
                    this._imCurrent.alpha = 1;
                    this._imOther.alpha = 1;
                    Actuate.tween(this._imCurrent, GlobalPlayer.movie.collections[this._data.collection].time, { y: 0 });
                    Actuate.tween(this._imOther, GlobalPlayer.movie.collections[this._data.collection].time, { y: this._imCurrent.height });
                case 'bottom':
                    this._multSize.x = 1;
                    this._multSize.y = 1;//2;
                    this._imCurrent.y = this._imCurrent.height;
                    this._imOther.y = 0;
                    this._imCurrent.x = this._imOther.x = 0;
                    this._imCurrent.alpha = 1;
                    this._imOther.alpha = 1;
                    Actuate.tween(this._imCurrent, GlobalPlayer.movie.collections[this._data.collection].time, { y: 0 });
                    Actuate.tween(this._imOther, GlobalPlayer.movie.collections[this._data.collection].time, { y: -this._imCurrent.height });
                default:
                    // no transition
                    this._multSize.x = this._multSize.y = 1;
                    this._imCurrent.x = this._imOther.x = this._imCurrent.y = this._imOther.y = 0;
                    this._imCurrent.alpha = 1;
                    this._imOther.alpha = 0;
            }
            //this._mask.width = this._im1.width = this._im2.width;// = this._imCurrent.oWidth();
            //this._mask.height = this._im1.height = this._im2.height;// = this._imCurrent.oHeight();
            this._mask.x = this._display.x = this._mask.y = this._display.y = 0;
            this._display.setChildIndex(this._imCurrent, 1);
            this._display.setChildIndex(this._imOther, 0);

            // first load? place object
            if (this._firstLoad) {
                var screenW:Int;
                var screenH:Float;
                if (GlobalPlayer.movie.data.screen.type == 'landscape') {
                    this._desc = this._data.horizontal;
                    screenW = GlobalPlayer.mdata.screen.big;
                    screenH = GlobalPlayer.mdata.screen.small;
                } else if (GlobalPlayer.movie.data.screen.type == 'portrait') {
                    this._desc = this._data.vertical;
                    screenW = GlobalPlayer.mdata.screen.small;
                    screenH = GlobalPlayer.mdata.screen.big;
                } else {
                    if (GlobalPlayer.orientation == 'horizontal') {
                        this._desc = this._data.horizontal;
                        screenW = GlobalPlayer.mdata.screen.big;
                        screenH = GlobalPlayer.mdata.screen.small;
                    } else {
                        this._desc = this._data.vertical;
                        screenW = GlobalPlayer.mdata.screen.small;
                        screenH = GlobalPlayer.mdata.screen.big;
                    }
                }    
                switch (GlobalPlayer.mdata.origin) {
                    case 'none':
                        this.x = this._desc.x;
                        this.y = this._desc.y;
                        this.width = this._desc.width * this._multSize.x;
                        this.height = this._desc.height * this._multSize.y;
                        this.alpha = this._desc.alpha;
                        this.rotation = this._desc.rotation;
                    case 'alpha':
                        this.x = this._desc.x;
                        this.y = this._desc.y;
                        this.width = this._desc.width * this._multSize.x;
                        this.height = this._desc.height * this._multSize.y;
                        this.alpha = 0;
                        this.rotation = this._desc.rotation;
                    case 'top':
                        this.width = this._desc.width * this._multSize.x;
                        this.height = this._desc.height * this._multSize.y;
                        this.alpha = this._desc.alpha;
                        this.rotation = this._desc.rotation;
                        this.x = this._desc.x;
                        this.y = -10 - this.height;
                    case 'topkeep':
                        this.width = this._desc.width * this._multSize.x;
                        this.height = this._desc.height * this._multSize.y;
                        this.alpha = this._desc.alpha;
                        this.rotation = this._desc.rotation;
                        this.x = this._desc.x;
                        this.y = -10 - screenH + this._desc.y;
                    case 'bottom':
                        this.width = this._desc.width * this._multSize.x;
                        this.height = this._desc.height * this._multSize.y;
                        this.alpha = this._desc.alpha;
                        this.rotation = this._desc.rotation;
                        this.x = this._desc.x;
                        this.y = screenH + 10;
                    case 'bottomkeep':
                        this.width = this._desc.width * this._multSize.x;
                        this.height = this._desc.height * this._multSize.y;
                        this.alpha = this._desc.alpha;
                        this.rotation = this._desc.rotation;
                        this.x = this._desc.x;
                        this.y = screenH + 10 + this._desc.y;
                    case 'left':
                        this.width = this._desc.width * this._multSize.x;
                        this.height = this._desc.height * this._multSize.y;
                        this.alpha = this._desc.alpha;
                        this.rotation = this._desc.rotation;
                        this.y = this._desc.y;
                        this.x = -10 - this.width;
                    case 'leftkeep':
                        this.width = this._desc.width * this._multSize.x;
                        this.height = this._desc.height * this._multSize.y;
                        this.alpha = this._desc.alpha;
                        this.rotation = this._desc.rotation;
                        this.y = this._desc.y;
                        this.x = -10 - screenW + this._desc.x;
                    case 'right':
                        this.width = this._desc.width * this._multSize.x;
                        this.height = this._desc.height * this._multSize.y;
                        this.alpha = this._desc.alpha;
                        this.rotation = this._desc.rotation;
                        this.y = this._desc.y;
                        this.x = screenW + 10;
                    case 'rightkeep':
                        this.width = this._desc.width * this._multSize.x;
                        this.height = this._desc.height * this._multSize.y;
                        this.alpha = this._desc.alpha;
                        this.rotation = this._desc.rotation;
                        this.y = this._desc.y;
                        this.x = screenW + 10 + this._desc.x;
                }
            }
            this._firstLoad = false;

            // stops other image timer
            this._imOther.stopTimer();
            this._imOther.stop();

            // play on load?
            if (this._playOnLoad) {
                this._imCurrent.startTimer();
            } else {
                this._imCurrent.stopTimer();
            }

            // place content
            if (this._changeAsset == '') this.place();
            this._changeAsset = '';
        }
    }

    private function onTimedAc(time:Int):Void {
        if (GlobalPlayer.canTrigger) {
            if (this._data.timedAc.exists(time+'s')) {
                GlobalPlayer.parser.run(this._data.timedAc[time+'s']);
            }
        }
    }

    /**
        Instance click action.
    **/
    public function onClick(evt:MouseEvent = null):Void {
        if (GlobalPlayer.canTrigger) {
            if (GlobalPlayer.mode != Player.MODE_EDITOR) {
                if (this._data.action != '') {
                    GlobalPlayer.parser.run(this._data.action);
                }
            } else {
                this._onSelect(this._name);
                // callback
                if (GlobalPlayer.callback != null) {
                    GlobalPlayer.callback('selectimage', ['nm' => this._name]);
                }
            }
        }
    }

    /**
        Mouse over instance.
    **/
    public function onMouseOver(evt:MouseEvent):Void {
        if (GlobalPlayer.cursorVisible) if (GlobalPlayer.cursorVisible) if ((GlobalPlayer.mode != Player.MODE_EDITOR) && (this._data.action != '') && (GlobalPlayer.mdata.highlightInt != null) && !GlobalPlayer.isMobile()) {
            this._imCurrent.filters = this._imOther.filters = [
                new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
            ];
        }
        if (GlobalPlayer.canTrigger) {
            if (GlobalPlayer.mode != Player.MODE_EDITOR) {
                if (this._data.actionover != '') {
                    GlobalPlayer.parser.run(this._data.actionover);
                }
            }
        }
    }

    /**
        Mouse out instance.
    **/
    public function onMouseOut(evt:MouseEvent = null):Void {
        this._imCurrent.filters = this._imOther.filters = [ ];
    }

    /**
        Starts image drag.
    **/
    public function dragImageStart():Void {
        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
            this._dragging = true;
            this.startDrag();
        }
    }

    /**
        Stops dragging.
    **/
    public function finishDrag():Void {
        if (this._dragging) {
            this._dragging = false;
            this.stopDrag();
        }
    }

    /**
        Updates instance information on scene.
    **/
    public function updateInstance():Void {
        if (Global.displayType == 'portrait') {
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical.x = this.x;
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical.y = this.y;
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical.width = this.displayWidth;
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical.height = this.displayHeight;
        } else {
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal.x = this.x;
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal.y = this.y;
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal.width = this.displayWidth;
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal.height = this.displayHeight;
        }
        Global.history.addState(Global.ln.get('rightbar-history-move'));
        Global.history.updateProperties();
    }

    public function setDescWidth(to:Float):Void {
        if (Global.displayType == 'portrait') {
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical.width = to;
        } else {
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal.width = to;
        }
    }

    public function setDescHeight(to:Float):Void {
        if (Global.displayType == 'portrait') {
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical.height = to;
        } else {
            GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal.height = to;
        }
    }

    /**
        Gets current display image property.
        @param  name    the property name
        @return the value or 0 if it is not found
    **/
    public function getCurrentNum(name:String):Float {
        var desc:InstanceDesc;
        if (Global.displayType == 'portrait') {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical;
        } else {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal;
        }
        switch (name) {
            case 'x': return (desc.x); 
            case 'y': return (desc.y);
            case 'width': {
                return (desc.width);
            }
            case 'height': return (desc.height);
            case 'order': return (desc.order);
            case 'rotation': return (desc.rotation);
            case 'alpha': return (desc.alpha);
            case 'coloralpha': return (desc.colorAlpha);
            case 'volume': return (desc.volume);
            case 'textsize': return (desc.textSize);
            case 'textleading': return (desc.textLeading);
            case 'textspacing': return (desc.textSpacing);
            default: return (0);
        }
    }

    /**
        Gets current display string property.
        @param  name    the property name
        @return the value or '' if it is not found
    **/
    public function getCurrentStr(name:String):String {
        var desc:InstanceDesc;
        if (Global.displayType == 'portrait') {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical;
        } else {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal;
        }
        switch (name) {
            case 'color': return (desc.color);
            case 'blend': return (desc.blend);
            case 'textfont': return (desc.textFont);
            case 'textcolor': return (desc.textColor);
            case 'textalign': return (desc.textAlign);
            case 'textbackground': return (desc.textBackground);
            case 'instance': return (this._name);
            case 'collection': return (this._collection);
            case 'asset': return (this._asset);
            default: return ('');
        }
    }

    /**
        Gets current display boolean property.
        @param  name    the property name
        @return the value or '' if it is not found
    **/
    public function getCurrentBool(name:String):Bool {
        var desc:InstanceDesc;
        if (Global.displayType == 'portrait') {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical;
        } else {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal;
        }
        switch (name) {
            case 'textbold': return (desc.textBold);
            case 'textitalic': return (desc.textItalic);
            case 'blur': return (desc.blur.length == 2);
            case 'dropshadow': return (desc.dropshadow.length == 8);
            case 'glow': return (desc.glow.length == 5);
            case 'visible': return (desc.visible);
            default: return (false);
        }
    }

    /**
        Gets current display array property.
        @param  name    the property name
        @return the value or '' if it is not found
    **/
    public function getCurrentArr(name:String):Array<String> {
        var desc:InstanceDesc;
        if (Global.displayType == 'portrait') {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].vertical;
        } else {
            desc = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].horizontal;
        }
        switch (name) {
            case 'blur':
                if (desc.blur.length == 2) {
                    return (desc.blur);
                } else {
                    return ([ '4', '4' ]);
                }
            case 'dropshadow':
                if (desc.dropshadow.length == 8) {
                    return (desc.dropshadow);
                } else {
                    return ([ '1', '45', '0x000000', '1', '4', '4', '1', '0' ]);
                }
            case 'glow':
                if (desc.glow.length == 5) {
                    return (desc.glow);
                } else {
                    return ([ '0xFFFFFF', '1', '6', '1', '0' ]);
                }
            default: return ([ ]);
        }
    }

    /**
        Gets this image instance name.
    **/
    public function getInstName():String {
        return (this._name);
    }

    /**
        Sets sound properties.
        @param  volume  volume level
        @param  pan pan
    **/
    public function setSound(volume:Float, pan:Float = 0):Void {
        this._imCurrent.iterateSound(volume, pan);
    }

    /**
        Play this instance media automatically?
    **/
    public function playOnLoad():Bool {
        if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].exists(this._name)) {
            return(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._name].playOnLoad);
        } else {
            return (false);
        }
    }

}

class ImageSet {

    /**
        properties currenly fixed
    **/
    private var _fixed:Array<String> = [ ];

    /**
        horizontal instance description
    **/
    public var horizontal:InstanceDesc;

    /**
        vertical instance description
    **/
    public var vertical:InstanceDesc;

    /**
        Constructor.
    **/
    public function new() {
        this.horizontal = new InstanceDesc([ ]);
        this.vertical = new InstanceDesc([ ]);
        this.horizontal.ok = this.vertical.ok = true;
    }

    /**
        Loads an intance information.
        @param  hr  horizontal display information
        @param  vt  vertical display information
    **/
    public function load(hr:InstanceDesc, vt:InstanceDesc):Void {
        this.setProp('order', hr.order, vt.order);
        this.setProp('x', hr.x, vt.x);
        this.setProp('y', hr.y, vt.y);
        this.setProp('alpha', hr.alpha, vt.alpha);
        this.setProp('width', hr.width, vt.width);
        this.setProp('height', hr.height, vt.height);
        this.setProp('rotation', hr.rotation, vt.rotation);
        this.setProp('visible', hr.visible, vt.visible);
        this.setProp('color', hr.color, vt.color);
        this.setProp('blend', hr.blend, vt.blend);
        this.setProp('colorAlpha', hr.colorAlpha, vt.colorAlpha);
        this.setProp('volume', hr.volume, vt.volume);
        this.setProp('pan', hr.pan, vt.pan);
        this.setProp('blur', hr.blur, vt.blur);
        this.setProp('dropshadow', hr.dropshadow, vt.dropshadow);
        this.setProp('glow', hr.glow, vt.glow);
        this.setProp('textFont', hr.textFont, vt.textFont);
        this.setProp('textSize', hr.textSize, vt.textSize);
        this.setProp('textColor', hr.textColor, vt.textColor);
        this.setProp('textBold', hr.textBold, vt.textBold);
        this.setProp('textItalic', hr.textItalic, vt.textItalic);
        this.setProp('textLeading', hr.textLeading, vt.textLeading);
        this.setProp('textSpacing', hr.textSpacing, vt.textSpacing);
        this.setProp('textBackground', hr.textBackground, vt.textBackground);
        this.setProp('textAlign', hr.textAlign, vt.textAlign);
    }

    /**
        Sets the value of a property.
        @param  prop    the property name
        @param  valH    new value for horizontal display
        @param  valV    new value to vertical display
        @return was the property really set (not fixed)?
    **/
    public function setProp(prop:String, valH:Dynamic, valV:Dynamic):Bool {
        if (!this.isFixed(prop)) {
            switch (prop) {
                case 'order':
                    this.horizontal.order = valH;
                    this.vertical.order = valV;
                case 'x':
                    this.horizontal.x = valH;
                    this.vertical.x = valV;
                case 'y':
                    this.horizontal.y = valH;
                    this.vertical.y = valV;
                case 'alpha':
                    this.horizontal.alpha = valH;
                    this.vertical.alpha = valV;
                case 'width':
                    this.horizontal.width = valH;
                    this.vertical.width = valV;
                case 'height':
                    this.horizontal.height = valH;
                    this.vertical.height = valV;
                case 'rotation':
                    this.horizontal.rotation = valH;
                    this.vertical.rotation = valV;
                case 'visible':
                    this.horizontal.visible = valH;
                    this.vertical.visible = valV;
                case 'color':
                    this.horizontal.color = valH;
                    this.vertical.color = valV;
                case 'colorAlpha':
                    this.horizontal.colorAlpha = valH;
                    this.vertical.colorAlpha = valV;
                case 'volume':
                    this.horizontal.volume = valH;
                    this.vertical.volume = valV;
                case 'pan':
                    this.horizontal.pan = valH;
                    this.vertical.pan = valV;
                case 'blend':
                    this.horizontal.blend = valH;
                    this.vertical.blend = valV;
                case 'blur':
                    this.horizontal.blur = valH;
                    this.vertical.blur = valV;
                case 'dropshadow':
                    this.horizontal.dropshadow = valH;
                    this.vertical.dropshadow = valV;
                case 'glow':
                    this.horizontal.glow = valH;
                    this.vertical.glow = valV;
                case 'textFont':
                    this.horizontal.textFont = valH;
                    this.vertical.textFont = valV;
                case 'textSize':
                    this.horizontal.textSize = valH;
                    this.vertical.textSize = valV;
                case 'textColor':
                    this.horizontal.textColor = valH;
                    this.vertical.textColor = valV;
                case 'textBold':
                    this.horizontal.textBold = valH;
                    this.vertical.textBold = valV;
                case 'textItalic':
                    this.horizontal.textItalic = valH;
                    this.vertical.textItalic = valV;
                case 'textLeading':
                    this.horizontal.textLeading = valH;
                    this.vertical.textLeading = valV;
                case 'textSpacing':
                    this.horizontal.textSpacing = valH;
                    this.vertical.textSpacing = valV;
                case 'textBackground':
                    this.horizontal.textBackground = valH;
                    this.vertical.textBackground = valV;
                case 'textAlign':
                    this.horizontal.textAlign = valH;
                    this.vertical.textAlign = valV;
            }
            // property set
            return (true);
        } else {
            // property fixed
            return (false);
        }
    }

    /**
        Checks if a property is currently fixed.
        @return is the property fixed?
    **/
    public function isFixed(prop:String):Bool {
        return (this._fixed.contains(prop));
    }

    /**
        Fixed a property value.
        @param  prop    the property name
        @param  valH    fixed value for horizontal display
        @param  valV    fixed value to vertical display
    **/
    public function fixProp(prop:String, valH:Dynamic, valV:Dynamic):Void {
        if (!this.isFixed(prop)) this._fixed.push(prop);
        switch (prop) {
            case 'order':
                this.horizontal.order = valH;
                this.vertical.order = valV;
            case 'x':
                this.horizontal.x = valH;
                this.vertical.x = valV;
            case 'y':
                this.horizontal.y = valH;
                this.vertical.y = valV;
            case 'alpha':
                this.horizontal.alpha = valH;
                this.vertical.alpha = valV;
            case 'width':
                this.horizontal.width = valH;
                this.vertical.width = valV;
            case 'height':
                this.horizontal.height = valH;
                this.vertical.height = valV;
            case 'rotation':
                this.horizontal.rotation = valH;
                this.vertical.rotation = valV;
            case 'visible':
                this.horizontal.visible = valH;
                this.vertical.visible = valV;
            case 'color':
                this.horizontal.color = valH;
                this.vertical.color = valV;
            case 'colorAlpha':
                this.horizontal.colorAlpha = valH;
                this.vertical.colorAlpha = valV;
            case 'volume':
                this.horizontal.volume = valH;
                this.vertical.volume = valV;
            case 'pan':
                this.horizontal.pan = valH;
                this.vertical.pan = valV;
            case 'blend':
                this.horizontal.blend = valH;
                this.vertical.blend = valV;
            case 'blur':
                this.horizontal.blur = valH;
                this.vertical.blur = valV;
            case 'dropshadow':
                this.horizontal.dropshadow = valH;
                this.vertical.dropshadow = valV;
            case 'glow':
                this.horizontal.glow = valH;
                this.vertical.glow = valV;
            case 'textFont':
                this.horizontal.textFont = valH;
                this.vertical.textFont = valV;
            case 'textSize':
                this.horizontal.textSize = valH;
                this.vertical.textSize = valV;
            case 'textColor':
                this.horizontal.textColor = valH;
                this.vertical.textColor = valV;
            case 'textBold':
                this.horizontal.textBold = valH;
                this.vertical.textBold = valV;
            case 'textItalic':
                this.horizontal.textItalic = valH;
                this.vertical.textItalic = valV;
            case 'textLeading':
                this.horizontal.textLeading = valH;
                this.vertical.textLeading = valV;
            case 'textSpacing':
                this.horizontal.textSpacing = valH;
                this.vertical.textSpacing = valV;
            case 'textBackground':
                this.horizontal.textBackground = valH;
                this.vertical.textBackground = valV;
            case 'textAlign':
                this.horizontal.textAlign = valH;
                this.vertical.textAlign = valV;
        }
    }

    /**
        Releases a fixed property.
        @param  prop    the property name
    **/
    public function releaseProp(prop:String):Void {
        if (this.isFixed(prop)) this._fixed.remove(prop);
    }

    /**
        Releases all fixed properties.
    **/
    public function releaseAll():Void {
        while (this._fixed.length > 0) this._fixed.shift();
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        while (this._fixed.length > 0) this._fixed.shift();
        this._fixed = null;
        this.horizontal.kill();
        this.horizontal = null;
        this.vertical.kill();
        this.vertical = null;
    }

}