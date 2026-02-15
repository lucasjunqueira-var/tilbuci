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

/**
 * A contraption that displays a user interface with images, spritemaps, text, and interactive elements.
 * Used for HUDs, menus, and overlay interfaces.
 */
class InterfaceContraption extends Sprite {

    /** Indicates whether the contraption is properly loaded and ready. */
    public var ok:Bool = false;

    /** Unique identifier for this interface contraption. */
    public var id:String;

    /** Array of interface element definitions (background, spritemap, text, images). */
    public var elem:Array<InterfaceElem> = [ ];

    private var _created:Bool = false;

    private var _graphics:Map<String, BaseImage> = [ ];

    private var _smap:SpritemapImage;

    private var _text:TextField;

    /**
     * Creates a new InterfaceContraption instance.
     * @param data Optional initialization data (as returned by `toObject`).
     */
    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    /**
     * Starts the interface, creating all visual elements and attaching event listeners.
     * @return True if the contraption is loaded (ok = true), false otherwise.
     */
    public function start():Bool {
        if (this.ok) {
            if (!this._created) {
                var imnum:Int = 1;
                for (el in this.elem) {
                    var pi:PictureImage;
                    var opt:Array<String>;
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
                                if (el.rot != null) pi.rotation = el.rot;
                                if (el.alpha != null) pi.alpha = el.alpha / 100;
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

    /**
     * Checks if a given sprite collides with any interactive element in the interface.
     * If a collision is detected, triggers the associated action.
     * @param obj Sprite to test collision against.
     * @return True if a collision occurred and an action was triggered, false otherwise.
     */
    public function checkCollision(obj:Sprite):Bool {
        var ret:Bool = false;
        for (k in this._graphics) {
            if (!ret) {
                if (k.hasEventListener(MouseEvent.CLICK) && (k.extraInfo.length > 0)) {
                    if (obj.hitTestObject(k)) {
                        if (GlobalPlayer.mvActions.exists(GlobalPlayer.parser.parseString(k.extraInfo[0]))) {
                            GlobalPlayer.parser.run(GlobalPlayer.mvActions[GlobalPlayer.parser.parseString(k.extraInfo[0])]);
                            ret = true;
                        }
                    }
                }
            }
        }
        return (ret);
    }

    /**
     * Removes the interface from its parent (but does not destroy resources).
     */
    public function remove():Void {
        if (this.parent != null) this.parent.removeChild(this);
    }

    /**
     * Creates a deep copy of this interface contraption.
     * @return A new InterfaceContraption with the same properties.
     */
    public function clone():InterfaceContraption {
        return (new InterfaceContraption(this.toObject()));
    }

    /**
     * Loads interface configuration data.
     * @param data Dynamic object containing id and elem fields.
     * @return True if the data contains an 'id' and an 'elem' field, false otherwise.
     */
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

    /**
     * Completely destroys the interface contraption, releasing all resources and removing event listeners.
     */
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

    /**
     * Serializes the interface contraption to a plain object.
     * @return Dynamic object containing id and elem fields.
     */
    public function toObject():Dynamic {
        return({
            id: this.id,
            elem: this.elem,
        });
    }

    /**
     * Updates the text content of the text element (if present).
     * @param tx New text string.
     * @return True if the text element exists, false otherwise.
     */
    public function setText(tx:String):Bool {
        if (this._text == null) {
            return (false);
        } else {
            this._text.text = tx;
            return (true);
        }
    }

    /**
     * Sets the current frame of the spritemap element.
     * @param fr Frame index (0‑based).
     * @return True if the spritemap exists, false otherwise.
     */
    public function setMapFrame(fr:Int):Bool {
        if (this._smap == null) {
            return (false);
        } else {
            return (this._smap.setFrame(fr));
        }
    }

    /**
     * Pauses the spritemap animation.
     * @return True if the spritemap exists, false otherwise.
     */
    public function pauseMap():Bool {
        if (this._smap == null) {
            return (false);
        } else {
            this._smap.pause();
            return (true);
        }
    }

    /**
     * Starts or resumes the spritemap animation.
     * @return True if the spritemap exists, false otherwise.
     */
    public function playMap():Bool {
        if (this._smap == null) {
            return (false);
        } else {
            this._smap.play();
            return (true);
        }
    }

    /**
     * Click event handler for interactive elements. Executes the associated action.
     * @param evt MouseEvent object.
     */
    private function onClick(evt:MouseEvent):Void {
        this.onOut(evt);
        var img:BaseImage = cast evt.target;
        if (img.extraInfo.length > 0) {
            if (GlobalPlayer.mvActions.exists(GlobalPlayer.parser.parseString(img.extraInfo[0]))) {
                GlobalPlayer.parser.run(GlobalPlayer.mvActions[GlobalPlayer.parser.parseString(img.extraInfo[0])]);
            }
        }
    }

    /**
     * Mouse‑over event handler for interactive elements. Applies a highlight glow.
     * @param evt MouseEvent object.
     */
    private function onOver(evt:MouseEvent):Void {
        var img:BaseImage = cast evt.target;
        if (GlobalPlayer.cursorVisible) if (GlobalPlayer.mdata.highlight != '') {
            img.filters = [
                new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
            ];
        }
    }

    /**
     * Mouse‑out event handler for interactive elements. Removes the highlight glow.
     * @param evt MouseEvent object.
     */
    private function onOut(evt:MouseEvent):Void {
        var img:BaseImage = cast evt.target;
        img.filters = [ ];
    }
}

/**
 * Structure defining a single interface element.
 */
typedef InterfaceElem = {
    /** Element type: 'background', 'spritemap', 'text', or any other (treated as an image). */
    var type:String;
    /** Path or URL to the image file (or spritemap file). */
    var file:String;
    /** Action identifier (mapped to a movie action) for interactive elements. */
    var action:String;
    /** X coordinate of the element. */
    var x:Int;
    /** Y coordinate of the element. */
    var y:Int;
    /** Optional rotation in degrees. */
    var rot:Null<Int>;
    /** Optional opacity (0‑100). */
    var alpha:Null<Int>;
    /** Semicolon‑separated options (format depends on element type). */
    var options:String;
}