package com.tilbuci.display;

/** OPENFL **/
import openfl.media.SoundChannel;
import openfl.media.Sound;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.URLRequest;

/** ACTUATE **/
import motion.Actuate;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;

class AudioImage extends BaseImage {

    /**
        the sound object
    **/
    private var _sound:Sound;

    /**
        playback channel
    **/
    private var _channel:SoundChannel;

    /**
        media loaded?
    **/
    private var _loaded:Bool = false;

    /**
        end-of-media function  to call
    **/
    private var _onEnd:Dynamic;

    public function new(ol:Dynamic, end:Dynamic) {
        super('audio', true, ol);
        this._onEnd = end;
        this._sound = new Sound();  
        this._sound.addEventListener(Event.COMPLETE, onComplete);
        this._sound.addEventListener(IOErrorEvent.IO_ERROR, onError);
    }

    /**
        Gets the current playback time.
        @return the current time in seconds
    **/
    public function getTime():Int {
        if (this._loaded) {
            return (Math.round(this._channel.position / 1000));
        } else {
            return (0);
        }
    }

    /**
        Sets the current playback time.
        @param  to  the new time in seconds
    **/
    public function setTime(to:Int):Void {
        if (this._loaded) {
            if (this._channel != null) {
                //this._channel.position = to * 1000;
            }
        }
    }

    /**
        Loads a new media file.
        @param  media   file path inside the media folder
    **/
    public function load(media:String):Void {
        media = StringTools.replace(media, (GlobalPlayer.path + 'media/audio/'), '');
        this._loaded = false;
        if (this._channel != null) {
			this._channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			this._channel.stop();
			this._channel = null;
		}
        var path:String = GlobalPlayer.parser.parsePath(GlobalPlayer.path + 'media/audio/' + media);
        this._sound.load(new URLRequest(path));
    }

     /**
        Manipulates sound properties.
        @param  vol sound volume
        @param  pan sound pan
    **/
    public function iterateSound(vol:Float, pan:Float):Void {
        if (this._channel != null) {
            //Actuate.transform(this._channel, GlobalPlayer.mdata.time).sound(vol, pan);
            Actuate.transform(this._channel, GlobalPlayer.mdata.time).sound(vol, null);
        }
    }

    /**
        Stops sound transformations.
    **/
    public function stopSound():Void {
        Actuate.stop(this._sound);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
        this._loaded = false;
        this._onEnd = null;
        try {
            this._sound.close();
        } catch (e) { }
        this._sound.removeEventListener(Event.COMPLETE, onComplete);
        this._sound.removeEventListener(IOErrorEvent.IO_ERROR, onError);
        this._sound = null;
        if (this._channel != null) {
			this._channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			this._channel.stop();
			this._channel = null;
		}
    }

    /**
        Starts video playback.
    **/
    public function play():Void {
        if (this._loaded) {
            var pos:Float = 0;
            if (this._channel != null) {
                pos = this._channel.position;
                this._channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
                this._channel.stop();
                this._channel = null;
            }
            this._channel = this._sound.play(pos);
            this._channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
        }
    }

    /**
        Pauses video playback.
    **/
    public function pause():Void {
        if (this._loaded) {
            this._channel.stop();
        }
    }

    /**
        Stops the current playback.
    **/
    public function stop():Void {
        if (this._loaded) {
            this._channel.stop();
        }
    }

    /**
	 * Media loaded.
	 */
	private function onComplete(evt:Event):Void {
        this._loaded = true;
        if (this._channel != null) {
			this._channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			this._channel.stop();
			this._channel = null;
		}
        this._channel = this._sound.play(0);
        this._channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
        this._onLoad(true);
	}

    /**
	 * IO error event.
	 */
	private function onError(evt:IOErrorEvent):Void {
        this._loaded = false;
		this._onLoad(false);
	}

    /**
	 * Sound playback reaches the end of the file.
	 */
	private function soundComplete(evt:Event):Void {
        this._onEnd();
    }
}