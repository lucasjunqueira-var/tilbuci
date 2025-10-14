/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.contraptions;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.contraptions.TargetContraption;
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

class WindowContrTarget extends PopupWindow {

    // current layouts
    private var _list:Map<String, TargetContraption> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-contrtr-title'), 1000, InterfaceFactory.pickValue(575, 590), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // picture inputs
        this.ui.createHContainer('default');
        this.ui.createTInput('default', '', '', this.ui.hcontainers['default'], false);
        this.ui.createIconButton('default', this.acImgD, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['default'], false);
        this.ui.createIconButton('defaultdel', this.acImgDdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['default'], false);
        this.ui.inputs['default'].enabled = false;
        this.ui.hcontainers['default'].setWidth(460, [350, 50, 50]);

        this.ui.createHContainer('menus');
        this.ui.createTInput('menus', '', '', this.ui.hcontainers['menus'], false);
        this.ui.createIconButton('menus', this.acImgM, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['menus'], false);
        this.ui.createIconButton('menusdel', this.acImgMdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['menus'], false);
        this.ui.inputs['menus'].enabled = false;
        this.ui.hcontainers['menus'].setWidth(460, [350, 50, 50]);

        this.ui.createHContainer('interf');
        this.ui.createTInput('interf', '', '', this.ui.hcontainers['interf'], false);
        this.ui.createIconButton('interf', this.acImgI, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['interf'], false);
        this.ui.createIconButton('interfdel', this.acImgIdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['interf'], false);
        this.ui.inputs['interf'].enabled = false;
        this.ui.hcontainers['interf'].setWidth(460, [350, 50, 50]);

        this.ui.createHContainer('inst1');
        this.ui.createTInput('inst1', '', '', this.ui.hcontainers['inst1'], false);
        this.ui.createIconButton('inst1', this.acImgI1, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['inst1'], false);
        this.ui.createIconButton('inst1del', this.acImgI1del, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['inst1'], false);
        this.ui.inputs['inst1'].enabled = false;
        this.ui.hcontainers['inst1'].setWidth(460, [350, 50, 50]);

        this.ui.createHContainer('inst2');
        this.ui.createTInput('inst2', '', '', this.ui.hcontainers['inst2'], false);
        this.ui.createIconButton('inst2', this.acImgI2, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['inst2'], false);
        this.ui.createIconButton('inst2del', this.acImgI2del, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['inst2'], false);
        this.ui.inputs['inst2'].enabled = false;
        this.ui.hcontainers['inst2'].setWidth(460, [350, 50, 50]);
        
        this.ui.createHContainer('inst3');
        this.ui.createTInput('inst3', '', '', this.ui.hcontainers['inst3'], false);
        this.ui.createIconButton('inst3', this.acImgI3, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['inst3'], false);
        this.ui.createIconButton('inst3del', this.acImgI3del, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['inst3'], false);
        this.ui.inputs['inst3'].enabled = false;
        this.ui.hcontainers['inst3'].setWidth(460, [350, 50, 50]);

        // creating columns
        this.addForm(Global.ln.get('window-contrtr-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'registered', tx: Global.ln.get('window-contrtr-registered'), vr: '' }, 
                { tp: 'List', id: 'registered', vl: [ ], sl: null, ht: 260 }, 
                { tp: 'Button', id: 'load', tx: Global.ln.get('window-contrtr-load'), ac: loadContr }, 
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-contrtr-remove'), ac: removeContr },
                { tp: 'Spacer', id: 'add', ht: 15, ln: true }, 
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-contrtr-name'), vr: 'detail' }, 
                { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
                { tp: 'Button', id: 'add', tx: Global.ln.get('window-contrtr-add'), ac: addContr },
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'landscape', tx: Global.ln.get('window-contrtr-default'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['default'] },
                { tp: 'Label', id: 'menus', tx: Global.ln.get('window-contrtr-menus'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['menus'] },     
                { tp: 'Label', id: 'interf', tx: Global.ln.get('window-contrtr-interf'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['interf'] },
                { tp: 'Spacer', id: 'spacer', ht: 20, ln: true },
                { tp: 'Label', id: 'inst1', tx: Global.ln.get('window-contrtr-inst'), vr: 'detail' },
                { tp: 'TInput', id: 'inst1name', tx: '', vr: '' }, 
                { tp: 'Custom', cont: this.ui.hcontainers['inst1'] },
                { tp: 'Spacer', id: 'spacer1', ht: 10, ln: false },
                { tp: 'Label', id: 'inst2', tx: Global.ln.get('window-contrtr-inst'), vr: 'detail' },
                { tp: 'TInput', id: 'inst2name', tx: '', vr: '' }, 
                { tp: 'Custom', cont: this.ui.hcontainers['inst2'] },
                { tp: 'Spacer', id: 'spacer2', ht: 10, ln: false },
                { tp: 'Label', id: 'inst3', tx: Global.ln.get('window-contrtr-inst'), vr: 'detail' },
                { tp: 'TInput', id: 'inst3name', tx: '', vr: '' }, 
                { tp: 'Custom', cont: this.ui.hcontainers['inst3'] },

            ]),
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'save', tx: Global.ln.get('window-contrtr-save'), ac: saveContr },
            ])
            , 480));
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
        for (contk in GlobalPlayer.contraptions.targets) {
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
        this.ui.inputs['default'].text = '';
        this.ui.inputs['menus'].text = '';
        this.ui.inputs['interf'].text = '';
        this.ui.inputs['inst1'].text = '';
        this.ui.inputs['inst1name'].text = '';
        this.ui.inputs['inst2'].text = '';
        this.ui.inputs['inst2name'].text = '';
        this.ui.inputs['inst3'].text = '';
        this.ui.inputs['inst3name'].text = '';
    }

    private function loadContr(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.value)) {
                this.ui.inputs['name'].text = this._list[this.ui.lists['registered'].selectedItem.value].id;
                this.ui.inputs['default'].text = this._list[this.ui.lists['registered'].selectedItem.value].defaultp;
                this.ui.inputs['menus'].text = this._list[this.ui.lists['registered'].selectedItem.value].menus;
                this.ui.inputs['interf'].text = this._list[this.ui.lists['registered'].selectedItem.value].interf;
                this.ui.inputs['inst1'].text = this._list[this.ui.lists['registered'].selectedItem.value].inst1;
                this.ui.inputs['inst1name'].text = this._list[this.ui.lists['registered'].selectedItem.value].inst1name;
                this.ui.inputs['inst2'].text = this._list[this.ui.lists['registered'].selectedItem.value].inst2;
                this.ui.inputs['inst2name'].text = this._list[this.ui.lists['registered'].selectedItem.value].inst2name;
                this.ui.inputs['inst3'].text = this._list[this.ui.lists['registered'].selectedItem.value].inst3;
                this.ui.inputs['inst3name'].text = this._list[this.ui.lists['registered'].selectedItem.value].inst3name;
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'default':
                this.ui.inputs['default'].text = data['file'];
            case 'menus':
                this.ui.inputs['menus'].text = data['file'];
            case 'interf':
                this.ui.inputs['interf'].text = data['file'];
            case 'inst1':
                this.ui.inputs['inst1'].text = data['file'];
            case 'inst2':
                this.ui.inputs['inst2'].text = data['file'];
            case 'inst3':
                this.ui.inputs['inst3'].text = data['file'];
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
        for (cont in GlobalPlayer.contraptions.targets.keys()) {
            GlobalPlayer.contraptions.targets[cont].kill();
            GlobalPlayer.contraptions.targets.remove(cont);
        }
        for (cont in this._list.keys()) {
            GlobalPlayer.contraptions.targets[cont] = this._list[cont].clone();
        }
        this.clear();
        Global.ws.send('Movie/SaveContraptions', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.contraptions.getData()
        ], this.onSaveReturn);
    }

    private function addContr(evt:Event):Void {
        if (this.ui.inputs['name'].text.length > 3) {
            if (this.ui.inputs['default'].text != '') {
                var contr:TargetContraption;
                if (this._list.exists(this.ui.inputs['name'].text)) {
                    contr = this._list[this.ui.inputs['name'].text];
                    contr.load({
                        id: this.ui.inputs['name'].text, 
                        defaultp: this.ui.inputs['default'].text, 
                        menus: this.ui.inputs['menus'].text, 
                        interf: this.ui.inputs['interf'].text, 
                        inst1: this.ui.inputs['inst1'].text, 
                        inst1name: this.ui.inputs['inst1name'].text, 
                        inst2: this.ui.inputs['inst2'].text, 
                        inst2name: this.ui.inputs['inst2name'].text, 
                        inst3: this.ui.inputs['inst3'].text, 
                        inst3name: this.ui.inputs['inst3name'].text, 
                    });
                    this.clear();
                } else {
                    contr = new TargetContraption();
                    contr.load({
                        id: this.ui.inputs['name'].text, 
                        defaultp: this.ui.inputs['default'].text, 
                        menus: this.ui.inputs['menus'].text, 
                        interf: this.ui.inputs['interf'].text, 
                        inst1: this.ui.inputs['inst1'].text, 
                        inst1name: this.ui.inputs['inst1name'].text, 
                        inst2: this.ui.inputs['inst2'].text, 
                        inst2name: this.ui.inputs['inst2name'].text, 
                        inst3: this.ui.inputs['inst3'].text, 
                        inst3name: this.ui.inputs['inst3name'].text,
                    });
                    this._list[this.ui.inputs['name'].text] = contr;
                    this.clear();
                }
            } else {
                Global.showPopup(Global.ln.get('window-contrtr-title'), Global.ln.get('window-contrtr-nographics'), 320, 150, Global.ln.get('default-ok'));
            }           
        } else {
            Global.showPopup(Global.ln.get('window-contrtr-title'), Global.ln.get('window-contrtr-noname'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    private function acImgD(evt:Event):Void {
        this._ac('default');
    }

    private function acImgDdel(evt:Event):Void {
        this.ui.inputs['default'].text = '';
    }

    private function acImgM(evt:Event):Void {
        this._ac('menus');
    }

    private function acImgMdel(evt:Event):Void {
        this.ui.inputs['menus'].text = '';
    }

    private function acImgI(evt:Event):Void {
        this._ac('interf');
    }

    private function acImgIdel(evt:Event):Void {
        this.ui.inputs['interf'].text = '';
    }

    private function acImgI1(evt:Event):Void {
        this._ac('inst1');
    }

    private function acImgI1del(evt:Event):Void {
        this.ui.inputs['inst1'].text = '';
    }

    private function acImgI2(evt:Event):Void {
        this._ac('inst2');
    }

    private function acImgI2del(evt:Event):Void {
        this.ui.inputs['inst2'].text = '';
    }

    private function acImgI3(evt:Event):Void {
        this._ac('inst3');
    }

    private function acImgI3del(evt:Event):Void {
        this.ui.inputs['inst3'].text = '';
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-contrtr-title'), Global.ln.get('window-contrtr-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-contrtr-title'), Global.ln.get('window-contrtr-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-contrtr-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-contrtr-title'), Global.ln.get('window-contrtr-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

}