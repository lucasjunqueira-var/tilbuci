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

class AssistNarrative extends AssistBase {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-narrative-title'), Global.ln.get('window-narrative-list'));
        this.setActions([
            'dialogue.loadgroup' => { p: ['s'], s:false, c: false, t: false, i: false, d:true, ic: 'icNarrative' }, 
            'dialogue.start' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icNarrative' }, 
            'dialogue.next' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icNarrative' }, 
            'dialogue.previous' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icNarrative' }, 
            'dialogue.last' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icNarrative' }, 
            'dialogue.first' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icNarrative' }, 
            'dialogue.close' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icNarrative' }, 
        ]);
    }


}