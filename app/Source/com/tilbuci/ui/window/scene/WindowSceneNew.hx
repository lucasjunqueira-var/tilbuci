/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.scene;

/** OPENFL **/
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

class WindowSceneNew extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-scenenew-title'), 800, 170, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-scenenew-title'), this.ui.forge('leftcol', [
            { tp: 'Label', id: 'scenename', tx: Global.ln.get('window-scenenew-name'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'scenename', tx: '', vr: '' },  
            { tp: 'Spacer', id: 'scenenew', ht: 20 },  
            { tp: 'Button', id: 'scenecreate', tx: Global.ln.get('window-scenenew-create'), ac: this.onCreateScene }
            
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
        Asks for a scene creation on server.
    **/
    private function onCreateScene(evt:TriggerEvent):Void {
        if (this.ui.inputs['scenename'].text == '') {
            this.ui.createWarning(Global.ln.get('window-scenenew-title'), Global.ln.get('window-scenenew-norequired'), 300, 180, this.stage);
        } else {
            Global.ws.send('Scene/New', [
                'title' => this.ui.inputs['scenename'].text, 
                'id' => '', //this.ui.inputs['sceneid'].text, 
                'movie' => GlobalPlayer.movie.mvId, 
            ], onCreateSceneReturn);
        }
    }

    /**
        Scene creation return.
    **/
    private function onCreateSceneReturn(ok:Bool, ld:DataLoader):Void {

trace ('create return', ok, ld.map);

        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-scenenew-title'), Global.ln.get('window-scenenew-createer'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-scenenew-title'), Global.ln.get('window-scenenew-createer'), 300, 180, this.stage);
        } else {
            GlobalPlayer.area.imgSelect();
            this.ui.inputs['scenename'].text = '';
            PopUpManager.removePopUp(this);
            this._ac('sceneload', [ 'id' => ld.map['id'] ]);
            Global.acInfo.loadInfo(true);
        }
    }

}