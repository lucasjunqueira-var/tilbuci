/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.contraptions;

/** OPENFL **/
import com.tilbuci.contraptions.InterfaceContraption;
import com.tilbuci.ui.base.InterfaceContainer;
import com.tilbuci.contraptions.FormContraption;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.contraptions.CoverContraption;
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

class WindowContrInterf extends PopupWindow {

    // contraptions list
    private var _list:Map<String, InterfaceContraption> = [ ];

    // last received number of frames
    private var _lastframes:Int = 1;

    //last received framne time
    private var _lastfrtime:Int = 250;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-contrinterf-title'), 1000, 710, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // background input
        this.ui.createHContainer('background');
        this.ui.createTInput('background', '', '', this.ui.hcontainers['background'], false);
        this.ui.createIconButton('background', this.acBackground, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['background'], false);
        this.ui.createIconButton('backgrounddel', this.acBackgrounddel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['background'], false);
        this.ui.inputs['background'].enabled = false;
        this.ui.hcontainers['background'].setWidth(450, [340, 50, 50]);
        this.ui.forge('background', [
            { tp: 'Label', id: 'backgroundset', tx: Global.ln.get('window-contrinterf-background'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['background'] }, 
            { tp: 'Spacer', id: 'backgroundset', ht: 10, ln: false }, 
            { tp: 'Button', id: 'backgroundset', tx: Global.ln.get('window-contrinterf-setbutton'), ac: setElement },
        ]);


        // spritemap input
        this.ui.createHContainer('spritemap');
        this.ui.createTInput('spritemap', '', '', this.ui.hcontainers['spritemap'], false);
        this.ui.createIconButton('spritemap', this.acBtsm, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['spritemap'], false);
        this.ui.createIconButton('spritemap', this.acBtsmdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['spritemap'], false);
        this.ui.inputs['spritemap'].enabled = false;
        this.ui.hcontainers['spritemap'].setWidth(450, [340, 50, 50]);
        this.ui.createHContainer('formelsmpos');
        this.ui.createLabel('formelsmposx', 'X', 'detail', this.ui.hcontainers['formelsmpos']);
        this.ui.createNumeric('formelsmposx', -3840, 3840, 10, 0, this.ui.hcontainers['formelsmpos']);
        this.ui.createLabel('formelsmposy', 'Y', 'detail', this.ui.hcontainers['formelsmpos']);
        this.ui.createNumeric('formelsmposy', -3840, 3840, 10, 0, this.ui.hcontainers['formelsmpos']);
        this.ui.forge('spritemap', [
            { tp: 'Label', id: 'spritemap', tx: Global.ln.get('window-contrinterf-smap'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['spritemap'] }, 
            { tp: 'Label', id: 'smaction', tx: Global.ln.get('window-contrinterf-smapac'), vr: '' },
            { tp: 'TInput', id: 'smaction', vl: '', vr: '' }, 
            { tp: 'Spacer', id: 'spritemap', ht: 10, ln: false }, 
            { tp: 'Label', id: 'formelsmpos', tx: Global.ln.get('window-contrinterf-formelposition'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['formelsmpos'] }, 
            { tp: 'Spacer', id: 'formelsmpos', ht: 10, ln: false }, 
            { tp: 'Button', id: 'btsmset', tx: Global.ln.get('window-contrinterf-setbutton'), ac: setElement },
        ]);

        // text input
        this.ui.createHContainer('formeltxpos');
        this.ui.createLabel('formeltxposx', 'X', 'detail', this.ui.hcontainers['formeltxpos']);
        this.ui.createNumeric('formeltxposx', -3840, 3840, 10, 0, this.ui.hcontainers['formeltxpos']);
        this.ui.createLabel('formeltxposy', 'Y', 'detail', this.ui.hcontainers['formeltxpos']);
        this.ui.createNumeric('formeltxposy', -3840, 3840, 10, 0, this.ui.hcontainers['formeltxpos']);
        this.ui.forge('txset', [
            { tp: 'Label', id: 'txset', tx: Global.ln.get('window-contrinterf-text'), vr: '' },
            { tp: 'Label', id: 'txuse', tx: Global.ln.get('window-contrinterf-use'), vr: 'detail' },
            { tp: 'Toggle', id: 'txuse', vl: false },
            { tp: 'Label', id: 'txfont', tx: Global.ln.get('window-contrinterf-font'), vr: 'detail' },
            { tp: 'Select', id: 'txfont', vl: [ ], sl: null }, 
            { tp: 'Label', id: 'txsize', tx: Global.ln.get('window-contrinterf-fontsize'), vr: 'detail' },
            { tp: 'Numeric', id: 'txsize', mn: 1, mx: 1000, st: 1, vl: 12 }, 
            { tp: 'Label', id: 'txcolor', tx: Global.ln.get('window-contrinterf-fontcolor'), vr: 'detail' },
            { tp: 'TInput', id: 'txcolor', vl: '#FFFFFF', vr: '' }, 
            { tp: 'Label', id: 'txdeco', tx: Global.ln.get('window-contrinterf-fontdeco'), vr: 'detail' },
            { tp: 'Select', id: 'txdeco', vl: [
                { text: Global.ln.get('window-contrinterf-fontdeco-normal'), value: 'normal' }, 
                { text: Global.ln.get('window-contrinterf-fontdeco-bold'), value: 'bold' }, 
                { text: Global.ln.get('window-contrinterf-fontdeco-italic'), value: 'italic' }, 
                { text: Global.ln.get('window-contrinterf-fontdeco-bolditalic'), value: 'bolditalic' }, 
            ], sl: null },
            { tp: 'Label', id: 'txalign', tx: Global.ln.get('window-contrinterf-fontalign'), vr: 'detail' },
            { tp: 'Select', id: 'txalign', vl: [
                { text: Global.ln.get('window-contrinterf-fontalign-left'), value: 'left' }, 
                { text: Global.ln.get('window-contrinterf-fontalign-right'), value: 'right' }, 
                { text: Global.ln.get('window-contrinterf-fontalign-center'), value: 'center' }, 
            ], sl: null },
            { tp: 'Spacer', id: 'txwidth', ht: 10, ln: false }, 
            { tp: 'Label', id: 'txwidth', tx: Global.ln.get('window-contrinterf-width'), vr: '' },
            { tp: 'Numeric', id: 'txwidth', mn: 1, mx: 10000, st: 10, vl: 100 }, 
            { tp: 'Label', id: 'formeltxpos', tx: Global.ln.get('window-contrinterf-formelposition'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['formeltxpos'] },
            { tp: 'Spacer', id: 'txset', ht: 10, ln: false }, 
            { tp: 'Button', id: 'txset', tx: Global.ln.get('window-contrinterf-setbutton'), ac: setElement },
        ]);

        // button elements
        this.ui.createHContainer('formel');
        this.ui.createTInput('formel', '', '', this.ui.hcontainers['formel'], false);
        this.ui.createIconButton('formel', this.acElem, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['formel'], false);
        this.ui.createIconButton('formeldel', this.acElemdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['formel'], false);
        this.ui.inputs['formel'].enabled = false;
        this.ui.hcontainers['formel'].setWidth(450, [340, 50, 50]);
        this.ui.createHContainer('formelpos');
        this.ui.createLabel('formelposx', 'X', 'detail', this.ui.hcontainers['formelpos']);
        this.ui.createNumeric('formelposx', -3840, 3840, 10, 0, this.ui.hcontainers['formelpos']);
        this.ui.createLabel('formelposy', 'Y', 'detail', this.ui.hcontainers['formelpos']);
        this.ui.createNumeric('formelposy', -3840, 3840, 10, 0, this.ui.hcontainers['formelpos']);
        this.ui.forge('formel', [
            { tp: 'Label', id: 'btset', tx: Global.ln.get('window-contrinterf-btgraph'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['formel'] }, 
            { tp: 'Label', id: 'formelac', tx: Global.ln.get('window-contrinterf-elac'), vr: '' },
            { tp: 'TInput', id: 'formelac', tx: '', vr: '' },  
            { tp: 'Label', id: 'formelposition', tx: Global.ln.get('window-contrinterf-formelposition'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['formelpos'] }, 
            { tp: 'Spacer', id: 'formel', ht: 10, ln: false }, 
            { tp: 'Button', id: 'formelbt', tx: Global.ln.get('window-contrinterf-setbutton'), ac: setElement },
        ]);

        // elements
        this.ui.createHContainer('elements');
        this.ui.createButton('elementadd', Global.ln.get('window-contrinterf-eladd'), onElAdd, this.ui.hcontainers['elements']);
        this.ui.createButton('elementrem', Global.ln.get('window-contrinterf-elrem'), onElRem, this.ui.hcontainers['elements']);

        // creating columns
        this.addForm(Global.ln.get('window-kfmanage-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'registered', tx: Global.ln.get('window-contrinterf-registered'), vr: '' }, 
                { tp: 'List', id: 'registered', vl: [ ], sl: null, ht: 150 }, 
                { tp: 'Button', id: 'load', tx: Global.ln.get('window-contrinterf-load'), ac: loadContr }, 
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-contrinterf-remove'), ac: removeContr },
                { tp: 'Spacer', id: 'add', ht: 15, ln: true }, 
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-contrinterf-name'), vr: 'detail' }, 
                { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
                { tp: 'Label', id: 'elements', tx: Global.ln.get('window-contrinterf-elements'), vr: 'detail' }, 
                { tp: 'List', id: 'elements', vl: [ ], sl: null, ht: 190, ch: onElLoad }, 
                { tp: 'Custom', cont: this.ui.hcontainers['elements'] },
                { tp: 'Button', id: 'add', tx: Global.ln.get('window-contrinterf-add'), ac: addContr },
            ]), 
            this.ui.forge('rightcol', [
                
            ]),
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'save', tx: Global.ln.get('window-contrinterf-save'), ac: saveContr },
            ])
            , 610));
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
        for (contk in GlobalPlayer.contraptions.interf) {
            this._list[contk.id] = contk.clone();
        }
        this.clear();
        this.ui.hcontainers['elements'].setWidth(460);
        this.clearElements();
        var fnts:Array<Dynamic> = [ ];
        for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
        for (i in GlobalPlayer.mdata.fonts) fnts.push({ text: i.name, value: i.name });
        this.ui.setSelectOptions('txfont', fnts);
    }

    private function clearElements():Void {
        var list:Array<Dynamic> = [ ];
        list.push({
            text: Global.ln.get('window-contrinterf-namebg'), 
            value: {
                type: 'background',
                file: '',
                action: '', 
                x: 0, 
                y: 0, 
                options: '', 
            }
        });
        list.push({
            text: Global.ln.get('window-contrinterf-nameanim'), 
            value: {
                type: 'spritemap',
                file: '',
                action: '', 
                x: 0, 
                y: 0, 
                options: '', 
            }
        });
        list.push({
            text: Global.ln.get('window-contrinterf-nametx'), 
            value: {
                type: 'text',
                file: '',
                action: '', 
                x: 0, 
                y: 0, 
                options: '', 
            }
        });
        this.ui.setListValues('elements', list);
        this.ui.setListSelectValue('elements', null);
    }

    private function redrawElementsList():Void {
        var list:Array<Dynamic> = [ ];
        for (el in this.ui.lists['elements'].dataProvider) {
            list.push({ text: el.text, value: el.value });
        }
        this.ui.setListValues('elements', list);
        this.ui.setListSelectValue('elements', null);
        this.ui.containers['rightcol'].removeChildren();
    }

    /**
        Clears current layout data.
    **/
    private function clear():Void {
        var list:Array<Dynamic> = [ ];
        for (cont in this._list) {
            list.push({text: cont.id, value: cont});
        }
        this.ui.setListValues('registered', list);
        this.ui.setListSelectValue('registered', null);
        this.ui.inputs['name'].text = '';
        this.clearElements();
    }

    private function loadContr(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.text)) {
                this.ui.inputs['name'].text = this.ui.lists['registered'].selectedItem.text;
                var list:Array<Dynamic> = [ ];
                var cont:InterfaceContraption = cast this.ui.lists['registered'].selectedItem.value;
                for (el in cont.elem) {
                    var elname:String = '';
                    switch (el.type) {
                        case 'background': elname = Global.ln.get('window-contrinterf-namebg');
                        case 'spritemap': elname = Global.ln.get('window-contrinterf-nameanim');
                        case 'text': elname = Global.ln.get('window-contrinterf-nametx');
                        default: elname = Global.ln.get('window-contrinterf-namebutton');
                    }
                    list.push({ text: elname, value: el });
                }
                this.ui.setListValues('elements', list);
                this.ui.setListSelectValue('elements', null);
                this.ui.containers['rightcol'].removeChildren();
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'intbackground':
                this.ui.inputs['background'].text = data['file'];
            case 'intanim':
                this.ui.inputs['spritemap'].text = data['file'];
                this._lastframes = Std.parseInt(data['frames']);
                this._lastfrtime = Std.parseInt(data['frtime']);
            case 'intimage':
                this.ui.inputs['formel'].text = data['file'];
        }
    }

    private function removeContr(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.text)) {
                this._list[this.ui.lists['registered'].selectedItem.text].kill();
                this._list.remove(this.ui.lists['registered'].selectedItem.text);
                this.clear();
            }
        }
    }

    private function saveContr(evt:Event):Void {
        for (cont in GlobalPlayer.contraptions.forms.keys()) {
            GlobalPlayer.contraptions.forms[cont].kill();
            GlobalPlayer.contraptions.forms.remove(cont);
        }
        for (cont in this._list.keys()) {
            GlobalPlayer.contraptions.interf[cont] = this._list[cont].clone();
        }
        this.clear();
        Global.ws.send('Movie/SaveContraptions', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.contraptions.getData()
        ], this.onSaveReturn);
    }

    private function addContr(evt:Event):Void {
        if (this.ui.inputs['name'].text.length > 3) {
            var okbt:Bool = true;
            var list:Array<Dynamic> = [ ];
            for (el in this.ui.lists['elements'].dataProvider) list.push(el.value);
            var contr:InterfaceContraption;
            if (this._list.exists(this.ui.inputs['name'].text)) {
                contr = this._list[this.ui.inputs['name'].text];
            } else {
                contr = new InterfaceContraption();
            }
            if (contr.load({
                id: this.ui.inputs['name'].text, 
                elem: list
            })) {
                this._list[this.ui.inputs['name'].text] = contr;
                this.ui.inputs['name'].text = '';
                this.clear();
            }    
        } else {
            Global.showPopup(Global.ln.get('window-contrinterf-title'), Global.ln.get('window-contrinterf-noname'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    private function acBackground(evt:Event):Void {
        this._ac('intbackground');
    }

    private function acBackgrounddel(evt:Event):Void {
        this.ui.inputs['background'].text = '';
    }

    private function acBtsm(evt:Event):Void {
        this._ac('intanim');
    }

    private function acBtsmdel(evt:Event):Void {
        this.ui.inputs['spritemap'].text = '';
    }

    private function acElem(evt:Event):Void {
        this._ac('intimage');
    }

    private function acElemdel(evt:Event):Void {
        this.ui.inputs['formel'].text = '';
    }

    private function onElAdd(evt:Event):Void {
        var list:Array<Dynamic> = [ ];
        for (el in this.ui.lists['elements'].dataProvider) {
            list.push({
                text: el.text, 
                value: el.value
            });
        }
        list.push({
            text: Global.ln.get('window-contrinterf-namebutton'), 
            value: {
                type: '',
                file: '',
                action: '', 
                x: 0, 
                y: 0, 
                options: '', 
            }
        });
        this.ui.setListValues('elements', list);
        this.ui.setListSelectValue('elements', null);
        this.ui.containers['rightcol'].removeChildren();
    }

    private function onElLoad(evt:Event):Void {
        if (this.ui.lists['elements'].selectedItem != null) {
            this.ui.containers['rightcol'].removeChildren();
            switch (this.ui.lists['elements'].selectedItem.value.type) {
                case 'background':
                    this.ui.containers['rightcol'].addChild(this.ui.containers['background']);
                    this.ui.labels['backgroundset'].width = this.ui.buttons['backgroundset'].width = 450;
                    this.ui.inputs['background'].text = this.ui.lists['elements'].selectedItem.value.file;
                case 'spritemap':
                    this.ui.containers['rightcol'].addChild(this.ui.containers['spritemap']);
                    this.ui.labels['formelsmpos'].width = this.ui.labels['spritemap'].width = this.ui.labels['smaction'].width = this.ui.inputs['smaction'].width = this.ui.buttons['btsmset'].width = 450;
                    this.ui.hcontainers['formelsmpos'].setWidth(450, [ 60, 145, 60, 145 ]);
                    this.ui.inputs['spritemap'].text = this.ui.lists['elements'].selectedItem.value.file;
                    this.ui.inputs['smaction'].text = this.ui.lists['elements'].selectedItem.value.action;
                    this.ui.numerics['formelsmposx'].value = this.ui.lists['elements'].selectedItem.value.x;
                    this.ui.numerics['formelsmposy'].value = this.ui.lists['elements'].selectedItem.value.y;
                    if (this.ui.lists['elements'].selectedItem.value.options != '') {
                        var opt:Array<String> = this.ui.lists['elements'].selectedItem.value.options.split(';');
                        if (opt.length == 2) {
                            this._lastframes = Std.parseInt(opt[0]);
                            this._lastfrtime = Std.parseInt(opt[1]);
                        }
                    }
                case 'text':
                    this.ui.containers['rightcol'].addChild(this.ui.containers['txset']);
                    this.ui.labels['formeltxpos'].width = this.ui.labels['txset'].width = this.ui.buttons['txset'].width = 450;
                    this.ui.hcontainers['formeltxpos'].setWidth(450, [ 60, 145, 60, 145 ]);
                    this.ui.numerics['formeltxposx'].value = this.ui.lists['elements'].selectedItem.value.x;
                    this.ui.numerics['formeltxposy'].value = this.ui.lists['elements'].selectedItem.value.y;
                    this.ui.labels['txuse'].width = this.ui.labels['txfont'].width = this.ui.selects['txfont'].width = 450;
                    this.ui.labels['txsize'].width = this.ui.numerics['txsize'].width = 450;
                    this.ui.labels['txcolor'].width = this.ui.inputs['txcolor'].width = 450;
                    this.ui.labels['txalign'].width = this.ui.selects['txalign'].width = 450;
                    this.ui.labels['txdeco'].width = this.ui.selects['txdeco'].width = 450;
                    this.ui.labels['txwidth'].width = this.ui.numerics['txwidth'].width = 450;
                    this.ui.toggles['txuse'].selected = false;
                    if (this.ui.lists['elements'].selectedItem.value.options != '') {
                        var opt:Array<String> = this.ui.lists['elements'].selectedItem.value.options.split(';');
                        if (opt.length == 7) {
                            this.ui.toggles['txuse'].selected = true;
                            this.ui.numerics['txwidth'].value = Std.parseInt(opt[0]);
                            this.ui.setSelectValue('txfont', opt[1]);
                            this.ui.numerics['txsize'].value = Std.parseInt(opt[2]);
                            this.ui.inputs['txcolor'].text = opt[3];
                            if ((opt[4] == 'true') && (opt[5] == 'true')) {
                                this.ui.setSelectValue('txdeco', 'bolditalic');
                            } else if (opt[4] == 'true') {
                                this.ui.setSelectValue('txdeco', 'bold');
                            } else if (opt[5] == 'true') {
                                this.ui.setSelectValue('txdeco', 'italic');
                            } else {
                                this.ui.setSelectValue('txdeco', 'normal');
                            }
                            this.ui.setSelectValue('txalign', opt[6]);
                        }
                    }
                default:
                    this.ui.containers['rightcol'].addChild(this.ui.containers['formel']);
                    this.ui.hcontainers['formelpos'].setWidth(450, [ 60, 145, 60, 145 ]);
                    this.ui.numerics['formelposx'].value = this.ui.lists['elements'].selectedItem.value.x;
                    this.ui.numerics['formelposy'].value = this.ui.lists['elements'].selectedItem.value.y;
                    this.ui.labels['btset'].width = this.ui.labels['formelac'].width = this.ui.inputs['formelac'].width = 450;
                    this.ui.labels['formelposition'].width = this.ui.buttons['formelbt'].width = 450;
                    this.ui.inputs['formel'].text = this.ui.lists['elements'].selectedItem.value.file;
                    this.ui.inputs['formelac'].text = this.ui.lists['elements'].selectedItem.value.action;
                    this.ui.numerics['formelposx'].value = this.ui.lists['elements'].selectedItem.value.x;
                    this.ui.numerics['formelposy'].value = this.ui.lists['elements'].selectedItem.value.y;
            }
        }
    }

    private function onElRem(evt:Event):Void {
        if (this.ui.lists['elements'].selectedItem != null) {
            switch (this.ui.lists['elements'].selectedItem.value.type) {
                case 'background': // nothing to do
                case 'spritemap': // nothing to do
                case 'text': // nothing to do
                default:
                    var list:Array<Dynamic> = [ ];
                    for (i in 0...this.ui.lists['elements'].dataProvider.length) {
                        if (i != this.ui.lists['elements'].selectedIndex) {
                            var el = this.ui.lists['elements'].dataProvider.get(i);
                            list.push({ text: el.text, value: el.value });
                        }
                    }
                    this.ui.setListValues('elements', list);
                    this.ui.setListSelectValue('elements', null);
                    this.ui.containers['rightcol'].removeChildren();
            }
        }
    }

    private function setElement(evt:Event):Void {
        if (this.ui.lists['elements'].selectedItem != null) {
            switch (this.ui.lists['elements'].selectedItem.value.type) {
                case 'background':
                    this.ui.lists['elements'].selectedItem.value.file = this.ui.inputs['background'].text;
                    this.redrawElementsList();
                case 'spritemap':
                    this.ui.lists['elements'].selectedItem.value.file = this.ui.inputs['spritemap'].text;
                    this.ui.lists['elements'].selectedItem.value.options = this._lastframes + ';' + this._lastfrtime;
                    this.ui.lists['elements'].selectedItem.value.action = this.ui.inputs['smaction'].text;
                    this.ui.lists['elements'].selectedItem.value.x = Math.round(this.ui.numerics['formelsmposx'].value);
                    this.ui.lists['elements'].selectedItem.value.y = Math.round(this.ui.numerics['formelsmposy'].value);
                    this.redrawElementsList();
                case 'text':
                    if (this.ui.toggles['txuse'].selected) {
                        var opt:Array<String> = [ ];
                        opt.push(Std.string(this.ui.numerics['txwidth'].value));
                        opt.push(this.ui.selects['txfont'].selectedItem.value);
                        opt.push(Std.string(this.ui.numerics['txsize'].value));
                        opt.push(StringStatic.colorHex(this.ui.inputs['txcolor'].text));
                        switch (this.ui.selects['txdeco'].selectedItem.value) {
                            case 'bold':
                                opt.push('true');
                                opt.push('false');
                            case 'italic':
                                opt.push('false');
                                opt.push('true');
                            case 'bolditalic':
                                opt.push('true');
                                opt.push('true');
                            default:
                                opt.push('false');
                                opt.push('false');
                        }
                        opt.push(this.ui.selects['txalign'].selectedItem.value);
                        this.ui.lists['elements'].selectedItem.value.options = opt.join(';');
                    } else {
                        this.ui.lists['elements'].selectedItem.value.options = '';
                    }
                    this.ui.lists['elements'].selectedItem.value.x = Math.round(this.ui.numerics['formeltxposx'].value);
                    this.ui.lists['elements'].selectedItem.value.y = Math.round(this.ui.numerics['formeltxposy'].value);
                    this.redrawElementsList();
                default:
                    this.ui.lists['elements'].selectedItem.value.file = this.ui.inputs['formel'].text;
                    this.ui.lists['elements'].selectedItem.value.action = this.ui.inputs['formelac'].text;
                    this.ui.lists['elements'].selectedItem.value.x = Math.round(this.ui.numerics['formelposx'].value);
                    this.ui.lists['elements'].selectedItem.value.y = Math.round(this.ui.numerics['formelposy'].value);
                    this.redrawElementsList();                 
            }
            
        }
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-contrinterf-title'), Global.ln.get('window-contrinterf-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-contrinterf-title'), Global.ln.get('window-contrinterf-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-contrinterf-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-contrinterf-title'), Global.ln.get('window-contrinterf-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

}