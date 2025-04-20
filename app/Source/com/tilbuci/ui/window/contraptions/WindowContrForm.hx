/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.contraptions;

/** OPENFL **/
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

class WindowContrForm extends PopupWindow {

    // contraptions list
    private var _list:Map<String, FormContraption> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-contrform-title'), 1000, 710, false, true, true);
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
            { tp: 'Label', id: 'backgroundset', tx: Global.ln.get('window-contrform-background'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['background'] }, 
            { tp: 'Spacer', id: 'backgroundset', ht: 10, ln: false }, 
            { tp: 'Button', id: 'backgroundset', tx: Global.ln.get('window-contrform-setbutton'), ac: setElement },
        ]);


        // ok button input
        this.ui.createHContainer('btok');
        this.ui.createTInput('btok', '', '', this.ui.hcontainers['btok'], false);
        this.ui.createIconButton('btok', this.acBtok, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['btok'], false);
        this.ui.createIconButton('btokdel', this.acBtokdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['btok'], false);
        this.ui.inputs['btok'].enabled = false;
        this.ui.hcontainers['btok'].setWidth(450, [340, 50, 50]);
        this.ui.createHContainer('formelokpos');
        this.ui.createLabel('formelokposx', 'X', 'detail', this.ui.hcontainers['formelokpos']);
        this.ui.createNumeric('formelokposx', -3840, 3840, 10, 0, this.ui.hcontainers['formelokpos']);
        this.ui.createLabel('formelokposy', 'Y', 'detail', this.ui.hcontainers['formelokpos']);
        this.ui.createNumeric('formelokposy', -3840, 3840, 10, 0, this.ui.hcontainers['formelokpos']);
        this.ui.forge('btok', [
            { tp: 'Label', id: 'btokset', tx: Global.ln.get('window-contrform-btok'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['btok'] }, 
            { tp: 'Spacer', id: 'okpos', ht: 10, ln: false }, 
            { tp: 'Label', id: 'formelokpos', tx: Global.ln.get('window-contrform-formelposition'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['formelokpos'] }, 
            { tp: 'Spacer', id: 'btokset', ht: 10, ln: false }, 
            { tp: 'Button', id: 'btokset', tx: Global.ln.get('window-contrform-setbutton'), ac: setElement },
        ]);

        // cancel button input
        this.ui.createHContainer('btcancel');
        this.ui.createTInput('btcancel', '', '', this.ui.hcontainers['btcancel'], false);
        this.ui.createIconButton('btcancel', this.acBtcancel, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['btcancel'], false);
        this.ui.createIconButton('btcanceldel', this.acBtcanceldel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['btcancel'], false);
        this.ui.inputs['btcancel'].enabled = false;
        this.ui.hcontainers['btcancel'].setWidth(450, [340, 50, 50]);
        this.ui.createHContainer('formelcancpos');
        this.ui.createLabel('formelcancposx', 'X', 'detail', this.ui.hcontainers['formelcancpos']);
        this.ui.createNumeric('formelcancposx', -3840, 3840, 10, 0, this.ui.hcontainers['formelcancpos']);
        this.ui.createLabel('formelcancposy', 'Y', 'detail', this.ui.hcontainers['formelcancpos']);
        this.ui.createNumeric('formelcancposy', -3840, 3840, 10, 0, this.ui.hcontainers['formelcancpos']);
        this.ui.forge('btcancel', [
            { tp: 'Label', id: 'btcancelset', tx: Global.ln.get('window-contrform-btcancel'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['btcancel'] }, 
            { tp: 'Spacer', id: 'cancpos', ht: 10, ln: false }, 
            { tp: 'Label', id: 'formelcancpos', tx: Global.ln.get('window-contrform-formelposition'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['formelcancpos'] },
            { tp: 'Spacer', id: 'btcancelset', ht: 10, ln: false }, 
            { tp: 'Button', id: 'btcancelset', tx: Global.ln.get('window-contrform-setbutton'), ac: setElement },
        ]);

        // form elements
        this.ui.createHContainer('formelpos');
        this.ui.createLabel('formelposx', 'X', 'detail', this.ui.hcontainers['formelpos']);
        this.ui.createNumeric('formelposx', -3840, 3840, 10, 0, this.ui.hcontainers['formelpos']);
        this.ui.createLabel('formelposy', 'Y', 'detail', this.ui.hcontainers['formelpos']);
        this.ui.createNumeric('formelposy', -3840, 3840, 10, 0, this.ui.hcontainers['formelpos']);
        this.ui.forge('formel', [
            { tp: 'Label', id: 'formelname', tx: Global.ln.get('window-contrform-elname'), vr: '' },
            { tp: 'TInput', id: 'formelname', tx: '', vr: '' }, 
            { tp: 'Label', id: 'formeltytpe', tx: Global.ln.get('window-contrform-eltype'), vr: '' },
            { tp: 'Select', id: 'formeltytpe', sl: '', vl: [
                { text: Global.ln.get('window-contrform-eltype-input'), value: 'input' }, 
                { text: Global.ln.get('window-contrform-eltype-select'), value: 'select' }, 
                { text: Global.ln.get('window-contrform-eltype-toggle'), value: 'toggle' }, 
                { text: Global.ln.get('window-contrform-eltype-numeric'), value: 'numeric' }, 
                { text: Global.ln.get('window-contrform-eltype-password'), value: 'password' }, 
                { text: Global.ln.get('window-contrform-eltype-textarea'), value: 'textarea' }, 
            ] }, 
            { tp: 'Label', id: 'formelselect', tx: Global.ln.get('window-contrform-formelselect'), vr: '' },
            { tp: 'TInput', id: 'formelselect', tx: '', vr: '' }, 
            { tp: 'Spacer', id: 'forplace', ht: 10, ln: false }, 
            { tp: 'Label', id: 'formelwidth', tx: Global.ln.get('window-contrform-formelwidth'), vr: '' },
            { tp: 'Numeric', id: 'formelwidth', mn: 10, mx: 3840, st: 10, vl:100 }, 
            { tp: 'Label', id: 'formelposition', tx: Global.ln.get('window-contrform-formelposition'), vr: '' },
            { tp: 'Custom', cont: this.ui.hcontainers['formelpos'] }, 
            { tp: 'Spacer', id: 'formel', ht: 10, ln: false }, 
            { tp: 'Button', id: 'formel', tx: Global.ln.get('window-contrform-setbutton'), ac: setElement },
        ]);

        // elements
        this.ui.createHContainer('elements');
        this.ui.createButton('elementadd', Global.ln.get('window-contrform-eladd'), onElAdd, this.ui.hcontainers['elements']);
        this.ui.createButton('elementrem', Global.ln.get('window-contrform-elrem'), onElRem, this.ui.hcontainers['elements']);

        // creating columns
        this.addForm(Global.ln.get('window-kfmanage-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'registered', tx: Global.ln.get('window-contrform-registered'), vr: '' }, 
                { tp: 'List', id: 'registered', vl: [ ], sl: null, ht: 150 }, 
                { tp: 'Button', id: 'load', tx: Global.ln.get('window-contrform-load'), ac: loadContr }, 
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-contrform-remove'), ac: removeContr },
                { tp: 'Spacer', id: 'add', ht: 15, ln: true }, 
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-contrform-name'), vr: 'detail' }, 
                { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
                { tp: 'Label', id: 'elements', tx: Global.ln.get('window-contrform-elements'), vr: 'detail' }, 
                { tp: 'List', id: 'elements', vl: [ ], sl: null, ht: 190, ch: onElLoad }, 
                { tp: 'Custom', cont: this.ui.hcontainers['elements'] },
                { tp: 'Button', id: 'add', tx: Global.ln.get('window-contrform-add'), ac: addContr },
            ]), 
            this.ui.forge('rightcol', [
                /*{ tp: 'Label', id: 'properties', tx: Global.ln.get('window-contrcover-properties'), vr: '' }, 
                { tp: 'Label', id: 'landscape', tx: Global.ln.get('window-contrcover-landscape'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['landscape'] }, 
                { tp: 'Label', id: 'portrait', tx: Global.ln.get('window-contrcover-portrait'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['portrait'] },               
                { tp: 'Label', id: 'block', tx: Global.ln.get('window-contrcover-block'), vr: 'detail' },
                { tp: 'Toggle', id: 'block', vl: false }, */
            ]),
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'save', tx: Global.ln.get('window-contrform-save'), ac: saveContr },
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
        for (contk in GlobalPlayer.contraptions.forms) {
            this._list[contk.id] = contk.clone();
        }
        this.clear();
        this.ui.hcontainers['elements'].setWidth(460);
        this.clearElements();
    }

    private function clearElements():Void {
        var list:Array<Dynamic> = [ ];
        list.push({
            text: Global.ln.get('window-contrform-nameok'), 
            value: {
                name: Global.ln.get('window-contrform-nameok'),
                type: 'btok',
                file: '',
                options: '', 
                width: 100, 
                x: 0, 
                y: 0
            }
        });
        list.push({
            text: Global.ln.get('window-contrform-namebg'), 
            value: {
                name: Global.ln.get('window-contrform-namebg'),
                type: 'background',
                file: '',
                options: '', 
                width: 100, 
                x: 0, 
                y: 0
            }
        });
        list.push({
            text: Global.ln.get('window-contrform-namecancel'), 
            value: {
                name: Global.ln.get('window-contrform-namecancel'),
                type: 'btcancel',
                file: '',
                options: '', 
                width: 100, 
                x: 0, 
                y: 0
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
                var cont:FormContraption = cast this.ui.lists['registered'].selectedItem.value;
                for (el in cont.elem) {
                    var elname:String = '';
                    switch (el.type) {
                        case 'background': elname = Global.ln.get('window-contrform-background');
                        case 'btok': elname = Global.ln.get('window-contrform-btok');
                        case 'btcancel': elname = Global.ln.get('window-contrform-btcancel');
                        default: elname = el.name + ' (' + Global.ln.get('window-contrform-eltype-' + el.type) + ')';
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
            case 'formbackground':
                this.ui.inputs['background'].text = data['file'];
            case 'formbtok':
                this.ui.inputs['btok'].text = data['file'];
            case 'formbtcancel':
                this.ui.inputs['btcancel'].text = data['file'];
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
            GlobalPlayer.contraptions.forms[cont] = this._list[cont].clone();
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
            for (el in this.ui.lists['elements'].dataProvider) {
                switch (el.value.type) {
                    case 'background': list.push(el.value);
                    case 'btcancel': list.push(el.value);
                    case 'btok':
                        list.push(el.value);
                        if (el.value.file == '') okbt = false;
                    default:
                        if (el.value.name != '') list.push(el.value);
                }
            }
            if (okbt) {
                if (list.length <= 3) {
                    Global.showPopup(Global.ln.get('window-contrform-title'), Global.ln.get('window-contrform-noelem'), 320, 150, Global.ln.get('default-ok'));
                } else {
                    var contr:FormContraption;
                    if (this._list.exists(this.ui.inputs['name'].text)) {
                        contr = this._list[this.ui.inputs['name'].text];
                    } else {
                        contr = new FormContraption();
                    }
                    if (contr.load({
                        id: this.ui.inputs['name'].text, 
                        elem: list
                    })) {
                        this._list[this.ui.inputs['name'].text] = contr;
                        this.ui.inputs['name'].text = '';
                        this.clear();
                    }
                }
            } else {
                Global.showPopup(Global.ln.get('window-contrform-title'), Global.ln.get('window-contrform-nook'), 320, 150, Global.ln.get('default-ok'));
            }           
        } else {
            Global.showPopup(Global.ln.get('window-contrform-title'), Global.ln.get('window-contrform-noname'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    private function acBackground(evt:Event):Void {
        this._ac('formbackground');
    }

    private function acBackgrounddel(evt:Event):Void {
        this.ui.inputs['background'].text = '';
    }

    private function acBtok(evt:Event):Void {
        this._ac('formbtok');
    }

    private function acBtokdel(evt:Event):Void {
        this.ui.inputs['btok'].text = '';
    }

    private function acBtcancel(evt:Event):Void {
        this._ac('formbtcancel');
    }

    private function acBtcanceldel(evt:Event):Void {
        this.ui.inputs['btcancel'].text = '';
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
            text: Global.ln.get('window-contrform-new'), 
            value: {
                {
                    name: '',
                    type: '',
                    file: '',
                    options: '', 
                    width: 100, 
                    x: 0, 
                    y: 0
                }
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
                case 'btok':
                    this.ui.containers['rightcol'].addChild(this.ui.containers['btok']);
                    this.ui.labels['formelokpos'].width = this.ui.labels['btokset'].width = this.ui.buttons['btokset'].width = 450;
                    this.ui.hcontainers['formelokpos'].setWidth(450, [ 60, 145, 60, 145 ]);
                    this.ui.inputs['btok'].text = this.ui.lists['elements'].selectedItem.value.file;
                    this.ui.numerics['formelokposx'].value = this.ui.lists['elements'].selectedItem.value.x;
                    this.ui.numerics['formelokposy'].value = this.ui.lists['elements'].selectedItem.value.y;
                case 'btcancel':
                    this.ui.containers['rightcol'].addChild(this.ui.containers['btcancel']);
                    this.ui.labels['formelcancpos'].width = this.ui.labels['btcancelset'].width = this.ui.buttons['btcancelset'].width = 450;
                    this.ui.hcontainers['formelcancpos'].setWidth(450, [ 60, 145, 60, 145 ]);
                    this.ui.inputs['btcancel'].text = this.ui.lists['elements'].selectedItem.value.file;
                    this.ui.numerics['formelcancposx'].value = this.ui.lists['elements'].selectedItem.value.x;
                    this.ui.numerics['formelcancposy'].value = this.ui.lists['elements'].selectedItem.value.y;
                default:
                    this.ui.containers['rightcol'].addChild(this.ui.containers['formel']);
                    this.ui.inputs['formelname'].width = this.ui.labels['formelname'].width = 450;
                    this.ui.selects['formeltytpe'].width = this.ui.labels['formeltytpe'].width = 450;
                    this.ui.inputs['formelselect'].width = this.ui.labels['formelselect'].width = 450;
                    this.ui.numerics['formelwidth'].width = this.ui.labels['formelwidth'].width = 450;
                    this.ui.labels['formelposition'].width = this.ui.buttons['formel'].width = 450;
                    this.ui.hcontainers['formelpos'].setWidth(450, [ 60, 145, 60, 145 ]);
                    this.ui.inputs['formelname'].text = this.ui.lists['elements'].selectedItem.value.name;
                    this.ui.setSelectValue('formeltytpe', this.ui.lists['elements'].selectedItem.value.type);
                    this.ui.inputs['formelselect'].text = this.ui.lists['elements'].selectedItem.value.options;
                    this.ui.numerics['formelposx'].value = this.ui.lists['elements'].selectedItem.value.x;
                    this.ui.numerics['formelposy'].value = this.ui.lists['elements'].selectedItem.value.y;
                    this.ui.numerics['formelwidth'].value = this.ui.lists['elements'].selectedItem.value.width;
            }
        }
    }

    private function onElRem(evt:Event):Void {
        if (this.ui.lists['elements'].selectedItem != null) {
            switch (this.ui.lists['elements'].selectedItem.value.type) {
                case 'background': // nothing to do
                case 'btok': // nothing to do
                case 'btcancel': // nothing to do
                default:
                    var list:Array<Dynamic> = [ ];
                    for (el in this.ui.lists['elements'].dataProvider) {
                        if (el.value.name != this.ui.lists['elements'].selectedItem.value.name) {
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
                case 'btok':
                    this.ui.lists['elements'].selectedItem.value.file = this.ui.inputs['btok'].text;
                    this.ui.lists['elements'].selectedItem.value.x = Math.round(this.ui.numerics['formelokposx'].value);
                    this.ui.lists['elements'].selectedItem.value.y = Math.round(this.ui.numerics['formelokposy'].value);
                    this.redrawElementsList();
                case 'btcancel':
                    this.ui.lists['elements'].selectedItem.value.file = this.ui.inputs['btcancel'].text;
                    this.ui.lists['elements'].selectedItem.value.x = Math.round(this.ui.numerics['formelcancposx'].value);
                    this.ui.lists['elements'].selectedItem.value.y = Math.round(this.ui.numerics['formelcancposy'].value);
                    this.redrawElementsList();
                default:
                    var newname:String = this.ui.inputs['formelname'].text;
                    if (newname.length < 3) {
                        Global.showPopup(Global.ln.get('window-contrform-title'), Global.ln.get('window-contrform-showtname'), 320, 150, Global.ln.get('default-ok'));
                    } else {
                        var ok:Bool = true;
                        if (newname != this.ui.lists['elements'].selectedItem.value.name) {
                            for (el in this.ui.lists['elements'].dataProvider) {
                                if (newname == el.value.name) {
                                    ok = false;
                                }
                            }
                        }
                        if (!ok) {
                            Global.showPopup(Global.ln.get('window-contrform-title'), Global.ln.get('window-contrform-usedname'), 320, 150, Global.ln.get('default-ok'));
                        } else {
                            this.ui.lists['elements'].selectedItem.value.name = this.ui.inputs['formelname'].text;
                            this.ui.lists['elements'].selectedItem.value.type = this.ui.selects['formeltytpe'].selectedItem.value;
                            this.ui.lists['elements'].selectedItem.value.options = this.ui.inputs['formelselect'].text;
                            this.ui.lists['elements'].selectedItem.value.x = Math.round(this.ui.numerics['formelposx'].value);
                            this.ui.lists['elements'].selectedItem.value.y = Math.round(this.ui.numerics['formelposy'].value);
                            this.ui.lists['elements'].selectedItem.value.width = Math.round(this.ui.numerics['formelwidth'].value);
                            this.ui.lists['elements'].selectedItem.text = this.ui.inputs['formelname'].text + ' (' + Global.ln.get('window-contrform-eltype-' + this.ui.selects['formeltytpe'].selectedItem.value) + ')';
                            this.redrawElementsList();
                        }
                    }                    
            }
            
        }
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-contrform-title'), Global.ln.get('window-contrform-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-contrform-title'), Global.ln.get('window-contrform-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-contrform-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-contrform-title'), Global.ln.get('window-contrform-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

}