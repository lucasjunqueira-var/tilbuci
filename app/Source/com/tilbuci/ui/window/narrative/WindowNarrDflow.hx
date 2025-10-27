/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.narrative;

/** OPENFL **/
import com.tilbuci.contraptions.DflowContraption;
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

class WindowNarrDflow extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-narrdflow-title'), 1000, 580, true, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {

        this.ui.createHContainer('imgbt');
        this.ui.createTInput('imgbt', '', '', this.ui.hcontainers['imgbt'], false);
        this.ui.createIconButton('imgbt', this.acImgbt, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgbt'], false);
        this.ui.createIconButton('imgimgbtdel', this.acImgbtdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgbt'], false);
        this.ui.inputs['imgbt'].enabled = false;
        
        this.addForm(Global.ln.get('window-narrdflow-settings'), this.ui.forge('settings', [
            { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrdflow-setabout'), vr: '' }, 
            { tp: 'Spacer', id: 'set', ht: 10, ln: false }, 
            { tp: 'Label', id: 'set', tx: Global.ln.get('window-narrdflow-button'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Custom', cont: this.ui.hcontainers['imgbt'] }, 
            { tp: 'Label', id: 'position', tx: Global.ln.get('window-narrdflow-position'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'position', vl: [
                { value: 'top', text: Global.ln.get('window-narrdflow-top') }, 
                { value: 'topleft', text: Global.ln.get('window-narrdflow-topleft') }, 
                { value: 'topright', text: Global.ln.get('window-narrdflow-topright') }, 
                { value: 'center', text: Global.ln.get('window-narrdflow-center') }, 
                { value: 'centerleft', text: Global.ln.get('window-narrdflow-centerleft') }, 
                { value: 'centerright', text: Global.ln.get('window-narrdflow-centerright') },
                { value: 'bottom', text: Global.ln.get('window-narrdflow-bottom') }, 
                { value: 'bottomleft', text: Global.ln.get('window-narrdflow-bottomleft') }, 
                { value: 'bottomright', text: Global.ln.get('window-narrdflow-bottomright') }, 
            ], sl: 'center' },
            { tp: 'Label', id: 'gap', tx: Global.ln.get('window-narrdflow-gap'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Numeric', id: 'gap', mn: 0, mx: 1000, st: 1, vl: 10 },
            { tp: 'Label', id: 'font', tx: Global.ln.get('window-narrdflow-font'), vr: 'detail' }, 
            { tp: 'Select', id: 'font', vl: [ ], sl: null }, 
            { tp: 'Label', id: 'fontsize', tx: Global.ln.get('window-narrdflow-fontsize'), vr: 'detail' },
            { tp: 'Numeric', id: 'fontsize', mn: 8, mx: 200, st: 1, vl: 20 }, 
            { tp: 'Label', id: 'fontc', tx: Global.ln.get('window-narrdflow-fontc'), vr: 'detail' }, 
            { tp: 'TInput', id: 'fontc', tx: '#FFFFFF', vr: '' },  
            { tp: 'Spacer', id: 'gap', ht: 110, ln: false }, 
            { tp: 'Button', id: 'set', tx: Global.ln.get('window-narrdflow-btset'), ac: this.onSaveSet },  
        ]));

        this.addForm(Global.ln.get('window-narrdflow-flow'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'scenes', tx: Global.ln.get('window-narrdflow-scenes'), vr: '' }, 
                { tp: 'List', id: 'scenes', vl: [ ], sl: null, ht: 435, ch: sceneSelected }, 
                { tp: 'Button', id: 'scenes', tx: Global.ln.get('window-narrdflow-loadscene'), ac: onScene }, 
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'options', tx: Global.ln.get('window-narrdflow-options'), vr: '' }, 
                { tp: 'List', id: 'options', vl: [ ], sl: null, ht: 435 }, 
                { tp: 'Button', id: 'options', tx: Global.ln.get('window-narrdflow-loadoption'), ac: onOption },                
            ])));

        super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        this.ui.hcontainers['imgbt'].setWidth(960, [810, 70, 70]);
        var fnts:Array<Dynamic> = [ ];
        for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
        for (i in GlobalPlayer.mdata.fonts) fnts.push({ text: i.name, value: i.name });
        this.ui.setSelectOptions('font', fnts);

        if (GlobalPlayer.contraptions.dflow.exists('dflow')) {
            this.ui.inputs['imgbt'].text = GlobalPlayer.contraptions.dflow['dflow'].buton;
            this.ui.setSelectValue('position', GlobalPlayer.contraptions.dflow['dflow'].position);
            this.ui.numerics['gap'].value = GlobalPlayer.contraptions.dflow['dflow'].gap;
            this.ui.setSelectValue('font', GlobalPlayer.contraptions.dflow['dflow'].font);
            this.ui.numerics['fontsize'].value = GlobalPlayer.contraptions.dflow['dflow'].fontsize;
            this.ui.inputs['fontc'].text = StringStatic.colorHex(GlobalPlayer.contraptions.dflow['dflow'].fontcolor, '#FFFFFF');
        }

        this.ui.setListValues('scenes', [ ]);
        this.ui.setListValues('options', [ ]);

        Global.ws.send('Scene/ListDflow', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
    }

    /**
        The scenes list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-narrdflow-title'), Global.ln.get('window-narrdflow-nolist'), 300, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else{
            if (ld.map['e'] == 0) {

                trace ('recuperado', ld.map);

                var ar:Array<Dynamic> = cast ld.map['list'];
                if (ar.length == 0) {
                    Global.showMsg(Global.ln.get('window-narrdflow-nooption'));
                } else {
                    var list:Array<Dynamic> = [ ];
                    for (i in ar) {
                        var sdo:SceneDFOptions = cast i;
                        if (sdo != null) {
                            list.push({
                                text: sdo.title, 
                                value: sdo, 
                            });
                        }
                    }
                    this.ui.setListValues('scenes', list);
                }
            } else {
                this.ui.createWarning(Global.ln.get('window-narrdflow-title'), Global.ln.get('window-narrdflow-nolist'), 300, 180, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'dflowbrowseimgbt':
                this.ui.inputs['imgbt'].text = data['file'];
        }
    }

    private function acImgbt(evt:Event):Void {
        this._ac('dflowbrowseimgbt');
    }

    private function acImgbtdel(evt:Event):Void {
        this.ui.inputs['imgbt'].text = '';
    }

    /**
        Save display settings.
    **/
    private function onSaveSet(evt:Event):Void {
        if (this.ui.inputs['imgbt'].text == '') {
            Global.showPopup(Global.ln.get('window-narrdflow-title'), Global.ln.get('window-narrdflow-nobutton'), 320, 150, Global.ln.get('default-ok'));
        } else {
            var contr:DflowContraption = new DflowContraption();
            if (contr.load({
                id: 'dflow', 
                font: this.ui.selects['font'].selectedItem.value, 
                fontcolor: StringStatic.colorHex(this.ui.inputs['fontc'].text, '#FFFFFF'),
                fontsize: Math.round(this.ui.numerics['fontsize'].value), 
                buton: this.ui.inputs['imgbt'].text, 
                position: this.ui.selects['position'].selectedItem.value, 
                gap: Math.round(this.ui.numerics['gap'].value), 
            })) {
                for (k in GlobalPlayer.contraptions.dflow.keys()) {
                    GlobalPlayer.contraptions.dflow[k].kill();
                    GlobalPlayer.contraptions.dflow.remove(k);
                }
                GlobalPlayer.contraptions.dflow['dflow'] = contr;
                Global.ws.send('Movie/SaveContraptions', [
                    'movie' => GlobalPlayer.movie.mvId, 
                    'data' => GlobalPlayer.contraptions.getData()
                ], this.onSaveReturn);
            } else {
                Global.showPopup(Global.ln.get('window-narrdflow-title'), Global.ln.get('window-narrdflow-errorset'), 320, 150, Global.ln.get('default-ok'));
            }
            
        }
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-narrdflow-title'), Global.ln.get('window-narrdflow-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-narrdflow-title'), Global.ln.get('window-narrdflow-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showPopup(Global.ln.get('window-narrdflow-title'), Global.ln.get('window-narrdflow-oksave'), 320, 150, Global.ln.get('default-ok'));
            }
        } else {
            Global.showPopup(Global.ln.get('window-narrdflow-title'), Global.ln.get('window-narrdflow-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    private function sceneSelected(evt:Event):Void {
        if (this.ui.lists['scenes'].selectedItem != null) {
            var list:Array<Dynamic> = [ ];
            var sco:SceneDFOptions = cast this.ui.lists['scenes'].selectedItem.value;
            if (sco != null) {
                if ((sco.df1[0] != '') && (sco.df1[1] != '')) list.push({ text: sco.df1[0], value: sco.df1[1] });
                if ((sco.df2[0] != '') && (sco.df2[1] != '')) list.push({ text: sco.df2[0], value: sco.df2[1] });
                if ((sco.df3[0] != '') && (sco.df3[1] != '')) list.push({ text: sco.df3[0], value: sco.df3[1] });
                if ((sco.df4[0] != '') && (sco.df4[1] != '')) list.push({ text: sco.df4[0], value: sco.df4[1] });
            }
            this.ui.setListValues('options', list);
        }
    }

    private function onScene(evt:Event):Void {
        if (this.ui.lists['scenes'].selectedItem != null) {
            var sco:SceneDFOptions = cast this.ui.lists['scenes'].selectedItem.value;
            if (sco != null) {
                GlobalPlayer.area.imgSelect();
                GlobalPlayer.movie.loadScene(sco.id);
            }
        }
    }

    private function onOption(evt:Event):Void {
        if (this.ui.lists['options'].selectedItem != null) {
            GlobalPlayer.area.imgSelect();
            GlobalPlayer.movie.loadScene(this.ui.lists['options'].selectedItem.value);
        }
    }

}

typedef SceneDFOptions = {
    var id: String;
    var title:String;
    var df1:Array<String>;
    var df2:Array<String>;
    var df3:Array<String>;
    var df4:Array<String>;
}