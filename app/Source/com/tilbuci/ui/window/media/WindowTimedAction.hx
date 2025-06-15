/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.media;

/** OPENFL **/
import haxe.ds.ArraySort;
import com.tilbuci.ui.base.InterfaceContainer;
import com.tilbuci.def.AssetData;
import com.tilbuci.def.CollectionData;
import com.tilbuci.display.InstanceImage;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.contraptions.MenuContraption;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.display.Stage;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.ui.component.ActionArea;

class WindowTimedAction extends PopupWindow {

    private var _instance:InstanceImage;

    private var _acarea:ActionArea;

    private var _list:Array<Dynamic> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-timedac-title'), 1300, 690, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this._acarea = new ActionArea(610, 520);
        this.addForm('columns', this.ui.createColumnHolder('columns',
            this.ui.forge('left', [
                { tp: 'Label', id: 'registered', tx: Global.ln.get('window-timedac-registered'), vr: '' }, 
                { tp: 'List', id: 'registered', vl: [ ], ht: 325, sl: null }, 
                { tp: 'Button', id: 'loadac', tx:  Global.ln.get('window-timedac-loadac'), ac: onLoad},
                { tp: 'Button', id: 'clearac', tx:  Global.ln.get('window-timedac-clearac'), ac: onClear},
                { tp: 'Spacer',  id: 'newtime', ht: 10, ln: false }, 
                { tp: 'Label', id: 'newtime', tx: Global.ln.get('window-timedac-newtime'), vr: '' },
                { tp: 'Numeric', id: 'newtime', mn: 1, mx: 10000, st: 1, vl: 1 }, 
                { tp: 'Button', id: 'newtime', tx:  Global.ln.get('window-timedac-newtimebt'), ac: onNew},
                { tp: 'Spacer',  id: 'buttons', ht: 10, ln: false }, 
                { tp: 'Button', id: 'onclose', tx:  Global.ln.get('window-timedac-close'), ac: onClose},
                { tp: 'Button', id: 'onsave', tx:  Global.ln.get('window-timedac-set'), ac: onSave},
            ]), 
            this.ui.forge('right', [
                { tp: 'Label', id: 'actions', tx: Global.ln.get('window-timedac-actions'), vr: '' }, 
                { tp: 'Custom', cont: this._acarea },
                { tp: 'Spacer',  id: 'actions', ht: 6, ln: false }, 
                { tp: 'Button', id: 'onupdate', tx:  Global.ln.get('window-timedac-update'), ac: onUpdate}, 
            ])
        ));
        this.ui.listDbClick('registered', onLoad);
        super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        this._instance = null;
    }

    /**
        Window custom actions (to override).
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        this._instance = GlobalPlayer.area.pickInstance(data['instance']);
        if (this._instance != null) {
            this._list = [ ];
            var timedAc:Map<String, String> = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._instance.getInstName()].timedAc;
            for (k in timedAc.keys()) {
                if (timedAc[k] != '') {
                    this._list.push({
                        text: k, 
                        value: {
                            time: Std.parseInt(StringTools.replace(k, 's', '')), 
                            action: timedAc[k]
                        }
                    }); 
                }
            }
            this.orderActions();
        } else {
            Global.showMsg(Global.ln.get('window-asset-noinstance'));
            PopUpManager.removePopUp(this);
        }
    }

    private function onSave(evt:Event = null):Void {
        var timedAc:Map<String, String> = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._instance.getInstName()].timedAc;
        for (k in timedAc.keys()) timedAc.remove(k);
        for (i in 0...this._list.length) {
            if (this._list[i].value.action != '') {
                timedAc[this._list[i].value.time + 's'] = this._list[i].value.action;
            }
        }
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._instance.getInstName()].timedAc = timedAc;
        this._instance = null;
        PopUpManager.removePopUp(this);
    }

    private function onClose(evt:Event = null):Void {
        this._instance = null;
        PopUpManager.removePopUp(this);
    }

    private function onNew(evt:Event = null):Void {
        if (this.ui.numerics['newtime'].value > 0) {
            var time:Int = Math.round(this.ui.numerics['newtime'].value);
            var found:Int = -1;
            for (i in 0...this._list.length) {
                if (this._list[i].value.time == time) {
                    found = i;
                }
            }
            if (found >= 0) {
                this.ui.lists['registered'].selectedIndex = found;
                this.ui.lists['registered'].dataProvider.updateAt(this.ui.lists['registered'].selectedIndex);
                this.onLoad();
            } else {
                this._list.push({
                    text: (time + 's'), 
                    value: {
                        time: time, 
                        action: ''
                    }
                });
                this.orderActions(time);
            }
        }
    }

    private function orderActions(current:Int = 0):Void {
        this._acarea.setText('');
        this.ui.setListSelectValue('registered', null);
        this.ui.setListValues('registered', [ ]);
        ArraySort.sort(this._list, function(a, b){
            if (a.value.time < b.value.time) {
                return (-1);
            } else if (a.value.time > b.value.time) {
                return (1);
            } else {
                return (0);
            }
        });
        this.ui.setListValues('registered', this._list);
        if (current > 0) {
            var found:Int = -1;
            for (i in 0...this._list.length) {
                if (this._list[i].value.time == current) {
                    found = i;
                }
            }
            if (found >= 0) {
                this.ui.lists['registered'].selectedIndex = found;
                this.ui.lists['registered'].dataProvider.updateAt(this.ui.lists['registered'].selectedIndex);
                this.onLoad();
            }
        }
    }

    private function onLoad(evt:Event = null):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            this._acarea.setText(this.ui.lists['registered'].selectedItem.value.action);
        }
    }

    private function onClear(evt:Event = null):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            var time:Int = this.ui.lists['registered'].selectedItem.value.time;
            var newlist:Array<Dynamic> = [ ];
            for (i in 0...this._list.length) {
                if (this._list[i].value.time != time) newlist.push(this._list[i]);
            }
            this._list = newlist;
            this.orderActions();
        }
    }

    private function onUpdate(evt:Event = null):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            var time:Int = this.ui.lists['registered'].selectedItem.value.time;
            for (i in 0...this._list.length) {
                if (this._list[i].value.time == time) this._list[i].value.action = this._acarea.getText();
            }
            this.orderActions();
        }
    }

}