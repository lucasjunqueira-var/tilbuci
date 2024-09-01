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

class FilterPanel extends DropDownPanel {

    /**
        histopry update timer
    **/
    private var _timer:Timer;

    /**
        currently selected instance
    **/
    private var _current:InstanceImage = null;

    public function new(wd:Float) {
        super(Global.ln.get('rightbar-filter'), wd);
        this._timer = null;
        this._content = this.ui.forge('properties', [
            { tp: 'Label', id: 'blur', tx: Global.ln.get('rightbar-filter-blur'), vr: '' }, 
            { tp: 'Toggle', id: 'blur', vl: false, ch: changeProperties }, 
            { tp: 'Label', id: 'blurx', tx: Global.ln.get('rightbar-filter-blurx'), vr: 'detail' }, 
            { tp: 'Numeric', id: 'blurx', mn: 0, mx: 255, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'blury', tx: Global.ln.get('rightbar-filter-blury'), vr: 'detail' }, 
            { tp: 'Numeric', id: 'blury', mn: 0, mx: 255, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'dropshadow', tx: Global.ln.get('rightbar-filter-dropshadow'), vr: '' }, 
            { tp: 'Toggle', id: 'dropshadow', vl: false, ch: changeProperties }, 
            { tp: 'Label', id: 'dsdistance', tx: Global.ln.get('rightbar-filter-dsdistance'), vr: 'detail' }, 
            { tp: 'Numeric', id: 'dsdistance', mn: -100, mx: 100, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'dsangle', tx: Global.ln.get('rightbar-filter-dsangle'), vr: 'detail' }, 
            { tp: 'Numeric', id: 'dsangle', mn: 0, mx: 360, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'dscolor', tx: Global.ln.get('rightbar-filter-dscolor'), vr: 'detail' }, 
            { tp: 'TInput', id: 'dscolor', tx: '', vr: '', ch: changeProperties }, 
            { tp: 'Label', id: 'dsalpha', tx: Global.ln.get('rightbar-filter-dsalpha'), vr: 'detail' }, 
            { tp: 'Numeric', id: 'dsalpha', mn: 0, mx: 100, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'dsblurx', tx: Global.ln.get('rightbar-filter-dsblurx'), vr: 'detail' }, 
            { tp: 'Numeric', id: 'dsblurx', mn: 0, mx: 100, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'dsblury', tx: Global.ln.get('rightbar-filter-dsblury'), vr: 'detail' }, 
            { tp: 'Numeric', id: 'dsblury', mn: 0, mx: 100, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'dsstrength', tx: Global.ln.get('rightbar-filter-dsstrength'), vr: 'detail' }, 
            { tp: 'Numeric', id: 'dsstrength', mn: 0, mx: 255, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'dsinner', tx: Global.ln.get('rightbar-filter-dsinner'), vr: 'detail' }, 
            { tp: 'Toggle', id: 'dsinner', vl: false, ch: changeProperties }
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
            this.ui.toggles['blur'].selected = this._current.getCurrentBool('blur');
            this.ui.toggles['dropshadow'].selected = this._current.getCurrentBool('dropshadow');
            var data:Array<String> = this._current.getCurrentArr('blur');
            this.ui.numerics['blurx'].value = Std.parseInt(data[0]);
            this.ui.numerics['blury'].value = Std.parseInt(data[1]);
            data = this._current.getCurrentArr('dropshadow');
            this.ui.numerics['dsdistance'].value = Std.parseInt(data[0]);
            this.ui.numerics['dsangle'].value = Std.parseInt(data[1]);
            this.ui.inputs['dscolor'].text = StringTools.replace(data[2], '0x', '#');
            this.ui.numerics['dsalpha'].value = Math.round(Std.parseFloat(data[3]) * 100);
            this.ui.numerics['dsblurx'].value = Std.parseInt(data[4]);
            this.ui.numerics['dsblury'].value = Std.parseInt(data[5]);
            this.ui.numerics['dsstrength'].value = Std.parseInt(data[6]);
            this.ui.toggles['dsinner'].selected = (data[7] == '1');
            this.ui.containers['properties'].enabled = true;
        }
    }

    private function clearValues():Void {
        this.ui.containers['properties'].enabled = false;
        this.ui.toggles['blur'].selected = false;
        this.ui.toggles['dropshadow'].selected = false;
        this.ui.numerics['blurx'].value = 0;
        this.ui.numerics['blury'].value = 0;
        this.ui.numerics['dsdistance'].value = 0;
        this.ui.numerics['dsangle'].value = 0;
        this.ui.inputs['dscolor'].text = '#000000';
        this.ui.numerics['dsalpha'].value = 0;
        this.ui.numerics['dsblurx'].value = 0;
        this.ui.numerics['dsblury'].value = 0;
        this.ui.numerics['dsstrength'].value = 0;
        this.ui.toggles['dsinner'].selected = false;
        this._current = null;
    }

    private function changeProperties(evt:Event = null):Void {
        if ((this._current != null) && this.ui.containers['properties'].enabled) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            GlobalPlayer.area.setCurrentArray('blur', [
                Std.string(this.ui.numerics['blurx'].value), 
                Std.string(this.ui.numerics['blury'].value)
            ]);
            var color:String = StringTools.replace(this.ui.inputs['dscolor'].text, '#', '0x');
            var colorint:Int = Std.parseInt(color);
            if (colorint == null) {
                color = '0x000000';
            } else {
                color = '0x' + StringTools.hex(colorint);
            }
            GlobalPlayer.area.setCurrentStr('textcolor', color);
            this.ui.inputs['dscolor'].text = StringTools.replace(color, '0x', '#');
            var dsinner:String = '0';
            if (this.ui.toggles['dsinner'].selected) dsinner = '1';

            GlobalPlayer.area.setCurrentArray('dropshadow', [
                Std.string(this.ui.numerics['dsdistance'].value), 
                Std.string(this.ui.numerics['dsangle'].value), 
                color, 
                Std.string(this.ui.numerics['dsalpha'].value / 100), 
                Std.string(this.ui.numerics['dsblurx'].value), 
                Std.string(this.ui.numerics['dsblury'].value), 
                Std.string(this.ui.numerics['dsstrength'].value), 
                dsinner 
            ]);

            GlobalPlayer.area.setCurrentBool('blur', this.ui.toggles['blur'].selected);
            GlobalPlayer.area.setCurrentBool('dropshadow', this.ui.toggles['dropshadow'].selected);
            if (this._timer == null) {
                this._timer = new Timer(2000);
                this._timer.run = this.saveHistory;
            }
        }
    }

    private function saveHistory():Void {
        try {
            this._timer.stop();
        } catch (e) { }
        this._timer = null;
        Global.history.addState(Global.ln.get('rightbar-history-filters'));
    }

}