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

class AssistPlus extends AssistBase {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-acplus-title'), Global.ln.get('window-acplus-list'));
        this.setActions([
            'replace.clearfile' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.clearstring' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.clearallfiles' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.clearallstrings' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.origin' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.setfile' => { p: ['s', 's'], s:false, c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'replace.setstring' => { p: ['s', 's'], s:false, c: false, t: false, i: false, d:false, ic: 'icReplace' }, 
            'run' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icSnippets' }, 
            'system.copytext' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.fullscreen' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.visitoringroup' => { p: [ 's' ], s:false, c: true, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.logout' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.openembed' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.closeembed' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.embedplace' => { p: ['i', 'i', 'i', 'i'], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.embedreset' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.openurl' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.quit' => { p: [], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.sendevent' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'system.setkftime' => { p: ['i'], s:false, c: false, t: false, i: false, d:false, ic: 'icSystem' }, 
            'css.clear' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icText' }, 
            'css.set' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icText' }, 
            'timer.clear' => { p: ['s'], s:false, c: false, t: false, i: false, d:false, ic: 'icTimer' }, 
            'timer.clearall' => { p: [ ], s:false, c: false, t: false, i: false, d:false, ic: 'icTimer' }, 
            'timer.set' => { p: ['s', 'i', 'i'], s:false, c: false, t: true, i: false, d:false, ic: 'icTimer' }, 
        ]);
    }


}