/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.movie;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
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
import com.tilbuci.ui.base.InterfaceContainer;

class WindowMovieNewPDF extends PopupWindow {

    /**
        movie information form
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
        super(ac, Global.ln.get('window-movienewpdf-title'), 800, InterfaceFactory.pickValue(330, 420), false);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // information form
        this._infoform =this.ui.forge('info', [
            { tp: 'Label', id: 'movieid', tx: Global.ln.get('window-movienewpdf-id'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'movieid', tx: '', vr: '' },  
            { tp: 'Label', id: 'movieauthor', tx: Global.ln.get('window-movienewpdf-author'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'movieauthor', tx: '', vr: '' }, 
            { tp: 'Label', id: 'movietime', tx: Global.ln.get('window-movienewpdf-timeframe'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'movietime', vl: [
                { text: Global.ln.get('window-movienew-time025'), value: "0.25" }, 
                { text: Global.ln.get('window-movienew-time050'), value: "0.50" }, 
                { text: Global.ln.get('window-movienew-time100'), value: "1.00" }, 
                { text: Global.ln.get('window-movienew-time150'), value: "1.50" }, 
                { text: Global.ln.get('window-movienew-time200'), value: "2.00" }, 
                { text: Global.ln.get('window-movienew-time250'), value: "2.50" }, 
                { text: Global.ln.get('window-movienew-time300'), value: "3.00" }, 
                { text: Global.ln.get('window-movienew-time350'), value: "3.50" }, 
                { text: Global.ln.get('window-movienew-time400'), value: "4.00" }, 
                { text: Global.ln.get('window-movienew-time450'), value: "4.50" }, 
                { text: Global.ln.get('window-movienew-time500'), value: "5.00" }, 
                ], sl: '1.00' },
            { tp: 'Label', id: 'moviemodel', tx: Global.ln.get('window-movienewpdf-model'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'moviemodel', vl: [
                { text: Global.ln.get('window-movienewpdf-modelstandard'), value: "pdfbase" }, 
                { text: Global.ln.get('window-movienewpdf-modelinterface'), value: "pdfinterface" }, 
                ], sl: '1.00' },
            { tp: 'Spacer', id: 'font-spacer', ht: 20, ln: false }, 
            { tp: 'Button', id: 'moviecreate', tx: Global.ln.get('window-movienewpdf-create'), ac: this.onCreateMovie }
        ]);
        this.addForm('infoform', this._infoform);

        // upload form
        this._uploadform = this.ui.forge('upload', [
            { tp: 'Label', id: 'aboutpdf', tx: Global.ln.get('window-movienewpdf-about'), vr: '' },  
            { tp: 'Spacer', id: 'import', ht: 120 },  
            { tp: 'Button', id: 'importsend', tx: Global.ln.get('window-movienewpdf-buttonselect'), ac: this.onSelect },
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
        }
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
            this.ui.createWarning(Global.ln.get('window-movienewpdf-title'), Global.ln.get('window-movienewpdf-errorsend'), 300, 180, this.stage);
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Asks for a movie creation on server.
    **/
    private function onCreateMovie(evt:TriggerEvent):Void {
        if (this.ui.inputs['movieauthor'].text == '') {
            this.ui.createWarning(Global.ln.get('window-movienewpdf-title'), Global.ln.get('window-movienewpdf-norequired'), 300, 180, this.stage);
        } else {
            Global.ws.send('Movie/NewPdf', [
                'id' => this.ui.inputs['movieid'].text, 
                'author' => this.ui.inputs['movieauthor'].text, 
                'interval' => this.ui.selects['movietime'].selectedItem.value, 
                'model'=> this.ui.selects['moviemodel'].selectedItem.value
            ], onCreateMovieReturn);
        }
    }

    /**
        Movie creration return.
    **/
    private function onCreateMovieReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-movienewpdf-title'), Global.ln.get('window-movienewpdf-createer'), 300, 180, this.stage);
        } else if (ld.map['e'] == 1) {
            this.ui.createWarning(Global.ln.get('window-movienewpdf-title'), Global.ln.get('window-movienewpdf-createer1'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-movienewpdf-title'), Global.ln.get('window-movienewpdf-createer'), 300, 180, this.stage);
        } else {
            this._forms.removeChild(this._infoform);
            this._forms.addChild(this._uploadform);
            GlobalPlayer.area.imgSelect();
            PopUpManager.removePopUp(this);
            this._ac('movieload', [ 'id' => ld.map['id'] ]);
        }
    }

}