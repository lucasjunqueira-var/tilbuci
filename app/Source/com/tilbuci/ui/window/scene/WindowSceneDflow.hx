/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.scene;

/** OPENFL **/
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

class WindowSceneDflow extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-scenedflow-title'), 600, InterfaceFactory.pickValue(475, 485), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        for (i in 1...5) {
            this.ui.createHContainer('dflowt'+i);
            this.ui.createLabel(('dflowt'+i), Global.ln.get('window-scenedflow-choicetext'), Label.VARIANT_DETAIL, this.ui.hcontainers['dflowt'+i]);
            this.ui.createTInput(('dflowt'+i), '', '', this.ui.hcontainers['dflowt'+i]);
            this.ui.createHContainer('dflows'+i);
            this.ui.createLabel(('dflows'+i), Global.ln.get('window-scenedflow-choicescene'), Label.VARIANT_DETAIL, this.ui.hcontainers['dflows'+i]);
            this.ui.createSelect(('dflows'+i), [], null, this.ui.hcontainers['dflows'+i]);
        }

        this.addForm(Global.ln.get('window-scenedflow-title'), this.ui.forge('window', [
            { tp: 'Label', id: 'choice1', tx: Global.ln.get('window-scenedflow-choice1') }, 
            { tp: 'Custom', cont: this.ui.hcontainers['dflowt1'] }, 
            { tp: 'Custom', cont: this.ui.hcontainers['dflows1'] }, 
            { tp: 'Spacer', id: 'choice1', ht: 10, ln: true }, 

            { tp: 'Label', id: 'choice2', tx: Global.ln.get('window-scenedflow-choice2') }, 
            { tp: 'Custom', cont: this.ui.hcontainers['dflowt2'] }, 
            { tp: 'Custom', cont: this.ui.hcontainers['dflows2'] }, 
            { tp: 'Spacer', id: 'choice2', ht: 10, ln: true }, 

            { tp: 'Label', id: 'choice3', tx: Global.ln.get('window-scenedflow-choice3') }, 
            { tp: 'Custom', cont: this.ui.hcontainers['dflowt3'] }, 
            { tp: 'Custom', cont: this.ui.hcontainers['dflows3'] }, 
            { tp: 'Spacer', id: 'choice3', ht: 10, ln: true }, 

            { tp: 'Label', id: 'choice4', tx: Global.ln.get('window-scenedflow-choice4') }, 
            { tp: 'Custom', cont: this.ui.hcontainers['dflowt4'] }, 
            { tp: 'Custom', cont: this.ui.hcontainers['dflows4'] },
            { tp: 'Spacer', id: 'choice4', ht: 10, ln: false }, 

            { tp: 'Button', id: 'okbutton', tx: Global.ln.get('window-scenedflow-set'), ac: this.onSave }
        ]));
        super.startInterface();
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        for (i in 1...5) {
            this.ui.hcontainers['dflowt'+i].setWidth(560, [180, 370]);
            this.ui.hcontainers['dflows'+i].setWidth(560, [180, 370]);
        }
        Global.ws.send('Scene/List', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
    }

    /**
        The scenes list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-scenedflow-title'), Global.ln.get('window-scenedflow-nolist'), 300, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else{
            if (ld.map['e'] == 0) {
                // scenes list
                var sclist:Array<Dynamic> = [ { text: Global.ln.get('window-scenedflow-none'), value: '' } ];
                var ar:Array<Dynamic> = cast ld.map['list'];
                if (ar.length > 0) {
                    for (i in ar) sclist.push({ text: Reflect.field(i, 'title'), value: Reflect.field(i, 'id') });
                }
                for (i in 1...5) {
                    this.ui.inputs['dflowt'+i].text = GlobalPlayer.movie.scene.dflow[i-1][0];
                    this.ui.setSelectOptions(('dflows'+i), sclist, GlobalPlayer.movie.scene.dflow[i-1][1]);    
                }
            } else {
                this.ui.createWarning(Global.ln.get('window-scenedflow-title'), Global.ln.get('window-scenedflow-nolist'), 300, 180, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Saves current information.
    **/
    private function onSave(evt:TriggerEvent):Void {
        var dflow = [ [ '', '', ], [ '', '', ], [ '', '', ], [ '', '', ] ];
        for (i in 1...5) {
            if (this.ui.selects['dflows'+i].selectedItem.value != '') {
                if (this.ui.inputs['dflowt'+i].text == '') {
                    this.ui.inputs['dflowt'+i].text = this.ui.selects['dflows'+i].selectedItem.text;
                }
                dflow[i-1] = [
                    this.ui.inputs['dflowt'+i].text, 
                    this.ui.selects['dflows'+i].selectedItem.value
                ];
            }
        }
        while (GlobalPlayer.movie.scene.dflow.length > 0) GlobalPlayer.movie.scene.dflow.shift();
        GlobalPlayer.movie.scene.dflow = dflow;
        Global.showMsg(Global.ln.get('window-scenedflow-sceneset'));
        PopUpManager.removePopUp(this);
    }

}