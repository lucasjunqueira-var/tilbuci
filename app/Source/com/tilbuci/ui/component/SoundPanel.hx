/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

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

class SoundPanel extends DropDownPanel {

    /**
        histopry update timer
    **/
    private var _timer:Timer;

    /**
        currently selected instance
    **/
    private var _current:InstanceImage = null;

    public function new(wd:Float) {
        super(Global.ln.get('rightbar-sound'), wd);
        this._timer = null;
        this._content = this.ui.forge('properties', [
            { tp: 'Label', id: 'volume', tx: Global.ln.get('rightbar-sound-volume'), vr: '' }, 
            { tp: 'Numeric', id: 'volume', mn: 0, mx: 100, st: 1, vl: 0, ch: changeProperties }
        ], 0x333333, (wd - 5));
        this.ui.containers['properties'].enabled = false;
        Global.history.propDisplay.push(this.updateValues);
    }

    override public function updateContent(data:Map<String, Dynamic> = null):Void {
        if (data.exists('nm')) {
            if (data['nm'] == '') {
                this.clearValues();
            } else {
                this._current = GlobalPlayer.area.instanceRef(data['nm']);
                this.updateValues();
            }
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
            this.ui.numerics['volume'].value = Math.round(this._current.getCurrentNum('volume') * 100);
            this.ui.containers['properties'].enabled = true;
        }
    }

    private function clearValues():Void {
        this.ui.containers['properties'].enabled = false;
        this.ui.numerics['volume'].value = 0;
        this._current = null;
    }

    private function changeProperties(evt:Event = null):Void {
        if ((this._current != null) && this.ui.containers['properties'].enabled) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            GlobalPlayer.area.setCurrentNum('volume', this.ui.numerics['volume'].value / 100);
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
        Global.history.addState(Global.ln.get('rightbar-history-sound'));
    }

}