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
        this._content = this.ui.forge('properties', [
            { tp: 'Label', id: 'name', tx: Global.ln.get('rightbar-media-name'), vr: '' }, 
            { tp: 'TInput', id: 'name', tx: '', vr: '' }, 
            { tp: 'Label', id: 'collection', tx: Global.ln.get('rightbar-media-collection'), vr: '' }, 
            { tp: 'Select', id: 'collection', vl: [ ], sl: null, ch: changeCol }, 
            { tp: 'Label', id: 'asset', tx: Global.ln.get('rightbar-media-asset'), vr: '' }, 
            { tp: 'Select', id: 'asset', vl: [ ], sl: null }, 
            { tp: 'Label', id: 'playonload', tx: Global.ln.get('rightbar-media-playonload'), vr: '' }, 
            { tp: 'Toggle', id: 'playonload', vl: true }, 
            { tp: 'Spacer', id: 'update', ht: 5 }, 
            { tp: 'Button', id: 'update', tx: Global.ln.get('rightbar-media-update'), ac: onUpdate }, 
            { tp: 'Spacer', id: 'update', ht: 5 }, 
            { tp: 'Button', id: 'update', tx: Global.ln.get('rightbar-media-cache'), ac: onCache }, 
            { tp: 'Spacer', id: 'remove', ht: 10 }, 
            { tp: 'Button', id: 'remove', tx: Global.ln.get('rightbar-media-remove'), ac: onRemove }
        ], 0x333333, (wd - 5));
        this.ui.containers['properties'].enabled = false;
        Global.history.propDisplay.push(this.updateValues);
    }

    override public function updateContent(data:Map<String, Dynamic> = null):Void {
        if (data.exists('nm')) {
            this._current = GlobalPlayer.area.instanceRef(data['nm']);
            this.updateValues();
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
        if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
        GlobalPlayer.area.setCurrentPrecache();
        this.ui.toggles['playonload'].selected = false;
        Global.history.addState(Global.ln.get('rightbar-history-cache'));
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


}