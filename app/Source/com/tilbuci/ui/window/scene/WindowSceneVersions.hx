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

class WindowSceneVersions extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-sceneversion-title'), 600, InterfaceFactory.pickValue(420, 430), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-sceneversion-title'), this.ui.forge('window', [
            { tp: 'Label', id: 'openabout', tx: Global.ln.get('window-sceneversion-wait') }, 
            { tp: 'List', id: 'openlist', vl: [ ], ht: 295, sl: null }, 
            { tp: 'Button', id: 'okbutton', tx: Global.ln.get('window-sceneversion-button'), ac: this.onOpen }
        ]));
        this.ui.setListToIcon('openlist');
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
        this.loadScenes();
    }

    /**
        Load the scenes list.
    **/
    public function loadScenes():Void {
        this.ui.labels['openabout'].text = Global.ln.get('window-sceneversion-wait');
        this.ui.setListValues('openlist', [ ]);
        Global.ws.send('Scene/ListVersions', [ 
            'movie' => GlobalPlayer.movie.mvId, 
            'id' => GlobalPlayer.movie.scId, 
            'format' => Global.ln.get('default-dateformat')
        ], this.onList);
    }

    /**
        The scenes list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.labels['openabout'].text = Global.ln.get('window-sceneversion-error');
        } else{
            if (ld.map['e'] == 0) {
                var ar:Array<Dynamic> = cast ld.map['list'];
                if (ar.length == 0) {
                    this.ui.labels['openabout'].text = Global.ln.get('window-sceneversion-noscenes');
                } else {
                    var items:Array<Dynamic> = [ ];
                    for (it in Reflect.fields(ld.map['list'])) {
                        if (Reflect.field(Reflect.field(ld.map['list'], it), 'pub') == '1') {
                            items.push({
                                text: Reflect.field(Reflect.field(ld.map['list'], it), 'date'), 
                                value: Reflect.field(Reflect.field(ld.map['list'], it), 'uid'), 
                                user: Reflect.field(Reflect.field(ld.map['list'], it), 'user'), 
                                asset: 'iconPublished'
                            });
                        } else {
                            items.push({
                                text: Reflect.field(Reflect.field(ld.map['list'], it), 'date'), 
                                value: Reflect.field(Reflect.field(ld.map['list'], it), 'uid'), 
                                user: Reflect.field(Reflect.field(ld.map['list'], it), 'user'), 
                                asset: ''
                            });
                        }
                    }
                    this.ui.setListValues('openlist', items);
                    this.ui.labels['openabout'].text = Global.ln.get('window-sceneversion-about');
                }
            } else {
                this.ui.labels['openabout'].text = Global.ln.get('window-sceneversion-error');
            }
        }
    }

    /**
        Opens the selected version.
    **/
    private function onOpen(evt:TriggerEvent):Void {
        if (this.ui.lists['openlist'].selectedItem != null) {
            this._ac('sceneversionload', ['id' => this.ui.lists['openlist'].selectedItem.value, 'movie' => GlobalPlayer.movie.mvId]);
            PopUpManager.removePopUp(this);
        }
    }

}