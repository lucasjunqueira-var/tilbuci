/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.exchange;

/** OPENFL **/
import openfl.Assets;
import openfl.display.Bitmap;
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

class WindowExchangeCordova extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-exchcord-title'), 1100, 655, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {

        this.ui.createHContainer('icon');
        this.ui.createTInput('icon', '', '', this.ui.hcontainers['icon']);
        this.ui.createIconButton('icon', onIcon, new Bitmap(Assets.getBitmapData('btOpenfile')), null, this.ui.hcontainers['icon']);
        this.ui.inputs['icon'].enabled = false;

        this.addForm(Global.ln.get('window-exchcord-title'), this.ui.forge('desk', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchcord-about'), vr: '' },  
            { tp: 'Spacer', id: 'about', ht: 5, ln: false }, 
            { tp: 'Label', id: 'mode', tx: Global.ln.get('window-exchcord-export'), vr: Label.VARIANT_DETAIL },  
            { tp: 'Select', id: 'mode', vl: [
                { text: Global.ln.get('window-exchcord-complete'), value: 'complete' }, 
                { text: Global.ln.get('window-exchcord-update'), value: 'update' }, 
            ], sl: 'complete' }, 
            { tp: 'Label', id: 'appid', tx: Global.ln.get('window-exchcord-appid'), vr: Label.VARIANT_DETAIL },  
            { tp: 'TInput', id: 'appid', tx: '', vr: '' }, 
            { tp: 'Label', id: 'appsite', tx: Global.ln.get('window-exchcord-appsite'), vr: Label.VARIANT_DETAIL },  
            { tp: 'TInput', id: 'appsite', tx: '', vr: '' }, 
            { tp: 'Label', id: 'applicense', tx: Global.ln.get('window-exchcord-applicense'), vr: Label.VARIANT_DETAIL },  
            { tp: 'TInput', id: 'applicense', tx: '', vr: '' }, 
            { tp: 'Label', id: 'appauthor', tx: Global.ln.get('window-exchcord-appauthor'), vr: Label.VARIANT_DETAIL },  
            { tp: 'TInput', id: 'appauthor', tx: '', vr: '' }, 
            { tp: 'Label', id: 'appemail', tx: Global.ln.get('window-exchcord-appemail'), vr: Label.VARIANT_DETAIL },  
            { tp: 'TInput', id: 'appemail', tx: '', vr: '' }, 
            { tp: 'Label', id: 'icon', tx: Global.ln.get('window-exchcord-icon'), vr: '' }, 
            { tp: 'Custom', cont: this.ui.hcontainers['icon'] }, 
            { tp: 'Label', id: 'fullscr', tx: Global.ln.get('window-exchcord-fullscr'), vr: '' }, 
            { tp: 'Toggle', id: 'fullscr', vl: false }, 
            { tp: 'Spacer', id: 'export', ht: 5, ln: false }, 
            { tp: 'Button', id: 'export', tx: Global.ln.get('window-exchcord-button'), ac: this.onExport }, 
            { tp: 'Spacer', id: 'nw', ht: 10, ln: true }, 
            { tp: 'Label', id: 'cord', tx: Global.ln.get('window-exchcord-aboutcord'), vr: '' },  
            { tp: 'Button', id: 'cord', tx: Global.ln.get('window-exchcord-buttoncord'), ac: this.onCord }
        ]));
        this.ui.labels['about'].wordWrap = true;
        this.ui.labels['cord'].wordWrap = true;
        super.startInterface();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        if (StringTools.contains(Global.econfig.base, 'localhost') || StringTools.contains(Global.econfig.base, '127.0.0.1')) {
            this.ui.inputs['appid'].text = GlobalPlayer.movie.mvId.toLowerCase();
            this.ui.inputs['appsite'].text = '';
        } else {
            var parts:Array<String> = Global.econfig.base.toLowerCase().split('/');
            var reverse:String = '';
            var domain:String = '';
            for (i in 0...parts.length) {
                if ((reverse == '') && (parts[i] != '') && (parts[i] != 'http') && (parts[i] != 'http:') && (parts[i] != 'https') && (parts[i] != 'https:')) {
                    var dots:Array<String> = parts[i].split('.');
                    domain = parts[0] + '//' + dots.join('.') + '/';
                    dots.reverse();
                    reverse = dots.join('.');
                }
            }
            this.ui.inputs['appid'].text = reverse + '.' + GlobalPlayer.movie.mvId.toLowerCase();
            this.ui.inputs['appsite'].text = domain;
        }
        this.ui.inputs['applicense'].text = '';
        this.ui.inputs['appauthor'].text = GlobalPlayer.mdata.author;
        if (Global.ws.user.toLowerCase() == 'single') {
            this.ui.inputs['appemail'].text = '';
        } else {
            this.ui.inputs['appemail'].text = Global.ws.user;
        }
        this.ui.inputs['icon'].text = GlobalPlayer.mdata.favicon;
        this.ui.hcontainers['icon'].setWidth(1060, [1000, 50]);
    }

    /**
        Open Cordova site.
    **/
    private function onCord(evt:TriggerEvent):Void {
        var req:URLRequest = new URLRequest('https://cordova.apache.org/');
        req.method = 'GET';
        Lib.getURL(req);
    }

    /**
        Start movie export.
    **/
    private function onExport(evt:TriggerEvent):Void {
        var fullscr:String = 'false';
        if (this.ui.toggles['fullscr'].selected) fullscr = 'true';
        Global.ws.send('Movie/ExportCordova', [
            'movie' => GlobalPlayer.movie.mvId, 
            'mode' => this.ui.selects['mode'].selectedItem.value, 
            'appid' => this.ui.inputs['appid'].text, 
            'appsite' => this.ui.inputs['appsite'].text, 
            'appauthor' => this.ui.inputs['appauthor'].text, 
            'appemail' => this.ui.inputs['appemail'].text, 
            'applicense' => this.ui.inputs['applicense'].text, 
            'fullscr' => fullscr, 
            'icon' => this.ui.inputs['icon'].text
        ], onExportReturn);
    }

    /**
        Movie export return.
    **/
    private function onExportReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-exchcord-title'), Global.ln.get('window-exchcord-error'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-exchcord-title'), Global.ln.get('window-exchcord-error'), 300, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-exchcord-title'), Global.ln.get('window-exchcord-ok'), 320, 200, this.stage);
            Global.ws.download([
                'file' => 'desk', 
                'exp' => ld.map['exp'], 
                'movie' => GlobalPlayer.movie.mvId,  
            ]);
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'browsecordovaicon':
                this.ui.inputs['icon'].text = data['file'];
        }
    }

    private function onIcon(evt:Event):Void {
        this._ac('browsecordovaicon');
    }

}