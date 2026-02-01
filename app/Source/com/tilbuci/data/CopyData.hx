/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.data;

import com.tilbuci.statictools.StringStatic;
import com.tilbuci.js.ExternBrowser;
import com.tilbuci.def.InstanceData;
import com.tilbuci.def.CollectionData;

/**
    Instance copy/paste information.
**/
class CopyData {

    private var _collections:Map<String, CollectionData> = [ ];

    private var _instances:Map<String, InstanceData> = [ ];

    private var _has:Bool = false;

    public var updateDisplay:Dynamic;

    public function new() {

    }

    public function hasCopy():Bool {
        return (this._has);
    }

    public function clear():Void {
        for (k in this._collections.keys()) this._collections.remove(k);
        for (k in this._instances.keys()) this._instances.remove(k);
        this._has = false;
    }

    public function addCollection(name):Bool {
        if (GlobalPlayer.movie.collections.exists(name)) {
            this._collections[name] = GlobalPlayer.movie.collections[name];
            return (true);
        } else {
            return (false);
        }
    }

    public function addInstance(name:String, data:InstanceData):Void {
        this._instances[name] = data;
        this._has = true;
    }

    public function broadcast():Void {
        if (this._has) {
            var col:Map<String, Dynamic> = [ ];
            for (k in this._collections.keys()) col[k] = this._collections[k].toJson();
            var inst:Map<String, Dynamic> = [ ];
            for (k in this._instances.keys()) inst[k] = this._instances[k].toJson();
            var msg:Map<String, Dynamic> = [ ];
            msg['movie'] = GlobalPlayer.movie.mvId;
            msg['scene'] = GlobalPlayer.movie.scId;
            msg['collections'] = col;
            msg['instances'] = inst;
            ExternBrowser.TBB_sendTabsMessage('copy', StringStatic.jsonStringify(msg));
            this.receiveMessage(StringStatic.jsonStringify(msg));
        }
    }

    public function receiveMessage(msg:String):Void {
        var msg:Map<String, Dynamic> = StringStatic.jsonAsMap(msg);
        if (msg.exists('movie') && msg.exists('collections') && msg.exists('instances')) {
            if (msg['movie'] == GlobalPlayer.movie.mvId) {
                this.clear();
                for (k in Reflect.fields(msg['collections'])) {
                    var col:CollectionData = new CollectionData(k, null, false);
                    if (col.fromJson(Reflect.field(msg['collections'], k))) {
                        this._collections[k] = col;
                    }
                }
                for (k in Reflect.fields(msg['instances'])) {
                    var inst:InstanceData = new InstanceData(StringStatic.jsonParse(Reflect.field(msg['instances'], k)));
                    if (inst.ok && (this._collections.exists(inst.collection))) {
                        this._instances[k] = inst;
                        this._has = true;
                    }
                }
                if (this.updateDisplay != null) this.updateDisplay();
            }
        }
    }

    public function pasteInstances():Void {
        if (this._has) {
            for (k in this._collections.keys()) {
                GlobalPlayer.movie.collections[k] = this._collections[k];
            }
            for (k in this._instances.keys()) {
                GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][k] = this._instances[k];
            }
            GlobalPlayer.area.updateOrder();
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
        }
    }

}