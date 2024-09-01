package com.tilbuci.plugin;

/** OPENFL **/
import openfl.events.EventDispatcher;

/** TILBUCI **/
import com.tilbuci.plugin.PluginEvent;

/**
    Information about the system.
**/
class SystemInfo extends EventDispatcher {

    /**
        current movie name
    **/
    public var movieName:String = '';

    /**
        current movie id
    **/
    public var movieId:String = '';

    /**
        current scene name
    **/
    public var sceneName:String = '';

    /**
        current scene id
    **/
    public var sceneId:String = '';

    /**
        number of keyframes of the current scene
    **/
    public var keyframeTotal:Int = 0;

    /**
        number of the current keyframe
    **/
    public var keyframeCurrent:Int = 0;

    /**
        display bigger size
    **/
    public var displayBigger:Int = 0;

    /**
        display smaller size
    **/
    public var displaySmaller:Int = 0;

    /**
        current asset multiply level
    **/
    public var displayMultiply:Int = 1;

    /**
        current display orientation
    **/
    public var orientation:String = '';

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.movieName = this.movieId = null;
        this.sceneName = this.sceneId = null;
    }

    /**
        A movie was just loaded.
    **/
    public function onNewMovie(nm:String, id:String, bs:Int, ss:Int):Void {
        this.movieName = nm;
        this.movieId = id;
        this.displayBigger = bs;
        this.displaySmaller = ss;
        this.dispatchEvent(new PluginEvent(PluginEvent.MOVIELOAD));
    }

    /**
        A scene was just loaded.
    **/
    public function onNewScene(nm:String, id:String, kfs:Int):Void {
        this.sceneName = nm;
        this.sceneId = id;
        this.keyframeTotal = kfs;
        this.keyframeCurrent = 0;
        this.dispatchEvent(new PluginEvent(PluginEvent.SCENELOAD));
    }

    /**
        A keyframe was just loaded.
    **/
    public function onNewKeyframe(kf:Int):Void {
        this.keyframeCurrent = kf;
        this.dispatchEvent(new PluginEvent(PluginEvent.KEYFRAMELOAD));
    }

    /**
        The display was just resized.
    **/
    public function onDisplayResize(or:String, mt:Int):Void {
        this.orientation = or;
        this.displayMultiply = mt;
        this.dispatchEvent(new PluginEvent(PluginEvent.DISPLAYRESIZE));
    }

}