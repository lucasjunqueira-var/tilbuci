/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;


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

class PropertiesPanel extends DropDownPanel {

    /**
        histopry update timer
    **/
    private var _timer:Timer;

    /**
        currently selected instance
    **/
    private var _current:InstanceImage = null;

    public function new(wd:Float) {
        super(Global.ln.get('rightbar-properties'), wd);
        this._timer = null;
        var orderContainer:HInterfaceContainer = this.ui.createHContainer('orderbuttons', 0x333333);
        this.ui.createIconButton('orderdown', onOrderDown, new Bitmap(Assets.getBitmapData('iconDown')), null, orderContainer);
        this.ui.createIconButton('orderup', onOrderUp, new Bitmap(Assets.getBitmapData('iconUp')), null, orderContainer);
        orderContainer.width = wd - 5;

        var xContainer:HInterfaceContainer = this.ui.createHContainer('xbuttons', 0x333333);
        this.ui.createIconButton('xleft', onXLeft, new Bitmap(Assets.getBitmapData('btToLeft')), null, xContainer);
        this.ui.createIconButton('xcenter', onXCenter, new Bitmap(Assets.getBitmapData('btToCenter')), null, xContainer);
        this.ui.createIconButton('xright', onXRight, new Bitmap(Assets.getBitmapData('btToRight')), null, xContainer);
        xContainer.width = wd - 5;

        var yContainer:HInterfaceContainer = this.ui.createHContainer('xbuttons', 0x333333);
        this.ui.createIconButton('ytop', onYTop, new Bitmap(Assets.getBitmapData('btToTop')), null, yContainer);
        this.ui.createIconButton('ymiddle', onYMiddle, new Bitmap(Assets.getBitmapData('btToMiddle')), null, yContainer);
        this.ui.createIconButton('ybottom', onYBottom, new Bitmap(Assets.getBitmapData('btToDown')), null, yContainer);
        yContainer.width = wd - 5;

        this._content = this.ui.forge('properties', [
            { tp: 'Label', id: 'px', tx: Global.ln.get('rightbar-properties-px'), vr: '' }, 
            { tp: 'Numeric', id: 'px', mn: -10000, mx: 100000, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Custom', cont: xContainer }, 
            { tp: 'Label', id: 'py', tx: Global.ln.get('rightbar-properties-py'), vr: '' }, 
            { tp: 'Numeric', id: 'py', mn: -10000, mx: 100000, st: 1, vl: 0, ch: changeProperties },
            { tp: 'Custom', cont: yContainer }, 
            { tp: 'Label', id: 'width', tx: Global.ln.get('rightbar-properties-width'), vr: '' }, 
            { tp: 'Numeric', id: 'width', mn: -10000, mx: 100000, st: 1, vl: 0, ch: changeProperties },
            { tp: 'Label', id: 'height', tx: Global.ln.get('rightbar-properties-height'), vr: '' }, 
            { tp: 'Numeric', id: 'height', mn: -10000, mx: 100000, st: 1, vl: 0, ch: changeProperties },
            { tp: 'Button', id: 'awidth', tx: Global.ln.get('rightbar-properties-awidth'), cl: onAdjustWidth },
            { tp: 'Button', id: 'aheight', tx: Global.ln.get('rightbar-properties-aheight'), cl: onAdjustHeight },
            { tp: 'Button', id: 'soriginal', tx: Global.ln.get('rightbar-properties-soriginal'), cl: onAdjustOriginal },
            { tp: 'Label', id: 'order', tx: Global.ln.get('rightbar-properties-order'), vr: '' }, 
            { tp: 'Custom', cont: orderContainer }, 
            { tp: 'Label', id: 'visible', tx: Global.ln.get('rightbar-properties-visible'), vr: '' }, 
            { tp: 'Toggle', id: 'visible', vl: false, ch: changeProperties },
            /*{ tp: 'Label', id: 'rotation', tx: Global.ln.get('rightbar-properties-rotation'), vr: '' }, 
            { tp: 'Numeric', id: 'rotation', mn: -10000, mx: 100000, st: 1, vl: 0, ch: changeProperties }*/
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
            this.ui.numerics['px'].value = Math.round(this._current.getCurrentNum('x'));
            this.ui.numerics['py'].value = Math.round(this._current.getCurrentNum('y'));
            this.ui.numerics['width'].value = Math.round(this._current.getCurrentNum('width'));
            this.ui.numerics['height'].value = Math.round(this._current.getCurrentNum('height'));
            //this.ui.numerics['rotation'].value = Math.round(this._current.getCurrentNum('rotation'));
            this.ui.toggles['visible'].selected = this._current.getCurrentBool('visible');
            this.ui.containers['properties'].enabled = true;
        }
    }

    private function clearValues():Void {
        this.ui.containers['properties'].enabled = false;
        this.ui.numerics['px'].value = 0;
        this.ui.numerics['py'].value = 0;
        this.ui.numerics['width'].value = 0;
        this.ui.numerics['height'].value = 0;
        //this.ui.numerics['rotation'].value = 0;
        this.ui.toggles['visible'].selected = true;
        this._current = null;
    }

    private function changeProperties(evt:Event = null):Void {
        if ((this._current != null) && this.ui.containers['properties'].enabled) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            GlobalPlayer.area.setCurrentNum('x', this.ui.numerics['px'].value);
            GlobalPlayer.area.setCurrentNum('y', this.ui.numerics['py'].value);
            GlobalPlayer.area.setCurrentNum('width', this.ui.numerics['width'].value);
            GlobalPlayer.area.setCurrentNum('height', this.ui.numerics['height'].value);
            //GlobalPlayer.area.setCurrentNum('rotation', this.ui.numerics['rotation'].value);
            GlobalPlayer.area.setCurrentBool('visible', this.ui.toggles['visible'].selected);
            if (this._timer == null) {
                this._timer = new Timer(2000);
                this._timer.run = this.saveHistory;
            }
        }
    }

    private function onAdjustWidth(evt:Event = null):Void {
        this.ui.containers['properties'].enabled = false;
        if (this._current.oHeight() > 0) {
            var nw:Float = this._current.oWidth() * this.ui.numerics['height'].value / this._current.oHeight();
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            GlobalPlayer.area.setCurrentNum('width', nw);
            this.ui.numerics['width'].value = Math.round(nw);
            if (this._timer == null) {
                this._timer = new Timer(2000);
                this._timer.run = this.saveHistory;
            }
        }
        this.ui.containers['properties'].enabled = true;
    }

    private function onAdjustOriginal(evt:Event = null):Void {
        this.ui.containers['properties'].enabled = false;
        if ((this._current.oWidth() > 0) && (this._current.oHeight() > 0)) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            GlobalPlayer.area.setCurrentNum('width', this._current.oWidth());
            GlobalPlayer.area.setCurrentNum('height', this._current.oHeight());
            this.ui.numerics['width'].value = Math.round(this._current.oWidth());
            this.ui.numerics['height'].value = Math.round(this._current.oHeight());
            if (this._timer == null) {
                this._timer = new Timer(2000);
                this._timer.run = this.saveHistory;
            }
        }
        this.ui.containers['properties'].enabled = true;
    }

    private function onAdjustHeight(evt:Event = null):Void {
        this.ui.containers['properties'].enabled = false;
        if (this._current.oWidth() > 0) {
            var nh:Float = this._current.oHeight() * this.ui.numerics['width'].value / this._current.oWidth();
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            GlobalPlayer.area.setCurrentNum('height', nh);
            this.ui.numerics['height'].value = Math.round(nh);
            if (this._timer == null) {
                this._timer = new Timer(2000);
                this._timer.run = this.saveHistory;
            }
        }
        this.ui.containers['properties'].enabled = true;
    }

    private function onOrderDown(evt:Event = null):Void {
        if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
        GlobalPlayer.area.orderDown();
        if (this._timer == null) {
            this._timer = new Timer(2000);
            this._timer.run = this.saveHistory;
        }
    }

    private function onOrderUp(evt:Event = null):Void {
        if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
        GlobalPlayer.area.orderUp();
        if (this._timer == null) {
            this._timer = new Timer(2000);
            this._timer.run = this.saveHistory;
        }
    }

    private function onXLeft(evt:Event = null):Void {
        if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
        GlobalPlayer.area.setCurrentNum('x', 0);
        this.ui.numerics['px'].value = Math.round(this._current.getCurrentNum('x'));
        if (this._timer == null) {
            this._timer = new Timer(2000);
            this._timer.run = this.saveHistory;
        }
    }

    private function onXRight(evt:Event = null):Void {
        if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
        if (GlobalPlayer.orientation == 'horizontal') {
            GlobalPlayer.area.setCurrentNum('x', (GlobalPlayer.mdata.screen.big - this._current.getCurrentNum('width')));
        } else {
            GlobalPlayer.area.setCurrentNum('x', (GlobalPlayer.mdata.screen.small - this._current.getCurrentNum('width')));
        }
        this.ui.numerics['px'].value = Math.round(this._current.getCurrentNum('x'));
        if (this._timer == null) {
            this._timer = new Timer(2000);
            this._timer.run = this.saveHistory;
        }
    }

    private function onXCenter(evt:Event = null):Void {
        if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
        if (GlobalPlayer.orientation == 'horizontal') {
            GlobalPlayer.area.setCurrentNum('x', ((GlobalPlayer.mdata.screen.big - this._current.getCurrentNum('width')) / 2));
        } else {
            GlobalPlayer.area.setCurrentNum('x', ((GlobalPlayer.mdata.screen.small - this._current.getCurrentNum('width')) / 2));
        }
        this.ui.numerics['px'].value = Math.round(this._current.getCurrentNum('x'));
        if (this._timer == null) {
            this._timer = new Timer(2000);
            this._timer.run = this.saveHistory;
        }
    }

    private function onYTop(evt:Event = null):Void {
        if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
        GlobalPlayer.area.setCurrentNum('y', 0);
        this.ui.numerics['py'].value = Math.round(this._current.getCurrentNum('y'));
        if (this._timer == null) {
            this._timer = new Timer(2000);
            this._timer.run = this.saveHistory;
        }
    }

    private function onYBottom(evt:Event = null):Void {
        if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
        if (GlobalPlayer.orientation == 'horizontal') {
            GlobalPlayer.area.setCurrentNum('y', (GlobalPlayer.mdata.screen.small - this._current.getCurrentNum('height')));
        } else {
            GlobalPlayer.area.setCurrentNum('y', (GlobalPlayer.mdata.screen.big - this._current.getCurrentNum('height')));
        }
        this.ui.numerics['py'].value = Math.round(this._current.getCurrentNum('y'));
        if (this._timer == null) {
            this._timer = new Timer(2000);
            this._timer.run = this.saveHistory;
        }
    }

    private function onYMiddle(evt:Event = null):Void {
        if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
        if (GlobalPlayer.orientation == 'horizontal') {
            GlobalPlayer.area.setCurrentNum('y', ((GlobalPlayer.mdata.screen.small - this._current.getCurrentNum('height')) / 2));
        } else {
            GlobalPlayer.area.setCurrentNum('y', ((GlobalPlayer.mdata.screen.big - this._current.getCurrentNum('height')) / 2));
        }
        this.ui.numerics['py'].value = Math.round(this._current.getCurrentNum('y'));
        if (this._timer == null) {
            this._timer = new Timer(2000);
            this._timer.run = this.saveHistory;
        }
    }

    private function saveHistory():Void {
        try {
            this._timer.stop();
        } catch (e) { }
        this._timer = null;
        Global.history.addState(Global.ln.get('rightbar-history-placement'));
    }

}