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
            'int.abs' => { p: ['s', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.clear' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.clearall' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.divide' => { p: ['s', 'i', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.max' => { p: ['s', 'i', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.min' => { p: ['s', 'i', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.multiply' => { p: ['s', 'i', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.random' => { p: ['s', 'i', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.set' => { p: ['s', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.subtract' => { p: ['s', 'i', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.sum' => { p: ['s', 'i', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.tofloat' => { p: ['s', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' }, 
            'int.tostring' => { p: ['s', 'i'], c: false, t: false, i: false, d:false, ic: 'btInteger' },
            'bool.clear' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'btBool' }, 
            'bool.clearall' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'btBool' }, 
            'bool.set' => { p: ['s', 'b'], c: false, t: false, i: false, d:false, ic: 'btBool' }, 
            'bool.setinverse' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'btBool' }, 
            'float.abs' => { p: ['s', 'b'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.clear' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.clearall' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.divide' => { p: ['s', 'f', 'f'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.max' => { p: ['s', 'f', 'f'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.min' => { p: ['s', 'f', 'f'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.multiply' => { p: ['s', 'f', 'f'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.random' => { p: ['s', 'f', 'f'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.set' => { p: ['s', 'f'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.subtract' => { p: ['s', 'f', 'f'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.sum' => { p: ['s', 'f', 'f'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.toint' => { p: ['s', 'f'], c: false, t: false, i: false, d:false, ic: 'btFloat' }, 
            'float.tostring' => { p: ['s', 'f'], c: false, t: false, i: false, d:false, ic: 'btFloat' },  
            'string.clear' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.clearall' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.clearglobal' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.concat' => { p: ['s', 's', 's'], c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.replace' => { p: ['s', 's', 's', 's'], c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.set' => { p: ['s', 's'], c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.setglobal' => { p: ['s', 's'], c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.setgroup' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'btString' }, 
            'string.tofloat' => { p: ['s', 's'], c: false, t: false, i: false, d:false, ic: 'btString' },
            'string.toint' => { p: ['s', 's'], c: false, t: false, i: false, d:false, ic: 'btString' }, 

            'if.intsdifferent' => { p: ['i', 'i'], c: true, t: false, i: false, d:false, ic: 'btInteger' }, 
            'if.intsequal' => { p: ['i', 'i'], c: true, t: false, i: false, d:false, ic: 'btInteger' }, 
            'if.intgreater' => { p: ['i', 'i'], c: true, t: false, i: false, d:false, ic: 'btInteger' }, 
            'if.intgreaterequal' => { p: ['i', 'i'], c: true, t: false, i: false, d:false, ic: 'btInteger' }, 
            'if.intlower' => { p: ['i', 'i'], c: true, t: false, i: false, d:false, ic: 'btInteger' }, 
            'if.intlowerequal' => { p: ['i', 'i'], c: true, t: false, i: false, d:false, ic: 'btInteger' },
            'if.bool' => { p: ['s'], c: true, t: false, i: false, d:false, ic: 'btBool' }, 
            'if.floatsdifferent' => { p: ['f', 'f'], c: true, t: false, i: false, d:false, ic: 'btFloat' }, 
            'if.floatsequal' => { p: ['f', 'f'], c: true, t: false, i: false, d:false, ic: 'btFloat' }, 
            'if.floatgreater' => { p: ['f', 'f'], c: true, t: false, i: false, d:false, ic: 'btFloat' }, 
            'if.floatgreaterequal' => { p: ['f', 'f'], c: true, t: false, i: false, d:false, ic: 'btFloat' }, 
            'if.floatlower' => { p: ['f', 'f'], c: true, t: false, i: false, d:false, ic: 'btFloat' }, 
            'if.floatlowerequal' => { p: ['f', 'f'], c: true, t: false, i: false, d:false, ic: 'btFloat' },  
            'if.stringcontains' => { p: ['s', 's'], c: true, t: false, i: false, d:false, ic: 'btString' }, 
            'if.stringendswith' => { p: ['s', 's'], c: true, t: false, i: false, d:false, ic: 'btString' }, 
            'if.stringsdifferent' => { p: ['s', 's'], c: true, t: false, i: false, d:false, ic: 'btString' }, 
            'if.stringsequal' => { p: ['s', 's'], c: true, t: false, i: false, d:false, ic: 'btString' }, 
            'if.stringstartswith' => { p: ['s', 's'], c: true, t: false, i: false, d:false, ic: 'btString' }, 
            'if.stringemail' => { p: ['s'], c: true, t: false, i: false, d:false, ic: 'btString' }, 
        ]);
    }


}