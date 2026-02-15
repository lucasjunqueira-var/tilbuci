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

/**
 * A contraption that displays a dynamic flow of buttons (menu-like) with configurable appearance.
 * Used for decision points, navigation menus, or interactive choice panels.
 */
class DflowContraption extends Sprite {

    /** Indicates whether the contraption is properly loaded and ready. */
    public var ok:Bool = false;

    /** Unique identifier for this flow contraption. */
    public var id:String;

    /** Font family used for button labels. Default 'sans'. */
    public var font:String = 'sans';

    /** Font color in hexadecimal string (e.g., '0xffffff'). */
    public var fontcolor:String = '0xffffff';

    /** Font size in pixels. Default 20. */
    public var fontsize:Int = 20;

    /** Path or URL to the button background image. Empty string means no background. */
    public var buton:String = '';

    /** Positioning of the button group: 'center', 'left', 'right', etc. */
    public var position:String = 'center';

    /** Vertical gap between buttons in pixels. Default 10. */
    public var gap:Int = 10;

    /** Calculated total size of the menu (width and height). */
    public var menuSize:Point = new Point();

    private var _btbitmap:PictureImage;

    private var _btsize:Point;

    private var _buttons:Array<ContraptionButton> = [ ];

    private var _options:Array<Array<String>> = [ ];

    /**
     * Creates a new DflowContraption instance.
     */
    public function new() {
        super();
    }

    /**
     * Creates the visual button flow from an array of button definitions.
     * Each button definition is an array [label, targetScene].
     * @param bts Array of button definitions.
     * @return This sprite instance.
     */
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

    /**
     * Checks if a given sprite collides with any button in the flow.
     * If a collision is detected, triggers the button's action.
     * @param obj Sprite to test collision against.
     * @return True if a collision occurred, false otherwise.
     */
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

    /**
     * Removes all buttons and clears the flow from its parent.
     */
    public function remove():Void {
        this.removeChildren();
        while (this._buttons.length > 0) this._buttons.shift().kill();
        this._options = [ ];
        if (this.parent != null) this.parent.removeChild(this);
    }

    /**
     * Creates a deep copy of this flow contraption.
     * @return A new DflowContraption with the same properties.
     */
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

    /**
     * Loads configuration data and prepares the button background image.
     * @param data Dynamic object containing id, font, fontcolor, fontsize, buton, position, gap.
     * @return True if the data contains an 'id' field, false otherwise.
     */
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

    /**
     * Completely destroys the flow contraption, releasing all resources.
     */
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

    /**
     * Serializes the flow contraption to a plain object.
     * @return Dynamic object containing id, font, fontcolor, fontsize, buton, position, gap.
     */
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

    /**
     * Called when the button background image finishes loading.
     * @param ok Whether the image loaded successfully.
     */
    private function onBTLoad(ok:Bool):Void {
        this.ok = ok;
        if (ok) {
            this._btsize = new Point(this._btbitmap.oWidth, this._btbitmap.oHeight);
        }
    }

    /**
     * Handles button click events. Loads the target scene and removes the flow.
     * @param val The button's value (index as string).
     */
    private function onClick(val:String):Void {
        if (this._options[Std.parseInt(val)][1] != '') {
            GlobalPlayer.parser.run('{"ac":"scene.load","param":["' + this._options[Std.parseInt(val)][1] + '"]}');
        }
        this.remove();
    }
}