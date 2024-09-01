package com.tilbuci.ui.component;


import com.tilbuci.statictools.StringStatic;
import openfl.Assets;
import openfl.display.Bitmap;
import com.tilbuci.display.InstanceImage;
import haxe.macro.Expr.Catch;
import haxe.Timer;
import feathers.layout.AnchorLayoutData;
import feathers.controls.ListView;
import feathers.data.ArrayCollection;
import openfl.events.Event;
import com.tilbuci.ui.base.HInterfaceContainer;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.Global;

class ColorPanel extends DropDownPanel {

    /**
        histopry update timer
    **/
    private var _timer:Timer;

    /**
        currently selected instance
    **/
    private var _current:InstanceImage = null;

    public function new(wd:Float) {
        super(Global.ln.get('rightbar-color'), wd);
        this._timer = null;
        this._content = this.ui.forge('properties', [
            { tp: 'Label', id: 'alpha', tx: Global.ln.get('rightbar-color-alpha'), vr: '' }, 
            { tp: 'Numeric', id: 'alpha', mn: 0, mx: 100, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'alphacolor', tx: Global.ln.get('rightbar-color-alphacolor'), vr: '' }, 
            { tp: 'Numeric', id: 'alphacolor', mn: 0, mx: 100, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'red', tx: Global.ln.get('rightbar-color-red'), vr: '' }, 
            { tp: 'Numeric', id: 'red', mn: 0, mx: 255, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'green', tx: Global.ln.get('rightbar-color-green'), vr: '' }, 
            { tp: 'Numeric', id: 'green', mn: 0, mx: 255, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'blue', tx: Global.ln.get('rightbar-color-blue'), vr: '' }, 
            { tp: 'Numeric', id: 'blue', mn: 0, mx: 255, st: 1, vl: 0, ch: changeProperties }
        ], 0x333333, (wd - 5));
        this.ui.containers['properties'].enabled = false;
        Global.history.propDisplay.push(this.updateValues);
    }

    override public function updateContent(data:Map<String, Dynamic> = null):Void {
        if (data.exists('nm')) {
            this._current = GlobalPlayer.area.instanceRef(data['nm']);
            this.updateValues();
        } else {
            this.clearValues();
        }
        
    }

    override public function reloadContent(data:Map<String, Dynamic> = null):Void {
        this.clearValues();
    }

    public function updateValues():Void {
        if (this._current != null) {
            this.ui.containers['properties'].enabled = false;
            this.ui.numerics['alpha'].value = Math.round(this._current.getCurrentNum('alpha') * 100);
            this.ui.numerics['alphacolor'].value = Math.round(this._current.getCurrentNum('coloralpha') * 100);
            var color:String = this._current.getCurrentStr('color');
            this.ui.numerics['red'].value = Std.parseInt('0x'+color.substr(-6, 2));
            this.ui.numerics['green'].value = Std.parseInt('0x'+color.substr(-4, 2));
            this.ui.numerics['blue'].value = Std.parseInt('0x'+color.substr(-2, 2));
            this.ui.containers['properties'].enabled = true;
        }
    }

    private function clearValues():Void {
        this.ui.containers['properties'].enabled = false;
        this.ui.numerics['alpha'].value = 0;
        this.ui.numerics['alphacolor'].value = 0;
        this.ui.numerics['red'].value = 0;
        this.ui.numerics['green'].value = 0;
        this.ui.numerics['blue'].value = 0;
        this._current = null;
    }

    private function changeProperties(evt:Event = null):Void {
        if ((this._current != null) && this.ui.containers['properties'].enabled) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            GlobalPlayer.area.setCurrentNum('alpha', this.ui.numerics['alpha'].value / 100);
            GlobalPlayer.area.setCurrentNum('coloralpha', this.ui.numerics['alphacolor'].value / 100);
            GlobalPlayer.area.setCurrentStr('color', StringStatic.rgbToHex(this.ui.numerics['red'].value, this.ui.numerics['green'].value, this.ui.numerics['blue'].value));
            if (this._timer == null) {
                this._timer = new Timer(2000);
                this._timer.run = this.saveHistory;
            }
            this._current.alpha = (this.ui.numerics['alpha'].value / 100);
        }
    }

    private function saveHistory():Void {
        try {
            this._timer.stop();
        } catch (e) { }
        this._timer = null;
        Global.history.addState(Global.ln.get('rightbar-history-color'));
    }

}