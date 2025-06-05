/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.narrative;

/** OPENFL **/
import com.tilbuci.narrative.CharacterNarrative;
import com.tilbuci.statictools.StringStatic;
import openfl.Assets;
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
import com.tilbuci.ui.window.media.WindowCollections;

class WindowNarrChar extends PopupWindow {

    // current characters
    private var _list:Map<String, CharacterNarrative> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-narrchar-title'), 1000, 510, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-narrchar-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'registered', tx: Global.ln.get('window-narrchar-registered'), vr: '' }, 
                { tp: 'List', id: 'registered', vl: [ ], sl: null, ht: 200 }, 
                { tp: 'Button', id: 'load', tx: Global.ln.get('window-narrchar-load'), ac: loadNarr }, 
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-narrchar-remove'), ac: removeNarr },
                { tp: 'Spacer', id: 'add', ht: 15, ln: true }, 
                { tp: 'Label', id: 'id', tx: Global.ln.get('window-narrchar-id'), vr: 'detail' }, 
                { tp: 'TInput', id: 'id', tx: '', vr: '' }, 
                { tp: 'Button', id: 'add', tx: Global.ln.get('window-narrchar-add'), ac: addNarr },
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'properties', tx: Global.ln.get('window-narrchar-properties'), vr: '' }, 
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-narrchar-name'), vr: 'detail' },
                { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
                { tp: 'Label', id: 'about', tx: Global.ln.get('window-narrchar-about'), vr: 'detail' },
                { tp: 'TArea', id: 'about', tx: '', vr: '' }, 
                { tp: 'Label', id: 'collection', tx: Global.ln.get('window-narrchar-collection'), vr: 'detail' },
                { tp: 'Select', id: 'collection', vl: [], sl: null }, 
            ]),
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'save', tx: Global.ln.get('window-narrchar-save'), ac: saveNarr },
            ])
            , 410));
            this.ui.listDbClick('registered', this.loadNarr);
            super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        for (k in this._list.keys()) {
            this._list[k].kill();
            this._list.remove(k);
        }
        for (k in GlobalPlayer.narrative.chars) {
            this._list[k.id] = k.clone();
        }
        this.clear();
        Global.ws.send('Media/ListCollections', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
    }

    /**
        The collections list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-narrchar-title'), Global.ln.get('window-narrchar-nolist'), 300, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else{
            if (ld.map['e'] == 0) {
                var clist:Array<CollectionInfo> = cast ld.map['list'];
                var list = [ ];
                for (i in clist) {
                    list.push({
                        text: i.title, 
                        value: i.id
                    });
                }

trace ('options', list);

                this.ui.setSelectOptions('collection', list);
            } else {
                this.ui.createWarning(Global.ln.get('window-narrchar-title'), Global.ln.get('window-narrchar-nolist'), 300, 180, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Clears current layout data.
    **/
    private function clear():Void {
        var list:Array<Dynamic> = [ ];
        for (k in this._list) {
            list.push({text: k.id, value: k.id});
        }
        this.ui.setListValues('registered', list);
        this.ui.setListSelectValue('registered', null);
        this.ui.inputs['id'].text = '';
        this.ui.inputs['name'].text = '';
        this.ui.tareas['about'].text = '';
    }

    private function loadNarr(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.value)) {
                this.ui.inputs['id'].text = this._list[this.ui.lists['registered'].selectedItem.value].id;
                this.ui.inputs['name'].text = this._list[this.ui.lists['registered'].selectedItem.value].chname;
                this.ui.tareas['about'].text = this._list[this.ui.lists['registered'].selectedItem.value].about;
                this.ui.setSelectValue('collection', this._list[this.ui.lists['registered'].selectedItem.value].collection);
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            
        }
    }

    private function removeNarr(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.value)) {
                this._list[this.ui.lists['registered'].selectedItem.value].kill();
                this._list.remove(this.ui.lists['registered'].selectedItem.value);
                this.clear();
            }
        }
    }

    private function saveNarr(evt:Event):Void {
        for (nar in GlobalPlayer.narrative.chars.keys()) {
            GlobalPlayer.narrative.chars[nar].kill();
            GlobalPlayer.narrative.chars.remove(nar);
        }
        for (nar in this._list.keys()) {
            GlobalPlayer.narrative.chars[nar] = this._list[nar].clone();
        }
        this.clear();
        Global.ws.send('Movie/SaveNarrative', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.narrative.getData(), 
        ], this.onSaveReturn);
    }

    private function addNarr(evt:Event):Void {
        if (this.ui.inputs['id'].text.length >= 3) {
            if (this.ui.inputs['name'].text != '') {
                var char:CharacterNarrative;
                var collection:String = '';
                if (this.ui.selects['collection'].selectedItem != null) collection = this.ui.selects['collection'].selectedItem.value;
                if (this._list.exists(this.ui.inputs['id'].text)) {
                    char = this._list[this.ui.inputs['id'].text];
                    char.load({
                        id: this.ui.inputs['id'].text, 
                        chname: this.ui.inputs['name'].text, 
                        about: this.ui.tareas['about'].text, 
                        collection: collection, 
                    });
                    this._list[this.ui.inputs['id'].text] = char;
                    this.clear();
                } else {
                    char = new CharacterNarrative();
                    char.load({
                        id: this.ui.inputs['id'].text, 
                        chname: this.ui.inputs['name'].text, 
                        about: this.ui.tareas['about'].text, 
                        collection: collection, 
                    });
                    this._list[this.ui.inputs['id'].text] = char;
                    this.clear();
                }
            } else {
                Global.showPopup(Global.ln.get('window-narrchar-title'), Global.ln.get('window-narrchar-noname'), 320, 150, Global.ln.get('default-ok'));
            }  
        } else {
            Global.showPopup(Global.ln.get('window-narrchar-title'), Global.ln.get('window-narrchar-noid'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-narrchar-title'), Global.ln.get('window-narrchar-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-narrchar-title'), Global.ln.get('window-narrchar-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-narrchar-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-narrchar-title'), Global.ln.get('window-narrchar-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

}