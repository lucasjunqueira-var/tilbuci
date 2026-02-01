/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;

import com.tilbuci.display.InstanceImage;
import feathers.controls.Label;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.ui.base.ConfirmWindow;
import feathers.controls.LayoutGroup;
import feathers.events.TriggerEvent;
import com.tilbuci.data.GlobalPlayer;
import feathers.layout.AnchorLayoutData;
import feathers.controls.ListView;
import feathers.data.ArrayCollection;
import com.tilbuci.data.Global;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.Assets;

class InstancesPanel extends DropDownPanel {

    private var _curX:Float = 0;
    private var _curY:Float = 0;
    private var _curW:Float = 0;
    private var _curH:Float = 0;
    private var _calculating:Bool = false;

    public function new(wd:Float) {
        super(Global.ln.get('rightbar-instances'), wd);

        this.ui.createHContainer('copybuttons', 0x333333);
        this.ui.createIconButton('none', onNone, new Bitmap(Assets.getBitmapData('btNone')), null, this.ui.hcontainers['copybuttons']);
        this.ui.createIconButton('all', onAll, new Bitmap(Assets.getBitmapData('btAll')), null, this.ui.hcontainers['copybuttons']);
        this.ui.createIconButton('btcopy', onCopy, new Bitmap(Assets.getBitmapData('btCopy')), null, this.ui.hcontainers['copybuttons']);
        this.ui.createIconButton('btpaste', onPaste, new Bitmap(Assets.getBitmapData('btPaste')), null, this.ui.hcontainers['copybuttons']);
        this.ui.hcontainers['copybuttons'].width = wd - 5;

        this.ui.createHContainer('stage', 0x333333);
        this.ui.createIconButton('stageleft', onStageLeft, new Bitmap(Assets.getBitmapData('btStageLeft')), null, this.ui.hcontainers['stage']);
        this.ui.createIconButton('stagecenter', onStageCenter, new Bitmap(Assets.getBitmapData('btStageCenter')), null, this.ui.hcontainers['stage']);
        this.ui.createIconButton('stageright', onStageRight, new Bitmap(Assets.getBitmapData('btStageRight')), null, this.ui.hcontainers['stage']);
        this.ui.createIconButton('stagetop', onStageTop, new Bitmap(Assets.getBitmapData('btStageTop')), null, this.ui.hcontainers['stage']);
        this.ui.createIconButton('stagemiddle', onStageMiddle, new Bitmap(Assets.getBitmapData('btStageMiddle')), null, this.ui.hcontainers['stage']);
        this.ui.createIconButton('stagebottom', onStageBottom, new Bitmap(Assets.getBitmapData('btStageBottom')), null, this.ui.hcontainers['stage']);
        this.ui.hcontainers['stage'].width = wd - 5;

        this.ui.createHContainer('selection', 0x333333);
        this.ui.createIconButton('selectionleft', onSelectionLeft, new Bitmap(Assets.getBitmapData('btSelectionLeft')), null, this.ui.hcontainers['selection']);
        this.ui.createIconButton('selectioncenter', onSelectionCenter, new Bitmap(Assets.getBitmapData('btSelectionCenter')), null, this.ui.hcontainers['selection']);
        this.ui.createIconButton('selectionright', onSelectionRight, new Bitmap(Assets.getBitmapData('btSelectionRight')), null, this.ui.hcontainers['selection']);
        this.ui.createIconButton('selectiontop', onSelectionTop, new Bitmap(Assets.getBitmapData('btSelectionTop')), null, this.ui.hcontainers['selection']);
        this.ui.createIconButton('selectionmiddle', onSelectionMiddle, new Bitmap(Assets.getBitmapData('btSelectionMiddle')), null, this.ui.hcontainers['selection']);
        this.ui.createIconButton('selectionbottom', onSelectionBottom, new Bitmap(Assets.getBitmapData('btSelectionBottom')), null, this.ui.hcontainers['selection']);
        this.ui.hcontainers['selection'].width = wd - 5;

        this.ui.createHContainer('distribute', 0x333333);
        this.ui.createIconButton('distributeh', onDistributeH, new Bitmap(Assets.getBitmapData('btDistributeH')), null, this.ui.hcontainers['distribute']);
        this.ui.createIconButton('distributev', onDistributeV, new Bitmap(Assets.getBitmapData('btDistributeV')), null, this.ui.hcontainers['distribute']);
        this.ui.hcontainers['distribute'].width = wd - 5;

        this.ui.createHContainer('pos', 0x333333);
        this.ui.createLabel('xpos', Global.ln.get('rightbar-instances-xpos'), Label.VARIANT_DETAIL, this.ui.hcontainers['pos']);
        this.ui.createLabel('ypos', Global.ln.get('rightbar-instances-ypos'), Label.VARIANT_DETAIL, this.ui.hcontainers['pos']);
        this.ui.hcontainers['pos'].width = wd - 5;

        this.ui.createHContainer('posnum', 0x333333);
        this.ui.createNumeric('xpos', -100000, 100000, 1, 0, this.ui.hcontainers['posnum']);
        this.ui.createNumeric('ypos', -100000, 100000, 1, 0, this.ui.hcontainers['posnum']);
        this.ui.hcontainers['posnum'].width = wd - 5;

        this.ui.createHContainer('size', 0x333333);
        this.ui.createLabel('xsize', Global.ln.get('rightbar-instances-xsize'), Label.VARIANT_DETAIL, this.ui.hcontainers['size']);
        this.ui.createLabel('ysize', Global.ln.get('rightbar-instances-ysize'), Label.VARIANT_DETAIL, this.ui.hcontainers['size']);
        this.ui.hcontainers['size'].width = wd - 5;

        this.ui.createHContainer('sizenum', 0x333333);
        this.ui.createNumeric('xsize', -100000, 100000, 1, 0, this.ui.hcontainers['sizenum']);
        this.ui.createNumeric('ysize', -100000, 100000, 1, 0, this.ui.hcontainers['sizenum']);
        this.ui.hcontainers['sizenum'].width = wd - 5;

        this._content = this.ui.forge('instancepan', [
            { tp: 'List', id: 'ilist', ht: 200, vl: [ ], sl: null, ch: onChange}, 
            { tp: 'Custom', cont: this.ui.hcontainers['copybuttons'] }, 
            { tp: 'Spacer', id: 'align', ht: 5, ln: false }, 
            { tp: 'Custom', cont: this.ui.hcontainers['pos'] }, 
            { tp: 'Custom', cont: this.ui.hcontainers['posnum'] },
            { tp: 'Custom', cont: this.ui.hcontainers['size'] }, 
            { tp: 'Custom', cont: this.ui.hcontainers['sizenum'] },
            { tp: 'Custom', cont: this.ui.hcontainers['stage'] }, 
            { tp: 'Custom', cont: this.ui.hcontainers['selection'] }, 
            { tp: 'Custom', cont: this.ui.hcontainers['distribute'] }, 
            { tp: 'Spacer', id: 'extra', ht: 5, ln: false }, 
            { tp: 'Button', id: 'randbt', tx: Global.ln.get('rightbar-instances-rand'), ac: onRand}, 
        ], 0x333333, (wd - 5));
        this.ui.lists['ilist'].layoutData = AnchorLayoutData.fill();
        this.ui.lists['ilist'].itemToText = (item:Dynamic) -> {
			return item.text;
		};
        this.ui.lists['ilist'].allowMultipleSelection = true;

        this.ui.buttons['btcopy'].enabled = this.ui.buttons['btpaste'].enabled = false;
        this.ui.buttons['btcopy'].toolTip = Global.ln.get('rightbar-instances-noinstances');
        this.ui.buttons['btpaste'].toolTip = Global.ln.get('rightbar-instances-nocopied'); 
        this.ui.buttons['none'].toolTip = Global.ln.get('rightbar-instances-none'); 
        this.ui.buttons['all'].toolTip = Global.ln.get('rightbar-instances-all'); 
        this.ui.buttons['stageleft'].toolTip = Global.ln.get('rightbar-instances-stageleft'); 
        this.ui.buttons['stagecenter'].toolTip = Global.ln.get('rightbar-instances-stagecenter'); 
        this.ui.buttons['stageright'].toolTip = Global.ln.get('rightbar-instances-stageright'); 
        this.ui.buttons['stagetop'].toolTip = Global.ln.get('rightbar-instances-stagetop'); 
        this.ui.buttons['stagemiddle'].toolTip = Global.ln.get('rightbar-instances-stagemiddle'); 
        this.ui.buttons['stagebottom'].toolTip = Global.ln.get('rightbar-instances-stagebottom'); 
        this.ui.buttons['selectionleft'].toolTip = Global.ln.get('rightbar-instances-selectionleft'); 
        this.ui.buttons['selectioncenter'].toolTip = Global.ln.get('rightbar-instances-selectioncenter'); 
        this.ui.buttons['selectionright'].toolTip = Global.ln.get('rightbar-instances-selectionright'); 
        this.ui.buttons['selectiontop'].toolTip = Global.ln.get('rightbar-instances-selectiontop'); 
        this.ui.buttons['selectionmiddle'].toolTip = Global.ln.get('rightbar-instances-selectionmiddle'); 
        this.ui.buttons['selectionbottom'].toolTip = Global.ln.get('rightbar-instances-selectionbottom'); 
        this.ui.buttons['distributeh'].toolTip = Global.ln.get('rightbar-instances-disth'); 
        this.ui.buttons['distributev'].toolTip = Global.ln.get('rightbar-instances-distv'); 

        this.ui.numerics['xpos'].addEventListener(Event.CHANGE, onChangePosX);
        this.ui.numerics['ypos'].addEventListener(Event.CHANGE, onChangePosY);
        this.ui.numerics['xsize'].addEventListener(Event.CHANGE, onChangeSizeX);
        this.ui.numerics['ysize'].addEventListener(Event.CHANGE, onChangeSizeY);

        Global.copy.updateDisplay = this.updatePaste;
    }

    private function onCopy(evt:TriggerEvent):Void {
        if (this.ui.lists['ilist'].selectedItems.length > 0) {
            Global.copy.clear();
            for (inst in this.ui.lists['ilist'].selectedItems) {
                if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].exists(inst.value)) {
                    if (Global.copy.addCollection(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][inst.value].collection)) {
                        Global.copy.addInstance(inst.value, GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][inst.value]);
                    }
                }
            }
        }
        Global.copy.broadcast();
        this.updatePaste();
    }

    private function onPaste(evt:TriggerEvent):Void {
        if (Global.copy.hasCopy() && (GlobalPlayer.movie.scId != '')) {
            Global.copy.pasteInstances();
        }
    }

    private function onNone(evt:TriggerEvent):Void {
        GlobalPlayer.area.imgSelect();
        this.reloadContent();
        for (cb in this.callbacks) cb([ 'nm' => '' ]);
        this.updatePaste();
    }

    private function onAll(evt:TriggerEvent):Void {
        GlobalPlayer.area.imgSelect();
        this.reloadContent();
        var indices:Array<Int> = [ ];
        for (n in 0...this.ui.lists['ilist'].dataProvider.length) indices.push(n);
        this.ui.lists['ilist'].selectedIndices = indices;
        this.updatePaste();
    }

    private function onRand(evt:TriggerEvent):Void {
        if (this.ui.lists['ilist'].dataProvider.length > 0) {
            Global.showPopup(Global.ln.get('rightbar-instances'), Global.ln.get('rightbar-instances-randcheck'), 340, 205, Global.ln.get('default-ok'), onRandConf, ConfirmWindow.MODECONFIRM, Global.ln.get('default-cancel'));
        }
        this.updatePaste();
    }

    private function onRandConf(ok:Bool):Void {
        if (ok) {
            var nms:Array<String> = [ ];
            for (i in 0...this.ui.lists['ilist'].dataProvider.length) {
                var ch:Bool = true;
                if (this.ui.lists['ilist'].selectedItem != null) {
                    if (i == this.ui.lists['ilist'].selectedIndex) {
                        ch = false;
                    }
                }
                if (ch) {
                    var name:String = this.ui.lists['ilist'].dataProvider.get(i).text;
                    var newname:String = StringStatic.random().substr(0, 10);
                    while (nms.contains(newname)) newname = StringStatic.random().substr(0, 10);
                    nms.push(newname);
                    GlobalPlayer.area.imgSelect(name);
                    GlobalPlayer.area.setCurrentStr('instance', newname);
                }
            }
            GlobalPlayer.area.imgSelect();
            this.reloadContent();
        }
        this.updatePaste();
    }

    override public function reloadContent(data:Map<String, Dynamic> = null):Void {
        var items = [ ];
        for (k in GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].keys()) {
            items.push({ text: k, value: k });
        }
        this.ui.lists['ilist'].dataProvider = new ArrayCollection(items);
        this.ui.buttons['btcopy'].enabled = false;
        this.ui.buttons['btcopy'].toolTip = Global.ln.get('rightbar-instances-noinstances');
        this.updatePaste();
    }

    override public function updateContent(data:Map<String, Dynamic> = null):Void {
        if (this.ui.lists['ilist'].dataProvider != null) {
            for (n in 0...this.ui.lists['ilist'].dataProvider.length) {
                if (this.ui.lists['ilist'].dataProvider.get(n) != null) {
                    if (this.ui.lists['ilist'].dataProvider.get(n).value == data['nm']) {
                        this.ui.lists['ilist'].selectedIndex = n;
                    }
                }
            }
        }
        this.updatePaste();
    }

    public function instanceRename(oldn:String, newn:String):Void {
        if (this.ui.lists['ilist'].dataProvider != null) {
            for (n in 0...this.ui.lists['ilist'].dataProvider.length) {
                if (this.ui.lists['ilist'].dataProvider.get(n) != null) {
                    if (this.ui.lists['ilist'].dataProvider.get(n).value == oldn) {
                        this.ui.lists['ilist'].dataProvider.get(n).text = newn;
                        this.ui.lists['ilist'].dataProvider.get(n).value = newn;
                        this.ui.lists['ilist'].selectedIndex = n;
                        this.ui.lists['ilist'].dataProvider.updateAt(this.ui.lists['ilist'].selectedIndex);
                    }
                }
            }
        }
        this.updatePaste();
    }

    private function onChange(evt:Event):Void {
        if (this.ui.lists['ilist'].selectedItems.length == 1) {
            GlobalPlayer.area.imgSelect(this.ui.lists['ilist'].selectedItems[0].value);
            for (cb in this.callbacks) cb([ 'nm' => this.ui.lists['ilist'].selectedItems[0].value ]);
            this.ui.buttons['btcopy'].enabled = true;
            this.ui.buttons['btcopy'].toolTip = Global.ln.get('rightbar-instances-copy');
            this.getNums();
        } else if (this.ui.lists['ilist'].selectedItems.length > 1) {
            GlobalPlayer.area.imgSelect(null);
            this.ui.buttons['btcopy'].enabled = true;
            this.ui.buttons['btcopy'].toolTip = Global.ln.get('rightbar-instances-copy');
            var insts:Array<String> = [ ];
            for (it in this.ui.lists['ilist'].selectedItems) insts.push(it.value);
            GlobalPlayer.area.imgSelectMultiple(insts);
            this.getNums();
        } else {
            this.ui.buttons['btcopy'].enabled = false;
            this.ui.buttons['btcopy'].toolTip = Global.ln.get('rightbar-instances-noinstances');
        }
        this.updatePaste();
    }

    private function getNums():Void {
        this._calculating = true;
        var nx:Null<Float> = null;
        var ny:Null<Float> = null;
        var nw:Null<Float> = null;
        var nh:Null<Float> = null;
        var endx:Null<Float> = null;
        var endy:Null<Float> = null;
        for (inst in this.ui.lists['ilist'].selectedItems) {
            var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
            if (ref != null) {
                if ((nx == null) || (nx > ref.x)) nx = ref.x;
                if ((ny == null) || (ny > ref.y)) ny = ref.y;
                if ((endx == null) || (endx < (ref.x + ref.width))) endx = ref.x + ref.width;
                if ((endy == null) || (endy < (ref.y + ref.height))) endy = ref.y + ref.height;
                nw = endx - nx;
                nh = endy - ny;
            }
        }
        if (nx != null) {
            this._curX = this.ui.numerics['xpos'].value = Math.round(nx);
            this._curY = this.ui.numerics['ypos'].value = Math.round(ny);
            this._curW = this.ui.numerics['xsize'].value = Math.round(nw);
            this._curH = this.ui.numerics['ysize'].value = Math.round(nh);
        }
        this._calculating = false;
    }

    private function onChangePosX(evt:Event):Void {
        if (!this._calculating && (this.ui.lists['ilist'].selectedItems.length > 0)) {
            var change:Float = this._curX - this.ui.numerics['xpos'].value;
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    ref.x -= change;
                }
            }
            this.onChange(null);
        }
    }

    private function onChangePosY(evt:Event):Void {
        if (!this._calculating && (this.ui.lists['ilist'].selectedItems.length > 0)) {
            var change:Float = this._curY - this.ui.numerics['ypos'].value;
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    ref.y -= change;
                }
            }
            this.onChange(null);
        }
    }

    private function onChangeSizeX(evt:Event):Void {
        if (!this._calculating && (this.ui.lists['ilist'].selectedItems.length > 0)) {
            var change:Float = this.ui.numerics['xsize'].value / this._curW;
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    ref.width *= change;
                    if (ref.x != this._curX) {
                        ref.x = this._curX + ((ref.x - this._curX) * change);
                    }
                }
            }
            this.onChange(null);
        }
    }

    private function onChangeSizeY(evt:Event):Void {
        if (!this._calculating && (this.ui.lists['ilist'].selectedItems.length > 0)) {
            var change:Float = this.ui.numerics['ysize'].value / this._curH;
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    ref.height *= change;
                    if (ref.y != this._curY) {
                        ref.y = this._curY + ((ref.y - this._curY) * change);
                    }
                }
            }
            this.onChange(null);
        }
    }

    private function updatePaste():Void {
        if (Global.copy.hasCopy()) {
            this.ui.buttons['btpaste'].enabled = true;
            this.ui.buttons['btpaste'].toolTip = Global.ln.get('rightbar-instances-paste'); 
        } else {
            this.ui.buttons['btpaste'].enabled = false;
            this.ui.buttons['btpaste'].toolTip = Global.ln.get('rightbar-instances-nocopied'); 
        }
    }

    private function onStageLeft():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 0) {
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    GlobalPlayer.area.setPropertyNum(inst.value, 'x', 0);
                }
            }
            this.onChange(null);
        }
    }

    private function onStageRight():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 0) {
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if (GlobalPlayer.orientation == 'horizontal') {
                        GlobalPlayer.area.setPropertyNum(inst.value, 'x', (GlobalPlayer.mdata.screen.big - ref.width));
                    } else {
                        GlobalPlayer.area.setPropertyNum(inst.value, 'x', (GlobalPlayer.mdata.screen.small - ref.width));
                    }
                }
            }
            this.onChange(null);
        }
    }

    private function onStageCenter():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 0) {
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if (GlobalPlayer.orientation == 'horizontal') {
                        GlobalPlayer.area.setPropertyNum(inst.value, 'x', ((GlobalPlayer.mdata.screen.big/2) - (ref.width/2)));
                    } else {
                        GlobalPlayer.area.setPropertyNum(inst.value, 'x', ((GlobalPlayer.mdata.screen.small/2) - (ref.width/2)));
                    }
                }
            }
            this.onChange(null);
        }
    }

    private function onStageTop():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 0) {
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    GlobalPlayer.area.setPropertyNum(inst.value, 'y', 0);
                }
            }
            this.onChange(null);
        }
    }

    private function onStageBottom():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 0) {
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if (GlobalPlayer.orientation == 'horizontal') {
                        GlobalPlayer.area.setPropertyNum(inst.value, 'y', (GlobalPlayer.mdata.screen.small - ref.height));
                    } else {
                        GlobalPlayer.area.setPropertyNum(inst.value, 'y', (GlobalPlayer.mdata.screen.big - ref.height));
                    }
                }
            }
            this.onChange(null);
        }
    }

    private function onStageMiddle():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 0) {
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if (GlobalPlayer.orientation == 'horizontal') {
                        GlobalPlayer.area.setPropertyNum(inst.value, 'y', ((GlobalPlayer.mdata.screen.small/2) - (ref.height/2)));
                    } else {
                        GlobalPlayer.area.setPropertyNum(inst.value, 'y', ((GlobalPlayer.mdata.screen.big/2) - (ref.height/2)));
                    }
                }
            }
            this.onChange(null);
        }
    }

    private function onSelectionLeft():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 1) {
            var refnum:Null<Float> = null;
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if ((refnum == null) || (refnum > ref.x)) refnum = ref.x;
                }
            }
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    GlobalPlayer.area.setPropertyNum(inst.value, 'x', refnum);
                }
            }
            this.onChange(null);
        }
    }

    private function onSelectionRight():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 1) {
            var refnum:Null<Float> = null;
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if ((refnum == null) || (refnum < (ref.x + ref.width))) refnum = ref.x + ref.width;
                }
            }
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    GlobalPlayer.area.setPropertyNum(inst.value, 'x', (refnum - ref.width));
                }
            }
            this.onChange(null);
        }
    }

    private function onSelectionCenter():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 1) {
            var refx:Null<Float> = null;
            var refwidth:Null<Float> = null;
            var refcenter:Null<Float> = null;
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if ((refx == null) || (refx > ref.x)) refx = ref.x;
                    if ((refwidth == null) || (refwidth < (ref.x + ref.width))) refwidth = ref.x + ref.width;
                    refcenter = refx + (refwidth / 2);
                }
            }
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    GlobalPlayer.area.setPropertyNum(inst.value, 'x', (refcenter - (ref.width/2)));
                }
            }
            this.onChange(null);
        }
    }

    private function onSelectionTop():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 1) {
            var refnum:Null<Float> = null;
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if ((refnum == null) || (refnum > ref.y)) refnum = ref.y;
                }
            }
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    GlobalPlayer.area.setPropertyNum(inst.value, 'y', refnum);
                }
            }
            this.onChange(null);
        }
    }

    private function onSelectionBottom():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 1) {
            var refnum:Null<Float> = null;
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if ((refnum == null) || (refnum < (ref.y + ref.height))) refnum = ref.y + ref.height;
                }
            }
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    GlobalPlayer.area.setPropertyNum(inst.value, 'y', (refnum - ref.height));
                }
            }
            this.onChange(null);
        }
    }

    private function onSelectionMiddle():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 1) {
            var refy:Null<Float> = null;
            var refheight:Null<Float> = null;
            var refcenter:Null<Float> = null;
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if ((refy == null) || (refy > ref.y)) refy = ref.y;
                    if ((refheight == null) || (refheight < (ref.y + ref.height))) refheight = ref.y + ref.height;
                    refcenter = refy + (refheight / 2);
                }
            }
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    GlobalPlayer.area.setPropertyNum(inst.value, 'y', (refcenter - (ref.height/2)));
                }
            }
            this.onChange(null);
        }
    }

    private function onDistributeH():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 2) {
            var refstart:Null<Float> = null;
            var refend:Null<Float> = null;
            var refsize:Null<Float> = null;
            var sizetot:Null<Float> = 0;
            var insts:Array<InstanceImage> = [ ];
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if ((refstart == null) || (refstart > ref.x)) refstart = ref.x;
                    if ((refend == null) || (refend < (ref.x + ref.width))) refend = ref.x + ref.width;
                    sizetot += ref.width;
                    refsize = refend - refstart;
                    insts.push(ref);
                }
            }
            if (insts.length > 2) {
                refsize = (refsize - sizetot) / (insts.length - 1);
                insts.sort(function(a:InstanceImage, b:InstanceImage) {
                    if (a.x < b.x) return -1;
                    else if (a.x > b.x) return 1;
                    else return 0;
                });
                for (i in 1...insts.length) {
                    insts[i].x = (insts[i-1].x + insts[i-1].width) + refsize;
                }
                this.onChange(null);
            }
        }
    }

    private function onDistributeV():Void {
        if (this.ui.lists['ilist'].selectedItems.length > 2) {
            var refstart:Null<Float> = null;
            var refend:Null<Float> = null;
            var refsize:Null<Float> = null;
            var sizetot:Null<Float> = 0;
            var insts:Array<InstanceImage> = [ ];
            for (inst in this.ui.lists['ilist'].selectedItems) {
                var ref:InstanceImage = GlobalPlayer.area.pickInstance(inst.value);
                if (ref != null) {
                    if ((refstart == null) || (refstart > ref.y)) refstart = ref.y;
                    if ((refend == null) || (refend < (ref.y + ref.height))) refend = ref.y + ref.height;
                    sizetot += ref.height;
                    refsize = refend - refstart;
                    insts.push(ref);
                }
            }
            if (insts.length > 2) {
                refsize = (refsize - sizetot) / (insts.length - 1);
                insts.sort(function(a:InstanceImage, b:InstanceImage) {
                    if (a.y < b.y) return -1;
                    else if (a.y > b.y) return 1;
                    else return 0;
                });
                for (i in 1...insts.length) {
                    insts[i].y = (insts[i-1].y + insts[i-1].height) + refsize;
                }
                this.onChange(null);
            }
        }
    }

}