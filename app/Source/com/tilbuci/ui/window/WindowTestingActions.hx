/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window;

/** OPENFL **/
import com.tilbuci.ui.component.ActionArea;
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.data.GlobalPlayer;
import openfl.events.Event;
import openfl.display.Stage;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;

class WindowTestingActions extends PopupWindow {

    private var _actions:ActionArea;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-tactions-title'), 800, InterfaceFactory.pickValue(520, 530), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this._actions = new ActionArea(760, 300);
        this.addForm(Global.ln.get('window-tactions-title'), this.ui.forge('window', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-tactions-about') }, 
            { tp: 'Custom', cont: this._actions }, 
            { tp: 'Spacer', id: 'action', ht: 10, ln: false }, 
            { tp: 'Label', id: 'delay', tx: Global.ln.get('window-tactions-delay'), 'vr': Label.VARIANT_DETAIL },
            { tp: 'Numeric', id: 'delay', vl: 0, mn: 0, mx: 10000, st: 250 },
            { tp: 'Spacer', id: 'delay', ht: 10, ln: false },  
            { tp: 'Button', id: 'okbutton', tx: Global.ln.get('window-tactions-button'), ac: this.onSet }
        ]));
        this.ui.labels['about'].wordWrap = true;
        super.startInterface();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        this._actions.setText(Global.testActions);
        this.ui.numerics['delay'].value = Global.testDelay;
    }

    /**
        Save testing actions.
    **/
    private function onSet(evt:TriggerEvent):Void {
        Global.testActions = this._actions.getText();
        Global.testDelay = Math.round(this.ui.numerics['delay'].value);
        PopUpManager.removePopUp(this);
    }

}