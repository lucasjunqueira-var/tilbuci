package com.tilbuci.ui.component;

import openfl.Assets;
import com.tilbuci.data.Global;
import feathers.events.TriggerEvent;
import openfl.events.MouseEvent;
import feathers.layout.VerticalLayout;
import com.tilbuci.statictools.StringStatic;
import feathers.controls.ScrollContainer;

class BlockArea extends ScrollContainer {

    /**
        reference to the code area
    **/
    private var _code:CodeArea;

    /**
        json action object
    **/
    private var _json:Dynamic;

    /**
        the selected block
    **/
    private var _selected:ActionBlock;

    /**
        block objects
    **/
    private var _blocks:Array<ActionBlock> = [ ];

    /**
        add block
    **/
    private var _addbt:IDButton;

    public function new(code:CodeArea) {
        super();
        this._code = code;
        var lay:VerticalLayout = new VerticalLayout();
        lay.setPadding(5);
        lay.gap = 5;
        this.layout = lay;
        this._selected = null;
        this._addbt = new IDButton('addbt', addActionBlock, null, Assets.getBitmapData('btPlus'));
        this._addbt.toolTip = Global.ln.get('acblock-addbt');
    }

    public function refresh():Bool {

trace ('refresh', this._code.text);

        this.clear();

trace ('clear');

        if ((this._code.text == '') || (this._code.text == '[]')) {
            this._json = StringStatic.jsonParse('[ ]');
            this.addChild(this._addbt);
            return (true);
        } else {
            if (StringTools.trim(this._code.text.substr(0, 1)) != '[') this._code.text = '[' + StringTools.trim(this._code.text) + ']';
            this._json = StringStatic.jsonParse(this._code.text);
            if (this._json == false) {
                return (false);
            } else {
                var ord:Int = 0;
                for (k in Reflect.fields(this._json)) {
                    this.addAction(new BlockAction(Reflect.field(this._json, k)), ord);
                    ord++;
                }
                this.addChild(this._addbt);
                return (true);
            }
        }
    }

    public function addAction(ac:BlockAction, ord:Int):Void {
        var bla:ActionBlock = new ActionBlock(ac, this.width, ord, clickAction, dbClickAction);
        this._blocks.push(bla);
        this.addChild(bla);
    }

    public function clear():Void {
        this.removeChildren();
        this._selected = null;
        while (this._blocks.length > 0) this._blocks.shift().kill();
    }

    public function toJson():String {
        if (this._blocks.length == 0) {
            return ('');
        } else {
            var json:Array<Dynamic> = [ ];
            for (bl in this._blocks) json.push(bl.toObject());
            return (StringStatic.jsonStringify(json, '  '));
        }
    }

    public function openAll():Void {
        if (this._selected == null) {
            for (b in this._blocks) b.openAll();
        } else {
            this._selected.openAll();
        }
    }

    public function closeAll():Void {
        if (this._selected == null) {
            for (b in this._blocks) b.closeAll();
        } else {
            this._selected.closeAll();
        }
    }

    public function upAction():Void {
        if (this._selected != null) {
            var isHere:Bool = false;
            for (bl in this._blocks) if (bl == this._selected) isHere = true;
            if (isHere) {
                if (this._selected.order > 0) {
                    var newArr:Array<ActionBlock> = [ ];
                    if ((this._selected.order - 1) > 0) {
                        for (i in 0...(this._selected.order - 1)) {
                            newArr.push(this._blocks[i]);
                        }
                    }
                    newArr.push(this._blocks[this._selected.order]);
                    newArr.push(this._blocks[this._selected.order - 1]);
                    if (this._blocks.length > (this._selected.order + 1)) {
                        for (i in (this._selected.order + 1)...this._blocks.length) {
                            newArr.push(this._blocks[i]);
                        }
                    }
                    while (this._blocks.length > 0) this._blocks.shift();
                    while (newArr.length > 0) this._blocks.push(newArr.shift());
                    this.removeChildren();
                    for (i in 0...this._blocks.length) {
                        this._blocks[i].setOrder(i);
                        this.addChild(this._blocks[i]);
                    }
                    this.addChild(this._addbt);
                }
            } else {
                for (bl in this._blocks) bl.upAction(this._selected);
            }            
        }
    }

    public function downAction():Void {
        if (this._selected != null) {
            var isHere:Bool = false;
            for (bl in this._blocks) if (bl == this._selected) isHere = true;
            if (isHere) {
                if (this._selected.order < (this._blocks.length - 1)) {
                    var newArr:Array<ActionBlock> = [ ];
                    if (this._selected.order > 0) {
                        for (i in 0...this._selected.order) {
                            newArr.push(this._blocks[i]);
                        }
                    }
                    newArr.push(this._blocks[this._selected.order + 1]);
                    newArr.push(this._blocks[this._selected.order]);
                    if (this._blocks.length > (this._selected.order + 2)) {
                        for (i in (this._selected.order + 2)...this._blocks.length) {
                            newArr.push(this._blocks[i]);
                        }
                    }
                    while (this._blocks.length > 0) this._blocks.shift();
                    while (newArr.length > 0) this._blocks.push(newArr.shift());
                    this.removeChildren();
                    for (i in 0...this._blocks.length) {
                        this._blocks[i].setOrder(i);
                        this.addChild(this._blocks[i]);
                    }
                    this.addChild(this._addbt);
                }
            } else {
                for (bl in this._blocks) bl.downAction(this._selected);
            } 
        }
    }

    public function removeAction():Void {
        if (this._selected != null) {
            var isHere:Bool = false;
            for (bl in this._blocks) if (bl == this._selected) isHere = true;
            if (isHere) {
                this._blocks.splice(this._selected.order, 1);
                this.removeChildren();
                for (i in 0...this._blocks.length) {
                    this._blocks[i].setOrder(i);
                    this.addChild(this._blocks[i]);
                }
                this.addChild(this._addbt);
            } else {
                for (bl in this._blocks) bl.removeAction(this._selected);
            }
            this._selected.kill();
            this._selected = null;
        }
    }

    public function editAction():Void {
        if (this._selected != null) {
            Global.showEditBlockWindow(this._selected.blaction.ac, editReturn, this._selected.order, this._selected.blaction);
        }
    }

    public function addActionBlock(evt:MouseEvent):Void {
        evt.stopImmediatePropagation();
        Global.showNewBlockWindow(onNewBlock);
    }

    private function clickAction(bl:ActionBlock, inner:Bool = false):Void {
        this._selected = null;
        if (inner) {
            for (b in this._blocks) b.unselect();
            if (bl.selected) this._selected = bl;
        } else {
            if (bl.selected) {
                bl.unselect();
            } else {
                for (b in this._blocks) b.unselect();
                bl.select();
            }
            for (b in this._blocks) if (b.selected) this._selected = b;
        }
        for (b in this._blocks) b.unselectAll(this._selected);
    }

    private function dbClickAction(bl:ActionBlock):Void {
        this._selected = null;
        for (b in this._blocks) b.unselectAll(this._selected);
        bl.select();
        this._selected = bl;
        this.editAction();
    }

    private function onNewBlock(jsonac:Dynamic):Void {
        if (jsonac == false) {
            if (this._selected != null) {
                this._selected.refresh();
            }
        } else {
            this.removeChild(this._addbt);
            var bla:ActionBlock = new ActionBlock(new BlockAction(jsonac), this.width, this._blocks.length, clickAction, dbClickAction);
            this._blocks.push(bla);
            this.addChild(bla);
            this.addChild(this._addbt);
        }
    }

    private function editReturn(jsonac:Dynamic):Void {
        if (jsonac == false) {
            if (this._selected != null) {
                this._selected.refresh();
            }
        } else {
            this.removeChild(this._addbt);
            var bla:ActionBlock = new ActionBlock(new BlockAction(jsonac), this.width, this._blocks.length, clickAction, dbClickAction);
            this._blocks.push(bla);
            this.addChild(bla);
            this.addChild(this._addbt);
        }
    }

}

class BlockAction {

    public var ac:String = '';

    public var color:Int = 0;

    public var param:Array<String> = [ ];

    public var extras:Map<String, Array<BlockAction>>;

    public function new(json:Dynamic) {
        if (Reflect.hasField(json, 'ac')) this.ac = Reflect.field(json, 'ac');
        if (Reflect.hasField(json, 'param')) this.param = Reflect.field(json, 'param');
        this.extras = [
            'then' => [ ], 
            'else' => [ ], 
            'tick' => [ ], 
            'end' => [ ], 
            'ok' => [ ], 
            'cancel' => [ ], 
            'success' => [ ], 
            'error' => [ ], 
        ];
        for (ex in this.extras.keys()) {
            if (Reflect.hasField(json, ex)) {
                var acs:Dynamic = Reflect.field(json, ex);
                for (k in Reflect.fields(acs)) {
                    var bla:BlockAction = new BlockAction(Reflect.field(acs, k));
                    if (bla.ac != '') {
                        this.extras[ex].push(bla);
                    } else {
                        bla.kill();
                    }
                }
            }
        }   
    }

    public function extraJson(name:String):String {
        if (this.extras.exists(name)) {
            if (this.extras[name].length > 0) {
                var exdata:Array<Dynamic> = [ ];
                for (iex in 0...this.extras[name].length) {
                    exdata.push(this.extras[name][iex].toObject());
                }
                return (StringStatic.jsonStringify(exdata));
            } else {
                return ("[ ]");
            }
        } else {
            return ("[ ]");
        }
    }

    public function toObject():Dynamic {
        var ret:Dynamic = {
            ac: this.ac, 
            param: this.param
        };
        for (ex in this.extras.keys()) {
            if (this.extras[ex].length > 0) {
                var exdata:Array<Dynamic> = [ ];
                for (iex in 0...this.extras[ex].length) {
                    exdata.push(this.extras[ex][iex].toObject());
                }
                Reflect.setField(ret, ex, exdata);
            }
        }
        return (ret);
    }

    public function kill():Void {
        this.ac = null;
        if (this.param != null) while (this.param.length > 0) this.param.shift();
        this.param = null;
        if (this.extras != null) for (k in this.extras.keys()) {
            while(this.extras[k].length > 0) this.extras[k].shift().kill();
            this.extras.remove(k);
        }
        this.extras = null;
    }

}