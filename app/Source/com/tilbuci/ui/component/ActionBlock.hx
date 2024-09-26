package com.tilbuci.ui.component;

import openfl.events.MouseEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.VerticalLayout;
import feathers.controls.Label;
import feathers.skins.RectangleSkin;
import feathers.controls.Panel;
import openfl.Assets;

import com.tilbuci.ui.component.BlockArea;
import com.tilbuci.data.Global;

class ActionBlock extends Panel {

    private var _name:Label;

    private var _paramArea:Panel;

    private var _paramValues:Array<Label> = [ ];

    private var _extra1Area:Panel;

    private var _extra2Area:Panel;

    public var blaction:BlockAction;

    private var _clickAction:Dynamic;

    private var _dbClickAction:Dynamic;

    public var selected:Bool = false;

    public var order:Int = 0;

    public var isOpen:Bool = false;

    private var _blocks1:Array<ActionBlock> = [ ];

    private var _blocks2:Array<ActionBlock> = [ ];

    private var _addbt1:IDButton;

    private var _addbt2:IDButton;

    public function new(bl:BlockAction, wd:Float, ord:Int, clAc:Dynamic = null, dbClAc:Dynamic = null) {
        super();
        this.blaction = bl;
        var vlay:VerticalLayout = new VerticalLayout();
        vlay.gap = 5;
        vlay.setPadding(8);
        this.layout = vlay;
        var skin:RectangleSkin = new RectangleSkin(SolidColor(0x444444), SolidColor(1, 0x888888));
        skin.cornerRadius = 5;
        this.backgroundSkin = skin;
        this.width = wd - 24;
        this.order = ord;
        this.isOpen = false;
        
        this._name = new Label((this.order + 1) + ': ' + Global.acInfo.getAcName(bl.ac) + Global.acInfo.getParamLine(bl.ac, bl.param));
        this._name.x = 5;
        this._name.y = 5;
        this._name.maxWidth = this.width - 20;
        this.addChild(this._name);

        var inlay:VerticalLayout = new VerticalLayout();
        inlay.gap = 2;
        inlay.setPadding(5);

        if ((Global.acInfo.getNumParams(bl.ac) > 0) || (bl.param.length > 0)) {
            this._paramArea = new Panel();
            this._paramArea.backgroundSkin = new RectangleSkin(SolidColor(0x000000), SolidColor(1, 0x888888));
            this._paramArea.width = this.width - 20;
            this._paramArea.layout = inlay;
            var pat:Int = 0;
            for (i in 0...bl.param.length) {
                var lb:Label = new Label(Global.acInfo.getAcParam(bl.ac, i, bl.param[i]));
                lb.variant = Label.VARIANT_DETAIL;
                this._paramValues.push(lb);
                pat = i + 1;
            }
            if (pat < Global.acInfo.getNumParams(bl.ac)) {
                for (i in pat...Global.acInfo.getNumParams(bl.ac)) {
                    var lb:Label = new Label(Global.acInfo.getAcParam(bl.ac, i));
                    lb.variant = Label.VARIANT_DETAIL;
                    this._paramValues.push(lb);
                }
            }
            for (par in this._paramValues) this._paramArea.addChild(par);
        }

        var exlay:VerticalLayout = new VerticalLayout();
        exlay.gap = 5;
        exlay.setPadding(8);

        if (Global.acInfo.getExtra1(bl.ac) != '') {
            this._extra1Area = new Panel();
            this._extra1Area.backgroundSkin = new RectangleSkin(SolidColor(0x000000), SolidColor(1, 0x888888));
            this._extra1Area.width = this.width - 20;
            this._extra1Area.layout = exlay;
            var lb:Label = new Label(Global.ln.get('acblock-' + Global.acInfo.getExtra1(bl.ac)));
            this._extra1Area.addChild(lb);
            this._paramValues.push(lb);
            if (bl.extras.exists(Global.acInfo.getExtra1(bl.ac))) {
                for (ex in 0...bl.extras[Global.acInfo.getExtra1(bl.ac)].length) {
                    var ab:ActionBlock = new ActionBlock(bl.extras[Global.acInfo.getExtra1(bl.ac)][ex], (this.width - 20), ex, clickAction1, dbClAc);
                    this._extra1Area.addChild(ab);
                    this._blocks1.push(ab);
                }
            }
            this._addbt1 = new IDButton('addbt', addActionBlock1, null, Assets.getBitmapData('btPlus'));
            this._addbt1.toolTip = Global.ln.get('acblock-addbt');
            this._extra1Area.addChild(this._addbt1);
        }

        if (Global.acInfo.getExtra2(bl.ac) != '') {
            this._extra2Area = new Panel();
            this._extra2Area.backgroundSkin = new RectangleSkin(SolidColor(0x000000), SolidColor(1, 0x888888));
            this._extra2Area.width = this.width - 20;
            this._extra2Area.layout = exlay;
            var lb:Label = new Label(Global.ln.get('acblock-' + Global.acInfo.getExtra2(bl.ac)));
            this._extra2Area.addChild(lb);
            this._paramValues.push(lb);
            if (bl.extras.exists(Global.acInfo.getExtra2(bl.ac))) {
                for (ex in 0...bl.extras[Global.acInfo.getExtra2(bl.ac)].length) {
                    var ab:ActionBlock = new ActionBlock(bl.extras[Global.acInfo.getExtra2(bl.ac)][ex], (this.width - 20), ex, clickAction2, dbClAc);
                    this._extra2Area.addChild(ab);
                    this._blocks2.push(ab);
                }
            }
            this._addbt2 = new IDButton('addbt', addActionBlock2, null, Assets.getBitmapData('btPlus'));
            this._addbt2.toolTip = Global.ln.get('acblock-addbt');
            this._extra2Area.addChild(this._addbt2);
        }

        if (clAc != null) {
            this.addEventListener(MouseEvent.CLICK, onClick);
            this.addEventListener(MouseEvent.MIDDLE_CLICK, onClickMiddle);
            this.addEventListener(MouseEvent.DOUBLE_CLICK, onDbClick);
            this._clickAction = clAc;
            this._dbClickAction = dbClAc;
        }
    }

    public function setOrder(num:Int):Void {
        this.order = num;
        if (this.isOpen) {
            this._name.text = (this.order + 1) + ': ' + Global.acInfo.getAcName(this.blaction.ac);
        } else {
            this._name.text = (this.order + 1) + ': ' + Global.acInfo.getAcName(this.blaction.ac) + Global.acInfo.getParamLine(this.blaction.ac, this.blaction.param);
        }
    }

    public function select():Void {
        this.selected = true;
        var skin:RectangleSkin = new RectangleSkin(SolidColor(0x000088), SolidColor(1, 0x888888));
        skin.cornerRadius = 5;
        this.backgroundSkin = skin;
    }

    public function unselect():Void {
        this.selected = false;
        var skin:RectangleSkin = new RectangleSkin(SolidColor(0x444444), SolidColor(1, 0x888888));
        skin.cornerRadius = 5;
        this.backgroundSkin = skin;
    }

    public function openAll():Void {
        if ((this._paramArea != null) && (this._paramArea.parent == null)) this.addChild(this._paramArea);
        if ((this._extra1Area != null) && (this._extra1Area.parent == null)) {
            this.addChild(this._extra1Area);
            for (i in 0...this._extra1Area.numChildren) {
                if (this._extra1Area.getChildAt(i) is ActionBlock) {
                    var ac:ActionBlock = cast this._extra1Area.getChildAt(i);
                    ac.openAll();
                }
            }
        }
        if ((this._extra2Area != null) && (this._extra2Area.parent == null)) {
            this.addChild(this._extra2Area);
            for (i in 0...this._extra2Area.numChildren) {
                if (this._extra2Area.getChildAt(i) is ActionBlock) {
                    var ac:ActionBlock = cast this._extra2Area.getChildAt(i);
                    ac.openAll();
                }
            }
        }
        this._name.text = (this.order + 1) + ': ' + Global.acInfo.getAcName(this.blaction.ac);
        this.isOpen = true;
    }

    public function closeAll():Void {
        if ((this._paramArea != null) && (this._paramArea.parent != null)) this.removeChild(this._paramArea);
        if ((this._extra1Area != null) && (this._extra1Area.parent != null)) {
            this.removeChild(this._extra1Area);
            for (i in 0...this._extra1Area.numChildren) {
                if (this._extra1Area.getChildAt(i) is ActionBlock) {
                    var ac:ActionBlock = cast this._extra1Area.getChildAt(i);
                    ac.closeAll();
                }
            }
        }
        if ((this._extra2Area != null) && (this._extra2Area.parent != null)) {
            this.removeChild(this._extra2Area);
            for (i in 0...this._extra2Area.numChildren) {
                if (this._extra2Area.getChildAt(i) is ActionBlock) {
                    var ac:ActionBlock = cast this._extra2Area.getChildAt(i);
                    ac.closeAll();
                }
            }
        }
        this._name.text = (this.order + 1) + ': ' + Global.acInfo.getAcName(this.blaction.ac) + Global.acInfo.getParamLine(this.blaction.ac, this.blaction.param);
        this.isOpen = false;
    }

    public function refresh() {
        if (!this.isOpen) {
            this._name.text = (this.order + 1) + ': ' + Global.acInfo.getAcName(this.blaction.ac) + Global.acInfo.getParamLine(this.blaction.ac, this.blaction.param);
        }
        this._paramArea.removeChildren();
        while (this._paramValues.length > 0) this._paramValues.shift();
        var pat:Int = 0;
        for (i in 0...this.blaction.param.length) {
            var lb:Label = new Label(Global.acInfo.getAcParam(this.blaction.ac, i, this.blaction.param[i]));
            lb.variant = Label.VARIANT_DETAIL;
            this._paramValues.push(lb);
            pat = i + 1;
        }
        if (pat < Global.acInfo.getNumParams(this.blaction.ac)) {
            for (i in pat...Global.acInfo.getNumParams(this.blaction.ac)) {
                var lb:Label = new Label(Global.acInfo.getAcParam(this.blaction.ac, i));
                lb.variant = Label.VARIANT_DETAIL;
                this._paramValues.push(lb);
            }
        }
        for (par in this._paramValues) this._paramArea.addChild(par);
    }

    public function toObject():Dynamic {
        var obj:Dynamic = {
            ac: this.blaction.ac, 
            param: this.blaction.param
        };
        if (Global.acInfo.getExtra1(this.blaction.ac) != '') {
            var ex1:Array<Dynamic> = [ ];
            for (bl in this._blocks1) ex1.push(bl.toObject());
            Reflect.setField(obj, Global.acInfo.getExtra1(this.blaction.ac), ex1);
        }
        if (Global.acInfo.getExtra2(this.blaction.ac) != '') {
            var ex2:Array<Dynamic> = [ ];
            for (bl in this._blocks2) ex2.push(bl.toObject());
            Reflect.setField(obj, Global.acInfo.getExtra2(this.blaction.ac), ex2);
        }
        return (obj);
    }

    public function kill():Void {
        this.removeChildren();
        this._name = null;
        if (this._paramArea != null) {
            this._paramArea.removeChildren();
            this._paramArea = null;
        }
        if (this._extra1Area != null) {
            this._extra1Area.removeChildren();
            this._extra1Area = null;
            this._addbt1.kill();
            this._addbt1 = null;
        }
        if (this._extra2Area != null) {
            this._extra2Area.removeChildren();
            this._extra2Area = null;
            this._addbt2.kill();
            this._addbt2 = null;
        }
        while (this._paramValues.length > 0) this._paramValues.shift();
        while (this._blocks1.length > 0) this._blocks1.shift().kill();
        while (this._blocks2.length > 0) this._blocks2.shift().kill();
        this._blocks1 = null;
        this._blocks2 = null;
        this._paramValues = null;
        this.blaction.kill();
        this.blaction = null;
        if (this._clickAction != null) {
            this.removeEventListener(MouseEvent.CLICK, onClick);
            this.removeEventListener(MouseEvent.DOUBLE_CLICK, onDbClick);
            this.removeEventListener(MouseEvent.MIDDLE_CLICK, onClickMiddle);
        }
        this._clickAction = null;
        this._dbClickAction = null;
    }

    public function unselectAll(bl:ActionBlock):Void {
        if (this != bl) this.unselect();
        for (bl1 in this._blocks1) bl1.unselectAll(bl);
        for (bl2 in this._blocks2) bl2.unselectAll(bl);
    }

    public function upAction(sl:ActionBlock):Void {
        var isHere:Int = 0;
        for (bl in this._blocks1) if (bl == sl) isHere = 1;
        if (isHere == 0) for (bl in this._blocks2) if (bl == sl) isHere = 2;
        if (isHere == 1) {
            if (sl.order > 0) {
                var newArr:Array<ActionBlock> = [ ];
                if ((sl.order - 1) > 0) {
                    for (i in 0...(sl.order - 1)) {
                        newArr.push(this._blocks1[i]);
                    }
                }
                newArr.push(this._blocks1[sl.order]);
                newArr.push(this._blocks1[sl.order - 1]);
                if (this._blocks1.length > (sl.order + 1)) {
                    for (i in (sl.order + 1)...this._blocks1.length) {
                        newArr.push(this._blocks1[i]);
                    }
                }
                while (this._blocks1.length > 0) this._blocks1.shift();
                while (newArr.length > 0) this._blocks1.push(newArr.shift());
                this._extra1Area.removeChildren();
                this._extra1Area.addChild(new Label(Global.ln.get('acblock-' + Global.acInfo.getExtra1(this.blaction.ac))));
                for (i in 0...this._blocks1.length) {
                    this._blocks1[i].setOrder(i);
                    this._extra1Area.addChild(this._blocks1[i]);
                }
                this._extra1Area.addChild(this._addbt1);
            }
        } else if (isHere == 2) {
            if (sl.order > 0) {
                var newArr:Array<ActionBlock> = [ ];
                if ((sl.order - 1) > 0) {
                    for (i in 0...(sl.order - 1)) {
                        newArr.push(this._blocks2[i]);
                    }
                }
                newArr.push(this._blocks2[sl.order]);
                newArr.push(this._blocks2[sl.order - 1]);
                if (this._blocks2.length > (sl.order + 1)) {
                    for (i in (sl.order + 1)...this._blocks2.length) {
                        newArr.push(this._blocks2[i]);
                    }
                }
                while (this._blocks2.length > 0) this._blocks2.shift();
                while (newArr.length > 0) this._blocks2.push(newArr.shift());
                this._extra2Area.removeChildren();
                this._extra2Area.addChild(new Label(Global.ln.get('acblock-' + Global.acInfo.getExtra2(this.blaction.ac))));
                for (i in 0...this._blocks2.length) {
                    this._blocks2[i].setOrder(i);
                    this._extra2Area.addChild(this._blocks2[i]);
                }
                this._extra2Area.addChild(this._addbt2);
            }
        } else {
            for (bl in this._blocks1) bl.upAction(sl);
            for (bl in this._blocks2) bl.upAction(sl);
        }
    }

    public function downAction(sl:ActionBlock):Void {
        var isHere:Int = 0;
        for (bl in this._blocks1) if (bl == sl) isHere = 1;
        if (isHere == 0) for (bl in this._blocks2) if (bl == sl) isHere = 2;
        if (isHere == 1) {
            if (sl.order < (this._blocks1.length - 1)) {
                var newArr:Array<ActionBlock> = [ ];
                if (sl.order > 0) {
                    for (i in 0...sl.order) {
                        newArr.push(this._blocks1[i]);
                    }
                }
                newArr.push(this._blocks1[sl.order + 1]);
                newArr.push(this._blocks1[sl.order]);
                if (this._blocks1.length > (sl.order + 2)) {
                    for (i in (sl.order + 2)...this._blocks1.length) {
                        newArr.push(this._blocks1[i]);
                    }
                }
                while (this._blocks1.length > 0) this._blocks1.shift();
                while (newArr.length > 0) this._blocks1.push(newArr.shift());
                this._extra1Area.removeChildren();
                this._extra1Area.addChild(new Label(Global.ln.get('acblock-' + Global.acInfo.getExtra1(this.blaction.ac))));
                for (i in 0...this._blocks1.length) {
                    this._blocks1[i].setOrder(i);
                    this._extra1Area.addChild(this._blocks1[i]);
                }
                this._extra1Area.addChild(this._addbt1);
            }
        } else if (isHere == 2) {
            if (sl.order < (this._blocks2.length - 1)) {
                var newArr:Array<ActionBlock> = [ ];
                if (sl.order > 0) {
                    for (i in 0...sl.order) {
                        newArr.push(this._blocks2[i]);
                    }
                }
                newArr.push(this._blocks2[sl.order + 1]);
                newArr.push(this._blocks2[sl.order]);
                if (this._blocks2.length > (sl.order + 2)) {
                    for (i in (sl.order + 2)...this._blocks2.length) {
                        newArr.push(this._blocks2[i]);
                    }
                }
                while (this._blocks2.length > 0) this._blocks2.shift();
                while (newArr.length > 0) this._blocks2.push(newArr.shift());
                this._extra2Area.removeChildren();
                this._extra2Area.addChild(new Label(Global.ln.get('acblock-' + Global.acInfo.getExtra2(this.blaction.ac))));
                for (i in 0...this._blocks2.length) {
                    this._blocks2[i].setOrder(i);
                    this._extra2Area.addChild(this._blocks2[i]);
                }
                this._extra2Area.addChild(this._addbt2);
            }
        } else {
            for (bl in this._blocks1) bl.downAction(sl);
            for (bl in this._blocks2) bl.downAction(sl);
        }
    }

    public function removeAction(sl:ActionBlock):Void {
        var isHere:Int = 0;
        for (bl in this._blocks1) if (bl == sl) isHere = 1;
        if (isHere == 0) for (bl in this._blocks2) if (bl == sl) isHere = 2;
        if (isHere == 1) {
            this._blocks1.splice(sl.order, 1);
            this._extra1Area.removeChildren();
            this._extra1Area.addChild(new Label(Global.ln.get('acblock-' + Global.acInfo.getExtra1(this.blaction.ac))));
            for (i in 0...this._blocks1.length) {
                this._blocks1[i].setOrder(i);
                this._extra1Area.addChild(this._blocks1[i]);
            }
            this._extra1Area.addChild(this._addbt1);
        } else if (isHere == 2) {
            this._blocks2.splice(sl.order, 1);
            this._extra2Area.removeChildren();
            this._extra2Area.addChild(new Label(Global.ln.get('acblock-' + Global.acInfo.getExtra2(this.blaction.ac))));
            for (i in 0...this._blocks2.length) {
                this._blocks2[i].setOrder(i);
                this._extra2Area.addChild(this._blocks2[i]);
            }
            this._extra2Area.addChild(this._addbt2);
        } else {
            for (bl in this._blocks1) bl.removeAction(sl);
            for (bl in this._blocks2) bl.removeAction(sl);
        }
    }

    private function addActionBlock1(evt:MouseEvent):Void {
        evt.stopImmediatePropagation();
        Global.showNewBlockWindow(onNewBlock1);
    }

    private function onNewBlock1(jsonac:Dynamic):Void {
        if (jsonac == false) {
            // nothing to do
        } else {
            this._extra1Area.removeChild(this._addbt1);
            var bla:ActionBlock = new ActionBlock(new BlockAction(jsonac), (this.width - 20), this._blocks1.length, this._clickAction, this._dbClickAction);
            this._blocks1.push(bla);
            this._extra1Area.addChild(bla);
            this._extra1Area.addChild(this._addbt1);
        }
    }

    private function addActionBlock2(evt:MouseEvent):Void {
        evt.stopImmediatePropagation();
        Global.showNewBlockWindow(onNewBlock2);
    }

    private function onNewBlock2(jsonac:Dynamic):Void {
        if (jsonac == false) {
            // nothing to do
        } else {
            this._extra2Area.removeChild(this._addbt1);
            var bla:ActionBlock = new ActionBlock(new BlockAction(jsonac), (this.width - 20), this._blocks2.length, this._clickAction, this._dbClickAction);
            this._blocks2.push(bla);
            this._extra2Area.addChild(bla);
            this._extra2Area.addChild(this._addbt2);
        }
    }

    private function onClick(evt:MouseEvent):Void {
        evt.stopImmediatePropagation();
        this._clickAction(this);
    }

    private function onDbClick(evt:MouseEvent):Void {
        evt.stopImmediatePropagation();
        this._dbClickAction(this);
    }

    private function onClickMiddle(evt:MouseEvent):Void {
        evt.stopImmediatePropagation();
        if (this.isOpen) {
            this.closeAll();
        } else {
            this.openAll();
        }
    }

    private function clickAction1(bl:ActionBlock, inner:Bool = false):Void {
        if (inner) {
            for (b in this._blocks1) b.unselect();
            for (b in this._blocks2) b.unselect();
        } else {
            if (bl.selected) {
                bl.unselect();
            } else {
                for (b in this._blocks1) b.unselect();
                bl.select();
            }
            for (b in this._blocks2) b.unselect();
        }
        this._clickAction(bl, true);
    }

    private function clickAction2(bl:ActionBlock, inner:Bool = false):Void {
        if (inner) {
            for (b in this._blocks1) b.unselect();
            for (b in this._blocks2) b.unselect();
        } else {
            if (bl.selected) {
                bl.unselect();
            } else {
                for (b in this._blocks2) b.unselect();
                bl.select();
            }
            for (b in this._blocks1) b.unselect();
        }
        this._clickAction(bl, true);
    }

}