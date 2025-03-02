/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.media;

/** OPENFL **/
import feathers.layout.AnchorLayout;
import com.tilbuci.display.ShapeImage;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.def.AssetData;
import openfl.Assets;
import openfl.display.Bitmap;
import com.tilbuci.ui.base.InterfaceColumns;
import com.tilbuci.ui.base.InterfaceContainer;
import com.tilbuci.def.CollectionData;
import com.tilbuci.ui.base.HInterfaceContainer;
import com.tilbuci.ui.component.MediaPreview;
import openfl.events.MouseEvent;
import com.tilbuci.data.GlobalPlayer;
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

class WindowCollections extends PopupWindow {

    /**
        collection insterface
    **/
    private var _colint:InterfaceColumns;

    /**
        asset insterface
    **/
    private var _astint:InterfaceContainer;

    /**
        information about current asset
    **/
    private var _curast:AssetInfo;

    /**
        updated information
    **/
    private var _collections:Map<String, ColEdit>;

    /**
        any change made to the collections?
    **/
    private var _changed:Bool = false;

    /**
        shape display
    **/
    private var _shape:ShapeImage;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-collection-title'), 1000, 650, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.ui.createHContainer('assetback');
        this.ui.createButton('astbackok', Global.ln.get('window-collection-astbackok'), onAssetOk, this.ui.hcontainers['assetback'], false);
        this.ui.createButton('astbackcancel', Global.ln.get('window-collection-astbackcancel'), onAssetCancel, this.ui.hcontainers['assetback'], false);
        this.ui.hcontainers['assetback'].setWidth(960);

        this.ui.createContainer('media', 0);

        this.ui.createContainer('file', 0);
        this.ui.createLabel('assets', Global.ln.get('window-collection-astfiles'), '', this.ui.containers['file']);
        this.ui.createSpacer('assets', 5, false, this.ui.containers['file']);
        this.ui.containers['file'].addChild(this.createFileInput(1, this.onFile1));
        this.ui.createSpacer('file1', 5, false, this.ui.containers['file']);
        this.ui.containers['file'].addChild(this.createFileInput(2, this.onFile2));
        this.ui.createSpacer('file2', 5, false, this.ui.containers['file']);
        this.ui.containers['file'].addChild(this.createFileInput(3, this.onFile3));
        this.ui.createSpacer('file3', 5, false, this.ui.containers['file']);
        this.ui.containers['file'].addChild(this.createFileInput(4, this.onFile4));
        this.ui.createSpacer('file4', 5, false, this.ui.containers['file']);
        this.ui.containers['file'].addChild(this.createFileInput(5, this.onFile5));
        this.ui.containers['media'].addChild(this.ui.containers['file']);

        this.ui.createContainer('shape', 0);
        this.ui.containers['shape'].layout = new AnchorLayout();
        this._shape = new ShapeImage(this.onShapeShow);
        this.ui.createButton('shape', Global.ln.get('window-collection-astshape'), onFile1);
        this.ui.containers['shape'].width = this.ui.buttons['shape'].width = 960;

        this.ui.createContainer('assettext', 0);
        this.ui.createTArea('assettext', '', false, '', this.ui.containers['assettext']);
        this.ui.createButton('assettext', Global.ln.get('window-collection-asttext'), onFile1, this.ui.containers['assettext']);
        this.ui.containers['assettext'].width = this.ui.buttons['assettext'].width = this.ui.tareas['assettext'].width = 1000;
        this.ui.tareas['assettext'].height = 140;

        this.ui.createHContainer('spritemap');
        this.ui.hcontainers['spritemap'].addChild(this.ui.forge('smapleft', [
            { tp: 'Label', id: 'astsmapnum', tx: Global.ln.get('window-collection-astsmapnum'), vr: '' }, 
            { tp: 'Numeric', id: 'astsmapnum', mn: 1, mx: 1000, st: 1, vl: 1 }, 
        ], -1, 490, 0));
        this.ui.hcontainers['spritemap'].addChild(this.ui.forge('smapright', [
            { tp: 'Label', id: 'astsmaptime', tx: Global.ln.get('window-collection-astsmaptime'), vr: '' }, 
            { tp: 'Numeric', id: 'astsmaptime', mn: 50, mx: 5000, st: 50, vl: 100 }, 
        ], -1, 500, 0));

        this._astint = this.ui.forge('assetinterf', [
                { tp: 'Label', id: 'assetname', tx: Global.ln.get('window-collection-astname'), vr: '' }, 
                { tp: 'TInput', id: 'assetname', tx: '' }, 
                { tp: 'Spacer', id: 'assetname', ht: 10, ln: false }, 
                { tp: 'Label', id: 'assetac', tx: Global.ln.get('window-collection-astac'), vr: '' }, 
                { tp: 'Select', id: 'assetac', vl: [
                    { text: Global.ln.get('window-collection-astacloop'), value: 'loop' }, 
                    { text: Global.ln.get('window-collection-astacnext'), value: 'next' }, 
                    { text: Global.ln.get('window-collection-astacprevious'), value: 'previous' }, 
                    { text: Global.ln.get('window-collection-astacstop'), value: 'stop' }, 
                    { text: Global.ln.get('window-collection-astacaction'), value: 'action' }, 
                ], sl: null}, 
                { tp: 'Button', id: 'endactions', tx:  Global.ln.get('window-collection-astacset'), ac: onEndActions}, 
                { tp: 'Spacer', id: 'endactions', ht: 10, ln: false },
                { tp: 'Custom', cont: this.ui.containers['media'] },
                { tp: 'Spacer', id: 'assets', ht: 10, ln: false },
                { tp: 'Label', id: 'asttime', tx: Global.ln.get('window-collection-asttime'), vr: '' }, 
                { tp: 'Numeric', id: 'asttime', mn: 1, mx: 1000, st: 1, vl: 1 }, 
                { tp: 'Spacer', id: 'asttime', ht: 10, ln: false },
                { tp: 'Custom', cont: this.ui.hcontainers['spritemap'] }, 
                { tp: 'Spacer', id: 'astback', ht: 90, ln: false },
                { tp: 'Custom', cont: this.ui.hcontainers['assetback'] }
            ]);
        this.addForm(Global.ln.get('window-collection-asset'), this._astint);

        this.ui.createHContainer('newasset');
        this.ui.hcontainers['newasset'].addChild(this.ui.forge('newassetleft', [
            { tp: 'Select', id: 'assetadd', vl: [
                { text: Global.ln.get('menu-media-audio'), value: 'audio' }, 
                { text: Global.ln.get('menu-media-html'), value: 'html' }, 
                { text: Global.ln.get('menu-media-paragraph'), value: 'paragraph' }, 
                { text: Global.ln.get('menu-media-picture'), value: 'picture' }, 
                { text: Global.ln.get('menu-media-shape'), value: 'shape' }, 
                { text: Global.ln.get('menu-media-spritemap'), value: 'spritemap' }, 
                //{ text: Global.ln.get('menu-media-text'), value: 'text' }, 
                { text: Global.ln.get('menu-media-video'), value: 'video' }, 
            ], sl: 'picture'}, 
        ], -1, 180, 0));
        this.ui.hcontainers['newasset'].addChild(this.ui.forge('newassetright', [
            { tp: 'Button', id: 'assetadd', tx: Global.ln.get('window-collection-assetadd2'), ac: this.onNewAsset },
        ], -1, 311, 0));

        this.ui.createHContainer('assetorder');
        this.ui.createIconButton('orderup', onAssetUp, new Bitmap(Assets.getBitmapData('btUp')), null, this.ui.hcontainers['assetorder'], false);
        this.ui.createIconButton('orderdown', onAssetDown, new Bitmap(Assets.getBitmapData('btDown')), null, this.ui.hcontainers['assetorder'], false);
        this.ui.hcontainers['assetorder'].setWidth(460);

        this._colint = this.ui.createColumnHolder('columns',
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'collections', tx: Global.ln.get('window-collection-cols'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'collections', vl: [ ], ht: 323, sl: null, ch: this.onColChange }, 
                { tp: 'Label', id: 'coltitle', tx: Global.ln.get('window-collection-coltitle'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'coltitle', tx: '' }, 
                { tp: 'Label', id: 'coltrans', tx: Global.ln.get('window-collection-coltrans'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Select', id: 'coltrans', vl: [
                    { text: Global.ln.get('window-collection-ctralpha'), value: 'alpha' }, 
                    { text: Global.ln.get('window-collection-ctrright'), value: 'right' }, 
                    { text: Global.ln.get('window-collection-ctrleft'), value: 'left' }, 
                    { text: Global.ln.get('window-collection-ctrtop'), value: 'top' }, 
                    { text: Global.ln.get('window-collection-ctrbottom'), value: 'bottom' }, 
                    { text: Global.ln.get('window-collection-ctrno'), value: 'no' }, 
                ], sl: null}, 
                { tp: 'Label', id: 'coltime', tx: Global.ln.get('window-collection-coltime'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Select', id: 'coltime', vl: [
                    { text: '0.25s', value: 0.25 }, 
                    { text: '0.5s', value: 0.5 }, 
                    { text: '0.75s', value: 0.75 }, 
                    { text: '1s', value: 1 }, 
                    { text: '1.5s', value: 1.5 }, 
                    { text: '2s', value: 2 }, 
                    { text: '5s', value: 5 }, 
                ], sl: null}, 
                { tp: 'Button', id: 'colupdate', tx: Global.ln.get('window-collection-colupdate'), ac: this.onUpdateCol }, 
                { tp: 'Spacer',  id: 'exitapply', ht: 18, ln: false }, 
                { tp: 'Button', id: 'exitapply', tx: Global.ln.get('window-collection-exitapply'), ac: this.onApply }, 
                
                
            ]),
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'assets', tx: Global.ln.get('window-collection-assets'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'assets', vl: [ ], ht: 325, sl: null }, 
                { tp: 'Custom', cont: this.ui.hcontainers['assetorder'] }, 
                { tp: 'Button', id: 'removeasset', tx: Global.ln.get('window-collection-removea'), ac: this.onRemoveAsset }, 
                { tp: 'Button', id: 'assetprop', tx: Global.ln.get('window-collection-assetprop'), ac: this.onAssetProp }, 
                { tp: 'Button', id: 'assetstage', tx: Global.ln.get('window-collection-assetstage'), ac: this.onAddToStage }, 
                { tp: 'Spacer',  id: 'assetprop', ht: 10, ln: false }, 
                { tp: 'Label', id: 'assetadd', tx: Global.ln.get('window-collection-assetadd'), vr: Label.VARIANT_DETAIL },
                { tp: 'Custom', cont: this.ui.hcontainers['newasset'] },
                { tp: 'Spacer',  id: 'exitno', ht: 20, ln: false }, 
                { tp: 'Button', id: 'exitno', tx: Global.ln.get('window-collection-exitno'), ac: this.onNoApply }, 
            ]));
        this.addForm(Global.ln.get('window-media-file'), this._colint);
        this.ui.setListToIcon('collections');
        this.ui.setListToIcon('assets');
        this.ui.listDbClick('assets', this.onAssetProp);

        super.startInterface();
        this._forms.removeChild(this._astint);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Loading initial file list.
    **/
    override public function acStart():Void {
        this._changed = false;
        this.loadCollections();
        this._forms.removeChildren();
        this._forms.addChild(this._colint);
        this._head.text = Global.ln.get('window-collection-title');
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'setfile':
                this.ui.numerics['astsmapnum'].value = Std.parseInt(data['frames']);
                this.ui.numerics['astsmaptime'].value = Std.parseInt(data['frtime']);
                if (this.ui.lists['assets'].selectedItem.value.type == 'shape') {
                    this.ui.inputs['file@1'].text = this.ui.inputs['file@2'].text = this.ui.inputs['file@3'].text = this.ui.inputs['file@4'].text = this.ui.inputs['file@5'].text = data['file'];
                    this.ui.containers['shape'].removeChildren();
                    this._shape.visible = false;
                    this._shape.load(data['file']);
                } else if ((this.ui.lists['assets'].selectedItem.value.type == 'paragraph' || (this.ui.lists['assets'].selectedItem.value.type == 'text'))) {
                    this.ui.inputs['file@1'].text = this.ui.inputs['file@2'].text = this.ui.inputs['file@3'].text = this.ui.inputs['file@4'].text = this.ui.inputs['file@5'].text = data['file'];
                    this.ui.tareas['assettext'].text = data['file'];
                } else {
                    this.ui.inputs['file@' + data['num']].text = data['file'];
                }
            case 'addasset':
                if (this.ui.lists['collections'].selectedItem != null) {
                    //var id:String = data['name'];
                    var id:String = StringStatic.md5(data['name']).substr(0, 10);
                    while (this._collections[this.ui.lists['collections'].selectedItem.value.id].assets.exists(id)) {
                        id = StringStatic.md5(id).substr(0, 10);
                    }
                    var nm:String = data['name'];
                    if (data['type'] == 'shape') {
                        nm = Global.ln.get('menu-media-shape');
                    } else if (data['type'] == 'paragraph') {
                        nm = Global.ln.get('menu-media-paragraph');
                    } else if (data['type'] == 'text') {
                        nm = Global.ln.get('menu-media-text');
                    }
                    this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[id] = {
                        uid: '-1', 
                        id: id, 
                        order: 0, 
                        name: nm, 
                        type: data['type'], 
                        time: 5, 
                        frames: Std.parseInt(data['frames']), 
                        frtime: Std.parseInt(data['frtime']), 
                        file1: data['file'], 
                        file2: data['file'], 
                        file3: data['file'], 
                        file4: data['file'], 
                        file5: data['file'], 
                        action: 'loop'
                    }
                    var ord:Int = 0;
                    for (k in this._collections[this.ui.lists['collections'].selectedItem.value.id].assets.keys()) {
                        this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[k].order = ord;
                        ord++;
                    }
                    this.ui.lists['collections'].selectedItem.user = ord + ' ' + Global.ln.get('window-collection-numassets');
                    this.ui.lists['collections'].dataProvider.updateAt(this.ui.lists['collections'].selectedIndex);
                    this.onColChange();
                    this._changed = true;
                }
        }
    }

    /**
        Loads current movie collections.
    **/
    private function loadCollections():Void {
        this.ui.lists['collections'].selectedItem = null;
        this.ui.lists['assets'].selectedItem = null;
        this.ui.setListValues('collections', [ ]);
        this.ui.setListValues('assets', [ ]);
        var list = [ ];
        this._collections = [ ];
        for (k in GlobalPlayer.movie.scene.collections) {
            if (GlobalPlayer.movie.collections.exists(k)) {

                var col:CollectionData = GlobalPlayer.movie.collections[k];
                var info:CollectionInfo = {
                    uid: GlobalPlayer.movie.mvId + k, 
                    id: k, 
                    title: col.name, 
                    transition: col.transition, 
                    time: col.time, 
                    num: col.assetOrder.length
                };
                list.push({
                    text: col.name, 
                    value: info, 
                    user: (col.assetOrder.length + ' ' + Global.ln.get('window-collection-numassets'))
                });

                var asts:Map<String, AssetInfo> = [ ];
                for (i in 0...GlobalPlayer.movie.collections[k].assetOrder.length) {
                    var asid:String = GlobalPlayer.movie.collections[k].assetOrder[i];
                    if (GlobalPlayer.movie.collections[k].assets.exists(asid)) {
                        var adata:AssetData = GlobalPlayer.movie.collections[k].assets[asid];
                        var ainfo:AssetInfo = {
                            uid: '-' + Std.string(i), 
                            id: asid, 
                            order: i, 
                            name: adata.name, 
                            type: adata.type, 
                            time: adata.time, 
                            frames: adata.frames, 
                            frtime: adata.frtime, 
                            file1: adata.file['@1'], 
                            file2: adata.file['@2'], 
                            file3: adata.file['@3'], 
                            file4: adata.file['@4'], 
                            file5: adata.file['@5'], 
                            action: adata.action
                        };
                        asts[asid] = ainfo;
                    }
                }

                this._collections[k] = {
                    collection: info, 
                    assets: asts, 
                }

            }
            this.ui.setListValues('collections', list);

        }
    }

    /**
        A new collection was selected on the list.
    **/
    private function onColChange(evt:Event = null):Void {
        this.ui.lists['assets'].selectedItem = null;
        this.ui.setListValues('assets', [ ]);
        if (this.ui.lists['collections'].selectedItem != null) {
            var list = [ ];
            for (k in this._collections[this.ui.lists['collections'].selectedItem.value.id].assets.keys()) {
                list.push({
                    text: this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[k].name,
                    user: Global.ln.get('menu-media-' + this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[k].type), 
                    value: this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[k]
                });
            }
            this.ui.setListValues('assets', list);
            this.ui.inputs['coltitle'].text = this.ui.lists['collections'].selectedItem.value.title;
            this.ui.setSelectValue('coltrans', this.ui.lists['collections'].selectedItem.value.transition);
            this.ui.setSelectValue('coltime', this.ui.lists['collections'].selectedItem.value.time);
        }
    }

    /**
        Updates the selected collection.
    **/
    private function onUpdateCol(evt:TriggerEvent):Bool {
        if (this.ui.lists['collections'].selectedItem != null) {
            if (this.ui.inputs['coltitle'].text.length < 3) {
                Global.showPopup(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-colnameer'), 320, 180, Global.ln.get('default-ok'));
                return (false);
            } else {
                this._collections[this.ui.lists['collections'].selectedItem.value.id].collection.title = this.ui.inputs['coltitle'].text;
                this._collections[this.ui.lists['collections'].selectedItem.value.id].collection.transition = this.ui.selects['coltrans'].selectedItem.value;
                this._collections[this.ui.lists['collections'].selectedItem.value.id].collection.time = this.ui.selects['coltime'].selectedItem.value;
                this.ui.lists['collections'].selectedItem.text = this.ui.inputs['coltitle'].text;
                this.ui.lists['collections'].dataProvider.updateAt(this.ui.lists['collections'].selectedIndex);
                this._changed = true;
                return (true);
            }
        } else {
            return (true);
        }
    }

    /**
        Removes the selected asset.
    **/
    private function onRemoveAsset(evt:TriggerEvent):Void {
        if ((this.ui.lists['collections'].selectedItem != null) && (this.ui.lists['assets'].selectedItem != null)) {
            if (this.ui.lists['assets'].dataProvider.length < 2) {
                Global.showPopup(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-astonlyone'), 320, 180, Global.ln.get('default-ok'));
            } else {
                var colid:String = this.ui.lists['collections'].selectedItem.value.id;
                var asid:String = this.ui.lists['assets'].selectedItem.value.id;
                var newasts:Map<String, AssetInfo> = [ ];
                var ord:Int = 0;
                for (a in this._collections[colid].assets.keys()) {
                    if (a != asid) {
                        this._collections[colid].assets[a].order = ord;
                        ord++;
                        newasts[a] = this._collections[colid].assets[a];
                    }
                }
                this._collections[colid].assets = newasts;
                this.ui.lists['collections'].selectedItem.user = ord + ' ' + Global.ln.get('window-collection-numassets');
                this.ui.lists['collections'].dataProvider.updateAt(this.ui.lists['collections'].selectedIndex);
                this.onColChange();
                this._changed = true;
            }
        }
    }

    /**
        Adds the selected asset to stage.
    **/
    private function onAddToStage(evt:TriggerEvent):Void {
        if ((this.ui.lists['collections'].selectedItem != null) && (this.ui.lists['assets'].selectedItem != null)) {
            if (this._changed) {
                Global.showPopup(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-astaddchange'), 320, 220, Global.ln.get('default-ok'), onApplyThenAdd, 'confirm', Global.ln.get('default-cancel'));
            } else {
                this.addAssetStage();
            }
        }
    }

    /**
        Confirm info update and add to stage.
    **/
    private function onApplyThenAdd(ok:Bool):Void {
        if (ok) {
            this.updateScene();
            this.addAssetStage();
        }
    }

    /**
        Finally add to the stage!
    **/
    private function addAssetStage():Void {
        this._ac('addinstance', [
            'collection' => this.ui.lists['collections'].selectedItem.value.id, 
            'asset' => this.ui.lists['assets'].selectedItem.value.id
        ]);
        PopUpManager.removePopUp(this);
    }
    

    /**
        Moves selected asset up in collection.
    **/
    private function onAssetUp(evt:TriggerEvent):Void {
        if ((this.ui.lists['collections'].selectedItem != null) && (this.ui.lists['assets'].selectedItem != null)) {
            var index:Int = this.ui.lists['assets'].selectedIndex;
            if (index > 0) {
                var ord:Int = 0;
                for (k in this._collections[this.ui.lists['collections'].selectedItem.value.id].assets.keys()) {
                    this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[k].order = ord;
                    ord++;
                }
                var astid:String = this.ui.lists['assets'].selectedItem.value.id;
                var newast:Map<String, AssetInfo> = [ ];
                ord = 0;
                for (k in this._collections[this.ui.lists['collections'].selectedItem.value.id].assets.keys()) {
                    if (ord == (index-1)) {
                        newast[astid] = this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[astid];
                    }
                    if (k != astid) {
                        newast[k] = this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[k];
                    }
                    ord++;
                }
                ord = 0;
                for (k in newast.keys()) {
                    newast[k].order = ord;
                    ord++;
                }
                this._collections[this.ui.lists['collections'].selectedItem.value.id].assets = newast;
                this.onColChange();
                this.ui.lists['assets'].selectedIndex = index - 1;
                this.ui.lists['assets'].dataProvider.updateAt(this.ui.lists['assets'].selectedIndex);
                this._changed = true;
            }
        }
    }

    /**
        Moves selected asset down in collection.
    **/
    private function onAssetDown(evt:TriggerEvent):Void {
        if ((this.ui.lists['collections'].selectedItem != null) && (this.ui.lists['assets'].selectedItem != null)) {
            var index:Int = this.ui.lists['assets'].selectedIndex;
            if (index < (this.ui.lists['assets'].dataProvider.length - 1)) {
                var ord:Int = 0;
                for (k in this._collections[this.ui.lists['collections'].selectedItem.value.id].assets.keys()) {
                    this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[k].order = ord;
                    ord++;
                }
                var astid:String = this.ui.lists['assets'].selectedItem.value.id;
                var newast:Map<String, AssetInfo> = [ ];
                ord = 0;
                for (k in this._collections[this.ui.lists['collections'].selectedItem.value.id].assets.keys()) {
                    if (k != astid) {
                        newast[k] = this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[k];
                    }
                    if (ord == (index+1)) {
                        newast[astid] = this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[astid];
                    }
                    ord++;
                }
                ord = 0;
                for (k in newast.keys()) {
                    newast[k].order = ord;
                    ord++;
                }
                this._collections[this.ui.lists['collections'].selectedItem.value.id].assets = newast;
                this.onColChange();
                this.ui.lists['assets'].selectedIndex = index + 1;
                this.ui.lists['assets'].dataProvider.updateAt(this.ui.lists['assets'].selectedIndex);
                this._changed = true;
            }
        }
    }

    /**
        Adds an asset to current collection.
    **/
    private function onNewAsset(evt:TriggerEvent):Void {
        if (this.ui.lists['collections'].selectedItem != null) {
            this._ac('newasset', [ 'type' => this.ui.selects['assetadd'].selectedItem.value ]);
        }
    }

    /**
        Sets an asset properties.
    **/
    private function onAssetProp(evt:TriggerEvent):Void {
        if (this.ui.lists['assets'].selectedItem != null) {
            this._curast = {
                uid: this.ui.lists['assets'].selectedItem.value.uid,
                id: this.ui.lists['assets'].selectedItem.value.id,
                order: this.ui.lists['assets'].selectedItem.value.order,
                time: this.ui.lists['assets'].selectedItem.value.time,
                name: this.ui.lists['assets'].selectedItem.value.name,
                type: this.ui.lists['assets'].selectedItem.value.type,
                frames: this.ui.lists['assets'].selectedItem.value.frames,
                frtime: this.ui.lists['assets'].selectedItem.value.frtime,
                file1: this.ui.lists['assets'].selectedItem.value.file1,
                file2: this.ui.lists['assets'].selectedItem.value.file2,
                file3: this.ui.lists['assets'].selectedItem.value.file3,
                file4: this.ui.lists['assets'].selectedItem.value.file4,
                file5: this.ui.lists['assets'].selectedItem.value.file5,
                action: this.ui.lists['assets'].selectedItem.value.action
            };

            this._head.text = Global.ln.get('menu-media-' + this.ui.lists['assets'].selectedItem.value.type);
            this.ui.inputs['assetname'].text = this.ui.lists['assets'].selectedItem.value.name;
            this.ui.inputs['file@1'].text = this.ui.lists['assets'].selectedItem.value.file1;
            this.ui.inputs['file@2'].text = this.ui.lists['assets'].selectedItem.value.file2;
            this.ui.inputs['file@3'].text = this.ui.lists['assets'].selectedItem.value.file3;
            this.ui.inputs['file@4'].text = this.ui.lists['assets'].selectedItem.value.file4;
            this.ui.inputs['file@5'].text = this.ui.lists['assets'].selectedItem.value.file5;
            this.ui.numerics['asttime'].value = this.ui.lists['assets'].selectedItem.value.time;
            this.ui.numerics['astsmapnum'].value = this.ui.lists['assets'].selectedItem.value.frames;
            this.ui.numerics['astsmaptime'].value = this.ui.lists['assets'].selectedItem.value.frtime;
            switch (this.ui.lists['assets'].selectedItem.value.action) {
                case '':
                    this.ui.setSelectValue('assetac', 'loop');
                case 'loop':
                    this.ui.setSelectValue('assetac', 'loop');
                case 'next':
                    this.ui.setSelectValue('assetac', 'next');
                case 'previous':
                    this.ui.setSelectValue('assetac', 'previous');
                case 'stop':
                    this.ui.setSelectValue('assetac', 'stop');
                default:
                    this.ui.setSelectValue('assetac', 'action');
            }

            this.ui.containers['media'].removeChildren();
            if (this.ui.lists['assets'].selectedItem.value.type == 'shape') {
                this.ui.containers['media'].addChild(this.ui.containers['shape']);
                this.ui.containers['shape'].removeChildren();
                this._shape.visible = false;
                this._shape.load(this.ui.lists['assets'].selectedItem.value.file1);
            } else if ((this.ui.lists['assets'].selectedItem.value.type == 'paragraph') || (this.ui.lists['assets'].selectedItem.value.type == 'text')) {
                this.ui.containers['media'].addChild(this.ui.containers['assettext']);
                this.ui.tareas['assettext'].text = this.ui.lists['assets'].selectedItem.value.file1;
            } else {
                this.ui.containers['media'].addChild(this.ui.containers['file']);
            }

            this._forms.removeChild(this._colint);
            this._forms.addChild(this._astint);
        }
    }

    private function onShapeShow(ok:Bool):Void {
        if (ok) {
            this._shape.height = 100;
            this._shape.width = this._shape.oWidth * (this._shape.height/this._shape.oHeight);
            this._shape.y = 0;
            this.ui.containers['shape'].addChild(this._shape);
            this.ui.containers['shape'].addChild(this.ui.buttons['shape']);
            this._shape.visible = true;
            this._shape.x = (960 - this._shape.width) / 2;
            this.ui.buttons['shape'].y = this._shape.height + 30;
        } else {
            this._shape.visible = false;
        }
    }

    /**
        Set asset file level @1.
    **/
    private function onFile1(evt:Event = null):Void {
        this._ac('file', [
            'type' => this._curast.type, 
            'current' => this.ui.lists['assets'].selectedItem.value.file1, 
            'num' => '1'
        ]);
    }

    /**
        Set asset file level @2.
    **/
    private function onFile2(evt:Event = null):Void {
        this._ac('file', [
            'type' => this._curast.type, 
            'current' => this.ui.lists['assets'].selectedItem.value.file2, 
            'num' => '2'
        ]);
    }

    /**
        Set asset file level @3.
    **/
    private function onFile3(evt:Event = null):Void {
        this._ac('file', [
            'type' => this._curast.type, 
            'current' => this.ui.lists['assets'].selectedItem.value.file3, 
            'num' => '3'
        ]);
    }

    /**
        Set asset file level @4.
    **/
    private function onFile4(evt:Event = null):Void {
        this._ac('file', [
            'type' => this._curast.type, 
            'current' => this.ui.lists['assets'].selectedItem.value.file4, 
            'num' => '4'
        ]);
    }

    /**
        Set asset file level @5.
    **/
    private function onFile5(evt:Event = null):Void {
        this._ac('file', [
            'type' => this._curast.type, 
            'current' => this.ui.lists['assets'].selectedItem.value.file5, 
            'num' => '5'
        ]);
    }

    /**
        Set asset end actions.
    **/
    private function onEndActions(evt:Event = null):Void {
        var current:String;
        switch (this._curast.action) {
            case '': current = '';
            case 'loop': current = '';
            case 'next': current = '';
            case 'previous': current = '';
            case 'stop': current = '';
            default: current = this._curast.action;
        }
        Global.showActionWindow(current, onAcOk);
    }

    /**
        New end action set.
    **/
    private function onAcOk(txt:String):Void {
        if (txt == '') {
            this._curast.action = 'loop';
            this.ui.setSelectValue('assetac', 'loop');
        } else {
            this._curast.action = txt;
            this.ui.setSelectValue('assetac', 'action');
        }
    }

    /**
        Cancel asset changes.
    **/
    private function onAssetCancel(evt:Event = null):Void {
        this._curast = null;
        this._forms.removeChild(this._astint);
        this._forms.addChild(this._colint);
    }

    /**
        Apply asset changes.
    **/
    private function onAssetOk(evt:Event = null):Void {
        if (this.ui.inputs['assetname'].text.length < 3) {
            Global.showPopup(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-astnameer'), 320, 180, Global.ln.get('default-ok'));
        } else if (this.ui.numerics['asttime'].value < 1) {
            Global.showPopup(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-asttimeer'), 320, 180, Global.ln.get('default-ok'));
        } else if (this.ui.numerics['astsmapnum'].value < 1) {
            Global.showPopup(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-astframeser'), 320, 180, Global.ln.get('default-ok'));
        } else if (this.ui.numerics['astsmaptime'].value < 50) {
            Global.showPopup(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-astfrtimeser'), 320, 180, Global.ln.get('default-ok'));
        } else if ((this.ui.inputs['file@1'].text == '') || (this.ui.inputs['file@2'].text == '') || (this.ui.inputs['file@3'].text == '') || (this.ui.inputs['file@4'].text == '') || (this.ui.inputs['file@5'].text == '')) {
            Global.showPopup(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-astfileser'), 320, 180, Global.ln.get('default-ok'));
        } else {
            var newast:AssetInfo = {
                uid: this._curast.uid, 
                id: this._curast.id, 
                order: this._curast.order, 
                name: this.ui.inputs['assetname'].text, 
                type: this._curast.type, 
                time: Math.round(this.ui.numerics['asttime'].value), 
                frames: Math.round(this.ui.numerics['astsmapnum'].value), 
                frtime: Math.round(this.ui.numerics['astsmaptime'].value), 
                file1: this.ui.inputs['file@1'].text,
                file2: this.ui.inputs['file@2'].text,
                file3: this.ui.inputs['file@3'].text,
                file4: this.ui.inputs['file@4'].text,
                file5: this.ui.inputs['file@5'].text,
                action: '',
            }
            switch (this.ui.selects['assetac'].selectedItem.value) {
                case 'loop': newast.action = 'loop'; 
                case 'next': newast.action = 'next'; 
                case 'previous': newast.action = 'previous'; 
                case 'stop': newast.action = 'stop'; 
                case 'action': newast.action = this._curast.action;
            }
            this.ui.lists['assets'].selectedItem.value = newast;
            this.ui.lists['assets'].selectedItem.text = newast.name;
            this._collections[this.ui.lists['collections'].selectedItem.value.id].assets[newast.id] = newast;
            this._curast = null;
            this._forms.removeChild(this._astint);
            this._forms.addChild(this._colint);
            this._changed = true;
        }
    }

    /**
        Creates a file asset input.
        @param  num level number
        @param  ac  action for button click
    **/
    private function createFileInput(num:Int, ac:Dynamic):HInterfaceContainer {
        this.ui.createHContainer('at'+num);
        this.ui.createLabel('file@'+num, Global.ln.get('window-collection-astfiles'+num), '', null, false);
        this.ui.labels['file@'+num].width = 25;
        this.ui.hcontainers['at'+num].addChild(this.ui.labels['file@'+num]);
        this.ui.createTInput('file@'+num, '', '', null, false);
        this.ui.inputs['file@'+num].width = 875;
        this.ui.inputs['file@'+num].enabled = false;
        this.ui.hcontainers['at'+num].addChild(this.ui.inputs['file@'+num]);
        this.ui.createIconButton('file@'+num, ac, new Bitmap(Assets.getBitmapData('btOpenfile')), null, false);
        this.ui.buttons['file@'+num].width = 50;
        this.ui.hcontainers['at'+num].addChild(this.ui.buttons['file@'+num]);
        this.ui.hcontainers['at'+num].setWidth(960, [50, 820, 70]);
        return(this.ui.hcontainers['at'+num]);
    }

    /**
        Applies all changes.
    **/
    private function onApply(evt:TriggerEvent):Void {
        if (this.onUpdateCol(null)) {
            if (this._changed) {
                Global.showPopup(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-colapplyok'), 320, 220, Global.ln.get('default-ok'), onApplySure, 'confirm', Global.ln.get('default-cancel'));
            } else {
                PopUpManager.removePopUp(this);
            }
        } else {
            // nothing to do
        }
    }

    /**
        Exit without changing.
    **/
    private function onNoApply(evt:TriggerEvent):Void {
        if (this._changed) {
            Global.showPopup(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-colapplyno'), 320, 220, Global.ln.get('default-ok'), onApplyNo, 'confirm', Global.ln.get('default-cancel'));
        } else {
            PopUpManager.removePopUp(this);
        }
    }

    /**
        Collections update confirmation.
        @param  ok  really apply?
    **/
    private function onApplySure(ok:Bool):Void {
        if (ok) {
            this.updateScene();
            PopUpManager.removePopUp(this);
        }
    }

    /**
        Really exit without applying changes.
        @param  ok  really apply?
    **/
    private function onApplyNo(ok:Bool):Void {
        if (ok) {
            PopUpManager.removePopUp(this);
        }
    }

    /**
        Updates scene collections with current data.
    **/
    private function updateScene():Void {
        for (k in this._collections.keys()) {
            if (GlobalPlayer.movie.collections.exists(k)) {
                GlobalPlayer.movie.collections[k].name = this._collections[k].collection.title;
                GlobalPlayer.movie.collections[k].transition = this._collections[k].collection.transition;
                GlobalPlayer.movie.collections[k].time = this._collections[k].collection.time;

                GlobalPlayer.movie.collections[k].assets = [ ];
                var astorder:Array<String> = [ ];
                var ord:Int = 0;
                for (a in this._collections[k].assets.keys()) {
                    this._collections[k].assets[a].order = ord;
                    astorder.push(a);
                    GlobalPlayer.movie.collections[k].assets[a] = new AssetData({
                        order: this._collections[k].assets[a].order, 
                        name: this._collections[k].assets[a].name, 
                        type: this._collections[k].assets[a].type, 
                        time: this._collections[k].assets[a].time, 
                        action: this._collections[k].assets[a].action, 
                        frames: this._collections[k].assets[a].frames, 
                        frtime: this._collections[k].assets[a].frtime, 
                        file: {
                            '@1': this._collections[k].assets[a].file1, 
                            '@2': this._collections[k].assets[a].file2, 
                            '@3': this._collections[k].assets[a].file3, 
                            '@4': this._collections[k].assets[a].file4, 
                            '@5': this._collections[k].assets[a].file5, 
                        }
                    });
                    ord++;
                }
                GlobalPlayer.movie.collections[k].assetOrder = astorder;
                GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
            }
        }
    }

}

/**
    Collection information.
**/
typedef CollectionInfo = {
    var uid:String;
    var id:String;
    var title:String;
    var transition:String;
    var time:Float;
    var num:Int;
}

/**
    Asset information.
**/
typedef AssetInfo = {
    var uid:String;
    var id:String;
    var order:Int;
    var name:String;
    var type:String;
    var time:Int;
    var frames:Int;
    var frtime:Int;
    var file1:String;
    var file2:String;
    var file3:String;
    var file4:String;
    var file5:String;
    var action:String;
}

/**
    Temporary scene collections list.
**/
typedef ColEdit = {
    var collection:CollectionInfo;
    var assets:Map<String, AssetInfo>;
}