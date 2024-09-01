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
        super(ac, Global.ln.get('window-exchpwa-title'), 1000, 520, false);
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
        this.ui.inputs['url'].text = '';
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
                    'url' => url
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
            this.ui.createWarning(Global.ln.get('window-exchpwa-title'), Global.ln.get('window-exchpwa-ok'), 320, 200, this.stage);
            Global.ws.download([
                'file' => 'pwa', 
                'movie' => GlobalPlayer.movie.mvId,  
            ]);
        }
    }

}