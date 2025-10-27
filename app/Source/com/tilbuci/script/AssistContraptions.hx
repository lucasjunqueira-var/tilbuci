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
            'contraption.message' => { p: ['s', 's', 's', 's'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.messagehide' => { p: [ ], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
            'contraption.menu' => { p: ['s', 's', 's', 's', 'i', 'i'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.menuhide' => { p: [ ], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
            'contraption.cover' => { p: ['s'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.coverhide' => { p: [ ], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
            'contraption.background' => { p: ['s'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.backgroundhide' => { p: [ ], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
            'contraption.showloading' => { p: [ ], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
            'contraption.hideloading' => { p: [ ], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
            'contraption.musicplay' => { p: ['s'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.musicpause' => { p: [ ], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
            'contraption.musicstop' => { p: [ ], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
            'contraption.musicvolume' => { p: ['i'], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
            'contraption.form' => { p: ['s', 'i', 'i'], c: false, t: false, i: true, d:false, s: true, ic: 'icContraption' }, 
            'contraption.formvalue' => { p: ['s', 's'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.formsetstepper' => { p: ['s', 'i', 'i', 'i'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.formhide' => { p: [ ], c: false, t: false, i: false, d:false, s:false, ic: 'icContraption' },
            'contraption.interface' => { p: ['s', 'i', 'i'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.interfacehide' => { p: ['s'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.interfacehideall' => { p: [ ], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.interfacetext' => { p: ['s', 's'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.interfaceanimframe' => { p: ['s', 'i'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.interfaceanimplay' => { p: ['s'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
            'contraption.interfaceanimpause' => { p: ['s'], c: false, t: false, i: false, d:false, s: true, ic: 'icContraption' }, 
        ]);
    }


}