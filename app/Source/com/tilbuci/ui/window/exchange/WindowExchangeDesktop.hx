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

class WindowExchangeDesktop extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-exchdesk-title'), 1000, 550, false);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.addForm(Global.ln.get('window-exchdesk-title'), this.ui.forge('desk', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchdesk-about'), vr: '' },  
            { tp: 'Spacer', id: 'about', ht: 10, ln: false }, 
            { tp: 'Label', id: 'os', tx: Global.ln.get('window-exchdesk-os'), vr: Label.VARIANT_DETAIL },  
            { tp: 'Select', id: 'os', vl: [
                { text: Global.ln.get('window-exchdesk-oswindows'), value: 'windows' }, 
                { text: Global.ln.get('window-exchdesk-oslinux'), value: 'linux' }, 
                { text: Global.ln.get('window-exchdesk-osmacintel'), value: 'macosintel' }, 
                { text: Global.ln.get('window-exchdesk-osmacsilicon'), value: 'macossilicon' }, 
            ], sl: 'windows' }, 
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
            { tp: 'Spacer', id: 'export', ht: 10, ln: false }, 
            { tp: 'Button', id: 'export', tx: Global.ln.get('window-exchdesk-button'), ac: this.onExport }, 
            { tp: 'Spacer', id: 'nw', ht: 50, ln: true }, 
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
    }

    /**
        Open nw.js site.
    **/
    private function onNw(evt:TriggerEvent):Void {
        var req:URLRequest = new URLRequest('https://nwjs.io/');
        req.method = 'GET';
        Lib.getURL(req);
    }

    /**
        Start movie export.
    **/
    private function onExport(evt:TriggerEvent):Void {
        Global.ws.send('Movie/ExportDesk', [
            'movie' => GlobalPlayer.movie.mvId, 
            'os' => this.ui.selects['os'].selectedItem.value, 
            'window' => this.ui.selects['window'].selectedItem.value, 
            'width' => Math.round(this.ui.numerics['width'].value), 
            'height' => Math.round(this.ui.numerics['height'].value)
        ], onExportReturn, 12000000);
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