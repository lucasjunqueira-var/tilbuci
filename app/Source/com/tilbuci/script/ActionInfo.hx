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

    private var _mvOrigins:Map<String, String> = [ ];

    private var _scDirections:Map<String, String> = [ ];

    public function new() {

        // select values
        this._mvOrigins = [
            'alpha' => Global.ln.get('window-movieprop-oralpha'), 
            'center' => Global.ln.get('window-movieprop-orcenter'), 
            'top' => Global.ln.get('window-movieprop-ortop'), 
            'topkeep' => Global.ln.get('window-movieprop-ortopkeep'), 
            'bottom' => Global.ln.get('window-movieprop-orbottom'), 
            'bottomkeep' => Global.ln.get('window-movieprop-orbottomkeep'), 
            'left' => Global.ln.get('window-movieprop-orleft'), 
            'leftkeep' => Global.ln.get('window-movieprop-orleftkeep'), 
            'righ' => Global.ln.get('window-movieprop-orright'), 
            'rightkeep' => Global.ln.get('window-movieprop-orrightkeep'), 
        ];
        this._scDirections = [
            'up' => Global.ln.get('window-movieprop-input-opup'), 
            'down' => Global.ln.get('window-movieprop-input-opdown'), 
            'left' => Global.ln.get('window-movieprop-input-opleft'), 
            'right' => Global.ln.get('window-movieprop-input-opright'), 
            'nin' => Global.ln.get('window-movieprop-input-opnin'), 
            'nout' => Global.ln.get('window-movieprop-input-opnout'), 
        ];
        
        // movie and scene
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbmovie-title'), 
            [
                { n: Global.ln.get('acinfo-movieload'), a: 'movie.load', p: [
                    { t: 's', n: Global.ln.get('acinfo-movieload-p1'), v: 'movies' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-sceneload'), a: 'scene.load', p: [
                    { t: 's', n: Global.ln.get('acinfo-sceneload-p1'), v: 'scenes' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-scenenavigate'), a: 'scene.navigate', p: [
                    { t: 's', n: Global.ln.get('acinfo-scenenavigate-p1'), v: 'navigation' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-scenepause'), a: 'scene.pause', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-sceneplay'), a: 'scene.play', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-sceneplaypause'), a: 'scene.playpause', p: [ ], e: [ ] }, 
            ]
        ));

        // boolean variables
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbbool-title'), 
            [
                { n: Global.ln.get('acinfo-boolset'), a: 'bool.set', p: [
                    { t: 's', n: Global.ln.get('acinfo-boolset-p1'), v: '' }, 
                    { t: 'b', n: Global.ln.get('acinfo-boolset-p2'), v: '' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-ifbool'), a: 'if.bool', p: [
                    { t: 'b', n: Global.ln.get('acinfo-ifbool-p1'), v: '' }, 
                    { t: 'b', n: Global.ln.get('acinfo-ifbool-p2'), v: '' }
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-boolsetinverse'), a: 'bool.setinverse', p: [
                    { t: 's', n: Global.ln.get('acinfo-boolsetinverse-p1'), v: '' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-ifboolset'), a: 'if.boolset', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifboolset-p1'), v: '' }, 
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-boolclear'), a: 'bool.clear', p: [
                    { t: 's', n: Global.ln.get('acinfo-boolclear-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-boolclearall'), a: 'bool.clearall', p: [ ], e: [ ] }, 
            ]
        ));

        // string variables
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbstring-title'), 
            [
                { n: Global.ln.get('acinfo-stringset'), a: 'string.set', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringset-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-stringset-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-stringconcat'), a: 'string.concat', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringconcat-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-stringconcat-p2'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-stringconcat-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-stringreplace'), a: 'string.replace', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringreplace-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-stringreplace-p2'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-stringreplace-p3'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-stringreplace-p4'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-stringclear'), a: 'string.clear', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringclear-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-stringtoint'), a: 'string.toint', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringtoint-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-stringtoint-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-stringtofloat'), a: 'string.tofloat', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringtofloat-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-stringtofloat-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-stringsetgroup'), a: 'string.setgroup', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringsetgroup-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-stringclearall'), a: 'string.clearall', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-stringsetglobal'), a: 'string.setglobal', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringsetglobal-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-stringsetglobal-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-stringclearglobal'), a: 'string.clearglobal', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringclearglobal-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-ifstringsequal'), a: 'if.stringsequal', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifstringsequal-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-ifstringsequal-p2'), v: '' }, 
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-ifstringsdifferent'), a: 'if.stringsdifferent', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifstringsdifferent-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-ifstringsdifferent-p2'), v: '' }, 
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-ifstringset'), a: 'if.stringset', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifstringset-p1'), v: '' }, 
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-ifstringcontains'), a: 'if.stringcontains', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifstringcontains-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-ifstringcontains-p2'), v: '' }, 
                ], e: [ 'then', 'else' ] },
                { n: Global.ln.get('acinfo-ifstringstartswith'), a: 'if.stringstartswith', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifstringstartswith-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-ifstringstartswith-p2'), v: '' }, 
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-ifstringendswith'), a: 'if.stringendswith', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifstringendswith-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-ifstringendswith-p2'), v: '' }, 
                ], e: [ 'then', 'else' ] }, 
            ]
        ));

        // integer variables
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbint-title'), 
            [
                { n: Global.ln.get('acinfo-intset'), a: 'int.set', p: [
                    { t: 's', n: Global.ln.get('acinfo-intset-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intset-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-intsum'), a: 'int.sum', p: [
                    { t: 's', n: Global.ln.get('acinfo-intsum-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intsum-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intsum-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-intsubtract'), a: 'int.subtract', p: [
                    { t: 's', n: Global.ln.get('acinfo-intsubtract-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intsubtract-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intsubtract-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-intmultiply'), a: 'int.multiply', p: [
                    { t: 's', n: Global.ln.get('acinfo-intmultiply-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intmultiply-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intmultiply-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-intdivide'), a: 'int.divide', p: [
                    { t: 's', n: Global.ln.get('acinfo-intdivide-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intdivide-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intdivide-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-intmax'), a: 'int.max', p: [
                    { t: 's', n: Global.ln.get('acinfo-intmax-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intmax-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intmax-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-intmin'), a: 'int.min', p: [
                    { t: 's', n: Global.ln.get('acinfo-intmin-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intmin-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intmin-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-intrandom'), a: 'int.random', p: [
                    { t: 's', n: Global.ln.get('acinfo-intrandom-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intrandom-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intrandom-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-intabs'), a: 'int.abs', p: [
                    { t: 's', n: Global.ln.get('acinfo-intabs-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-intabs-p2'), v: '' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-intclear'), a: 'int.clear', p: [
                    { t: 's', n: Global.ln.get('acinfo-intclear-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-intclearall'), a: 'int.clearall', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inttofloat'), a: 'int.tofloat', p: [
                    { t: 's', n: Global.ln.get('acinfo-inttofloat-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inttofloat-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inttostring'), a: 'int.tostring', p: [
                    { t: 's', n: Global.ln.get('acinfo-inttostring-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inttostring-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-ifintsequal'), a: 'if.intsequal', p: [
                    { t: 'f', n: Global.ln.get('acinfo-ifintsequal-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-ifintsequal-p2'), v: '' }
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-ifintsdifferent'), a: 'if.intsdifferent', p: [
                    { t: 'f', n: Global.ln.get('acinfo-ifintsdifferent-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-ifintsdifferent-p2'), v: '' }
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-ifintgreater'), a: 'if.intgreater', p: [
                    { t: 'f', n: Global.ln.get('acinfo-ifintgreater-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-ifintgreater-p2'), v: '' }
                ], e: [ 'then', 'else' ] },
                { n: Global.ln.get('acinfo-ifintlower'), a: 'if.intlower', p: [
                    { t: 'f', n: Global.ln.get('acinfo-ifintlower-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-ifintlower-p2'), v: '' }
                ], e: [ 'then', 'else' ] },
                { n: Global.ln.get('acinfo-ifintgreaterequal'), a: 'if.intgreaterequal', p: [
                    { t: 'f', n: Global.ln.get('acinfo-ifintgreaterequal-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-ifintgreaterequal-p2'), v: '' }
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-ifintlowerequal'), a: 'if.intlowerequal', p: [
                    { t: 'f', n: Global.ln.get('acinfo-ifintlowerequal-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-ifintlowerequal-p2'), v: '' }
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-ifintset'), a: 'if.intset', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifintset-p1'), v: '' }, 
                ], e: [ 'then', 'else' ] }, 

            ]
        ));

        // float variables
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbfloat-title'), 
            [
                { n: Global.ln.get('acinfo-floatset'), a: 'float.set', p: [
                    { t: 's', n: Global.ln.get('acinfo-floatset-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatset-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floatsum'), a: 'float.sum', p: [
                    { t: 's', n: Global.ln.get('acinfo-floatsum-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatsum-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatsum-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floatsubtract'), a: 'float.subtract', p: [
                    { t: 's', n: Global.ln.get('acinfo-floatsubtract-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatsubtract-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatsubtract-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floatmultiply'), a: 'float.multiply', p: [
                    { t: 's', n: Global.ln.get('acinfo-floatmultiply-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatmultiply-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatmultiply-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floatdivide'), a: 'float.divide', p: [
                    { t: 's', n: Global.ln.get('acinfo-floatdivide-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatdivide-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatdivide-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floatmax'), a: 'float.max', p: [
                    { t: 's', n: Global.ln.get('acinfo-floatmax-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatmax-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatmax-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floatmin'), a: 'float.min', p: [
                    { t: 's', n: Global.ln.get('acinfo-floatmin-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatmin-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatmin-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floatrandom'), a: 'float.random', p: [
                    { t: 's', n: Global.ln.get('acinfo-floatrandom-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatrandom-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatrandom-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floatabs'), a: 'float.abs', p: [
                    { t: 's', n: Global.ln.get('acinfo-floatabs-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floatabs-p2'), v: '' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floatclear'), a: 'float.clear', p: [
                    { t: 's', n: Global.ln.get('acinfo-floatclear-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floatclearall'), a: 'float.clearall', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floattoint'), a: 'float.toint', p: [
                    { t: 's', n: Global.ln.get('acinfo-floattoint-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floattoint-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-floattostring'), a: 'float.tostring', p: [
                    { t: 's', n: Global.ln.get('acinfo-floattostring-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-floattostring-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-iffloatsequal'), a: 'if.floatsequal', p: [
                    { t: 'f', n: Global.ln.get('acinfo-iffloatsequal-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-iffloatsequal-p2'), v: '' }
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-iffloatsdifferent'), a: 'if.floatsdifferent', p: [
                    { t: 'f', n: Global.ln.get('acinfo-iffloatsdifferent-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-iffloatsdifferent-p2'), v: '' }
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-iffloatgreater'), a: 'if.floatgreater', p: [
                    { t: 'f', n: Global.ln.get('acinfo-iffloatgreater-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-iffloatgreater-p2'), v: '' }
                ], e: [ 'then', 'else' ] },
                { n: Global.ln.get('acinfo-iffloatlower'), a: 'if.floatlower', p: [
                    { t: 'f', n: Global.ln.get('acinfo-iffloatlower-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-iffloatlower-p2'), v: '' }
                ], e: [ 'then', 'else' ] },
                { n: Global.ln.get('acinfo-iffloatgreaterequal'), a: 'if.floatgreaterequal', p: [
                    { t: 'f', n: Global.ln.get('acinfo-iffloatgreaterequal-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-iffloatgreaterequal-p2'), v: '' }
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-iffloatlowerequal'), a: 'if.floatlowerequal', p: [
                    { t: 'f', n: Global.ln.get('acinfo-iffloatlowerequal-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-iffloatlowerequal-p2'), v: '' }
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-iffloatset'), a: 'if.floatset', p: [
                    { t: 's', n: Global.ln.get('acinfo-iffloatset-p1'), v: '' }, 
                ], e: [ 'then', 'else' ] }, 

            ]
        ));

        // instance manipulation
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbinstance-title'), 
            [
                { n: Global.ln.get('acinfo-instancepause'), a: 'instance.pause', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancepause-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceplay'), a: 'instance.play', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceplay-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceplaypause'), a: 'instance.playpause', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceplaypause-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancestop'), a: 'instance.stop', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancestop-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancenext'), a: 'instance.next', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancenext-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceprevious'), a: 'instance.previous', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceprevious-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceseek'), a: 'instance.seek', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceseek-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instanceseek-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetparagraph'), a: 'instance.setparagraph', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetparagraph-p1'), v: 'instances' }, 
                    { t: 's', n: Global.ln.get('acinfo-instancesetparagraph-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceloadasset'), a: 'instance.loadasset', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceloadasset-p1'), v: 'instances' }, 
                    { t: 's', n: Global.ln.get('acinfo-instanceloadasset-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetx'), a: 'instance.setx', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetx-p1'), v: 'instances' }, 
                    { t: 'f', n: Global.ln.get('acinfo-instancesetx-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesety'), a: 'instance.sety', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesety-p1'), v: 'instances' }, 
                    { t: 'f', n: Global.ln.get('acinfo-instancesety-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetwidth'), a: 'instance.setwidth', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetwidth-p1'), v: 'instances' }, 
                    { t: 'f', n: Global.ln.get('acinfo-instancesetwidth-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetheight'), a: 'instance.setheight', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetheight-p1'), v: 'instances' }, 
                    { t: 'f', n: Global.ln.get('acinfo-instancesetheight-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetvisible'), a: 'instance.setvisible', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetvisible-p1'), v: 'instances' }, 
                    { t: 'b', n: Global.ln.get('acinfo-instancesetvisible-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetalpha'), a: 'instance.setalpha', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetalpha-p1'), v: 'instances' }, 
                    { t: 'f', n: Global.ln.get('acinfo-instancesetalpha-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetwidth'), a: 'instance.setwidth', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetwidth-p1'), v: 'instances' }, 
                    { t: 'f', n: Global.ln.get('acinfo-instancesetwidth-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetorder'), a: 'instance.setorder', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetorder-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instancesetorder-p2'), v: '' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-instancesetcolor'), a: 'instance.setcolor', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetcolor-p1'), v: 'instances' }, 
                    { t: 's', n: Global.ln.get('acinfo-instancesetcolor-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetcoloralpha'), a: 'instance.setcoloralpha', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetcoloralpha-p1'), v: 'instances' }, 
                    { t: 'f', n: Global.ln.get('acinfo-instancesetcoloralpha-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetfont'), a: 'instance.setfont', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetfont-p1'), v: 'instances' }, 
                    { t: 's', n: Global.ln.get('acinfo-instancesetfont-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetfontsize'), a: 'instance.setfontsize', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetfontsize-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instancesetfontsize-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetfontalign'), a: 'instance.setfontalign', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetfontalign-p1'), v: 'instances' }, 
                    { t: 's', n: Global.ln.get('acinfo-instancesetfontalign-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetfontbackground'), a: 'instance.setfontbackground', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetfontbackground-p1'), v: 'instances' }, 
                    { t: 'e', n: Global.ln.get('acinfo-instancesetfontbackground-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetfontbold'), a: 'instance.setfontbold', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetfontbold-p1'), v: 'instances' }, 
                    { t: 'b', n: Global.ln.get('acinfo-instancesetfontbold-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetfontitalic'), a: 'instance.setfontitalic', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetfontitalic-p1'), v: 'instances' }, 
                    { t: 'b', n: Global.ln.get('acinfo-instancesetfontitalic-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetfontcolor'), a: 'instance.setfontcolor', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetfontcolor-p1'), v: 'instances' }, 
                    { t: 's', n: Global.ln.get('acinfo-instancesetfontcolor-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetfontleading'), a: 'instance.setfontleading', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetfontleading-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instancesetfontleading-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetvolume'), a: 'instance.setvolume', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetvolume-p1'), v: 'instances' }, 
                    { t: 'f', n: Global.ln.get('acinfo-instancesetvolume-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancesetrotation'), a: 'instance.setrotation', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancesetrotation-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instancesetrotation-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancescrolldown'), a: 'instance.scrolldown', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancescrolldown-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancescrollup'), a: 'instance.scrollup', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancescrollup-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancescrollbottom'), a: 'instance.scrollbottom', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancescrollbottom-p1'), v: 'instances' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-instancescrolltop'), a: 'instance.scrolltop', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancescrolltop-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearall'), a: 'instance.clearall', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearall-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearx'), a: 'instance.clearx', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearx-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancecleary'), a: 'instance.cleary', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancecleary-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearwidth'), a: 'instance.clearwidth', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearwidth-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearheight'), a: 'instance.clearheight', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearheight-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearvisible'), a: 'instance.clearvisible', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearvisible-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearalpha'), a: 'instance.clearalpha', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearalpha-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearwidth'), a: 'instance.clearwidth', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearwidth-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearorder'), a: 'instance.clearorder', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearorder-p1'), v: 'instances' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-instanceclearcolor'), a: 'instance.clearcolor', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearcolor-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearcoloralpha'), a: 'instance.clearcoloralpha', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearcoloralpha-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearfont'), a: 'instance.clearfont', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearfont-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearfontsize'), a: 'instance.clearfontsize', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearfontsize-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearfontalign'), a: 'instance.clearfontalign', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearfontalign-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearfontbackground'), a: 'instance.clearfontbackground', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearfontbackground-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearfontbold'), a: 'instance.clearfontbold', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearfontbold-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearfontitalic'), a: 'instance.clearfontitalic', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearfontitalic-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearfontcolor'), a: 'instance.clearfontcolor', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearfontcolor-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearfontleading'), a: 'instance.clearfontleading', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearfontleading-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearvolume'), a: 'instance.clearvolume', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearvolume-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearrotation'), a: 'instance.clearrotation', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearrotation-p1'), v: 'instances' }, 
                ], e: [ ] }, 
            ]
        ));

        // data handling
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbdata-title'), 
            [
                { n: Global.ln.get('acinfo-dataevent'), a: 'data.event', p: [
                    { t: 's', n: Global.ln.get('acinfo-dataevent-p1'), v: '' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-dataliststates'), a: 'data.liststates', p: [ ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-dataload'), a: 'data.load', p: [
                    { t: 's', n: Global.ln.get('acinfo-dataload-p1'), v: '' }
                ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-dataloadlocal'), a: 'data.loadlocal', p: [
                    { t: 's', n: Global.ln.get('acinfo-dataloadlocal-p1'), v: '' }
                ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-dataloadquickstate'), a: 'data.loadquickstate', p: [ ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-dataloadstatelocal'), a: 'data.loadstatelocal', p: [ ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-datasave'), a: 'data.save', p: [
                    { t: 's', n: Global.ln.get('acinfo-datasave-p1'), v: '' }, 
                    { t: 'v', n: Global.ln.get('acinfo-datasave-p2'), v: '' }, 
                ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-datasavelocal'), a: 'data.savelocal', p: [
                    { t: 's', n: Global.ln.get('acinfo-datasavelocal-p1'), v: '' }, 
                    { t: 'v', n: Global.ln.get('acinfo-datasavelocal-p2'), v: '' }, 
                ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-datasavestate'), a: 'data.savestate', p: [ ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-datasavequickstate'), a: 'data.savequickstate', p: [ ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-datasavestatelocal'), a: 'data.savestatelocal', p: [ ], e: [ 'success', 'error' ] }, 
            ]
        ));

        // input handling
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbinput-title'), 
            [
                { n: Global.ln.get('acinfo-inputmessage'), a: 'input.message', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputmessage-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-inputmessage-p2'), v: '' }, 
                ], e: [ 'ok', 'cancel' ] }, 
                { n: Global.ln.get('acinfo-inputstring'), a: 'input.string', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputstring-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-inputstring-p2'), v: '' }, 
                ], e: [ 'ok', 'cancel' ] }, 
                { n: Global.ln.get('acinfo-inputint'), a: 'input.int', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputint-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-inputint-p2'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputint-p3'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputint-p4'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputint-p5'), v: '' }, 
                ], e: [ 'ok', 'cancel' ] }, 
                { n: Global.ln.get('acinfo-inputfloat'), a: 'input.float', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputfloat-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-inputfloat-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputfloat-p3'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputfloat-p4'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputfloat-p5'), v: '' }, 
                ], e: [ 'ok', 'cancel' ] }, 
                { n: Global.ln.get('acinfo-inputlist'), a: 'input.list', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputlist-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-inputlist-p2'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-inputlist-p3'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-inputlist-p4'), v: '' }, 
                ], e: [ 'ok', 'cancel' ] }, 
                { n: Global.ln.get('acinfo-inputlogin'), a: 'input.login', p: [ ], e: [ 'ok', 'cancel' ] }, 
                { n: Global.ln.get('acinfo-inputemail'), a: 'input.email', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputemail-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-inputemail-p2'), v: '' }, 
                ], e: [ 'ok', 'cancel' ] }, 
            ]
        ));

        // system
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbsystem-title'), 
            [
                { n: Global.ln.get('acinfo-systemfullscreen'), a: 'system.fullscreen', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-run'), a: 'run', p: [
                    { t: 's', n: Global.ln.get('acinfo-run-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-systemopenembed'), a: 'system.openembed', p: [
                    { t: 's', n: Global.ln.get('acinfo-systemopenembed-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-systemopenurl'), a: 'system.openurl', p: [
                    { t: 's', n: Global.ln.get('acinfo-systemopenurl-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-systemcopytext'), a: 'system.copytext', p: [
                    { t: 's', n: Global.ln.get('acinfo-systemcopytext-p1'), v: '' }, 
                ], e: [ ] },  
                { n: Global.ln.get('acinfo-systemquit'), a: 'system.quit', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-systemlogout'), a: 'system.logout', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-systemsendevent'), a: 'system.sendevent', p: [
                    { t: 's', n: Global.ln.get('acinfo-systemsendevent-p1'), v: '' }, 
                ], e: [ ] },  
                { n: Global.ln.get('acinfo-cssset'), a: 'css.set', p: [
                    { t: 's', n: Global.ln.get('acinfo-cssset-p1'), v: '' }, 
                ], e: [ ] },  
                { n: Global.ln.get('acinfo-cssclear'), a: 'css.clear', p: [ ], e: [ ] },  
            ]
        ));

        // timer
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbtimer-title'), 
            [
                { n: Global.ln.get('acinfo-timerset'), a: 'timer.set', p: [
                    { t: 's', n: Global.ln.get('acinfo-timerset-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-timerset-p2'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-timerset-p3'), v: '' }, 
                ], e: [ 'tick', 'end' ] },  
                { n: Global.ln.get('acinfo-timerclear'), a: 'timer.clear', p: [
                    { t: 's', n: Global.ln.get('acinfo-timerclear-p1'), v: '' }, 
                ], e: [ ] },  
                { n: Global.ln.get('acinfo-timerclearall'), a: 'timer.clearall', p: [ ], e: [ ] }, 
            ]
        ));

        // replace
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbreplace-title'), 
            [
                { n: Global.ln.get('acinfo-replaceorigin'), a: 'replace.origin', p: [
                    { t: 's', n: Global.ln.get('acinfo-replaceorigin-p1'), v: 'origins' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-replacesetstring'), a: 'replace.setstring', p: [
                    { t: 's', n: Global.ln.get('acinfo-replacesetstring-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-replacesetstring-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-replacesetfile'), a: 'replace.setfile', p: [
                    { t: 's', n: Global.ln.get('acinfo-replacesetfile-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-replacesetfile-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-replaceclearstring'), a: 'replace.clearstring', p: [
                    { t: 's', n: Global.ln.get('acinfo-replaceclearstring-p1'), v: '' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-replaceclearfile'), a: 'replace.clearfile', p: [
                    { t: 's', n: Global.ln.get('acinfo-replaceclearfile-p1'), v: '' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-replaceclearallstrings'), a: 'replace.clearallstrings', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-replaceclearallfiles'), a: 'replace.clearallfiles', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-ifreplacestringset'), a: 'if.replacestringset', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifreplacestringset-p1'), v: '' }
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-ifreplacefileset'), a: 'if.replacefileset', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifreplacefileset-p1'), v: '' }
                ], e: [ 'then', 'else' ] }, 
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
                                } else if (gr.actions[ac].p[i].v == 'origins') {
                                    if (this._mvOrigins.exists(pr[i])) {
                                        ps.push(this._mvOrigins[pr[i]]);
                                    } else {
                                        ps.push(pr[i]);
                                    }
                                } else if (gr.actions[ac].p[i].v == 'navigation') {
                                    if (this._scDirections.exists(pr[i])) {
                                        ps.push(this._scDirections[pr[i]]);
                                    } else {
                                        ps.push(pr[i]);
                                    }
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
                case 'origins':
                    if (this._mvOrigins.exists(val)) {
                        ret += this._mvOrigins[val];
                    } else {
                        ret += val;
                    }
                case 'navigation':
                    if (this._scDirections.exists(val)) {
                        ret += this._scDirections[val];
                    } else {
                        ret += val;
                    }
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