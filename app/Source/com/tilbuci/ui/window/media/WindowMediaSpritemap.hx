package com.tilbuci.ui.window.media;

/** OPENFL **/
import feathers.core.FeathersControl;
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

class WindowMediaSpritemap extends WindowMediaBase {

    /**
        spritemap settings
    **/
    private var _smapset:FeathersControl;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic, mode:String) {
        // creating window
        super(ac, Global.ln.get('window-mdspritemap-title'), 'spritemap', mode);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        super.startInterface();
        
        this._smapset = this.ui.createHContainer('spritemapset');
        this._smapset.addChild(this.ui.forge('smapleft', [
            { tp: 'Label', id: 'frames', tx: Global.ln.get('window-mdspritemap-frames'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Numeric', id: 'frames', vl: this._frames, mn: 1, mx: 100, st: 1, ch: onSmapChange }
            
        ], -1, 200, 0));
        this._smapset.addChild(this.ui.forge('smapright', [
            { tp: 'Label', id: 'frtime', tx: Global.ln.get('window-mdspritemap-frtime'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Numeric', id: 'frtime2', vl: this._frtime, mn: 50, mx: 5000, st: 50, ch: onSmapChange }
        ], -1, 260, 0));
        this.ui.containers['rightcol'].addChild(this._smapset);

    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Spritemap settings change.
    **/
    private function onSmapChange(evt:Event):Void {
        if ((this.ui.numerics['frames'].value > 0) && (this.ui.numerics['frames'].value <= 100)) this._frames = Math.round(this.ui.numerics['frames'].value);
        if ((this.ui.numerics['frtime2'].value >= 50) && (this.ui.numerics['frtime2'].value <= 5000)) this._frtime = Math.round(this.ui.numerics['frtime2'].value);
        this._preview.setSpritemap(this._frames, this._frtime);
    }

}