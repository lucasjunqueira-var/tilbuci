package com.tilbuci.script;

/** TILBUCI **/
import openfl.external.ExternalInterface;
import openfl.net.URLRequest;
import com.tilbuci.data.Global;
import haxe.macro.Expr.Catch;
import haxe.Timer;
import openfl.net.SharedObject;
import com.tilbuci.data.DataLoader;
import com.tilbuci.plugin.Plugin.ParsedInt;
import com.tilbuci.plugin.Plugin.ParsedFloat;
import com.tilbuci.plugin.Plugin.ParsedString;
import com.tilbuci.plugin.Plugin.ParsedBool;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.statictools.StringStatic;
import openfl.display.StageDisplayState;
import openfl.Lib;

class ScriptParser {

    /**
        string variables
    **/
    private var _strings:Map<String, String> = [ ];

    /**
        strings.json content
    **/
    private var _stringsjson:Map<String, Map<String, String>> = [ ];

    /**
        current strings group
    **/
    private var _jsongropup:String = '';

    /**
        automatic replace strings
    **/
    private var _replacestr:Map<String, String> = [ ];

    /**
        automatic replace file names
    **/
    private var _replacefile:Map<String, String> = [ ];

    /**
        action timers
    **/
    private var _timers:Map<String, ActionTimer> = [ ];

    /**
        float variables
    **/
    private var _floats:Map<String, Float> = [ ];

    /**
        int variables
    **/
    private var _ints:Map<String, Int> = [ ];

    /**
        boolean variables
    **/
    private var _bools:Map<String, Bool> = [ ];

    /**
        list of available actions
    **/
    public var available:Array<ActionGroup> = [ ];

    /**
        list of available global vars
    **/
    public var globalAvailable:Array<GlobalGroup> = [ ];

    /**
        custom event send function
    **/
    public var eventSend:Dynamic = null;

    /**
        ok/confirm/success actions on hold
    **/
    private var _acOk:Dynamic;

    /**
        error/deny/failure actions on hold
    **/
    private var _acError:Dynamic;

    /**
        Constructor.
    **/
    public function new() { }

    /**
        Gets a variable type array reference.
    **/
    public function getVarRef(type:String):Dynamic {
        switch (type) {
            case 'string': return (this._strings);
            case 'float': return (this._floats);
            case 'int': return (this._ints);
            case 'bool': return (this._bools);
            default: return (null);
        }
    }

    /**
        Adds an action group description.
        @param  ag  action group descriptor
    **/
    public function addAvailableGroup(ag:ActionGroup):Void {
        this.available.push(ag);
    }

    /**
        Adds a global variable group description.
        @param  gg  group descriptor
    **/
    public function addAvailableGlobal(gg:GlobalGroup):Void {
        this.globalAvailable.push(gg);
    }

    /**
        Releases resouces used by the object.
    **/
    public function kill():Void {
        for (k in this._strings.keys()) this._strings.remove(k);
        for (k in this._floats.keys()) this._floats.remove(k);
        for (k in this._ints.keys()) this._ints.remove(k);
        for (k in this._bools.keys()) this._bools.remove(k);
        this._strings = null;
        this._floats = null;
        this._ints = null;
        this._bools = null;
        while (this.available.length > 0) {
            var ag:ActionGroup = this.available.shift();
            while (ag.a.length > 0) {
                var ac:ActionDescriptor = ag.a.shift();
                while (ac.p.length > 0) {
                    var pr:ParamDescriptor = ac.p.shift();
                    pr = null;
                }
                ac = null;
            }
            ag = null;
        }
        this.available = null;
        while (this.globalAvailable.length > 0) {
            var vg:GlobalGroup = this.globalAvailable.shift();
            while (vg.v.length > 0) vg.v.shift();
            vg = null;
        }
        this.globalAvailable = null;
    }

    /**
        Clears registered variables.
        @param  what    the type of variable to clear (empty string for all)
        @return always true
    **/
    public function clearVars(what:String = ''):Bool {
        switch (what) {
            case 'strings': for (k in this._strings.keys()) this._strings.remove(k);
            case 'bools': for (k in this._bools.keys()) this._strings.remove(k);
            case 'ints': for (k in this._ints.keys()) this._ints.remove(k);
            case 'floats': for (k in this._floats.keys()) this._floats.remove(k);
            default:
                for (k in this._strings.keys()) this._strings.remove(k);
                for (k in this._floats.keys()) this._floats.remove(k);
                for (k in this._ints.keys()) this._ints.remove(k);
                for (k in this._bools.keys()) this._bools.remove(k);
        }
        return (true);
    }

    /**
        Loads current movie strings.json file.
    **/
    public function loadStringsJson():Void {
        this._stringsjson = [ ];
        this._jsongropup = ''; 
        if (GlobalPlayer.nocache) {
            new DataLoader(true, (GlobalPlayer.base + 'movie/' + GlobalPlayer.movie.mvId + '.movie/strings.json'), 'GET', [ 'rand' => Date.now().getTime() ], DataLoader.MODEJSON, onStringsJSON);
        } else {
            new DataLoader(true, (GlobalPlayer.base + 'movie/' + GlobalPlayer.movie.mvId + '.movie/strings.json'), 'GET', [ ], DataLoader.MODEJSON, onStringsJSON);
        }
    }

    /**
        Strings.json file loaded.
        @param  ok  correctly loaded?
        @param  ld  loader reference
    **/
    private function onStringsJSON(ok:Bool, ld:DataLoader = null):Void {
        if (ok) {
            for (k in Reflect.fields(ld.json)) {
                var kdata:Dynamic = Reflect.field(ld.json, k);
                var mapk:Map<String, String> = [ ];
                for (k2 in Reflect.fields(kdata)) {
                    mapk['$' + k2] = Reflect.field(kdata, k2);
                }
                this._stringsjson[k] = mapk;
            }
        }
    }

    /**
        Returns the value of a string variable.
        @param  name    the variable name
        @return the variable name or empty string if not found
    **/
    public function getString(name):String {
        if (this._strings.exists(name)) {
            return (this._strings[name]);
        } else {
            return ('');
        }
    }

    /**
        Sets a string variable value.
        @param  name    the variable name
        @param  value   the new value
        @return always true
    **/
    public function setString(name:String, value:String):Bool {
        this._strings[this.parseString(name)] = this.parseString(value);
        return (true);
    }

    /**
        Clears a string variable.
        @param  name    the variable name
        @return always true
    **/
    public function clearString(name:String):Bool {
        if (this._strings.exists(this.parseString(name))) {
            this._strings.remove(this.parseString(name));
        }
        return (true);
    }

    /**
        Concatenates two strings.
        @param  name    the variable name to receive the result
        @param  str1    the first string
        @param  str2    the second string
        @return always true
    **/
    public function concatString(name:String, str1:String, str2:String):Bool {
        this._strings[this.parseString(name)] = this.parseString(str1) + this.parseString(str2);
        return (true);
    }

    /**
        Returns the value of a float variable.
        @param  name    the variable name
        @return the variable name or 0.0 if not found
    **/
    public function getFloat(name):Float {
        if (this._floats.exists(name)) {
            return (this._floats[name]);
        } else {
            return (0.0);
        }
    }

    /**
        Clears a float variable.
        @param  name    the variable name
        @return always true
    **/
    public function clearFloat(name:String):Bool {
        if (this._floats.exists(this.parseString(name))) {
            this._floats.remove(this.parseString(name));
        }
        return (true);
    }

    /**
        Sets the value of a float variable.
        @param  name    the variable name
        @param  value   the float value or a reference to a variable (starting with "#")
        @return always true
    **/
    public function setFloat(name:String, value:Dynamic):Bool {
        name = this.parseString(name);
        if ((Type.typeof(value) == TFloat) || (Type.typeof(value) == TInt)) {
            this._floats[name] = value;
        } else {
            this._floats[name] = this.parseFloat(value);
        }
        return (true);
    }

    /**
        Returns the value of an int variable.
        @param  name    the variable name
        @return the variable name or 0 if not found
    **/
    public function getInt(name):Int {
        if (this._ints.exists(name)) {
            return (this._ints[name]);
        } else {
            return (0);
        }
    }

    /**
        Clears an int variable.
        @param  name    the variable name
        @return always true
    **/
    public function clearInt(name:String):Bool {
        if (this._ints.exists(this.parseString(name))) {
            this._ints.remove(this.parseString(name));
        }
        return (true);
    }

    /**
        Sets the value of am int variable.
        @param  name    the variable name
        @param  value   the int value or a reference to a variable (starting with "#")
        @return always true
    **/
    public function setInt(name:String, value:Dynamic):Bool {
        name = this.parseString(name);
        if (Type.typeof(value) == TInt) {
            this._ints[name] = value;
        } else if (Type.typeof(value) == TFloat) {
            this._ints[name] = Math.round(value);
        } else {
            this._ints[name] = this.parseInt(value);
        }
        return (true);
    }

    /**
        Returns the value of a bool variable.
        @param  name    the variable name
        @return the variable name or false if not found
    **/
    public function getBool(name):Bool {
        if (this._bools.exists(name)) {
            return (this._bools[name]);
        } else {
            return (false);
        }
    }

    /**
        Clears a bool variable.
        @param  name    the variable name
        @return always true
    **/
    public function clearBool(name:String):Bool {
        if (this._bools.exists(this.parseString(name))) {
            this._bools.remove(this.parseString(name));
        }
        return (true);
    }

    /**
        Sets the value of a boolean variable.
        @param  name    the variable name
        @param  value   the boolean value or a reference to a variable (starting with "?" or "true"/"false" strings)
        @param  invert  invert the boolean value to set?
        @return always true
    **/
    public function setBool(name:String, value:Dynamic, invert:Bool = false):Bool {
        name = this.parseString(name);
        if (Type.typeof(value) == TBool) {
            if (invert) this._bools[name] = !value;
                else this._bools[name] = value;
        } else {
            if (invert) this._bools[name] = !this.parseBool(value);
                else this._bools[name] = this.parseBool(value);
        }
        return (true);
    }

    /**
        Runs actions on a JSON.
        @param  src json-encoded string or parsed object
        @param  parsed  is the first param an already-parsed json?
        @return were the action completed?
    **/
    public function run(scr:Dynamic, parsed:Bool = false):Bool {
        // parse json     
        var json:Dynamic;
        if (parsed) {
            if (scr == null) {
                return (true);
            } else {
                json = scr;
            }
        } else {
            json = StringStatic.jsonParse(scr);
        }
        if (json == false) {
            // corrupted json
            return (false);
        } else {
            // array of commands?
            if (Type.typeof(json) != TObject) {
                var arcmd:Array<Dynamic> = [ ];
                var ok:Bool = false;
                try {
                    arcmd = cast (json, Array<Dynamic>);
                    ok = true;
                } catch (e) { ok = false; }
                if (ok) {
                    for (obj in arcmd) if (!this.run(obj, true)) ok = false;
                    return (ok);
                } else {
                    return (false);
                }
            } else {
                return (this.exec(json));
            }
        }
    }

    /**
        Executes an action.
        @param  inf the action information
        @return was the action really executed?
    **/
    private function exec(inf:Dynamic):Bool {
        // required fields sent?
        if (Reflect.hasField(inf, 'ac') && Reflect.hasField(inf, 'param') && (Type.typeof(Reflect.field(inf, 'param')) != TObject)) {
            // prepare params
            var param:Array<Dynamic> = [ ];
            var ok:Bool = false;
            try {
                param = cast (Reflect.field(inf, 'param'), Array<Dynamic>);
                ok = true;
            } catch (e) { ok = false; }
            if (!ok) {
                return (false);
            } else {
                // run action
                switch (Reflect.field(inf, 'ac')) {

                    // system actions
                    case 'system.fullscreen':
                        if (GlobalPlayer.area.stage != null) {
                            if (GlobalPlayer.area.stage.displayState == StageDisplayState.NORMAL) {
                                GlobalPlayer.area.stage.displayState = StageDisplayState.FULL_SCREEN;
                            } else {
                                GlobalPlayer.area.stage.displayState = StageDisplayState.NORMAL;
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'system.logout':
                        GlobalPlayer.ws.clearUser();
                           return (true);
                    case 'system.openurl':
                        if (param.length > 0) {
                            var req:URLRequest = new URLRequest(param[0]);
                            req.method = 'GET';
                            Lib.getURL(req);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'system.copytext':
                        if (param.length > 0) {
                            return (GlobalPlayer.copyText(this.parseString(param[0])));
                        } else {
                            return (false);
                        }
                    case 'system.sendevent':
                        if (this.eventSend == null) {
                            return (false);
                        } else {
                            var map:Map<String, String> = [ ];
                            for (i in 0...param.length) map['v' + i] = this.parseString(param[i]);
                            this.eventSend(map);
                            return (true);
                        }
                    case 'system.openembed':
                        if (param.length > 0) {
                            #if tilbuciplayer
                                ExternEmbed.embed_place('movie/' + GlobalPlayer.movie.mvId + '.movie/media/embed/' + this.parseString(param[0]) + '/index.html');
                            #else
                                ExternEmbed.embed_place('../movie/' + GlobalPlayer.movie.mvId + '.movie/media/embed/' + this.parseString(param[0]) + '/index.html');
                            #end                            
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'system.quit':
                        return (GlobalPlayer.appQuit());

                    
                    // movie actions
                    case 'movie.load':
                        GlobalPlayer.movie.loadMovie(this.parseString(param[0]));
                        return (true);

                    // scene and keyframe actions
                    case 'scene.load':
                        return(GlobalPlayer.movie.loadScene(this.parseString(param[0])));
                    case 'scene.playpause':
                        GlobalPlayer.area.playPause();
                        return(true);
                    case 'scene.play':
                        GlobalPlayer.area.play();
                        return(true);
                    case 'scene.pause':
                        GlobalPlayer.area.pause();
                        return(true);
                    case 'scene.navigate':
                        if (param.length > 0) {
                            if (GlobalPlayer.movie.scene.navigation.exists(param[0])) {
                                if (GlobalPlayer.movie.scene.navigation[param[0]] != '') {
                                    return(GlobalPlayer.movie.loadScene(this.parseString(GlobalPlayer.movie.scene.navigation[param[0]])));
                                } else {
                                    return (false);
                                }
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }

                    // instance actions
                    case 'instance.setorder':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'order', this.parseInt(param[1]), this.parseInt(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'order', this.parseInt(param[1]), this.parseInt(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setx':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'x', this.parseFloat(param[1]), this.parseFloat(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'x', this.parseFloat(param[1]), this.parseFloat(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.sety':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'y', this.parseFloat(param[1]), this.parseFloat(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'y', this.parseFloat(param[1]), this.parseFloat(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setalpha':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'alpha', this.parseFloat(param[1]), this.parseFloat(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'alpha', this.parseFloat(param[1]), this.parseFloat(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setwidth':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'width', this.parseFloat(param[1]), this.parseFloat(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'width', this.parseFloat(param[1]), this.parseFloat(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setheight':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'height', this.parseFloat(param[1]), this.parseFloat(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'height', this.parseFloat(param[1]), this.parseFloat(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setrotation':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'rotation', this.parseFloat(param[1]), this.parseFloat(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'rotation', this.parseFloat(param[1]), this.parseFloat(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setvisible':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'visible', this.parseBool(param[1]), this.parseBool(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'visible', this.parseBool(param[1]), this.parseBool(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setcolor':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'color', this.parseString(param[1]), this.parseString(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'color', this.parseString(param[1]), this.parseString(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setcoloralpha':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'colorAlpha', this.parseFloat(param[1]), this.parseFloat(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'colorAlpha', this.parseFloat(param[1]), this.parseFloat(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setvolume':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'volume', this.parseFloat(param[1]), this.parseFloat(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'volume', this.parseFloat(param[1]), this.parseFloat(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setpan':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'pan', this.parseFloat(param[1]), this.parseFloat(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'pan', this.parseFloat(param[1]), this.parseFloat(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setfont':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textFont', this.parseString(param[1]), this.parseString(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textFont', this.parseString(param[1]), this.parseString(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setfontsize':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textSize', this.parseInt(param[1]), this.parseInt(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textSize', this.parseInt(param[1]), this.parseInt(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setfontcolor':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textColor', this.parseString(param[1]), this.parseString(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textColor', this.parseString(param[1]), this.parseString(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setfontbold':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textBold', this.parseBool(param[1]), this.parseBool(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textBold', this.parseBool(param[1]), this.parseBool(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setfontitalic':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textItalic', this.parseBool(param[1]), this.parseBool(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textItalic', this.parseBool(param[1]), this.parseBool(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setfontleading':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textLeading', this.parseInt(param[1]), this.parseInt(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textLeading', this.parseInt(param[1]), this.parseInt(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setfontspacing':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textSpacing', this.parseFloat(param[1]), this.parseFloat(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textSpacing', this.parseFloat(param[1]), this.parseFloat(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setfontbackground':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textBackground', this.parseString(param[1]), this.parseString(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textBackground', this.parseString(param[1]), this.parseString(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.setfontalign':
                        if (param.length == 2) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textAlign', this.parseString(param[1]), this.parseString(param[1])));
                        } else if (param.length >= 3) {
                            return (GlobalPlayer.area.setProperty(this.parseString(param[0]), 'textAlign', this.parseString(param[1]), this.parseString(param[2])));
                        } else {
                            return (false);
                        }
                    case 'instance.clearorder':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'order'));
                    case 'instance.clearx':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'x'));
                    case 'instance.cleary':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'y'));
                    case 'instance.clearalpha':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'alpha'));
                    case 'instance.clearwidth':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'width'));
                    case 'instance.clearheight':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'height'));
                    case 'instance.clearrotation':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'rotation'));
                    case 'instance.clearvisible':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'visible'));
                    case 'instance.clearcolor':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'color'));
                    case 'instance.clearcoloralpha':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'colorAlpha'));
                    case 'instance.clearvolume':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'volume'));
                    case 'instance.clearpan':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'pan'));
                    case 'instance.clearfont':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'textFont'));
                    case 'instance.clearfontsize':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'textSize'));
                    case 'instance.clearfontcolor':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'textColor'));
                    case 'instance.clearfontbold':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'textBold'));
                    case 'instance.clearfontitalic':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'textItalic'));
                    case 'instance.clearfontleading':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'textLeading'));
                    case 'instance.clearfontspacing':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'textSpacing'));
                    case 'instance.clearfontbackground':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'textBackground'));
                    case 'instance.clearfontalign':
                        return (GlobalPlayer.area.releaseProperty(this.parseString(param[0]), 'textAlign'));
                    case 'instance.clearall':
                        return (GlobalPlayer.area.releaseAllProperties(this.parseString(param[0])));
                    case 'instance.next':
                        return (GlobalPlayer.area.next(this.parseString(param[0])));
                    case 'instance.previous':
                        return (GlobalPlayer.area.previous(this.parseString(param[0])));
                    case 'instance.loadasset':
                        return (GlobalPlayer.area.loadAsset(this.parseString(param[0]), this.parseString(param[1])));
                    case 'instance.playpause':
                        return (GlobalPlayer.area.playPauseInstance(this.parseString(param[0])));
                    case 'instance.play':
                        return (GlobalPlayer.area.playInstance(this.parseString(param[0])));
                    case 'instance.pause':
                        return (GlobalPlayer.area.pauseInstance(this.parseString(param[0])));
                    case 'instance.seek':
                        return (GlobalPlayer.area.instanceSeek(this.parseString(param[0]), this.parseInt(param[1])));
                    case 'instance.stop':
                        return (GlobalPlayer.area.stopInstance(this.parseString(param[0])));
                    case 'instance.scrollup':
                        return (GlobalPlayer.area.textScroll(this.parseString(param[0]), -1));
                    case 'instance.scrolldown':
                        return (GlobalPlayer.area.textScroll(this.parseString(param[0]), 1));
                    case 'instance.scrolltop':
                        return (GlobalPlayer.area.textScroll(this.parseString(param[0]), 0));
                    case 'instance.scrollbottom':
                        return (GlobalPlayer.area.textScroll(this.parseString(param[0]), 2));
                    case 'instance.setparagraph':
                        return (GlobalPlayer.area.setText(this.parseString(param[0]), this.parseString(param[1])));

                    // animation
                    case 'animation.method':
                        GlobalPlayer.area.setAnimation(this.parseString(param[0]));
                        return (true);

                    // text
                    case 'css.set':
                        GlobalPlayer.style.parseCSS(this.parseString(param[0]));
                        return (true);
                    case 'css.clear':
                        GlobalPlayer.style.clear();
                        return (true);

                    // named actions
                    case 'run':
                        if (GlobalPlayer.mvActions.exists(this.parseString(param[0]))) {
                            return (this.run(GlobalPlayer.mvActions[this.parseString(param[0])]));
                        } else {
                            return (false);
                        }

                    // input
                    case 'input.string':
                        if (param.length > 1) {
                            var acOk:Dynamic = null;
                            var acCancel:Dynamic = null;
                            if (Reflect.hasField(inf, 'ok')) acOk = Reflect.field(inf, 'ok');
                            if (Reflect.hasField(inf, 'cancel')) acCancel = Reflect.field(inf, 'cancel');
                            GlobalPlayer.area.showTextInput(this.parseString(param[0]), this.parseString(param[1]), acOk, acCancel);
                        return (true);
                        } else {
                            return (false);
                        }
                    case 'input.list':
                        if (param.length > 3) {
                            var acOk:Dynamic = null;
                            var acCancel:Dynamic = null;
                            if (Reflect.hasField(inf, 'ok')) acOk = Reflect.field(inf, 'ok');
                            if (Reflect.hasField(inf, 'cancel')) acCancel = Reflect.field(inf, 'cancel');
                            var op:Array<String> = [ ];
                            for (i in 2...param.length) op.push(this.parseString(param[i]));
                            GlobalPlayer.area.showListInput(this.parseString(param[0]), this.parseString(param[1]), op, acOk, acCancel);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.int':
                        if (param.length > 1) {
                            var acOk:Dynamic = null;
                            var acCancel:Dynamic = null;
                            if (Reflect.hasField(inf, 'ok')) acOk = Reflect.field(inf, 'ok');
                            if (Reflect.hasField(inf, 'cancel')) acCancel = Reflect.field(inf, 'cancel');
                            var step:Int = 1;
                            var min:Int = 0;
                            var max:Int = 100;
                            if (param.length > 2) step = this.parseInt(param[2]);
                            if (param.length > 3) min = this.parseInt(param[3]);
                            if (param.length > 4) max = this.parseInt(param[4]);
                            GlobalPlayer.area.showNumericInput('int', this.parseString(param[0]), this.parseString(param[1]), acOk, acCancel, step, min, max);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.float':
                        if (param.length > 1) {
                            var acOk:Dynamic = null;
                            var acCancel:Dynamic = null;
                            if (Reflect.hasField(inf, 'ok')) acOk = Reflect.field(inf, 'ok');
                            if (Reflect.hasField(inf, 'cancel')) acCancel = Reflect.field(inf, 'cancel');
                            var step:Float = 1;
                            var min:Float = 0;
                            var max:Float = 100;
                            if (param.length > 2) step = this.parseInt(param[2]);
                            if (param.length > 3) min = this.parseInt(param[3]);
                            if (param.length > 4) max = this.parseInt(param[4]);
                            GlobalPlayer.area.showNumericInput('float', this.parseString(param[0]), this.parseString(param[1]), acOk, acCancel, step, min, max);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.message':
                        if (param.length > 1) {
                            var acOk:Dynamic = null;
                            var acCancel:Dynamic = null;
                            if (Reflect.hasField(inf, 'ok')) acOk = Reflect.field(inf, 'ok');
                            if (Reflect.hasField(inf, 'cancel')) acCancel = Reflect.field(inf, 'cancel');
                            GlobalPlayer.area.showMessageInput(this.parseString(param[0]), this.parseString(param[1]), acOk, acCancel);
                        return (true);
                        } else {
                            return (false);
                        }
                    case 'input.email':
                        if (param.length > 1) {
                            var acOk:Dynamic = null;
                            var acCancel:Dynamic = null;
                            if (Reflect.hasField(inf, 'ok')) acOk = Reflect.field(inf, 'ok');
                            if (Reflect.hasField(inf, 'cancel')) acCancel = Reflect.field(inf, 'cancel');
                            var domains:Array<String> = [ ];
                            if (param.length > 2) for (i in 2...param.length) domains.push(this.parseString(param[i]));
                            GlobalPlayer.area.showEmailInput(this.parseString(param[0]), this.parseString(param[1]), domains, acOk, acCancel);
                        return (true);
                        } else {
                            return (false);
                        }
                    case 'input.login':
                        var acOk:Dynamic = null;
                        var acCancel:Dynamic = null;
                        if (Reflect.hasField(inf, 'ok')) acOk = Reflect.field(inf, 'ok');
                        if (Reflect.hasField(inf, 'cancel')) acCancel = Reflect.field(inf, 'cancel');
                        GlobalPlayer.area.showLoginInput(acOk, acCancel);
                        return (true);

                    // data
                    case 'data.save':
                            this._acOk = this._acError = null;
                            if (GlobalPlayer.ws.userLogged() && (param.length > 1)) {
                                var values:Array<Dynamic> = [ ];
                                for (i in 1...param.length) {
                                    var obj:Dynamic = this.getValueObj(param[i]);
                                    if (obj != null) values.push(obj);
                                }
                                if (values.length == 0) {
                                    if (Reflect.hasField(inf, 'error')) {
                                        this.run(Reflect.field(inf, 'error'), true);
                                    }
                                } else {
                                    if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                                    if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                                    GlobalPlayer.ws.dataSave(this.parseString(param[0]), values, onDataSave);
                                }
                                return (true);
                            } else {
                                if (Reflect.hasField(inf, 'error')) {
                                    this.run(Reflect.field(inf, 'error'), true);
                                }
                                return (false);
                            }
                    case 'data.load':
                            this._acOk = this._acError = null;
                            if (GlobalPlayer.ws.userLogged() && (param.length > 0)) {
                                if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                                if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                                GlobalPlayer.ws.dataLoad(this.parseString(param[0]), onDataLoad);
                                return (true);
                            } else {
                                if (Reflect.hasField(inf, 'error')) {
                                    this.run(Reflect.field(inf, 'error'), true);
                                }
                                return (false);
                            }
                    case 'data.savelocal':
                        this._acOk = this._acError = null;
                        if (param.length > 1) {
                            var values:Array<Dynamic> = [ ];
                            for (i in 1...param.length) {
                                var obj:Dynamic = this.getValueObj(param[i]);
                                if (obj != null) values.push(obj);
                            }
                            if (values.length == 0) {
                                if (Reflect.hasField(inf, 'error')) {
                                    this.run(Reflect.field(inf, 'error'), true);
                                }
                            } else {
                                try {
                                    var shared:SharedObject = SharedObject.getLocal(GlobalPlayer.movie.mvId + '_' + this.parseString(param[0]));
                                    shared.data.values = StringStatic.jsonStringify(values);
                                    shared.flush();
                                    if (Reflect.hasField(inf, 'success')) {
                                        this.run(Reflect.field(inf, 'success'), true);
                                    }
                                } catch (e) {
                                    if (Reflect.hasField(inf, 'error')) {
                                        this.run(Reflect.field(inf, 'error'), true);
                                    }
                                }
                            }
                            return (true);
                        } else {
                            if (Reflect.hasField(inf, 'error')) {
                                this.run(Reflect.field(inf, 'error'), true);
                            }
                            return (false);
                        }
                    case 'data.loadlocal':
                        this._acOk = this._acError = null;
                        if (param.length > 0) {
                            try {
                                var shared:SharedObject = SharedObject.getLocal(GlobalPlayer.movie.mvId + '_' + this.parseString(param[0]));
                                if (Reflect.hasField(shared.data, 'values')) {
                                    var vals:Dynamic = StringStatic.jsonParse(Reflect.field(shared.data, 'values'));
                                    if (vals == false) {
                                        if (Reflect.hasField(inf, 'error')) {
                                            this.run(Reflect.field(inf, 'error'), true);
                                        }
                                    } else {
                                        for (i in Reflect.fields(vals)) {
                                            var obj:Dynamic = Reflect.field(vals, i);
                                            switch (Reflect.field(obj, 't')) {
                                                case 'S': this._strings[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                                                case 'F': this._floats[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                                                case 'I': this._ints[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                                                case 'B': this._bools[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                                            }
                                        }
                                        if (Reflect.hasField(inf, 'success')) {
                                            this.run(Reflect.field(inf, 'success'), true);
                                        }
                                    }
                                } else {
                                    if (Reflect.hasField(inf, 'error')) {
                                        this.run(Reflect.field(inf, 'error'), true);
                                    }
                                }
                            } catch (e) {
                                if (Reflect.hasField(inf, 'error')) {
                                    this.run(Reflect.field(inf, 'error'), true);
                                }
                            }
                            return (true);
                        } else {
                            if (Reflect.hasField(inf, 'error')) {
                                this.run(Reflect.field(inf, 'error'), true);
                            }
                            return (false);
                        }
                    case 'data.savestate':
                            this._acOk = this._acError = null;
                            if (GlobalPlayer.ws.userLogged()) {
                                var values:Array<Dynamic> = [ ];
                                for (i in this._strings.keys()) values.push({ n: i, t: 'S', v: this._strings[i] });
                                for (i in this._floats.keys()) values.push({ n: i, t: 'F', v: this._floats[i] });
                                for (i in this._ints.keys()) values.push({ n: i, t: 'I', v: this._ints[i] });
                                for (i in this._bools.keys()) values.push({ n: i, t: 'B', v: this._bools[i] });
                                if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                                if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                                var about:String = '';
                                if (param.length > 0) about = this.parseString(param[0]);
                                GlobalPlayer.ws.stateSave(values, false, about, onDataSave);
                                return (true);
                            } else {
                                if (Reflect.hasField(inf, 'error')) {
                                    this.run(Reflect.field(inf, 'error'), true);
                                }
                                return (false);
                            }
                    case 'data.loadstate':
                            this._acOk = this._acError = null;
                            if (GlobalPlayer.ws.userLogged() && (param.length > 0)) {
                                if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                                if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                                GlobalPlayer.ws.stateLoad(this.parseString(param[0]), false, onStateLoad);
                                return (true);
                            } else {
                                if (Reflect.hasField(inf, 'error')) {
                                    this.run(Reflect.field(inf, 'error'), true);
                                }
                                return (false);
                            }
                    case 'data.savequickstate':
                            this._acOk = this._acError = null;
                            if (GlobalPlayer.ws.userLogged()) {
                                var values:Array<Dynamic> = [ ];
                                for (i in this._strings.keys()) values.push({ n: i, t: 'S', v: this._strings[i] });
                                for (i in this._floats.keys()) values.push({ n: i, t: 'F', v: this._floats[i] });
                                for (i in this._ints.keys()) values.push({ n: i, t: 'I', v: this._ints[i] });
                                for (i in this._bools.keys()) values.push({ n: i, t: 'B', v: this._bools[i] });
                                if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                                if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                                var about:String = '';
                                if (param.length > 0) about = this.parseString(param[0]);
                                GlobalPlayer.ws.stateSave(values, true, about, onDataSave);
                                return (true);
                            } else {
                                if (Reflect.hasField(inf, 'error')) {
                                    this.run(Reflect.field(inf, 'error'), true);
                                }
                                return (false);
                            }
                    case 'data.loadquickstate':
                            this._acOk = this._acError = null;
                            if (GlobalPlayer.ws.userLogged()) {
                                if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                                if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                                GlobalPlayer.ws.stateLoad('', true, onStateLoad);
                                return (true);
                            } else {
                                if (Reflect.hasField(inf, 'error')) {
                                    this.run(Reflect.field(inf, 'error'), true);
                                }
                                return (false);
                            }
                    case 'data.savestatelocal':
                        this._acOk = this._acError = null;
                        var values:Array<Dynamic> = [ ];
                        for (i in this._strings.keys()) values.push({ n: i, t: 'S', v: this._strings[i] });
                        for (i in this._floats.keys()) values.push({ n: i, t: 'F', v: this._floats[i] });
                        for (i in this._ints.keys()) values.push({ n: i, t: 'I', v: this._ints[i] });
                        for (i in this._bools.keys()) values.push({ n: i, t: 'B', v: this._bools[i] });
                        if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                        if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                        try {
                            var shared:SharedObject = SharedObject.getLocal(GlobalPlayer.movie.mvId + '_state');
                            shared.data.values = StringStatic.jsonStringify(values);
                            shared.data.scene = GlobalPlayer.movie.scId;
                            shared.flush();
                            if (Reflect.hasField(inf, 'success')) {
                                this.run(Reflect.field(inf, 'success'), true);
                            }
                        } catch (e) {
                            if (Reflect.hasField(inf, 'error')) {
                                this.run(Reflect.field(inf, 'error'), true);
                            }
                        }
                        return (true);
                    case 'data.loadstatelocal':
                        this._acOk = this._acError = null;
                        try {
                            var shared:SharedObject = SharedObject.getLocal(GlobalPlayer.movie.mvId + '_state');
                            if ((Reflect.hasField(shared.data, 'values') && (Reflect.hasField(shared.data, 'scene')))) {
                                var vals:Dynamic = StringStatic.jsonParse(Reflect.field(shared.data, 'values'));
                                if (vals == false) {
                                    if (Reflect.hasField(inf, 'error')) {
                                        this.run(Reflect.field(inf, 'error'), true);
                                    }
                                } else {
                                    for (i in Reflect.fields(vals)) {
                                        var obj:Dynamic = Reflect.field(vals, i);
                                        switch (Reflect.field(obj, 't')) {
                                            case 'S': this._strings[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                                            case 'F': this._floats[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                                            case 'I': this._ints[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                                            case 'B': this._bools[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                                        }
                                    }
                                    GlobalPlayer.movie.loadScene(Reflect.field(shared.data, 'scene'));
                                    if (Reflect.hasField(inf, 'success')) {
                                        this.run(Reflect.field(inf, 'success'), true);
                                    }
                                }
                            } else {
                                if (Reflect.hasField(inf, 'error')) {
                                    this.run(Reflect.field(inf, 'error'), true);
                                }
                            }
                        } catch (e) {
                            if (Reflect.hasField(inf, 'error')) {
                                this.run(Reflect.field(inf, 'error'), true);
                            }
                        }
                        return (true);
                    case 'data.liststates':
                            this._acOk = this._acError = null;
                            if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                            if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                            GlobalPlayer.area.showStatesInput(this._acOk, this._acError);
                            return (true);
                    case 'data.event':
                            var prData:Array<String> = [ ];
                            if (param.length > 1) {
                                for (i in 1...param.length) prData.push(this.parseString(param[i]));
                            }
                            GlobalPlayer.ws.send('Visitor/Event', [
                                'name' => this.parseString(param[0]), 
                                'data' => StringStatic.jsonStringify(prData), 
                                'movieid' => GlobalPlayer.movie.mvId, 
                                'sceneid' => GlobalPlayer.movie.scId, 
                                'movietitle' => GlobalPlayer.mdata.title, 
                                'scenetitle' => GlobalPlayer.movie.scene.title, 
                                'visitor' => GlobalPlayer.ws.user, 
                            ], null);
                            return (true);

                    // timers
                    case 'timer.clearall':
                        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
                            return (true);
                        } else {
                            for (k in this._timers.keys()) {
                                this._timers[k].clear();
                                this._timers.remove(k);
                            }
                            return (true);
                        }
                    case 'timer.clear':
                        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
                            return (true);
                        } else {
                            for (k in this._timers.keys()) {
                                if (this._timers[k].name == null) {
                                    this._timers.remove(k);
                                }
                            }
                            if (param.length >= 1) {
                                if (this._timers.exists(param[0])) {
                                    try {
                                        this._timers[param[0]].clear();
                                    } catch (e) { }
                                    this._timers.remove(param[0]);
                                    return (true);
                                } else {
                                    return (false);
                                }
                            } else {
                                return (false);
                            }
                        }
                    case 'timer.set':
                        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
                            return (true);
                        } else {
                            for (k in this._timers.keys()) {
                                if (this._timers[k].name == null) {
                                    this._timers.remove(k);
                                }
                            }
                            if (Reflect.hasField(inf, 'tick')) {
                                if (param.length == 3) {
                                    var inter:Int = Std.parseInt(param[1]);
                                    if ((inter == null) || (inter < 250)) {
                                        return (false);
                                    } else {
                                        var stp:Int = Std.parseInt(param[2]);
                                        if ((stp == null) || (stp < 1)) {
                                            return (false);
                                        } else {
                                            if (this._timers.exists(param[0])) {
                                                this._timers[param[0]].clear();
                                                this._timers.remove(param[0]);
                                            }
                                            var end:Dynamic = null;
                                            if (Reflect.hasField(inf, 'end')) end = Reflect.field(inf, 'end');
                                            this._timers[param[0]] = new ActionTimer(param[0], inter, stp, Reflect.field(inf, 'tick'), end);
                                            return (true);
                                        }
                                    }
                                } else {
                                    return (false);
                                }
                            } else {
                                return (false);
                            }
                        }

                    // automatic replace
                    case 'replace.setstring':
                        if (param.length > 1) {
                            this._replacestr[this.parseString(param[0])] = this.parseString(param[1]);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'replace.setfile':
                        if (param.length > 1) {
                            this._replacefile[this.parseString(param[0])] = this.parseString(param[1]);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'replace.clearallstrings':
                        this._replacestr = [ ];
                        return (true);
                    case 'replace.clearallfiles':
                        this._replacefile = [ ];
                        return (true);
                    case 'replace.clearstring':
                        if (param.length > 0) {
                            if (this._replacestr.exists(this.parseString(param[0]))) {
                                this._replacestr.remove(this.parseString(param[0]));
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'replace.clearfile':
                        if (param.length > 0) {
                            if (this._replacefile.exists(this.parseString(param[0]))) {
                                this._replacefile.remove(this.parseString(param[0]));
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'if.replacestringset':
                        if (param.length > 0) {
                            if (this._replacestr.exists(this.parseString(param[0]))) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.replacefileset':
                        if (param.length > 0) {
                            if (this._replacefile.exists(this.parseString(param[0]))) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'replace.origin':
                        if (param.length > 0) {
                            switch (this.parseString(param[0])) {
                                case 'center': GlobalPlayer.mdata.origin = this.parseString(param[0]);
                                case 'top': GlobalPlayer.mdata.origin = this.parseString(param[0]);
                                case 'topkeep': GlobalPlayer.mdata.origin = this.parseString(param[0]);
                                case 'bottom': GlobalPlayer.mdata.origin = this.parseString(param[0]);
                                case 'bottomkeep': GlobalPlayer.mdata.origin = this.parseString(param[0]);
                                case 'left': GlobalPlayer.mdata.origin = this.parseString(param[0]);
                                case 'leftkeep': GlobalPlayer.mdata.origin = this.parseString(param[0]);
                                case 'right': GlobalPlayer.mdata.origin = this.parseString(param[0]);
                                case 'rightkeep': GlobalPlayer.mdata.origin = this.parseString(param[0]);
                                default: GlobalPlayer.mdata.origin = 'alpha';
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    
                        
                    // string values
                    case 'string.setgroup':
                        if (param.length > 0) {
                            if (this._stringsjson.exists(this.parseString(param[0]))) {
                                this._jsongropup = this.parseString(param[0]);
                            } else {
                                this._jsongropup = '';
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'string.setglobal':
                        if (param.length > 1) {
                            GlobalPlayer.mdata.texts[this.parseString(param[0])] = this.parseString(param[1]);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'string.clearglobal':
                        if (param.length > 1) {
                            if (GlobalPlayer.mdata.texts.exists(this.parseString(param[0]))) {
                                GlobalPlayer.mdata.texts.remove(this.parseString(param[0]));
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'string.set':
                        if (param.length > 1) return (this.setString(param[0], param[1]))
                            else return (false);
                    case 'string.clear':
                        return (this.clearString(param[0]));
                    case 'string.clearall':
                        return (this.clearVars('strings'));
                    case 'string.concat':
                        if (param.length > 2) {
                            var varname:String = this.parseString(param[0]);
                            this.concatString(varname, param[1], param[2]);
                            if (param.length > 3) {
                                for (i in 3...param.length) {
                                    this.concatString(varname, ('$'+varname), param[i]);
                                }
                            }
                            return (true);
                        } else return (false);
                    case 'string.replace':
                        if (param.length > 3) {
                            this._strings[this.parseString(param[0])] = StringTools.replace(this.parseString(param[1]), this.parseString(param[2]), this.parseString(param[3]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'string.tofloat':
                        if ((param.length > 1)) {
                            this._floats[this.parseString(param[0])] = Std.parseFloat(this.parseString(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'string.toint':
                        if ((param.length > 1)) {
                            this._ints[this.parseString(param[0])] = Std.parseInt(this.parseString(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }

                    // string conditions
                    case 'if.stringsequal':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseString(param[0]) == this.parseString(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.stringset':
                        if (param.length > 0) {
                            if (this._strings.exists(this.parseString(param[0]))) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.stringsdifferent':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseString(param[0]) != this.parseString(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.stringcontains':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (StringTools.contains(this.parseString(param[0]), this.parseString(param[1]))) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.stringendswith':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (StringTools.endsWith(this.parseString(param[0]), this.parseString(param[1]))) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.stringstartswith':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (StringTools.startsWith(this.parseString(param[0]), this.parseString(param[1]))) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }

                    // boolean values
                    case 'bool.set':
                        return (this.setBool(param[0], param[1]));
                    case 'bool.setinverse':
                        return (this.setBool(param[0], param[1], true));
                    case 'bool.clear':
                        return (this.clearBool(param[0]));
                    case 'bool.clearall':
                        return (this.clearVars('bools'));

                    // boolean conditions
                    case 'if.bool':
                        if ((param.length > 0) && Reflect.hasField(inf, 'then')) {
                            if (this.parseBool(param[0])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.boolset':
                        if (param.length > 0) {
                            if (this._bools.exists(this.parseString(param[0]))) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }

                    // float values
                    case 'float.set':
                        return (this.setFloat(param[0], param[1]));
                    case 'float.clear':
                        return (this.clearFloat(param[0]));
                    case 'float.clearall':
                        return (this.clearVars('floats'));
                    case 'float.sum':
                        if ((param.length > 2)) {
                            var varname:String = this.parseString(param[0]);
                            this._floats[varname] = this.parseFloat(param[1]) + this.parseFloat(param[2]);
                            if (param.length > 3) {
                                for (i in 3...param.length) {
                                    this._floats[varname] += this.parseFloat(param[i]);
                                }
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'float.subtract':
                        if ((param.length > 2)) {
                            var varname:String = this.parseString(param[0]);
                            this._floats[varname] = this.parseFloat(param[1]) - this.parseFloat(param[2]);
                            if (param.length > 3) {
                                for (i in 3...param.length) {
                                    this._floats[varname] -= this.parseFloat(param[i]);
                                }
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'float.multiply':
                        if ((param.length > 2)) {
                            var varname:String = this.parseString(param[0]);
                            this._floats[varname] = this.parseFloat(param[1]) * this.parseFloat(param[2]);
                            if (param.length > 3) {
                                for (i in 3...param.length) {
                                    this._floats[varname] *= this.parseFloat(param[i]);
                                }
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'float.divide':
                        if ((param.length > 2)) {
                            var varname:String = this.parseString(param[0]);
                            this._floats[varname] = this.parseFloat(param[1]) / this.parseFloat(param[2]);
                            if (param.length > 3) {
                                for (i in 3...param.length) {
                                    this._floats[varname] = this._floats[varname] / this.parseFloat(param[i]);
                                }
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'float.random':
                        if ((param.length > 2)) {
                            var start:Float = this.parseFloat(param[1]);
                            var dif:Float = Math.abs(this.parseFloat(param[2]) - start);
                            this._floats[this.parseString(param[0])] = start + (Math.random() * dif);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'float.min':
                        if ((param.length > 2)) {
                            this._floats[this.parseString(param[0])] = Math.min(this.parseFloat(param[1]), this.parseFloat(param[2]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'float.max':
                        if ((param.length > 2)) {
                            this._floats[this.parseString(param[0])] = Math.max(this.parseFloat(param[1]), this.parseFloat(param[2]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'float.abs':
                        if ((param.length > 1)) {
                            this._floats[this.parseString(param[0])] = Math.abs(this.parseFloat(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'float.toint':
                        if ((param.length > 1)) {
                            this._ints[this.parseString(param[0])] = Math.round(this.parseFloat(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'float.tostring':
                        if ((param.length > 1)) {
                            this._strings[this.parseString(param[0])] = Std.string(this.parseFloat(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }

                    // float conditions
                    case 'if.floatsequal':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseFloat(param[0]) == this.parseFloat(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.floatset':
                        if (param.length > 0) {
                            if (this._floats.exists(this.parseString(param[0]))) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.floatsdifferent':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseFloat(param[0]) != this.parseFloat(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.floatlower':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseFloat(param[0]) < this.parseFloat(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.floatlowerequal':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseFloat(param[0]) <= this.parseFloat(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.floatgreater':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseFloat(param[0]) > this.parseFloat(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.floatgreaterequal':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseFloat(param[0]) >= this.parseFloat(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }   

                    // int values
                    case 'int.set':
                        return (this.setInt(param[0], param[1]));
                    case 'int.clear':
                        return (this.clearInt(param[0]));
                    case 'int.clearall':
                        return (this.clearVars('ints'));
                    case 'int.sum':
                        if ((param.length > 2)) {
                            var varname:String = this.parseString(param[0]);
                            this._ints[varname] = this.parseInt(param[1]) + this.parseInt(param[2]);
                            if (param.length > 3) {
                                for (i in 3...param.length) {
                                    this._ints[varname] += this.parseInt(param[i]);
                                }
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'int.subtract':
                        if ((param.length > 2)) {
                            var varname:String = this.parseString(param[0]);
                            this._ints[varname] = this.parseInt(param[1]) - this.parseInt(param[2]);
                            if (param.length > 3) {
                                for (i in 3...param.length) {
                                    this._ints[varname] -= this.parseInt(param[i]);
                                }
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'int.multiply':
                        if ((param.length > 2)) {
                            var varname:String = this.parseString(param[0]);
                            this._ints[varname] = this.parseInt(param[1]) * this.parseInt(param[2]);
                            if (param.length > 3) {
                                for (i in 3...param.length) {
                                    this._ints[varname] *= this.parseInt(param[i]);
                                }
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'int.divide':
                        if ((param.length > 2)) {
                            var varname:String = this.parseString(param[0]);
                            this._ints[varname] = Math.round(this.parseInt(param[1]) / this.parseInt(param[2]));
                            if (param.length > 3) {
                                for (i in 3...param.length) {
                                    this._ints[varname] = Math.round(this._ints[varname] / this.parseInt(param[i]));
                                }
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'int.random':
                        if ((param.length > 2)) {
                            var start:Int = this.parseInt(param[1]);
                            var dif:Int = Math.round(Math.abs(this.parseInt(param[2]) - start));
                            this._ints[this.parseString(param[0])] = start + Math.round(Math.random() * dif);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'int.min':
                        if ((param.length > 2)) {
                            this._ints[this.parseString(param[0])] = Math.round(Math.min(this.parseInt(param[1]), this.parseInt(param[2])));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'int.max':
                        if ((param.length > 2)) {
                            this._ints[this.parseString(param[0])] = Math.round(Math.max(this.parseInt(param[1]), this.parseInt(param[2])));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'int.abs':
                        if ((param.length > 1)) {
                            this._ints[this.parseString(param[0])] = Math.round(Math.abs(this.parseInt(param[1])));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'int.tofloat':
                        if ((param.length > 1)) {
                            this._floats[this.parseString(param[0])] = this.parseInt(param[1]) * 1.0;
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'int.tostring':
                        if ((param.length > 1)) {
                            this._strings[this.parseString(param[0])] = Std.string(this.parseInt(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }

                    // int conditions
                    case 'if.intsequal':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseInt(param[0]) == this.parseInt(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.intset':
                        if (param.length > 0) {
                            if (this._ints.exists(this.parseString(param[0]))) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.intsdifferent':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseInt(param[0]) != this.parseInt(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.intlower':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseInt(param[0]) < this.parseInt(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.intlowerequal':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseInt(param[0]) <= this.parseInt(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.intgreater':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseInt(param[0]) > this.parseInt(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }
                    case 'if.intgreaterequal':
                        if ((param.length > 1) && Reflect.hasField(inf, 'then')) {
                            if (this.parseInt(param[0]) >= this.parseInt(param[1])) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        } else {
                            return (false);
                        }

                    // plugin actions
                    default:
                        var found:Bool = false;
                        var ret:Bool = false;
                        var after:AfterScript = {
                            onthen: null,
                            onelse: null,
                            onok: null,
                            oncancel: null,
                            ontick: null,
                            onend: null,
                            onsuccess: null,
                            onerror: null
                        };
                        if (Reflect.hasField(inf, 'then')) after.onthen = Reflect.field(inf, 'then');
                        if (Reflect.hasField(inf, 'else')) after.onelse = Reflect.field(inf, 'else');
                        if (Reflect.hasField(inf, 'ok')) after.onok = Reflect.field(inf, 'ok');
                        if (Reflect.hasField(inf, 'cancel')) after.oncancel = Reflect.field(inf, 'cancel');
                        if (Reflect.hasField(inf, 'tick')) after.ontick = Reflect.field(inf, 'tick');
                        if (Reflect.hasField(inf, 'end')) after.onend = Reflect.field(inf, 'end');
                        if (Reflect.hasField(inf, 'success')) after.onsuccess = Reflect.field(inf, 'success');
                        if (Reflect.hasField(inf, 'error')) after.onerror = Reflect.field(inf, 'error');
                        for (p in GlobalPlayer.plugins) {
                            if (p.active && !found) {
                                if (p.hasAction(Reflect.field(inf, 'ac'))) {
                                    ret = p.runAction(Reflect.field(inf, 'ac'), param, after);
                                    found = true;
                                }
                            }
                        }
                        // action processed?
                        return (ret);
                }
            }
        } else {
            // required information not sent
            return (false);
        }
    }

    /** PARSING VARIABLES **/

    /**
        Evaluates a given file path replacing required fields.
        @param  path    the file path
        @return the path with replaced values
    **/
    public function parsePath(path:String):String {
        for (k in this._replacefile.keys()) {
            path = StringTools.replace(path, k, this._replacefile[k]);
        }
        return (path);
    }

    /**
        Parses a string checking for variables and replaced values.
        @param  str the string to parse (starting with $ to look for a variable name)
        @return the original string if not starting with $, found string variable with the name after $ if found
    **/
    public function parseString(str:String):String {
        var str:String = this.parseStringVar(str);
        for (k in this._replacestr.keys()) {
            str = StringTools.replace(str, k, this._replacestr[k]);
        }
        return (str);
    }

    /**
        Parses a string to check if it is a variable reference.
        @param  str the string to parse (starting with $ to look for a variable name)
        @return the original string if not starting with $, found string variable with the name after $ if found
    **/
    public function parseStringVar(str:String):String {
        if (str.charAt(0) == '$') {
            // looking for plugin globals
            for (p in GlobalPlayer.plugins) {
                if (p.active) {
                    var plparse:ParsedString = p.parseString(str);
                    if (plparse.found) {
                        return (plparse.value);
                    }
                }
            }
            // look for instance globals
            if (str.substr(0, 10) == "$_INSTANCE") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    switch (arstr[0]) {
                        case "$_INSTANCECOLOR":
                            return (GlobalPlayer.area.instanceStringProp(this.parseString(arstr[1]), 'color'));
                        case "$_INSTANCETEXT":
                            return (GlobalPlayer.area.instanceStringProp(this.parseString(arstr[1]), 'text'));
                        case "$_INSTANCEFONT":
                            return (GlobalPlayer.area.instanceStringProp(this.parseString(arstr[1]), 'font'));
                        case "$_INSTANCEFONTCOLOR":
                            return (GlobalPlayer.area.instanceStringProp(this.parseString(arstr[1]), 'fontColor'));
                        default:
                            return (str);
                    }
                } else {
                    return (str);
                }
            } else if (str.substr(0, 7) == "$_TEXTS") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    if (GlobalPlayer.mdata.texts.exists(this.parseString(arstr[1]))) {
                        return (GlobalPlayer.mdata.texts[this.parseString(arstr[1])]);
                    } else {
                        return ('');
                    }
                } else {
                    return ('');
                }
            } else if ((this._jsongropup != '') && this._stringsjson.exists(this._jsongropup) && this._stringsjson[this._jsongropup].exists(str)) {
                return(this._stringsjson[this._jsongropup][str]);
            } else {
                // look for other globals
                switch (str) {
                    case "$_RUNTIME":
                        #if runtimewebsite
                            return('website');
                        #elseif runtimepwa
                            return ('pwa');
                        #elseif runtimedesktop
                            return ('desktop');
                        #elseif runtimemobile
                            return ('mobile');
                        #elseif runtimepublish
                            return ('publish');
                        #elseif tilbuciplayer
                            return ('embed');
                        #else
                            return('tilbuci');
                        #end
                    case "$_RENDER":
                        #if renderdom
                            return ('dom');
                        #else 
                            return ('webgl');
                        #end
                    case "$_WSSERVER": return (GlobalPlayer.ws.url);
                    case "$_VERSION": return (GlobalPlayer.build.version);
                    case "$_MOVIETITLE": return (GlobalPlayer.movie.data.title);
                    case "$_MOVIEID": return (GlobalPlayer.movie.mvId);
                    case "$_SCENETITLE": return (GlobalPlayer.movie.scene.title);
                    case "$_SCENEID": return (GlobalPlayer.movie.scId);
                    case "$_ORIENTATION": return (GlobalPlayer.area.pOrientation);
                    case "$_USERNAME": return (GlobalPlayer.ws.getUser());
                    case "$_URLMOVIE": return(GlobalPlayer.base + 'app?mv=' + GlobalPlayer.movie.mvId);
                    case "$_URLSCENE": return(GlobalPlayer.base + 'app?mv=' + GlobalPlayer.movie.mvId + '&sc=' + GlobalPlayer.movie.scId);
                    default:
                        // look on stantard variables
                        if (this._strings.exists(str.substr(1))) {
                            return (this._strings[str.substr(1)]);
                        } else {
                            return (str);
                        }
                }
            }
        } else {
            return (str);
        }
    }

    /**
        Parses a string to check if it is a bool variable reference.
        @param  str the string to check
        @return the variable value of found, if not, returns if the string is equal to "true" (case isensitive)
    **/
    public function parseBool(str:String):Bool {
        if (str.charAt(0) == '?') {
            // looking for plugin globals
            for (p in GlobalPlayer.plugins) {
                if (p.active) {
                    var plparse:ParsedBool = p.parseBool(str);
                    if (plparse.found) {
                        return (plparse.value);
                    }
                }
            }
            // look for instance globals
            if (str.substr(0, 10) == '?_INSTANCE') {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    switch (arstr[0]) {
                        case '?_INSTANCEPLAYING':
                            return (GlobalPlayer.area.instancePlaying(this.parseString(arstr[1])));
                        case '?_INSTANCEVISIBLE':
                            return (GlobalPlayer.area.instanceBoolProp(this.parseString(arstr[1]), 'visible'));
                        case '?_INSTANCEFONTBOLD':
                            return (GlobalPlayer.area.instanceBoolProp(this.parseString(arstr[1]), 'fontBold'));
                        case '?_INSTANCEFONTITALIC':
                            return (GlobalPlayer.area.instanceBoolProp(this.parseString(arstr[1]), 'fontItalic'));
                        default:
                            return (false);
                    }
                } else {
                    return (false);
                }
            } else if (str.substr(0, 7) == "?_FLAGS") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    if (GlobalPlayer.mdata.flags.exists(this.parseString(arstr[1]))) {
                        return (GlobalPlayer.mdata.flags[this.parseString(arstr[1])]);
                    } else {
                        return (false);
                    }
                } else {
                    return (false);
                }
            } else {
                // look for other globals
                switch (str) {
                    case '?_SERVER': return (GlobalPlayer.server);
                    case "?_PLAYING": return(GlobalPlayer.area.playing);
                    case "?_USERLOGGED": return(GlobalPlayer.ws.userLogged());
                    default:
                        // look on stantard variables
                        if (this._bools.exists(str.substr(1))) {
                            return (this._bools[str.substr(1)]);
                        } else {
                            return ((str.substr(1).toLowerCase() == 'true') || (str.substr(1).toLowerCase() == '1'));
                        }
                }
            }
        } else {
            return ((str.toLowerCase() == 'true') || (str == '1'));
        }
    }

    /**
        Parses a string to check if it is a float variable reference.
        @param  str the string to check
        @return the variable value if found, if not, tries to parse the string as a float value
    **/
    public function parseFloat(str:String):Float {
        if (str.charAt(0) == '#') {
            // looking for plugin globals
            for (p in GlobalPlayer.plugins) {
                if (p.active) {
                    var plparse:ParsedFloat = p.parseFloat(str);
                    if (plparse.found) {
                        return (plparse.value);
                    }
                }
            }
            // look for instance globals
            if (str.substr(0, 10) == '#_INSTANCE') {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    switch (arstr[0]) {
                        case '#_INSTANCEX':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'x'));
                        case '#_INSTANCEY':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'y'));
                        case '#_INSTANCEWIDTH':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'width'));
                        case '#_INSTANCEHEIGHT':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'height'));
                        case '#_INSTANCEALPHA':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'alpha'));
                        case '#_INSTANCEVOLUME':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'volume'));
                        case '#_INSTANCEPAN':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'pan'));
                        case '#_INSTANCEORDER':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'order'));
                        case '#_INSTANCECOLORALPHA':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'colorAlpha'));
                        case '#_INSTANCEROTATION':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'rotation'));
                        case '#_INSTANCEFONTSIZE':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'fontSize'));
                        case '#_INSTANCEFONTLEADING':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'fontLeading'));
                        case '#_INSTANCEFONTSPACING':
                            return (GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'fontSpacing'));
                        default:
                            return (0);
                    }
                } else {
                    return (0);
                }
            } else if (str.substr(0, 9) == "#_NUMBERS") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    if (GlobalPlayer.mdata.numbers.exists(this.parseString(arstr[1]))) {
                        return (GlobalPlayer.mdata.numbers[this.parseString(arstr[1])]);
                    } else {
                        return (0);
                    }
                } else {
                    return (0);
                }
            } else {
            // look for globals
                switch (str) {
                    case "#_KEYFRAME": return(GlobalPlayer.area.currentKf * 1.0);
                    case "#_AREABIG": return(GlobalPlayer.mdata.screen.big * 1.0);
                    case "#_AREASMALL": return(GlobalPlayer.mdata.screen.small * 1.0);
                    default:
                        // look on stantard variables
                        if (this._floats.exists(str.substr(1))) {
                            return (this._floats[str.substr(1)]);
                        } else {
                            return (Std.parseFloat(str.substr(1)));
                        }
                }
            }
        } else {
            return (Std.parseFloat(str));
        }
    }

    /**
        Parses a string to check if it is an int variable reference.
        @param  str the string to check
        @return the variable value if found, if not, tries to parse the string as an intr value
    **/
    public function parseInt(str:String):Int {
        if (str.charAt(0) == '#') {
            // looking for plugin globals
            for (p in GlobalPlayer.plugins) {
                if (p.active) {
                    var plparse:ParsedInt = p.parseInt(str);
                    if (plparse.found) {
                        return (plparse.value);
                    }
                }
            }
            // look for instance globals
            if (str.substr(0, 10) == '#_INSTANCE') {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    switch (arstr[0]) {
                        case '#_INSTANCEX':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'x')));
                        case '#_INSTANCEY':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'y')));
                        case '#_INSTANCEWIDTH':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'width')));
                        case '#_INSTANCEHEIGHT':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'height')));
                        case '#_INSTANCEALPHA':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'alpha')));
                        case '#_INSTANCEVOLUME':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'volume')));
                        case '#_INSTANCEPAN':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'pan')));
                        case '#_INSTANCEORDER':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'order')));
                        case '#_INSTANCECOLORALPHA':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'colorAlpha')));
                        case '#_INSTANCEROTATION':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'rotation')));
                        case '#_INSTANCEFONTSIZE':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'fontSize')));
                        case '#_INSTANCEFONTLEADING':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'fontLeading')));
                        case '#_INSTANCEFONTSPACING':
                            return (Math.round(GlobalPlayer.area.instanceProp(this.parseString(arstr[1]), 'fontSpacing')));
                        default:
                            return (0);
                    }
                } else {
                    return (0);
                }
            } else if (str.substr(0, 9) == "#_NUMBERS") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    if (GlobalPlayer.mdata.numbers.exists(this.parseString(arstr[1]))) {
                        return (Math.round(GlobalPlayer.mdata.numbers[this.parseString(arstr[1])]));
                    } else {
                        return (0);
                    }
                } else {
                    return (0);
                }
            } else {
                // look for globals
                switch (str) {
                    case "#_KEYFRAME": return(GlobalPlayer.area.currentKf);
                    case "#_AREABIG": return(GlobalPlayer.mdata.screen.big);
                    case "#_AREASMALL": return(GlobalPlayer.mdata.screen.small);
                    default:
                        // look on stantard variables
                        if (this._ints.exists(str.substr(1))) {
                            return (this._ints[str.substr(1)]);
                        } else {
                            return (Std.parseInt(str.substr(1)));
                        }
                }
            }
        } else {
            return (Std.parseInt(str));
        }
    }

    /**
        Gets a value object for saving.
        @param  name    the value name (starting with type, like "S:", "F:", "I:" or "B:")
        @return the value object or null if not found
    **/
    private function getValueObj(name:String):Dynamic {
        var varname:Array<String> = this.parseString(name).split(':');
        if (varname.length == 2) {
            switch (varname[0]) {
                case 'S': return ({ n: varname[1], t: 'S', v: this.parseString('$' + varname[1])});
                case 'F': return ({ n: varname[1], t: 'F', v: this.parseFloat('#' + varname[1])});
                case 'I': return ({ n: varname[1], t: 'I', v: this.parseInt('#' + varname[1])});
                case 'B': return ({ n: varname[1], t: 'B', v: this.parseBool('?' + varname[1])});
                default: return (null);
            }
        } else {
            return (null);
        }
    }

    /**
        Visitor data save return.
    **/
    private function onDataSave(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            if (this._acError != null) this.run(this._acError, true);
        } else {
            if (ld.map['e'] == 0) {
                if (this._acOk != null) this.run(this._acOk, true);
            } else {
                if (this._acError != null) this.run(this._acError, true);
            }
        }
    }

    /**
        Visitor data load return.
    **/
    private function onDataLoad(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            if (this._acError != null) this.run(this._acError, true);
        } else {
            if (ld.map['e'] == 0) {
                var vals:Dynamic = StringStatic.jsonParse(ld.map['values']);
                if (vals == false) {
                    if (this._acError != null) this.run(this._acError, true);
                } else {
                    for (i in Reflect.fields(vals)) {
                        var obj:Dynamic = Reflect.field(vals, i);
                        switch (Reflect.field(obj, 't')) {
                            case 'S': this._strings[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                            case 'F': this._floats[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                            case 'I': this._ints[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                            case 'B': this._bools[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                        }
                    }
                    if (this._acOk != null) this.run(this._acOk, true);
                }
            } else {
                if (this._acError != null) this.run(this._acError, true);
            }
        }
    }

    /**
        Visitor state load return.
    **/
    private function onStateLoad(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            if (this._acError != null) this.run(this._acError, true);
        } else {
            if (ld.map['e'] == 0) {
                var vals:Dynamic = StringStatic.jsonParse(ld.map['values']);
                if (vals == false) {
                    if (this._acError != null) this.run(this._acError, true);
                } else {
                    for (i in Reflect.fields(vals)) {
                        var obj:Dynamic = Reflect.field(vals, i);
                        switch (Reflect.field(obj, 't')) {
                            case 'S': this._strings[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                            case 'F': this._floats[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                            case 'I': this._ints[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                            case 'B': this._bools[Reflect.field(obj, 'n')] = Reflect.field(obj, 'v');
                        }
                    }
                    GlobalPlayer.movie.loadScene(ld.map['scene']);
                    if (this._acOk != null) this.run(this._acOk, true);
                }
            } else {
                if (this._acError != null) this.run(this._acError, true);
            }
        }
    }

    #if (js && html5)
    /**
        Exposed function to request a string value.
    **/
    @:expose('tilbuci_getstring')
    public static function tilbuci_getstring(name:String):String {
        return (GlobalPlayer.parser.getString(name));
    }

    /**
        Exposed function to request a float value.
    **/
    @:expose('tilbuci_getfloat')
    public static function tilbuci_getfloat(name:String):Float {
        return (GlobalPlayer.parser.getFloat(name));
    }

    /**
        Exposed function to request an int value.
    **/
    @:expose('tilbuci_getint')
    public static function tilbuci_getint(name:String):Int {
        return (GlobalPlayer.parser.getInt(name));
    }

    /**
        Exposed function to request a boolean value.
    **/
    @:expose('tilbuci_getbool')
    public static function tilbuci_getbool(name:String):Bool {
        return (GlobalPlayer.parser.getBool(name));
    }

    /**
        Exposed function to set a string value.
    **/
    @:expose('tilbuci_setstring')
    public static function tilbuci_setstring(name:String, value:String):Void {
        GlobalPlayer.parser.setString(name, value);
    }

    /**
        Exposed function to set a float value.
    **/
    @:expose('tilbuci_setfloat')
    public static function tilbuci_setfloat(name:String, value:Float):Void {
        GlobalPlayer.parser.setFloat(name, value);
    }

    /**
        Exposed function to set an int value.
    **/
    @:expose('tilbuci_setint')
    public static function tilbuci_setint(name:String, value:Int):Void {
        GlobalPlayer.parser.setInt(name, value);
    }

    /**
        Exposed function to set a boolean value.
    **/
    @:expose('tilbuci_setbool')
    public static function tilbuci_setbool(name:String, value:Bool):Void {
        GlobalPlayer.parser.setBool(name, value);
    }

    /**
        Exposed function to run an action code.
    **/
    @:expose('tilbuci_runaction')
    public static function tilbuci_runaction(action:String):Bool {
        return (GlobalPlayer.parser.run(action));
    }
    #end
}

/**
    Action descriptor.
**/
typedef ActionDescriptor = {
    var n:String;                   // name
    var a:String;                   // action code
    var c:Bool;                     // is a condition (if)?
    var d:String;                   // description
    var p:Array<ParamDescriptor>;   // parameters
}

/**
    Action parameter description.
**/
typedef ParamDescriptor = {
    var n:String;       // name
    var t:String;       // type
    var d:String;       // description
    var o:Bool;         // optional parameter?
}

/**
    Action group.
**/
typedef ActionGroup = {
    var n:String;                       // name
    var d:String;                       // description
    var a:Array<ActionDescriptor>;      // actions
}

/**
    Global variable descriptor.
**/
typedef GlobalVar = {
    var d:String;   // description
    var t:String;   // type
    var c:String;   // code
}

/**
    Group of global variables.
**/
typedef GlobalGroup = {
    var n:String;               // name
    var v:Array<GlobalVar>;     // global variables
}

/**
    Movie global actions.
**/
typedef MovieAction = {
    var name:String;        // movie action name
    var ac:String;          // movie action script
}

/**
    Save state variable description.
**/
typedef StateVars = {
    var n:String;   // variable name
    var t:String;   // variable type
    var v:Dynamic;   // variable value
}

/**
    Actions to run after some processing (for plugins).
**/
typedef AfterScript = {
    var onthen:Dynamic;
    var onelse:Dynamic;
    var onok:Dynamic;
    var oncancel:Dynamic;
    var ontick:Dynamic;
    var onend:Dynamic;
    var onsuccess:Dynamic;
    var onerror:Dynamic;
}

/**
    Embed content javascript methods.
**/
#if (js && html5)
@:native("window")
extern class ExternEmbed {

    /**
        Places the embed content area above the TilBuci player.
        @param  src the URL to load
    **/
    static function embed_place(src:String):Void;

    /**
        Closes the embed window.
    **/
    static function embed_close():Void;

}
#else
class ExternEmbed {
    
    /**
        Places the embed content area above the TilBuci player.
        @param  src the URL to load
    **/
    static function embed_place(src:String):Void { trace ('HTML5 embed content not supported on this platform.'); }

    /**
        Closes the embed window.
    **/
    static function embed_close():Void { trace ('HTML5 embed content not supported on this platform.'); }

}
#end