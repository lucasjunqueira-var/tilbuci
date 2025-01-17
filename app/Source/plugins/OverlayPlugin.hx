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

class OverlayPlugin extends Plugin {

    /**
        information about current overlay
    **/
    public static var overlayInfo:OverlayInfo;

    /**
        the configuration window
    **/
    private var _confWindow:PluginWindow;

    /**
        Constructor.
    **/
    public function new() {
        super('overlay', 'Overlay',  'Overlay', true, true);
    }

    /**
        Initializes the plugin.
        @param  ac  initialization data
    **/
    override public function initialize(ac:PluginAccess):Void {
        super.initialize(ac);
        // add plugin button
        this.addMenu('Overlay', onOverlay);
        // create plugin config window
        this._confWindow = new PluginWindow('Overlay', 500, 150);
        this._confWindow.addForm('config', this._confWindow.ui.forge('config', [
            { tp: 'Label', id: 'overlay', tx: 'Secret KEY for server communication', vr: '' }, 
            { tp: 'TInput', id: 'overlay', tx: '', vr: '' }, 
            { tp: 'Button', id: 'overlay', tx: 'Update configuration', ac: onUpdate }
        ]));
        this._confWindow.startInterface();
        // custom events
        this.setAction('overlay.show', this.getKey);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
        this._confWindow.kill();
        this._confWindow = null;
    }

    /**
        Gets a key to overlay display.
    **/
    private function getKey(param:Array<String>, after:AfterScript):Bool {
        if (param.length >= 2) {
                OverlayPlugin.overlayInfo = null;
                var addget:String = '0';
                if (param.length >= 3) if (this._access.parser.parseBool(param[2])) addget = '1';
                var data:Map<String, String> = [ ];
                if (param.length >= 4) {
                    for (p in 3...param.length) data['v'+(p-2)] = this._access.parser.parseString(param[p]);
                }
                GlobalPlayer.ws.send('Overlay/GetKey', [
                    'url' => this._access.parser.parseString(param[0]), 
                    'title' => this._access.parser.parseString(param[1]), 
                    'addget' => addget, 
                    'data' => StringStatic.jsonStringify(data), 
                ], onKeyReturn, after);
                return (true);
        } else {
            return (false);
        }
    }

    /**
        Key request return.
    **/
    private function onKeyReturn(ok:Bool, ld:DataLoader):Void {
        var after:AfterScript = cast ld.extra;
        if (ok) {
            if (ld.map['e'] == 0) {
                if (ld.map['key'] != '') {
                    OverlayPlugin.overlayInfo = {
                        key: ld.map['key'], 
                        onerror: after.onerror, 
                        onsuccess: after.onsuccess, 
                        parser: this._access.parser
                    };
                    var url:String = ld.map['url'] + '?key=' + ld.map['key'];
                    if (ld.map['addget'] == '1') {
                        var dmap:Map<String, Dynamic> = StringStatic.jsonAsMap(ld.map['data']);
                        for (k in dmap.keys()) {
                            url += '&' + k + '=' + StringTools.urlEncode(dmap[k]);
                        }
                    }
                    ExternOverlay.overlay_place(url, ld.map['title']);
                } else {
                    if (after.onerror != null) this._access.parser.run(after.onerror, true);    
                }
            } else {
                if (after.onerror != null) this._access.parser.run(after.onerror, true);
            }
        } else {
            if (after.onerror != null) this._access.parser.run(after.onerror, true);
        }
    }

    /**
        Opens the configuration window.
    **/
    private function onOverlay(evt:TriggerEvent):Void {
        if (Global.ws.level == 0) {
            if (this.config.exists('overlay')) {
                this._confWindow.ui.inputs['overlay'].text = this.config['overlay'];
            }
            this.showWindow(this._confWindow);
        } else {
            Global.showPopup('Overlay', 'This configuration is only available to system administrators.', 320, 180, 'OK', 'warn');
        }
    }

    /**
        Updates the plugin configuration.
    **/
    private function onUpdate(evt:TriggerEvent):Void {
        this.config['overlay'] = this._confWindow.ui.inputs['overlay'].text;
        this.updateConfig(this.onUpdateFinish);
    }

    /**
        Plugin config update return.
    **/
    private function onUpdateFinish(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            Global.showPopup('Overlay', 'Error while saving the plugin configuration.', 320, 180, 'OK');
        } else if (ld.map['e'] != 0) {
            Global.showPopup('Overlay', 'Error while saving the plugin configuration.', 320, 180, 'OK');
        } else {
            Global.showMsg('The overlay configuration was updated.');
            this.hideWindow(this._confWindow);
        }
    }

    /**
        Exposed function to call on overlay close.
    **/
    @:expose('overlay_return')
    public static function overlay_return() {
        if (OverlayPlugin.overlayInfo != null) {
            // request return data
            GlobalPlayer.ws.send('Overlay/LoadKey', [
                'key' => OverlayPlugin.overlayInfo.key, 
            ], OverlayPlugin.onkeyLoaded);
        }
    }

    /**
        Data returned from the overlay content was loaded.
    **/
    public static function onkeyLoaded(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                if (ld.map['key'] != '') {
                    if (ld.map['ret'] != '') {
                        var json:Dynamic = StringStatic.jsonParse(ld.map['ret']);
                        if (json == false) {
                            // response error
                            if (OverlayPlugin.overlayInfo.onerror != null) OverlayPlugin.overlayInfo.parser.run(OverlayPlugin.overlayInfo.onerror, true); 
                        } else {
                            // getting variables
                            for (k in Reflect.fields(json)) {
                                var vval:Dynamic = Reflect.field(json, k);
                                if (Reflect.hasField(vval, 't') && Reflect.hasField(vval, 'v')) {
                                    switch (Reflect.field(vval, 't')) {
                                        case 'S':
                                            OverlayPlugin.overlayInfo.parser.setString(k, Reflect.field(vval, 'v'));
                                        case 'F':
                                            OverlayPlugin.overlayInfo.parser.setFloat(k, Reflect.field(vval, 'v'));
                                        case 'I':
                                            OverlayPlugin.overlayInfo.parser.setInt(k, Reflect.field(vval, 'v'));
                                        case 'B':
                                            OverlayPlugin.overlayInfo.parser.setBool(k, Reflect.field(vval, 'v'));
                                    }
                                }
                            }
                        }
                    }
                    if (OverlayPlugin.overlayInfo.onsuccess != null) OverlayPlugin.overlayInfo.parser.run(OverlayPlugin.overlayInfo.onsuccess, true); 
                } else {
                    if (OverlayPlugin.overlayInfo.onerror != null) OverlayPlugin.overlayInfo.parser.run(OverlayPlugin.overlayInfo.onerror, true);    
                }
            } else {
                if (OverlayPlugin.overlayInfo.onerror != null) OverlayPlugin.overlayInfo.parser.run(OverlayPlugin.overlayInfo.onerror, true);
            }
        } else {
            if (OverlayPlugin.overlayInfo.onerror != null) OverlayPlugin.overlayInfo.parser.run(OverlayPlugin.overlayInfo.onerror, true);
        }
        OverlayPlugin.overlayInfo = null;
    }

}

/**
    Overlay call info.
**/
typedef OverlayInfo = {
    var parser:ScriptParser;
    var onsuccess:Dynamic;
    var onerror:Dynamic;
    var key:String;
}

/**
    Overlay javascript methods.
**/
#if (js && html5)
@:native("window")
extern class ExternOverlay {

    /**
        Places the overlay area above the TilBuci player.
        @param  src the URL to load
        @param  title   the overlay title
    **/
    static function overlay_place(src:String, title:String = ''):Void;

    /**
        Closes the overlay window.
    **/
    static function overlay_close():Void;

}
#else
class ExternOverlay {
    
    /**
        Places the overlay area above the TilBuci player.
        @param  src the URL to load
        @param  title   the overlay title
    **/
    static function overlay_place(src:String, title:String = ''):Void { trace ('Overylay not supported on this platform.'); }

    /**
        Closes the overlay window.
    **/
    static function overlay_close():Void { trace ('Overylay not supported on this platform.'); }

}
#end