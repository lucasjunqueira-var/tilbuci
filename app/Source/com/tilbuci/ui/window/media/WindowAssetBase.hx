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

class WindowAssetBase extends PopupWindow {

    private var _interface:InterfaceContainer;

    private var _instance:InstanceImage;

    private var _asset:AssetData;

    private var _endAction:String = '';

    private var _frames:Int = 1;

    private var _frtime:Int = 100;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-asset-title'), 1000, 380, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {

        this.ui.createHContainer('atfile');
        this.ui.createTInput('atfile', '', '', null, false);
        this.ui.inputs['atfile'].width = 875;
        this.ui.inputs['atfile'].enabled = false;
        this.ui.hcontainers['atfile'].addChild(this.ui.inputs['atfile']);
        this.ui.createIconButton('atfile', onFile, new Bitmap(Assets.getBitmapData('btOpenfile')), null, false);
        this.ui.buttons['atfile'].width = 50;
        this.ui.hcontainers['atfile'].addChild(this.ui.buttons['atfile']);
        this.ui.hcontainers['atfile'].setWidth(960, [870, 70]);
        
        this._interface = this.ui.forge('properties', [
            { tp: 'Label', id: 'name', tx: Global.ln.get('window-asset-name'), vr: '' }, 
            { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
            { tp: 'Label', id: 'atfile', tx: Global.ln.get('window-asset-file'), vr: '' }, 
            { tp: 'Custom', cont: this.ui.hcontainers['atfile'] }, 
            { tp: 'Button', id: 'shape', tx:  Global.ln.get('window-asset-shape'), ac: onFile}, 
            { tp: 'Button', id: 'spritemap', tx:  Global.ln.get('window-asset-spritemap'), ac: onFile}, 
            { tp: 'Button', id: 'text', tx:  Global.ln.get('window-asset-text'), ac: onFile}, 
            { tp: 'Label', id: 'asttime', tx: Global.ln.get('window-collection-asttime'), vr: '' }, 
            { tp: 'Numeric', id: 'asttime', mn: 1, mx: 1000, st: 1, vl: 1 }, 
            { tp: 'Label', id: 'assetac', tx: Global.ln.get('window-collection-astac'), vr: '' }, 
            { tp: 'Select', id: 'assetac', vl: [
                { text: Global.ln.get('window-collection-astacloop'), value: 'loop' }, 
                { text: Global.ln.get('window-collection-astacnext'), value: 'next' }, 
                { text: Global.ln.get('window-collection-astacprevious'), value: 'previous' }, 
                { text: Global.ln.get('window-collection-astacstop'), value: 'stop' }, 
                { text: Global.ln.get('window-collection-astacaction'), value: 'action' }, 
            ], sl: null}, 
            { tp: 'Button', id: 'assetac', tx:  Global.ln.get('window-collection-astacset'), ac: onEndActions}, 


            { tp: 'Spacer', id: 'buttons', ht: 10, ln: false },
            { tp: 'Button', id: 'btok', tx:  Global.ln.get('window-asset-btok'), ac: onSave}, 
            { tp: 'Button', id: 'btcancel', tx:  Global.ln.get('window-asset-btcancel'), ac: onClose}, 
        ]);

        this.addForm('properties', this._interface);
        super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        this._instance = null;
        this._asset = null;
    }

    /**
        Window custom actions (to override).
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        if (ac == 'setfile') {
            this.ui.inputs['atfile'].text = data['file'];
            this._frames = Std.parseInt(data['frames']);
            this._frtime = Std.parseInt(data['frtime']);
        } else {
            this._instance = GlobalPlayer.area.pickInstance(data['instance']);
            if (this._instance != null) {
                if (GlobalPlayer.movie.collections.exists(this._instance.getCurrentStr('collection'))) {
                    if (GlobalPlayer.movie.collections[this._instance.getCurrentStr('collection')].assets.exists(this._instance.getCurrentStr('asset'))) {
                        this._asset = GlobalPlayer.movie.collections[this._instance.getCurrentStr('collection')].assets[this._instance.getCurrentStr('asset')];
                        if (this._asset.ok) {
                            this._endAction = this._asset.action;
                            this.show();
                        } else {
                            Global.showMsg(Global.ln.get('window-asset-noasset'));
                            PopUpManager.removePopUp(this);
                        }
                    } else {
                        Global.showMsg(Global.ln.get('window-asset-noasset'));
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
        this._interface.removeChildren();

        this._interface.addChild(this.ui.labels['name']);
        this._interface.addChild(this.ui.inputs['name']);
        this.ui.inputs['name'].text = this._asset.name;

        switch (this._asset.type) {
            case 'picture':
                this._interface.addChild(this.ui.labels['atfile']);
                this._interface.addChild(this.ui.hcontainers['atfile']);
                this.ui.inputs['atfile'].text = this._asset.file['@1'];
                this._interface.addChild(this.ui.labels['asttime']);
                this._interface.addChild(this.ui.numerics['asttime']);
                this.ui.numerics['asttime'].value = this._asset.time;
            case 'video':
                this._interface.addChild(this.ui.labels['atfile']);
                this._interface.addChild(this.ui.hcontainers['atfile']);
                this.ui.inputs['atfile'].text = this._asset.file['@1'];
            case 'audio':
                this._interface.addChild(this.ui.labels['atfile']);
                this._interface.addChild(this.ui.hcontainers['atfile']);
                this.ui.inputs['atfile'].text = this._asset.file['@1'];
            case 'html':
                this._interface.addChild(this.ui.labels['atfile']);
                this._interface.addChild(this.ui.hcontainers['atfile']);
                this.ui.inputs['atfile'].text = this._asset.file['@1'];
                this._interface.addChild(this.ui.labels['asttime']);
                this._interface.addChild(this.ui.numerics['asttime']);
                this.ui.numerics['asttime'].value = this._asset.time;
            case 'shape':
                this._interface.addChild(this.ui.buttons['shape']);
                this._interface.addChild(this.ui.labels['asttime']);
                this._interface.addChild(this.ui.numerics['asttime']);
                this.ui.numerics['asttime'].value = this._asset.time;
            case 'paragraph':
                this._interface.addChild(this.ui.buttons['text']);
                this._interface.addChild(this.ui.labels['asttime']);
                this._interface.addChild(this.ui.numerics['asttime']);
                this.ui.numerics['asttime'].value = this._asset.time;
            case 'spritemap':
                this._interface.addChild(this.ui.buttons['spritemap']);
                this._interface.addChild(this.ui.labels['asttime']);
                this._interface.addChild(this.ui.numerics['asttime']);
                this.ui.numerics['asttime'].value = this._asset.time;
        }
        switch (this._endAction) {
            case '': this.ui.setSelectValue('assetac', 'loop');
            case 'loop': this.ui.setSelectValue('assetac', this._endAction);
            case 'next': this.ui.setSelectValue('assetac', this._endAction);
            case 'previous': this.ui.setSelectValue('assetac', this._endAction);
            case 'stop': this.ui.setSelectValue('assetac', this._endAction);
            default: this.ui.setSelectValue('assetac', 'action');
        }
        this._interface.addChild(this.ui.labels['assetac']);
        this._interface.addChild(this.ui.selects['assetac']);
        this._interface.addChild(this.ui.buttons['assetac']);

        this._interface.addChild(this.ui.spacers['buttons']);
        this._interface.addChild(this.ui.buttons['btok']);
        this._interface.addChild(this.ui.buttons['btcancel']);
    }

    private function onSave(evt:Event = null):Void {
        if (this.ui.inputs['name'].text.length < 5) {
            Global.showPopup(Global.ln.get('window-asset-title'), Global.ln.get('window-collection-astnameer'), 320, 180, Global.ln.get('default-ok'));
        } else {
            this._asset.name = this.ui.inputs['name'].text;
            if (this.ui.selects['assetac'].selectedItem.value == 'action') {
                this._asset.action = this._endAction;
            } else {
                this._asset.action = this.ui.selects['assetac'].selectedItem.value;
            }
            this._asset.time = Math.round(this.ui.numerics['asttime'].value);
            this._asset.frames = this._frames;
            this._asset.frtime = this._frtime;
            var curfile:String = this._asset.file['@1'];
            this._asset.file['@1'] = this.ui.inputs['atfile'].text;
            if (this._asset.file['@2'] == curfile) this._asset.file['@2'] = this.ui.inputs['atfile'].text;
            if (this._asset.file['@3'] == curfile) this._asset.file['@3'] = this.ui.inputs['atfile'].text;
            if (this._asset.file['@4'] == curfile) this._asset.file['@4'] = this.ui.inputs['atfile'].text;
            if (this._asset.file['@5'] == curfile) this._asset.file['@5'] = this.ui.inputs['atfile'].text;
            //if (this._asset.type == 'spritemap') this._instance.updateFrames(this._frames, this._frtime);
            this._asset = null;
            this._instance = null;
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
            PopUpManager.removePopUp(this);
        }
        
    }

    private function onClose(evt:Event = null):Void {
        this._asset = null;
        this._instance = null;
        PopUpManager.removePopUp(this);
    }

    private function onFile(evt:Event = null):Void {
        this._ac('file', [
            'type' => this._asset.type, 
            'current' => this._asset.file['@1'], 
            'num' => '1'
        ]);
    }

    private function onEndActions(evt:Event = null):Void {
        var current:String = '';
        switch (this._endAction) {
            case 'loop': current = '';
            case 'next': current = '';
            case 'previous': current = '';
            case 'stop': current = '';
            default: current = this._endAction;
        }
        Global.showActionWindow(current, onAcOk);
    }

    private function onAcOk(txt:String):Void {
        if (txt != '') {
            this._endAction = txt;
            this.ui.setSelectValue('assetac', 'action');
        }
    }

}