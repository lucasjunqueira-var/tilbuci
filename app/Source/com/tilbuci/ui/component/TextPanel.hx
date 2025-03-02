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

class TextPanel extends DropDownPanel {

    /**
        histopry update timer
    **/
    private var _timer:Timer;

    /**
        currently selected instance
    **/
    private var _current:InstanceImage = null;

    public function new(wd:Float) {
        super(Global.ln.get('rightbar-text'), wd);
        this._timer = null;

        var colorCont:HInterfaceContainer = this.ui.createHContainer('colorcont', 0x333333);
        this.ui.createTInput('color', '', '', colorCont);
        this.ui.createButton('color', Global.ln.get('default-set'), changeProperties, colorCont);
        colorCont.width = wd - 5;

        var bgcolorCont:HInterfaceContainer = this.ui.createHContainer('bgcolorcont', 0x333333);
        this.ui.createTInput('background', '', '', bgcolorCont);
        this.ui.createButton('background', Global.ln.get('default-set'), changeProperties, bgcolorCont);
        bgcolorCont.width = wd - 5;

        this._content = this.ui.forge('properties', [
            { tp: 'Label', id: 'font', tx: Global.ln.get('rightbar-text-font'), vr: '' }, 
            { tp: 'Select', id: 'font', vl: [ ], sl: null, ch: changeProperties }, 
            { tp: 'Label', id: 'size', tx: Global.ln.get('rightbar-text-size'), vr: '' }, 
            { tp: 'Numeric', id: 'size', mn: 4, mx: 1000, st: 1, vl: 12, ch: changeProperties }, 
            { tp: 'Label', id: 'color', tx: Global.ln.get('rightbar-text-color'), vr: '' }, 
            //{ tp: 'TInput', id: 'color', tx: '', vr: '', ch: changeProperties }, 
            { tp: 'Custom', cont: colorCont },
            { tp: 'Label', id: 'bold', tx: Global.ln.get('rightbar-text-bold'), vr: '' }, 
            { tp: 'Toggle', id: 'bold', vl: false, ch: changeProperties }, 
            { tp: 'Label', id: 'italic', tx: Global.ln.get('rightbar-text-italic'), vr: '' }, 
            { tp: 'Toggle', id: 'italic', vl: false, ch: changeProperties }, 
            { tp: 'Label', id: 'leading', tx: Global.ln.get('rightbar-text-leading'), vr: '' }, 
            { tp: 'Numeric', id: 'leading', mn: -1000, mx: 1000, st: 1, vl: 0, ch: changeProperties }, 
            //{ tp: 'Label', id: 'spacing', tx: Global.ln.get('rightbar-text-spacing'), vr: '' }, 
            //{ tp: 'Numeric', id: 'spacing', mn: -100, mx: 100, st: 1, vl: 0, ch: changeProperties }, 
            { tp: 'Label', id: 'align', tx: Global.ln.get('rightbar-text-align'), vr: '' }, 
            { tp: 'Select', id: 'align', vl: [
                { text: Global.ln.get('rightbar-text-alleft'), value: 'left' }, 
                { text: Global.ln.get('rightbar-text-alright'), value: 'right' }, 
                { text: Global.ln.get('rightbar-text-alcenter'), value: 'center' }, 
                { text: Global.ln.get('rightbar-text-aljustify'), value: 'justify' }
            ], sl: 'left', ch: changeProperties }, 
            { tp: 'Label', id: 'background', tx: Global.ln.get('rightbar-text-background'), vr: '' }, 
            //{ tp: 'TInput', id: 'background', tx: '', vr: '', ch: changeProperties }
            { tp: 'Custom', cont: bgcolorCont },
        ], 0x333333, (wd - 5));
        this.ui.containers['properties'].enabled = false;
        Global.history.propDisplay.push(this.updateValues);
        
        this.ui.createNumeric('spacing', -100, 100, 1, 0);
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
            var fnts:Array<Dynamic> = [ ];
            for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
            for (i in GlobalPlayer.mdata.fonts) fnts.push({ text: i.name, value: i.name });
            this.ui.setSelectOptions('font', fnts);
            this.ui.setSelectValue('font', this._current.getCurrentStr('textfont'));
            this.ui.inputs['color'].text = StringTools.replace(this._current.getCurrentStr('textcolor'), '0x', '#');
            this.ui.toggles['bold'].selected = this._current.getCurrentBool('textbold');
            this.ui.toggles['italic'].selected = this._current.getCurrentBool('textitalic');
            this.ui.numerics['size'].value = Math.round(this._current.getCurrentNum('textsize'));
            this.ui.numerics['leading'].value = Math.round(this._current.getCurrentNum('textleading'));
            this.ui.numerics['spacing'].value = Math.round(this._current.getCurrentNum('textspacing') * 100);
            this.ui.setSelectValue('align', this._current.getCurrentStr('textalign'));
            this.ui.inputs['background'].text = StringTools.replace(this._current.getCurrentStr('textbackground'), '0x', '#');
            this.ui.containers['properties'].enabled = true;
        }
    }

    private function clearValues():Void {
        this.ui.containers['properties'].enabled = false;
        this.ui.setSelectOptions('font', [ ]);
        this.ui.setSelectValue('font', '');
        this.ui.inputs['color'].text = '';
        this.ui.toggles['bold'].selected = false;
        this.ui.toggles['italic'].selected = false;
        this.ui.numerics['size'].value = 12;
        this.ui.numerics['leading'].value = 0;
        this.ui.numerics['spacing'].value = 0;
        this.ui.setSelectValue('align', 'left');
        this.ui.inputs['background'].text = '';
        this._current = null;
    }

    private function changeProperties(evt:Event = null):Void {
        if ((this._current != null) && this.ui.containers['properties'].enabled) {
            if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
            GlobalPlayer.area.setCurrentStr('textfont', this.ui.selects['font'].selectedItem.value);
            var color:String = StringTools.replace(this.ui.inputs['color'].text, '#', '0x');
            var colorint:Int = Std.parseInt(color);
            if (colorint == null) {
                color = '0xFFFFFF';
            } else {
                color = '0x' + StringTools.hex(colorint);
            }
            GlobalPlayer.area.setCurrentStr('textcolor', color);
            this.ui.inputs['color'].text = StringTools.replace(color, '0x', '#');
            GlobalPlayer.area.setCurrentBool('textbold', this.ui.toggles['bold'].selected);
            GlobalPlayer.area.setCurrentBool('textitalic', this.ui.toggles['italic'].selected);
            GlobalPlayer.area.setCurrentNum('textsize', this.ui.numerics['size'].value);
            GlobalPlayer.area.setCurrentNum('textleading', this.ui.numerics['leading'].value);
            GlobalPlayer.area.setCurrentNum('textspacing', this.ui.numerics['spacing'].value / 100);
            GlobalPlayer.area.setCurrentStr('textalign', this.ui.selects['align'].selectedItem.value);
            color = StringTools.replace(this.ui.inputs['background'].text, '#', '0x');
            if (color != '') {
                colorint = Std.parseInt(color);
                if (colorint == null) {
                    color = '';
                } else {
                    color = '0x' + StringTools.hex(colorint);
                }
            }
            GlobalPlayer.area.setCurrentStr('textbackground', color);
            this.ui.inputs['background'].text = StringTools.replace(color, '0x', '#');
            GlobalPlayer.area.applyText();
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
        Global.history.addState(Global.ln.get('rightbar-history-text'));
    }

}