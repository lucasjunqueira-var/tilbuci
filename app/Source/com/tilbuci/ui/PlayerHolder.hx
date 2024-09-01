package com.tilbuci.ui;

/** OPENFL **/
import com.tilbuci.def.InstanceData;
import com.tilbuci.def.AssetData;
import com.tilbuci.def.CollectionData;
import com.tilbuci.data.DataLoader;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.Global;
import openfl.display.Shape;
import openfl.display.Sprite;

import feathers.core.FeathersControl;

/** TILBUCI **/
import com.tilbuci.Player;

class PlayerHolder extends FeathersControl {

    /**
        background area
    **/
    private var _bg:Shape;

    /**
        the player
    **/
    public var player:Player;

    /**
        real width in pixels
    **/
    public var rWidth(get, null):Float;
    private function get_rWidth():Float { return (this.player.rWidth); }

    /**
        real height in pixels
    **/
    public var rHeight(get, null):Float;
    private function get_rHeight():Float { return (this.player.rHeight); }

    public function new(path:String, callback:Dynamic) {
        super();
        this._bg = new Shape();
        this._bg.graphics.beginFill(0, 0);
        this._bg.graphics.drawRect(0, 0, 32, 32);
        this._bg.graphics.endFill();
        this.addChild(this._bg);
        this.player = new Player('player.json', Player.MODE_EDITOR, Player.ORIENTATION_LANDSCAPE, true, callback);
        this.addChild(this.player);
    }

    /**
        Sets the player width.
        @param  to  new player width
    **/
    public function setWidth(to:Float):Void {
        this._bg.width = this._bg.height = to + 600;
        if (Global.displayType == 'portrait') {
            this.player.setSize(((GlobalPlayer.mdata.screen.small / GlobalPlayer.mdata.screen.big) * to), to);
        } else {
            this.player.setSize(to, ((GlobalPlayer.mdata.screen.small / GlobalPlayer.mdata.screen.big) * to));
        }
        this.player.x = this.player.y = 300;
        this.width = this._bg.width;
        this.height = this._bg.height;
    }

    /**
        Creates a collection.
        @param  name    collection name
        @param  ac  method to call after collection creation
        @param  id  collection ID (emprty string for automatic)
    **/
    public function createCollection(name:String, ac:Dynamic, id:String = ''):Void {
        Global.ws.send(
            'Media/CreateCollection', [
                'movie' => GlobalPlayer.movie.mvId, 
                'name' => name,
                'id' => id
            ], 
            ac 
        );
    }

    /**
        Sets a collection information.
        @param  id  collection id
        @param  name    collection name
        @param  transition  transition mode
        @param  time    the transition time
        @param  assets  information about the collection assets
    **/
    public function setCollection(id:String, name:String, transition:String, time:Float, assets:Map<String, Dynamic> = null):Void {
        var col:CollectionData = new CollectionData(id, null, false);
        col.name = name;
        col.transition = transition;
        col.time = time;
        col.ok = true;
        if (assets != null) {
            for (k in assets.keys()) {
                var kast:String = k.substr(0, 32);
                col.assets[kast] = new AssetData(assets[k]);
                col.assetOrder.push(kast);
            }
        }
        GlobalPlayer.movie.collections[id] = col;
    }

    /**
        Adds an instance to current keyframe.
        @param  id  instance id
        @param  data    information about the instance
    **/
    public function addInstance(id:String, data:Dynamic):Void {
        // check if instance id already exists
        while (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].exists(id)) {
            id = StringStatic.md5(id);
        }
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][id] = new InstanceData(data);
        if (!GlobalPlayer.movie.scene.collections.contains(Reflect.field(data, 'collection'))) {
            GlobalPlayer.movie.scene.collections.push(Reflect.field(data, 'collection'));
        }
        GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
    }

    /**
        Adds a keyframe after the current one.
    **/
    public function addKeyframe():Void {
        if (GlobalPlayer.movie.scId != '') {
            var kfs:Array<Map<String, InstanceData>> = [ ];
            var kfa:Array<String> = [ ];
            var curkf:Int = GlobalPlayer.area.currentKf;
            for (i in 0...GlobalPlayer.movie.scene.keyframes.length) {
                // copy the keyframe
                kfs.push(GlobalPlayer.movie.scene.keyframes[i]);
                if (GlobalPlayer.movie.scene.ackeyframes.length > i) {
                    kfa.push(GlobalPlayer.movie.scene.ackeyframes[i]);
                } else {
                    kfa.push('');
                }
                // add the same keyframe again
                if (i == curkf) {
                    var newkf:Map<String, InstanceData> = [ ];
                    for (k in GlobalPlayer.movie.scene.keyframes[i].keys()) {
                        newkf[k] = GlobalPlayer.movie.scene.keyframes[i][k].clone();
                    }
                    kfs.push(newkf);
                    if (GlobalPlayer.movie.scene.ackeyframes.length > i) {
                        kfa.push(GlobalPlayer.movie.scene.ackeyframes[i]);
                    } else {
                        kfa.push('');
                    }
                }
            }
            GlobalPlayer.movie.scene.keyframes = kfs;
            GlobalPlayer.movie.scene.ackeyframes = kfa;
            curkf++;
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[curkf], curkf);
            Global.showMsg(Global.ln.get('menu-keyframe-addok'));
        }
    }

    /**
        Removes the current one.
    **/
    public function removeKeyframe():Void {
        if (GlobalPlayer.movie.scId != '') {
            var kfs:Array<Map<String, InstanceData>> = [ ];
            var kfa:Array<String> = [ ];
            var curkf:Int = GlobalPlayer.area.currentKf;
            for (i in 0...GlobalPlayer.movie.scene.keyframes.length) {
                // copy the keyframe
                if (i != curkf) {
                    kfs.push(GlobalPlayer.movie.scene.keyframes[i]);
                    if (GlobalPlayer.movie.scene.ackeyframes.length > i) {
                        kfa.push(GlobalPlayer.movie.scene.ackeyframes[i]);
                    } else {
                        kfa.push('');
                    }
                }
            }
            GlobalPlayer.movie.scene.keyframes = kfs;
            GlobalPlayer.movie.scene.ackeyframes = kfa;
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[curkf], curkf);
        }
    }

}