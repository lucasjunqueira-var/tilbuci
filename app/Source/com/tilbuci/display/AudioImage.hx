/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.display;

/** HAXE **/
import openfl.media.SoundTransform;
import haxe.Timer;

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

    /**
        timer count
    **/
    private var _timer:Timer;

    /**
        last dispatched time
    **/
    private var _currentTime:Int = 0;

    /**
        sound channel position
    **/
    private var _channelPos:Float = -1;

    /**
        sound transform
    **/
    private var _transform:SoundTransform;

    /**
        timed action function
    **/
    private var _onTimedAc:Dynamic;

    public function new(ol:Dynamic, end:Dynamic, ta:Dynamic = null) {
        super('audio', true, ol);
        this._onEnd = end;
        this._sound = new Sound();  
        this._sound.addEventListener(Event.COMPLETE, onComplete);
        this._sound.addEventListener(IOErrorEvent.IO_ERROR, onError);
        this._onTimedAc = ta;
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
        this._lastMedia = media;
        this._loaded = false;
        this._channelPos = -1;
        this._transform = null;
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
    public function iterateSound(vol:Float, pan:Float = 0):Void {
        if (this._channel != null) {
            //Actuate.transform(this._channel, GlobalPlayer.mdata.time).sound(vol, pan);
            Actuate.transform(this._channel, GlobalPlayer.mdata.time).sound(vol, null);
            this._transform = new SoundTransform(vol, 0);
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
        this._onTimedAc = null;
        if (this._timer != null) {
            try { this._timer.stop(); } catch (e) { }
            this._timer = null;
        }
    }

    /**
        Starts audio playback.
    **/
    public function play():Void {
        if (this._loaded) {
            var pos:Float = 0;
            if (this._channelPos > 0) pos = this._channelPos;
            this._channelPos = -1;
            if (this._channel != null) {
                this._channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
                this._channel.stop();
                this._channel = null;
            }
            this._channel = this._sound.play(pos, 0, this._transform);
            this._channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
            if (this._timer != null) {
                try { this._timer.stop(); } catch (e) { }
                this._timer = null;
            }
            this._currentTime = Math.round(pos/1000);
            this._timer = new Timer(1000);
            this._timer.run = this.onTimer;
        }
    }

    /**
        Pauses video playback.
    **/
    public function pause():Void {
        if (this._loaded) {
            this._channelPos = this._channel.position;
            this._channel.stop();
        }
    }

    /**
        Stops the current playback.
    **/
    public function stop():Void {
        if (this._loaded) {
            this._channel.stop();
            if (this._timer != null) {
                try { this._timer.stop(); } catch (e) { }
                this._timer = null;
            }
            this._channelPos = -1;
        }
    }

    /**
        Media playback.
    **/
    private function onTimer():Void {
        var tm:Int = Math.round(this._channel.position / 1000);
        if (this._currentTime != tm) {
            if (this._onTimedAc != null) {
                this._currentTime = tm;
                this._onTimedAc(tm);
            }
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