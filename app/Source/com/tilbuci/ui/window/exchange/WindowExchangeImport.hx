/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.exchange;

/** OPENFL **/
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

class WindowExchangeImport extends PopupWindow {

    /**
        id request form
    **/
    private var _idform:InterfaceContainer;

    /**
        upload form
    **/
    private var _uploadform:InterfaceContainer;

    /**
        import movie id
    **/
    private var _movieid:String = '';

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-exchimport-title'), 800, 200, false);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {

        // upload form
        this._uploadform = this.ui.forge('upload', [
            { tp: 'Label', id: 'aboutupload', tx: Global.ln.get('window-exchimport-aboutupload'), vr: '' },  
            { tp: 'Spacer', id: 'import', ht: 30 },  
            { tp: 'Button', id: 'importsend', tx: Global.ln.get('window-exchimport-buttonselectzip'), ac: this.onSelectZip },
            { tp: 'Button', id: 'importalready', tx: Global.ln.get('window-exchimport-buttonalready'), ac: this.onAlreadyZip },
        ]);
        this.addForm('uploadform', this._uploadform);
        this.ui.labels['aboutupload'].wordWrap = true;

        // id form
        this._idform = this.ui.forge('id', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchimport-aboutid'), vr: '' }, 
            { tp: 'TInput', id: 'movieid', tx: '', vr: '' },  
            { tp: 'Spacer', id: 'import', ht: 30 },  
            { tp: 'Button', id: 'import', tx: Global.ln.get('window-exchimport-buttonid'), ac: this.onCheckId }
        ]);
        this.addForm('idform', this._idform);
        this.ui.labels['about'].wordWrap = true;

        super.startInterface();
        this._forms.removeChild(this._uploadform);
    }

    /**
        Initialize window.
    **/
    override public function acStart():Void {
        this._forms.removeChildren();
        this._forms.addChild(this._idform);
        this._movieid = '';
        this.ui.inputs['movieid'].text = '';
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Start movie export.
    **/
    private function onCheckId(evt:TriggerEvent):Void {
        this._movieid = '';
        if (this.ui.inputs['movieid'].text.length >= 3) {
            Global.ws.send('Movie/ImportID', [
                'movie' => this.ui.inputs['movieid'].text, 
            ], onCheckIdReturn);
        }
    }

    /**
       ID check return.
    **/
    private function onCheckIdReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-error'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-errorid'), 300, 180, this.stage);
        } else {
            this.ui.labels['aboutupload'].text = StringTools.replace(Global.ln.get('window-exchimport-aboutupload'), '[NAME]', ld.map['imp']);
            this.ui.buttons['importalready'].text = StringTools.replace(Global.ln.get('window-exchimport-buttonalready'), '[NAME]', ld.map['imp']);
            this._movieid = ld.map['imp'];
            this._forms.removeChild(this._idform);
            this._forms.addChild(this._uploadform);
        }
    }

    /**
        Selects a zip file to upload.
    **/
    private function onSelectZip(evt:TriggerEvent):Void {
        Global.up.browseForMedia(onFileSelcted, 'movie');
    }

    /**
        A new file was selected.
        @param  ok  file correctly selected?
    **/
    private function onFileSelcted(ok:Bool):Void {
        if (ok) {
            Global.up.uploadMedia(onUploadReturn, [
                'movie' => this._movieid, 
                'type' => 'movie', 
                'path' => ''
            ]);
        }
    }

    /**
        Upload return.
    **/
    private function onUploadReturn(ok:Bool, data:Map<String, Dynamic> = null):Void {
        if (ok) {
            Global.ws.send('Movie/ImportZip', [
                'movie' => this._movieid, 
            ], onZipReturn);
        } else {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-errorsend'), 300, 180, this.stage);
        }
    }

    /**
        The zip file is already on server.
    **/
    private function onAlreadyZip(evt:TriggerEvent):Void {
        Global.ws.send('Movie/ImportZip', [
            'movie' => this._movieid, 
        ], onZipReturn);
    }

    /**
       Zip import return.
    **/
    private function onZipReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-errorimport'), 300, 180, this.stage);
        } else if (ld.map['e'] == 0) {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-impok'), 300, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else if (ld.map['e'] == 1) {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-errorimp1'), 300, 180, this.stage);
            this.acStart();
        } else if (ld.map['e'] == 2) {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-errorimp2'), 300, 180, this.stage);
            this.acStart();
        } else if (ld.map['e'] == 3) {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-errorimp3'), 300, 180, this.stage);
            this.acStart();
        } else if (ld.map['e'] == 4) {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-errorimp4'), 300, 180, this.stage);
            this.acStart();
        } else if (ld.map['e'] == 5) {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-errorimp5'), 300, 180, this.stage);
            this.acStart();
        } else if (ld.map['e'] == 6) {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-errorimp6'), 300, 180, this.stage);
            this.acStart();
        } else {
            this.ui.createWarning(Global.ln.get('window-exchimport-title'), Global.ln.get('window-exchimport-errorimport'), 300, 180, this.stage);
            this.acStart();
        }
    }

}