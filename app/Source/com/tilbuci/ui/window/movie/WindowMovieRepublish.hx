/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.movie;

/** OPENFL **/
import com.tilbuci.ui.component.IDButton;
import com.tilbuci.ui.base.HInterfaceContainer;
import openfl.events.Event;
import openfl.display.Stage;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;

class WindowMovieRepublish extends PopupWindow {

    /**
        current sequence
    **/
    private var _sequence:Array<Dynamic> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-republish-title'), 800, 200, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.addForm('intr', this.ui.forge('interface', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-republish-about'), vr: '' }, 
            { tp: 'Select', id: 'version', vl: [
                { text: Global.ln.get('window-republish-current'), value: 'current' }, 
                { text: Global.ln.get('window-republish-newest'), value: 'newest' }, 
            ], sl: 'current' }, 
            { tp: 'Spacer', id: 'rep', ht: 20, ln: false }, 
            { tp: 'Button', id: 'rep', tx: Global.ln.get('window-republish-button'), ac: this.onRepublish }
        ]));
        this.ui.labels['about'].wordWrap = true;
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
        this.ui.setSelectValue('version', 'current');
    }

    /**
        Creates the sequence.
    **/
    private function onRepublish(evt:TriggerEvent):Void {
        var newest:String = 'false';
        if (this.ui.selects['version'].selectedItem.value == 'newest') newest = 'true';
        Global.ws.send('Movie/Republish', [
            'movie' => GlobalPlayer.movie.mvId, 
            'newest' => newest, 
        ], this.onReturn);
    }

    /**
        Return from republishing.
    **/
    private function onReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-republish-title'), Global.ln.get('window-republish-error'), 420, 150, this.stage);
        } else {
            if (ld.map['e'] == 0) {
                this.ui.createWarning(Global.ln.get('window-republish-title'), Global.ln.get('window-republish-ok'), 420, 150, this.stage);
            } else {
                this.ui.createWarning(Global.ln.get('window-republish-title'), Global.ln.get('window-republish-error'), 420, 150, this.stage);
            }
        }
    }

}