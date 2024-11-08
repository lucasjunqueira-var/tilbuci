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

class WindowExchangePublish extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-exchpub-title'), 600, 200, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.addForm(Global.ln.get('window-exchpub-title'), this.ui.forge('pub', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchpub-about'), vr: '' },  
            { tp: 'Spacer', id: 'about', ht: 20, ln: false }, 
            { tp: 'Button', id: 'export', tx: Global.ln.get('window-exchpub-button'), ac: this.onExport }
        ]));
        this.ui.labels['about'].wordWrap = true;
        super.startInterface();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        super.acStart();
    }

    /**
        Start movie export.
    **/
    private function onExport(evt:TriggerEvent):Void {
        Global.ws.send('Movie/ExportPub', [
            'movie' => GlobalPlayer.movie.mvId, 
        ], onExportReturn);
    }

    /**
        Movie export return.
    **/
    private function onExportReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-exchpub-title'), Global.ln.get('window-exchpub-error'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-exchpub-title'), Global.ln.get('window-exchpub-error'), 300, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-exchpub-title'), Global.ln.get('window-exchpub-ok'), 320, 200, this.stage);
            Global.ws.download([
                'file' => 'pub', 
                'movie' => GlobalPlayer.movie.mvId,  
            ]);
        }
    }

}