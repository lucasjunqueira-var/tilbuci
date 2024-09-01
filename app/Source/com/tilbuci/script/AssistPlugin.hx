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

class AssistPlugin extends AssistBase {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-plugin-title'), Global.ln.get('window-plugin-list'));
        this.setActions([
            'analytics.event' => { p: ['s', 's'], c: false, t: false, i: false, d:false, ic: 'icGoogle' }, 
            'call.sdprocess' => { p: ['s', 's'], c: false, t: false, i: false, d:true, ic: 'icServer' }, 
            'call.process' => { p: ['s', 's'], c: false, t: false, i: false, d:true, ic: 'icServer' }, 
            'call.url' => { p: ['s'], c: false, t: false, i: false, d:true, ic: 'icServer' }, 
            'debuginfo.hide' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icDebug' }, 
            'debuginfo.show' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icDebug' }, 
            'overlay.show' => { p: ['s', 's'], c: false, t: false, i: false, d:true, ic: 'icServer' }, 
            'share.facebook' => { p: ['b'], c: false, t: false, i: false, d:false, ic: 'icShare' }, 
            'share.linkedin' => { p: ['b'], c: false, t: false, i: false, d:false, ic: 'icShare' }, 
            'share.pinterest' => { p: ['b'], c: false, t: false, i: false, d:false, ic: 'icShare' }, 
            'share.reddit' => { p: ['b'], c: false, t: false, i: false, d:false, ic: 'icShare' }, 
            'share.x' => { p: ['b'], c: false, t: false, i: false, d:false, ic: 'icShare' }, 
            'trace' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icDebug' }, 
            'trace.bools' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icDebug' }, 
            'trace.ints' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icDebug' }, 
            'trace.floats' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icDebug' }, 
            'trace.strings' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icDebug' }, 
            'trace.vars' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icDebug' }, 
        ]);
    }


}