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

class WindowExchangeWebsite extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-exchsite-title'), 800, 320, false);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-exchsite-title'), this.ui.forge('leftcol', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchsite-about'), vr: '' }, 
            { tp: 'Spacer', id: 'mode', ht: 10 },  
            { tp: 'Label', id: 'mode', tx: Global.ln.get('window-exchsite-mode'), vr: '' }, 
            { tp: 'Select', id: 'mode', vl: [
                { text: Global.ln.get('window-exchsite-webgl'), value: 'webgl' }, 
                { text: Global.ln.get('window-exchsite-dom'), value: 'dom' }, 
            ], sl: 'webgl' }, 
            { tp: 'Spacer', id: 'sitemap', ht: 10 },  
            { tp: 'Label', id: 'sitemap', tx: Global.ln.get('window-exchsite-sitemap'), vr: '' }, 
            { tp: 'TInput', id: 'sitemap', tx: '', vr: '' }, 
            { tp: 'Spacer', id: 'export', ht: 10 },  
            { tp: 'Button', id: 'export', tx: Global.ln.get('window-exchexport-button'), ac: this.onExport }
        ]));

        this.ui.labels['about'].wordWrap = true;
        this.ui.labels['sitemap'].wordWrap = true;

        super.startInterface();
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
    private function onExport(evt:TriggerEvent):Void {
        Global.ws.send('Movie/ExportSite', [
            'movie' => GlobalPlayer.movie.mvId, 
            'mode' => this.ui.selects['mode'].selectedItem.value, 
            'sitemap' => this.ui.inputs['sitemap'].text, 
        ], onExportReturn);
    }

    /**
        Movie export return.
    **/
    private function onExportReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-exchsite-title'), Global.ln.get('window-exchsite-error'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-exchsite-title'), Global.ln.get('window-exchsite-error'), 300, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-exchsite-title'), Global.ln.get('window-exchsite-ok'), 320, 200, this.stage);
            Global.ws.download([
                'file' => 'website', 
                'movie' => GlobalPlayer.movie.mvId,  
            ]);
        }
    }

}