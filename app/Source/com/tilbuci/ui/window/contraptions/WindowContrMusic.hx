/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.contraptions;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.contraptions.MusicContraption;
import openfl.Assets;
import openfl.display.Bitmap;
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

class WindowContrMusic extends PopupWindow {

    // current list
    private var _list:Map<String, MusicContraption> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-contrmusic-title'), 1000, 510, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // audio input
        this.ui.createHContainer('audio');
        this.ui.createTInput('audio', '', '', this.ui.hcontainers['audio'], false);
        this.ui.createIconButton('audio', this.acAudio, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['audio'], false);
        this.ui.createIconButton('audiodel', this.acAudiodel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['audio'], false);
        this.ui.inputs['audio'].enabled = false;
        this.ui.hcontainers['audio'].setWidth(460, [350, 50, 50]);

        // creating columns
        this.addForm(Global.ln.get('window-kfmanage-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'registered', tx: Global.ln.get('window-contrmusic-registered'), vr: '' }, 
                { tp: 'List', id: 'registered', vl: [ ], sl: null, ht: 200 }, 
                { tp: 'Button', id: 'load', tx: Global.ln.get('window-contrmusic-load'), ac: loadContr }, 
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-contrmusic-remove'), ac: removeContr },
                { tp: 'Spacer', id: 'add', ht: 15, ln: true }, 
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-contrmusic-name'), vr: 'detail' }, 
                { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
                { tp: 'Button', id: 'add', tx: Global.ln.get('window-contrmusic-add'), ac: addContr },
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'properties', tx: Global.ln.get('window-contrmusic-properties'), vr: '' }, 
                { tp: 'Label', id: 'audio', tx: Global.ln.get('window-contrmusic-file'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['audio'] }, 
            ]),
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'save', tx: Global.ln.get('window-contrmusic-save'), ac: saveContr },
            ])
            , 410));
            this.ui.listDbClick('registered', this.loadContr);
            super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        for (cont in this._list.keys()) {
            this._list[cont].kill();
            this._list.remove(cont);
        }
        for (contk in GlobalPlayer.contraptions.musics) {
            this._list[contk.id] = contk.clone();
        }
        this.clear();
    }

    /**
        Clears current data.
    **/
    private function clear():Void {
        var list:Array<Dynamic> = [ ];
        for (cont in this._list) {
            list.push({text: cont.id, value: cont.id});
        }
        this.ui.setListValues('registered', list);
        this.ui.setListSelectValue('registered', null);
        this.ui.inputs['name'].text = '';
        this.ui.inputs['audio'].text = '';
    }

    private function loadContr(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.value)) {
                this.ui.inputs['name'].text = this._list[this.ui.lists['registered'].selectedItem.value].id;
                this.ui.inputs['audio'].text = this._list[this.ui.lists['registered'].selectedItem.value].media;
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'music':
                this.ui.inputs['audio'].text = data['file'];
        }
    }

    private function removeContr(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.value)) {
                this._list[this.ui.lists['registered'].selectedItem.value].kill();
                this._list.remove(this.ui.lists['registered'].selectedItem.value);
                this.clear();
            }
        }
    }

    private function saveContr(evt:Event):Void {
        for (cont in GlobalPlayer.contraptions.musics.keys()) {
            GlobalPlayer.contraptions.musics[cont].kill();
            GlobalPlayer.contraptions.musics.remove(cont);
        }
        for (cont in this._list.keys()) {
            GlobalPlayer.contraptions.musics[cont] = this._list[cont].clone();
        }
        this.clear();
        Global.ws.send('Movie/SaveContraptions', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.contraptions.getData()
        ], this.onSaveReturn);
    }

    private function addContr(evt:Event):Void {
        if (this.ui.inputs['name'].text.length > 3) {
            if (this.ui.inputs['audio'].text != '') {
                var contr:MusicContraption;
                if (this._list.exists(this.ui.inputs['name'].text)) {
                    contr = this._list[this.ui.inputs['name'].text];
                    contr.load({
                        id: this.ui.inputs['name'].text, 
                        media: this.ui.inputs['audio'].text
                    });
                    this.clear();
                } else {
                    contr = new MusicContraption();
                    contr.load({
                        id: this.ui.inputs['name'].text, 
                        media: this.ui.inputs['audio'].text
                    });
                    this._list[this.ui.inputs['name'].text] = contr;
                    this.clear();
                }
            } else {
                Global.showPopup(Global.ln.get('window-contrmusic-title'), Global.ln.get('window-contrmusic-noaudio'), 320, 150, Global.ln.get('default-ok'));
            }           
        } else {
            Global.showPopup(Global.ln.get('window-contrmusic-title'), Global.ln.get('window-contrmusic-noname'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    private function acAudio(evt:Event):Void {
        this._ac('music');
    }

    private function acAudiodel(evt:Event):Void {
        this.ui.inputs['audio'].text = '';
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-contrmusic-title'), Global.ln.get('window-contrmusic-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-contrmusic-title'), Global.ln.get('window-contrmusic-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-contrmusic-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-contrmusic-title'), Global.ln.get('window-contrmusic-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

}