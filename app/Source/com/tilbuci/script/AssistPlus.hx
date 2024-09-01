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

class AssistPlus extends AssistBase {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-acplus-title'), Global.ln.get('window-acplus-list'));
        this.setActions([
            'replace.clearfile' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.clearstring' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.clearallfiles' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.clearallstrings' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.origin' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.setfile' => { p: ['s', 's'], c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.setstring' => { p: ['s', 's'], c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'run' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icSnippets' }, 
            'system.copytext' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.fullscreen' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.logout' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.openembed' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.openurl' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.quit' => { p: [], c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.sendevent' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'css.clear' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icText' }, 
            'css.set' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icText' }, 
            'timer.clear' => { p: ['s'], c: false, t: false, i: false, d:false, ic: 'icTimer' }, 
            'timer.clearall' => { p: [ ], c: false, t: false, i: false, d:false, ic: 'icTimer' }, 
            'timer.set' => { p: ['s', 'i', 'i'], c: false, t: true, i: false, d:false, ic: 'icTimer' }, 
        ]);
    }


}