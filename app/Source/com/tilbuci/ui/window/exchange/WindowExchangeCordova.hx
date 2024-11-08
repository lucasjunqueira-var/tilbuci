package com.tilbuci.ui.window.exchange;

/** OPENFL **/
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
        super(ac, Global.ln.get('window-exchcord-title'), 1100, 600, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.addForm(Global.ln.get('window-exchcord-title'), this.ui.forge('desk', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchcord-about'), vr: '' },  
            { tp: 'Spacer', id: 'about', ht: 10, ln: false }, 
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
            { tp: 'Spacer', id: 'export', ht: 10, ln: false }, 
            { tp: 'Button', id: 'export', tx: Global.ln.get('window-exchcord-button'), ac: this.onExport }, 
            { tp: 'Spacer', id: 'nw', ht: 30, ln: true }, 
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
        Global.ws.send('Movie/ExportCordova', [
            'movie' => GlobalPlayer.movie.mvId, 
            'mode' => this.ui.selects['mode'].selectedItem.value, 
            'appid' => this.ui.inputs['appid'].text, 
            'appsite' => this.ui.inputs['appsite'].text, 
            'appauthor' => this.ui.inputs['appauthor'].text, 
            'appemail' => this.ui.inputs['appemail'].text, 
            'applicense' => this.ui.inputs['applicense'].text
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

}