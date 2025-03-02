/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.media;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceContainer;
import com.tilbuci.def.AssetData;
import com.tilbuci.def.CollectionData;
import com.tilbuci.display.InstanceImage;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.contraptions.MenuContraption;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.display.Stage;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;

class WindowCollectionBase extends PopupWindow {

    private var _instance:InstanceImage;

    private var _collection:CollectionData;

    private var _assets:Array<Dynamic> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-collectionbasic-title'), 1000, 640, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.ui.createHContainer('assetorder');
        this.ui.createIconButton('orderup', onAssetUp, new Bitmap(Assets.getBitmapData('btUp')), null, this.ui.hcontainers['assetorder'], false);
        this.ui.createIconButton('orderdown', onAssetDown, new Bitmap(Assets.getBitmapData('btDown')), null, this.ui.hcontainers['assetorder'], false);
        this.ui.hcontainers['assetorder'].setWidth(460);


        this.addForm('columns', this.ui.createColumnHolder('columns',
            this.ui.forge('left', [
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-collectionbasic-name'), vr: '' }, 
                { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
                { tp: 'Label', id: 'coltrans', tx: Global.ln.get('window-collection-coltrans'), vr: '' }, 
                { tp: 'Select', id: 'coltrans', vl: [
                    { text: Global.ln.get('window-collection-ctralpha'), value: 'alpha' }, 
                    { text: Global.ln.get('window-collection-ctrright'), value: 'right' }, 
                    { text: Global.ln.get('window-collection-ctrleft'), value: 'left' }, 
                    { text: Global.ln.get('window-collection-ctrtop'), value: 'top' }, 
                    { text: Global.ln.get('window-collection-ctrbottom'), value: 'bottom' }, 
                    { text: Global.ln.get('window-collection-ctrno'), value: 'no' }, 
                ], sl: null}, 
                { tp: 'Label', id: 'coltime', tx: Global.ln.get('window-collection-coltime'), vr: '' }, 
                { tp: 'Select', id: 'coltime', vl: [
                    { text: '0.25s', value: 0.25 }, 
                    { text: '0.5s', value: 0.5 }, 
                    { text: '0.75s', value: 0.75 }, 
                    { text: '1s', value: 1 }, 
                    { text: '1.5s', value: 1.5 }, 
                    { text: '2s', value: 2 }, 
                    { text: '5s', value: 5 }, 
                ], sl: null}, 
                { tp: 'Spacer',  id: 'buttons', ht: 354, ln: false }, 
                { tp: 'Button', id: 'onok', tx:  Global.ln.get('window-collectionbasic-save'), ac: onSave},
                { tp: 'Button', id: 'oncancel', tx:  Global.ln.get('window-collectionbasic-cancel'), ac: onClose},
            ]), 
            this.ui.forge('right', [
                { tp: 'Label', id: 'assets', tx: Global.ln.get('window-collection-assets'), vr: '' }, 
                { tp: 'List', id: 'assets', vl: [ ], ht: 325, sl: null }, 
                { tp: 'Custom', cont: this.ui.hcontainers['assetorder'] }, 
                { tp: 'Spacer',  id: 'assettime', ht: 10, ln: false }, 
                { tp: 'Label', id: 'assettime', tx: Global.ln.get('window-collectionbasic-assettime'), vr: '' },
                { tp: 'Numeric', id: 'assettime', mn: 1, mx: 1000, st: 1, vl: 1 }, 
                { tp: 'Button', id: 'assettime', tx:  Global.ln.get('window-collectionbasic-assettimeset'), ac: onTime},
                { tp: 'Spacer',  id: 'assetac', ht: 10, ln: false }, 
                { tp: 'Label', id: 'assetac', tx: Global.ln.get('window-collectionbasic-astac'), vr: '' }, 
                { tp: 'Select', id: 'assetac', vl: [
                    { text: Global.ln.get('window-collection-astacloop'), value: 'loop' }, 
                    { text: Global.ln.get('window-collection-astacnext'), value: 'next' }, 
                    { text: Global.ln.get('window-collection-astacprevious'), value: 'previous' }, 
                    { text: Global.ln.get('window-collection-astacstop'), value: 'stop' }, 
                ], sl: null}, 
                { tp: 'Button', id: 'assetac', tx:  Global.ln.get('window-collectionbasic-astacset'), ac: onEnd},
            ])
        ));
        this.ui.setListToIcon('assets');
        super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        this._instance = null;
        this._collection = null;
    }

    /**
        Window custom actions (to override).
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        if (ac == 'setfile') {
            
        } else {
            this._instance = GlobalPlayer.area.pickInstance(data['instance']);
            if (this._instance != null) {
                if (GlobalPlayer.movie.collections.exists(this._instance.getCurrentStr('collection'))) {
                    if (GlobalPlayer.movie.collections[this._instance.getCurrentStr('collection')].ok) {
                        this._collection = GlobalPlayer.movie.collections[this._instance.getCurrentStr('collection')];
                        this.show();
                    } else {
                        Global.showMsg(Global.ln.get('window-asset-nocollection'));
                        PopUpManager.removePopUp(this);
                    }
                } else {
                    Global.showMsg(Global.ln.get('window-asset-nocollection'));
                    PopUpManager.removePopUp(this);
                }
            } else {
                Global.showMsg(Global.ln.get('window-asset-noinstance'));
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Shows current data.
    **/
    private function show():Void {
        this.ui.inputs['name'].text = this._collection.name;
        this.ui.setSelectValue('coltrans', this._collection.transition);
        this.ui.setSelectValue('coltime', this._collection.time);
        this.ui.lists['assets'].selectedItem = null;
        this.ui.setListValues('assets', [ ]);
        this._assets = [ ];
        for (asnm in this._collection.assetOrder) {
            this._assets.push({
                text: this._collection.assets[asnm].name, 
                user: Global.ln.get('menu-media-' + this._collection.assets[asnm].type), 
                value: {
                    time: this._collection.assets[asnm].time, 
                    action: this._collection.assets[asnm].action, 
                    order: this._collection.assets[asnm].order, 
                    id: asnm
                }
            });
        }
        this.ui.setListValues('assets', this._assets);
    }

    private function onSave(evt:Event = null):Void {
        if (this.ui.inputs['name'].text.length < 5) {
            Global.showPopup(Global.ln.get('window-collectionbasic-title'), Global.ln.get('window-collection-colnameer'), 320, 180, Global.ln.get('default-ok'));
        } else {
            Global.showPopup(Global.ln.get('window-collectionbasic-title'), Global.ln.get('window-collectionbasic-colapply'), 320, 180, Global.ln.get('default-ok'), onColSure, 'confirm', Global.ln.get('default-cancel'));
        }
    }

    private function onColSure(ok:Bool):Void {
        if (ok) {
            this._collection.name = this.ui.inputs['name'].text;
            this._collection.transition = this.ui.selects['coltrans'].selectedItem.value;
            this._collection.time = this.ui.selects['coltime'].selectedItem.value;
            this._collection.assetOrder = [ ];
            for (i in 0...this._assets.length) {
                this._collection.assetOrder.push(this._assets[i].value.id);
                this._collection.assets[this._assets[i].value.id].order = i;
                this._collection.assets[this._assets[i].value.id].time = this._assets[i].value.time;
                this._collection.assets[this._assets[i].value.id].action = this._assets[i].value.action;
            }
            this._collection = null;
            this._instance = null;
            this._assets = null;
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
            PopUpManager.removePopUp(this);
        }
    }

    private function onClose(evt:Event = null):Void {
        this._collection = null;
        this._instance = null;
        this._assets = null;
        PopUpManager.removePopUp(this);
    }

    private function onTime(evt:Event = null):Void {
        Global.showPopup(Global.ln.get('window-collectionbasic-title'), Global.ln.get('window-collectionbasic-timeapply'), 320, 190, Global.ln.get('default-ok'), onTimeSure, 'confirm', Global.ln.get('default-cancel'));
    }

    private function onTimeSure(ok:Bool):Void {
        if (ok) {
            for (i in 0...this._assets.length) {
                this._assets[i].value.time = this.ui.numerics['assettime'].value;
            }
        }
    }

    private function onEnd(evt:Event = null):Void {
        Global.showPopup(Global.ln.get('window-collectionbasic-title'), Global.ln.get('window-collectionbasic-actionapply'), 320, 190, Global.ln.get('default-ok'), onEndSure, 'confirm', Global.ln.get('default-cancel'));

    }

    private function onEndSure(ok:Bool):Void {
        if (ok) {
            for (i in 0...this._assets.length) {
                this._assets[i].value.action = this.ui.selects['assetac'].selectedItem.value;
            }
        }
    }

    /**
        Moves selected asset up in collection.
    **/
    private function onAssetUp(evt:TriggerEvent):Void {
        if (this.ui.lists['assets'].selectedItem != null) {
            var index:Int = this.ui.lists['assets'].selectedIndex;
            if (index > 0) {
                var it1:Dynamic = this._assets[index];
                var it2:Dynamic = this._assets[index - 1];
                this._assets[index] = it2;
                this._assets[index - 1] = it1;
                for (i in 0...this._assets.length) {
                    this._assets[i].value.order = i;
                }
                this.ui.lists['assets'].selectedItem = null;
                this.ui.setListValues('assets', [ ]);
                this.ui.setListValues('assets', this._assets);
                this.ui.lists['assets'].selectedIndex = index - 1;
                this.ui.lists['assets'].dataProvider.updateAt(this.ui.lists['assets'].selectedIndex);                
            }
        }
    }

    /**
        Moves selected asset down in collection.
    **/
    private function onAssetDown(evt:TriggerEvent):Void { 
        if (this.ui.lists['assets'].selectedItem != null) {
            var index:Int = this.ui.lists['assets'].selectedIndex;
            if (index < (this._assets.length - 1)) {
                var it1:Dynamic = this._assets[index];
                var it2:Dynamic = this._assets[index + 1];
                this._assets[index] = it2;
                this._assets[index + 1] = it1;
                for (i in 0...this._assets.length) {
                    this._assets[i].value.order = i;
                }
                this.ui.lists['assets'].selectedItem = null;
                this.ui.setListValues('assets', [ ]);
                this.ui.setListValues('assets', this._assets);
                this.ui.lists['assets'].selectedIndex = index + 1;
                this.ui.lists['assets'].dataProvider.updateAt(this.ui.lists['assets'].selectedIndex);   
            }
        }
    }

}