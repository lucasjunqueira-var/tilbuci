/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.script;

/** OPENFL **/
import openfl.events.Event;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.component.IDButton;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.DataLoader;

class AssistVariables extends AssistBase {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-acvariable-title'), Global.ln.get('window-acvariable-list'));
        this.setActions([
            'int.abs' => { p: ['s', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.clear' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.clearall' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.divide' => { p: ['s', 'i', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.max' => { p: ['s', 'i', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.min' => { p: ['s', 'i', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.multiply' => { p: ['s', 'i', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.random' => { p: ['s', 'i', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.set' => { p: ['s', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.subtract' => { p: ['s', 'i', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.sum' => { p: ['s', 'i', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.tofloat' => { p: ['s', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.tostring' => { p: ['s', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'btInteger' },
            'bool.clear' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'btBool' }, 
            'bool.clearall' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'btBool' }, 
            'bool.set' => { p: ['s', 'b'], s:false, c: false, t: false, i: false, d:false, ic: 'btBool' }, 
            'bool.setinverse' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'btBool' }, 
            'float.abs' => { p: ['s', 'b'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.clear' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.clearall' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.divide' => { p: ['s', 'f', 'f'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.max' => { p: ['s', 'f', 'f'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.min' => { p: ['s', 'f', 'f'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.multiply' => { p: ['s', 'f', 'f'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.random' => { p: ['s', 'f', 'f'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.set' => { p: ['s', 'f'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.subtract' => { p: ['s', 'f', 'f'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.sum' => { p: ['s', 'f', 'f'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.toint' => { p: ['s', 'f'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.tostring' => { p: ['s', 'f'], s:false, c: false, t: false, i: false, d:false, ic: 'btFloat' },  
            'string.clear' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.clearall' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.clearglobal' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.concat' => { p: ['s', 's', 's'], s:false, c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.replace' => { p: ['s', 's', 's', 's'], s:false, c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.set' => { p: ['s', 's'], s:false, c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.setglobal' => { p: ['s', 's'], s:false, c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.setgroup' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.loadfile' => { p: ['s'], s:false, c: false, t: false, i: false, d:true, ic: 'btString' }, 
            'string.tofloat' => { p: ['s', 's'], s:false, c: false, t: false, i: false, d:false, ic: 'btString' },
            'string.toint' => { p: ['s', 's'], s:false, c: false, t: false, i: false, d:false, ic: 'btString' }, 

            'if.intsdifferent' => { p: ['i', 'i'], s:false, c: true, t: false, i: false, d:false, ic: 'btInteger' }, 
            'if.intsequal' => { p: ['i', 'i'], s:false, c: true, t: false, i: false, d:false, ic: 'btInteger' }, 
            'if.intgreater' => { p: ['i', 'i'], s:false, c: true, t: false, i: false, d:false, ic: 'btInteger' }, 
            'if.intgreaterequal' => { p: ['i', 'i'], s:false, c: true, t: false, i: false, d:false, ic: 'btInteger' }, 
            'if.intlower' => { p: ['i', 'i'], s:false, c: true, t: false, i: false, d:false, ic: 'btInteger' }, 
            'if.intlowerequal' => { p: ['i', 'i'], s:false, c: true, t: false, i: false, d:false, ic: 'btInteger' },
            'if.bool' => { p: ['s'], s:false, c: true, t: false, i: false, d:false, ic: 'btBool' }, 
            'if.floatsdifferent' => { p: ['f', 'f'], s:false, c: true, t: false, i: false, d:false, ic: 'btFloat' }, 
            'if.floatsequal' => { p: ['f', 'f'], s:false, c: true, t: false, i: false, d:false, ic: 'btFloat' }, 
            'if.floatgreater' => { p: ['f', 'f'], s:false, c: true, t: false, i: false, d:false, ic: 'btFloat' }, 
            'if.floatgreaterequal' => { p: ['f', 'f'], s:false, c: true, t: false, i: false, d:false, ic: 'btFloat' }, 
            'if.floatlower' => { p: ['f', 'f'], s:false, c: true, t: false, i: false, d:false, ic: 'btFloat' }, 
            'if.floatlowerequal' => { p: ['f', 'f'], s:false, c: true, t: false, i: false, d:false, ic: 'btFloat' },  
            'if.stringcontains' => { p: ['s', 's'], s:false, c: true, t: false, i: false, d:false, ic: 'btString' }, 
            'if.stringendswith' => { p: ['s', 's'], s:false, c: true, t: false, i: false, d:false, ic: 'btString' }, 
            'if.stringsdifferent' => { p: ['s', 's'], s:false, c: true, t: false, i: false, d:false, ic: 'btString' }, 
            'if.stringsequal' => { p: ['s', 's'], s:false, c: true, t: false, i: false, d:false, ic: 'btString' }, 
            'if.stringstartswith' => { p: ['s', 's'], s:false, c: true, t: false, i: false, d:false, ic: 'btString' }, 
            'if.stringemail' => { p: ['s'], s:false, c: true, t: false, i: false, d:false, ic: 'btString' }, 
        ]);
    }


}