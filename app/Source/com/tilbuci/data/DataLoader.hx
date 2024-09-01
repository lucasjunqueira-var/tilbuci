package com.tilbuci.data;

/** OPENFL **/
import haxe.crypto.Base64;
import haxe.io.Bytes;
import openfl.utils.ByteArray;
import openfl.net.URLRequest;
import openfl.net.URLVariables;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.events.EventDispatcher;
import openfl.net.URLLoaderDataFormat;

/** TILBUCI **/
import com.tilbuci.statictools.StringStatic;

class DataLoader extends EventDispatcher {

    /**
        binary load mode
    **/
    public static inline var MODEBINARY:Int = 0;

    /**
        general text load mode
    **/
    public static inline var MODETEXT:Int = 1;

    /**
        json text load mode
    **/
    public static inline var MODEJSON:Int = 3;

    /**
        json text load into <String, Dynamic> map
    **/
    public static inline var MODEMAP:Int = 4;

    /**
        encoded binary to extract text
    **/
    public static inline var MODEBINTXT:Int = 5;

    /**
        encoded binary to extract map
    **/
    public static inline var MODEBINMAP:Int = 6;


    /**
        the loader object
    **/
    private var _loader:URLLoader;

    /**
        action function to call on loader events
    **/
    private var _ac:Dynamic;

    /**
        action to call on request end, just before the callback action
    **/
    private var _end:Dynamic;

    /**
        progress function to call on loader events
    **/
    private var _pr:Dynamic;

    /**
        single-use loader?
    **/
    private var _single:Bool;

    /**
        current load mode
    **/
    private var _mode:Int = 0;

    /**
        key to decrypt loaded content
    **/
    private var _key:String = null;

    /**
        secret to decrypt loaded content
    **/
    private var _secret:Bytes = null;

    /**
        last loaded url
    **/
    public var url:String = '';

    /**
        binary data loaded
    **/
    public var binary:ByteArray = null;

    /**
        raw text loaded
    **/
    public var rawtext:String = null;

    /**
        parsed json content loaded
    **/
    public var json:Dynamic = null;

    /**
        parsed json into map
    **/
    public var map:Map<String, Dynamic> = null;

    /**
        extra information to hold
    **/
    public var extra:Dynamic = null;


    /**
        Creator.
        @param  single  single-use loader?
        @param  url the URL to access (null to just create the loader and wait for the request)
        @param  method  the request method (POST/GET)
        @param  params  request parameters (null for none)
        @param  mode    response processing mode
        @param  ac  a listener method (null for none, must receive two parameters: bool => operation successful?, DataLoader => reference to this loader)
        @param  pr  progress information callback
        @param  key a key to decrypt loaded content (null to ignore)
        @param  secret  secret bytes to decrypt loaded content (null to ignore)
        @param  end method to call juste before the callback action
        @param  extra   extra information to hold at the object
        @param  timeout time in miliseconds to wait for the response (0 for os default)
    **/
    public function new(single:Bool = false, url:String = null, method:String = 'POST', params:Map<String, Dynamic> = null, mode:Int = DataLoader.MODEBINARY, ac:Dynamic = null, pr:Dynamic = null, key:String = null, secret:Bytes = null, end:Dynamic = null, extra:Dynamic = null, timeout:Int = 0) {
        super();

        // creating the loader
        this._loader = new URLLoader();
        this._loader.addEventListener(Event.COMPLETE, onLoaderComplete);
        this._loader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError);
        this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityError);
        this._loader.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress);

        // single use?
        this._single = single;

        // request right now?
        if (url != null) this.load(url, method, params, mode, ac, pr, key, secret, end, extra, timeout);
    }

    /**
        Sets a listener function (must receive two parameters: bool => operation successful?, DataLoader => reference to this loader).
        @param  ac  the listener
    **/
    public function setAction(ac:Dynamic):Void {
        this._ac = ac;
    }

    /**
        Loads a content form a URL.
        @param  url the URL to access
        @param  method  the request method (POST/GET)
        @param  params  request parameters (null for none)
        @param  mode    response processing mode
        @param  ac  a listener method (null for none, must receive two parameters: bool => operation successful?, DataLoader => reference to this loader)
        @param  pr  progress information callback
        @param  key a key to decrypt loaded content (null to ignore)
        @param  secret  secret bytes to decrypt loaded content (null to ignore)
        @param  end method to call juste before the callback action
        @param  extra   extra information to hold at the object
        @param  timeout time in miliseconds to wait for the response (0 for os default)
    **/
    public function load(url:String, method:String = 'POST', params:Map<String, Dynamic> = null, mode:Int = DataLoader.MODEBINARY, ac:Dynamic = null, pr:Dynamic = null, key:String = null, secret:Bytes = null, end:Dynamic = null, extra:Dynamic = null, timeout:Int = 0):Void {
        // setting mode
        switch (mode) {
            case DataLoader.MODETEXT:
                this._mode = DataLoader.MODETEXT;
                this._loader.dataFormat = URLLoaderDataFormat.TEXT;
            case DataLoader.MODEJSON:
                this._mode = DataLoader.MODEJSON;
                this._loader.dataFormat = URLLoaderDataFormat.TEXT;
            case DataLoader.MODEMAP:
                this._mode = DataLoader.MODEMAP;
                this._loader.dataFormat = URLLoaderDataFormat.TEXT;
            case DataLoader.MODEBINTXT:
                this._mode = DataLoader.MODEBINTXT;
                this._loader.dataFormat = URLLoaderDataFormat.BINARY;
            case DataLoader.MODEBINMAP:
                this._mode = DataLoader.MODEBINMAP;
                this._loader.dataFormat = URLLoaderDataFormat.BINARY;
            default:
                this._mode = DataLoader.MODEBINARY;
                this._loader.dataFormat = URLLoaderDataFormat.BINARY;
        }
        // listener methods?
        this._end = end;
        this._ac = ac;
        this._pr = pr;
        // extra information
        this.extra = extra;
        // decryption data
        if ((key != null) && (secret != null)) {
            this._key = key;
            this._secret = secret;
        } else {
            this._key = null;
            this._secret = null;
        }
        // prepare parameters
        var variables:URLVariables = new URLVariables();
        if (params != null) {
            for (name in params.keys()) {
                Reflect.setField(variables, name, params[name]);
            }
        }
        // prepare request
        var req:URLRequest = new URLRequest(url);
        req.data = variables;
        req.method = method;
        if (timeout > 0) req.idleTimeout = timeout;
        // load content
        this.url = url;
        this._loader.load(req);
    }

    /**
        Cancel current load operation.
    **/
    public function cancel():Void {
        if (this._loader != null) {
            try {
                this._loader.close();
            } catch (e) { }
            if (this._end != null) this._end();
            if (this._single) this.kill();
        }
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this._loader.removeEventListener(Event.COMPLETE, onLoaderComplete);
        this._loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError);
        this._loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityError);
        this._loader.removeEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
        try { this._loader.close(); } catch (e) { }
        this._loader = null;
        this._ac = null;
        this._pr = null;
        this._key = null;
        this._secret = null;
        this.binary = null;
        this.rawtext = null;
        this.json = null;
        this.map = null;
        this.url = null;
        this._end = null;
        this.extra = null;
    }

    /**
        Gets the final loaded text (decrypted if encryption was expected).
        @param  loaded  the laoded text
        @return the loaded text (decrypted if encrypted)
    **/
    private function finalText(loaded:String):String {
        if (this._key != null) {
            return (StringStatic.decrypt(loaded, this._key, this._secret));
        } else {
            return (loaded);
        }
    }

    /** EVENTS **/

    /**
        Content received.
    **/
    private function onLoaderComplete(evt:Event):Void {
        // processing the response
        this.binary = null;
        this.rawtext = null;
        this.json = null;
        this.map = null;
        var ok:Bool = false;
        switch (this._mode) {
            case DataLoader.MODETEXT:
                this.rawtext = this.finalText(this._loader.data);
                ok = true;
            case DataLoader.MODEJSON:
                this.rawtext = this.finalText(this._loader.data);
                var js:Dynamic = StringStatic.jsonParse(this.rawtext);
                if (js == false) {
                    ok = false;
                    this.rawtext = null;
                } else {
                    this.json = js;
                    ok = true;
                }
            case DataLoader.MODEMAP:
                this.rawtext = this.finalText(this._loader.data);
                var js:Dynamic = StringStatic.jsonParse(this.rawtext);
                if (js == false) {
                    ok = false;
                    this.rawtext = null;
                } else {
                    this.json = js;
                    this.map = [ ];
                    for (k in Reflect.fields(js)) this.map[k] = Reflect.field(js, k);
                    ok = true;
                }
            case DataLoader.MODEBINTXT:
                if (this._key == null) {
                    ok = false;
                } else {
                    this.binary = this._loader.data;
                    this.rawtext = this.finalText(Base64.encode(this.binary));
                    ok = true;
                }
            case DataLoader.MODEBINMAP:
                if (this._key == null) {
                    ok = false;
                } else {
                    this.binary = this._loader.data;
                    this.rawtext = this.finalText(Base64.encode(this.binary));
                    var js:Dynamic = StringStatic.jsonParse(this.rawtext);
                    if (js == false) {
                        ok = false;
                        this.rawtext = null;
                        this.binary = null;
                    } else {
                        this.json = js;
                        this.map = [ ];
                        for (k in Reflect.fields(js)) this.map[k] = Reflect.field(js, k);
                        ok = true;
                    }
                }
            default:
                this.binary = this._loader.data;
                ok = true;
        }
        if (this._end != null) this._end();
        // warn listeners
        if (this._ac != null) {
            if (ok) {
                this._ac(true, this);
            } else {

trace ('erro ws', this._loader.data);

                this._ac(false, null);
            }
        }
        this.dispatchEvent(evt);
        // kill object?
        if (this._single) this.kill();
    }

    /**
        IO error on access.
    **/
    private function onLoaderIOError(evt:IOErrorEvent):Void {
        if (this._end != null) this._end();
        if (this._ac != null) this._ac(false, null);
        this.dispatchEvent(evt);
        if (this._single) this.kill();
    }

    /**
        Security error on access.
    **/
    private function onLoaderSecurityError(evt:SecurityErrorEvent):Void {
        if (this._end != null) this._end();
        if (this._ac != null) this._ac(false, null);
        this.dispatchEvent(evt);
        if (this._single) this.kill();
    }

    /**
       Load progress.
    **/
    private function onLoaderProgress(evt:ProgressEvent):Void {
        if (this._pr != null) this._pr(evt.bytesLoaded, evt.bytesTotal);
        this.dispatchEvent(evt);
    }
}