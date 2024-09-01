package com.tilbuci.data;

/** OPENFL **/
import openfl.events.EventDispatcher;
import openfl.Assets;

/** TILBUCI **/
import com.tilbuci.statictools.StringStatic;

/**
    Multi-language text.
**/
class Language extends EventDispatcher {

    /** PRIVATE VARS **/

    /**
        language data ok?
    **/
    public var ok(get, null):Bool;
    private function get_ok():Bool { return (this._ok); }
    private var _ok:Bool = false;

    /**
        current language
    **/
    public var current(get, null):String;
    private function get_current():String { return (this._current); }
    private var _current:String = '';

    /**
        loaded texts
    **/
    private var _texts:Map<String, String> = [ ];

    /**
        Constructor.
    **/
    public function new() {
        super();
        
        // loading the default language file
        #if tilbuciplayer
            this._ok = true;
        #else
            this._ok = this.load('langDefault');
        #end
    }

    /**
        Loads a language file.
        @param  lang   the language asset id
        @return was the language file loaded?
    **/
    public function load(lang:String):Bool {
        var ok:Bool = false;
        var str:String = Assets.getText(lang);
        var file:Dynamic = StringStatic.jsonParse(str);
        if (file == false) {
            ok = false;
        } else {
            for (n in Reflect.fields(file)) {
                this._texts[n] = Reflect.field(file, n);
			}
            this._current = lang;
            ok = true;
        }
        return (ok);
    }

    /**
        Gets a text value from currently loaded language.
    **/
    public function get(name:String):String {
        if (this._texts.exists(name)) {
            return(this._texts[name]);
        } else {
            return('');
        }
    }

    /**
        Releases resources used by object.
    **/
    public function kill():Void {
        for (name in this._texts.keys()) this._texts.remove(name);
        this._texts = null;
    }
}