/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.contraptions;

/** OPENFL **/
import com.tilbuci.contraptions.MessagesContraption;
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.statictools.StringStatic;
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

class WindowContrMessages extends PopupWindow {

    // current layouts
    private var _list:Map<String, MessagesContraption> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-contrmess-title'), 1000, InterfaceFactory.pickValue(570, 590), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // picture inputs
        this.ui.createHContainer('imgbg');
        this.ui.createTInput('imgbg', '', '', this.ui.hcontainers['imgbg'], false);
        this.ui.createIconButton('imgbg', this.acImgbg, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgbg'], false);
        this.ui.createIconButton('imgbgdel', this.acImgbgdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgbg'], false);
        this.ui.inputs['imgbg'].enabled = false;
        this.ui.hcontainers['imgbg'].setWidth(460, [350, 50, 50]);

        this.ui.createHContainer('imgbt0');
        this.ui.createTInput('imgbt0', '', '', this.ui.hcontainers['imgbt0'], false);
        this.ui.createIconButton('imgbt0', this.acImgbt0, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgbt0'], false);
        this.ui.createIconButton('imgimgbt0del', this.acImgbt0del, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgbt0'], false);
        this.ui.inputs['imgbt0'].enabled = false;
        this.ui.hcontainers['imgbt0'].setWidth(460, [350, 50, 50]);

        this.ui.createHContainer('imgbt1');
        this.ui.createTInput('imgbt1', '', '', this.ui.hcontainers['imgbt1'], false);
        this.ui.createIconButton('imgbt1', this.acImgbt1, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgbt1'], false);
        this.ui.createIconButton('imgimgbt1del', this.acImgbt1del, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgbt1'], false);
        this.ui.inputs['imgbt1'].enabled = false;
        this.ui.hcontainers['imgbt1'].setWidth(460, [350, 50, 50]);

        this.ui.createHContainer('imgbt2');
        this.ui.createTInput('imgbt2', '', '', this.ui.hcontainers['imgbt2'], false);
        this.ui.createIconButton('imgbt2', this.acImgbt2, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgbt2'], false);
        this.ui.createIconButton('imgimgbtdel', this.acImgbt2del, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgbt2'], false);
        this.ui.inputs['imgbt2'].enabled = false;
        this.ui.hcontainers['imgbt2'].setWidth(460, [350, 50, 50]);

        // creating columns
        this.addForm(Global.ln.get('window-contrmess-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'registered', tx: Global.ln.get('window-contrmess-registered'), vr: '' }, 
                { tp: 'List', id: 'registered', vl: [ ], sl: null, ht: 245 }, 
                { tp: 'Button', id: 'load', tx: Global.ln.get('window-contrmess-load'), ac: loadMenu }, 
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-contrmess-remove'), ac: removeMenu },
                { tp: 'Spacer', id: 'add', ht: 15, ln: true }, 
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-contrmess-name'), vr: 'detail' }, 
                { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
                { tp: 'Button', id: 'add', tx: Global.ln.get('window-contrmess-add'), ac: addMenu },
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'properties', tx: Global.ln.get('window-contrmess-properties'), vr: '' }, 
                { tp: 'Label', id: 'font', tx: Global.ln.get('window-contrmess-font'), vr: 'detail' }, 
                { tp: 'Select', id: 'font', vl: [ ], sl: null }, 
                { tp: 'Label', id: 'fontsize', tx: Global.ln.get('window-contrmess-fontsize'), vr: 'detail' },
                { tp: 'Numeric', id: 'fontsize', mn: 8, mx: 200, st: 1, vl: 0 }, 
                { tp: 'Label', id: 'fontc', tx: Global.ln.get('window-contrmess-fontc'), vr: 'detail' }, 
                { tp: 'TInput', id: 'fontc', tx: '', vr: '' },  
                { tp: 'Label', id: 'gap', tx: Global.ln.get('window-contrmess-gap'), vr: 'detail' },
                { tp: 'Numeric', id: 'gap', mn: 0, mx: 500, st: 1, vl: 10 }, 
                { tp: 'Label', id: 'imgbg', tx: Global.ln.get('window-contrmess-imgbg'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['imgbg'] }, 
                { tp: 'Label', id: 'imgbt0', tx: Global.ln.get('window-contrmess-imgbt0'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['imgbt0'] },  
                { tp: 'Label', id: 'imgbt1', tx: Global.ln.get('window-contrmess-imgbt1'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['imgbt1'] },  
                { tp: 'Label', id: 'imgbt2', tx: Global.ln.get('window-contrmess-imgbt2'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['imgbt2'] },               
            ]),
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'save', tx: Global.ln.get('window-contrmess-save'), ac: saveMenu },
            ])
            , 460));
            this.ui.listDbClick('registered', this.loadMenu);
            super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        for (mnk in this._list.keys()) {
            this._list[mnk].kill();
            this._list.remove(mnk);
        }
        for (mn in GlobalPlayer.contraptions.messages) {
            this._list[mn.id] = mn.clone();
        }
        this.clear();
    }

    /**
        Clears current layout data.
    **/
    private function clear():Void {
        this.ui.inputs['fontc'].text = '#FFFFFF';
        var list:Array<Dynamic> = [ ];
        for (mn in this._list) {
            list.push({text: mn.id, value: mn.id});
        }
        this.ui.setListValues('registered', list);
        this.ui.setListSelectValue('registered', null);
        this.ui.inputs['name'].text = '';
        var fnts:Array<Dynamic> = [ ];
        for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
        for (i in GlobalPlayer.mdata.fonts) fnts.push({ text: i.name, value: i.name });
        this.ui.setSelectOptions('font', fnts);
        this.ui.setSelectValue('font', null);
        this.ui.numerics['fontsize'].value = 20;
        this.ui.numerics['gap'].value = 10;
        this.ui.inputs['imgbg'].text = '';
        this.ui.inputs['imgbt0'].text = '';
        this.ui.inputs['imgbt1'].text = '';
        this.ui.inputs['imgbt2'].text = '';
    }

    private function loadMenu(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.value)) {
                this.ui.inputs['name'].text = this._list[this.ui.lists['registered'].selectedItem.value].id;
                this.ui.inputs['fontc'].text = this._list[this.ui.lists['registered'].selectedItem.value].fontcolor;
                this.ui.setSelectValue('font', this._list[this.ui.lists['registered'].selectedItem.value].font);
                this.ui.numerics['fontsize'].value = Math.round(this._list[this.ui.lists['registered'].selectedItem.value].fontsize);
                this.ui.numerics['gap'].value = Math.round(this._list[this.ui.lists['registered'].selectedItem.value].gap);
                this.ui.inputs['imgbg'].text = this._list[this.ui.lists['registered'].selectedItem.value].background;
                this.ui.inputs['imgbt0'].text = this._list[this.ui.lists['registered'].selectedItem.value].buton[0];
                this.ui.inputs['imgbt1'].text = this._list[this.ui.lists['registered'].selectedItem.value].buton[1];
                this.ui.inputs['imgbt2'].text = this._list[this.ui.lists['registered'].selectedItem.value].buton[2];
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'messagesbrowseimgbg':
                this.ui.inputs['imgbg'].text = data['file'];
            case 'messagesbrowseimgbt0':
                this.ui.inputs['imgbt0'].text = data['file'];
            case 'messagesbrowseimgbt1':
                this.ui.inputs['imgbt1'].text = data['file'];
            case 'messagesbrowseimgbt2':
                this.ui.inputs['imgbt2'].text = data['file'];
        }
    }

    private function removeMenu(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.value)) {
                this._list[this.ui.lists['registered'].selectedItem.value].kill();
                this._list.remove(this.ui.lists['registered'].selectedItem.value);
                this.clear();
            }
        }
    }

    private function saveMenu(evt:Event):Void {
        for (mn in GlobalPlayer.contraptions.messages.keys()) {
            GlobalPlayer.contraptions.messages[mn].kill();
            GlobalPlayer.contraptions.messages.remove(mn);
        }
        for (mn in this._list.keys()) {
            GlobalPlayer.contraptions.messages[mn] = this._list[mn].clone();
        }
        this.clear();
        Global.ws.send('Movie/SaveContraptions', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.contraptions.getData()
        ], this.onSaveReturn);
    }

    private function addMenu(evt:Event):Void {
        if (this.ui.inputs['name'].text.length >= 3) {
            if ((this.ui.inputs['imgbg'].text == '') || (this.ui.inputs['imgbt0'].text == '')) {
                Global.showPopup(Global.ln.get('window-contrmess-title'), Global.ln.get('window-contrmess-nographics'), 320, 150, Global.ln.get('default-ok'));
            } else {
                var mn:MessagesContraption;
                if (this._list.exists(this.ui.inputs['name'].text)) {
                    mn = this._list[this.ui.inputs['name'].text];
                } else {
                    mn = new MessagesContraption();
                }
                mn.load({
                    id: this.ui.inputs['name'].text, 
                    font: this.ui.selects['font'].selectedItem.value, 
                    fontcolor: StringStatic.colorHex(this.ui.inputs['fontc'].text, '#FFFFFF'), 
                    fontsize: this.ui.numerics['fontsize'].value, 
                    gap: this.ui.numerics['gap'].value, 
                    background: this.ui.inputs['imgbg'].text, 
                    buton0: this.ui.inputs['imgbt0'].text, 
                    buton1: this.ui.inputs['imgbt1'].text, 
                    buton2: this.ui.inputs['imgbt2'].text, 
                });
                this._list[this.ui.inputs['name'].text] = mn;
                this.clear();
            }            
        } else {
            Global.showPopup(Global.ln.get('window-contrmess-title'), Global.ln.get('window-contrmess-noname'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    private function acImgbg(evt:Event):Void {
        this._ac('messagesbrowseimgbg');
    }

    private function acImgbgdel(evt:Event):Void {
        this.ui.inputs['imgbg'].text = '';
    }

    private function acImgbt0(evt:Event):Void {
        this._ac('messagesbrowseimgbt0');
    }

    private function acImgbt0del(evt:Event):Void {
        this.ui.inputs['imgbt0'].text = '';
    }

    private function acImgbt1(evt:Event):Void {
        this._ac('messagesbrowseimgbt1');
    }

    private function acImgbt1del(evt:Event):Void {
        this.ui.inputs['imgbt1'].text = '';
    }

    private function acImgbt2(evt:Event):Void {
        this._ac('messagesbrowseimgbt2');
    }

    private function acImgbt2del(evt:Event):Void {
        this.ui.inputs['imgbt2'].text = '';
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-contrmess-title'), Global.ln.get('window-contrmess-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-contrmess-title'), Global.ln.get('window-contrmess-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-contrmess-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-contrmess-title'), Global.ln.get('window-contrmess-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

}