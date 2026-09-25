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

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;

class WindowExchangeMakers extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-exchmakers-title'), 1000, InterfaceFactory.pickValue(300, 320), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-exchmakers-title'), this.ui.forge('pwa', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchmakers-about'), vr: '' }, 
            { tp: 'Label', id: 'platform', tx: Global.ln.get('window-exchmakers-platform'), vr: '' }, 
            { tp: 'Select', id: 'platform', vl: [
                { text: Global.ln.get('window-exchmakers-esp32'), value: 'esp32' }, 
            ], sl: 'esp32' }, 
            { tp: 'Label', id: 'ip', tx: Global.ln.get('window-exchmakers-ip'), vr: '' }, 
            { tp: 'TInput', id: 'ip', vl: '192.168.4.1', vr: '' }, 
            { tp: 'Spacer', id: 'export', ht: 20 }, 
            { tp: 'Button', id: 'export', tx: Global.ln.get('window-exchmakers-button'), ac: this.onExport }
        ]));
        this.ui.labels['about'].wordWrap = true;
        super.startInterface();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        this.ui.setSelectValue('platform', 'esp32');
        this.ui.inputs['ip'].text = '192.168.4.1';
    }

    /**
        Start movie export.
    **/
    private function onExport(evt:TriggerEvent):Void {
        if (this.ui.inputs['ip'].text == '') {
            this.ui.createWarning(Global.ln.get('window-exchmakers-title'), Global.ln.get('window-exchmakers-noip'), 300, 180, this.stage);
        } else {
            var regex = ~/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;
            if (!regex.match(this.ui.inputs['ip'].text)) {
                this.ui.createWarning(Global.ln.get('window-exchmakers-title'), Global.ln.get('window-exchmakers-noip'), 300, 180, this.stage);
            } else {
                var limitnum:Bool = true;
                for (i in 1...5) {
                    var num = Std.parseInt(regex.matched(i));
                    if (num < 0 || num > 255) limitnum = false;
                }
                if (!limitnum) {
                    this.ui.createWarning(Global.ln.get('window-exchmakers-title'), Global.ln.get('window-exchmakers-noip'), 300, 180, this.stage);
                } else {
                    Global.ws.send('Movie/ExportMakers', [
                        'movie' => GlobalPlayer.movie.mvId, 
                        'ip' => this.ui.inputs['ip'].text, 
                        'platform' => this.ui.selects['platform'].selectedItem.value
                    ], onExportReturn);
                }
            }
        }
    }

    /**
        Movie export return.
    **/
    private function onExportReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-exchmakers-title'), Global.ln.get('window-exchmakers-error'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-exchmakers-title'), Global.ln.get('window-exchmakers-error'), 300, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-exchmakers-title'), Global.ln.get('window-exchmakers-ok'), 320, 200, this.stage);
            Global.ws.download([
                'file' => 'makers', 
                'movie' => GlobalPlayer.movie.mvId,  
            ]);
        }
    }

}