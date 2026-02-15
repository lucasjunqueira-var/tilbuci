/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import com.tilbuci.player.MovieArea;
import com.tilbuci.display.PictureImage;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class BackgroundContraption extends Sprite {

    /** Indicates whether the contraption is properly loaded and ready. */
    public var ok:Bool = false;

    /** Unique identifier for this background contraption. */
    public var id:String;

    /** Path or identifier for the landscape orientation image. */
    public var landscape:String;

    /** Path or identifier for the portrait orientation image. */
    public var portrait:String;

    private var _landscape:PictureImage;

    private var _portrait:PictureImage;

    /**
        Creates a new BackgroundContraption instance.
        @param data Optional configuration data to load immediately.
    */
    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    /**
        Creates the visual representation of the background contraption.
        @param bts Unused parameter (kept for compatibility).
        @param ac Unused parameter (kept for compatibility).
        @return This instance as a Sprite.
    */
    public function create(bts:Array<String>, ac:Dynamic):Sprite {
        if (this.ok) {
            this.removeChildren();
        }
        return (this);
    }

    /**
        Removes the contraption from its parent container and clears its children.
    */
    public function remove():Void {
        this.removeChildren();
        if (this.parent != null) this.parent.removeChild(this);
    }

    /**
        Creates a deep copy of this background contraption.
        @return A new BackgroundContraption instance with identical properties.
    */
    public function clone():BackgroundContraption {
        return (new BackgroundContraption(this.toObject()));
    }

    /**
        Displays the appropriate background image based on screen orientation.
        @return This instance with the correct image added as a child.
    */
    public function getCover():BackgroundContraption {
        this.removeChildren();
        if (GlobalPlayer.area.pOrientation == MovieArea.HORIENTATION) {
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
        Loads configuration data into the background contraption.
        @param data Dynamic object containing `id`, `landscape`, and `portrait` fields.
        @return True if data contains required 'id' field and at least one image, false otherwise.
    */
    public function load(data:Dynamic):Bool {
        this.ok = false;
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
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
            if (this.portrait == null) this.portrait = '';
            if (this.landscape == null) this.landscape = '';
            if ((this.landscape != '') || (this.portrait != '')) {
                if (this._landscape != null) this._landscape.load(this.landscape);
                if (this._portrait != null) this._portrait.load(this.portrait);
                this.mouseEnabled = false;
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
        Called when a background image finishes loading.
        Adjusts the image dimensions according to the current screen orientation.
        @param ok Whether the image loaded successfully.
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
        Destroys the contraption, releasing all resources and removing all references.
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
    }

    /**
        Serializes the contraption configuration into a dynamic object.
        @return Dynamic object containing `id`, `landscape`, and `portrait` fields.
    */
    public function toObject():Dynamic {
        return({
            id: this.id,
            landscape: this.landscape,
            portrait: this.portrait,
        });
    }
}