/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.def;

/** HAXE **/
import com.tilbuci.data.GlobalPlayer;
import haxe.Json;

/** TILBUCI **/
import com.tilbuci.def.DefBase;

/**
    Loaded movie information.
**/
class SceneData extends DefBase {

    /**
        scene title
    **/
    public var title:String = '';

    /**
        about the scene
    **/
    public var about:String = '';

    /**
        share image path
    **/
    public var image:String = '';

    /**
        static scene?
    **/
    public var staticsc:Bool = false;

    /**
        collections used
    **/
    public var collections:Array<String> = [ ];

    /**
        scene keyframes
    **/
    public var keyframes:Array<Map<String, InstanceData>> = [ ];

    /**
        keyframne to loop to
    **/
    public var loop:Int = 0;

    /**
        scene start actions
    **/
    public var acstart:String = '';

    /**
        end of keyframe actions
    **/
    public var ackeyframes:Array<String> = [ ];

    /**
        scene navigation
    **/
    public var navigation:Map<String, String> = [ ];

    public function new() {
        super(['title', 'about', 'image', 'navigation', 'collections', 'keyframes', 'loop', 'acstart', 'ackeyframes']);
        this.clear();
    }

    /**
        Clears scene data.
    **/
    public function clear():Void {
        this.title = '';
        this.about = '';
        this.image = '';
        this.staticsc = false;
        for (nv in this.navigation.keys()) this.navigation.remove(nv);
        this.navigation = [ 'up' => '', 'down' => '', 'left' => '', 'right' => '', 'nin' => '', 'nout' => '' ];
        this.loop = 0;
        while (this.collections.length > 0) this.collections.shift();
        while (this.keyframes.length > 0) {
            var kf:Map<String, InstanceData> = this.keyframes.shift();
            for (i in kf.keys()) {
                kf[i].kill();
                kf.remove(i);
            }
        }
        this.acstart = '';
        while (this.ackeyframes.length > 0) this.ackeyframes.shift();
    }

    /**
        Loads a scene information.
        @param  data    scene data to load
        @return all required fields sent on data?
    **/
    public function load(data:Map<String, Dynamic>):Bool {
        GlobalPlayer.contraptions.removeContraptions();
        if (this.checkFields(data)) {
            this.title = data['title'];
            this.about = data['about'];
            this.image = data['image'];
            this.navigation = [ 
                'up' => data['navigation'].up, 
                'down' => data['navigation'].down, 
                'left' => data['navigation'].left, 
                'right' => data['navigation'].right, 
                'nin' => data['navigation'].nin, 
                'nout' => data['navigation'].nout, 
            ];
            while (this.collections.length > 0) this.collections.shift();
            var carr:Array<String> = cast data['collections'];
            if (carr.length > 0) for (v in carr) this.collections.push(v);
            while (this.keyframes.length > 0) {
                var inst:Map<String, InstanceData> = this.keyframes.shift();
                for (k in inst.keys()) {
                    inst[k].kill();
                    inst.remove(k);
                }
            }
            for (k in Reflect.fields(data['keyframes'])) {
                var inst:Map<String, InstanceData> = [ ];
                for (i in Reflect.fields(Reflect.field(data['keyframes'], k))) {
                    inst[i] = new InstanceData(Reflect.field(Reflect.field(data['keyframes'], k), i));
                }
                this.keyframes.push(inst);
            }
            this.loop = data['loop'];
            if ((this.loop >= this.keyframes.length) || (this.loop < 0)) this.loop = 0;
            this.acstart = data['acstart'];
            while (this.ackeyframes.length > 0) this.ackeyframes.shift();
            for (k in Reflect.fields(data['ackeyframes'])) {
                this.ackeyframes.push(Reflect.field(data['ackeyframes'], k));
            }
            // optional/new properties
            if (data.exists('staticsc')) {
                this.staticsc = data['staticsc'];
            } else {
                this.staticsc = false;
            }
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Creates a JSON-encoded string with current scene information.
        @return the JSON-formatted text
    **/
    public function toJson():String {
        return (Json.stringify(this.toObject()));
    }

    /**
        Gets a clen representation of current object.
    **/
    public function toObject():Dynamic {
        var kfs:Array<Dynamic> = [ ];
        for (n in 0...this.keyframes.length) {
            var kf:Dynamic = { };
            for (k in this.keyframes[n].keys()) Reflect.setField(kf, k, this.keyframes[n][k].toObject());
            kfs.push(kf);
        }
        return ({
            title: this.title, 
            about: this.about, 
            image: this.image, 
            staticsc: this.staticsc, 
            navigation: {
                up: this.navigation['up'], 
                down: this.navigation['down'], 
                left: this.navigation['left'], 
                right: this.navigation['right'], 
                nin: this.navigation['nin'], 
                nout: this.navigation['nout']
            }, 
            collections: this.collections, 
            loop: this.loop, 
            acstart: this.acstart, 
            ackeyframes: this.ackeyframes, 
            keyframes: kfs
        });
    }

    /**
        Loads a clean representation of scene.
        @param  obj the object to load
    **/
    public function fromObject(obj:Dynamic):Void {
        if (Reflect.hasField(obj, 'title')) this.title = Reflect.field(obj, 'title');
        if (Reflect.hasField(obj, 'about')) this.about = Reflect.field(obj, 'about');
        if (Reflect.hasField(obj, 'image')) this.image = Reflect.field(obj, 'image');
        if (Reflect.hasField(obj, 'staticsc')) this.staticsc = Reflect.field(obj, 'staticsc');
        if (Reflect.hasField(obj, 'loop')) this.loop = Reflect.field(obj, 'loop');
        if (Reflect.hasField(obj, 'acstart')) this.acstart = Reflect.field(obj, 'acstart');
        if (Reflect.hasField(obj, 'ackeyframes')) this.ackeyframes = Reflect.field(obj, 'ackeyframes');
        if (Reflect.hasField(obj, 'collections')) this.collections = Reflect.field(obj, 'collections');
        if (Reflect.hasField(obj, 'navigation')) {
            var navigation:Dynamic = Reflect.field(obj, 'navigation');
            if (Reflect.hasField(navigation, 'up')) this.navigation['up'] = Reflect.field(navigation, 'up');
            if (Reflect.hasField(navigation, 'down')) this.navigation['down'] = Reflect.field(navigation, 'down');
            if (Reflect.hasField(navigation, 'left')) this.navigation['left'] = Reflect.field(navigation, 'left');
            if (Reflect.hasField(navigation, 'right')) this.navigation['right'] = Reflect.field(navigation, 'right');
            if (Reflect.hasField(navigation, 'nin')) this.navigation['nin'] = Reflect.field(navigation, 'nin');
            if (Reflect.hasField(navigation, 'nout')) this.navigation['nout'] = Reflect.field(navigation, 'nout');
        }
        if (Reflect.hasField(obj, 'keyframes')) {
            while (this.keyframes.length > 0) {
                var kf:Map<String, InstanceData> = this.keyframes.shift();
                for (k in kf.keys()) {
                    kf[k].kill();
                    kf.remove(k);
                }
            }
            var kfs:Array<Dynamic> = Reflect.field(obj, 'keyframes');
            for (k in Reflect.fields(kfs)) {
                var inst:Map<String, InstanceData> = [ ];
                for (i in Reflect.fields(Reflect.field(kfs, k))) {
                    inst[i] = new InstanceData(Reflect.field(Reflect.field(kfs, k), i));
                }
                this.keyframes.push(inst);
            }
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
        this.title = null;
        this.about = null;
        this.image = null;
        for (nv in this.navigation.keys()) this.navigation.remove(nv);
        this.navigation = null;
        while (this.collections.length > 0) this.collections.shift();
        this.collections = null;
        while (this.keyframes.length > 0) {
            var inst:Map<String, InstanceData> = this.keyframes.shift();
            for (i in inst.keys()) {
                inst[i].kill();
                inst.remove(i);
            }
        }
        this.keyframes = null;
        this.acstart = null;
        while (this.ackeyframes.length > 0) this.ackeyframes.shift();
        this.ackeyframes = null;
    }

}