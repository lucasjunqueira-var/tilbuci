package com.tilbuci.display;

/** OPENFL **/
import openfl.media.SoundTransform;
import openfl.display.Shape;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.media.Video;
import openfl.net.URLRequest;
import openfl.events.SecurityErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.NetStatusEvent;
import openfl.events.AsyncErrorEvent;
import openfl.events.Event;

/** ACTUATE **/
import motion.Actuate;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;

class VideoImage extends BaseImage {

    /**
        the video display
    **/
    private var _video:Video;

    /**
        video file loader
    **/
    private var _connection:NetConnection;

    /**
        the video stream
    **/
    private var _stream:NetStream;

    /**
        content loaded?
    **/
    private var _loaded:Bool = false;

    /**
        clickable background
    **/
    private var _bg:Shape;

    /**
        end-of-media function  to call
    **/
    private var _onEnd:Dynamic;

    /**
        current video file
    **/
    private var _current:String = '';

    public function new(ol:Dynamic, end:Dynamic) {
        super('video', true, ol);
        this._onEnd = end;

        // adding the clickable background
        this._bg = new Shape();
        this._bg.graphics.beginFill(0x000000);
		this._bg.graphics.drawRect(0, 0, 32, 32);
		this._bg.graphics.endFill();
		this.addChild(this._bg);

        this._video = new Video();
        this._video.smoothing = true;
        this.addChild(this._video);

        this._connection = new NetConnection();
        this._connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		this._connection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		this._connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		this._connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
        this._connection.connect(null);

        this._stream = new NetStream(this._connection);
		this._stream.checkPolicyFile = true;
		this._stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
		this._stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		this._stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);

        var clientObj:Dynamic = {
			'onMetaData': this.metadataEvent,
			'onImageData': this.imagedataEvent,
			'onPlayStatus': this.playstatusEvent,
			'onCuePoint': this.cuepointEvent
		};
		this._stream.client = clientObj;
		this._video.attachNetStream(this._stream);
    }

    /**
        Gets the current playback time.
        @return the current time in seconds
    **/
    public function getTime():Int {
        if (this._loaded) {
            return (Math.round(this._stream.time));
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
            this._stream.seek(to);
        }
    }

    /**
        Loads a new media file.
        @param  media   file path inside the media folder
    **/
    public function load(media:String):Void {
        media = StringTools.replace(media, (GlobalPlayer.path + 'media/video/'), '');
        var path:String = GlobalPlayer.parser.parsePath(GlobalPlayer.path + 'media/video/' + media);
        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
            this._loaded = false;
            this._current = '';
            this._stream.play(path);
        } else if (this._current != media) {
            this._loaded = false;
            this._current = media;
            this._stream.play(path);
        } else {
            this._loaded = false;
            this._stream.seek(0);
            this._stream.play(path);
        }
    }

    /**
        Manipulates sound properties.
        @param  vol sound volume
        @param  pan sound pan
    **/
    public function iterateSound(vol:Float, pan:Float):Void {
        //Actuate.transform(this._stream, GlobalPlayer.mdata.time).sound(vol, pan);
        Actuate.transform(this._stream, GlobalPlayer.mdata.time).sound(vol, null);
    }

    /**
        Stops sound transformations.
    **/
    public function stopSound():Void {
        Actuate.stop(this._stream);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
        this._bg.graphics.clear();
		this._bg = null;
        this._video.attachNetStream(null);
		this._video = null;
		this._connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		this._connection.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		this._connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		this._connection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
		this._connection = null;
		this._stream.client = null;
		this._stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
		this._stream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		this._stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		this._stream = null;
        this._onEnd = null;
        this._current = null;
    }

    /**
        Starts video playback.
    **/
    public function play():Void {
        if (this._loaded) {
            this._stream.resume();
        }
    }

    /**
        Pauses video playback.
    **/
    public function pause():Void {
        if (this._loaded) {
            this._stream.pause();
        }
    }

    /**
        Stops the current playback.
    **/
    public function stop():Void {
        this._stream.pause();
        this._stream.seek(0);
    }

    /**
	 * Net status event.
	 */
	private function netStatusHandler(event:NetStatusEvent):Void {
        switch (event.info.code) {
            case 'NetStream.Play.Start':
                if (!this._loaded) {
                    this._loaded = true;
                    this._bg.width = this._video.width = this.oWidth;
                    this._bg.height = this._video.height = this.oHeight;
                    this._onLoad(true);
                    if (GlobalPlayer.mode == Player.MODE_EDITOR) this.stop();
                }
            case 'NetStream.Play.Complete':
                this._onEnd();
        }
	}

    /**
	 * IO error event.
	 */
	private function ioErrorHandler(evt:IOErrorEvent):Void {
		this._onLoad(false);
	}

    /**
	 * Security error event.
	 */
	private function securityErrorHandler(evt:SecurityErrorEvent):Void {
		this._onLoad(false);
	}

    /**
	 * Async error event.
	 */
	private function asyncErrorHandler(evt:AsyncErrorEvent):Void {
        this._onLoad(false);
    }

    /**
	 * Metadata received.
	 */
	private function metadataEvent(data:Dynamic):Void {
        this.oWidth = data.width;
        this.oHeight = data.height;
        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
            this._loaded = true;
            this._bg.width = this._video.width = this.oWidth = data.width;
            this._bg.height = this._video.height = this.oHeight = data.height;
            this._onLoad(true);
            this.stop();
        }
	}

    /**
	 * Image data received.
	 */
	private function imagedataEvent(data:Dynamic):Void {
        //trace ('imagedataEvent', data);
    }

    /**
	 * Playstatus data received.
	 */
	private function playstatusEvent(data:Dynamic):Void {
		// trace ('playstatusEvent', data);
	}

    /**
	 * Cuepoint data received.
	 */
	private function cuepointEvent(data:Dynamic):Void {
		// future cuepoint support
	}
}