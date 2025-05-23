/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;


import com.tilbuci.statictools.StringStatic;
import openfl.Assets;
import openfl.display.Bitmap;
import com.tilbuci.display.InstanceImage;
import haxe.macro.Expr.Catch;
import haxe.Timer;
import feathers.layout.AnchorLayoutData;
import feathers.controls.ListView;
import feathers.data.ArrayCollection;
import openfl.events.Event;
import com.tilbuci.ui.base.HInterfaceContainer;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.Global;

class MediaPanel extends DropDownPanel {

    /**
        currently selected instance
    **/
    private var _current:InstanceImage = null;

    public var instanceNamePanelUpdate:Dynamic;

    public function new(wd:Float) {
        super(Global.ln.get('rightbar-media'), wd);

        this.ui.createHContainer('playback', 0x333333);
        this.ui.createIconButton('play', onPlay, new Bitmap(Assets.getBitmapData('btPlay')), null, this.ui.hcontainers['playback']);
        this.ui.createIconButton('pause', onPause, new Bitmap(Assets.getBitmapData('btPause')), null, this.ui.hcontainers['playback']);
        this.ui.createIconButton('stop', onStop, new Bitmap(Assets.getBitmapData('btStop')), null, this.ui.hcontainers['playback']);

        this._content = this.ui.forge('properties', [
            { tp: 'Label', id: 'name', tx: Global.ln.get('rightbar-media-name'), vr: '' }, 
            { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
            { tp: 'Label', id: 'collection', tx: Global.ln.get('rightbar-media-collection'), vr: '' }, 
            { tp: 'Select', id: 'collection', vl: [ ], sl: null, ch: changeCol },
            { tp: 'Button', id: 'collection', tx: Global.ln.get('rightbar-media-collectioned'), ac: onCollection },  
            { tp: 'Label', id: 'asset', tx: Global.ln.get('rightbar-media-asset'), vr: '' }, 
            { tp: 'Select', id: 'asset', vl: [ ], sl: null }, 
            { tp: 'Button', id: 'asset', tx: Global.ln.get('rightbar-media-asseted'), ac: onAsset }, 
            { tp: 'Label', id: 'playonload', tx: Global.ln.get('rightbar-media-playonload'), vr: '' }, 
            { tp: 'Toggle', id: 'playonload', vl: true }, 
            { tp: 'Spacer', id: 'update', ht: 5 }, 
            { tp: 'Button', id: 'update', tx: Global.ln.get('rightbar-media-update'), ac: onUpdate }, 
            { tp: 'Spacer', id: 'cache', ht: 10 }, 
            { tp: 'Button', id: 'cache', tx: Global.ln.get('rightbar-media-cache'), ac: onCache }, 
            { tp: 'Button', id: 'remove', tx: Global.ln.get('rightbar-media-remove'), ac: onRemove }, 
            { tp: 'Spacer', id: 'playback', ht: 10 },
            { tp: 'Custom', cont: this.ui.hcontainers['playback'] }
        ], 0x333333, (wd - 5));
        this.ui.hcontainers['playback'].setWidth(Math.round(wd - 5));
        this.ui.containers['properties'].enabled = false;
        Global.history.propDisplay.push(this.updateValues);
    }

    override public function updateContent(data:Map<String, Dynamic> = null):Void {
        if (data.exists('nm')) {
            if (data['nm'] == '') {
                this.clearValues();
            } else {
                this._current = GlobalPlayer.area.instanceRef(data['nm']);
                this.updateValues();
            }
        } else {
            this.clearValues();
        }
        
    }

    override public function reloadContent(data:Map<String, Dynamic> = null):Void {
        this.clearValues();
    }

    public function updateValues():Void {
        if (this._current != null) {
            this.ui.containers['properties'].enabled = false;
            var cols:Array<Dynamic> = [ ];
            for (col in GlobalPlayer.movie.collections.keys()) cols.push({ text: GlobalPlayer.movie.collections[col].name, value: col });
            this.ui.setSelectOptions('collection', cols);
            this.ui.setSelectValue('collection', this._current.getCurrentStr('collection'));
            var asts:Array<Dynamic> = [ ];
            if (GlobalPlayer.movie.collections.exists(this._current.getCurrentStr('collection'))) {
                for (ast in GlobalPlayer.movie.collections[this._current.getCurrentStr('collection')].assets.keys()) {
                    asts.push({ text: GlobalPlayer.movie.collections[this._current.getCurrentStr('collection')].assets[ast].name, value: ast });
                }
            }
            this.ui.setSelectOptions('asset', asts);
            this.ui.setSelectValue('asset', this._current.getCurrentStr('asset'));
            this.ui.inputs['name'].text = this._current.getCurrentStr('instance');
            this.ui.toggles['playonload'].selected = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._current.getInstName()].playOnLoad;
            this.ui.containers['properties'].enabled = true;
        }
    }

    private function clearValues():Void {
        this.ui.containers['properties'].enabled = false;
        this.ui.setSelectOptions('collection', [ ]);
        this.ui.setSelectOptions('asset', [ ]);
        this.ui.inputs['name'].text = '';
        this.ui.toggles['playonload'].selected = true;
        this._current = null;
    }

    private function changeCol(evt:Event = null):Void {
        if ((this._current != null) && this.ui.containers['properties'].enabled) {
            var asts:Array<Dynamic> = [ ];
            if (GlobalPlayer.movie.collections.exists(this.ui.selects['collection'].selectedItem.value)) {
                for (ast in GlobalPlayer.movie.collections[this.ui.selects['collection'].selectedItem.value].assets.keys()) {
                    asts.push({ text: GlobalPlayer.movie.collections[this.ui.selects['collection'].selectedItem.value].assets[ast].name, value: ast });
                }
            }
            this.ui.setSelectOptions('asset', asts);
            this.ui.setSelectValue('asset', this._current.getCurrentStr('asset'));
        }
    }

    private function onCollection(evt:Event = null):Void {
        if (this._current != null) {
            this.startWindow('collectionbase', [
                'instance' => this._current.getCurrentStr('instance'), 
                'collection' => this._current.getCurrentStr('collection'), 
                'asset' => this._current.getCurrentStr('asset'), 
            ]);
        }
    }

    private function onAsset(evt:Event = null):Void {
        if (this._current != null) {
            this.startWindow('assetbase', [
                'instance' => this._current.getCurrentStr('instance'), 
                'collection' => this._current.getCurrentStr('collection'), 
                'asset' => this._current.getCurrentStr('asset'), 
            ]);
        }
    }

    private function onUpdate(evt:Event = null):Void {
        if ((this.ui.inputs['name'].text == '') || (this.ui.inputs['name'].text.length < 3)) {
            Global.showMsg(Global.ln.get('rightbar-media-noid'));
        } else {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._current.getInstName()].playOnLoad != this.ui.toggles['playonload'].selected) {
                GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._current.getInstName()].playOnLoad = this.ui.toggles['playonload'].selected;
                if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].exists(this.ui.inputs['name'].text)) {
                    GlobalPlayer.area.setCurrentStr('instance', this.ui.inputs['name'].text);
                }
                if ((GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._current.getInstName()].collection != this.ui.selects['collection'].selectedItem.value) || (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._current.getInstName()].asset != this.ui.selects['asset'].selectedItem.value)) {
                    GlobalPlayer.area.setCurrentStr('asset', (this.ui.selects['collection'].selectedItem.value + '|:|' + this.ui.selects['asset'].selectedItem.value));
                }
                Global.history.addState(Global.ln.get('rightbar-history-instance'));
            } else if ((GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._current.getInstName()].collection != this.ui.selects['collection'].selectedItem.value) || (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._current.getInstName()].asset != this.ui.selects['asset'].selectedItem.value)) {
                GlobalPlayer.area.setCurrentStr('asset', (this.ui.selects['collection'].selectedItem.value + '|:|' + this.ui.selects['asset'].selectedItem.value));
                if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].exists(this.ui.inputs['name'].text)) {
                    GlobalPlayer.area.setCurrentStr('instance', this.ui.inputs['name'].text);
                }
                Global.history.addState(Global.ln.get('rightbar-history-instance'));
            } else if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].exists(this.ui.inputs['name'].text)) {
                Global.showPopup(Global.ln.get('rightbar-media'), Global.ln.get('rightbar-media-idtaken'), 300, 180, Global.ln.get('default-ok'));
            } else {
                var oldn:String = this._current.getInstName();
                GlobalPlayer.area.setCurrentStr('instance', this.ui.inputs['name'].text);
                Global.history.addState(Global.ln.get('rightbar-history-instance'));
                if (instanceNamePanelUpdate != null) instanceNamePanelUpdate(oldn, this.ui.inputs['name'].text);
            } 
        }
    }

    private function onCache(evt:Event = null):Void {
        if (this._current.getInstName() != '') {
            var nm:String = this._current.getInstName();
            Global.showPopup(Global.ln.get('rightbar-media'), Global.ln.get('rightbar-media-precachecheck'), 300, 220, Global.ln.get('default-ok'), onCacheConfirm, 'confirm', Global.ln.get('default-cancel'));
        }
    }

    private function onCacheConfirm(ok:Bool):Void {
        if (ok) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            GlobalPlayer.area.setCurrentPrecache();
            this.ui.toggles['playonload'].selected = false;
            Global.history.addState(Global.ln.get('rightbar-history-cache'));
        }
    }

    private function onRemove(evt:Event = null):Void {
        if (this._current.getInstName() != '') {
            var nm:String = this._current.getInstName();
            Global.showPopup(Global.ln.get('rightbar-media'), Global.ln.get('rightbar-media-removecheck'), 300, 220, Global.ln.get('default-ok'), onRemoveConfirm, 'confirm', Global.ln.get('default-cancel'));
        }
    }

    private function onRemoveConfirm(ok:Bool):Void {
        if (ok) {
            if (this._current.getInstName() != '') {
                var nm:String = this._current.getInstName();
                GlobalPlayer.area.imgSelect();
                GlobalPlayer.area.removeInstance(nm);
                this.clearValues();
            }
        }
    }

    private function onPlay(evt:Event = null):Void {
        if (this._current != null) {
            if ((this._current.currentType == 'video') || (this._current.currentType == 'audio')) {
                this._current.play();
            }
        }
    }

    private function onPause(evt:Event = null):Void {
        if (this._current != null) {
            if ((this._current.currentType == 'video') || (this._current.currentType == 'audio')) {
                this._current.pause();
            }
        }
    }

    private function onStop(evt:Event = null):Void {
        if (this._current != null) {
            if ((this._current.currentType == 'video') || (this._current.currentType == 'audio')) {
                this._current.stop();
                this._current.seek(0);
            }
        }
    }


}