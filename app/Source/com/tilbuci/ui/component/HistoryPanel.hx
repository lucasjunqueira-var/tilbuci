/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;


import feathers.layout.AnchorLayoutData;
import feathers.controls.ListView;
import feathers.data.ArrayCollection;
import openfl.events.Event;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.Global;
import com.tilbuci.data.History;

class HistoryPanel extends DropDownPanel {

    private var _centerMethod:Dynamic;

    public function new(wd:Float, centerMethod:Dynamic) {
        super(Global.ln.get('rightbar-history'), wd);
        this._centerMethod = centerMethod;
        this.ui.createList('list', [], 200);
        this.ui.setListToIcon('list');
        this.ui.lists['list'].addEventListener(Event.CHANGE, onChange);
        this._content = this.ui.lists['list'];
        this._content.width = wd - 20;
        Global.history.historyDisplay = this.reloadContent;
    }

    override public function reloadContent(data:Map<String, Dynamic> = null):Void {
        var items = [ ];
        var stnum:Int = 0;
        for (st in Global.history.states) {
            items.push({
                text: st.title, 
                value: stnum, 
                asset: st.orientation, 
                user: st.name
            });
            stnum++;
        }
        items.reverse();
        this.ui.setListValues('list', items);
    }

    private function onChange(evt:Event):Void {
        if (this.ui.lists['list'].selectedItem != null) {
            Global.history.loadState(this.ui.lists['list'].selectedItem.value);
            this._centerMethod();
        }
    }

}