/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.exchange;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.GlobalPlayer;
import openfl.events.Event;
import openfl.display.Stage;
import openfl.Lib;
import openfl.net.URLRequest;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;

class WindowExchangeDesktop extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-exchdesk-title'), 1000, InterfaceFactory.pickValue(650, 730), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.addForm(Global.ln.get('window-exchdesk-title'), this.ui.forge('desk', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchdesk-about'), vr: '' },  
            { tp: 'Spacer', id: 'about', ht: 10, ln: false }, 
            { tp: 'Label', id: 'mode', tx: Global.ln.get('window-exchdesk-mode'), vr: Label.VARIANT_DETAIL },  
            { tp: 'Select', id: 'mode', vl: [
                { text: Global.ln.get('window-exchdesk-full'), value: 'full' }, 
                { text: Global.ln.get('window-exchdesk-update'), value: 'update' }, 
            ], sl: 'full' }, 
            { tp: 'Label', id: 'window', tx: Global.ln.get('window-exchdesk-window'), vr: Label.VARIANT_DETAIL },  
            { tp: 'Select', id: 'window', vl: [
                { text: Global.ln.get('window-exchdesk-windownormal'), value: 'normal' }, 
                { text: Global.ln.get('window-exchdesk-windowresize'), value: 'resize' }, 
                { text: Global.ln.get('window-exchdesk-windowfull'), value: 'full' }, 
                { text: Global.ln.get('window-exchdesk-windowkiosk'), value: 'kiosk' }, 
            ], sl: 'normal' }, 
            { tp: 'Label', id: 'width', tx: Global.ln.get('window-exchdesk-width'), vr: Label.VARIANT_DETAIL },  
            { tp: 'Numeric', id: 'width', mn: 240, mx: 1920, vl: 1280, st: 50 }, 
            { tp: 'Label', id: 'height', tx: Global.ln.get('window-exchdesk-height'), vr: Label.VARIANT_DETAIL },  
            { tp: 'Numeric', id: 'height', mn: 240, mx: 1920, vl: 720, st: 50 }, 
            { tp: 'Label', id: 'icon', tx: Global.ln.get('window-exchdesk-icon'), vr: Label.VARIANT_DETAIL}, 
            { tp: 'TInput', id: 'icon', tx: '', vr: '' }, 
            { tp: 'Label', id: 'author', tx: Global.ln.get('window-exchdesk-author'), vr: Label.VARIANT_DETAIL}, 
            { tp: 'TInput', id: 'author', tx: '', vr: '' }, 
            { tp: 'Label', id: 'description', tx: Global.ln.get('window-exchdesk-description'), vr: Label.VARIANT_DETAIL}, 
            { tp: 'TInput', id: 'description', tx: '', vr: '' }, 
            { tp: 'Spacer', id: 'export', ht: 10, ln: false }, 
            { tp: 'Button', id: 'export', tx: Global.ln.get('window-exchdesk-button'), ac: this.onExport }, 
            { tp: 'Spacer', id: 'nw', ht: 20, ln: true }, 
            { tp: 'Label', id: 'nw', tx: Global.ln.get('window-exchdesk-aboutnw'), vr: '' },  
            { tp: 'Button', id: 'nw', tx: Global.ln.get('window-exchdesk-buttonnw'), ac: this.onNw }
        ]));
        this.ui.labels['about'].wordWrap = true;
        this.ui.labels['nw'].wordWrap = true;
        super.startInterface();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        if (GlobalPlayer.mdata.screen.type == 'portrait') {
            this.ui.numerics['height'].value = 600;
            this.ui.numerics['width'].value = Math.round(GlobalPlayer.mdata.screen.big * 600 / GlobalPlayer.mdata.screen.small);
        } else {
            this.ui.numerics['width'].value = 1280;
            this.ui.numerics['height'].value = Math.round(GlobalPlayer.mdata.screen.small * 1280 / GlobalPlayer.mdata.screen.big);
        }
        this.ui.inputs['icon'].enabled = false;
        this.ui.inputs['icon'].text = GlobalPlayer.mdata.favicon;
        this.ui.inputs['author'].enabled = false;
        this.ui.inputs['author'].text = GlobalPlayer.mdata.author;
        this.ui.inputs['description'].enabled = false;
        this.ui.inputs['description'].text = GlobalPlayer.mdata.description;
    }

    /**
        Open electron site.
    **/
    private function onNw(evt:TriggerEvent):Void {
        var req:URLRequest = new URLRequest('https://www.electronjs.org/');
        req.method = 'GET';
        Lib.getURL(req);
    }

    /**
        Start movie export.
    **/
    private function onExport(evt:TriggerEvent):Void {
        if ((GlobalPlayer.mdata.favicon == '') || (GlobalPlayer.mdata.author == '') || (GlobalPlayer.mdata.description == '')) {
            this.ui.createWarning(Global.ln.get('window-exchdesk-title'), Global.ln.get('window-exchdesk-errormiss'), 300, 180, this.stage);
        } else {
            Global.ws.send('Movie/ExportDesk', [
                'movie' => GlobalPlayer.movie.mvId, 
                'mode' => this.ui.selects['mode'].selectedItem.value, 
                'window' => this.ui.selects['window'].selectedItem.value, 
                'width' => Math.round(this.ui.numerics['width'].value), 
                'height' => Math.round(this.ui.numerics['height'].value), 
                'favicon' => GlobalPlayer.mdata.favicon, 
                'author' => GlobalPlayer.mdata.author, 
                'description' => GlobalPlayer.mdata.description, 
                'title' => GlobalPlayer.mdata.title
            ], onExportReturn, 12000000);
        }
        
    }

    /**
        Movie export return.
    **/
    private function onExportReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-exchdesk-title'), Global.ln.get('window-exchdesk-error'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-exchdesk-title'), Global.ln.get('window-exchdesk-error'), 300, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-exchdesk-title'), Global.ln.get('window-exchdesk-ok'), 320, 200, this.stage);
            Global.ws.download([
                'file' => 'desk', 
                'exp' => ld.map['exp'], 
                'movie' => GlobalPlayer.movie.mvId,  
            ]);
        }
    }

}