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

class AssistRuntime extends AssistBase {

    /**
        Constructor.
        @param  ac  the menu action method
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-runtime-title'), Global.ln.get('window-runtime-list'));
        this.setActions([
            'runtime.install' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'runtime.quit' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'runtime.savedata' => { p: [ 's' ], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'runtime.loaddata' => { p: [ 's' ], s:false, c: false, t: false, i: false, d:true, ic: 'icSystem' }, 

            'runtime.ifdataexist' => { p: [ 's' ], s:false, c: true, t: false, i: false, d:false, ic: 'icSystem' }, 
            'runtime.ifbrowser' => { p: [ ], s:false, c: true, t: false, i: false, d:false, ic: 'icSystem' }, 
        ]);
    }


}