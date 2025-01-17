/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;

/** FEATHRES UI **/
import com.tilbuci.display.SpritemapImage;
import feathers.events.TriggerEvent;
import openfl.Assets;
import openfl.display.Bitmap;
import feathers.controls.Button;
import com.tilbuci.data.Global;
import openfl.events.Event;
import openfl.net.URLRequest;
import openfl.display.Loader;
import feathers.core.FeathersControl;
import com.tilbuci.display.VideoImage;
import com.tilbuci.display.AudioImage;
import com.tilbuci.display.HtmlImage;

class MediaPreview extends FeathersControl {

    /**
        media type
    **/
    private var _type:String;

    /**
        display width
    **/
    private var _wd:Int;

    /**
        display height
    **/
    private var _ht:Int;

    /**
        playback controls
    **/
    private var _controls:FeathersControl;

    /**
        picture loader
    **/
    private var _loader:Loader;

    /**
        video loader
    **/
    private var _video:VideoImage;

    /**
        audio loader
    **/
    private var _audio:AudioImage;

    /**
        html loader
    **/
    private var _html:HtmlImage;

    /**
        spritemap loader
    **/
    private var _spritemap:SpritemapImage;



    public function new(type:String, wd:Int = 500, ht:Int = 500) {
        super();
        this._type = type;
        this._wd = wd;
        this._ht = ht;
        this.alpha = 0;

        switch (type) {
            case 'picture':
                this._loader = new Loader();
                this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPicture);
                this.addChild(this._loader);
            case 'video':
                this._video = new VideoImage(this.onVideo, null);
                this.addChild(this._video);
                this.createPlayback();
            case 'audio':
                this._audio = new AudioImage(this.onAudio, null);
                this.addChild(this._audio);
                this.createPlayback();
            case 'html':
                this._html = new HtmlImage(this.onHtml);
                this.addChild(this._html);
            case 'spritemap':
                this._spritemap = new SpritemapImage(this.onSpritemap);
                this.addChild(this._spritemap);
        }
    }

    public function setSpritemap(frames:Int, frtime:Int):Void {
        if (this._type == 'spritemap') {
            this._spritemap.frames = frames;
            this._spritemap.frtime = frtime;
            if (this._spritemap.mediaLoaded) this._spritemap.load(this._spritemap.lastMedia);
        }
    }

    private function createPlayback():Void {
        this._controls = new FeathersControl();

        var icon:Bitmap = new Bitmap(Assets.getBitmapData('btPlay'));
        icon.smoothing = true;
        icon.width = icon.height = 20;
        var btPlay:Button = new Button();
        btPlay.icon = icon;
        btPlay.addEventListener(TriggerEvent.TRIGGER, onPlay);
        this._controls.addChild(btPlay);

        icon = new Bitmap(Assets.getBitmapData('btStop'));
        icon.smoothing = true;
        icon.width = icon.height = 20;
        var btStop:Button = new Button();
        btStop.icon = icon;
        btStop.addEventListener(TriggerEvent.TRIGGER, onStop);
        btStop.y = 0;
        btStop.x = 50;
        this._controls.addChild(btStop);

        this.addChild(this._controls);
        this._controls.x = 0;
        this._controls.y = this._ht - 10 - this._controls.height;
    }

    public function hide():Void {
        this.alpha = 0;
        switch (this._type) {
            case 'picture':
                this._loader.unload();
            case 'video':
                this._video.visible = false;
            case 'html':
                this._html.visible = false;
            case 'audio':
                this._audio.visible = false;
            case 'spritemap':
                this._spritemap.visible = false;
        }
    }

    public function preview(url:String):Void {
        switch (this._type) {
            case 'picture':
                this._loader.load(new URLRequest(url + '?rand=' + (Math.random() * 10000)));
                this.alpha = 1;
            case 'video':
                this._video.load(url);
                this._video.visible = false;
                this.alpha = 1;
            case 'html':
                this._html.load(url);
                this._html.visible = false;
                this.alpha = 1;
            case 'audio':
                this._audio.load(url);
                this._audio.visible = false;
                this.alpha = 1;
            case 'spritemap':
                this._spritemap.load(url);
                this._spritemap.visible = false;
                this.alpha = 1;
        }
    }

    private function onPlay(evt:TriggerEvent):Void {
        switch (this._type) {
            case 'video':
                this._video.play();
            case 'audio':
                this._audio.play();
        }
    }

    public function onStop(evt:TriggerEvent):Void {
        switch (this._type) {
            case 'video':
                this._video.stop();
            case 'audio':
                this._audio.stop();
        }
    }

    /**
        A picture was loaded.
    **/
    private function onPicture(evt:Event):Void {
        if (this._loader.content.height > this._loader.content.width) {
            this._loader.height = this._ht;
            this._loader.width = this._loader.content.width * (this._ht / this._loader.content.height);
        } else {
            this._loader.width = this._wd;
            this._loader.height = this._loader.content.height * (this._wd / this._loader.content.width);
        }
        this._loader.x = (this._wd - this._loader.width) / 2;
        this._loader.y = (this._ht - this._loader.height) / 2;
    }

    /**
        A video was loaded.
    **/
    private function onVideo(ok:Bool):Void {
        if (ok) {
            if ((this._video.oHeight + this._controls.height + 20) > this._video.oWidth) {
                this._video.height = this._ht - this._controls.height - 20;
                this._video.width = this._video.oWidth * (this._video.height / this._video.oHeight);
            } else {
                this._video.width = this._wd;
                this._video.height = this._video.oHeight * (this._wd / this._video.oWidth);
            }
            this._video.x = (this._wd - this._video.width) / 2;
            this._video.y = ((this._ht - this._controls.height - 20) - this._video.height) / 2;
            this._video.stop();
            this._video.visible = true;
        } else {
            this._video.visible = false;
            Global.showMsg(Global.ln.get('window-mdvideo-loaderror'));
        }
    }

    /**
        An html file was loaded.
    **/
    private function onHtml(ok:Bool):Void {
        if (ok) {
            this._html.width = this._wd;
            this._html.height = this._ht;
            this._html.visible = true;
        } else {
            this._html.visible = false;
            Global.showMsg(Global.ln.get('window-mdhtml-loaderror'));
        }
    }

    /**
        An audio was loaded.
    **/
    private function onAudio(ok:Bool):Void {
        if (ok) {
            this._audio.stop();
            this._audio.visible = true;
        } else {
            Global.showMsg(Global.ln.get('window-mdaudio-loaderror'));
        }
    }

    /**
        A spritemap was loaded.
    **/
    private function onSpritemap(ok:Bool):Void {
        if (ok) {
            if (this._spritemap.oHeight > this._spritemap.oWidth) {
                this._spritemap.height = this._ht;
                this._spritemap.width = this._spritemap.oWidth * (this._spritemap.height / this._spritemap.oHeight);
            } else {
                this._spritemap.width = this._wd;
                this._spritemap.height = this._spritemap.oHeight * (this._wd / this._spritemap.oWidth);
            }
            this._spritemap.x = (this._wd - this._spritemap.width) / 2;
            this._spritemap.y = 40 + ((this._ht - this._spritemap.height) / 2);
            this._spritemap.visible = true;
        } else {
            this._spritemap.visible = false;
            Global.showMsg(Global.ln.get('window-mdspritemap-loaderror'));
        }
    }

}
