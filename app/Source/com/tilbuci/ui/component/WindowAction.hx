/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
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
import com.tilbuci.ui.component.ActionArea;
import com.tilbuci.ui.base.HInterfaceContainer;

class WindowAction extends PopupWindow {

    /**
        actions area
    **/
    private var _acarea:ActionArea;

    /**
        action to call on ok click
    **/
    private var _acok:Dynamic;

    /**
        action to call on cancel click
    **/
    private var _accancel:Dynamic;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic = null) {
        // creating window
        super(ac, Global.ln.get('window-actions-title'), 980, 530, false, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {

        // action area
        this._acarea = new ActionArea(956, 446);

        // buttons
        var btContainer:HInterfaceContainer = this.ui.createHContainer('buttons');
        this.ui.createButton('btcancel', Global.ln.get('window-actions-cancel'), onCancel, btContainer, false);
        this.ui.createButton('btok', Global.ln.get('window-actions-ok'), onOk, btContainer, false);
        btContainer.setWidth(956);

        // creating interface
        this.addForm(Global.ln.get('window-actions-title'), this.ui.forge('ac', [
            { tp: 'Custom', cont: this._acarea }, 
            { tp: 'Custom', cont: btContainer }
        ], -1, 450));
        super.startInterface();
    }

    /**
        Sets current content.
        @param  text    initial aciton text
        @param  onOk    action to call on ok button click (must receive a single String parameter)
        @param  onCancel    action to call on cancel button click
    **/
    public function setContent(text:String, onOk:Dynamic, onCancel:Dynamic = null):Void {
        this._acarea.setText(text);
        this._acok = onOk;
        this._accancel = onCancel;
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Cancel action input.
    **/
    private function onCancel(evt:TriggerEvent):Void {
        if (this._accancel != null) this._accancel();
        this._acok = this._accancel = null;
        this.closeWindow(null);
    }

    /**
        Confirm action input.
    **/
    private function onOk(evt:TriggerEvent):Void {
        // current text is a valid json?
        var json = StringStatic.jsonParse(this._acarea.getText());
        if ((this._acarea.getText() != '') && (json == false)) {
            Global.showPopup(Global.ln.get('window-actions-title'), Global.ln.get('window-actions-error'), 300, 180, Global.ln.get('default-ok'));
        } else {
            if (this._acok != null) this._acok(this._acarea.getText());
            this._acok = this._accancel = null;
            this.closeWindow(null);
        }
    }

}