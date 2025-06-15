/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.contraptions;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.contraptions.BackgroundContraption;
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

class WindowContrBackground extends PopupWindow {

    // current layouts
    private var _list:Map<String, BackgroundContraption> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-contrbg-title'), 1000, 540, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // picture inputs
        this.ui.createHContainer('landscape');
        this.ui.createTInput('landscape', '', '', this.ui.hcontainers['landscape'], false);
        this.ui.createIconButton('landscape', this.acImgL, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['landscape'], false);
        this.ui.createIconButton('landscapedel', this.acImgLdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['landscape'], false);
        this.ui.inputs['landscape'].enabled = false;
        this.ui.hcontainers['landscape'].setWidth(460, [350, 50, 50]);
        this.ui.createHContainer('portrait');
        this.ui.createTInput('portrait', '', '', this.ui.hcontainers['portrait'], false);
        this.ui.createIconButton('portrait', this.acImgP, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['portrait'], false);
        this.ui.createIconButton('portraitdel', this.acImgPdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['portrait'], false);
        this.ui.inputs['portrait'].enabled = false;
        this.ui.hcontainers['portrait'].setWidth(460, [350, 50, 50]);

        // creating columns
        this.addForm(Global.ln.get('window-kfmanage-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'registered', tx: Global.ln.get('window-contrbg-registered'), vr: '' }, 
                { tp: 'List', id: 'registered', vl: [ ], sl: null, ht: 200 }, 
                { tp: 'Button', id: 'load', tx: Global.ln.get('window-contrbg-load'), ac: loadContr }, 
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-contrbg-remove'), ac: removeContr },
                { tp: 'Spacer', id: 'add', ht: 15, ln: true }, 
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-contrbg-name'), vr: 'detail' }, 
                { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
                { tp: 'Button', id: 'add', tx: Global.ln.get('window-contrbg-add'), ac: addContr },
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'properties', tx: Global.ln.get('window-contrbg-properties'), vr: '' }, 
                { tp: 'Label', id: 'landscape', tx: Global.ln.get('window-contrbg-landscape'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['landscape'] }, 
                { tp: 'Label', id: 'portrait', tx: Global.ln.get('window-contrbg-portrait'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['portrait'] },               
            ]),
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'save', tx: Global.ln.get('window-contrbg-save'), ac: saveContr },
            ])
            , 420));
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
        for (contk in GlobalPlayer.contraptions.backgrounds) {
            this._list[contk.id] = contk.clone();
        }
        this.clear();
    }

    /**
        Clears current layout data.
    **/
    private function clear():Void {
        var list:Array<Dynamic> = [ ];
        for (cont in this._list) {
            list.push({text: cont.id, value: cont.id});
        }
        this.ui.setListValues('registered', list);
        this.ui.setListSelectValue('registered', null);
        this.ui.inputs['name'].text = '';
        this.ui.inputs['portrait'].text = '';
        this.ui.inputs['landscape'].text = '';
    }

    private function loadContr(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.value)) {
                this.ui.inputs['name'].text = this._list[this.ui.lists['registered'].selectedItem.value].id;
                this.ui.inputs['portrait'].text = this._list[this.ui.lists['registered'].selectedItem.value].portrait;
                this.ui.inputs['landscape'].text = this._list[this.ui.lists['registered'].selectedItem.value].landscape;
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'landscape':
                this.ui.inputs['landscape'].text = data['file'];
            case 'portrait':
                this.ui.inputs['portrait'].text = data['file'];
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
        for (cont in GlobalPlayer.contraptions.backgrounds.keys()) {
            GlobalPlayer.contraptions.backgrounds[cont].kill();
            GlobalPlayer.contraptions.backgrounds.remove(cont);
        }
        for (cont in this._list.keys()) {
            GlobalPlayer.contraptions.backgrounds[cont] = this._list[cont].clone();
        }
        this.clear();
        Global.ws.send('Movie/SaveContraptions', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.contraptions.getData()
        ], this.onSaveReturn);
    }

    private function addContr(evt:Event):Void {
        if (this.ui.inputs['name'].text.length > 3) {
            if ((this.ui.inputs['landscape'].text != '') || (this.ui.inputs['portrait'].text != '')) {
                var contr:BackgroundContraption;
                if (this._list.exists(this.ui.inputs['name'].text)) {
                    contr = this._list[this.ui.inputs['name'].text];
                    contr.load({
                        id: this.ui.inputs['name'].text, 
                        landscape: this.ui.inputs['landscape'].text, 
                        portrait: this.ui.inputs['portrait'].text, 
                    });
                    this.clear();
                } else {
                    contr = new BackgroundContraption();
                    contr.load({
                        id: this.ui.inputs['name'].text, 
                        landscape: this.ui.inputs['landscape'].text, 
                        portrait: this.ui.inputs['portrait'].text, 
                    });
                    this._list[this.ui.inputs['name'].text] = contr;
                    this.clear();
                }
            } else {
                Global.showPopup(Global.ln.get('window-contrbg-title'), Global.ln.get('window-contrbg-nographics'), 320, 150, Global.ln.get('default-ok'));
            }           
        } else {
            Global.showPopup(Global.ln.get('window-contrbg-title'), Global.ln.get('window-contrbg-noname'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    private function acImgP(evt:Event):Void {
        this._ac('portrait');
    }

    private function acImgPdel(evt:Event):Void {
        this.ui.inputs['portrait'].text = '';
    }

    private function acImgL(evt:Event):Void {
        this._ac('landscape');
    }

    private function acImgLdel(evt:Event):Void {
        this.ui.inputs['landscape'].text = '';
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-contrbg-title'), Global.ln.get('window-contrbg-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-contrbg-title'), Global.ln.get('window-contrbg-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-contrbg-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-contrbg-title'), Global.ln.get('window-contrbg-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

}