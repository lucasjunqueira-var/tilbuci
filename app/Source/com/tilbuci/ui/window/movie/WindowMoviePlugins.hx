package com.tilbuci.ui.window.movie;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.ui.base.InterfaceContainer;
import com.tilbuci.ui.base.HInterfaceContainer;
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
import com.tilbuci.data.GlobalPlayer;

class WindowMoviePlugins extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-movieplugin-title'), 1000, 720, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        for (pl in Global.plugins) {
            /*var setup:InterfaceContainer = pl.movieSetup;
            setup.width = 960;
            setup.height = 495;
            var active:Bool = false;
            if (GlobalPlayer.mdata.plugins.exists(pl.plname)) active = GlobalPlayer.mdata.plugins[pl.plname].active;
            this.addForm(pl.pltitle, this.ui.forge(pl.plname, [
                { tp: 'Label', id: (pl.plname + 'enabled'), tx: Global.ln.get('window-movieplugin-enable'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Toggle', id: (pl.plname + 'enabled'), vl: active }, 
                { tp: 'Spacer', id: (pl.plname + 'spacer'), ht: 5 }, 
                { tp: 'Custom', cont: setup }, 
                { tp: 'Spacer', id: (pl.plname + 'spacer2'), ht: 10 }, 
                { tp: 'Button', id: pl.plname, tx: Global.ln.get('window-movieplugin-save'), ac: this.onSave }
            ]));*/
        }

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
        
    }

    /**
        Save plugin click.
    **/
    private function onSave(evt:TriggerEvent):Void {
        var conf:String = '{}';
        if (Global.plugins.exists(evt.target.btid)) conf = StringStatic.jsonStringify(Global.plugins[evt.target.btid].getConfig());
        Global.ws.send(
            'Movie/Plugin', [
                'id' => GlobalPlayer.movie.mvId, 
                'plugin' => evt.target.btid, 
                'active' => this.ui.toggles[evt.target.btid + 'enabled'].selected, 
                'conf' => conf
            ], 
            this.onSaveReturn
        );
    }

    /**
        Save plugin return.
    **/
    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-movieplugin-title'), Global.ln.get('window-movieplugin-saveerror'), 300, 180, this.stage);
        } else {
            if (ld.map['e'] != 0) {
                this.ui.createWarning(Global.ln.get('window-movieplugin-title'), Global.ln.get('window-movieplugin-saveerror'), 300, 180, this.stage);
            } else {
                this.ui.createWarning(Global.ln.get('window-movieplugin-title'), Global.ln.get('window-movieplugin-saveok'), 300, 180, this.stage);
            }
        }
    }

}