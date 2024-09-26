package com.tilbuci.script;

import haxe.macro.Expr.Case;
import com.tilbuci.data.DataLoader;
import com.tilbuci.data.GlobalPlayer;
import feathers.layout.VerticalLayout;
import openfl.display.BitmapData;
import openfl.Assets;
import com.tilbuci.data.Global;

class ActionInfo {

    public var groups:Array<ActionInfoGroup> = [ ];

    public var movies:Map<String, String> = [ ];

    public var selMovies:Array<Dynamic> = [ ];

    public var scenes:Map<String, String> = [ ];

    public var selScenes:Array<Dynamic> = [ ];

    private var _lastUpdate:Float;

    public function new() {
        
        // movie and scene
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acscene-title'), 
            [
                { n: Global.ln.get('acinfo-movieload'), a: 'movie.load', p: [
                    { t: 's', n: Global.ln.get('acinfo-movieload-p1'), v: 'movies' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-sceneload'), a: 'scene.load', p: [
                    { t: 's', n: Global.ln.get('acinfo-sceneload-p1'), v: 'scenes' }
                ], e: [ ] }
            ]
        ));


        // variables
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acvariable-title'), 
            [
                { n: Global.ln.get('acinfo-intset'), a: 'int.set', p: [
                    { t: 's', n: Global.ln.get('acinfo-intset-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-intset-p2'), v: '' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-ifintsequal'), a: 'if.intsequal', p: [
                    { t: 'i', n: Global.ln.get('acinfo-ifintsequal-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-ifintsequal-p2'), v: '' }
                ], e: [ 'then', 'else' ] }
            ]
        ));
    }

    public function getAcName(ac:String):String {
        for (gr in this.groups) {
            if (gr.actions.exists(ac)) {
                ac = gr.actions[ac].n;
            }
        }
        return (ac);
    }

    public function getNumParams(ac:String):Int {
        var ret:Int = 0;
        for (gr in this.groups) {
            if (gr.actions.exists(ac)) {
                ret = gr.actions[ac].p.length;
            }
        }
        return (ret);
    }

    public function getParamLine(ac:String, pr:Array<String>):String {
        var ret:String = '';
        for (gr in this.groups) {
            if (gr.actions.exists(ac)) {
                if (gr.actions[ac].p.length > 0) {
                    var ps:Array<String> = [ ];
                    for (i in 0...gr.actions[ac].p.length) {
                        if (pr.length > i) {
                            if (pr[i] != '') {
                                if (gr.actions[ac].p[i].v == 'movies') {
                                    ps.push(this.getMovieName(pr[i]));
                                } else if (gr.actions[ac].p[i].v == 'scenes') {
                                    ps.push(this.getSceneName(pr[i]));
                                } else {
                                    ps.push(pr[i]);
                                }
                            }
                        }
                    }
                    if (ps.length > 0) ret = ' (' + ps.join(', ') + ')';
                }
            }
        }
        return (ret);
    }

    public function getAcParam(ac:String, num:Int, val:String = null):String {
        var ret:String = '#' + (num + 1) + ': ';
        var pv:String = '';
        for (gr in this.groups) {
            if (gr.actions.exists(ac)) {
                if (gr.actions[ac].p.length > num) {
                    ret = gr.actions[ac].p[num].n + ': ';
                    pv = gr.actions[ac].p[num].v;
                }
            }
        }
        if (val != null) {
            switch (pv) {
                case 'movies': ret += this.getMovieName(val);
                case 'scenes': ret += this.getSceneName(val);
                default: ret += val;
            }
        }
        return (ret);
    }

    public function getExtra1(ac:String):String {
        var ret:String = '';
        for (gr in this.groups) {
            if (gr.actions.exists(ac)) {
                if (gr.actions[ac].e.length > 0) {
                    ret = gr.actions[ac].e[0];
                }
            }
        }
        return (ret);
    }

    public function getExtra2(ac:String):String {
        var ret:String = '';
        for (gr in this.groups) {
            if (gr.actions.exists(ac)) {
                if (gr.actions[ac].e.length > 1) {
                    ret = gr.actions[ac].e[1];
                }
            }
        }
        return (ret);
    }

    public function getMovieName(id:String):String {
        if (this.movies.exists(id)) id = this.movies[id];
        return (id);
    }

    public function getSceneName(id:String):String {
        if (this.scenes.exists(id)) id = this.scenes[id];
        return (id);
    }

    public function loadInfo(force:Bool = false):Void {
        if (force) {
            this._lastUpdate = Date.now().getTime();
            Global.ws.send('Movie/AcInfo', [
                'id' => GlobalPlayer.movie.mvId
            ], onInfo, 0, false);
        } else {
            var now:Float = Date.now().getTime();
            if ((now - this._lastUpdate) > 600000) {
                this._lastUpdate = now;
                Global.ws.send('Movie/AcInfo', [
                    'id' => GlobalPlayer.movie.mvId
                ], onInfo, 0, false);
            }
        }
    }

    private function onInfo(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                if (ld.map.exists('movies')) {
                    for (k in this.movies.keys()) this.movies.remove(k);
                    while (this.selMovies.length > 0) this.selMovies.shift();
                    for (k in Reflect.fields(ld.map['movies'])) {
                        var it:Dynamic = Reflect.field(ld.map['movies'], k);
                        this.selMovies.push({ text: it.title, value: it.id });
                        this.movies[it.id] = it.title;
                    }
                }
                if (ld.map.exists('scenes')) {
                    for (k in this.scenes.keys()) this.scenes.remove(k);
                    while (this.selScenes.length > 0) this.selScenes.shift();
                    for (k in Reflect.fields(ld.map['scenes'])) {
                        var it:Dynamic = Reflect.field(ld.map['scenes'], k);
                        this.selScenes.push({ text: it.title, value: it.id });
                        this.scenes[it.id] = it.title;
                    }
                }
            }
        }
    }

}

class ActionInfoGroup {

    public var name:String = '';

    public var actions:Map<String, ActionInfoAc> = [ ];

    public function new(nm:String, ac:Dynamic) {
        this.name = nm;
        for (f in Reflect.fields(ac)) {
            var acf:Dynamic = Reflect.field(ac, f);
            this.actions[acf.a] = new ActionInfoAc(acf);
        }
    }

}

class ActionInfoAc {

    public var a:String = '';

    public var n:String = '';

    public var p:Array<ActionInfoParam> = [ ];

    public var e:Array<String> = [ ];

    public function new(ac:Dynamic) {
        this.a = ac.a;
        this.n = ac.n;
        for (f in Reflect.fields(ac.p)) {
            this.p.push(new ActionInfoParam(Reflect.field(ac.p, f)));
        }
        this.e = ac.e;
    }

}

class ActionInfoParam {

    public var t:String = 's';

    public var n:String = '';

    public var v:String = '';

    public function new(pr:Dynamic) {
        this.t = pr.t;
        this.n = pr.n;
        this.v = pr.v;
    }

}