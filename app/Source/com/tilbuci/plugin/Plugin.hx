package com.tilbuci.plugin;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.base.InterfaceContainer;
import com.tilbuci.ui.base.InterfaceFactory;
import openfl.display.Sprite;
import openfl.events.EventDispatcher;

/** TILBUCI **/
import com.tilbuci.script.ScriptParser;
import com.tilbuci.plugin.PluginAccess;
import com.tilbuci.plugin.SystemInfo;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.Global;

class Plugin extends EventDispatcher {

    /**
        plugin unique name
    **/
    public var plname(get, null):String;
    private var _plname:String;
    private function get_plname():String { return (this._plname); }

    /**
        plugin title
    **/
    public var pltitle(get, null):String;
    private var _pltitle:String;
    private function get_pltitle():String { return (this._pltitle); }

    /**
        plugin server file (without ".php")
    **/
    public var plfile(get, null):String;
    private var _plfile:String;
    private function get_plfile():String { return (this._plfile); }

    /**
        does the plugin manipulate de index page?
    **/
    private var _plindex:Bool = false;

    /**
        does the plugin have its own webservice?
    **/
    private var _plws:Bool = false;

    /**
        is the plugin ready to run?
    **/
    public var ready(get, null):Bool;
    private var _ready:Bool = false;
    private function get_ready():Bool { return (this._ready); }

    /**
        plugin configuration
    **/
    private var config:Map<String, Dynamic> = [ ];

    /**
        information about the system
    **/
    public var info:SystemInfo;

    /**
        is the plugin active for current movie?
    **/
    public var active:Bool = false;

    /**
        additional script actions
    **/
    private var _actions:Map<String, Dynamic> = [ ];

    /**
        system access interface
    **/
    private var _access:PluginAccess;

    /**
        Constructor.
        @param  nm  plugin unique name
        @param  tt  plugin title
        @param  fl  plugin server file name (witour ".php")
        @param  index   does the plugin manipulates the page index file?
        @param  ws  does the plugin call its own webservice?
    **/
    public function new(nm:String, tt:String, fl:String = '', index:Bool = false, ws:Bool = false) {
        super();
        this._plname = nm;
        this._pltitle = tt;
        this._plfile = fl;
        this._plindex = index;
        this._plws = ws;
        this._ready = false;
        this.info = new SystemInfo();
    }

    /**
        Initializes the plugin.
        @param  ac  initialization data
    **/
    public function initialize(ac:PluginAccess):Void {
        var index:String = '0';
        if (this._plindex) index = '1';
        var ws:String = '0';
        if (this._plws) ws = '1';
        GlobalPlayer.ws.send('Plugin/GetConfig', [
            'name' => this._plname, 
            'file' => this._plfile, 
            'index' => index, 
            'ws' => ws
        ], this.onConfig);
        this._access = ac;
    }

    /**
        Plugin configuration received.
    **/
    private function onConfig(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                if (ld.map.exists('conf')) {
                    for (f in Reflect.fields(ld.map['conf'])) {
                        this.config[f] = Reflect.field(ld.map['conf'], f);
                    }
                }
            }
        }
        this._ready = true;
    }

    /**
        Adds a button to the left menu.
        @param  name    the button name/label
        @param  callback    action callback
        @param  top add to the top buttons area?
    **/
    private function addMenu(name:String, callback:Dynamic, top:Dynamic = true):Void {
        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
            Global.editorActions('addleftbutton', [
                'name' => name, 
                'callback' => callback, 
                'top' => top, 
                'asset' => 'btPlugin'
            ]);
        }
    }

    /**
        Shows a window at the editor interface.
        @param  wd  the window reference
    **/
    private function showWindow(wd:Dynamic):Void {
        Global.editorActions('showwindow', [
            'wd' => wd
        ]);
    }

    /**
        Hides a window at the editor interface.
        @param  wd  the window reference
    **/
    private function hideWindow(wd:Dynamic):Void {
        Global.editorActions('hidewindow', [
            'wd' => wd
        ]);
    }

    /**
        Updates the plugin configuration.
    **/
    private function updateConfig(callback:Dynamic):Void {
        var index:String = '0';
        if (this._plindex) index = '1';
        var ws:String = '0';
        if (this._plws) ws = '1';
        var data:Map<String, String> = [
            'name' => this._plname, 
            'file' => this._plfile, 
            'index' => index, 
            'ws' => ws, 
            'conf' => StringStatic.jsonStringify(this.config), 
        ];
        Global.ws.send('Plugin/SetConfig', data, callback);
    }

    /**
        Sets a script action.
        @param  name    action name ("ac" field of the action json descriptor)
        @param  func    reference to the function that must receive a single parameter (an array of strings) and return a boolean
    **/
    public function setAction(name:String, func:Dynamic):Void {
        this._actions[name] = func;
    }

    /**
        Removes a script action.
        @param  name    action name ("ac" field of the action json descriptor)
        @return was the action found and removed?
    **/
    public function removeAction(name:String):Bool {
        if (this._actions.exists(name)) {
            this._actions.remove(name);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Does the plugin defines an action?
        @param  name    action name ("ac" field of the action json descriptor)
        @return is the action defined?
    **/
    public function hasAction(name:String):Bool {
        return (this._actions.exists(name));
    }

    /**
        Runs a registered action.
        @param  name    action name ("ac" field of the action json descriptor)
        @param  param   array of string parameters
        @param  after   actions to run after main commands are processed
        @return action found and successfully executed?
    **/
    public function runAction(name:String, param:Array<Dynamic>, after:AfterScript = null):Bool {
        if (this.hasAction(name)) {
            return (this._actions[name](param, after));
        } else {
            return (false);
        }
    }

    /**
        Checks for action on keyboard press.
        @param  code    code for the key pressed
        @return a related action was found?
    **/
    public function checkKeyboard(code:Int):Bool {
        return (false);
    }

    /**
        Gets a reference to an overlay layer.
        @param  name    the overlay name (creates one if doesn't exist)
        @return a reference to the overlay
    **/
    public function getOverlay(name:String):Sprite {
        return (GlobalPlayer.area.getOverlay(name));
    }

    /**
        Removes an overlay layer.
        @param  name    the layer name to remove
        @return was the layer found and removed?
    **/
    public function removeOverlay(name:String):Bool {
        return (GlobalPlayer.area.removeOverlay(name));
    }

    /**
        Brings an overlay layer to top.
        @param  name    the layer name to remove
        @return was the layer found and moved?
    **/
    public function overlayTop(name:String):Bool {
        return (GlobalPlayer.area.overlayTop(name));
    }

    /**
        Sends an overlay layer to bottom.
        @param  name    the layer name to remove
        @return was the layer found and moved?
    **/
    public function overlayBottom(name:String):Bool {
        return (GlobalPlayer.area.overlayBottom(name));
    }

    /**
        Global bool variables parse (meant for override).
        @param  str the string to parse
        @return information about found (or not) value
    **/
    public function parseBool(str:String):ParsedBool {
        return ({ found: false, value: false });
    }

    /**
        Global string variables parse (meant for override).
        @param  str the string to parse
        @return information about found (or not) value
    **/
    public function parseString(str:String):ParsedString {
        return ({ found: false, value: '' });
    }

    /**
        Global float variables parse (meant for override).
        @param  str the string to parse
        @return information about found (or not) value
    **/
    public function parseFloat(str:String):ParsedFloat {
        return ({ found: false, value: 0 });
    }

    /**
        Global int variables parse (meant for override).
        @param  str the string to parse
        @return information about found (or not) value
    **/
    public function parseInt(str:String):ParsedInt {
        return ({ found: false, value: 0 });
    }

    /**
        Adds an action group description.
        @param  ag  action group descriptor
    **/
    public function addActionGroupDescription(ag:ActionGroup):Void {
        GlobalPlayer.parser.addAvailableGroup(ag);
    }

    /**
        Adds a global variable group description.
        @param  gg  group descriptor
    **/
    public function addGlobalVarGroupDescription(gg:GlobalGroup):Void {
        GlobalPlayer.parser.addAvailableGlobal(gg);
    }

    /**
        Gets the plugin current movie configuration.
        @param  interf  load values from settings interface?
        @return current configuration (Dynanmic data for JSON ecnoding)
    **/
    public function getConfig(interf:Bool = true):Dynamic {
        return ({ });
    }

    /**
        Sets the plugin current movie configuration.
        @param  to  the confguration (Dynamic object)
    **/
    public function setConfig(to:Dynamic):Void {

    }

    /**
        Gets the plugin current scene configuration.
        @param  sc  scene id
        @param  interf  load values from settings interface?
        @return current configuration (Dynanmic data for JSON ecnoding)
    **/
    public function getSceneConfig(sc:String, interf:Bool = true):Dynamic {
        return ({ });
    }

    /**
        Sets the plugin current movie configuration.
        @param  sc  scene id
        @param  to  the confguration (Dynamic object)
    **/
    public function setSceneConfig(sc:String, to:Dynamic):Void {

    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this._ready = false;
        for (k in this._actions.keys()) this._actions.remove(k);
        this._actions = null;
        this._access.kill();
        this._access = null;
        this.info.kill();
        this.info = null;
    }
}

/**
    Bool parsing information.
**/
typedef ParsedBool = {
    var found:Bool;
    var value:Bool;
}

/**
    String parsing information.
**/
typedef ParsedString = {
    var found:Bool;
    var value:String;
}

/**
    Float parsing information.
**/
typedef ParsedFloat = {
    var found:Bool;
    var value:Float;
}

/**
    Int parsing information.
**/
typedef ParsedInt = {
    var found:Bool;
    var value:Int;
}

/**
    Plugin configuration.
**/
typedef PluginConf = {
    var active:Bool;
    var config:Dynamic;
}