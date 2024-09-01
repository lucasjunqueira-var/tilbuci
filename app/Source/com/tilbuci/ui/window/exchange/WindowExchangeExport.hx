package com.tilbuci.ui.window.exchange;

/** OPENFL **/
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

class WindowExchangeExport extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-exchexport-title'), 800, 200, false);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-exchexport-title'), this.ui.forge('leftcol', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-exchexport-about'), vr: '' }, 
            { tp: 'Spacer', id: 'export', ht: 20 },  
            { tp: 'Button', id: 'export', tx: Global.ln.get('window-exchexport-button'), ac: this.onExport }
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
        Start movie export.
    **/
    private function onExport(evt:TriggerEvent):Void {
        Global.ws.send('Movie/Export', [
            'movie' => GlobalPlayer.movie.mvId, 
        ], onExportReturn);
    }

    /**
        Movie export return.
    **/
    private function onExportReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-exchexport-title'), Global.ln.get('window-exchexport-error'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-exchexport-title'), Global.ln.get('window-exchexport-error'), 300, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-exchexport-title'), Global.ln.get('window-exchexport-ok'), 320, 200, this.stage);
            Global.ws.download([
                'file' => 'export', 
                'movie' => GlobalPlayer.movie.mvId,  
            ]);
        }
    }

}