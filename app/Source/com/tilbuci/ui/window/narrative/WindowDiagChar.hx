/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.narrative;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
import openfl.display.Bitmap;
import com.tilbuci.narrative.DialogueLineNarrative;
import com.tilbuci.narrative.DialogueNarrative;
import com.tilbuci.narrative.DialogueFolderNarrative;
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

class WindowDiagChar extends PopupWindow {

    // current dialog folders
    private var _list:Map<String, DialogueFolderNarrative> = [ ];

    private var _collections:Map<String, CharCollection> = [ ];

    private var _lines:Array<Dynamic> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-narrdiag-title'), 1200, InterfaceFactory.pickValue(670, 710), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // folder buttons
        this.ui.createHContainer('folderbt');
        this.ui.createTInput('folderbtname', '', '', this.ui.hcontainers['folderbt'], false);
        this.ui.createButton('folderbtadd', Global.ln.get('window-narrdiag-add'), addFolder, this.ui.hcontainers['folderbt']);
        this.ui.createButton('folderbtrename', Global.ln.get('window-narrdiag-rename'), renameFolder, this.ui.hcontainers['folderbt']);
        this.ui.createButton('folderbtremove', Global.ln.get('window-narrdiag-remove'), removeFolder, this.ui.hcontainers['folderbt']);
        this.ui.hcontainers['folderbt'].setWidth(560, [260, 90, 90, 90]);

        // dialogues buttons
        this.ui.createHContainer('fdialogs');
        this.ui.createTInput('fdialogsname', '', '', this.ui.hcontainers['fdialogs'], false);
        this.ui.createButton('fdialogsadd', Global.ln.get('window-narrdiag-add'), addDialogue, this.ui.hcontainers['fdialogs']);
        this.ui.createButton('fdialogsrename', Global.ln.get('window-narrdiag-rename'), renameDialogue, this.ui.hcontainers['fdialogs']);
        this.ui.createButton('fdialogsremove', Global.ln.get('window-narrdiag-remove'), removeDialogue, this.ui.hcontainers['fdialogs']);
        this.ui.hcontainers['fdialogs'].setWidth(560, [260, 90, 90, 90]);

        // output instances
        this.ui.createHContainer('insttext');
        this.ui.createLabel('insttext', Global.ln.get('window-narrdiag-insttext'), 'detail',this.ui.hcontainers['insttext']);
        this.ui.createTInput('insttext', '', '', this.ui.hcontainers['insttext'], false);
        this.ui.createHContainer('instname');
        this.ui.createLabel('instname', Global.ln.get('window-narrdiag-instname'), 'detail',this.ui.hcontainers['instname']);
        this.ui.createTInput('instname', '', '', this.ui.hcontainers['instname'], false);
        this.ui.createHContainer('instexpr');
        this.ui.createLabel('instexpr', Global.ln.get('window-narrdiag-instexpr'), 'detail',this.ui.hcontainers['instexpr']);
        this.ui.createTInput('instexpr', '', '', this.ui.hcontainers['instexpr'], false);
        this.ui.createContainer('output');
        this.ui.createLabel('output', Global.ln.get('window-narrdiag-outinstances'), 'detail', this.ui.containers['output']);
        this.ui.containers['output'].addChild(this.ui.hcontainers['insttext']);
        this.ui.containers['output'].addChild(this.ui.hcontainers['instname']);
        this.ui.containers['output'].addChild(this.ui.hcontainers['instexpr']);

        // navigation instances
        this.ui.createHContainer('navprev');
        this.ui.createLabel('navprev', Global.ln.get('window-narrdiag-navprev'), 'detail',this.ui.hcontainers['navprev']);
        this.ui.createTInput('navprev', '', '', this.ui.hcontainers['navprev'], false);
        this.ui.createHContainer('navnext');
        this.ui.createLabel('navnext', Global.ln.get('window-narrdiag-navnext'), 'detail',this.ui.hcontainers['navnext']);
        this.ui.createTInput('navnext', '', '', this.ui.hcontainers['navnext'], false);
        this.ui.createHContainer('navend');
        this.ui.createLabel('navend', Global.ln.get('window-narrdiag-navend'), 'detail',this.ui.hcontainers['navend']);
        this.ui.createTInput('navend', '', '', this.ui.hcontainers['navend'], false);
        this.ui.createContainer('navigation');
        this.ui.createLabel('navigation', Global.ln.get('window-narrdiag-navinstances'), 'detail', this.ui.containers['navigation']);
        this.ui.containers['navigation'].addChild(this.ui.hcontainers['navprev']);
        this.ui.containers['navigation'].addChild(this.ui.hcontainers['navnext']);
        this.ui.containers['navigation'].addChild(this.ui.hcontainers['navend']);

        // instances
        this.ui.createHContainer('instances');
        this.ui.hcontainers['instances'].addChild(this.ui.containers['output']);
        this.ui.hcontainers['instances'].addChild(this.ui.containers['navigation']);

        // dialogue line ordering
        this.ui.createHContainer('lineorder');
        this.ui.createIconButton('orderup', onUp, new Bitmap(Assets.getBitmapData('btUp')), null, this.ui.hcontainers['lineorder'], false);
        this.ui.createIconButton('orderdown', onDown, new Bitmap(Assets.getBitmapData('btDown')), null, this.ui.hcontainers['lineorder'], false);
        this.ui.createIconButton('linerem', onRemLine, new Bitmap(Assets.getBitmapData('btDel')), null, this.ui.hcontainers['lineorder'], false);

        // text
        this.ui.createHContainer('text');
        this.ui.createLabel('text', Global.ln.get('window-narrdiag-text'), 'detail', this.ui.hcontainers['text']);
        this.ui.createTInput('text', '', '', this.ui.hcontainers['text'], false);

        // character
        this.ui.createHContainer('character');
        this.ui.createLabel('character', Global.ln.get('window-narrdiag-character'), 'detail', this.ui.hcontainers['character']);
        this.ui.createSelect('character', [ ], null, this.ui.hcontainers['character']);
        this.ui.selects['character'].addEventListener(Event.CHANGE, onCharacterChange);

        // asset
        this.ui.createHContainer('asset');
        this.ui.createLabel('asset', Global.ln.get('window-narrdiag-asset'), 'detail', this.ui.hcontainers['asset']);
        this.ui.createSelect('asset', [ ], null, this.ui.hcontainers['asset']);

        // audio
        this.ui.createHContainer('audio');
        this.ui.createLabel('audio', Global.ln.get('window-narrdiag-audio'), 'detail', this.ui.hcontainers['audio']);
        this.ui.createTInput('audio', '', '', this.ui.hcontainers['audio'], false);
        this.ui.createIconButton('audio', this.acAudio, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['audio'], false);
        this.ui.createIconButton('audiodel', this.acAudiodel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['audio'], false);
        this.ui.inputs['audio'].enabled = false;

        // line butons
        this.ui.createHContainer('lbuttons');
        this.ui.createButton('lineadd', Global.ln.get('window-narrdiag-lineadd'), onAddLine, this.ui.hcontainers['lbuttons']);
        this.ui.createButton('lineedit', Global.ln.get('window-narrdiag-lineedit'), onEditLine, this.ui.hcontainers['lbuttons']);

        // creating columns
        this.addForm(Global.ln.get('window-narrdiag-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'folders', tx: Global.ln.get('window-narrdiag-folders'), vr: 'detail' }, 
                { tp: 'List', id: 'folders', vl: [ ], sl: null, ht: 150, ch: onFolderChange }, 
                { tp: 'Label', id: 'foldername', tx: Global.ln.get('window-narrdiag-foldername'), vr: 'detail' }, 
                { tp: 'Custom', cont: this.ui.hcontainers['folderbt'] }, 
                { tp: 'Spacer', id: 'add', ht: 15, ln: true }, 
                { tp: 'Label', id: 'fdialogs', tx: Global.ln.get('window-narrdiag-fdialogs'), vr: 'detail' },
                { tp: 'List', id: 'fdialogs', vl: [ ], sl: null, ht: InterfaceFactory.pickValue(227, 241), ch: onDiagChange }, 
                { tp: 'Label', id: 'dialogname', tx: Global.ln.get('window-narrdiag-dialoguesname'), vr: 'detail' }, 
                { tp: 'Custom', cont: this.ui.hcontainers['fdialogs'] }, 
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Custom', cont: this.ui.hcontainers['instances'] }, 
                { tp: 'Label', id: 'lines', tx: Global.ln.get('window-narrdiag-lines'), vr: 'detail' },
                { tp: 'List', id: 'lines', vl: [ ], sl: null, ht: InterfaceFactory.pickValue(150, 130), ch: onChangeLine },
                { tp: 'Custom', cont: this.ui.hcontainers['lineorder'] },
                { tp: 'Spacer', id: 'lines', ht: 10, ln: false },
                { tp: 'Custom', cont: this.ui.hcontainers['text'] },
                { tp: 'Custom', cont: this.ui.hcontainers['character'] },
                { tp: 'Custom', cont: this.ui.hcontainers['asset'] },
                { tp: 'Custom', cont: this.ui.hcontainers['audio'] },
                { tp: 'Custom', cont: this.ui.hcontainers['lbuttons'] },
                { tp: 'Spacer', id: 'lines', ht: 15, ln: true },
                { tp: 'Button', id: 'rightcol', tx: Global.ln.get('window-narrdiag-savediag'), ac: saveDiag },
            ]),
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'save', tx: Global.ln.get('window-narrdiag-save'), ac: saveNarr },
            ])
            , InterfaceFactory.pickValue(580, 600)));
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
        for (k in GlobalPlayer.narrative.dialogues) {
            this._list[k.id] = k.clone();
        }

        this.ui.hcontainers['folderbt'].setWidth(560, [260, 90, 90, 90]);
        this.ui.hcontainers['fdialogs'].setWidth(560, [260, 90, 90, 90]);

        this.ui.labels['output'].width = 250;
        this.ui.labels['navigation'].width = 250;
        this.ui.hcontainers['insttext'].setWidth(250, [100, 130]);
        this.ui.hcontainers['instname'].setWidth(250, [100, 130]);
        this.ui.hcontainers['instexpr'].setWidth(250, [100, 130]);
        this.ui.hcontainers['navprev'].setWidth(250, [100, 130]);
        this.ui.hcontainers['navnext'].setWidth(250, [100, 130]);
        this.ui.hcontainers['navend'].setWidth(250, [100, 130]);
        this.ui.hcontainers['instances'].setWidth(560);

        this.ui.hcontainers['lineorder'].setWidth(560, [250, 250, 50]);
        this.ui.hcontainers['text'].setWidth(560, [100, 450]);
        this.ui.hcontainers['character'].setWidth(560, [100, 450]);
        this.ui.hcontainers['asset'].setWidth(560, [100, 450]);
        this.ui.hcontainers['audio'].setWidth(560, [100, 340, 50, 50]);
        this.ui.hcontainers['lbuttons'].setWidth(560);

        this.clear();

        Global.ws.send('Media/ListCollectionsFull', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
    }

    /**
        The collections list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-nolist'), 300, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else {
            for (k in this._collections.keys()) this._collections.remove(k);
            this._collections[''] = {
                    chname: Global.ln.get('window-narrdiag-none'), 
                    chcollection: '', 
                    chassets: [ {
                        asname: Global.ln.get('window-narrdiag-none'), 
                        asid: ''
                    } ]
            };
            for (k in GlobalPlayer.narrative.chars.keys()) {
                this._collections[k] = {
                        chname: GlobalPlayer.narrative.chars[k].chname, 
                        chcollection: GlobalPlayer.narrative.chars[k].collection, 
                        chassets: [ {
                            asname: Global.ln.get('window-narrdiag-none'), 
                            asid: ''
                        } ]
                };
            }
            if (ld.map['e'] == 0) {
                for (cuid in Reflect.fields(ld.map['list'])) {
                    var clinfo = Reflect.field(ld.map['list'], cuid);
                    if (Reflect.hasField(clinfo, 'id') && Reflect.hasField(clinfo, 'assets')) {
                        for (k in this._collections.keys()) {
                            if (this._collections[k].chcollection == Reflect.field(clinfo, 'id')) {
                                var asinfo = Reflect.field(clinfo, 'assets');
                                for (ask in Reflect.fields(asinfo)) {
                                    var asdata = Reflect.field(asinfo, ask);
                                    if (Reflect.hasField(asdata, 'id') && Reflect.hasField(asdata, 'name')) {
                                        this._collections[k].chassets.push({
                                            asname: Reflect.field(asdata, 'name'), 
                                            asid: Reflect.field(asdata, 'id')
                                        });
                                    }
                                }
                            }
                        }
                    }
                }
                var list:Array<Dynamic> = [ ];
                for (k in this._collections.keys()) {
                    list.push({
                        text: this._collections[k].chname, 
                        value: k,
                    });
                }
                this.ui.setSelectOptions('character', list);
                this.ui.setSelectValue('character', '');
                this.ui.setSelectOptions('asset', [ {
                    text: Global.ln.get('window-narrdiag-none'), 
                    value: '',
                } ]);
                this.ui.setSelectValue('asset', '');
            } else {
                this.ui.createWarning(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-nolist'), 300, 180, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Clears current data.
    **/
    private function clear(folder:String = null):Void {
        var list:Array<Dynamic> = [ ];
        for (k in this._list.keys()) list.push({
            text: k, 
            value: k, 
        });
        this.ui.setListValues('folders', list);
        this.ui.setListSelectValue('folders', folder);

        var list2:Array<Dynamic> = [ ];
        if (folder != null) {
            for (k in this._list[folder].diags.keys()) {
                list2.push({
                    text: k, 
                    value: k, 
                });
            }
        }
        this.ui.setListValues('fdialogs', list2);

        this.ui.inputs['folderbtname'].text = '';
        this.ui.inputs['fdialogsname'].text = '';

        this.ui.containers['rightcol'].visible = false;
    }

    private function onFolderChange(evt:Event):Void {
        if (this.ui.lists['folders'].selectedItem != null) {
            var list:Array<Dynamic> = [ ];
            for (k in this._list[this.ui.lists['folders'].selectedItem.value].diags.keys()) {
                list.push({
                    text: k, 
                    value: k, 
                });
            }
            this.ui.setListValues('fdialogs', list);
        }
    }

    private function onDiagChange(evt:Event):Void {
        if (this.ui.lists['fdialogs'].selectedItem != null) {
            var diag:DialogueNarrative = this._list[this.ui.lists['folders'].selectedItem.value].diags[this.ui.lists['fdialogs'].selectedItem.value];
            this.ui.inputs['insttext'].text = diag.insttext;
            this.ui.inputs['instname'].text = diag.instname;
            this.ui.inputs['instexpr'].text = diag.instexpr;
            this.ui.inputs['navprev'].text = diag.navprev;
            this.ui.inputs['navnext'].text = diag.navnext;
            this.ui.inputs['navend'].text = diag.navend;
            while (this._lines.length > 0) this._lines.shift();
            for (k in 0...diag.lines.length) {
                this._lines.push({
                    text: diag.lines[k].text.substr(0, 50),
                    value: diag.lines[k],
                });
            }
            this.ui.setListValues('lines', this._lines);
            this.ui.inputs['text'].text = '';
            this.ui.inputs['audio'].text = '';
            this.ui.setSelectValue('collection', '');
            this.ui.setSelectValue('asset', '');
            this.ui.containers['rightcol'].visible = true;
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'audio':
                this.ui.inputs['audio'].text = data['file'];
        }
    }

    private function addFolder(evt:Event):Void {
        if (StringTools.trim(this.ui.inputs['folderbtname'].text).length < 3) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-fdnamesmall'), 320, 150, Global.ln.get('default-ok'));
        } else if (this._list.exists(StringTools.trim(this.ui.inputs['folderbtname'].text))) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-fdnamealready'), 320, 150, Global.ln.get('default-ok'));
        } else {
            this._list[StringTools.trim(this.ui.inputs['folderbtname'].text)] = new DialogueFolderNarrative({
                id: StringTools.trim(this.ui.inputs['folderbtname'].text)
            });
            this.clear();
        }
    }

    private function renameFolder(evt:Event):Void {
        if (this.ui.lists['folders'].selectedItem == null) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-fdnoselect'), 320, 150, Global.ln.get('default-ok'));
        } else if (StringTools.trim(this.ui.inputs['folderbtname'].text).length < 3) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-fdnamesmall'), 320, 150, Global.ln.get('default-ok'));
        } else if (this._list.exists(StringTools.trim(this.ui.inputs['folderbtname'].text))) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-fdnamealready'), 320, 150, Global.ln.get('default-ok'));
        } else {
            var list:Map<String, DialogueFolderNarrative> = [ ];
            for (k in this._list.keys()) {
                if (k == this.ui.lists['folders'].selectedItem.value) {
                    this._list[k].id = StringTools.trim(this.ui.inputs['folderbtname'].text);
                    list[StringTools.trim(this.ui.inputs['folderbtname'].text)] = this._list[k];
                } else {
                    list[k] = this._list[k];
                }
            }
            this._list = list;
            this.clear();
        }
    }

    private function removeFolder(evt:Event):Void {
        if (this.ui.lists['folders'].selectedItem == null) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-fdnoselect'), 320, 150, Global.ln.get('default-ok'));
        } else if (this._list[this.ui.lists['folders'].selectedItem.value].numDiags() > 0) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-fdhavediags'), 320, 150, Global.ln.get('default-ok'));
        } else {
            for (k in this._list.keys()) {
                if (k == this.ui.lists['folders'].selectedItem.value) {
                    this._list[k].kill();
                    this._list.remove(k);
                }
            }
            this.clear();
        }
    }

    private function addDialogue(evt:Event):Void {
        if (this.ui.lists['folders'].selectedItem == null) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-fdnoselect'), 320, 150, Global.ln.get('default-ok'));
        } else if (StringTools.trim(this.ui.inputs['fdialogsname'].text).length < 3) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-dgnamesmall'), 320, 150, Global.ln.get('default-ok'));
        } else if (this._list[this.ui.lists['folders'].selectedItem.value].diags.exists(StringTools.trim(this.ui.inputs['fdialogsname'].text))) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-dgnamealready'), 320, 150, Global.ln.get('default-ok'));
        } else {
            this._list[this.ui.lists['folders'].selectedItem.value].diags[StringTools.trim(this.ui.inputs['fdialogsname'].text)] = new DialogueNarrative({
                id: StringTools.trim(this.ui.inputs['fdialogsname'].text)
            });
            this.clear(this.ui.lists['folders'].selectedItem.value);
        }
    }

    private function renameDialogue(evt:Event):Void {
        if (this.ui.lists['folders'].selectedItem == null) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-fdnoselect'), 320, 150, Global.ln.get('default-ok'));
        } else if (this.ui.lists['fdialogs'].selectedItem == null) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-dgnoselect'), 320, 150, Global.ln.get('default-ok'));
        } else if (StringTools.trim(this.ui.inputs['fdialogsname'].text).length < 3) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-dgnamesmall'), 320, 150, Global.ln.get('default-ok'));
        } else if (this._list[this.ui.lists['folders'].selectedItem.value].diags.exists(StringTools.trim(this.ui.inputs['fdialogsname'].text))) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-dgnamealready'), 320, 150, Global.ln.get('default-ok'));
        } else {
            var list:Map<String, DialogueNarrative> = [ ];
            for (k in this._list[this.ui.lists['folders'].selectedItem.value].diags.keys()) {
                if (k == this.ui.lists['fdialogs'].selectedItem.value) {
                    this._list[this.ui.lists['folders'].selectedItem.value].diags[k].id = StringTools.trim(this.ui.inputs['fdialogsname'].text);
                    list[StringTools.trim(this.ui.inputs['fdialogsname'].text)] = this._list[this.ui.lists['folders'].selectedItem.value].diags[k];
                } else {
                    list[k] = this._list[this.ui.lists['folders'].selectedItem.value].diags[k];
                }
            }
            this._list[this.ui.lists['folders'].selectedItem.value].diags = list;
            this.clear(this.ui.lists['folders'].selectedItem.value);
        }
    }

    private function removeDialogue(evt:Event):Void {
        if (this.ui.lists['folders'].selectedItem == null) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-fdnoselect'), 320, 150, Global.ln.get('default-ok'));
        } else if (this.ui.lists['fdialogs'].selectedItem == null) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-dgnoselect'), 320, 150, Global.ln.get('default-ok'));
        } else if (this._list[this.ui.lists['folders'].selectedItem.value].diags[this.ui.lists['fdialogs'].selectedItem.value].numLines() > 0) {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-dghavelines'), 320, 150, Global.ln.get('default-ok'));
        } else {
            this._list[this.ui.lists['folders'].selectedItem.value].diags[this.ui.lists['fdialogs'].selectedItem.value].kill();
            this._list[this.ui.lists['folders'].selectedItem.value].diags.remove(this.ui.lists['fdialogs'].selectedItem.value);
            this.clear(this.ui.lists['folders'].selectedItem.value);
        }
    }

    private function saveDiag(evt:Event):Void {
        if (this.ui.lists['folders'].selectedItem != null) {
            if (this.ui.lists['fdialogs'].selectedItem != null) {
                var diag:DialogueNarrative = this._list[this.ui.lists['folders'].selectedItem.value].diags[this.ui.lists['fdialogs'].selectedItem.value];
                diag.navprev = this.ui.inputs['navprev'].text;
                diag.navnext = this.ui.inputs['navnext'].text;
                diag.navend = this.ui.inputs['navend'].text;
                diag.insttext = this.ui.inputs['insttext'].text;
                diag.instname = this.ui.inputs['instname'].text;
                diag.instexpr = this.ui.inputs['instexpr'].text;
                diag.lines = [ ];
                while (this._lines.length > 0) diag.lines.push(this._lines.shift().value);
                this.ui.setListSelectValue('fdialogs', null);
                this.ui.containers['rightcol'].visible = false;
            }
        }
    }

    private function saveNarr(evt:Event):Void {
        for (nar in GlobalPlayer.narrative.dialogues.keys()) {
            GlobalPlayer.narrative.dialogues[nar].kill();
            GlobalPlayer.narrative.dialogues.remove(nar);
        }
        for (nar in this._list.keys()) {
            GlobalPlayer.narrative.dialogues[nar] = this._list[nar].clone();
        }
        this.clear();
        Global.ws.send('Movie/SaveNarrative', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.narrative.getData(), 
        ], this.onSaveReturn);
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-narrdiag-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-narrdiag-title'), Global.ln.get('window-narrdiag-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    private function onUp(evt:TriggerEvent):Void {
        if (this.ui.lists['lines'].selectedItem != null) {
            if (this.ui.lists['lines'].selectedIndex > 0) {
                var newindex:Int = this.ui.lists['lines'].selectedIndex - 1;
                var temp:Dynamic = this._lines[newindex];
                this._lines[newindex] = this._lines[this.ui.lists['lines'].selectedIndex];
                this._lines[this.ui.lists['lines'].selectedIndex] = temp;
                this.ui.setListValues('lines', this._lines);
                this.ui.lists['lines'].selectedIndex = newindex;
            }
        }
    }

    private function onDown(evt:TriggerEvent):Void {
        if (this.ui.lists['lines'].selectedItem != null) {
            if (this.ui.lists['lines'].selectedIndex < (this._lines.length - 1)) {
                var newindex:Int = this.ui.lists['lines'].selectedIndex + 1;
                var temp:Dynamic = this._lines[newindex];
                this._lines[newindex] = this._lines[this.ui.lists['lines'].selectedIndex];
                this._lines[this.ui.lists['lines'].selectedIndex] = temp;
                this.ui.setListValues('lines', this._lines);
                this.ui.lists['lines'].selectedIndex = newindex;
            }
        }
    }

    private function acAudio(evt:Event):Void {
        this._ac('audio');
    }

    private function acAudiodel(evt:Event):Void {
        this.ui.inputs['audio'].text = '';
    }

    private function onAddLine(evt:Event):Void {
        if (StringTools.trim(this.ui.inputs['text'].text) != '') {
            this._lines.push({
                text: StringTools.trim(this.ui.inputs['text'].text).substr(0, 50), 
                value: new DialogueLineNarrative({
                    text: StringTools.trim(this.ui.inputs['text'].text), 
                    audio: StringTools.trim(this.ui.inputs['audio'].text), 
                    character: this.ui.selects['character'].selectedItem.value, 
                    asset: this.ui.selects['asset'].selectedItem.value,
                })
            });
            this.ui.setListValues('lines', this._lines);
            this.ui.setListSelectValue('lines', null);
            this.ui.inputs['text'].text = '';
            this.ui.inputs['audio'].text = '';
        }
    }

    private function onEditLine(evt:Event):Void {
        if ((this.ui.lists['lines'].selectedItem != null) && (StringTools.trim(this.ui.inputs['text'].text) != '')) {
            this._lines[this.ui.lists['lines'].selectedIndex] = {
                text: StringTools.trim(this.ui.inputs['text'].text).substr(0, 50), 
                value: new DialogueLineNarrative({
                    text: StringTools.trim(this.ui.inputs['text'].text), 
                    audio: StringTools.trim(this.ui.inputs['audio'].text), 
                    character: this.ui.selects['character'].selectedItem.value, 
                    asset: this.ui.selects['asset'].selectedItem.value,
                })
            };
            this.ui.setListValues('lines', this._lines);
            this.ui.setListSelectValue('lines', null);
            this.ui.inputs['text'].text = '';
            this.ui.inputs['audio'].text = '';
        }
    }

    private function onRemLine(evt:Event):Void {
        if (this.ui.lists['lines'].selectedItem != null) {
            var list:Array<Dynamic> = [ ];
            for (k in 0...this._lines.length) {
                if (k != this.ui.lists['lines'].selectedIndex) list.push(this._lines[k]);
            }
            this._lines = list;
            this.ui.setListValues('lines', this._lines);
            this.ui.setListSelectValue('lines', null);
            this.ui.inputs['text'].text = '';
            this.ui.inputs['audio'].text = '';
        }
    }

    private function onCharacterChange(evt:Event):Void {
        var list:Array<Dynamic> = [ ];
        for (k in this._collections[this.ui.selects['character'].selectedItem.value].chassets) {
            list.push({
                text: k.asname, 
                value: k.asid, 
            });
        }
        this.ui.setSelectOptions('asset', list);
    }

    private function onChangeLine(evt:Event):Void {
        if (this.ui.lists['lines'].selectedItem != null) {
            this.ui.inputs['text'].text = this.ui.lists['lines'].selectedItem.value.text;
            this.ui.inputs['audio'].text = this.ui.lists['lines'].selectedItem.value.audio;
            this.ui.setSelectValue('character', this.ui.lists['lines'].selectedItem.value.character);
            this.ui.setSelectValue('asset', this.ui.lists['lines'].selectedItem.value.asset);
        }
    }

}

typedef CharCollection = {
    var chname:String;
    var chcollection:String;
    var chassets:Array<CharAsset>;
};

typedef CharAsset = {
    var asname:String;
    var asid:String;
}