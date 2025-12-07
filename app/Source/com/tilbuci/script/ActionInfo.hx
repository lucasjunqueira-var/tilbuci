/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

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

    private var _mnPlacement:Map<String, String> = [ ];

    public function new() {

        // select values
        this._mvOrigins = [
            'none' => Global.ln.get('window-movieprop-ornone'), 
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
        this._mnPlacement = [
            'center' => Global.ln.get('placement-center'), 
            'centerleft' => Global.ln.get('placement-centerleft'), 
            'centerright' => Global.ln.get('placement-centerright'), 
            'top' => Global.ln.get('placement-top'), 
            'topleft' => Global.ln.get('placement-topleft'), 
            'topright' => Global.ln.get('placement-topright'), 
            'bottom' => Global.ln.get('placement-bottom'), 
            'bottomleft' => Global.ln.get('placement-bottomleft'), 
            'bottomright' => Global.ln.get('placement-bottomright'), 
            'absolute' => Global.ln.get('placement-absolute'), 
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
                { n: Global.ln.get('acinfo-scenehistoryback'), a: 'scene.historyback', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-scenenavigate'), a: 'scene.navigate', p: [
                    { t: 's', n: Global.ln.get('acinfo-scenenavigate-p1'), v: 'navigation' }
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-scenepause'), a: 'scene.pause', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-sceneplay'), a: 'scene.play', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-sceneplaypause'), a: 'scene.playpause', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-scenenextkf'), a: 'scene.nextkeyframe', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-scenepreviouskf'), a: 'scene.previouskeyframe', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-scenefirstkf'), a: 'scene.loadfirstkeyframe', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-scenelastkf'), a: 'scene.loadlastkeyframe', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-sceneloadkf'), a: 'scene.loadkeyframe', p: [
                    { t: 'i', n: Global.ln.get('acinfo-sceneloadkf-p1'), v: '' }
                ], e: [ ] },
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
                    { t: 'e', n: Global.ln.get('acinfo-stringset-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-stringconcat'), a: 'string.concat', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringconcat-p1'), v: '' }, 
                    { t: '', n: Global.ln.get('acinfo-stringconcat-p2'), v: '' }, 
                    { t: '', n: Global.ln.get('acinfo-stringconcat-p3'), v: '' }, 
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
                { n: Global.ln.get('acinfo-stringsload'), a: 'string.loadfile', p: [
                    { t: 's', n: Global.ln.get('acinfo-stringsload-p1'), v: '' }, 
                ], e: [ 'success', 'error' ] }, 
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
                { n: Global.ln.get('acinfo-ifstringemail'), a: 'if.stringemail', p: [
                    { t: 's', n: Global.ln.get('acinfo-ifstringemail-p1'), v: '' }, 
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

        // array files
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbarray-title'), 
            [
                { n: Global.ln.get('acinfo-arrayload'), a: 'array.loadfile', p: [
                    { t: 's', n: Global.ln.get('acinfo-arrayload-p1'), v: '' }, 
                ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-arraycreate'), a: 'array.create', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraycreate-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arrayremove'), a: 'array.remove', p: [
                    { t: 's', n: Global.ln.get('acinfo-arrayremove-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraypush'), a: 'array.push', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraypush-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraypush-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arrayset'), a: 'array.set', p: [
                    { t: 's', n: Global.ln.get('acinfo-arrayset-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-arrayset-p2'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arrayset-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arrayget'), a: 'array.get', p: [
                    { t: 's', n: Global.ln.get('acinfo-arrayget-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-arrayget-p2'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arrayget-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraygetint'), a: 'array.getint', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraygetint-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-arraygetint-p2'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraygetint-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraygetfloat'), a: 'array.getfloat', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraygetfloat-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-arraygetfloat-p2'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraygetfloat-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraygetbool'), a: 'array.getbool', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraygetbool-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-arraygetbool-p2'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraygetbool-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arrayclear'), a: 'array.clear', p: [
                    { t: 's', n: Global.ln.get('acinfo-arrayclear-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraycurrent'), a: 'array.current', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraycurrent-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraycurrent-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraynext'), a: 'array.next', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraynext-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraynext-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arrayprevious'), a: 'array.previous', p: [
                    { t: 's', n: Global.ln.get('acinfo-arrayprevious-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arrayprevious-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraycurrentint'), a: 'array.currentint', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraycurrentint-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraycurrentint-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraynextint'), a: 'array.nextint', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraynextint-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraynextint-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraypreviousint'), a: 'array.previousint', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraypreviousint-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraypreviousint-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraycurrentfloat'), a: 'array.currentfloat', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraycurrentfloat-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraycurrentfloat-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraynextfloat'), a: 'array.nextfloat', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraynextfloat-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraynextfloat-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraypreviousfloat'), a: 'array.previousfloat', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraypreviousfloat-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraypreviousfloat-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraycurrentbool'), a: 'array.currentbool', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraycurrentbool-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraycurrentbool-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraynextbool'), a: 'array.nextbool', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraynextbool-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraynextbool-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-arraypreviousbool'), a: 'array.previousbool', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraypreviousbool-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraypreviousbool-p2'), v: '' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-arraysetindex'), a: 'array.setindex', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraysetindex-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-arraysetindex-p2'), v: '' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-arraygetindex'), a: 'array.getindex', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraygetindex-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraygetindex-p2'), v: '' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-arraytostring'), a: 'array.tostring', p: [
                    { t: 's', n: Global.ln.get('acinfo-arraytostring-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arraytostring-p2'), v: '' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-arrayfromstring'), a: 'array.fromstring', p: [
                    { t: 's', n: Global.ln.get('acinfo-arrayfromstring-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-arrayfromstring-p2'), v: '' }, 
                ], e: [ ] },
            ]
        ));

        // instance manipulation
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbinstance-title'), 
            [
                { n: Global.ln.get('acinfo-instancemorezoom'), a: 'instance.morezoom', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancemorezoom-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instancemorezoom-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancelesszoom'), a: 'instance.lesszoom', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancelesszoom-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instancelesszoom-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearzoom'), a: 'instance.clearzoom', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearzoom-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancemoveup'), a: 'instance.moveup', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancemoveup-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instancemoveup-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancemovedown'), a: 'instance.movedown', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancemovedown-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instancemovedown-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancemoveleft'), a: 'instance.moveleft', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancemoveleft-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instancemoveleft-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancemoveright'), a: 'instance.moveright', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancemoveright-p1'), v: 'instances' }, 
                    { t: 'i', n: Global.ln.get('acinfo-instancemoveright-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instanceclearmove'), a: 'instance.clearmove', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceclearmove-p1'), v: 'instances' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-instancestartdrag'), a: 'instance.startdrag', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancestartdrag-p1'), v: 'instances' }, 
                ], e: [ 'complete' ] }, 
                { n: Global.ln.get('acinfo-instancestopdrag'), a: 'instance.stopdrag', p: [ ], e: [ ] },
                
                { n: Global.ln.get('acinfo-instanceisoverlapping'), a: 'instance.isoverlapping', p: [
                    { t: 's', n: Global.ln.get('acinfo-instanceisoverlapping-p1'), v: 'instances' }, 
                    { t: 's', n: Global.ln.get('acinfo-instanceisoverlapping-p2'), v: 'instances' }, 
                ], e: [ 'then', 'else' ] }, 
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
                { n: Global.ln.get('acinfo-instancezoom'), a: 'instance.zoom', p: [
                    { t: 's', n: Global.ln.get('acinfo-instancezoom-p1'), v: 'instances' }, 
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
                { n: Global.ln.get('acinfo-dataeventclear'), a: 'data.eventclear', p: [ ], e: [ ] }, 
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
                { n: Global.ln.get('acinfo-targetshow'), a: 'target.show', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-targethide'), a: 'target.hide', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-targettoggle'), a: 'target.toggle', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-targetsetposition'), a: 'target.setposition', p: [
                    { t: 'i', n: Global.ln.get('acinfo-targetsetposition-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-targetsetposition-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-targetclear'), a: 'target.clear', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-targetset'), a: 'target.set', p: [
                    { t: 's', n: Global.ln.get('acinfo-targetset-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-mousehide'), a: 'mouse.hide', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-mouseshow'), a: 'mouse.show', p: [ ], e: [ ] }, 
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
                { n: Global.ln.get('acinfo-inputadd'), a: 'input.add', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputadd-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputadd-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputadd-p3'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputadd-p4'), v: '' }, 
                    { t: 'e', n: Global.ln.get('acinfo-inputadd-p5'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputplace'), a: 'input.place', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputplace-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputplace-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputplace-p3'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputplace-p4'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputsettext'), a: 'input.settext', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputsettext-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-inputsettext-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputsetpassword'), a: 'input.setpassword', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputsetpassword-p1'), v: '' }, 
                    { t: 'b', n: Global.ln.get('acinfo-inputsetpassword-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputremove'), a: 'input.remove', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputremove-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputremoveall'), a: 'input.removeall', p: [ ], e: [ ] }, 

                { n: Global.ln.get('acinfo-inputaddtarea'), a: 'input.addtarea', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputaddtarea-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputaddtarea-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputaddtarea-p3'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputaddtarea-p4'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputaddtarea-p5'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputplacetarea'), a: 'input.placetarea', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputplacetarea-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputplacetarea-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputplacetarea-p3'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputplacetarea-p4'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputplacetarea-p5'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputsettextarea'), a: 'input.settextarea', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputsettextarea-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-inputsettextarea-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputremovetarea'), a: 'input.removetarea', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputremovetarea-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputremovealltareas'), a: 'input.removealltareas', p: [ ], e: [ ] }, 

                { n: Global.ln.get('acinfo-inputaddnumeric'), a: 'input.addnumeric', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputaddnumeric-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputaddnumeric-p2'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputaddnumeric-p3'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputaddnumeric-p4'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputaddnumeric-p5'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputplacenumeric'), a: 'input.placenumeric', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputplacenumeric-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputplacenumeric-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputplacenumeric-p3'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputplacenumeric-p4'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputsetnumeric'), a: 'input.setnumeric', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputsetnumeric-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputsetnumeric-p2'), v: '' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-inputsetnumericbounds'), a: 'input.setnumericbounds', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputsetnumericbounds-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputsetnumericbounds-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputsetnumericbounds-p3'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-inputsetnumericbounds-p4'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputremovenumeric'), a: 'input.removenumeric', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputremovenumeric-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputremoveallnumerics'), a: 'input.removeallnumerics', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputaddaddtoggle'), a: 'input.addtoggle', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputaddaddtoggle-p1'), v: '' }, 
                    { t: 'b', n: Global.ln.get('acinfo-inputaddaddtoggle-p2'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputaddaddtoggle-p3'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputaddaddtoggle-p4'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputplacetoggle'), a: 'input.placetoggle', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputplacetoggle-p1'), v: '' }, 
                    { t: 'b', n: Global.ln.get('acinfo-inputplacetoggle-p2'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-inputplacetoggle-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputsettoggle'), a: 'input.settoggle', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputsettoggle-p1'), v: '' }, 
                    { t: 'b', n: Global.ln.get('acinfo-inputsettoggle-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputinverttoggle'), a: 'input.inverttoggle', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputinverttoggle-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputremovetoggle'), a: 'input.removetoggle', p: [
                    { t: 's', n: Global.ln.get('acinfo-inputremovetoggle-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-inputrremovealltoggles'), a: 'input.removealltoggles', p: [ ], e: [ ] }, 
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
                { n: Global.ln.get('acinfo-systemcloseembed'), a: 'system.closeembed', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-systemsembedplace'), a: 'system.embedplace', p: [
                    { t: 'f', n: Global.ln.get('acinfo-systemsembedplace-p1'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-systemsembedplace-p2'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-systemsembedplace-p3'), v: '' }, 
                    { t: 'f', n: Global.ln.get('acinfo-systemsembedplace-p4'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-systemembedreset'), a: 'system.embedreset', p: [ ], e: [ ] },
                { n: Global.ln.get('acinfo-systemopenurl'), a: 'system.openurl', p: [
                    { t: 's', n: Global.ln.get('acinfo-systemopenurl-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-systemcopytext'), a: 'system.copytext', p: [
                    { t: 's', n: Global.ln.get('acinfo-systemcopytext-p1'), v: '' }, 
                ], e: [ ] },  
                { n: Global.ln.get('acinfo-systemifhorizontal'), a: 'system.ifhorizontal', p: [ ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-systemifvertical'), a: 'system.ifvertical', p: [ ], e: [ 'then', 'else' ] }, 
                //{ n: Global.ln.get('acinfo-systemquit'), a: 'system.quit', p: [ ], e: [ ] },  
                //{ n: Global.ln.get('acinfo-systempwainstall'), a: 'system.pwainstall', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-systemifwebsite'), a: 'system.ifwebsite', p: [ ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-systemifpwa'), a: 'system.ifpwa', p: [ ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-systemifpwainstalled'), a: 'system.ifpwainstalled', p: [ ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-systemifdesktop'), a: 'system.ifdesktop', p: [ ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-systemifmobile'), a: 'system.ifmobile', p: [ ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-systemifpublish'), a: 'system.ifpublish', p: [ ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-systemifplayer'), a: 'system.ifplayer', p: [ ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-systemvisitoringroup'), a: 'system.visitoringroup', p: [
                    { t: 's', n: Global.ln.get('acinfo-systemvisitoringroup-p1'), v: '' }, 
                ], e: [ 'then', 'else' ] },   
                { n: Global.ln.get('acinfo-systemlogout'), a: 'system.logout', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-systemsendevent'), a: 'system.sendevent', p: [
                    { t: 's', n: Global.ln.get('acinfo-systemsendevent-p1'), v: '' }, 
                ], e: [ ] },  
                { n: Global.ln.get('acinfo-systemsetkftime'), a: 'system.setkftime', p: [
                    { t: 'i', n: Global.ln.get('acinfo-systemsetkftime-p1'), v: '' }, 
                ], e: [ ] },  
                { n: Global.ln.get('acinfo-systemcalljs'), a: 'system.calljs', p: [
                    { t: 's', n: Global.ln.get('acinfo-systemcalljs-p1'), v: '' }, 
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

        // contraptions
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbcontraptions-title'), 
            [
                { n: Global.ln.get('acinfo-showmessage'), a: 'contraption.message', p: [
                    { t: 's', n: Global.ln.get('acinfo-showmessage-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-showmessage-p2'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-showmessage-p3'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-showmessage-p4'), v: '' }, 
                ], e: [ 'select' ] }, 
                { n: Global.ln.get('acinfo-hidemessage'), a: 'contraption.messagehide', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-showmenu'), a: 'contraption.menu', p: [
                    { t: 's', n: Global.ln.get('acinfo-showmenu-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-showmenu-p2'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-showmenu-p3'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-showmenu-p4'), v: 'placement' }, 
                    { t: 'i', n: Global.ln.get('acinfo-showmenu-p5'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-showmenu-p6'), v: '' }, 
                ], e: [ 'select' ] }, 
                { n: Global.ln.get('acinfo-hidemenu'), a: 'contraption.menuhide', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-showcover'), a: 'contraption.cover', p: [
                    { t: 's', n: Global.ln.get('acinfo-showcover-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-hidecover'), a: 'contraption.coverhide', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-showbg'), a: 'contraption.background', p: [
                    { t: 's', n: Global.ln.get('acinfo-showbg-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-hidebg'), a: 'contraption.backgroundhide', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-showloading'), a: 'contraption.showloading', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-hideloading'), a: 'contraption.hideloading', p: [ ], e: [ ] },
                { n: Global.ln.get('acinfo-musicplay'), a: 'contraption.musicplay', p: [
                    { t: 's', n: Global.ln.get('acinfo-musicplay-p1'), v: '' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-musicpause'), a: 'contraption.musicpause', p: [ ], e: [ ] },
                { n: Global.ln.get('acinfo-musicstop'), a: 'contraption.musicstop', p: [ ], e: [ ] },
                { n: Global.ln.get('acinfo-musicvolume'), a: 'contraption.musicvolume', p: [
                    { t: 'i', n: Global.ln.get('acinfo-musicvolume-p1'), v: '' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-showform'), a: 'contraption.form', p: [
                    { t: 's', n: Global.ln.get('acinfo-showform-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-showform-p2'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-showform-p3'), v: '' }, 
                ], e: [ 'ok', 'cancel' ] }, 
                { n: Global.ln.get('acinfo-setformvalue'), a: 'contraption.formvalue', p: [
                    { t: 's', n: Global.ln.get('acinfo-setformvalue-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-setformvalue-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-setformstepper'), a: 'contraption.formsetstepper', p: [
                    { t: 's', n: Global.ln.get('acinfo-setformstepper-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-setformstepper-p2'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-setformstepper-p3'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-setformstepper-p4'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-hideform'), a: 'contraption.formhide', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-showinterf'), a: 'contraption.interface', p: [
                    { t: 's', n: Global.ln.get('acinfo-showinterf-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-showinterf-p2'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-showinterf-p3'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-hideinterf'), a: 'contraption.interfacehide', p: [
                    { t: 's', n: Global.ln.get('acinfo-hideinterf-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-hideallinterf'), a: 'contraption.interfacehideall', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-interftext'), a: 'contraption.interfacetext', p: [
                    { t: 's', n: Global.ln.get('acinfo-interftext-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-interftext-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-interfframe'), a: 'contraption.interfaceanimframe', p: [
                    { t: 's', n: Global.ln.get('acinfo-interfframe-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-interfframe-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-interfplay'), a: 'contraption.interfaceanimplay', p: [
                    { t: 's', n: Global.ln.get('acinfo-interfplay-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-interfpause'), a: 'contraption.interfaceanimpause', p: [
                    { t: 's', n: Global.ln.get('acinfo-interfpause-p1'), v: '' }, 
                ], e: [ ] }, 
            ]
        ));

        // narrative
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbnarrative-title'), 
            [
                { n: Global.ln.get('acinfo-invshow'), a: 'inventory.show', p: [ ], e: [ 'complete' ] }, 
                { n: Global.ln.get('acinfo-invclose'), a: 'inventory.close', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-invaddkey'), a: 'inventory.addkeyitem', p: [
                    { t: 's', n: Global.ln.get('acinfo-invaddkey-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-invremkey'), a: 'inventory.removekeyitem', p: [
                    { t: 's', n: Global.ln.get('acinfo-invremkey-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-invclearkey'), a: 'inventory.clearkeyitems', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-invhaskey'), a: 'inventory.haskeyitem', p: [
                    { t: 's', n: Global.ln.get('acinfo-invhaskey-p1'), v: '' }, 
                ], e: [ 'then', 'else' ] },
                { n: Global.ln.get('acinfo-invaddcons'), a: 'inventory.addconsumable', p: [
                    { t: 's', n: Global.ln.get('acinfo-invaddcons-p1'), v: '' }, 
                    { t: 'i', n: Global.ln.get('acinfo-invaddcons-p2'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-invremcons'), a: 'inventory.removeconsumable', p: [
                    { t: 's', n: Global.ln.get('acinfo-invremcons-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-invconsume'), a: 'inventory.consumeitem', p: [
                    { t: 's', n: Global.ln.get('acinfo-invconsume-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-invclearcons'), a: 'inventory.clearconsumables', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-diagloadgroup'), a: 'dialogue.loadgroup', p: [
                    { t: 's', n: Global.ln.get('acinfo-diagloadgroup-p1'), v: '' }, 
                ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-diagstart'), a: 'dialogue.start', p: [
                    { t: 's', n: Global.ln.get('acinfo-diagstart-p1'), v: '' }, 
                ], e: [ ] }, 
                { n: Global.ln.get('acinfo-diagnext'), a: 'dialogue.next', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-diagprevious'), a: 'dialogue.previous', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-diaglast'), a: 'dialogue.last', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-diagfirst'), a: 'dialogue.first', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-diagclose'), a: 'dialogue.close', p: [ ], e: [ ] }, 
            ]
        ));

        // runtime
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbruntime-title'), 
            [
                { n: Global.ln.get('acinfo-runinstall'), a: 'runtime.install', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-runquit'), a: 'runtime.quit', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-runsavedata'), a: 'runtime.savedata', p: [
                    { t: 's', n: Global.ln.get('acinfo-runsavedata-p1'), v: '' }, 
                ], e: [ ] },
                { n: Global.ln.get('acinfo-runloaddata'), a: 'runtime.loaddata', p: [
                    { t: 's', n: Global.ln.get('acinfo-runloaddata-p1'), v: '' }, 
                ], e: [ 'success', 'error' ] },
                { n: Global.ln.get('acinfo-runifdataexist'), a: 'runtime.ifdataexist', p: [
                    { t: 's', n: Global.ln.get('acinfo-runifdataexist-p1'), v: '' }, 
                ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-runbrowser'), a: 'runtime.ifbrowser', p: [ ], e: [ 'then', 'else' ] }, 
                { n: Global.ln.get('acinfo-startkiosk'), a: 'runtime.startkiosk', p: [ ], e: [ ] }, 
                { n: Global.ln.get('acinfo-endkiosk'), a: 'runtime.endkiosk', p: [ ], e: [ ] }, 
            ]
        ));

        // server call plugin
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbserver-title'), 
            [
                { n: Global.ln.get('acinfo-callprocess'), a: 'call.process', p: [
                    { t: 's', n: Global.ln.get('acinfo-callprocess-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-callprocess-p2'), v: '' }, 
                ], e: [ 'success', 'error' ] }, 
                { n: Global.ln.get('acinfo-callsdprocess'), a: 'call.sdprocess', p: [
                    { t: 's', n: Global.ln.get('acinfo-callsdprocess-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-callsdprocess-p2'), v: '' }, 
                ], e: [ 'success', 'error' ] },  
                { n: Global.ln.get('acinfo-callurl'), a: 'call.url', p: [
                    { t: 's', n: Global.ln.get('acinfo-callurl-p1'), v: '' }, 
                    { t: 'e', n: Global.ln.get('acinfo-callurl-p2'), v: '' }, 
                ], e: [ 'success', 'error' ] },
            ]
        ));

        // debug plugin
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbdebug-title'), 
            [
                { n: Global.ln.get('acinfo-debugtrace'), a: 'trace', p: [
                    { t: 's', n: Global.ln.get('acinfo-debugtrace-p1'), v: '' }, 
                ], e: [ ] },  
                { n: Global.ln.get('acinfo-debugtracebools'), a: 'trace.bools', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-debugtraceints'), a: 'trace.ints', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-debugtracefloats'), a: 'trace.floats', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-debugtracestrings'), a: 'trace.strings', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-debuginfoshow'), a: 'debuginfo.show', p: [ ], e: [ ] },
                { n: Global.ln.get('acinfo-debuginfohide'), a: 'debuginfo.hide', p: [ ], e: [ ] },
            ]
        ));

        // google analytics plugin
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbanalytics-title'), 
            [
                { n: Global.ln.get('acinfo-analyticsevent'), a: 'analytics.event', p: [
                    { t: 's', n: Global.ln.get('acinfo-analyticsevent-p1'), v: '' }, 
                    { t: 's', n: Global.ln.get('acinfo-analyticsevent-p2'), v: '' }, 
                ], e: [ ] },  
            ]
        ));

        // share plugin
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acbshare-title'), 
            [
                { n: Global.ln.get('acinfo-sharefacebook'), a: 'share.facebook', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-sharelinkedin'), a: 'share.linkedin', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-sharepinterest'), a: 'share.pinterest', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-sharereddit'), a: 'share.reddit', p: [ ], e: [ ] },  
                { n: Global.ln.get('acinfo-sharex'), a: 'share.x', p: [ ], e: [ ] },  
            ]
        ));

        // overlay plugin
        this.groups.push(new ActionInfoGroup(
            Global.ln.get('window-acboverlay-title'), 
            [
                { n: Global.ln.get('acinfo-overlayshow'), a: 'overlay.show', p: [
                    { t: 's', n: Global.ln.get('acinfo-overlayshow-p1'), v: '' }, 
                    { t: 'e', n: Global.ln.get('acinfo-overlayshow-p2'), v: '' }, 
                    { t: 'b', n: Global.ln.get('acinfo-overlayshow-p3'), v: '' }, 
                    { t: 'e', n: Global.ln.get('acinfo-overlayshow-p4'), v: '' }, 
                ], e: [ 'success', 'error' ] }, 
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
                                } else if (gr.actions[ac].p[i].v == 'placement') {
                                    if (this._mnPlacement.exists(pr[i])) {
                                        ps.push(this._mnPlacement[pr[i]]);
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
                case 'placement':
                    if (this._mnPlacement.exists(val)) {
                        ret += this._mnPlacement[val];
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