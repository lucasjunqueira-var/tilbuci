/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.exchange;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
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

class WindowExchangePwa extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-exchpwa-title'), 1000, 590, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-exchpwa-title'), this.ui.forge('pwa', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchpwa-about'), vr: '' }, 
            { tp: 'Label', id: 'name', tx: Global.ln.get('window-exchpwa-name'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'name', vl: '', vr: '' }, 
            { tp: 'Label', id: 'shortname', tx: Global.ln.get('window-exchpwa-shortname'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'shortname', vl: '', vr: '' }, 
            { tp: 'Label', id: 'lang', tx: Global.ln.get('window-exchpwa-language'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'lang', vl: '', vr: '' }, 
            { tp: 'Label', id: 'icon', tx: Global.ln.get('window-exchpwa-icon'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'icon', vl: '', vr: '' }, 
            { tp: 'Label', id: 'location', tx: Global.ln.get('window-exchpwa-location'), vr: '' }, 
            { tp: 'Select', id: 'location', vl: [
                { text: Global.ln.get('window-exchpwa-locsite'), value: 'pwa' }, 
                { text: Global.ln.get('window-exchpwa-loczip'), value: 'zip' }, 
            ], sl: 'sites', ch: onChangeLocation }, 
            { tp: 'Label', id: 'url', tx: Global.ln.get('window-exchpwa-url'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'url', vl: '', vr: '' }, 
            { tp: 'Spacer', id: 'export', ht: 20 }, 
            { tp: 'Button', id: 'export', tx: Global.ln.get('window-exchpwa-button'), ac: this.onExport }
        ]));
        this.ui.labels['about'].wordWrap = true;
        this.ui.inputs['shortname'].maxChars = 12;
        super.startInterface();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        this.ui.inputs['name'].text = GlobalPlayer.mdata.title;
        if (GlobalPlayer.mdata.title.length <= 12) {
            this.ui.inputs['shortname'].text = GlobalPlayer.mdata.title;
        } else {
            this.ui.inputs['shortname'].text = '';
        }
        this.ui.inputs['lang'].text = 'en-US';
        this.ui.inputs['icon'].text = GlobalPlayer.mdata.favicon;
        this.ui.inputs['icon'].enabled = false;
        this.ui.setSelectValue('location', 'pwa');
        this.ui.inputs['url'].text = StringTools.replace((Global.econfig.base + 'pwa/' + GlobalPlayer.movie.mvId + '/'), '/editor/', '/');
    }

    private function onChangeLocation(evt:Event):Void {
        if (this.ui.selects['location'].selectedItem.value == 'zip') {
            this.ui.inputs['url'].text = '';
        } else {
            this.ui.inputs['url'].text = StringTools.replace((Global.econfig.base + 'pwa/' + GlobalPlayer.movie.mvId + '/'), '/editor/', '/');
        }
    }

    /**
        Start movie export.
    **/
    private function onExport(evt:TriggerEvent):Void {
        if ((this.ui.inputs['name'].text.length < 3) || (this.ui.inputs['shortname'].text.length < 3)) {
            this.ui.createWarning(Global.ln.get('window-exchpwa-title'), Global.ln.get('window-exchpwa-noname'), 300, 180, this.stage);
        } else if ((this.ui.inputs['icon'].text == '') || (this.ui.inputs['icon'].text.toLowerCase().substr(-3) != 'png')) {
            this.ui.createWarning(Global.ln.get('window-exchpwa-title'), Global.ln.get('window-exchpwa-nopng'), 300, 180, this.stage);
        } else if (this.ui.inputs['lang'].text.length < 5) {
            this.ui.createWarning(Global.ln.get('window-exchpwa-title'), Global.ln.get('window-exchpwa-nolang'), 300, 180, this.stage);
        } else {
            var url:String = this.ui.inputs['url'].text.toLowerCase();
            if (url.substr(0, 8) != 'https://') {
                this.ui.createWarning(Global.ln.get('window-exchpwa-title'), Global.ln.get('window-exchpwa-nourl'), 300, 180, this.stage);
            } else {
                Global.ws.send('Movie/ExportPwa', [
                    'movie' => GlobalPlayer.movie.mvId, 
                    'name' => this.ui.inputs['name'].text, 
                    'shortname' => this.ui.inputs['shortname'].text, 
                    'lang' => this.ui.inputs['lang'].text, 
                    'url' => url, 
                    'location' => this.ui.selects['location'].selectedItem.value
                ], onExportReturn);
            }
        }
    }

    /**
        Movie export return.
    **/
    private function onExportReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-exchpwa-title'), Global.ln.get('window-exchpwa-error'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-exchpwa-title'), Global.ln.get('window-exchpwa-error'), 300, 180, this.stage);
        } else {
            if (StringTools.contains(ld.map['exp'], '.zip')) {
                this.ui.createWarning(Global.ln.get('window-exchpwa-title'), Global.ln.get('window-exchpwa-ok'), 320, 200, this.stage);
                Global.ws.download([
                    'file' => 'pwa', 
                    'movie' => GlobalPlayer.movie.mvId,  
                ]);
            } else {
                var txt:String = StringTools.replace(Global.ln.get('window-exchpwa-siteok'), '[URL]', ld.map['exp']);
                this.ui.createWarning(Global.ln.get('window-exchpwa-title'), txt, 320, 150, this.stage);
                Global.ws.openurl(ld.map['exp']);
            }
        }
    }

}