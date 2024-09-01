package com.tilbuci.ws;

/** OPENFL **/
import com.tilbuci.data.GlobalPlayer;
import openfl.events.EventDispatcher;
import openfl.events.Event;

/** TILBUCI **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.DataLoader;

class WebserviceP extends EventDispatcher {

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
        current user grops key
    **/
    public var groups(get, null):Array<String>;
    private var _groups:Array<String> = [ ];
    private function get_groups():Array<String> { return (this._groups); } 

    /**
        Constructor.
        @param  ws  url to the webservice
        @param  key player key
    **/
    public function new(ws:String, key:String) {
        super();
        this._url = ws;
        this._user = 'system';
        this._key = key;
        this._groups = [ ];
    }

    /**
        Sends a request.
        @param  ac  the request action
        @param  req the request data
        @param  callback    a function to call after getting a response that must accept two parameters - bool: was the request successful, Map<String,String>: received data (null on error)
        @param  extra   extra information to hold at the object
        @return webservice available to send request?
    **/
    public function send(ac:String, req:Map<String, Dynamic>, callback:Dynamic, extra:Dynamic = null):Bool {
        if (GlobalPlayer.server) {
            var txt:String = StringStatic.jsonStringify(req);
            new DataLoader(true, this._url, 'POST', [
                'r' => txt, 
                's' => StringStatic.md5(this._key + txt), 
                'u' => this._user, 
                'a' => ac
            ], DataLoader.MODEMAP, callback, null, null, null, null, extra);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Sends a key request to an e-mail address.
        @param  email   the e-mail address
        @param  title   the message title
        @param  text   the message text
        @param  sender   the message sender name
    **/
    public function loginVisitor(email:String, title:String, text:String, sender:String, callback:Dynamic):Bool {
        return (this.send(
            'System/Visitor', 
            [
                'email' => email, 
                'title' => title, 
                'text' => text, 
                'sender' => sender
            ], 
            callback
        ));
    }

    /**
        Checks the key request of an e-mail address.
        @param  email   the e-mail address
        @param  code   the code to check
    **/
    public function checkVisitorCode(email:String, code:String, callback:Dynamic):Bool {
        return (this.send(
            'System/VisitorCode', 
            [
                'email' => email, 
                'code' => code
            ], 
            callback
        ));
    }

    /**
        Saves visitor data to the server.
        @param  name    the save name
        @param  values  the values to save
        @param  callback    function to call on return
        @return request sent?
    **/
    public function dataSave(name:String, values:Array<Dynamic>, callback:Dynamic):Bool {
        return (this.send(
            'Visitor/DataSave',
            [
                'name' => name, 
                'values' => StringStatic.jsonStringify(values), 
                'movie' => GlobalPlayer.movie.mvId
            ],
            callback
        ));
    }

    /**
        Loads visitor data from the server.
        @param  name    the save name
        @param  callback    function to call on return
        @return request sent?
    **/
    public function dataLoad(name:String, callback:Dynamic):Bool {
        return (this.send(
            'Visitor/DataLoad',
            [
                'name' => name, 
                'movie' => GlobalPlayer.movie.mvId
            ],
            callback
        ));
    }

    /**
        Saves visitor current state to the server.
        @param  values  the values to save
        @param  quick   quick state?
        @param  about   about the state
        @param  callback    function to call on return
        @return request sent?
    **/
    public function stateSave(values:Array<Dynamic>, quick:Bool, about:String, callback:Dynamic):Bool {
        return (this.send(
            'Visitor/StateSave',
            [
                'values' => StringStatic.jsonStringify(values), 
                'movie' => GlobalPlayer.movie.mvId, 
                'quick' => quick, 
                'scene' => GlobalPlayer.movie.scId, 
                'about' => about
            ],
            callback
        ));
    }

    /**
        Loads visitor data from the server.
        @param  name    the save name
        @param  callback    function to call on return
        @return request sent?
    **/
    public function stateLoad(id:String, quick:Bool, callback:Dynamic):Bool {
        return (this.send(
            'Visitor/StateLoad',
            [
                'id' => id, 
                'quick' => quick, 
                'movie' => GlobalPlayer.movie.mvId
            ],
            callback
        ));
    }

    /**
        loads a lis of saved states for current visitor/movie
        @param  callback    function to call on return
        @return request sent?
    **/
    public function stateList(dateformat:String, callback:Dynamic):Bool {
        return (this.send(
            'Visitor/StateList',
            [
                'format' => dateformat, 
                'movie' => GlobalPlayer.movie.mvId
            ],
            callback
        ));
    }

    /**
        Loads a scene information.
        @param  id  the scene id
        @param  callback    function to call on return
        @return request sent?
    **/
    public function loadScene(id:String, callback:Dynamic):Bool {
        return (this.send(
            'Visitor/LoadScene',
            [
                'id' => id, 
                'movie' => GlobalPlayer.movie.mvId, 
                'visitor' => this._user, 
            ],
            callback
        ));
    }

    /**
        Sets the current user.
        @param  us  user e-mail
        @param  key ws key for user
    **/
    public function setUser(us:String, key:String, groups:Array<String>):Void {
        this._user = us;
        this._key = key;
        this._groups = groups;
    }

    /**
        Clears current user login.
    **/
    public function clearUser():Void {
        this._user = 'system';
        this._key = '';
        this._groups = [ ];
    }

    /**
        Is there a logged user?
        @return user logged?
    **/
    public function userLogged():Bool {
        return ((this._user != 'system') && (this._user != ''));
    }

    /**
        Gets the current user name/email.
        @return the user email or empty string if no one is logged
    **/
    public function getUser():String {
        if (this.userLogged()) {
            return (this._user);
        } else {
            return('');
        }
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this._url = null;
        this._user = null;
        this._key = null;
        while (this._groups.length > 0) this._groups.shift();
        this._groups = null;
    }

}