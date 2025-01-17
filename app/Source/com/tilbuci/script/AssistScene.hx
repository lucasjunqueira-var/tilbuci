/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.script;

/** OPENFL **/
import feathers.controls.Label;
import openfl.events.Event;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.component.IDButton;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.DataLoader;

class AssistScene extends PopupWindow {

    /**
        action buttons
    **/
    private var _idbuttons:Map<String, IDButton> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-acscene-title'), 500, 640, false);
        this._idbuttons['btCopyMovieLoad'] = new IDButton('copymovieload', onCopyMovieLoad, Global.ln.get('window-acmovie-copyload'), Assets.getBitmapData('btCopy'));
        this._idbuttons['btShowMovieLoad'] = new IDButton('showmovieload', onShowMovieLoad, Global.ln.get('window-acvariable-show'));
        this._idbuttons['btCopyId'] = new IDButton('copyid', onCopyId, Global.ln.get('window-acscene-copyid'), Assets.getBitmapData('btCopy'));
        this._idbuttons['btCopyLoad'] = new IDButton('copyload', onCopyLoad, (Global.ln.get('window-acscene-copyload')), Assets.getBitmapData('btCopy'));
        this._idbuttons['btShowLoad'] = new IDButton('showload', onShowLoad, Global.ln.get('window-acvariable-show'));
        this._idbuttons['btCopyAc'] = new IDButton('copyac', onCopy, (Global.ln.get('window-acscene-btaction')), Assets.getBitmapData('btCopy'));
        this._idbuttons['btShowAc'] = new IDButton('showac', onShow, (Global.ln.get('window-acvariable-show')));
        this.addForm(Global.ln.get('window-acscene-title'), this.ui.forge('form', [
            { tp: "Label", id: 'movielist', tx: Global.ln.get('window-acmovie-list'), vr: '' }, 
            { tp: "Select", id: 'movielist', vl: [ ], sl: [ ] }, 
            { tp: "Custom", cont: this._idbuttons['btCopyMovieLoad'] }, 
            { tp: "Custom", cont: this._idbuttons['btShowMovieLoad'] }, 
            { tp: 'Spacer', id: 'acmovie', ht: 15, ln: true }, 
            { tp: "Label", id: 'list', tx: Global.ln.get('window-acscene-list'), vr: '' }, 
            { tp: "Select", id: 'list', vl: [ ], sl: [ ], ht: 150 }, 
            { tp: "Custom", cont: this._idbuttons['btCopyId'] }, 
            { tp: "Custom", cont: this._idbuttons['btCopyLoad'] }, 
            { tp: "Custom", cont: this._idbuttons['btShowLoad'] }, 
            { tp: 'Spacer', id: 'ac', ht: 15, ln: true }, 
            { tp: "Label", id: 'actions', tx: Global.ln.get('window-acscene-actions'), vr: '' }, 
            { tp: 'Select', id: 'actions', vl: [
                { text: 'scene.navigate', value: 'scene.navigate' }, 
                { text: 'scene.pause', value: 'scene.pause' }, 
                { text: 'scene.play', value: 'scene.play' }, 
                { text: 'scene.playpause', value: 'scene.playpause' }, 
                { text: 'scene.nextkeyframe', value: 'scene.nextkeyframe' }, 
                { text: 'scene.previouskeyframe', value: 'scene.previouskeyframe' }, 
                { text: 'scene.loadfirstkeyframe', value: 'scene.loadfirstkeyframe' }, 
                { text: 'scene.loadlastkeyframe', value: 'scene.loadlastkeyframe' }, 
            ], sl: null }, 
            { tp: "Label", id: 'navigate', tx: Global.ln.get('window-acscene-navigate'), vr: '' }, 
            { tp: 'Select', id: 'navigate', vl: [
                { text: 'right', value: 'right' }, 
                { text: 'left', value: 'left' }, 
                { text: 'up', value: 'up' }, 
                { text: 'down', value: 'down' }, 
                { text: 'nin', value: 'nin' }, 
                { text: 'nout', value: 'nout' }, 
            ], sl: null }, 
            { tp: "Custom", cont: this._idbuttons['btCopyAc'] }, 
            { tp: "Custom", cont: this._idbuttons['btShowAc'] }, 
            { tp: "Button", id: "close", tx: Global.ln.get('window-actions-close'), ac: onClose }, 
            { tp: 'Spacer', id: 'showAction', ht: 10, ln: false }, 
            { tp: "Label", id: 'showAction', tx: Global.ln.get('window-globals-showaction'), vr: Label.VARIANT_DETAIL }, 
            { tp: "TInput", id: 'showAction', tx: '' }, 
        ]));
    }

    /**
        Window statup actions.
    **/
    override function acStart() {
        super.acStart();
        this.ui.setSelectOptions('movielist', [ ]);
        this.ui.setSelectValue('movielist', null);
        this.ui.setSelectOptions('list', [ ]);
        this.ui.setSelectValue('list', null);
        Global.ws.send('Movie/List', [ ], this.onList);
    }

    /**
        Interface initialize
    **/
    override function startInterface(evt:Event = null) {
        super.startInterface(evt);
        for (k in this._idbuttons.keys()) this._idbuttons[k].width = this.ui.buttons['close'].width;
    }

    /**
        Copies a scene ID.
    **/
    private function onCopyId(evt:TriggerEvent = null):Void {
        if (this.ui.selects['list'].selectedItem != null) {
            Global.copyText(this.ui.selects['list'].selectedItem.value);
            PopUpManager.removePopUp(this);
        }
    }

    /**
        Copies a scene load action.
    **/
    private function onCopyLoad(evt:TriggerEvent = null):Void {
        if (this.ui.selects['list'].selectedItem != null) {
            Global.copyText('{ "ac": "scene.load", "param": [ "' + this.ui.selects['list'].selectedItem.value + '" ] }');
            PopUpManager.removePopUp(this);
        }
    }

    /**
        Shows a scene load action.
    **/
    private function onShowLoad(evt:TriggerEvent = null):Void {
        if (this.ui.selects['list'].selectedItem != null) {
            this.ui.inputs['showAction'].text = '{ "ac": "scene.load", "param": [ "' + this.ui.selects['list'].selectedItem.value + '" ] }';
        }
    }

    /**
        Copies a movie load action.
    **/
    private function onCopyMovieLoad(evt:TriggerEvent = null):Void {
        if (this.ui.selects['movielist'].selectedItem != null) {
            Global.copyText('{ "ac": "movie.load", "param": [ "' + this.ui.selects['movielist'].selectedItem.value + '" ] }');
            PopUpManager.removePopUp(this);
        }
    }

    /**
        Shows a movie load action.
    **/
    private function onShowMovieLoad(evt:TriggerEvent = null):Void {
        if (this.ui.selects['movielist'].selectedItem != null) {
            this.ui.inputs['showAction'].text = '{ "ac": "movie.load", "param": [ "' + this.ui.selects['movielist'].selectedItem.value + '" ] }';
        }
    }

    /**
        Copies a scene action.
    **/
    private function onCopy(evt:TriggerEvent = null):Void {
        if (this.ui.selects['actions'].selectedItem != null) {
            if (this.ui.selects['actions'].selectedItem.value == 'scene.navigate') {
                Global.copyText('{ "ac": "' + this.ui.selects['actions'].selectedItem.value + '", "param": [ "' + this.ui.selects['navigate'].selectedItem.value + '" ] }');
            } else {
                Global.copyText('{ "ac": "' + this.ui.selects['actions'].selectedItem.value + '", "param": [ ] }');
            }
            PopUpManager.removePopUp(this);
        }
    }

    /**
        Shows a scene action.
    **/
    private function onShow(evt:TriggerEvent = null):Void {
        if (this.ui.selects['actions'].selectedItem != null) {
            if (this.ui.selects['actions'].selectedItem.value == 'scene.navigate') {
                this.ui.inputs['showAction'].text = '{ "ac": "' + this.ui.selects['actions'].selectedItem.value + '", "param": [ "' + this.ui.selects['navigate'].selectedItem.value + '" ] }';
            } else {
                this.ui.inputs['showAction'].text = '{ "ac": "' + this.ui.selects['actions'].selectedItem.value + '", "param": [ ] }';
            }
        }
    }

    /**
        Closes window.
    **/
    private function onClose(evt:TriggerEvent = null):Void {
        PopUpManager.removePopUp(this);
    }

    /**
        The movies list was just loaded.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 0) {
                for (n in Reflect.fields(ld.map['list'])) {
                    var it:Dynamic = Reflect.field(ld.map['list'], n);
                    if (Reflect.hasField(it, 'id')) {
                        list.push({
                            text: Reflect.field(it, 'title'), 
                            value: Reflect.field(it, 'id')
                        });
                    }
                }
            }
        }
        this.ui.setSelectOptions('movielist', list);
        Global.ws.send('Scene/List', [ 'movie' => GlobalPlayer.movie.mvId ], this.onSceneList);
    }

    /**
        The scenes list was just loaded.
    **/
    private function onSceneList(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 0) {
                for (n in Reflect.fields(ld.map['list'])) {
                    var it:Dynamic = Reflect.field(ld.map['list'], n);
                    if (Reflect.hasField(it, 'id')) {
                        list.push({
                            text: Reflect.field(it, 'title'), 
                            value: Reflect.field(it, 'id')
                        });
                    }
                }
            }
        }
        this.ui.setSelectOptions('list', list);
    }

}