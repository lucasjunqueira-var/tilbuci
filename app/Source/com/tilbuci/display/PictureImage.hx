/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.display;

/** OPENFL **/
import openfl.display.Bitmap;
import openfl.net.URLRequest;
import openfl.events.SecurityErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.display.Loader;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;

class PictureImage extends BaseImage {

    /**
        content loader
    **/
    private var _loader:Loader;

    public function new(ol:Dynamic = null) {
        super('picture', false, ol);
        this._lastMedia = '';
        this._loader = new Loader();
        this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onOk);
        this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
        this.addChild(this._loader);
    }

    /**
        Loads a new media file.
        @param  media   file path inside the media folder
    **/
    public function load(media:String):Void {
        media = StringTools.replace(media, (GlobalPlayer.path + 'media/picture/'), '');
        this._lastMedia = media;
        var path:String = GlobalPlayer.parser.parsePath(GlobalPlayer.path + 'media/picture/' + media);
        this._loader.load(new URLRequest(path));
    }

    /**
        Unloads current image.
    **/
    public function unload():Void {
        this._lastMedia = '';
        try { this._loader.unload(); } catch (e) { }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
        try { this._loader.unload(); } catch (e) { }
        this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onOk);
        this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
        this._loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
        this._loader = null;
        this._lastMedia = null;
    }

    /**
        Media loded successfully.
    **/
    private function onOk(e:Event):Void {
        this.oWidth = this._loader.content.width;
        this.oHeight = this._loader.content.height;
        var cont:Bitmap = cast this._loader.content;
        cont.smoothing = true;
        if (this._onLoad != null) this._onLoad(true);
    }

    /**
        Error while loading the media.
    **/
    private function onError(e:Event):Void {
        this._lastMedia = '';
        if (this._onLoad != null) this._onLoad(false);
    }
}