/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.scene;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.ui.base.InterfaceContainer;
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

class WindowSceneNewPdf extends PopupWindow {

    /**
        scene information form
    **/
    private var _infoform:InterfaceContainer;

    /**
        upload form
    **/
    private var _uploadform:InterfaceContainer;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-scenenewpdf-title'), 800, InterfaceFactory.pickValue(250, 360), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // information form
        this._infoform = this.ui.forge('info', [
            { tp: 'Label', id: 'scenename', tx: Global.ln.get('window-scenenewpdf-name'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'scenename', tx: '', vr: '' },
            { tp: 'Label', id: 'scenepage', tx: Global.ln.get('window-scenenewpdf-page'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Numeric', id: 'scenepage', mn: 1, mx: 10000, vl: 1, st: 1 }, 
            { tp: 'Spacer', id: 'font-spacer', ht: 20, ln: false }, 
            { tp: 'Button', id: 'moviecreate', tx: Global.ln.get('window-scenenewpdf-create'), ac: this.onCreateScene }
        ]);
        this.addForm('infoform', this._infoform);

        // upload form
        this._uploadform = this.ui.forge('upload', [
            { tp: 'Label', id: 'aboutpdf', tx: Global.ln.get('window-scenenewpdf-about'), vr: '' },  
            { tp: 'Spacer', id: 'import', ht: 120 },  
            { tp: 'Button', id: 'importsend', tx: Global.ln.get('window-scenenewpdf-buttonselect'), ac: this.onSelect },
        ]);
        this.addForm('uploadform', this._uploadform);
        this.ui.labels['aboutpdf'].wordWrap = true;

        super.startInterface();
        this._forms.removeChild(this._infoform);
    }

    override public function acStart():Void {
        if (this._forms != null) {
            this._forms.removeChildren();
            if (this._uploadform != null) this._forms.addChild(this._uploadform);
            this.ui.inputs['scenename'].text = '';
            this.ui.numerics['scenepage'].value = 1;
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Selects a pdf file to upload.
    **/
    private function onSelect(evt:TriggerEvent):Void {
        Global.up.browseForMedia(onFileSelected, 'pdfmovie');
    }

    /**
        A new file was selected.
        @param  ok  file correctly selected?
    **/
    private function onFileSelected(ok:Bool):Void {
        if (ok) {
            Global.up.uploadMedia(onUploadReturn, [
                'movie' => '', 
                'type' => 'pdfmovie', 
                'path' => ''
            ]);
        }
    }

    /**
        Upload return.
    **/
    private function onUploadReturn(ok:Bool, data:Map<String, Dynamic> = null):Void {
        if (ok) {
            this._forms.removeChild(this._uploadform);
            this._forms.addChild(this._infoform);
        } else {
            this.ui.createWarning(Global.ln.get('window-scenenewpdf-title'), Global.ln.get('window-movienewpdf-errorsend'), 300, 180, this.stage);
        }
    }

    /**
        Asks for a scene creation on server.
    **/
    private function onCreateScene(evt:TriggerEvent):Void {
        if (this.ui.inputs['scenename'].text == '') {
            this.ui.createWarning(Global.ln.get('window-scenenew-title'), Global.ln.get('window-scenenew-norequired'), 300, 180, this.stage);
        } else {
            Global.ws.send('Scene/NewPdf', [
                'title' => this.ui.inputs['scenename'].text, 
                'page' => this.ui.numerics['scenepage'].value, 
                'movie' => GlobalPlayer.movie.mvId, 
            ], onCreateSceneReturn);
        }
    }

    /**
        Scene creation return.
    **/
    private function onCreateSceneReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-scenenewpdf-title'), Global.ln.get('window-scenenewpdf-createer'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-scenenewpdf-title'), Global.ln.get('window-scenenewpdf-createer'), 300, 180, this.stage);
        } else {
            GlobalPlayer.area.imgSelect();
            this.ui.inputs['scenename'].text = '';
            this.ui.numerics['scenepage'].value = 1;
            PopUpManager.removePopUp(this);
            this._ac('sceneload', [ 'id' => ld.map['id'] ]);
            Global.acInfo.loadInfo(true);
        }
    }

}