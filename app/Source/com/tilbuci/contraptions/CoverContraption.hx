/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import com.tilbuci.player.MovieArea;
import openfl.events.MouseEvent;
import com.tilbuci.display.PictureImage;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

/**
 * A contraption that displays a cover image (landscape/portrait) with optional click handling.
 * Used for splash screens, loading screens, or background covers.
 */
class CoverContraption extends Sprite {

    /** Indicates whether the contraption is properly loaded and ready. */
    public var ok:Bool = false;

    /** Unique identifier for this cover contraption. */
    public var id:String;

    /** If true, the cover will listen for click events and trigger an action. */
    public var holdClick:Bool;

    /** Path or URL to the landscape‑orientation image. */
    public var landscape:String;

    /** Path or URL to the portrait‑orientation image. */
    public var portrait:String;

    private var _landscape:PictureImage;

    private var _portrait:PictureImage;

    /**
     * Creates a new CoverContraption instance.
     * @param data Optional initialization data (as returned by `toObject`).
     */
    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    /**
     * Creates the visual representation of the cover.
     * @param bts Array of button identifiers (unused in current implementation).
     * @param ac Action callback (unused in current implementation).
     * @return This sprite instance.
     */
    public function create(bts:Array<String>, ac:Dynamic):Sprite {
        if (this.ok) {
            this.removeChildren();
            
        }
        return (this);
    }

    /**
     * Removes the cover from its parent and clears its children.
     */
    public function remove():Void {
        this.removeChildren();
        if (this.parent != null) this.parent.removeChild(this);
    }

    /**
     * Creates a deep copy of this cover contraption.
     * @return A new CoverContraption with the same properties.
     */
    public function clone():CoverContraption {
        return (new CoverContraption(this.toObject()));
    }

    /**
     * Displays the appropriate cover image based on the current screen orientation.
     * The image is scaled to fit the screen dimensions.
     * @return This cover contraption with the displayed image.
     */
    public function getCover():CoverContraption {
        this.removeChildren();
        if (GlobalPlayer.area.pOrientation == MovieArea.HORIZONTAL) {
            if (this._landscape != null) {
                this._landscape.width = GlobalPlayer.mdata.screen.big;
                this._landscape.height = GlobalPlayer.mdata.screen.small;
                this.addChild(this._landscape);
            } else {
                this._portrait.width = GlobalPlayer.mdata.screen.big;
                this._portrait.height = GlobalPlayer.mdata.screen.small;
                this.addChild(this._portrait);
            }
        } else {
            if (this._portrait != null) {
                this._portrait.width = GlobalPlayer.mdata.screen.small;
                this._portrait.height = GlobalPlayer.mdata.screen.big;
                this.addChild(this._portrait);
            } else {
                this._landscape.width = GlobalPlayer.mdata.screen.small;
                this._landscape.height = GlobalPlayer.mdata.screen.big;
                this.addChild(this._landscape);
            }
        }
        return (this);
    }

    /**
     * Loads cover data and prepares the images.
     * @param data Dynamic object containing id, click, portrait, and landscape fields.
     * @return True if at least one image (portrait or landscape) is provided, false otherwise.
     */
    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'click')) this.holdClick = Reflect.field(data, 'click');
                else this.holdClick = false;
            if (Reflect.hasField(data, 'portrait')) {
                this.portrait = Reflect.field(data, 'portrait');
                if (this.portrait != '') {
                    this._portrait = new PictureImage(this.onPicLoad);
                    this._portrait.visible = true;
                }
            } else {
                this.portrait = '';
            }
            if (Reflect.hasField(data, 'landscape')) {
                this.landscape = Reflect.field(data, 'landscape');
                if (this.landscape != '') {
                    this._landscape = new PictureImage(this.onPicLoad);
                    this._landscape.visible = true;
                }
            } else {
                this.landscape = '';
            }
            if (this.holdClick == null) this.holdClick = false;
            if (this.portrait == null) this.portrait = '';
            if (this.landscape == null) this.landscape = '';
            if ((this.landscape != '') || (this.portrait != '')) {
                if (this._landscape != null) this._landscape.load(this.landscape);
                if (this._portrait != null) this._portrait.load(this.portrait);
                if (this.holdClick) {
                    this.addEventListener(MouseEvent.CLICK, this.onClick);
                    this.mouseEnabled = true;
                } else {
                    this.mouseEnabled = false;
                }
                this.mouseChildren = false;
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    /**
     * Called when a picture finishes loading. Adjusts its dimensions according to the current orientation.
     * @param ok Whether the image loaded successfully.
     */
    private function onPicLoad(ok:Bool):Void {
        if (GlobalPlayer.area.pOrientation == MovieArea.HORIENTATION) {
            if (this._landscape != null) {
                this._landscape.width = GlobalPlayer.mdata.screen.big;
                this._landscape.height = GlobalPlayer.mdata.screen.small;
            } else {
                this._portrait.width = GlobalPlayer.mdata.screen.big;
                this._portrait.height = GlobalPlayer.mdata.screen.small;
            }
        } else {
            if (this._portrait != null) {
                this._portrait.width = GlobalPlayer.mdata.screen.small;
                this._portrait.height = GlobalPlayer.mdata.screen.big;
            } else {
                this._landscape.width = GlobalPlayer.mdata.screen.small;
                this._landscape.height = GlobalPlayer.mdata.screen.big;
            }
        }
    }

    /**
     * Completely destroys the cover contraption, releasing all resources and removing event listeners.
     */
    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        if (this._landscape != null) this._landscape.kill();
        if (this._portrait != null) this._portrait.kill();
        this._landscape = null;
        this._portrait = null;
        this.landscape = null;
        this.portrait = null;
        this.id = null;
        if (this.hasEventListener(MouseEvent.CLICK)) this.removeEventListener(MouseEvent.CLICK, this.onClick);
    }

    /**
     * Serializes the cover contraption to a plain object.
     * @return Dynamic object containing id, click, landscape, and portrait fields.
     */
    public function toObject():Dynamic {
        return({
            id: this.id,
            click: this.holdClick,
            landscape: this.landscape,
            portrait: this.portrait,
        });
    }

    /**
     * Click event handler (placeholder). Called when holdClick is true and the cover is clicked.
     * @param evt MouseEvent object.
     */
    private function onClick(evt:MouseEvent):Void {
        // noting to do
    }
}