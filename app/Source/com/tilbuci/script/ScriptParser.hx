/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.script;

/** TILBUCI **/
import com.tilbuci.contraptions.SoundContraption;
import com.tilbuci.statictools.SpriteStatic;
import moonshine.editor.text.syntax.format.SyntaxColorSettings;
import com.tilbuci.narrative.BattleCardNarrative;
import com.tilbuci.contraptions.BattleContraption;
import com.tilbuci.contraptions.InventoryContraption;
import com.tilbuci.def.TBArray;
import openfl.geom.Point;
import openfl.events.MouseEvent;
import com.tilbuci.display.InstanceImage;
import openfl.ui.Mouse;
import com.tilbuci.narrative.DialogueFolderNarrative;
import com.tilbuci.narrative.CharacterNarrative;
import com.tilbuci.narrative.DialogueNarrative;
import com.tilbuci.narrative.InvItemNarrative;
import com.tilbuci.player.MovieArea;
import haxe.macro.Expr.Function;
import com.tilbuci.contraptions.CoverContraption;
import com.tilbuci.contraptions.MenuContraption;
import com.tilbuci.contraptions.DflowContraption;
import com.tilbuci.contraptions.MessagesContraption;
import com.tilbuci.contraptions.MusicContraption;
import com.tilbuci.contraptions.FormContraption;
import com.tilbuci.contraptions.InterfaceContraption;
import com.tilbuci.contraptions.BackgroundContraption;
import com.tilbuci.contraptions.TargetContraption;
import feathers.core.FocusManager;
import openfl.ui.Keyboard;
import com.tilbuci.js.ExternBrowser;
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
        variable arrays
    **/
    private var _arrays:Map<String, TBArray> = [ ];
    private var _currentArray:String = '';

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
        has the visitor ever clicked on the screen?
    **/
    public var hadInteraction:Bool = false;

    /**
        ok/confirm/success/complete actions on hold
    **/
    private var _acOk:Dynamic;

    /**
        error/deny/failure actions on hold
    **/
    private var _acError:Dynamic;

    /**
        last event sent
    **/
    private var _lastEvent:Map<String, String> = [ ];

    /**
        strings loaded from file
    **/
    private var _stringfile:Map<String, String> = [ ];

    /**
        currently loaded dialogue group
    **/
    private var _currDiag:String = '';

    /**
        currently loaded dialogue
    **/
    private var _diagInfo:DialogueNarrative;

    /**
        instance being dragged
    **/
    public var onDrag:InstanceImage = null;

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
        for (k in this._arrays.keys()) {
            this._arrays[k].kill();
            this._arrays.remove(k);
        }
        this._strings = null;
        this._floats = null;
        this._ints = null;
        this._bools = null;
        this._arrays = null;
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
        this.clearStringFile();
        this._stringfile = null;
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
            case 'arrays': for (k in this._arrays.keys()) { this._arrays[k].kill(); this._arrays.remove(k); }
            default:
                for (k in this._strings.keys()) this._strings.remove(k);
                for (k in this._floats.keys()) this._floats.remove(k);
                for (k in this._ints.keys()) this._ints.remove(k);
                for (k in this._bools.keys()) this._bools.remove(k);
                for (k in this._arrays.keys()) { this._arrays[k].kill(); this._arrays.remove(k); }
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
        this.loadContraptions();
        this.loadNarrative();
    }

    /**
        Loads current movie contraptions.json file.
    **/
    public function loadContraptions():Void {
        if (GlobalPlayer.nocache) {
            new DataLoader(true, (GlobalPlayer.base + 'movie/' + GlobalPlayer.movie.mvId + '.movie/contraptions.json'), 'GET', [ 'rand' => Date.now().getTime() ], DataLoader.MODEJSON, onContraptions);
        } else {
            new DataLoader(true, (GlobalPlayer.base + 'movie/' + GlobalPlayer.movie.mvId + '.movie/contraptions.json'), 'GET', [ ], DataLoader.MODEJSON, onContraptions);
        }
    }

    /**
        Loads current movie narrative.json file.
    **/
    public function loadNarrative():Void {
        if (GlobalPlayer.nocache) {
            new DataLoader(true, (GlobalPlayer.base + 'movie/' + GlobalPlayer.movie.mvId + '.movie/narrative.json'), 'GET', [ 'rand' => Date.now().getTime() ], DataLoader.MODEJSON, onNarrative);
        } else {
            new DataLoader(true, (GlobalPlayer.base + 'movie/' + GlobalPlayer.movie.mvId + '.movie/narrative.json'), 'GET', [ ], DataLoader.MODEJSON, onNarrative);
        }
    }

    /**
        Removes all strigs loaded from file.
    **/
    public function clearStringFile():Void {
        for (k in this._stringfile.keys()) {
            this._stringfile.remove(k);
        }
    }

    /**
        A strings file was just loaded.
    **/
    public function onStringFile(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            this.clearStringFile();
            for (k in ld.map.keys()) this._stringfile[k] = ld.map[k];
            if (this._acOk != null) this.run(this._acOk, true);
        } else {
            if (this._acError != null) this.run(this._acError, true);
        }
    }

    /**
        An array file was just loaded.
    **/
    public function onArrayFile(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (this._currentArray != '') {
                if (!this._arrays.exists(this._currentArray)) this._arrays[this._currentArray] = new TBArray();
                if (this._arrays[this._currentArray].fromJson(ld.rawtext)) {
                    this._currentArray = '';
                    if (this._acOk != null) this.run(this._acOk, true);
                } else {
                    this._currentArray = '';
                    if (this._acError != null) this.run(this._acError, true);
                }
            } else {
                if (this._acError != null) this.run(this._acError, true);
            }
        } else {
            this._currentArray = '';
            if (this._acError != null) this.run(this._acError, true);
        }
    }

    /**
        A variables list file was loaded.
    **/
    public function onVariablesFile(ok:Bool, text:String):Void {
        if (ok) {
            text = StringStatic.decrypt(text, StringStatic.md5(GlobalPlayer.movie.mvId + GlobalPlayer.movie.mvId.substr(2)).toLowerCase());
            var json = StringStatic.jsonParse(text);
            if (json == false) {
                if (this._acError != null) this.run(this._acError, true);
            } else {
                for (k in Reflect.fields(json)) {
                    var vinfo:StateVars = cast Reflect.field(json, k);
                    if (vinfo != null) {
                        switch (vinfo.t) {
                            case 's':
                                this._strings[vinfo.n] = vinfo.v;
                            case 'i':
                                this._ints[vinfo.n] = vinfo.v;
                            case 'f':
                                this._floats[vinfo.n] = vinfo.v;
                            case 'b':
                                this._bools[vinfo.n] = vinfo.v;
                        }
                    }
                }
                if (this._acOk != null) this.run(this._acOk, true);
            }
        } else {
            if (this._acError != null) this.run(this._acError, true);
        }
    }

    /**
        A dialogue group data was loaded.
    **/
    public function onDiagGroup(ok:Bool):Void {
        if (ok) {
            if (this._acOk != null) this.run(this._acOk, true);
        } else {
            this._currDiag = '';
            if (this._acError != null) this.run(this._acError, true);
        }
    }

    /**
        Contraptions.json file loaded.
        @param  ok  correctly loaded?
        @param  ld  loader reference
    **/
    private function onContraptions(ok:Bool, ld:DataLoader = null):Void {
        GlobalPlayer.contraptions.removeAll();
        GlobalPlayer.contraptions.clear();
        if (ok) {
            for (k in Reflect.fields(ld.json)) {
                if (k == 'covers') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'covers'))) {
                        var cv:CoverContraption = new CoverContraption();
                        if (cv.load(Reflect.field(Reflect.field(ld.json, 'covers'), k2))) {
                            GlobalPlayer.contraptions.covers[cv.id] = cv;
                        } else {
                            cv.kill();
                        }
                    }
                } else if (k == 'backgrounds') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'backgrounds'))) {
                        var bg:BackgroundContraption = new BackgroundContraption();
                        if (bg.load(Reflect.field(Reflect.field(ld.json, 'backgrounds'), k2))) {
                            GlobalPlayer.contraptions.backgrounds[bg.id] = bg;
                        } else {
                            bg.kill();
                        }
                    }
                } else if (k == 'menus') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'menus'))) {
                        var mn:MenuContraption = new MenuContraption();
                        if (mn.load(Reflect.field(Reflect.field(ld.json, 'menus'), k2))) {
                            GlobalPlayer.contraptions.menus[mn.id] = mn;
                        } else {
                            mn.kill();
                        }
                    }
                } else if (k == 'messages') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'messages'))) {
                        var msg:MessagesContraption = new MessagesContraption();
                        if (msg.load(Reflect.field(Reflect.field(ld.json, 'messages'), k2))) {
                            GlobalPlayer.contraptions.messages[msg.id] = msg;
                        } else {
                            msg.kill();
                        }
                    }
                } else if (k == 'dflow') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'dflow'))) {
                        var dfl:DflowContraption = new DflowContraption();
                        if (dfl.load(Reflect.field(Reflect.field(ld.json, 'dflow'), k2))) {
                            GlobalPlayer.contraptions.dflow[dfl.id] = dfl;
                        } else {
                            dfl.kill();
                        }
                    }
                } else if (k == 'inv') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'inv'))) {
                        var inv:InventoryContraption = new InventoryContraption();
                        if (inv.load(Reflect.field(Reflect.field(ld.json, 'inv'), k2))) {
                            GlobalPlayer.contraptions.inv['inv'] = inv;
                        } else {
                            inv.kill();
                        }
                    }
                } else if (k == 'bs') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'bs'))) {
                        var bs:BattleContraption = new BattleContraption();
                        if (bs.load(Reflect.field(Reflect.field(ld.json, 'bs'), k2))) {
                            GlobalPlayer.contraptions.bs['bs'] = bs;
                        } else {
                            bs.kill();
                        }
                    }
                } else if (k == 'musics') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'musics'))) {
                        var ms:MusicContraption = new MusicContraption();
                        if (ms.load(Reflect.field(Reflect.field(ld.json, 'musics'), k2))) {
                            GlobalPlayer.contraptions.musics[ms.id] = ms;
                        } else {
                            ms.kill();
                        }
                    }
                } else if (k == 'sounds') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'sounds'))) {
                        var snd:SoundContraption = new SoundContraption();
                        if (snd.load(Reflect.field(Reflect.field(ld.json, 'sounds'), k2))) {
                            GlobalPlayer.contraptions.sounds[snd.id] = snd;
                        } else {
                            snd.kill();
                        }
                    }
                } else if (k == 'targets') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'targets'))) {
                        var tg:TargetContraption = new TargetContraption();
                        if (tg.load(Reflect.field(Reflect.field(ld.json, 'targets'), k2))) {
                            GlobalPlayer.contraptions.targets[tg.id] = tg;
                        } else {
                            tg.kill();
                        }
                    }
                } else if (k == 'forms') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'forms'))) {
                        var fc:FormContraption = new FormContraption();
                        if (fc.load(Reflect.field(Reflect.field(ld.json, 'forms'), k2))) {
                            GlobalPlayer.contraptions.forms[fc.id] = fc;
                        } else {
                            fc.kill();
                        }
                    }
                } else if (k == 'interf') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'interf'))) {
                        var it:InterfaceContraption = new InterfaceContraption();
                        if (it.load(Reflect.field(Reflect.field(ld.json, 'interf'), k2))) {
                            GlobalPlayer.contraptions.interf[it.id] = it;
                        } else {
                            it.kill();
                        }
                    }
                }
            }
            
        }
    }

    /**
        Narrative.json file loaded.
        @param  ok  correctly loaded?
        @param  ld  loader reference
    **/
    private function onNarrative(ok:Bool, ld:DataLoader = null):Void {
        GlobalPlayer.narrative.clear();
        if (ok) {
            for (k in Reflect.fields(ld.json)) {
                if (k == 'chars') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'chars'))) {
                        var chnar:CharacterNarrative = new CharacterNarrative();
                        if (chnar.load(Reflect.field(Reflect.field(ld.json, 'chars'), k2))) {
                            GlobalPlayer.narrative.chars[chnar.id] = chnar;
                        } else {
                            chnar.kill();
                        }
                    }
                } else if (k == 'dialogues') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'dialogues'))) {
                        var dnar:DialogueFolderNarrative = new DialogueFolderNarrative();
                        if (dnar.load(Reflect.field(Reflect.field(ld.json, 'dialogues'), k2))) {
                            GlobalPlayer.narrative.dialogues[dnar.id] = dnar;
                        } else {
                            dnar.kill();
                        }
                    }
                } else if (k == 'items') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'items'))) {
                        var itnar:InvItemNarrative = new InvItemNarrative();
                        if (itnar.load(Reflect.field(Reflect.field(ld.json, 'items'), k2))) {
                            GlobalPlayer.narrative.items[itnar.itname] = itnar;
                        } else {
                            itnar.kill();
                        }
                    }
                } else if (k == 'cards') {
                    for (k2 in  Reflect.fields(Reflect.field(ld.json, 'cards'))) {
                        var crdar:BattleCardNarrative = new BattleCardNarrative();
                        if (crdar.load(Reflect.field(Reflect.field(ld.json, 'cards'), k2))) {
                            GlobalPlayer.narrative.cards[crdar.cardname] = crdar;
                        } else {
                            crdar.kill();
                        }
                    }
                }
            }

            // loading media collections
            for (char in GlobalPlayer.narrative.chars) {
                if (char.collection != '') {
                    GlobalPlayer.movie.loadCollection(char.collection);
                }
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
        if (str1.substr(0, 1) == '#') {
            if (this._ints.exists(str1.substr(1)))  str1 = Std.string(this._ints[str1.substr(1)]);
                else if (this._floats.exists(str1.substr(1))) str1 = Std.string(this._floats[str1.substr(1)]);
                else str1 = this.parseString(str1);
        } else if (str1.substr(0, 1) == '?') {
            if (this._bools.exists(str1.substr(1))) {
                if (this._bools[str1.substr(1)]) str1 = 'true';
                    else str1 = 'false';
            } else str1 = this.parseString(str1);
        } else {
            str1 = this.parseString(str1);
        }
        if (str2.substr(0, 1) == '#') {
            if (this._ints.exists(str2.substr(1))) str2 = Std.string(this._ints[str2.substr(1)]);
                else if (this._floats.exists(str2.substr(1))) str2 = Std.string(this._floats[str2.substr(1)]);
                else str2 = this.parseString(str2);
        } else if (str2.substr(0, 1) == '?') {
            if (this._bools.exists(str2.substr(1))) {
                if (this._bools[str2.substr(1)]) str2 = 'true';
                    else str2 = 'false';
            } else str2 = this.parseString(str2);
        } else {
            str2 = this.parseString(str2);
        }
        this._strings[this.parseString(name)] = str1 + str2;
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
        Runs gamepad-assigned actions.
    **/
    public function checkJoystick(code:String):Bool {
        var found:Bool = false;
        switch (code) {
            case 'u':
                if (GlobalPlayer.usingTarget > 0) {
                    GlobalPlayer.area.moveTarget('up');
                    found = true;
                } else {
                    found = this.runInput('keyup');
                }
            case 'd':
                if (GlobalPlayer.usingTarget > 0) {
                    GlobalPlayer.area.moveTarget('down');
                    found = true;
                } else {
                    found = this.runInput('keydown');
                }
            case 'l':
                if (GlobalPlayer.usingTarget > 0) {
                    GlobalPlayer.area.moveTarget('left');
                    found = true;
                } else {
                    found = this.runInput('keyleft');
                }
            case 'r':
                if (GlobalPlayer.usingTarget > 0) {
                    GlobalPlayer.area.moveTarget('right');
                    found = true;
                } else {
                    found = this.runInput('keyright');
                }
            case '0':
                if (GlobalPlayer.usingTarget > 0) {
                    GlobalPlayer.area.triggerTarget();
                    found = true;
                } else {
                    found = this.runInput('keyspace');
                }
            case '1':
                found = this.runInput('keyenter');
            case '2':
                found = this.runInput('keypup');
            case '3':
                found = this.runInput('keypdown');
        }
        return (found);
    }

    /**
        Runs keyboard-assigned actions.
    **/
    public function checkKeyboard(keyCode:Int):Bool {
        var found:Bool = false;
        switch (keyCode) {
            case Keyboard.UP:
                if (GlobalPlayer.usingTarget > 0) {
                    GlobalPlayer.area.moveTarget('up');
                    found = true;
                } else {
                    found = this.runInput('keyup');
                }
            case Keyboard.DOWN:
                if (GlobalPlayer.usingTarget > 0) {
                    GlobalPlayer.area.moveTarget('down');
                    found = true;
                } else {
                    found = this.runInput('keydown');
                }
            case Keyboard.LEFT:
                if (GlobalPlayer.usingTarget > 0) {
                    GlobalPlayer.area.moveTarget('left');
                    found = true;
                } else {
                    found = this.runInput('keyleft');
                    if (!found) found = this.runInput('keyletf'); // bug
                }
            case Keyboard.RIGHT:
                if (GlobalPlayer.usingTarget > 0) {
                    GlobalPlayer.area.moveTarget('right');
                    found = true;
                } else {
                    found = this.runInput('keyright');
                }
            case Keyboard.PAGE_UP:
                found = this.runInput('keypup');
            case Keyboard.PAGE_DOWN:
                found = this.runInput('keypdown');
            case Keyboard.SPACE:
                if (GlobalPlayer.usingTarget > 0) {
                    GlobalPlayer.area.triggerTarget();
                    found = true;
                } else {
                    found = this.runInput('keyspace');
                }
            case Keyboard.ENTER:
                found = this.runInput('keyenter');
            case Keyboard.HOME:
                found = this.runInput('keyhome');
            case Keyboard.END:
                found = this.runInput('keyend');
        }
        return (found);
    }

    /**
        Runs mouse-assigned actions.
    **/
    public function checkMouse(inpt:String):Bool {
        var found:Bool = false;
        switch (inpt) {
            case 'mousemiddle':
                found = this.runInput('mousemiddle');
            case 'mouseright':
                found = this.runInput('mouseright');
            case 'mousewheelup':
                found = this.runInput('mousewheelup');
            case 'mousewheeldown':
                found = this.runInput('mousewheeldown');
        }
        return (found);
    }

    /**
        Runs an input action.
    **/
    public function runInput(name:String):Bool {
        var found:Bool = false;
        if (GlobalPlayer.mdata.inputs.exists(name)) {
            switch (GlobalPlayer.mdata.inputs[name]) {
                case 'nothing': found = false;
                case 'up': this.run('{ "ac": "scene.navigate", "param": [ "up" ] }'); found = true;
                case 'down': this.run('{ "ac": "scene.navigate", "param": [ "down" ] }'); found = true;
                case 'left': this.run('{ "ac": "scene.navigate", "param": [ "left" ] }'); found = true;
                case 'right': this.run('{ "ac": "scene.navigate", "param": [ "right" ] }'); found = true;
                case 'nin': this.run('{ "ac": "scene.navigate", "param": [ "nin" ] }'); found = true;
                case 'nout': this.run('{ "ac": "scene.navigate", "param": [ "nout" ] }'); found = true;
                case 'nextkf': this.run('{ "ac": "scene.nextkeyframe", "param": [ "" ] }'); found = true;
                case 'prevkf': this.run('{ "ac": "scene.previouskeyframe", "param": [ "" ] }'); found = true;
                case 'lastkf': this.run('{ "ac": "scene.loadlastkeyframe", "param": [ "" ] }'); found = true;
                case 'firstkf': this.run('{ "ac": "scene.loadfirstkeyframe", "param": [ "" ] }'); found = true;
                case 'target': this.run('{ "ac": "target.toggle", "param": [ "" ] }'); found = true;
                default: found = this.run('{ "ac": "run", "param": [ "' + GlobalPlayer.mdata.inputs[name] + '" ] }');
            }
        }
        return (found);
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
                        return (GlobalPlayer.fullscreen());
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
                    case 'system.setkftime':
                        if (param.length > 0) {
                            var kftime:Int = this.parseInt(param[0]);
                            if (kftime >= 250) {
                                GlobalPlayer.mdata.time = kftime / 1000;
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'system.openembed':
                        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
                            return (true);
                        } else {
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
                        }
                    case 'system.closeembed':
                        ExternEmbed.embed_close();
                        return (true);
                    case 'system.embedplace':
                        if (param.length > 3) {
                            ExternEmbed.embed_setposition(
                                this.parseInt(param[0]),
                                this.parseInt(param[1]), 
                                this.parseInt(param[2]), 
                                this.parseInt(param[3])
                            );
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'system.embedreset':
                        ExternEmbed.embed_setfull();
                        return (true);
                    case 'system.quit':
                        #if runtimedesktop
                            return (GlobalPlayer.appQuit());
                        #else
                            return (false);
                        #end
                    case 'system.pwainstall':
                        #if runtimepwa
                            return (GlobalPlayer.pwaInstall());
                        #else
                            return (false);
                        #end
                    case 'system.ifhorizontal':
                        if (GlobalPlayer.area.pOrientation == MovieArea.HORIENTATION) {
                            if (Reflect.hasField(inf, 'then')) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                return (true);
                            }
                        } else {
                            if (Reflect.hasField(inf, 'else')) {
                                return (this.run(Reflect.field(inf, 'else'), true));
                            } else {
                                return (true);
                            }
                        }
                    case 'system.ifvertical':
                        if (GlobalPlayer.area.pOrientation == MovieArea.VORIENTATION) {
                            if (Reflect.hasField(inf, 'then')) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                return (true);
                            }
                        } else {
                            if (Reflect.hasField(inf, 'else')) {
                                return (this.run(Reflect.field(inf, 'else'), true));
                            } else {
                                return (true);
                            }
                        }
                    case 'system.ifpwainstalled':
                        #if runtimepwa
                            if (ExternBrowser.TBB_installedPwa()) {
                                if (Reflect.hasField(inf, 'then')) {
                                    return (this.run(Reflect.field(inf, 'then'), true));
                                } else {
                                    return (true);
                                }
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            }
                        #else
                            if (Reflect.hasField(inf, 'else')) {
                                return (this.run(Reflect.field(inf, 'else'), true));
                            } else {
                                return (true);
                            }
                        #end
                    case 'system.ifwebsite':
                        #if runtimewebsite
                            if (Reflect.hasField(inf, 'then')) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                return (true);
                            }
                        #else
                            if (Reflect.hasField(inf, 'else')) {
                                return (this.run(Reflect.field(inf, 'else'), true));
                            } else {
                                return (true);
                            }
                        #end
                    case 'system.ifpwa':
                        #if runtimepwa
                            if (Reflect.hasField(inf, 'then')) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                return (true);
                            }
                        #else
                            if (Reflect.hasField(inf, 'else')) {
                                return (this.run(Reflect.field(inf, 'else'), true));
                            } else {
                                return (true);
                            }
                        #end
                    case 'system.ifdesktop':
                        #if runtimedesktop
                            if (Reflect.hasField(inf, 'then')) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                return (true);
                            }
                        #else
                            if (Reflect.hasField(inf, 'else')) {
                                return (this.run(Reflect.field(inf, 'else'), true));
                            } else {
                                return (true);
                            }
                        #end
                    case 'system.ifmobile':
                        #if runtimemobile
                            if (Reflect.hasField(inf, 'then')) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                return (true);
                            }
                        #else
                            if (Reflect.hasField(inf, 'else')) {
                                return (this.run(Reflect.field(inf, 'else'), true));
                            } else {
                                return (true);
                            }
                        #end
                    case 'system.ifpublish':
                        #if runtimepublish
                            if (Reflect.hasField(inf, 'then')) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                return (true);
                            }
                        #else
                            if (Reflect.hasField(inf, 'else')) {
                                return (this.run(Reflect.field(inf, 'else'), true));
                            } else {
                                return (true);
                            }
                        #end
                    case 'system.ifplayer':
                        #if tilbuciplayer
                            if (Reflect.hasField(inf, 'then')) {
                                return (this.run(Reflect.field(inf, 'then'), true));
                            } else {
                                return (true);
                            }
                        #else
                            if (Reflect.hasField(inf, 'else')) {
                                return (this.run(Reflect.field(inf, 'else'), true));
                            } else {
                                return (true);
                            }
                        #end
                    case 'system.visitoringroup':
                        if ((param.length > 0) && Reflect.hasField(inf, 'then')) {
                            if (GlobalPlayer.ws.groups.contains(this.parseString(param[0]))) {
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
                    case 'system.calljs':
                        if (param.length > 0) {
                            var args:Array<String> = [ ];
                            if (param.length > 1) args.push(this.parseString(param[1]));
                            if (param.length > 2) args.push(this.parseString(param[2]));
                            if (param.length > 3) args.push(this.parseString(param[3]));
                            if (param.length > 4) args.push(this.parseString(param[4]));
                            if (param.length > 5) args.push(this.parseString(param[5]));
                            if (param.length > 6) args.push(this.parseString(param[6]));
                            return (ExternBrowser.TBB_callJs(this.parseString(param[0]), args));
                        } else {
                            return (false);
                        }

                    // runtime actions
                    case 'runtime.quit':
                        return (GlobalPlayer.appQuit());
                    case 'runtime.install':
                        #if runtimepwa
                            return (GlobalPlayer.pwaInstall());
                        #else
                            return (false);
                        #end
                    case 'runtime.ifbrowser':
                        var ifbrowserthen:Dynamic = null;
                        var ifbrowserelse:Dynamic = null;
                        if (Reflect.hasField(inf, 'then')) ifbrowserthen = Reflect.field(inf, 'then');
                        if (Reflect.hasField(inf, 'else')) ifbrowserelse = Reflect.field(inf, 'else');
                        #if runtimewebsite
                            if (ifbrowserthen != null) return (this.run(ifbrowserthen, true));
                                else return (true);
                        #elseif runtimepwa
                            if (ifbrowserthen != null) return (this.run(ifbrowserthen, true));
                                else return (true);
                        #elseif runtimedesktop
                            if (ifbrowserelse != null) return (this.run(ifbrowserelse, true));
                                else return (true);
                        #elseif runtimemobile
                            if (ifbrowserelse != null) return (this.run(ifbrowserelse, true));
                                else return (true);
                        #elseif runtimepublish
                            if (ifbrowserthen != null) return (this.run(ifbrowserthen, true));
                                else return (true);
                        #elseif tilbuciplayer
                            if (ifbrowserthen != null) return (this.run(ifbrowserthen, true));
                                else return (true);
                        #else
                            if (ifbrowserthen != null) return (this.run(ifbrowserthen, true));
                                else return (true);
                        #end
                    case 'runtime.savedata':
                        if (param.length > 0) {
                            // preparing data
                            var data:Array<StateVars> = [ ];
                            for (k in this._strings.keys()) {
                                data.push({
                                    n: k, 
                                    t: 's', 
                                    v: this._strings[k]
                                });
                            }
                            for (k in this._ints.keys()) {
                                data.push({
                                    n: k, 
                                    t: 'i', 
                                    v: this._ints[k]
                                });
                            }
                            for (k in this._floats.keys()) {
                                data.push({
                                    n: k, 
                                    t: 'f', 
                                    v: this._floats[k]
                                });
                            }
                            for (k in this._bools.keys()) {
                                data.push({
                                    n: k, 
                                    t: 'b', 
                                    v: this._bools[k]
                                });
                            }
                            // saving
                            var encdata:String = StringStatic.encrypt(StringStatic.jsonStringify(data), StringStatic.md5(GlobalPlayer.movie.mvId + GlobalPlayer.movie.mvId.substr(2)).toLowerCase());                            
                            return (GlobalPlayer.saveFile((this.parseString(param[0]) + '.' + GlobalPlayer.movie.mvId), encdata));
                        } else {
                            return (false);
                        }
                    case 'runtime.loaddata':
                        this._acOk = this._acError = null;
                        if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                        if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                        if (param.length > 0) {
                            return (GlobalPlayer.loadFile((this.parseString(param[0]) + '.' + GlobalPlayer.movie.mvId), GlobalPlayer.movie.mvId, this.onVariablesFile));
                        } else {
                            if (this._acError != null) this.run(this._acError, true);
                            return (false);
                        }
                    case 'runtime.ifdataexist':
                        if (param.length > 0) {
                            if (GlobalPlayer.existsFile(this.parseString(param[0]) + '.' + GlobalPlayer.movie.mvId)) {
                                if (Reflect.hasField(inf, 'then')) this.run(Reflect.field(inf, 'then'), true);
                            } else {
                                if (Reflect.hasField(inf, 'else')) this.run(Reflect.field(inf, 'else'), true);
                            }
                            return (true);
                        } else {
                            if (Reflect.hasField(inf, 'else')) this.run(Reflect.field(inf, 'else'), true);
                            return (false);
                        }
                    case 'runtime.startkiosk':
                        #if runtimemobile
                            return (ExternBrowser.TBB_callJs('TBB_EnterKiosk', [ ]));
                        #elseif runtimedesktop
                            ExternBrowser.TBB_kioskStart();
                            return (true);
                        #else
                            return (false);
                        #end
                    case 'runtime.endkiosk':
                        #if runtimemobile
                            return (ExternBrowser.TBB_callJs('TBB_ExitKiosk', [ ]));
                        #elseif runtimedesktop
                            ExternBrowser.TBB_kioskEnd();
                            return (true);
                        #else
                            return (false);
                        #end
                        

                    // contraptions
                    case 'contraption.message':
                        if (param.length >= 4) {
                            var mn:String = this.parseString(param[0]);
                            if (GlobalPlayer.contraptions.messages.exists(mn)) {
                                var bts:Array<String> = this.parseString(param[2]).split(';');
                                var acSelect:Dynamic = null;
                                if (Reflect.hasField(inf, 'select')) acSelect = Reflect.field(inf, 'select');
                                return (GlobalPlayer.contraptions.messagesShow(mn, this.parseString(param[1]), bts, this.parseString(param[3]), acSelect));
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'contraption.messagehide':
                        GlobalPlayer.contraptions.messagesHide();
                        return (true);
                    case 'contraption.menu':
                        if (param.length >= 6) {
                            var mn:String = this.parseString(param[0]);
                            if (GlobalPlayer.contraptions.menus.exists(mn)) {
                                var bts:Array<String> = this.parseString(param[1]).split(';');
                                var acSelect:Dynamic = null;
                                if (Reflect.hasField(inf, 'select')) acSelect = Reflect.field(inf, 'select');
                                return (GlobalPlayer.contraptions.menuShow(mn, bts, this.parseString(param[2]), acSelect, this.parseString(param[3]), this.parseInt(param[4]), this.parseInt(param[5])));
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'contraption.menuhide':
                        GlobalPlayer.contraptions.menuHide();
                        return (true);
                    case 'contraption.cover':
                        if (param.length > 0) {
                            return (GlobalPlayer.contraptions.showCover(this.parseString(param[0])));
                        } else {
                            return (false);
                        }
                    case 'contraption.coverhide':
                        GlobalPlayer.contraptions.hideCover();
                        return (true);
                    case 'contraption.background':
                        if (param.length > 0) {
                            return (GlobalPlayer.contraptions.showBackground(this.parseString(param[0])));
                        } else {
                            return (false);
                        }
                    case 'contraption.backgroundhide':
                        GlobalPlayer.contraptions.hideBackground();
                        return (true);
                    case 'contraption.showloading':
                        GlobalPlayer.contraptions.showLoadingIc();
                        return (true);
                    case 'contraption.hideloading':
                        GlobalPlayer.contraptions.hideLoadingIc();
                        return (true);
                    case 'contraption.musicplay':
                        if (param.length > 0) {
                            return (GlobalPlayer.contraptions.musicPlay(this.parseString(param[0])));
                        } else {
                            return (false);
                        }
                    case 'contraption.musicpause':
                        GlobalPlayer.contraptions.musicPause();
                        return (true);
                    case 'contraption.musicstop':
                        GlobalPlayer.contraptions.musicStop();
                        return (true);
                    case 'contraption.musicvolume':
                        if (param.length > 0) {
                            GlobalPlayer.contraptions.musicVolume(this.parseInt(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }

                    case 'contraption.soundplay':
                        if (param.length > 0) {
                            return (GlobalPlayer.contraptions.soundPlay(this.parseString(param[0])));
                        } else {
                            return (false);
                        }
                    case 'contraption.soundpause':
                        if (param.length > 0) {
                            GlobalPlayer.contraptions.soundPause(this.parseString(param[0]));
                        } else {
                            GlobalPlayer.contraptions.soundPause();
                        }
                        return (true);
                    case 'contraption.soudstop':
                        if (param.length > 0) {
                            GlobalPlayer.contraptions.soundStop(this.parseString(param[0]));
                        } else {
                            GlobalPlayer.contraptions.soundStop();
                        }
                        return (true);
                    case 'contraption.soundvolume':
                        if (param.length > 1) {
                            GlobalPlayer.contraptions.soundVolume(this.parseInt(param[0]), this.parseString(param[1]));
                            return (true);
                        } else if (param.length > 0) {
                            GlobalPlayer.contraptions.soundVolume(this.parseInt(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }

                    case 'contraption.form':
                        if (param.length > 2) {
                            var acOk:Dynamic = null;
                            var acCancel:Dynamic = null;
                            if (Reflect.hasField(inf, 'ok')) acOk = Reflect.field(inf, 'ok');
                            if (Reflect.hasField(inf, 'cancel')) acCancel = Reflect.field(inf, 'cancel');
                            return(GlobalPlayer.contraptions.showForm(this.parseString(param[0]), this.parseInt(param[1]), this.parseInt(param[2]), acOk, acCancel));
                        } else {
                            return (false);
                        }
                    case 'contraption.formvalue':
                        if (param.length > 1) {
                            return(GlobalPlayer.contraptions.setFormValue(this.parseString(param[0]), param[1]));
                        } else {
                            return (false);
                        }
                    case 'contraption.formhide':
                        GlobalPlayer.contraptions.hideForm();
                        return (true);
                    case 'contraption.formsetstepper':
                        if (param.length > 3) {
                            return (GlobalPlayer.contraptions.setFormStepper(this.parseString(param[0]), this.parseInt(param[1]), this.parseInt(param[2]), this.parseInt(param[3])));
                        } else {
                            return (false);
                        }
                    case 'contraption.interface':
                        if (param.length > 2) {
                            return(GlobalPlayer.contraptions.showInterface(this.parseString(param[0]), this.parseInt(param[1]), this.parseInt(param[2])));
                        } else {
                            return (false);
                        }
                    case 'contraption.interfacehide':
                        if (param.length > 0) {
                            GlobalPlayer.contraptions.hideInterface(this.parseString(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'contraption.interfacehideall':
                        GlobalPlayer.contraptions.hideAllInterfaces();
                        return (true);
                    case 'contraption.interfacetext':
                        if (param.length > 1) {
                            return(GlobalPlayer.contraptions.setInterfaceText(this.parseString(param[0]), this.parseString(param[1])));
                        } else {
                            return (false);
                        }
                    case 'contraption.interfaceanimframe':
                        if (param.length > 1) {
                            return(GlobalPlayer.contraptions.setInterfaceFrame(this.parseString(param[0]), this.parseInt(param[1])));
                        } else {
                            return (false);
                        }
                    case 'contraption.interfaceanimplay':
                        if (param.length > 0) {
                            return(GlobalPlayer.contraptions.playInterface(this.parseString(param[0])));
                        } else {
                            return (false);
                        }
                    case 'contraption.interfaceanimpause':
                        if (param.length > 0) {
                            return(GlobalPlayer.contraptions.pauseInterface(this.parseString(param[0])));
                        } else {
                            return (false);
                        }

                    // narrative actions
                    case 'inventory.show':
                        var invclose:Dynamic = null;
                        if (Reflect.hasField(inf, 'complete')) invclose = Reflect.field(inf, 'complete');
                        GlobalPlayer.contraptions.inventoryShow(invclose);
                        return (true);
                    case 'inventory.close':
                        GlobalPlayer.contraptions.invHide();
                        return (true);
                    case 'inventory.addkeyitem':
                        if (param.length > 0) {
                            GlobalPlayer.narrative.addKeyItem(this.parseString(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.removekeyitem':
                        if (param.length > 0) {
                            GlobalPlayer.narrative.removeKeyItem(this.parseString(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.clearkeyitems':
                        GlobalPlayer.narrative.clearKeyItems();
                        return (true);
                    case 'inventory.haskeyitem':
                        if (param.length > 0) {
                            if (GlobalPlayer.narrative.hasKeyItem(this.parseString(param[0]))) {
                                if (Reflect.hasField(inf, 'then')) {
                                    this.run(Reflect.field(inf, 'then'), true);
                                }
                            } else {
                                if (Reflect.hasField(inf, 'else')) {
                                    this.run(Reflect.field(inf, 'else'), true);
                                }
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.addconsumable':
                        if (param.length > 1) {
                            GlobalPlayer.narrative.addConsumableItem(this.parseString(param[0]), this.parseInt(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.removeconsumable':
                        if (param.length > 0) {
                            GlobalPlayer.narrative.removeConsumableItem(this.parseString(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.consumeitem':
                        if (param.length > 0) {
                            GlobalPlayer.narrative.consumeItem(this.parseString(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.clearconsumables':
                        GlobalPlayer.narrative.clearConsumableItems();
                        return (true);
                    case 'inventory.tostring':
                        if (param.length > 0) {
                            this._strings[this.parseString(param[0])] = GlobalPlayer.narrative.currentItems();
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.fromstring':
                        if (param.length > 0) {
                            GlobalPlayer.narrative.loadItems(this._strings[this.parseString(param[0])]);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.keytostring':
                        if (param.length > 0) {
                            this._strings[this.parseString(param[0])] = GlobalPlayer.narrative.currentKeyItems();
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.keyfromstring':
                        if (param.length > 0) {
                            GlobalPlayer.narrative.loadKeyItems(this._strings[this.parseString(param[0])]);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.constostring':
                        if (param.length > 0) {
                            this._strings[this.parseString(param[0])] = GlobalPlayer.narrative.currentConsItems();
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'inventory.consfromstring':
                        if (param.length > 0) {
                            GlobalPlayer.narrative.loadConsItems(this._strings[this.parseString(param[0])]);
                            return (true);
                        } else {
                            return (false);
                        }

                    case 'battle.show':
                        if (param.length > 1) {
                            var pl:Array<String> = this.parseString(param[0]).split(',');
                            var op:Array<String> = this.parseString(param[1]).split(',');
                            var plfinal:Array<String> = [ ];
                            var opfinal:Array<String> = [ ];
                            for (i in 0...pl.length) {
                                if (i < 5) plfinal.push(this.parseString(StringTools.trim(pl[i])));
                            }
                            for (i in 0...op.length) {
                                if (i < 5) opfinal.push(this.parseString(StringTools.trim(op[i])));
                            }
                            var onwin:Dynamic = null;
                            var onloose:Dynamic = null;
                            if (Reflect.hasField(inf, 'win')) onwin = Reflect.field(inf, 'win');
                            if (Reflect.hasField(inf, 'loose')) onloose = Reflect.field(inf, 'loose');
                            GlobalPlayer.contraptions.battleShow(onwin, onloose, plfinal, opfinal);
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'battle.close':
                        GlobalPlayer.contraptions.bsHide();
                        return (true);
                    case "battle.setattribute":
                        if (param.length > 3) {
                            if (GlobalPlayer.contraptions.bs.exists('bs')) {
                                GlobalPlayer.contraptions.bs['bs'].setAttributes(true, (this.parseInt(param[0])-1), this.parseInt(param[1]), this.parseInt(param[2]), this.parseInt(param[3]));
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case "battle.setopponent":
                        if (param.length > 3) {
                            if (GlobalPlayer.contraptions.bs.exists('bs')) {
                                GlobalPlayer.contraptions.bs['bs'].setAttributes(false, (this.parseInt(param[0])-1), this.parseInt(param[1]), this.parseInt(param[2]), this.parseInt(param[3]));
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }


                    case 'dialogue.loadgroup':
                        this._currDiag = '';
                        this._diagInfo = null;
                        if (param.length > 0) {
                            this._acOk = this._acError = null;
                            if (GlobalPlayer.narrative.dialogues.exists(this.parseString(param[0]))) {
                                this._currDiag = this.parseString(param[0]);
                                if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                                if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                                GlobalPlayer.narrative.dialogues[this.parseString(param[0])].loadContents(onDiagGroup);
                                return (true);
                            } else {
                                if (Reflect.hasField(inf, 'error')) {
                                    this.run(Reflect.field(inf, 'error'), true);
                                }
                                return (false);
                            }
                        } else {
                            if (Reflect.hasField(inf, 'error')) {
                                this.run(Reflect.field(inf, 'error'), true);
                            }
                            return (false);
                        }
                    case 'dialogue.start':
                        this._diagInfo = null;
                        if ((param.length == 0) || (this._currDiag == '') || (!GlobalPlayer.narrative.dialogues.exists(this._currDiag))) {
                            return (false);
                        } else {
                            if (!GlobalPlayer.narrative.dialogues[this._currDiag].diags.exists(this.parseString(param[0]))) {
                                return (false);
                            } else {
                                this._diagInfo = GlobalPlayer.narrative.dialogues[this._currDiag].diags[this.parseString(param[0])];
                                this._diagInfo.show(0);
                                return (true);
                            }
                        }
                    case 'dialogue.next':
                        if (this._diagInfo != null) {
                            this._diagInfo.next();
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'dialogue.previous':
                        if (this._diagInfo != null) {
                            this._diagInfo.previous();
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'dialogue.last':
                        if (this._diagInfo != null) {
                            this._diagInfo.last();
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'dialogue.first':
                        if (this._diagInfo != null) {
                            this._diagInfo.first();
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'dialogue.close':
                        if (this._diagInfo != null) {
                            this._diagInfo.close();
                            this._diagInfo = null;
                            return (true);
                        } else {
                            return (false);
                        }

                    
                    // movie actions
                    case 'movie.load':
                        GlobalPlayer.contraptions.removeContraptions(true);
                        GlobalPlayer.movie.loadMovie(this.parseString(param[0]));
                        return (true);

                    // scene and keyframe actions
                    case 'scene.load':
                        return(GlobalPlayer.movie.loadScene(this.parseString(param[0])));
                    case 'scene.historyback':
                        if (GlobalPlayer.history.length > 0) {
                            GlobalPlayer.movie.preventHistory = true;
                            return(GlobalPlayer.movie.loadScene(GlobalPlayer.history.pop()));
                        } else {
                            return (false);
                        }
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
                    case 'scene.nextkeyframe':
                        var nkf:Int = GlobalPlayer.area.currentKf + 1;
                        if (nkf >= GlobalPlayer.movie.scene.keyframes.length) nkf = 0;
                        GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[nkf], nkf);
                        return (true);
                    case 'scene.previouskeyframe':
                        var pkf:Int = GlobalPlayer.area.currentKf - 1;
                        if (pkf < 0) pkf = GlobalPlayer.movie.scene.keyframes.length - 1;
                        GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[pkf], pkf);
                        return (true);
                    case 'scene.loadfirstkeyframe':
                        GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[0], 0);
                        return (true);
                    case 'scene.loadlastkeyframe':
                        GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[(GlobalPlayer.movie.scene.keyframes.length - 1)], (GlobalPlayer.movie.scene.keyframes.length - 1));
                        return (true);
                    case 'scene.loadkeyframe':
                        if (param.length > 0) {
                            var lkf:Int = this.parseInt(param[0]) - 1;
                            if ((lkf < 0) || (lkf > (GlobalPlayer.movie.scene.keyframes.length - 1))) {
                                return (false);
                            } else {
                                GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[lkf], lkf);
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'scene.shake':
                        if (param.length > 1) {
                            var end:Dynamic = null;
                            if (Reflect.hasField(inf, 'end')) end = Reflect.field(inf, 'end');
                            SpriteStatic.shake(GlobalPlayer.area, this.parseFloat(param[0]), this.parseFloat(param[1]), end);
                            return (true);
                        } else {
                            return (false);
                        }
                        
                    // instance actions
                    case 'instance.morezoom':
                        if (param.length > 1) {
                            var inst:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[0]));
                            if (inst == null) {
                                return (false);
                            } else {
                                var factor:Float = this.parseFloat(param[1]);
                                var wd:Float = inst.width * (1 + (factor / 100));
                                var ht:Float = inst.height * (1 + (factor / 100));
                                var px:Float = inst.x - ((wd - inst.width) / 2);
                                var py:Float = inst.y - ((ht - inst.height) / 2);
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'width', wd, wd);
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'height', ht, ht);
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'x', px, px);
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'y', py, py);
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'instance.lesszoom':
                        if (param.length > 1) {
                            var inst:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[0]));
                            if (inst == null) {
                                return (false);
                            } else {
                                var factor:Float = this.parseFloat(param[1]);
                                var wd:Float = inst.width * (1 - (factor / 100));
                                var ht:Float = inst.height * (1 - (factor / 100));
                                var px:Float = inst.x - ((wd - inst.width) / 2);
                                var py:Float = inst.y - ((ht - inst.height) / 2);
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'width', wd, wd);
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'height', ht, ht);
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'x', px, px);
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'y', py, py);
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'instance.clearzoom':
                        if (param.length > 0) {
                            var inst:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[0]));
                            if (inst == null) {
                                return (false);
                            } else {
                                GlobalPlayer.area.releaseProperty(inst.getInstName(), 'width');
                                GlobalPlayer.area.releaseProperty(inst.getInstName(), 'height');
                                GlobalPlayer.area.releaseProperty(inst.getInstName(), 'x');
                                GlobalPlayer.area.releaseProperty(inst.getInstName(), 'y');
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'instance.moveup':
                        if (param.length > 1) {
                            var inst:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[0]));
                            if (inst == null) {
                                return (false);
                            } else {
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'y', (inst.y - this.parseFloat(param[1])), (inst.y - this.parseFloat(param[1])));
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'instance.movedown':
                        if (param.length > 1) {
                            var inst:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[0]));
                            if (inst == null) {
                                return (false);
                            } else {
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'y', (inst.y + this.parseFloat(param[1])), (inst.y - this.parseFloat(param[1])));
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'instance.moveleft':
                        if (param.length > 1) {
                            var inst:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[0]));
                            if (inst == null) {
                                return (false);
                            } else {
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'x', (inst.x - this.parseFloat(param[1])), (inst.x - this.parseFloat(param[1])));
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'instance.moveright':
                        if (param.length > 1) {
                            var inst:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[0]));
                            if (inst == null) {
                                return (false);
                            } else {
                                GlobalPlayer.area.setProperty(inst.getInstName(), 'x', (inst.x + this.parseFloat(param[1])), (inst.x - this.parseFloat(param[1])));
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'instance.clearmove':
                        if (param.length > 0) {
                            var inst:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[0]));
                            if (inst == null) {
                                return (false);
                            } else {
                                GlobalPlayer.area.releaseProperty(inst.getInstName(), 'x');
                                GlobalPlayer.area.releaseProperty(inst.getInstName(), 'y');
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'instance.startdrag':
                        if (param.length > 0) {
                            var inst:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[0]));
                            if (inst == null) {
                                return (false);
                            } else {
                                this._acOk = null;
                                if (Reflect.hasField(inf, 'complete')) this._acOk = Reflect.field(inf, 'complete');
                                this.onDrag = inst;
                                if (GlobalPlayer.usingTarget != 0) {

                                } else {
                                    if (!GlobalPlayer.area.hasEventListener(MouseEvent.MOUSE_MOVE)) {
                                        GlobalPlayer.area.addEventListener(MouseEvent.MOUSE_MOVE, this.onDragMove);
                                    }
                                    if (!GlobalPlayer.area.stage.hasEventListener(MouseEvent.MOUSE_UP)) {
                                        GlobalPlayer.area.stage.addEventListener(MouseEvent.MOUSE_UP, this.onDragMoveStop);
                                    }
                                }
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'instance.stopdrag':
                        this.onDragMoveStop(null);
                        return (true);

                    case 'instance.isoverlapping':
                        if (param.length > 1) {
                            var inst1:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[0]));
                            var inst2:InstanceImage = GlobalPlayer.area.pickInstance(this.parseString(param[1]));
                            if ((inst1 == null) || (inst2 == null)) {
                                if (Reflect.hasField(inf, 'else')) {
                                    return (this.run(Reflect.field(inf, 'else'), true));
                                } else {
                                    return (true);
                                }
                            } else {
                                if (inst1.hitTestObject(inst2)) {
                                    if (Reflect.hasField(inf, 'then')) {
                                        return (this.run(Reflect.field(inf, 'then'), true));
                                    } else {
                                        return (true);
                                    }
                                } else {
                                    if (Reflect.hasField(inf, 'else')) {
                                        return (this.run(Reflect.field(inf, 'else'), true));
                                    } else {
                                        return (true);
                                    }
                                }
                            }
                        } else {
                            return (false);
                        }

                    case 'instance.zoom':
                        if (param.length > 0) {
                            return (GlobalPlayer.contraptions.zoomInstance(this.parseString(param[0])));
                        } else {
                            return (false);
                        }
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
                    case 'target.show':
                        GlobalPlayer.area.showTarget();
                        return (true);
                    case 'target.hide':
                        GlobalPlayer.area.hideTarget();
                        return (true);
                    case 'target.toggle':
                        GlobalPlayer.area.toggleTarget();
                        return (true);
                    case 'target.setposition':
                        if (param.length > 1) {
                            GlobalPlayer.area.setTargetPos(this.parseInt(param[0]), this.parseInt(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'target.clear':
                        GlobalPlayer.area.clearTarget();
                        return (true);
                    case 'target.set':
                        if (param.length > 0) {
                            return (GlobalPlayer.area.setTarget(this.parseString(param[0])));
                        } else {
                            return (false);
                        }
                        
                    case 'mouse.hide':
                        Mouse.hide();
                        GlobalPlayer.cursorVisible = false;
                        GlobalPlayer.area.noMouseOver();
                        return (true);
                    case 'mouse.show':
                        GlobalPlayer.cursorVisible = true;
                        Mouse.show();
                        return (true);

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
                            var arcmd:Array<Dynamic> = [ ];
                            var ok:Bool = false;
                            try {
                                arcmd = cast (acCancel, Array<Dynamic>);
                                ok = true;
                            } catch (e) { ok = false; }
                            if (!ok) acCancel = null;
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
                    case 'input.add':
                        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
                            return (true);
                        } else {
                            if (param.length == 4) {
                                GlobalPlayer.area.addInput(
                                    this.parseString(param[0]), 
                                    this.parseInt(param[1]), 
                                    this.parseInt(param[2]), 
                                    this.parseInt(param[3])
                                );
                                return (true);
                            } else if (param.length > 4) {
                                GlobalPlayer.area.addInput(
                                    this.parseString(param[0]), 
                                    this.parseInt(param[1]), 
                                    this.parseInt(param[2]), 
                                    this.parseInt(param[3]), 
                                    this.parseString(param[4])
                                );
                                return (true);
                            } else {
                                return (false);
                            }
                        }
                    case 'input.addtarea':
                        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
                            return (true);
                        } else {
                            if (param.length == 5) {
                                GlobalPlayer.area.addTarea(
                                    this.parseString(param[0]), 
                                    this.parseInt(param[1]), 
                                    this.parseInt(param[2]), 
                                    this.parseInt(param[3]), 
                                    this.parseInt(param[4])
                                );
                                return (true);
                            } else {
                                return (false);
                            }
                        }
                    case 'input.addnumeric':
                        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
                            return (true);
                        } else {
                            if (param.length > 4) {
                                GlobalPlayer.area.addNumeric(
                                    this.parseString(param[0]), 
                                    this.parseInt(param[1]), 
                                    this.parseInt(param[2]), 
                                    this.parseInt(param[3]), 
                                    this.parseInt(param[4])
                                );
                                return (true);
                            } else {
                                return (false);
                            }
                        }

                    case 'input.place':
                        if (param.length > 3) {
                            GlobalPlayer.area.placeInput(
                                this.parseString(param[0]), 
                                this.parseInt(param[1]), 
                                this.parseInt(param[2]), 
                                this.parseInt(param[3])
                            );
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.remove':
                        if (param.length > 0) {
                            GlobalPlayer.area.removeInput(this.parseString(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.removeall':
                        GlobalPlayer.area.removeAllInputs();
                        return (true);
                    case 'input.settext':
                        if (param.length > 1) {
                            GlobalPlayer.area.setInputText(this.parseString(param[0]), this.parseString(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.setpassword':
                        if (param.length > 1) {
                            GlobalPlayer.area.setInputPassword(this.parseString(param[0]), this.parseBool(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }

                    case 'input.placetarea':
                        if (param.length > 4) {
                            GlobalPlayer.area.placeTarea(
                                this.parseString(param[0]), 
                                this.parseInt(param[1]), 
                                this.parseInt(param[2]), 
                                this.parseInt(param[3]), 
                                this.parseInt(param[4])
                            );
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.removetarea':
                        if (param.length > 0) {
                            GlobalPlayer.area.removeTarea(this.parseString(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.removealltareas':
                        GlobalPlayer.area.removeAllTareas();
                        return (true);
                    case 'input.settextarea':
                        if (param.length > 1) {
                            GlobalPlayer.area.setTareaText(this.parseString(param[0]), this.parseString(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }

                    case 'input.placenumeric':
                        if (param.length > 3) {
                            GlobalPlayer.area.placeNumeric(
                                this.parseString(param[0]), 
                                this.parseInt(param[1]), 
                                this.parseInt(param[2]), 
                                this.parseInt(param[3])
                            );
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.removenumeric':
                        if (param.length > 0) {
                            GlobalPlayer.area.removeNumeric(this.parseString(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.removeallnumerics':
                        GlobalPlayer.area.removeAllNumerics();
                        return (true);
                    case 'input.setnumeric':
                        if (param.length > 1) {
                            GlobalPlayer.area.setNumericValue(this.parseString(param[0]), this.parseInt(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.setnumericbounds':
                        if (param.length > 1) {
                            GlobalPlayer.area.setNumericBounds(
                                this.parseString(param[0]), 
                                this.parseInt(param[1]), 
                                this.parseInt(param[2]), 
                                this.parseInt(param[3])
                            );
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.addtoggle':
                        if (GlobalPlayer.mode == Player.MODE_EDITOR) {
                            return (true);
                        } else {
                            if (param.length > 3) {
                                GlobalPlayer.area.addToggle(
                                    this.parseString(param[0]), 
                                    this.parseBool(param[1]), 
                                    this.parseInt(param[2]), 
                                    this.parseInt(param[3])
                                );
                                return (true);
                            } else {
                                return (false);
                            }
                        }
                    case 'input.placetoggle':
                        if (param.length > 2) {
                            GlobalPlayer.area.placeToggle(
                                this.parseString(param[0]), 
                                this.parseInt(param[1]), 
                                this.parseInt(param[2])
                            );
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.removetoggle':
                        if (param.length > 0) {
                            GlobalPlayer.area.removeToggle(this.parseString(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.removealltoggles':
                        GlobalPlayer.area.removeAllToggles();
                        return (true);
                    case 'input.settoggle':
                        if (param.length > 1) {
                            GlobalPlayer.area.setToggleValue(this.parseString(param[0]), this.parseBool(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'input.inverttoggle':
                        if (param.length > 0) {
                            GlobalPlayer.area.invertToggle(this.parseString(param[0]));
                            return (true);
                        } else {
                            return (false);
                        }

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
                            var prData:Array<Dynamic> = [ ];
                            if (param.length > 1) {
                                for (i in 1...param.length) {
                                    if (Std.string(param[i]).substr(0, 1) == '#') {
                                        if (this._ints.exists(Std.string(param[i]).substr(1))) {
                                            prData.push(this._ints[Std.string(param[i]).substr(1)]);
                                        } else if (this._floats.exists(Std.string(param[i]).substr(1))) {
                                            prData.push(this._floats[Std.string(param[i]).substr(1)]);
                                        } else {
                                            prData.push(this.parseString(param[i]));
                                        }
                                    } else if (Std.string(param[i]).substr(0, 1) == '?') {
                                        if (this._bools.exists(Std.string(param[i]).substr(1))) {
                                            prData.push(this._bools[Std.string(param[i]).substr(1)]);
                                        } else {
                                            prData.push(this.parseString(param[i]));
                                        }
                                    } else {
                                        prData.push(this.parseString(param[i]));
                                    }
                                }
                            }
                            this._lastEvent = [
                                'name' => this.parseString(param[0]), 
                                'when' => Date.now().toString(), 
                                'data' => StringStatic.jsonStringify(prData), 
                                'movieid' => GlobalPlayer.movie.mvId, 
                                'sceneid' => GlobalPlayer.movie.scId, 
                                'movietitle' => GlobalPlayer.mdata.title, 
                                'scenetitle' => GlobalPlayer.movie.scene.title, 
                                'visitor' => GlobalPlayer.ws.user, 
                                'sessionid' => GlobalPlayer.session, 
                            ];
                            GlobalPlayer.ws.send('Visitor/Event', this._lastEvent, onDataEvent);
                            return (true);
                    case 'data.eventclear':
                        try {
                            var eventData:SharedObject = SharedObject.getLocal(GlobalPlayer.movie.mvId + '_eventsheld');
                            eventData.data.events = [ ];
                            eventData.flush();
                            eventData.close();
                        } catch (e) { }
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
                                case 'none': GlobalPlayer.mdata.origin = this.parseString(param[0]);
                                default: GlobalPlayer.mdata.origin = 'alpha';
                            }
                            return (true);
                        } else {
                            return (false);
                        }
                    
                        
                    // string values
                    case 'string.loadfile':
                        if (param.length > 0) {
                            this._acOk = this._acError = null;
                            if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                            if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                            var cache:Map<String, Dynamic> = null;
                            if (GlobalPlayer.nocache) cache = [ 'rand' => Math.ceil(Math.random()*10000) ];
                            new DataLoader(true, (GlobalPlayer.path + 'media/strings/' + this.parseString(param[0]) + '.json'), 'GET', cache, DataLoader.MODEMAP, onStringFile);
                            return (true);
                        } else {
                            if (Reflect.hasField(inf, 'error')) {
                                this.run(Reflect.field(inf, 'error'), true);
                            }
                            return (false);
                        }
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
                    case 'if.stringemail':
                        if ((param.length > 0) && Reflect.hasField(inf, 'then')) {
                            if (StringStatic.validateEmail(this.parseString(param[0]))) {
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

                    // array manipulation
                    case 'array.loadfile':
                        if (param.length > 0) {
                            this._acOk = this._acError = null;
                            if (Reflect.hasField(inf, 'success')) this._acOk = Reflect.field(inf, 'success');
                            if (Reflect.hasField(inf, 'error')) this._acError = Reflect.field(inf, 'error');
                            var cache:Map<String, Dynamic> = null;
                            this._currentArray = this.parseString(param[0]);
                            if (GlobalPlayer.nocache) cache = [ 'rand' => Math.ceil(Math.random()*10000) ];
                            new DataLoader(true, (GlobalPlayer.path + 'media/strings/' + this.parseString(param[0]) + '.json'), 'GET', cache, DataLoader.MODETEXT, onArrayFile);
                            return (true);
                        } else {
                            if (Reflect.hasField(inf, 'error')) {
                                this.run(Reflect.field(inf, 'error'), true);
                            }
                            return (false);
                        }
                    case 'array.create':
                        if (param.length > 0) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                return (false);
                            } else {
                                this._arrays[this.parseString(param[0])] = new TBArray();
                                return (true);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.remove':
                        if (param.length > 0) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._arrays[this.parseString(param[0])].kill();
                                this._arrays.remove(this.parseString(param[0]));
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.push':
                        if (param.length > 1) {
                            this._arrays[this.parseString(param[0])].push(Std.string(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'array.set':
                        if (param.length > 2) {
                            this._arrays[this.parseString(param[0])].set(this.parseInt(param[1]), Std.string(param[2]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'array.get':
                        if (param.length > 2) {
                            this._strings[this.parseString(param[2])] = this._arrays[this.parseString(param[0])].get(this.parseInt(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'array.getint':
                        if (param.length > 2) {
                            this._ints[this.parseString(param[2])] = this._arrays[this.parseString(param[0])].getInt(this.parseInt(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'array.getfloat':
                        if (param.length > 2) {
                            this._floats[this.parseString(param[2])] = this._arrays[this.parseString(param[0])].getFloat(this.parseInt(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'array.getbool':
                        if (param.length > 2) {
                            this._bools[this.parseString(param[2])] = this._arrays[this.parseString(param[0])].getBool(this.parseInt(param[1]));
                            return (true);
                        } else {
                            return (false);
                        }
                    case 'array.clear':
                        if (param.length > 0) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._arrays[this.parseString(param[0])].clear();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.current':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._strings[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].current();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.next':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._strings[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].next();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.previous':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._strings[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].previous();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.currentint':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._ints[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].currentInt();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.nextint':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._ints[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].nextInt();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.previousint':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._ints[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].previousInt();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
					
					case 'array.currentfloat':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._floats[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].currentFloat();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.nextfloat':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._floats[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].nextFloat();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.previousfloat':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._floats[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].previousFloat();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
					
					case 'array.currentbool':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._bools[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].currentBool();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.nextbool':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._bools[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].nextBool();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.previousbool':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._bools[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].previousBool();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.setindex':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._arrays[this.parseString(param[0])].setIndex(this.parseInt(param[1]));
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.getindex':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._ints[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].currentIndex();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.tostring':
                        if (param.length > 1) {
                            if (this._arrays.exists(this.parseString(param[0]))) {
                                this._strings[this.parseString(param[1])] = this._arrays[this.parseString(param[0])].toJson();
                                return (true);
                            } else {
                                return (false);
                            }
                        } else {
                            return (false);
                        }
                    case 'array.fromstring':
                        if (param.length > 1) {
                            if (!this._arrays.exists(this.parseString(param[0]))) {
                                this._arrays[this.parseString(param[0])] = new TBArray();
                            }
                            return (this._arrays[this.parseString(param[0])].fromJson(this._strings[this.parseString(param[1])]));
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
            } else if (str.substr(0, 7) == "$_INPUT") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    return (GlobalPlayer.area.getInputText(arstr[1]));
                } else {
                    return (str);
                }
            } else if (str.substr(0, 7) == "$_TAREA") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    return (GlobalPlayer.area.getTareaText(arstr[1]));
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
            } else if (str.substr(0, 6) == "$_FORM") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    return (GlobalPlayer.contraptions.getFormValue(arstr[1]));
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
                    case "$_SESSION": return(GlobalPlayer.session);
                    case "$_YEAR": return(DateTools.format(Date.now(), "%Y"));
                    case "$_MONTH": return(DateTools.format(Date.now(), "%m"));
                    case "$_DAY": return(DateTools.format(Date.now(), "%d"));
                    case "$_HOUR": return(DateTools.format(Date.now(), "%H"));
                    case "$_MINUTE": return(DateTools.format(Date.now(), "%M"));
                    case "$_SECOND": return(DateTools.format(Date.now(), "%S"));
                    case "$_DATE": return(DateTools.format(Date.now(), "%Y-%m-%d"));
                    case "$_TIME": return(DateTools.format(Date.now(), "%H:%M:%S"));
                    default:
                        if (this._strings.exists(str.substr(1))) { // look on stantard variables
                            return (this._strings[str.substr(1)]);
                        } else if (this._stringfile.exists(str.substr(1))) { // look on loaded string file
                            return (this._stringfile[str.substr(1)]);
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
            } else if (str.substr(0, 8) == "?_TOGGLE") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    return (GlobalPlayer.area.getToggleValue(this.parseString(arstr[1])));
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
                    case "?_HADINTERACTION": return(this.hadInteraction);
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
            } else if (str.substr(0, 9) == "#_NUMERIC") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    return (GlobalPlayer.area.getNumericValue(this.parseString(arstr[1])));
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
                    case "#_CONTENTX": return(GlobalPlayer.contentPosition.x);
                    case "#_CONTENTY": return(GlobalPlayer.contentPosition.y);
                    case "#_CONTENTWIDTH": return(GlobalPlayer.contentWidth);
                    case "#_CONTENTHEIGHT": return(GlobalPlayer.contentHeight);
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
        @return the variable value if found, if not, tries to parse the string as an int value
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
            } else if (str.substr(0, 15) == "#_INVCONSUMABLE") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    return (GlobalPlayer.narrative.consumableAmount(this.parseString(arstr[1])));
                } else {
                    return (0);
                }
            } else if (str.substr(0, 9) == "#_NUMERIC") {
                var arstr:Array<String> = str.split(':');
                if (arstr.length == 2) {
                    return (GlobalPlayer.area.getNumericValue(this.parseString(arstr[1])));
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
                    case "#_CONTENTX": return(Math.round(GlobalPlayer.contentPosition.x));
                    case "#_CONTENTY": return(Math.round(GlobalPlayer.contentPosition.y));
                    case "#_CONTENTWIDTH": return(Math.round(GlobalPlayer.contentWidth));
                    case "#_CONTENTHEIGHT": return(Math.round(GlobalPlayer.contentHeight));
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

    public function onDragMove(evt:MouseEvent):Void {
        if (this.onDrag != null) {
            var localpt:Point = this.onDrag.parent.globalToLocal(new Point(evt.stageX, evt.stageY));
            var px:Int = Math.round(localpt.x - this.onDrag.lastClick.x);
            var py:Int = Math.round(localpt.y - this.onDrag.lastClick.y);
            GlobalPlayer.area.setProperty(this.onDrag.getInstName(), 'x', px, px);
            GlobalPlayer.area.setProperty(this.onDrag.getInstName(), 'y', py, py);
        }
    }

    public function onDragMoveStop(evt:MouseEvent):Void {
        this.onDrag = null;
        if (GlobalPlayer.area.hasEventListener(MouseEvent.MOUSE_MOVE)) {
            GlobalPlayer.area.removeEventListener(MouseEvent.MOUSE_MOVE, this.onDragMove);
        }
        if (GlobalPlayer.area.stage.hasEventListener(MouseEvent.MOUSE_UP)) {
            GlobalPlayer.area.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onDragMoveStop);
        }
        if (this._acOk != null) this.run(this._acOk, true);
        this._acOk = null;
    }

    /**
        Event recording return.
    **/
    private function onDataEvent(ok:Bool, ld:DataLoader):Void {
        var hold:Bool = false;
        var eventheld:Array<Map<String, String>> = [ ];
        try {
            var eventData:SharedObject = SharedObject.getLocal(GlobalPlayer.movie.mvId + '_eventsheld');
            for (k in Reflect.fields(eventData.data.events)) {
                eventheld.push(Reflect.field(eventData.data.events, k));
            }
            eventData.close();
        } catch (e) { }
        if (!ok) {
            if (this._lastEvent.exists('name')) hold = true;
        } else {
            if (ld.map['e'] != 0) {
                if (this._lastEvent.exists('name')) hold = true;
            } else {
                // are there held events so send?
                if (eventheld.length > 0) {
                    // remove previous event?
                    if (!this._lastEvent.exists('name')) eventheld.shift();
                    // another one to send?
                    if (eventheld.length > 0) {
                        GlobalPlayer.ws.send('Visitor/Event', eventheld[0], onDataEvent);
                    }
                }
            }
        }
        // hold event to send later?
        if (hold) {
            eventheld.push(this._lastEvent);
            while(eventheld.length > 100) eventheld.shift();
            try {
                var eventData:SharedObject = SharedObject.getLocal(GlobalPlayer.movie.mvId + '_eventsheld');
                eventData.data.events = eventheld;
                eventData.flush();
                eventData.close();
            } catch (e) { }
        }
        this._lastEvent = [ ];
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

    /**
        Sets the embed content size and position.
    **/
    static function embed_setposition(x:Int, y:Int, width:Int, height:Int):Void;

    /**
        Returns the embed content to full size.
    **/
    static function embed_setfull():Void;

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

    /**
        Sets the embed content size and position.
    **/
    static function embed_setposition(x:Int, y:Int, width:Int, height:Int):Void { trace ('HTML5 embed content not supported on this platform.'); }

    /**
        Returns the embed content to full size.
    **/
    static function embed_setfull():Void { trace ('HTML5 embed content not supported on this platform.'); }

}
#end