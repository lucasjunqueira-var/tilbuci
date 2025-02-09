/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.display;

/** HAXE **/
import openfl.geom.Matrix;
import haxe.Timer;

/** OPENFL **/
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.net.URLRequest;
import openfl.events.SecurityErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.display.Loader;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;

class SpritemapImage extends BaseImage {

    /**
        number of frames on map
    **/
    public var frames:Int = 1;

    /**
        time to keep each frame (miliseconds)
    **/
    public var frtime:Int = 100;

    /**
        content loader
    **/
    private var _loader:Loader;

    /**
        current frame number
    **/
    private var _current:Int = 0;

    /**
        animaiton timer
    **/
    private var _timer:Timer;

    /**
        the frames bitmaps
    **/
    private var _display:Array<Bitmap> = [ ];

    public function new(ol:Dynamic) {
        super('spritemap', false, ol);
        this._loader = new Loader();
        this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onOk);
        this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        this._loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
    }

    /**
        Loads a new media file.
        @param  media   file path inside the media folder
    **/
    public function load(media:String):Void {
        media = StringTools.replace(media, (GlobalPlayer.path + 'media/spritemap/'), '');
        this._lastMedia = media;
        this._mediaLoaded = false;
        if (this._timer != null) {
            try { this._timer.stop(); } catch (e) { }
            this._timer = null;
        }
        this.removeChildren();
        while (this._display.length > 0) {
            var bmp:Bitmap = this._display.shift();
            bmp.bitmapData.dispose();
            bmp = null;
        }
        var path:String = GlobalPlayer.parser.parsePath(GlobalPlayer.path + 'media/spritemap/' + media);
        this._loader.load(new URLRequest(path));
    }

    /**
        Unloads current image.
    **/
    public function unload():Void {
        this._mediaLoaded = false;
        this._lastMedia = '';
        try { this._loader.unload(); } catch (e) { }
        if (this._timer != null) {
            try { this._timer.stop(); } catch (e) { }
            this._timer = null;
        }
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
        while (this._display.length > 0) {
            var bmp:Bitmap = this._display.shift();
            bmp.bitmapData.dispose();
            bmp = null;
        }
        this._display = null;
        if (this._timer != null) {
            try { this._timer.stop(); } catch (e) { }
            this._timer = null;
        }
    }

    /**
        Media loded successfully.
    **/
    private function onOk(e:Event):Void {
        this._mediaLoaded = true;
        this.oWidth = this._loader.content.width / this.frames;
        this.oHeight = this._loader.content.height;
        for (i in 0...this.frames) {
            var bdata:BitmapData = new BitmapData(Math.ceil(this.oWidth), Math.ceil(this.oHeight), true, 0x00000000);
            bdata.draw(this._loader, new Matrix(1, 0, 0, 1, (-i * this.oWidth), 0), null, null, new Rectangle(0, 0, this.oWidth, this.oHeight));
            var bmp:Bitmap = new Bitmap(bdata);
            bmp.smoothing = true;
            this._display.push(bmp);
        }
        this._loader.unload();
        this._current = 0;
        this.loadFrame();
        this._onLoad(true);
        if (this._timer != null) {
            try { this._timer.stop(); } catch (e) { }
            this._timer = null;
        }
        this._timer = new Timer(this.frtime);
        this._timer.run = this.nextFrame;
    }

    /**
        Loads the current frame into display.
    **/
    private function loadFrame():Void {
        this.removeChildren();
        this.addChild(this._display[this._current]);
    }

    /**
        Jumps to the next frame.
    **/
    private function nextFrame():Void {
        this._current++;
        if (this._current >= this.frames) this._current = 0;
        this.loadFrame();
    }

    /**
        Error while loading the media.
    **/
    private function onError(e:Event):Void {
        this._mediaLoaded = false;
        this._onLoad(false);
    }
}