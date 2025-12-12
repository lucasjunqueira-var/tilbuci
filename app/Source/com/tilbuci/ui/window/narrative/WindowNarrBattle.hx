/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.narrative;

/** OPENFL **/
import com.tilbuci.narrative.BattleCardNarrative;
import com.tilbuci.contraptions.BattleContraption;
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

class WindowNarrBattle extends PopupWindow {

    private var _list:Map<String, BattleCardNarrative> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-narrbattle-title'), 1000, 580, true, true, true);
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

        this.ui.createHContainer('imgattr');
        this.ui.createTInput('imgattr', '', '', this.ui.hcontainers['imgattr'], false);
        this.ui.createIconButton('imgattr', this.acImgattr, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgattr'], false);
        this.ui.createIconButton('imgattrdel', this.acImgattrdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgattr'], false);
        this.ui.inputs['imgattr'].enabled = false;

        this.ui.createHContainer('imgcard');
        this.ui.createTInput('imgcard', '', '', this.ui.hcontainers['imgcard'], false);
        this.ui.createIconButton('imgcard', this.acImgcard, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgcard'], false);
        this.ui.createIconButton('imgcarddel', this.acImgcarddel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgcard'], false);
        this.ui.inputs['imgcard'].enabled = false;

        this.ui.createHContainer('itgraphic');
        this.ui.createTInput('itgraphic', '', '', this.ui.hcontainers['itgraphic'], false);
        this.ui.createIconButton('itgraphic', this.acItgraphic, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['itgraphic'], false);
        this.ui.createIconButton('itgraphicdel', this.acItgraphicdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['itgraphic'], false);
        this.ui.inputs['itgraphic'].enabled = false;

        this.addForm(Global.ln.get('window-narrbattle-cards'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'items', tx: Global.ln.get('window-narrbattle-available'), vr: '' }, 
                { tp: 'List', id: 'items', vl: [ ], sl: null, ht: 350 }, 
                { tp: 'Button', id: 'loadit', tx: Global.ln.get('window-narrbattle-loadcards'), ac: onLoadIt }, 
                { tp: 'Button', id: 'removeit', tx: Global.ln.get('window-narrbattle-removecard'), ac: onRemoveIt }, 
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'itname', tx: Global.ln.get('window-narrbattle-cardname'), vr: 'detail' }, 
                { tp: 'TInput', id: 'itname', tx: '', vr: '' }, 
                { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrbattle-cardgraphic'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Custom', cont: this.ui.hcontainers['itgraphic'] }, 
                { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrbattle-cardat1'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Numeric', id: 'cardat1', mn: -10000, mx: 10000, st: 1, vl: 0 }, 
                { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrbattle-cardat2'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Numeric', id: 'cardat2', mn: -10000, mx: 10000, st: 1, vl: 0 }, 
                { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrbattle-cardat3'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Numeric', id: 'cardat3', mn: -10000, mx: 10000, st: 1, vl: 0 }, 
                { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrbattle-cardat4'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Numeric', id: 'cardat4', mn: -10000, mx: 10000, st: 1, vl: 0 }, 
                { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrbattle-cardat5'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Numeric', id: 'cardat5', mn: -10000, mx: 10000, st: 1, vl: 0 }, 
                { tp: 'Spacer', id: 'saveitem', ht: 40, ln: false }, 
                { tp: 'Button', id: 'saveitem', tx: Global.ln.get('window-narrbattle-setcard'), ac: onSetItem },                
            ]), 
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'iconsave', tx: Global.ln.get('window-narrbattle-savecards'), ac: this.onSaveItems }
            ]), 460));

        this.ui.listDbClick('items', onLoadIt);

        this.addForm(Global.ln.get('window-narrbattle-attributes'), this.ui.forge('attributes', [
            { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrbattle-attrabout'), vr: '' }, 
            { tp: 'Spacer', id: 'set', ht: 10, ln: false }, 
            { tp: 'Label', id: 'attr1', tx: Global.ln.get('window-narrbattle-attr1'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'attr1', tx: '', vr: '' },  
            { tp: 'Label', id: 'attr2', tx: Global.ln.get('window-narrbattle-attr2'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'attr2', tx: '', vr: '' },  
            { tp: 'Label', id: 'attr3', tx: Global.ln.get('window-narrbattle-attr3'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'attr3', tx: '', vr: '' },  
            { tp: 'Label', id: 'attr4', tx: Global.ln.get('window-narrbattle-attr4'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'attr4', tx: '', vr: '' },  
            { tp: 'Label', id: 'attr5', tx: Global.ln.get('window-narrbattle-attr5'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'attr5', tx: '', vr: '' },  
            { tp: 'Spacer', id: 'gapattr', ht: 160, ln: false }, 
            { tp: 'Button', id: 'setattr', tx: Global.ln.get('window-narrbattle-btattr'), ac: this.onSaveAttr },  
        ]));
        
        this.addForm(Global.ln.get('window-narrbattle-display'), this.ui.forge('settings', [
            { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrbattle-setabout'), vr: '' }, 
            { tp: 'Spacer', id: 'set', ht: 5, ln: false }, 
            { tp: 'Label', id: 'imgbgh', tx: Global.ln.get('window-narrbattle-imgbgh'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Custom', cont: this.ui.hcontainers['imgbgh'] }, 
            { tp: 'Label', id: 'imgbgv', tx: Global.ln.get('window-narrbattle-imgbgv'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Custom', cont: this.ui.hcontainers['imgbgv'] }, 
            { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrbattle-button'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Custom', cont: this.ui.hcontainers['imgbt'] }, 
            { tp: 'Label', id: 'imgcard', tx: Global.ln.get('window-narrbattle-card'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Custom', cont: this.ui.hcontainers['imgcard'] }, 
            { tp: 'Label', id: 'imgattr', tx: Global.ln.get('window-narrbattle-imgattr'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Custom', cont: this.ui.hcontainers['imgattr'] }, 
            { tp: 'Label', id: 'font', tx: Global.ln.get('window-narrbattle-font'), vr: 'detail' }, 
            { tp: 'Select', id: 'font', vl: [ ], sl: null }, 
            { tp: 'Label', id: 'fontsize', tx: Global.ln.get('window-narrbattle-fontsize'), vr: 'detail' },
            { tp: 'Numeric', id: 'fontsize', mn: 8, mx: 200, st: 1, vl: 20 }, 
            { tp: 'Label', id: 'fontc', tx: Global.ln.get('window-narrbattle-fontc'), vr: 'detail' }, 
            { tp: 'TInput', id: 'fontc', tx: '#FFFFFF', vr: '' },  
            { tp: 'Spacer', id: 'gap', ht: 10, ln: false }, 
            { tp: 'Button', id: 'set', tx: Global.ln.get('window-narrbattle-btset'), ac: this.onSaveSet },  
        ]));

        this.addForm(Global.ln.get('window-narrbattle-sounds'), this.ui.forge('sounds', [
            { tp: 'Label', id: 'soundsabout', tx: Global.ln.get('window-narrbattle-soundsabout'), vr: '' }, 
            { tp: 'Spacer', id: 'soundsabout', ht: 10, ln: false }, 
            { tp: 'Label', id: 'soundpick', tx: Global.ln.get('window-narrbattle-soundpick'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'soundpick', tx: '', vr: '' },  
            { tp: 'Label', id: 'soundwin', tx: Global.ln.get('window-narrbattle-soundwin'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'soundwin', tx: '', vr: '' },  
            { tp: 'Label', id: 'soundloose', tx: Global.ln.get('window-narrbattle-soundloose'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'soundloose', tx: '', vr: '' },  
            { tp: 'Label', id: 'soundtie', tx: Global.ln.get('window-narrbattle-soundtie'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'soundtie', tx: '', vr: '' },    
            { tp: 'Spacer', id: 'gapattr', ht: 210, ln: false }, 
            { tp: 'Button', id: 'setattr', tx: Global.ln.get('window-narrbattle-soundsave'), ac: this.onSaveSound },  
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
        this.ui.hcontainers['imgattr'].setWidth(960, [810, 70, 70]);
        this.ui.hcontainers['imgcard'].setWidth(960, [810, 70, 70]);
        this.ui.hcontainers['itgraphic'].setWidth(460, [300, 70, 70]);

        this.ui.inputs['itname'].text = '';
        this.ui.inputs['itgraphic'].text = '';
        this.ui.setSelectValue('mode', 'a');
        this.ui.inputs['attr1'].text = this.ui.inputs['attr2'].text = this.ui.inputs['attr3'].text = this.ui.inputs['attr4'].text = this.ui.inputs['attr4'].text = '';
        this.ui.inputs['imgbt'].text = '';
        this.ui.inputs['imgbgh'].text = '';
        this.ui.inputs['imgbgv'].text = '';
        this.ui.inputs['imgattr'].text = '';
        this.ui.inputs['imgcard'].text = '';
        this.ui.setSelectValue('font', null);
        this.ui.inputs['fontc'].text = '#FFFFFF';
        this.ui.numerics['fontsize'].value = GlobalPlayer.contraptions.bs['bs'].fontsize;
        this.ui.numerics['cardat1'].value = 0;
        this.ui.numerics['cardat2'].value = 0;
        this.ui.numerics['cardat3'].value = 0;
        this.ui.numerics['cardat4'].value = 0;
        this.ui.numerics['cardat5'].value = 0;
        this.ui.inputs['soundpick'].text = '';
        this.ui.inputs['soundwin'].text = '';
        this.ui.inputs['soundloose'].text = '';
        this.ui.inputs['soundtie'].text = '';
        
        var fnts:Array<Dynamic> = [ ];
        for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
        for (i in GlobalPlayer.mdata.fonts) fnts.push({ text: i.name, value: i.name });
        this.ui.setSelectOptions('font', fnts);

        if (GlobalPlayer.contraptions.bs.exists('bs')) {
            this.ui.inputs['imgbt'].text = GlobalPlayer.contraptions.bs['bs'].close;
            this.ui.inputs['imgbgh'].text = GlobalPlayer.contraptions.bs['bs'].horizontal;
            this.ui.inputs['imgbgv'].text = GlobalPlayer.contraptions.bs['bs'].vertical;
            this.ui.inputs['imgattr'].text = GlobalPlayer.contraptions.bs['bs'].attrbg;
            this.ui.inputs['imgcard'].text = GlobalPlayer.contraptions.bs['bs'].card;
            this.ui.setSelectValue('font', GlobalPlayer.contraptions.bs['bs'].font);
            this.ui.inputs['fontc'].text = GlobalPlayer.contraptions.bs['bs'].fontcolor;
            this.ui.numerics['fontsize'].value = GlobalPlayer.contraptions.bs['bs'].fontsize;
            for (i in 0...GlobalPlayer.contraptions.bs['bs'].attributes.length) {
                this.ui.inputs['attr' + (i+1)].text = GlobalPlayer.contraptions.bs['bs'].attributes[i];
            }
            this.ui.inputs['soundpick'].text = GlobalPlayer.contraptions.bs['bs'].soundpick;
            this.ui.inputs['soundwin'].text = GlobalPlayer.contraptions.bs['bs'].soundwin;
            this.ui.inputs['soundloose'].text = GlobalPlayer.contraptions.bs['bs'].soundloose;
            this.ui.inputs['soundtie'].text = GlobalPlayer.contraptions.bs['bs'].soundtie;
        }

        for (k in this._list.keys()) {
            this._list.remove(k);
        }
        for (k in GlobalPlayer.narrative.cards) {
            this._list[k.cardname] = k.clone();
        }
        this.showItems();
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'battleattr':
                this.ui.inputs['imgattr'].text = data['file'];
            case 'battleclose':
                this.ui.inputs['imgbt'].text = data['file'];
            case 'battleh':
                this.ui.inputs['imgbgh'].text = data['file'];
            case 'battlev':
                this.ui.inputs['imgbgv'].text = data['file'];
            case 'itgraphic':
                this.ui.inputs['itgraphic'].text = data['file'];
            case 'imgcard':
                this.ui.inputs['imgcard'].text = data['file'];
        }
    }

    private function showItems():Void {
        var list:Array<Dynamic> = [ ];
        for (k in this._list.keys()) {
            list.push({
                value: k, 
                text: k
            });
        }
        this.ui.setListValues('items', list);
        this.ui.setListSelectValue('items', null);
    }

    private function acImgbt(evt:Event):Void {
        this._ac('battleclose');
    }

    private function acImgbtdel(evt:Event):Void {
        this.ui.inputs['imgbt'].text = '';
    }

    private function acImgattr(evt:Event):Void {
        this._ac('battleattr');
    }

    private function acImgattrdel(evt:Event):Void {
        this.ui.inputs['imgattr'].text = '';
    }

    private function acImgbgh(evt:Event):Void {
        this._ac('battleh');
    }

    private function acImgbghdel(evt:Event):Void {
        this.ui.inputs['imgbgh'].text = '';
    }

    private function acImgbgv(evt:Event):Void {
        this._ac('battlev');
    }

    private function acImgbgvdel(evt:Event):Void {
        this.ui.inputs['imgbgv'].text = '';
    }

    private function acItgraphic(evt:Event):Void {
        this._ac('itgraphic');
    }

    private function acItgraphicdel(evt:Event):Void {
        this.ui.inputs['itgraphic'].text = '';
    }

    private function acImgcard(evt:Event):Void {
        this._ac('imgcard');
    }

    private function acImgcarddel(evt:Event):Void {
        this.ui.inputs['imgcard'].text = '';
    }

    private function onLoadIt(evt:Event = null):Void {
        if (this.ui.lists['items'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['items'].selectedItem.value)) {
                this.ui.inputs['itname'].text = this._list[this.ui.lists['items'].selectedItem.value].cardname;
                this.ui.inputs['itgraphic'].text = this._list[this.ui.lists['items'].selectedItem.value].cardgraphic;
                this.ui.numerics['cardat1'].value = this._list[this.ui.lists['items'].selectedItem.value].cardattributes[0];
                this.ui.numerics['cardat2'].value = this._list[this.ui.lists['items'].selectedItem.value].cardattributes[1];
                this.ui.numerics['cardat3'].value = this._list[this.ui.lists['items'].selectedItem.value].cardattributes[2];
                this.ui.numerics['cardat4'].value = this._list[this.ui.lists['items'].selectedItem.value].cardattributes[3];
                this.ui.numerics['cardat5'].value = this._list[this.ui.lists['items'].selectedItem.value].cardattributes[4];
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
            Global.showPopup(Global.ln.get('window-narrbattle-cards'), Global.ln.get('window-narrbattle-cardno'), 320, 150, Global.ln.get('default-ok'));
        } else {
            this._list[this.ui.inputs['itname'].text] = new BattleCardNarrative({
                cardname: this.ui.inputs['itname'].text, 
                cardgraphic: this.ui.inputs['itgraphic'].text, 
                cardattributes: [
                    Math.round(this.ui.numerics['cardat1'].value), 
                    Math.round(this.ui.numerics['cardat2'].value), 
                    Math.round(this.ui.numerics['cardat3'].value), 
                    Math.round(this.ui.numerics['cardat4'].value), 
                    Math.round(this.ui.numerics['cardat5'].value), 
                ],
            });
            this.ui.inputs['itname'].text = '';
            this.ui.inputs['itgraphic'].text = '';
            this.ui.numerics['cardat1'].value = this.ui.numerics['cardat2'].value = this.ui.numerics['cardat3'].value = this.ui.numerics['cardat4'].value = this.ui.numerics['cardat5'].value = 0;
            this.showItems();
        }
    }

    private function onSaveItems(evt:Event):Void {
        for (k in GlobalPlayer.narrative.cards.keys()) {
            GlobalPlayer.narrative.cards.remove(k);
        }
        for (k in this._list.keys()) {
            GlobalPlayer.narrative.cards[k] = this._list[k];
        }
        Global.ws.send('Movie/SaveNarrative', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.narrative.getData(), 
        ], this.onSaveReturn);
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-narrbattle-cards'), Global.ln.get('window-narrbattle-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-narrbattle-cards'), Global.ln.get('window-narrbattle-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-narrbattle-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-narrbattle-cards'), Global.ln.get('window-narrinv-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    /**
        Save display settings.
    **/
    private function onSaveSet(evt:Event):Void {
        if ((this.ui.inputs['imgbt'].text == '') || (this.ui.inputs['imgattr'].text == '') || (this.ui.inputs['imgcard'].text == '')) {
            Global.showPopup(Global.ln.get('window-narrbattle-display'), Global.ln.get('window-narrbattle-noclose'), 320, 150, Global.ln.get('default-ok'));
        } else if ((this.ui.inputs['imgbgh'].text == '') && (this.ui.inputs['imgbgv'].text == '')) {
            Global.showPopup(Global.ln.get('window-narrbattle-display'), Global.ln.get('window-narrbattle-nobg'), 320, 150, Global.ln.get('default-ok'));
        } else {
            if (GlobalPlayer.contraptions.bs.exists('bs')) {
                GlobalPlayer.contraptions.bs['bs'].font = this.ui.selects['font'].selectedItem.value;
                GlobalPlayer.contraptions.bs['bs'].fontcolor = StringStatic.colorHex(this.ui.inputs['fontc'].text, '#FFFFFF');
                GlobalPlayer.contraptions.bs['bs'].fontsize = Math.round(this.ui.numerics['fontsize'].value);
                GlobalPlayer.contraptions.bs['bs'].close = this.ui.inputs['imgbt'].text;
                GlobalPlayer.contraptions.bs['bs'].card = this.ui.inputs['imgcard'].text;
                GlobalPlayer.contraptions.bs['bs'].horizontal = this.ui.inputs['imgbgh'].text;
                GlobalPlayer.contraptions.bs['bs'].vertical = this.ui.inputs['imgbgv'].text;
                GlobalPlayer.contraptions.bs['bs'].attrbg = this.ui.inputs['imgattr'].text;
                GlobalPlayer.contraptions.bs['bs'].loadGraphics();
                Global.ws.send('Movie/SaveContraptions', [
                    'movie' => GlobalPlayer.movie.mvId, 
                    'data' => GlobalPlayer.contraptions.getData()
                ], this.onSaveSetReturn);
            } else {
                var contr:BattleContraption = new BattleContraption();
                if (contr.load({
                    id: 'bs', 
                    font: this.ui.selects['font'].selectedItem.value, 
                    fontcolor: StringStatic.colorHex(this.ui.inputs['fontc'].text, '#FFFFFF'),
                    fontsize: Math.round(this.ui.numerics['fontsize'].value), 
                    close: this.ui.inputs['imgbt'].text, 
                    horizontal: this.ui.inputs['imgbgh'].text, 
                    vertical: this.ui.inputs['imgbgv'].text, 
                    attrbg:  this.ui.inputs['imgattr'].text, 
                    card:  this.ui.inputs['imgcard'].text, 
                })) {
                    for (k in GlobalPlayer.contraptions.bs.keys()) {
                        GlobalPlayer.contraptions.bs[k].kill();
                        GlobalPlayer.contraptions.bs.remove(k);
                    }
                    GlobalPlayer.contraptions.bs['bs'] = contr;
                    Global.ws.send('Movie/SaveContraptions', [
                        'movie' => GlobalPlayer.movie.mvId, 
                        'data' => GlobalPlayer.contraptions.getData()
                    ], this.onSaveSetReturn);
                } else {
                    Global.showPopup(Global.ln.get('window-narrbattle-display'), Global.ln.get('window-narrbattle-errorset'), 320, 150, Global.ln.get('default-ok'));
                }
            }
        }
    }

    private function onSaveSetReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-narrbattle-display'), Global.ln.get('window-narrbattle-ersave1set'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-narrbattle-display'), Global.ln.get('window-narrbattle-ersaveset'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-narrbattle-oksaveset'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-narrbattle-display'), Global.ln.get('window-narrbattle-ersaveset'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    /**
        Save attribute settings.
    **/
    private function onSaveAttr(evt:Event):Void {
        var nm1:String = this.ui.inputs['attr1'].text;
        var nm2:String = this.ui.inputs['attr2'].text;
        var nm3:String = this.ui.inputs['attr3'].text;
        var nm4:String = this.ui.inputs['attr4'].text;
        var nm5:String = this.ui.inputs['attr5'].text;
        if ((nm1 == '') && (nm2 == '') && (nm3 == '') && (nm4 == '') && (nm5 == '')) {
            Global.showPopup(Global.ln.get('window-narrbattle-attributes'), Global.ln.get('window-narrbattle-noattributes'), 320, 150, Global.ln.get('default-ok'));
        } else {
            if (!GlobalPlayer.contraptions.bs.exists('bs')) {
                GlobalPlayer.contraptions.bs['bs'] = new BattleContraption();
            }
            while (GlobalPlayer.contraptions.bs['bs'].attributes.length > 0) {
                GlobalPlayer.contraptions.bs['bs'].attributes.shift();
            }
            if (nm1 != '') GlobalPlayer.contraptions.bs['bs'].attributes.push(nm1);
            if (nm2 != '') GlobalPlayer.contraptions.bs['bs'].attributes.push(nm2);
            if (nm3 != '') GlobalPlayer.contraptions.bs['bs'].attributes.push(nm3);
            if (nm4 != '') GlobalPlayer.contraptions.bs['bs'].attributes.push(nm4);
            if (nm5 != '') GlobalPlayer.contraptions.bs['bs'].attributes.push(nm5);
            Global.ws.send('Movie/SaveContraptions', [
                'movie' => GlobalPlayer.movie.mvId, 
                'data' => GlobalPlayer.contraptions.getData()
            ], this.onSaveAttrReturn);
        }
    }

    private function onSaveAttrReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-narrbattle-attributes'), Global.ln.get('window-narrbattle-ersave1set'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-narrbattle-attributes'), Global.ln.get('window-narrbattle-ersaveset'), 320, 150, Global.ln.get('default-ok'));
            } else {
                this.ui.inputs['attr1'].text = this.ui.inputs['attr2'].text = this.ui.inputs['attr3'].text = this.ui.inputs['attr4'].text = this.ui.inputs['attr4'].text = '';
                for (i in 0...GlobalPlayer.contraptions.bs['bs'].attributes.length) {
                    this.ui.inputs['attr' + (i+1)].text = GlobalPlayer.contraptions.bs['bs'].attributes[i];
                }
                Global.showMsg(Global.ln.get('window-narrbattle-oksaveset'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-narrbattle-attributes'), Global.ln.get('window-narrbattle-ersaveset'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    /**
        Save sound settings.
    **/
    private function onSaveSound(evt:Event):Void {
        if (!GlobalPlayer.contraptions.bs.exists('bs')) {
            GlobalPlayer.contraptions.bs['bs'] = new BattleContraption();
        }
        GlobalPlayer.contraptions.bs['bs'].soundpick = this.ui.inputs['soundpick'].text;
        GlobalPlayer.contraptions.bs['bs'].soundwin = this.ui.inputs['soundwin'].text;
        GlobalPlayer.contraptions.bs['bs'].soundloose = this.ui.inputs['soundloose'].text;
        GlobalPlayer.contraptions.bs['bs'].soundtie = this.ui.inputs['soundtie'].text;
        Global.ws.send('Movie/SaveContraptions', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.contraptions.getData()
        ], this.onSaveSoundReturn);
    }

    private function onSaveSoundReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-narrbattle-sounds'), Global.ln.get('window-narrbattle-ersave1set'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-narrbattle-sounds'), Global.ln.get('window-narrbattle-ersaveset'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-narrbattle-oksaveset'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-narrbattle-sounds'), Global.ln.get('window-narrbattle-ersaveset'), 320, 150, Global.ln.get('default-ok'));
        }
    }

}