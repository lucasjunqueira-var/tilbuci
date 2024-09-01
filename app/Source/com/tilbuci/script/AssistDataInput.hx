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

class AssistDataInput extends AssistBase {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-acdata-title'), Global.ln.get('window-acdata-list'));
        this.setActions([
            'data.event' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icData' }, 
            'data.liststates' => { p: [ ], c: false, t: false, i: false, d:true, ic: 'icData' }, 
            'data.load' => { p: ['s'], c: false, t: false, i: false, d:true, ic: 'icData' }, 
            'data.loadlocal' => { p: ['s'], c: false, t: false, i: false, d:true, ic: 'icData' }, 
            'data.loadquickstate' => { p: ['s'], c: false, t: false, i: false, d:true, ic: 'icData' }, 
            'data.loadstatelocal' => { p: [ ], c: false, t: false, i: false, d:true, ic: 'icData' }, 
            'data.save' => { p: ['s', 's'], c: false, t: false, i: false, d:true, ic: 'icData' }, 
            'data.savelocal' => { p: ['s', 's'], c: false, t: false, i: false, d:true, ic: 'icData' }, 
            'data.savequickstate' => { p: ['s'], c: false, t: false, i: false, d:true, ic: 'icData' }, 
            'data.savestate' => { p: ['s'], c: false, t: false, i: false, d:true, ic: 'icData' }, 
            'data.savestatelocal' => { p: [ ], c: false, t: false, i: false, d:true, ic: 'icData' }, 
            'input.email' => { p: ['s', 's'], c: false, t: false, i: true, d:false, ic: 'icInput' }, 
            'input.float' => { p: ['s', 's', 'f', 'f', 'f'], c: false, t: false, i: true, d:false, ic: 'icInput' }, 
            'input.int' => { p: ['s', 's', 'i', 'i', 'i'], c: false, t: false, i: true, d:false, ic: 'icInput' }, 
            'input.list' => { p: ['s', 's', 's', 's'], c: false, t: false, i: true, d:false, ic: 'icInput' }, 
            'input.login' => { p: [ ], c: false, t: false, i: true, d:false, ic: 'icInput' }, 
            'input.message' => { p: ['s', 's'], c: false, t: false, i: true, d:false, ic: 'icInput' }, 
            'input.string' => { p: ['s', 's'], c: false, t: false, i: true, d:false, ic: 'icInput' }, 
        ]);
    }


}