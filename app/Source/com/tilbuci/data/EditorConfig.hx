/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.data;

/** OPENFL **/
import openfl.events.EventDispatcher;

/** TILBUCI **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.def.InterfaceLang;
import com.tilbuci.data.DataLoader;

/**
    Tilbuci editor configuration.
**/
class EditorConfig extends EventDispatcher {

    /**
        configuration loaded?
    **/
    public var loaded(get, null):Bool;
    private var _loaded:Bool = false;
    private function get_loaded():Bool { return (this._loaded); }

    /**
        base url
    **/
    public var base(get, null):String;
    private var _base:String = '';
    private function get_base():String { return (this._base); }

    /**
        player url
    **/
    public var player(get, null):String;
    private var _player:String = '';
    private function get_player():String { return (this._player); }

    /**
        webservice url
    **/
    public var ws(get, null):String;
    private var _ws:String = '';
    private function get_ws():String { return (this._ws); }

    /**
        font url
    **/
    public var font(get, null):String;
    private var _font:String = '';
    private function get_font():String { return (this._font); }

    /**
        available languages
    **/
    public var language(get, null):Array<InterfaceLang>;
    private var _language:Array<InterfaceLang> = [ ];
    private function get_language():Array<InterfaceLang> { return (this._language); }


    /**
        add date to uploaded files?
    **/
    public var dateFile(get, null):Bool;
    private var _dateFile:Bool = true;
    private function get_dateFile():Bool { return (this._dateFile); }

    /**
        callback method for config load - must accept one bool parameter: loaded successfully?
    **/
    private var _callback:Dynamic;

    /**
        Constructor.
    **/
    public function new(path:String, ac:Dynamic, nocache:Bool) {
        super();
        var cache:Map<String, Dynamic> = null;
        this._callback = ac;
        if (nocache) cache = [ 'rand' => Math.ceil(Math.random()*10000) ];
        new DataLoader(true, path, 'GET', cache, DataLoader.MODEJSON, this.dataLoaded);
    }

    /**
        Releases resources used by object.
    **/
    public function kill():Void {
        this._ws = null;
        this._base = null;
        this._font = null;
        if (this._language != null) while (this._language.length > 0) this._language.pop();
        this._language = null;
        this._callback = null;
    }

    /** EVENTS **/

    /**
        Config file was just loaded.
        @param  ok  loaded successfully?
        @param  data    the processed data
    **/
    private function dataLoaded(ok:Bool, ld:DataLoader):Void {
        this._loaded = ok;
        if (!ok) {
            this._callback(false);
        } else {
            if (!Reflect.hasField(ld.json, 'base')) this._loaded = false;
            if (this._loaded && !Reflect.hasField(ld.json, 'player')) this._loaded = false; 
            if (this._loaded && !Reflect.hasField(ld.json, 'ws')) this._loaded = false; 
            if (this._loaded && !Reflect.hasField(ld.json, 'font')) this._loaded = false; 
            if (this._loaded && !Reflect.hasField(ld.json, 'language')) {
                this._language = [ new InterfaceLang('English', 'default') ];
            } else  {
                this._language = ld.json.language;
            }
            // prepare data
            if (this._loaded) {
                this._base = StringStatic.slashURL(ld.json.base);
                this._player = StringStatic.slashURL(ld.json.player);
                this._ws = StringStatic.slashURL(ld.json.ws);
                this._font = StringStatic.slashURL(ld.json.font);
            }
            // warning listeners
            this._callback(this._loaded);
        }
        this._callback = null;
    }
}