/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;

import com.tilbuci.statictools.StringStatic;
import com.tilbuci.ui.base.ConfirmWindow;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import com.tilbuci.data.GlobalPlayer;
import feathers.layout.AnchorLayoutData;
import feathers.controls.ListView;
import feathers.data.ArrayCollection;
import com.tilbuci.data.Global;
import openfl.events.Event;

class InstancesPanel extends DropDownPanel {

    public function new(wd:Float) {
        super(Global.ln.get('rightbar-instances'), wd);

        this._content = this.ui.forge('instancepan', [
            { tp: 'List', id: 'ilist', ht: 150, vl: [ ], sl: null, ch: onChange}, 
            { tp: 'Button', id: 'none', tx: Global.ln.get('rightbar-instances-none'), ac: onNone}, 
            { tp: 'Button', id: 'randbt', tx: Global.ln.get('rightbar-instances-rand'), ac: onRand}
        ], 0x333333, (wd - 5));
        this.ui.lists['ilist'].layoutData = AnchorLayoutData.fill();
        this.ui.lists['ilist'].itemToText = (item:Dynamic) -> {
			return item.text;
		};
    }

    private function onNone(evt:TriggerEvent):Void {
        GlobalPlayer.area.imgSelect();
        this.reloadContent();
        for (cb in this.callbacks) cb([ 'nm' => '' ]);
    }

    private function onRand(evt:TriggerEvent):Void {
        if (this.ui.lists['ilist'].dataProvider.length > 0) {
            Global.showPopup(Global.ln.get('rightbar-instances'), Global.ln.get('rightbar-instances-randcheck'), 340, 205, Global.ln.get('default-ok'), onRandConf, ConfirmWindow.MODECONFIRM, Global.ln.get('default-cancel'));
        }
    }

    private function onRandConf(ok:Bool):Void {
        if (ok) {
            var nms:Array<String> = [ ];
            for (i in 0...this.ui.lists['ilist'].dataProvider.length) {
                var ch:Bool = true;
                if (this.ui.lists['ilist'].selectedItem != null) {
                    if (i == this.ui.lists['ilist'].selectedIndex) {
                        ch = false;
                    }
                }
                if (ch) {
                    var name:String = this.ui.lists['ilist'].dataProvider.get(i).text;
                    var newname:String = StringStatic.random().substr(0, 10);
                    while (nms.contains(newname)) newname = StringStatic.random().substr(0, 10);
                    nms.push(newname);
                    trace ('inst', name, newname);
                    GlobalPlayer.area.imgSelect(name);
                    GlobalPlayer.area.setCurrentStr('instance', newname);
                }
            }
            GlobalPlayer.area.imgSelect();
            this.reloadContent();
        }
    }

    override public function reloadContent(data:Map<String, Dynamic> = null):Void {
        var items = [ ];
        for (k in GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].keys()) {
            items.push({ text: k, value: k });
        }
        this.ui.lists['ilist'].dataProvider = new ArrayCollection(items);
    }

    override public function updateContent(data:Map<String, Dynamic> = null):Void {
        if (this.ui.lists['ilist'].dataProvider != null) {
            for (n in 0...this.ui.lists['ilist'].dataProvider.length) {
                if (this.ui.lists['ilist'].dataProvider.get(n) != null) {
                    if (this.ui.lists['ilist'].dataProvider.get(n).value == data['nm']) {
                        this.ui.lists['ilist'].selectedIndex = n;
                    }
                }
            }
        }
    }

    public function instanceRename(oldn:String, newn:String):Void {
        if (this.ui.lists['ilist'].dataProvider != null) {
            for (n in 0...this.ui.lists['ilist'].dataProvider.length) {
                if (this.ui.lists['ilist'].dataProvider.get(n) != null) {
                    if (this.ui.lists['ilist'].dataProvider.get(n).value == oldn) {
                        this.ui.lists['ilist'].dataProvider.get(n).text = newn;
                        this.ui.lists['ilist'].dataProvider.get(n).value = newn;
                        this.ui.lists['ilist'].selectedIndex = n;
                        this.ui.lists['ilist'].dataProvider.updateAt(this.ui.lists['ilist'].selectedIndex);
                    }
                }
            }
        }
    }

    private function onChange(evt:Event):Void {
        if (this.ui.lists['ilist'].selectedItem != null) {
            GlobalPlayer.area.imgSelect(this.ui.lists['ilist'].selectedItem.value);
            for (cb in this.callbacks) cb([ 'nm' => this.ui.lists['ilist'].selectedItem.value ]);
        }
    }

}