package com.tilbuci.ui.window.media;

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
import com.tilbuci.ui.window.media.WindowMediaBase;
import com.tilbuci.data.Global;

class WindowMediaAudio extends WindowMediaBase {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic, mode:String) {
        // creating window
        super(ac, Global.ln.get('window-mdaudio-title'), 'audio', mode);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        super.startInterface();
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

}