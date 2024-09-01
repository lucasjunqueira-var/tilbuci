package com.tilbuci.display;

/** OPENFL **/
import openfl.display.Sprite;

class BaseImage extends Sprite {

    /**
        image type
    **/
    public var type:String = '';

    /**
        use media time
    **/
    private var _autoTimer:Bool = false;

    /**
        method to call on content load (must receive a single Bool parameter)
    **/
    private var _onLoad:Dynamic;

    /**
        content original width
    **/
    public var oWidth:Float = 0;

    /**
        content original height
    **/
    public var oHeight:Float = 0;

    /**
        media loaded?
    **/
    public var mediaLoaded(get, null):Bool;
    private function get_mediaLoaded():Bool { return (this._mediaLoaded); }
    private var _mediaLoaded:Bool;

    /**
        last media loaded
    **/
    public var lastMedia(get, null):String;
    private function get_lastMedia():String { return (this._lastMedia); }
    private var _lastMedia:String;


    public function new(tp:String, at:Bool, ol:Dynamic) {
        super();
        this.type = tp;
        this._autoTimer = at;
        this._onLoad = ol;
        this._mediaLoaded = false;
        this.visible = false;
        this._lastMedia = '';
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.removeChildren();
        this.type = null;
        this._onLoad = null;
    }

}