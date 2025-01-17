/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.def;

/** HAXE **/
import haxe.Json;

/** TILBUCI **/
import com.tilbuci.def.DefBase;
import com.tilbuci.data.DataLoader;
import com.tilbuci.data.GlobalPlayer;

/**
    Loaded collection information.
**/
class CollectionData extends DefBase {

    /**
        collection loaded?
    **/
    public var ok:Bool = false;

    /**
        collection name
    **/
    public var name:String = '';

    /**
        asset transition mode
    **/
    public var transition:String = 'none';

    /**
        asset transition time
    **/
    public var time:Float = 1;

    /**
        assets information
    **/
    public var assets:Map<String, AssetData> = [ ];

    /**
        assets order
    **/
    public var assetOrder:Array<String> = [ ];

    /**
        action to call after collection load
    **/
    private var _acLoad:Dynamic;


    public function new(id:String, acLoad:Dynamic, load:Bool = true) {
        super(['name', 'transition', 'time', 'assets']);
        this._acLoad = acLoad;
        if (load) {
            var cache:Map<String, Dynamic> = null;
            if (GlobalPlayer.nocache) cache = [ 'rand' => Math.ceil(Math.random()*10000) ];
            new DataLoader(true, id, 'GET', cache, DataLoader.MODEMAP, onLoad);
        }
    }

    /**
        Creates a JSON-encoded string with current movie information.
        @return the JSON-formatted text
    **/
    public function toJson():String {
        return (Json.stringify(this.toObject()));
    }

    /**
        Gets a clen representation of current object.
    **/
    public function toObject():Dynamic {
        var asts:Dynamic = { };
        for (k in this.assets.keys()) Reflect.setField(asts, k, this.assets[k].toObject());
        return ({
            name: this.name, 
            transition: this.transition, 
            time: this.time, 
            assets: asts
        });
    }

    /**
        Releases resopurces used by the object.
    **/
    override public function kill():Void {
        super.kill();
        this.name = null;
        this.transition = null;
        for (a in this.assets.keys()) {
            this.assets[a].kill();
            this.assets.remove(a);
        }
        this.assets = null;
        while (this.assetOrder.length > 0) this.assetOrder.shift();
        this.assetOrder = null;
    }

    /**
        The collection information was loaded.
    **/
    private function onLoad(ok:Bool, ld:DataLoader):Void {
        this.ok = false;
        if (ok) {
            if (this.checkFields(ld.map)) {
                this.ok = true;
                this.name = ld.map['name'];
                this.transition = ld.map['transition'];
                this.time = ld.map['time'];
                for (c in Reflect.fields(ld.map['assets'])) {
                    this.assets[c] = new AssetData(Reflect.field(ld.map['assets'], c));
                    this.assetOrder.push('');
                }
                for (a in this.assets.keys()) this.assetOrder[this.assets[a].order] = a;
            }
        }
        if (this._acLoad != null) this._acLoad();
        this._acLoad = null;
    }

}