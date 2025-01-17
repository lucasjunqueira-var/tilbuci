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

class AssistContraptions extends AssistBase {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-contraptions-title'), Global.ln.get('window-contraptions-list'));
        this.setActions([
            'contraption.menu' => { p: ['s', 's', 's', 's', 'i', 'i'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.menuhide' => { p: [ ], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
        ]);
    }


}