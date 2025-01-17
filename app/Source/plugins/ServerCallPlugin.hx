/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package plugins;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.DataLoader;
import feathers.events.TriggerEvent;
import com.tilbuci.Player;
import openfl.net.URLRequest;
import openfl.display.Sprite;
import openfl.Lib;

/** TILBUCI **/
import com.tilbuci.plugin.PluginEvent;
import com.tilbuci.plugin.Plugin;
import com.tilbuci.plugin.PluginAccess;
import com.tilbuci.plugin.PluginWindow;
import com.tilbuci.data.Global;
import com.tilbuci.script.ScriptParser;

class ServerCallPlugin extends Plugin {

    /**
        Constructor.
    **/
    public function new() {
        super('server-call', 'Server Call',  'ServerCall', false, true);
    }

    /**
        Initializes the plugin.
        @param  ac  initialization data
    **/
    override public function initialize(ac:PluginAccess):Void {
        super.initialize(ac);
        // custom events
        this.setAction('call.url', this.acUrl);
        this.setAction('call.process', this.acProcess);
        this.setAction('call.sdprocess', this.acSdProcess);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Calls an URL from the server.
    **/
    private function acUrl(param:Array<String>, after:AfterScript):Bool {
        if (param.length > 0) {
                var strvar:String = '';
                if (param.length > 1) strvar = this._access.parser.parseString(param[1]);
                GlobalPlayer.ws.send('ServerCall/Url', [
                    'url' => this._access.parser.parseString(param[0]), 
                    'var' => strvar
                ], onCallReturn, after);
                return (true);
        } else {
            return (false);
        }
    }

    /**
        URL call returns.
    **/
    private function onCallReturn(ok:Bool, ld:DataLoader):Void {
        var after:AfterScript = cast ld.extra;
        if (ok) {
            if (ld.map['e'] == 0) {
                if (ld.map['var'] != '') this._access.parser.setString(ld.map['var'], ld.map['resp']);
                if (after.onsuccess != null) this._access.parser.run(after.onsuccess, true);
            } else {
                if (after.onerror != null) this._access.parser.run(after.onerror, true);
            }
        } else {
            if (after.onerror != null) this._access.parser.run(after.onerror, true);
        }
    }

    /**
        Calls an URL from the server for data processing.
    **/
    private function acProcess(param:Array<String>, after:AfterScript):Bool {
        if (param.length > 0) {
                var prData:Array<String> = [ ];
                if (param.length > 1) {
                    for (i in 1...param.length) prData.push(this._access.parser.parseString(param[i]));
                }
                GlobalPlayer.ws.send('ServerCall/Process', [
                    'url' => this._access.parser.parseString(param[0]), 
                    'data' => StringStatic.jsonStringify(prData), 
                    'movieid' => GlobalPlayer.movie.mvId, 
                    'sceneid' => GlobalPlayer.movie.scId, 
                    'movietitle' => GlobalPlayer.mdata.title, 
                    'scenetitle' => GlobalPlayer.movie.scene.title, 
                    'visitor' => GlobalPlayer.ws.user, 
                ], onProcessReturn, after);
                return (true);
        } else {
            return (false);
        }
    }

    /**
        Calls an URL from the same domain for data processing.
    **/
    private function acSdProcess(param:Array<String>, after:AfterScript):Bool {
        if (param.length > 0) {
            var prData:Array<String> = [ ];
            if (param.length > 1) {
                for (i in 1...param.length) prData.push(this._access.parser.parseString(param[i]));
            }
            new DataLoader(true, this._access.parser.parseString(param[0]), 'POST', [
                'data' => StringStatic.jsonStringify(prData), 
                'movieid' => GlobalPlayer.movie.mvId, 
                'sceneid' => GlobalPlayer.movie.scId, 
                'movietitle' => GlobalPlayer.mdata.title, 
                'scenetitle' => GlobalPlayer.movie.scene.title, 
                'visitor' => GlobalPlayer.ws.user, 
            ], DataLoader.MODEJSON, onSdProcessReturn, null, null, null, null, after);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Process call returns.
    **/
    private function onProcessReturn(ok:Bool, ld:DataLoader):Void {
        var after:AfterScript = cast ld.extra;
        if (ok) {
            if (ld.map['e'] == 0) {
                if (ld.map['resp'] != '') {
                    var json:Dynamic = StringStatic.jsonParse(ld.map['resp']);
                    if (json == false) {
                        // response error
                        if (after.onerror != null) this._access.parser.run(after.onerror, true);
                    } else {
                        // getting variables
                        for (k in Reflect.fields(json)) {
                            var vval:Dynamic = Reflect.field(json, k);
                            if (Reflect.hasField(vval, 't') && Reflect.hasField(vval, 'v')) {
                                switch (Reflect.field(vval, 't')) {
                                    case 'S':
                                        this._access.parser.setString(k, Reflect.field(vval, 'v'));
                                    case 'F':
                                        this._access.parser.setFloat(k, Reflect.field(vval, 'v'));
                                    case 'I':
                                        this._access.parser.setInt(k, Reflect.field(vval, 'v'));
                                    case 'B':
                                        this._access.parser.setBool(k, Reflect.field(vval, 'v'));
                                }
                            }
                        }
                        if (after.onsuccess != null) {
                            this._access.parser.run(after.onsuccess, true);
                        }
                    }
                }
            } else {
                if (after.onerror != null) this._access.parser.run(after.onerror, true);
            }
        } else {
            if (after.onerror != null) this._access.parser.run(after.onerror, true);
        }
    }

    /**
        Same domain process call returns.
    **/
    private function onSdProcessReturn(ok:Bool, ld:DataLoader):Void {
        var after:AfterScript = cast ld.extra;
        if (ok) {
            // getting variables
            for (k in Reflect.fields(ld.json)) {
                var vval:Dynamic = Reflect.field(ld.json, k);
                if (Reflect.hasField(vval, 't') && Reflect.hasField(vval, 'v')) {
                    switch (Reflect.field(vval, 't')) {
                        case 'S':
                            this._access.parser.setString(k, Reflect.field(vval, 'v'));
                        case 'F':
                            this._access.parser.setFloat(k, Reflect.field(vval, 'v'));
                        case 'I':
                            this._access.parser.setInt(k, Reflect.field(vval, 'v'));
                        case 'B':
                            this._access.parser.setBool(k, Reflect.field(vval, 'v'));
                    }
                }
            }
            if (after.onsuccess != null) {
                this._access.parser.run(after.onsuccess, true);
            }
        } else {
            if (after.onerror != null) this._access.parser.run(after.onerror, true);
        }
    }
}