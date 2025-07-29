/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.movie;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
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
import com.tilbuci.data.GlobalPlayer;

class WindowMovieRemove extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-movieremove-title'), 700, InterfaceFactory.pickValue(380, 400), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.addForm('list', this.ui.forge('list', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-movieremove-about'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'List', id: 'list', vl: [ ], ht:250, sl: '' },  
            { tp: 'Button', id: 'remove', tx: Global.ln.get('window-movieremove-button'), ac: this.onRemove }, 
        ]));
        super.startInterface();
        this.ui.labels['about'].wordWrap = true;
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
        Global.ws.send('Movie/List', [ 'owner' => 'true' ], this.onList);
    }

    /**
        The collaborators list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        this.ui.setListSelectValue('list', null);
        this.ui.setListValues('list', [ ]);
        if (ok) {
            if (ld.map['e'] == 0) {
                var ar:Array<Dynamic> = [ ] ;
                for (mvit in Reflect.fields(ld.map['list'])) {
                    var mv:Dynamic = Reflect.field(ld.map['list'], mvit);
                    ar.push({
                        text: Reflect.field(mv, 'title'), 
                        value: Reflect.field(mv, 'id')
                    });
                }
                this.ui.setListValues('list', ar);
            }
        }
    }

    /**
        Confirm movie removal.
    **/
    private function onRemove(evt:TriggerEvent):Void {
        if (this.ui.lists['list'].selectedItem != null) {
            this.ui.createConfirm(
                Global.ln.get('window-movieremove-title'),
                Global.ln.get('window-movieremove-confirm'),
                480,
                240,
                onConfirm, 
                Global.ln.get('default-ok'), 
                Global.ln.get('default-cancel'),
                this.stage
            );
        }
    }

    /**
        Movie removal confirmation.
    **/
    private function onConfirm(ok:Bool):Void {
        if (ok) {
            if (this.ui.lists['list'].selectedItem != null) {
                Global.ws.send('Movie/Remove', [ 'id' => this.ui.lists['list'].selectedItem.value ], this.onList);
            }
        }
    }

}