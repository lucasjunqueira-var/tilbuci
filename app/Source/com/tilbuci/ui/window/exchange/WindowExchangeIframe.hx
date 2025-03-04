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

class WindowExchangeIframe extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-exchiframe-title'), 800, 280, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-exchiframe-title'), this.ui.forge('leftcol', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchiframe-about'), vr: '' }, 
            { tp: 'Spacer', id: 'mode', ht: 10 },   
            { tp: 'Label', id: 'location', tx: Global.ln.get('window-exchiframe-location'), vr: '' }, 
            { tp: 'Select', id: 'location', vl: [
                { text: Global.ln.get('window-exchiframe-locsite'), value: 'sites' }, 
                { text: Global.ln.get('window-exchiframe-loczip'), value: 'zip' }, 
            ], sl: 'sites' }, 
            { tp: 'Spacer', id: 'export', ht: 10 },  
            { tp: 'Button', id: 'export', tx: Global.ln.get('window-exchiframe-button'), ac: this.onExport }
        ]));

        this.ui.labels['about'].wordWrap = true;

        super.startInterface();
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        this.ui.setSelectValue('location', 'sites');
    }

    /**
        Start movie export.
    **/
    private function onExport(evt:TriggerEvent):Void {
        Global.ws.send('Movie/ExportIframe', [
            'movie' => GlobalPlayer.movie.mvId, 
            'location' => this.ui.selects['location'].selectedItem.value, 
        ], onExportReturn);
    }

    /**
        Movie export return.
    **/
    private function onExportReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-exchiframe-title'), Global.ln.get('window-exchiframe-error'), 300, 150, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-exchiframe-title'), Global.ln.get('window-exchiframe-error'), 300, 150, this.stage);
        } else {
            if (StringTools.contains(ld.map['exp'], '.zip')) {
                this.ui.createWarning(Global.ln.get('window-exchiframe-title'), Global.ln.get('window-exchiframe-ok'), 320, 180, this.stage);
                Global.ws.download([
                    'file' => 'website', 
                    'movie' => GlobalPlayer.movie.mvId,  
                ]);
            } else {
                var txt:String = StringTools.replace(Global.ln.get('window-exchiframe-siteok'), '[URL]', ld.map['exp']);
                this.ui.createWarning(Global.ln.get('window-exchiframe-title'), txt, 320, 150, this.stage);
                Global.ws.openurl(ld.map['exp']);
            }
        }
    }

}