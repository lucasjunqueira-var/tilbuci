/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.media;

/** OPENFL **/
import openfl.display.Shape;
import openfl.display.Sprite;
import feathers.layout.AnchorLayout;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.display.ShapeImage;
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

class WindowMediaShape extends WindowMediaBase {

    /**
        shape display
    **/
    private var _shape:ShapeImage;

    /**
        shape description
    **/
    private var _desc:ShapeDesc;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic, mode:String) {
        // creating window
        super(ac, Global.ln.get('window-mdshape-title'), 'shape', mode);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        super.startInterface();

        this.ui.createHContainer('addtocol');
        this.ui.createButton('addcolast', Global.ln.get('window-media-addcolast'), onAddAsset, this.ui.hcontainers['addtocol']);
        this.ui.createButton('addtocol', Global.ln.get('window-media-addtocol'), onAddToCol, this.ui.hcontainers['addtocol']);
        this.ui.createSelect('addtocol', [ ], null, this.ui.hcontainers['addtocol']);
        this.ui.createToggle('close', true, this.ui.hcontainers['addtocol']);
        this.ui.createLabel('close', Global.ln.get('window-media-closeafter'), '', this.ui.hcontainers['addtocol']);

        this._shape = new ShapeImage(onShape);
        this.addForm(Global.ln.get('window-mdshape-title'), this.ui.createColumnHolder('columns',
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'shape', tx: Global.ln.get('window-mdshape-shape'), vr: '' }, 
                { tp: 'Select', id: 'shape', vl: [
                    { text: Global.ln.get('window-mdshape-circle'), value: 'circle' }, 
                    { text: Global.ln.get('window-mdshape-triangle'), value: 'triangle' }, 
                    { text: Global.ln.get('window-mdshape-isoscelestriangle'), value: 'isoscelestriangle' }, 
                    { text: Global.ln.get('window-mdshape-righttriangle'), value: 'righttriangle' }, 
                    { text: Global.ln.get('window-mdshape-square'), value: 'square' }, 
                    { text: Global.ln.get('window-mdshape-pentagon'), value: 'pentagon' }, 
                    { text: Global.ln.get('window-mdshape-hexagon'), value: 'hexagon' }, 
                    { text: Global.ln.get('window-mdshape-heptagon'), value: 'heptagon' }, 
                    { text: Global.ln.get('window-mdshape-octagon'), value: 'octagon' }, 
                    { text: Global.ln.get('window-mdshape-eneagon'), value: 'eneagon' }, 
                    { text: Global.ln.get('window-mdshape-decagon'), value: 'decagon' }
                ], sl: 'circle' }, 
                { tp: 'Label', id: 'color', tx: Global.ln.get('window-mdshape-color'), vr: '' }, 
                { tp: 'TInput', id: 'color', tx: '#000000', vr: '' }, 
                { tp: 'Label', id: 'alpha', tx: Global.ln.get('window-mdshape-alpha'), vr: '' }, 
                { tp: 'Numeric', id: 'alpha', mn: 0, mx: 100, vl: 100, st: 1 }, 
                { tp: 'Label', id: 'border', tx: Global.ln.get('window-mdshape-border'), vr: '' }, 
                { tp: 'Numeric', id: 'border', mn: 0, mx: 10, vl: 0, st: 1 }, 
                { tp: 'Label', id: 'bdcolor', tx: Global.ln.get('window-mdshape-bdcolor'), vr: '' }, 
                { tp: 'TInput', id: 'bdcolor', tx: '#FFFFFF', vr: '' }, 
                { tp: 'Label', id: 'bdalpha', tx: Global.ln.get('window-mdshape-bdalpha'), vr: '' }, 
                { tp: 'Numeric', id: 'bdalpha', mn: 0, mx: 100, vl: 100, st: 1 }, 
                { tp: 'Label', id: 'rotation', tx: Global.ln.get('window-mdshape-rotation'), vr: '' }, 
                { tp: 'Numeric', id: 'rotation', mn: 0, mx: 359, vl: 0, st: 1 }, 
                //{ tp: 'Spacer', id: 'show', ht: 20 }, 
                { tp: 'Button', id: 'show', tx: Global.ln.get('window-mdshape-show'), ac: this.onShow }, 
            ]),
            this.ui.forge('rightcol', [
                { tp: 'Custom', cont: this._shape }
            ]),
            this.ui.forge('bottom', [
                { tp: 'Spacer', id: 'btadd', ht: 10 }, 
                { tp: 'Button', id: 'btadd', tx: Global.ln.get('window-mdshape-show'), ac: this.onOpen }, 
                { tp: 'Custom', cont: this.ui.hcontainers['addtocol'] }
            ]), 510));
        this.ui.buttons['btadd'].visible = false;
    }

    /**
        Loading initial file list.
    **/
    override public function acStart():Void {
        this._path = '';
        this._mode = 'simple';
        this._shape.visible = false;
        this._desc = null;

        this.ui.hcontainers['addtocol'].setWidth(960, [ 260, 260, 260, 40, 100]);
        var list:Array<Dynamic> = [ ];
        for (k in GlobalPlayer.movie.collections.keys()) {
            list.push({
                text: GlobalPlayer.movie.collections[k].name, 
                value: k
            });
        }
        this.ui.setSelectOptions('addtocol', list);
        this.ui.hcontainers['addtocol'].visible = false;
        this.ui.buttons['btadd'].visible = false;
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Show current shape.
    **/
    private function onShow(evt:Event):Void {
        var shcolor:String = this.ui.inputs['color'].text;
        shcolor = StringTools.replace(shcolor, '#', '0x');
        var shcolorint:Int = Std.parseInt(shcolor);
        if (shcolorint == null) shcolor = '0x000000';
        var bdcolor:String = this.ui.inputs['bdcolor'].text;
        bdcolor = StringTools.replace(bdcolor, '#', '0x');
        var bdcolorint:Int = Std.parseInt(bdcolor);
        if (bdcolorint == null) bdcolor = '0xFFFFFF';
        this.ui.inputs['color'].text = StringTools.replace(shcolor, '0x', '#');
        this.ui.inputs['bdcolor'].text = StringTools.replace(bdcolor, '0x', '#');

        this._desc = {
            type: this.ui.selects['shape'].selectedItem.value, 
            color: shcolor, 
            alpha: (this.ui.numerics['alpha'].value / 100), 
            border: Math.round(this.ui.numerics['border'].value), 
            bdcolor: bdcolor, 
            bdalpha: (this.ui.numerics['bdalpha'].value / 100), 
            rotation: Math.round(this.ui.numerics['rotation'].value), 
        };

        this._shape.visible = false;
        this._shape.load(StringStatic.jsonStringify(this._desc));
    }

    private function onShape(ok:Bool):Void {
        if (ok) {
            this._shape.width = this._shape.oWidth - 50;
            this._shape.height = this._shape.oHeight - 50;
            this._shape.x = (500 - this._shape.width) / 2;
            this._shape.y = (500 - this._shape.height) / 2;
            this._shape.visible = true;

            this.ui.hcontainers['addtocol'].visible = false;
            if (this._mode == 'asset') {
                this.ui.buttons['btadd'].text = Global.ln.get('window-media-addshape');
            } else if (this._mode == 'assetsingle') {
                this.ui.buttons['btadd'].text = Global.ln.get('window-media-addshape');
            } else if (this._mode == 'newasset') {
                this.ui.buttons['btadd'].text = Global.ln.get('window-media-addast');
            } else {
                this.ui.buttons['btadd'].text = Global.ln.get('window-media-addstage');
                if (this.ui.selects['addtocol'].dataProvider.length > 0) {
                    this.ui.hcontainers['addtocol'].visible = true;
                }
            }
            this.ui.buttons['btadd'].visible = true;
        } else {
            this._desc = null;
            this.ui.buttons['btadd'].visible = false;
            this.ui.hcontainers['addtocol'].visible = false;
        }
    }

    /**
        Opens the current shape.
    **/
    override private function onOpen(evt:TriggerEvent):Void {
        if (this._desc != null) {
            var strdesc:String = StringStatic.jsonStringify(this._desc);
            if (this._mode == 'asset') {
                // set to asset
                this._mode = 'simple';
                this._ac('addasset', [ 'path' => '', 'type' => this._type, 'file' => strdesc, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime), 'num' => this._filenum ]);
                PopUpManager.removePopUp(this);
            } else if (this._mode == 'assetsingle') {
                // set to asset
                this._mode = 'simple';
                this._ac('assetsingle', [ 'path' => '', 'type' => this._type, 'file' => strdesc, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime), 'num' => this._filenum ]);
                PopUpManager.removePopUp(this);
            } else if (this._mode == 'newasset') {
                // add new asset
                this._mode = 'simple';
                this._ac('addnewasset', [ 'path' => '', 'type' => this._type, 'file' => strdesc, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
                PopUpManager.removePopUp(this);
            } else {
                // add to stage
                this._ac('addstage', [ 'path' => '', 'type' => this._type, 'file' => strdesc, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
                PopUpManager.removePopUp(this);
            }
        }
    }

    override private function onAddToCol(evt:TriggerEvent):Void {
        if ((this._desc != null) && (this.ui.selects['addtocol'].selectedItem != null)) {
            var strdesc:String = StringStatic.jsonStringify(this._desc);
            this._ac('addtocol', [ 'stage' => 'true', 'col' => this.ui.selects['addtocol'].selectedItem.value, 'path' => '', 'type' => this._type, 'file' => strdesc, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
            if (this.ui.toggles['close'].selected) {
                PopUpManager.removePopUp(this);
            } else {
                this._shape.visible = false;
                this._desc = null;
                this.ui.buttons['btadd'].visible = false;
                this.ui.hcontainers['addtocol'].visible = false;
                Global.showMsg(Global.ln.get('window-media-addedstage'));
            }
        }
    }

    override private function onAddAsset(evt:TriggerEvent):Void {
        if ((this._desc != null) && (this.ui.selects['addtocol'].selectedItem != null)) {
            var strdesc:String = StringStatic.jsonStringify(this._desc);
            this._ac('addtocol', [ 'stage' => 'false', 'col' => this.ui.selects['addtocol'].selectedItem.value, 'path' => '', 'type' => this._type, 'file' => strdesc, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
            if (this.ui.toggles['close'].selected) {
                PopUpManager.removePopUp(this);
            } else {
                this._shape.visible = false;
                this._desc = null;
                this.ui.buttons['btadd'].visible = false;
                this.ui.hcontainers['addtocol'].visible = false;
                Global.showMsg(Global.ln.get('window-media-addedcol'));
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        super.action(ac, data);
        this._shape.visible = false;
        this._desc = StringStatic.jsonParse(data['current']);
        if ((this._desc == null) || (this._desc.color == null)) {
            // nothing to do
        } else {
            this.ui.inputs['color'].text = StringTools.replace(this._desc.color, '0x', '#');
            this.ui.numerics['alpha'].value = Math.round(100 * this._desc.alpha);
            this.ui.numerics['border'].value = this._desc.border;
            this.ui.inputs['bdcolor'].text = StringTools.replace(this._desc.bdcolor, '0x', '#');
            this.ui.numerics['bdalpha'].value = Math.round(100 * this._desc.bdalpha);
            this.ui.numerics['rotation'].value = this._desc.rotation;
            this._shape.load(data['current']);
            this.ui.setSelectValue('shape', this._desc.type);
        } 
    }

}