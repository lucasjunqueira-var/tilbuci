/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.data;

/** TILBUCI **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.def.SceneData;
import com.tilbuci.data.DataLoader;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.def.MovieData;
import com.tilbuci.def.CollectionData;

class MovieInfo {

    /**
        loaded movie data
    **/
    public var data:MovieData;

    /**
        loaded scene data
    **/
    public var scene:SceneData;

    /**
        asset colletcions
    **/
    public var collections:Map<String, CollectionData> = [ ];

    /**
        movie folder set path
    **/
    private var _path:String;

    /**
        callback actions
    **/
    private var _actions:Map<String, Dynamic> = [ ];

    /**
        cached scene data
    **/
    private var _cacheScene:Map<String, String> = [ ];

    /**
        collections to load
    **/
    private var _colLoad:Int = 0;

    /**
        loaded movie ID
    **/
    public var mvId(get, null):String;
    private var _mvId:String = '';
    private function get_mvId():String { return (this._mvId); }

    /**
        is there a movie loaded?
    **/
    public var mvLoaded(get, null):Bool;
    private function get_mvLoaded():Bool { return (this._mvId != ''); }

    /**
        loaded scene ID
    **/
    public var scId(get, null):String;
    private var _scId:String = '';
    private function get_scId():String { return (this._scId); }

    /**
        is there a scene loaded?
    **/
    public var scLoaded(get, null):Bool;
    private function get_scLoaded():Bool { return (this._scId != ''); }

    /**
        Constructor.
        @param  onMovie method to call after a movie load operation
        @param  onScene method to call after a scene load operation
    **/
    public function new(onMovie:Dynamic, onScene:Dynamic) {
        this.data = new MovieData();
        this.scene = new SceneData();
        this._actions['movie'] = onMovie;
        this._actions['scene'] = onScene;
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.data.kill();
        this.data = null;
        this.scene.kill();
        this.scene = null;
        for (n in this._actions.keys()) this._actions.remove(n);
        this._actions = null;
        for (n in this._cacheScene.keys()) this._cacheScene.remove(n);
        this._cacheScene = null;
    }

    /**
        Starts loading a new movie set.
        @param  path    path to the movie folder
    **/
    public function loadMovie(path:String):Void {
        this._mvId = '';
        this._scId = '';
        this.data.clear();
        this.scene.clear();
        GlobalPlayer.area.clear();
        for (n in this._cacheScene.keys()) this._cacheScene.remove(n);
        if ((path.substr(0, 4) != 'http') && (path.substr(0, 4) != 'file')) {
            path = GlobalPlayer.base + 'movie/' + path;
        }
        if (path.substr(-6) != '.movie') path = path + '.movie';
        GlobalPlayer.path = this._path = path + '/';
        path = path + '/movie.json';
        var cache:Map<String, Dynamic> = null;
        if (GlobalPlayer.nocache) cache = [ 'rand' => Math.ceil(Math.random()*10000) ];
        new DataLoader(true, path, 'GET', cache, DataLoader.MODEMAP, onMovieLoaded);
    }

    /**
        Loads a scene from current movie.
        @param  id  scene id
        @param  uid scene uid (for editor)
        @return is there a movie loaded?
    **/
    public function loadScene(id:String, uid:Int = 0):Bool {
        if (this.mvLoaded) {
            GlobalPlayer.contraptions.showLoadingIc();
            if ((GlobalPlayer.mode == Player.MODE_EDITOR) || (GlobalPlayer.mode == Player.MODE_EDPLAYER) || ((GlobalPlayer.mode == Player.MODE_PLAYER) && GlobalPlayer.mdata.identify)) {
                // player requesting visitor identification?
                if ((GlobalPlayer.mode == Player.MODE_PLAYER) && GlobalPlayer.mdata.identify) {
                    GlobalPlayer.ws.loadScene(id, onSceneLoaded);
                } else if (id == null) { // editor
                    Global.ws.send(
                        'Scene/LoadUid', 
                        [
                            'movie' => GlobalPlayer.movie.mvId, 
                            'uid' => uid
                        ], 
                        onSceneLoadedEditor
                    );
                } else {
                    Global.ws.send(
                        'Scene/Load', 
                        [
                            'movie' => GlobalPlayer.movie.mvId, 
                            'id' => id
                        ], 
                        onSceneLoadedEditor
                    );
                }
                return (true);
            } else {
                // player
                if (this._cacheScene.exists(id)) {
                    if (this.scene.load(StringStatic.jsonAsMap(this._cacheScene[id]))) {
                        this._scId = id;
                    } else {
                        this._scId = '';
                    }
                    this._actions['scene'](this.scLoaded);
                    return (this.scLoaded);
                } else {
                    var cache:Map<String, Dynamic> = null;
                    if (GlobalPlayer.nocache) cache = [ 'rand' => Math.ceil(Math.random()*10000) ];
                    new DataLoader(true, (this._path + 'scene/' + id + '.json'), 'GET', cache, DataLoader.MODEMAP, onSceneLoaded);
                    return (true);
                }
            }
        } else {
            this._actions['scene'](false);
            return (false);
        }
    }

    /**
        Clears the scene id.
    **/
    public function noScene():Void {
        this._scId = '';
    }

    /**
        Loads and cache a scene information.
        @param  id  the scene id
        @return is there a movie loaded to get the scene?
    **/
    public function cacheScene(id:String):Bool {
        if (this.mvLoaded) {
            if (!this._cacheScene.exists(id)) {
                var cache:Map<String, Dynamic> = null;
                if (GlobalPlayer.nocache) cache = [ 'rand' => Math.ceil(Math.random()*10000) ];
                new DataLoader(true, (this._path + 'scene/' + id + '.json'), 'GET', cache, DataLoader.MODEMAP, onSceneCache);
            }
            return (true);
        } else {
            return (false);
        }
    }

    /** PRIVATE METHODS **/

    /**
        A movie was just loaded.
    **/
    private function onMovieLoaded(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (this.data.load(ld.map)) {
                var pathAr:Array<String> = StringTools.replace(this._path, '.movie/', '').split('/');
                this._mvId = pathAr[pathAr.length - 1];
            }
        }
        if (!this.mvLoaded) {
            this._path = '';
            this._actions['movie'](this.mvLoaded);
        } else {
            // specific groups required?
            var groupok:Bool = false;
            if (GlobalPlayer.mdata.vsgroups.length == 0) {
                groupok = true;
            } else {
                for (gr in GlobalPlayer.mdata.vsgroups) {
                    if (GlobalPlayer.ws.groups.contains(gr)) {
                        groupok = true;
                    }
                }
            }
            // can the movie be shown?
            if (GlobalPlayer.mdata.identify && !GlobalPlayer.ws.userLogged() && (GlobalPlayer.mode == Player.MODE_PLAYER)) {
                // load fallback movie
                this._mvId = '';
                this._path = '';
                if (GlobalPlayer.mdata.fallback != '') {
                    if (Reflect.hasField(Main, 'scene')) {
                        Reflect.setField(Main, 'scene', '');
                    }
                    this.loadMovie(GlobalPlayer.mdata.fallback);
                }
            } else if (!groupok  && (GlobalPlayer.mode == Player.MODE_PLAYER)) {
                // load fallback movie
                this._mvId = '';
                this._path = '';
                if (GlobalPlayer.mdata.fallback != '') {
                    if (Reflect.hasField(Main, 'scene')) {
                        Reflect.setField(Main, 'scene', '');
                    }
                    this.loadMovie(GlobalPlayer.mdata.fallback);
                }
            } else {
                // get strings.json
                GlobalPlayer.parser.loadStringsJson();
                // load initial scene?
                if (GlobalPlayer.mode == Player.MODE_PLAYER) {
                    var mainScene:String = '';
                    if (Reflect.hasField(Main, 'scene')) mainScene = Reflect.field(Main, 'scene');
                    if (mainScene == '') {
                        this.loadScene(ld.map['start']);
                    } else {
                        this.loadScene(mainScene);
                        if (Reflect.hasField(Main, 'scene')) {
                            Reflect.setField(Main, 'scene', '');
                        }
                    }
                }
            }
            //this._actions['movie'](this.mvLoaded);
            this._actions['movie'](true);
        }
    }

    /**
        A scene was just loaded on editor.
    **/
    private function onSceneLoadedEditor(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            // remove previous scene
            GlobalPlayer.movie.scene.clear();
            if (ld.map['e'] == 0) {
                // load scene
                var info:Map<String, Dynamic> = [ ];
                for (k in Reflect.fields(ld.map['info'])) info[k] = Reflect.field(ld.map['info'], k);
                if (this.scene.load(info)) {
                    this._scId = info['id'];
                    // load collections
                    this._colLoad = 0;
                    for (c in this.scene.collections) {
                        if (c != '') {
                            if (this.collections.exists(c)) {
                                this.collections[c].kill();
                                this.collections.remove(c);
                            }
                            this._colLoad++;
                            this.collections[c] = new CollectionData(this._path + 'collection/' + c + '.json', onColLoad);
                        }
                    }
                    // no collection to load?
                    if (this._colLoad == 0) this.onColLoad();
                } else {
                    // error loading
                    Global.showPopup(Global.ln.get('scene-load-windowtitle'), Global.ln.get('scene-load-error'), 320, 160, Global.ln.get('default-ok'));    
                }
            } else {
                // error loading
                Global.showPopup(Global.ln.get('scene-load-windowtitle'), Global.ln.get('scene-load-error'), 320, 160, Global.ln.get('default-ok'));    
            }
        } else {
            // error loading
            Global.showPopup(Global.ln.get('scene-load-windowtitle'), Global.ln.get('scene-load-error'), 320, 160, Global.ln.get('default-ok'));
        }
    }

    /**
        A scene was just loaded.
    **/
    private function onSceneLoaded(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            // remove previous scene
            GlobalPlayer.movie.scene.clear();

            // load scene
            if (this.scene.load(ld.map)) {
                if (StringTools.contains(ld.url, '.json')) {
                    var pathAr:Array<String> = StringTools.replace(ld.url, '.json', '').split('/');
                    this._scId = pathAr[pathAr.length - 1];
                } else if (ld.map.exists('id')) {
                    this._scId = ld.map['id'];
                }
                this._cacheScene[this._scId] = ld.rawtext;
                // load collections
                this._colLoad = 0;
                for (c in this.scene.collections) {
                    var okc:Bool = true;
                    try {
                        okc = this.collections.exists(c);
                    } catch (e) {
                        okc = false;
                    }
                    if (okc) {
                        if (!this.collections[c].ok) {
                            this.collections[c].kill();
                            this._colLoad++;
                            this.collections[c] = new CollectionData(this._path + 'collection/' + c + '.json', onColLoad);
                        }
                    } else {
                        this._colLoad++;
                        this.collections[c] = new CollectionData(this._path + 'collection/' + c + '.json', onColLoad);
                    }
                }

                // no collection to load?
                if (this._colLoad == 0) this.onColLoad();
            }
        }

    }

    /**
        A scene was just loaded for caching.
    **/
    private function onSceneCache(ok:Bool, ld:DataLoader):Void {
        var scid:String = ld.url.substr(-37, 32);
        if (ok && this.scene.checkFields(ld.map)) {
            this._cacheScene[scid] = ld.rawtext;
        } else {
            if (this._cacheScene.exists(scid)) this._cacheScene.remove(scid);
        }
    }

    /**
        New collection data loaded.
    **/
    private function onColLoad():Void {
        this._colLoad--;
        if (this._colLoad <= 0) {
            this._colLoad = 0;
            this._actions['scene'](this.scLoaded);
        }
    }

}