/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.narrative;

/** OPENFL **/
import com.tilbuci.narrative.InvItemNarrative;
import com.tilbuci.ui.component.ActionArea;
import com.tilbuci.contraptions.InventoryContraption;
import com.tilbuci.statictools.StringStatic;
import openfl.Assets;
import openfl.events.Event;
import openfl.display.Stage;
import openfl.display.Bitmap;

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

class WindowNarrInv extends PopupWindow {

    private var _list:Map<String, InvItemNarrative> = [ ];

    private var _acsnippet:ActionArea;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-narrinv-title'), 1000, 580, true, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {

        this.ui.createHContainer('imgbgh');
        this.ui.createTInput('imgbgh', '', '', this.ui.hcontainers['imgbgh'], false);
        this.ui.createIconButton('imgbgh', this.acImgbgh, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgbgh'], false);
        this.ui.createIconButton('imimgbghdel', this.acImgbghdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgbgh'], false);
        this.ui.inputs['imgbgh'].enabled = false;

        this.ui.createHContainer('imgbgv');
        this.ui.createTInput('imgbgv', '', '', this.ui.hcontainers['imgbgv'], false);
        this.ui.createIconButton('imgbgv', this.acImgbgv, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgbgv'], false);
        this.ui.createIconButton('imimgbgvdel', this.acImgbgvdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgbgv'], false);
        this.ui.inputs['imgbgv'].enabled = false;

        this.ui.createHContainer('imgbt');
        this.ui.createTInput('imgbt', '', '', this.ui.hcontainers['imgbt'], false);
        this.ui.createIconButton('imgbt', this.acImgbt, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgbt'], false);
        this.ui.createIconButton('imgimgbtdel', this.acImgbtdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgbt'], false);
        this.ui.inputs['imgbt'].enabled = false;

        this.ui.createHContainer('itgraphic');
        this.ui.createTInput('itgraphic', '', '', this.ui.hcontainers['itgraphic'], false);
        this.ui.createIconButton('itgraphic', this.acItgraphic, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['itgraphic'], false);
        this.ui.createIconButton('itgraphicdel', this.acItgraphicdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['itgraphic'], false);
        this.ui.inputs['itgraphic'].enabled = false;

        this._acsnippet = new ActionArea(460, 267);

        this.addForm(Global.ln.get('window-narrinv-items'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'items', tx: Global.ln.get('window-narrinv-items'), vr: '' }, 
                { tp: 'List', id: 'items', vl: [ ], sl: null, ht: 350 }, 
                { tp: 'Button', id: 'loadit', tx: Global.ln.get('window-narrinv-loaditem'), ac: onLoadIt }, 
                { tp: 'Button', id: 'removeit', tx: Global.ln.get('window-narrinv-removeitem'), ac: onRemoveIt }, 
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'itname', tx: Global.ln.get('window-narrinv-itname'), vr: 'detail' }, 
                { tp: 'TInput', id: 'itname', tx: '', vr: '' }, 
                { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrinv-itgraphic'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Custom', cont: this.ui.hcontainers['itgraphic'] }, 
                { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrinv-itaction'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Custom', cont: this._acsnippet }, 
                { tp: 'Spacer', id: 'saveitem', ht: 10, ln: false }, 
                { tp: 'Button', id: 'saveitem', tx: Global.ln.get('window-narrinv-saveitem'), ac: onSetItem },                
            ]), 
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'iconsave', tx: Global.ln.get('window-narrinv-saveinventory'), ac: this.onSaveItems }
            ]), 460));

        this.ui.listDbClick('items', onLoadIt);
        
        this.addForm(Global.ln.get('window-narrinv-settings'), this.ui.forge('settings', [
            { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrinv-setabout'), vr: '' }, 
            { tp: 'Spacer', id: 'set', ht: 5, ln: false }, 
            { tp: 'Label', id: 'mode', tx: Global.ln.get('window-narrinv-mode'), vr: 'detail' }, 
            { tp: 'Select', id: 'mode', vl: [
                { text: Global.ln.get('window-narrinv-modeall'), value: 'a' }, 
                { text: Global.ln.get('window-narrinv-modeconsumable'), value: 'c' }, 
                { text: Global.ln.get('window-narrinv-modek'), value: 'k' }, 
            ], sl: null }, 
            { tp: 'Label', id: 'imgbgh', tx: Global.ln.get('window-narrinv-imgbgh'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Custom', cont: this.ui.hcontainers['imgbgh'] }, 
            { tp: 'Label', id: 'imgbgv', tx: Global.ln.get('window-narrinv-imgbgv'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Custom', cont: this.ui.hcontainers['imgbgv'] }, 
            { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrinv-button'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Custom', cont: this.ui.hcontainers['imgbt'] }, 
            { tp: 'Label', id: 'sound', tx: Global.ln.get('window-narrinv-sound'), vr: 'detail' }, 
            { tp: 'TInput', id: 'sound', tx: '', vr: '' }, 
            { tp: 'Label', id: 'font', tx: Global.ln.get('window-narrinv-font'), vr: 'detail' }, 
            { tp: 'Select', id: 'font', vl: [ ], sl: null }, 
            { tp: 'Label', id: 'fontsize', tx: Global.ln.get('window-narrinv-fontsize'), vr: 'detail' },
            { tp: 'Numeric', id: 'fontsize', mn: 8, mx: 200, st: 1, vl: 20 }, 
            { tp: 'Label', id: 'fontc', tx: Global.ln.get('window-narrinv-fontc'), vr: 'detail' }, 
            { tp: 'TInput', id: 'fontc', tx: '#FFFFFF', vr: '' },  
            { tp: 'Spacer', id: 'gap', ht: 10, ln: false }, 
            { tp: 'Button', id: 'set', tx: Global.ln.get('window-narrinv-btset'), ac: this.onSaveSet },  
        ]));

        super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        this.ui.hcontainers['imgbt'].setWidth(960, [810, 70, 70]);
        this.ui.hcontainers['imgbgh'].setWidth(960, [810, 70, 70]);
        this.ui.hcontainers['imgbgv'].setWidth(960, [810, 70, 70]);
        this.ui.hcontainers['itgraphic'].setWidth(460, [300, 70, 70]);

        this.ui.inputs['itname'].text = '';
        this.ui.inputs['itgraphic'].text = '';
        this.ui.setSelectValue('mode', 'a');
        this._acsnippet.setText('');

        var fnts:Array<Dynamic> = [ ];
        for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
        for (i in GlobalPlayer.mdata.fonts) fnts.push({ text: i.name, value: i.name });
        this.ui.setSelectOptions('font', fnts);

        if (GlobalPlayer.contraptions.inv.exists('inv')) {
            this.ui.inputs['imgbt'].text = GlobalPlayer.contraptions.inv['inv'].close;
            this.ui.inputs['imgbgh'].text = GlobalPlayer.contraptions.inv['inv'].horizontal;
            this.ui.inputs['imgbgv'].text = GlobalPlayer.contraptions.inv['inv'].vertical;
            this.ui.setSelectValue('font', GlobalPlayer.contraptions.inv['inv'].font);
            this.ui.inputs['fontc'].text = GlobalPlayer.contraptions.inv['inv'].fontcolor;
            this.ui.numerics['fontsize'].value = GlobalPlayer.contraptions.inv['inv'].fontsize;
            this.ui.setSelectValue('mode', GlobalPlayer.contraptions.inv['inv'].mode);
            this.ui.inputs['sound'].text = GlobalPlayer.contraptions.inv['inv'].sound;
        }

        for (k in this._list.keys()) {
            this._list[k].kill();
            this._list.remove(k);
        }
        for (k in GlobalPlayer.narrative.items) {
            this._list[k.itname] = k.clone();
        }
        this.showItems();
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'inventitem':
                this.ui.inputs['itgraphic'].text = data['file'];
            case 'inventclose':
                this.ui.inputs['imgbt'].text = data['file'];
            case 'inventh':
                this.ui.inputs['imgbgh'].text = data['file'];
            case 'inventv':
                this.ui.inputs['imgbgv'].text = data['file'];
        }
    }

    private function showItems():Void {
        var list:Array<Dynamic> = [ ];
        for (k in this._list.keys()) {
            list.push({
                value: k, 
                text: k, // + ' (' + Global.ln.get('window-narrinv-ittype' + this._list[k].ittype) + ')', 
            });
        }
        this.ui.setListValues('items', list);
        this.ui.setListSelectValue('items', null);
    }

    private function acImgbt(evt:Event):Void {
        this._ac('inventclose');
    }

    private function acImgbtdel(evt:Event):Void {
        this.ui.inputs['imgbt'].text = '';
    }

    private function acImgbgh(evt:Event):Void {
        this._ac('inventh');
    }

    private function acImgbghdel(evt:Event):Void {
        this.ui.inputs['imgbgh'].text = '';
    }

    private function acImgbgv(evt:Event):Void {
        this._ac('inventv');
    }

    private function acImgbgvdel(evt:Event):Void {
        this.ui.inputs['imgbgv'].text = '';
    }

    private function acItgraphic(evt:Event):Void {
        this._ac('inventitem');
    }

    private function acItgraphicdel(evt:Event):Void {
        this.ui.inputs['itgraphic'].text = '';
    }

    private function onLoadIt(evt:Event = null):Void {
        if (this.ui.lists['items'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['items'].selectedItem.value)) {
                this.ui.inputs['itname'].text = this._list[this.ui.lists['items'].selectedItem.value].itname;
                this.ui.inputs['itgraphic'].text = this._list[this.ui.lists['items'].selectedItem.value].itgraphic;
                this._acsnippet.setText(this._list[this.ui.lists['items'].selectedItem.value].itaction);
            }
        }
        
    }

    private function onRemoveIt(evt:Event):Void {
        if (this.ui.lists['items'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['items'].selectedItem.value)) {
                this._list.remove(this.ui.lists['items'].selectedItem.value);
                this.showItems();
            }
        }
    }

    private function onSetItem(evt:Event):Void {
        if ((this.ui.inputs['itname'].text == '') || (this.ui.inputs['itgraphic'].text == '')) {
            Global.showPopup(Global.ln.get('window-narrinv-titleitem'), Global.ln.get('window-narrinv-itemno'), 320, 150, Global.ln.get('default-ok'));
        } else {
            this._list[this.ui.inputs['itname'].text] = new InvItemNarrative({
                itname: this.ui.inputs['itname'].text, 
                ittype: 'c', 
                itgraphic: this.ui.inputs['itgraphic'].text, 
                itaction: this._acsnippet.getText(),
            });
            this.ui.inputs['itname'].text = '';
            this.ui.inputs['itgraphic'].text = '';
            this._acsnippet.setText('');
            this.showItems();
        }
    }

    private function onSaveItems(evt:Event):Void {
        for (k in GlobalPlayer.narrative.items.keys()) {
            GlobalPlayer.narrative.items[k].kill();
            GlobalPlayer.narrative.items.remove(k);
        }
        for (k in this._list.keys()) {
            GlobalPlayer.narrative.items[k] = this._list[k];
            this._list.remove(k);
        }
        Global.ws.send('Movie/SaveNarrative', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.narrative.getData(), 
        ], this.onSaveReturn);
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-narrinv-titleitem'), Global.ln.get('window-narrinv-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-narrinv-titleitem'), Global.ln.get('window-narrinv-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-narrinv-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-narrinv-titleitem'), Global.ln.get('window-narrinv-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    /**
        Save display settings.
    **/
    private function onSaveSet(evt:Event):Void {
        if (this.ui.inputs['imgbt'].text == '') {
            Global.showPopup(Global.ln.get('window-narrinv-title'), Global.ln.get('window-narrinv-noclose'), 320, 150, Global.ln.get('default-ok'));
        } else if ((this.ui.inputs['imgbgh'].text == '') && (this.ui.inputs['imgbgv'].text == '')) {
            Global.showPopup(Global.ln.get('window-narrinv-title'), Global.ln.get('window-narrinv-nobg'), 320, 150, Global.ln.get('default-ok'));
        } else {
            var contr:InventoryContraption = new InventoryContraption();
            if (contr.load({
                id: 'inv', 
                font: this.ui.selects['font'].selectedItem.value, 
                fontcolor: StringStatic.colorHex(this.ui.inputs['fontc'].text, '#FFFFFF'),
                fontsize: Math.round(this.ui.numerics['fontsize'].value), 
                close: this.ui.inputs['imgbt'].text, 
                horizontal: this.ui.inputs['imgbgh'].text, 
                vertical: this.ui.inputs['imgbgv'].text, 
                mode: this.ui.selects['mode'].selectedItem.value, 
                sound: this.ui.inputs['sound'].text, 
            })) {
                for (k in GlobalPlayer.contraptions.inv.keys()) {
                    GlobalPlayer.contraptions.inv[k].kill();
                    GlobalPlayer.contraptions.inv.remove(k);
                }
                GlobalPlayer.contraptions.inv['inv'] = contr;
                Global.ws.send('Movie/SaveContraptions', [
                    'movie' => GlobalPlayer.movie.mvId, 
                    'data' => GlobalPlayer.contraptions.getData()
                ], this.onSaveSetReturn);
            } else {
                Global.showPopup(Global.ln.get('window-narrinv-title'), Global.ln.get('window-narrinv-errorset'), 320, 150, Global.ln.get('default-ok'));
            }
            
        }
    }

    private function onSaveSetReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-narrinv-title'), Global.ln.get('window-narrinv-ersave1set'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-narrinv-title'), Global.ln.get('window-narrinv-ersaveset'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-narrinv-oksaveset'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-narrinv-title'), Global.ln.get('window-narrinv-ersaveset'), 320, 150, Global.ln.get('default-ok'));
        }
    }

}