package com.tilbuci.ws;

/** OPENFL **/
import openfl.net.URLVariables;
import openfl.net.URLRequest;
import openfl.events.EventDispatcher;
import openfl.events.Event;
import openfl.Lib;

/** TILBUCI **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.DataLoader;
import com.tilbuci.data.Global;
import com.tilbuci.ui.component.Intercating.Interacting;

class Webservice extends EventDispatcher {

    /**
        base url for ws request
    **/
    public var url(get, null):String;
    private var _url:String;
    private function get_url():String { return (this._url); } 

    /**
        current user
    **/
    public var user(get, null):String;
    private var _user:String = 'system';
    private function get_user():String { return (this._user); } 

    /**
        current user access key
    **/
    public var key(get, null):String;
    private var _key:String = '';
    private function get_key():String { return (this._key); } 

    /**
        current use access level
    **/
    public var level(get, null):Int;
    private var _level:Int = -1;
    private function get_level():Int { return (this._level); }

    /**
        interaction display
    **/
    private var _interact:Interacting;

    /**
        Constructor.
        @param  ws  url to the webservice
    **/
    public function new(ws:String) {
        super();
        this._url = ws;
        this._interact = new Interacting();
    }

    /**
        Sets the current user.
        @param  us  the user name/email
        @param  key the user current access key
        @param  lv  the user access level
    **/
    public function setUser(us:String, key:String, lv:Int):Void {
        this._user = us;
        this._key = key;
        this._level = lv;
        Global.userLevel = lv;
    }

    /**
        Closes user connection.
    **/
    public function logout():Void {
        this._user = 'system';
        this._key = '';
        this._level = -1;
        Global.userLevel = -1;
    }

    /**
        Sends a request.
        @param  ac  the request action
        @param  req the request data
        @param  callback    a function to call after getting a response that must accept two parameters - bool: was the request successful, Map<String,String>: received data (null on error)
        @param  timeout time in miliseconds to wait for the response (0 for os default)
        @param  showInteract    show the server interaction animation?
    **/
    public function send(ac:String, req:Map<String, Dynamic>, callback:Dynamic, timeout:Int = 0, showInteract:Bool = true):Void {
        var txt:String = StringStatic.jsonStringify(req);
        new DataLoader(true, this._url, 'POST', [
            'r' => txt, 
            's' => StringStatic.md5(this._key + txt), 
            'u' => this._user, 
            'a' => ac
        ], DataLoader.MODEMAP, callback, null, null, null, onEnd, null, timeout);
        if (showInteract) this._interact.start();
    }

    /**
        Starts a file download.
        @param  req download request information
    **/
    public function download(req:Map<String, String>):Void {
        var urldw:String = StringTools.replace(this._url, '/ws', '/download');
        var variables:URLVariables = new URLVariables();
        for (k in req.keys()) Reflect.setField(variables, k, req[k]);
        Reflect.setField(variables, 'a', 'download');
        var request:URLRequest = new URLRequest(urldw);
        request.data = variables;
        request.method = 'GET';
        Lib.getURL(request);
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this._url = null;
        this._user = null;
        this._key = null;
    }

    /**
        Hides the server interactiong feedback.
    **/
    private function onEnd():Void {
        this._interact.stop();
    }

}