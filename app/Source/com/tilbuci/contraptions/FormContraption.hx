/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

/** OPENFL **/
import haxe.CallStack.StackItem;
import feathers.controls.TextArea;
import feathers.controls.NumericStepper;
import feathers.controls.ToggleButton;
import feathers.data.ArrayCollection;
import feathers.controls.PopUpListView;
import feathers.controls.TextInput;
import feathers.core.FeathersControl;
import openfl.filters.GlowFilter;
import com.tilbuci.player.MovieArea;
import openfl.events.MouseEvent;
import com.tilbuci.display.PictureImage;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class FormContraption extends Sprite {

    public var ok:Bool = false;

    public var id:String;

    public var elem:Array<FormElem> = [ ];

    private var _created:Bool = false;

    private var _graphics:Map<String, PictureImage> = [ ];

    private var _ok:Dynamic;

    private var _cancel:Dynamic;

    private var _inputs:Map<String, FeathersControl> = [ ];

    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    public function setValue(nm:String, value:String):Bool {
        if (this._created) {
            if (this._inputs.exists(nm)) {
                var found:Bool = false;
                if (Std.isOfType(this._inputs[nm], TextInput)) {
                    var timp:TextInput = cast this._inputs[nm];
                    timp.text = GlobalPlayer.parser.parseString(value);
                    found = true;
                } else if (Std.isOfType(this._inputs[nm], NumericStepper)) {
                    var nimp:NumericStepper = cast this._inputs[nm];
                    nimp.value = GlobalPlayer.parser.parseInt(value);
                    found = true;
                } else if (Std.isOfType(this._inputs[nm], ToggleButton)) {
                    var tgimp:ToggleButton = cast this._inputs[nm];
                    tgimp.selected = GlobalPlayer.parser.parseBool(value);
                    found = true;
                } else if (Std.isOfType(this._inputs[nm], TextArea)) {
                    var tximp:TextArea = cast this._inputs[nm];
                    tximp.text = GlobalPlayer.parser.parseString(value);
                    found = true;
                } else if (Std.isOfType(this._inputs[nm], PopUpListView)) {
                    var simp:PopUpListView = cast this._inputs[nm];
                    for (i in 0...simp.dataProvider.length) {
                        if (simp.dataProvider.get(i).text == GlobalPlayer.parser.parseString(value)) {
                            simp.selectedIndex = i;
                        }
                    }
                    found = true;
                }
                return (found);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    public function getValue(nm:String):String {
        if (this._created) {
            if (this._inputs.exists(nm)) {
                var found:String = '';
                if (Std.isOfType(this._inputs[nm], TextInput)) {
                    var timp:TextInput = cast this._inputs[nm];
                    found = timp.text;
                } else if (Std.isOfType(this._inputs[nm], NumericStepper)) {
                    var nimp:NumericStepper = cast this._inputs[nm];
                    found = Std.string(nimp.value);
                } else if (Std.isOfType(this._inputs[nm], ToggleButton)) {
                    var tgimp:ToggleButton = cast this._inputs[nm];
                    if (tgimp.selected) found = 'true';
                        else found = 'false';
                } else if (Std.isOfType(this._inputs[nm], TextArea)) {
                    var tximp:TextArea = cast this._inputs[nm];
                    found = tximp.text;
                } else if (Std.isOfType(this._inputs[nm], PopUpListView)) {
                    var simp:PopUpListView = cast this._inputs[nm];
                    found = simp.selectedItem.text;
                }
                return (found);
            } else {
                return ('');
            }
        } else {
            return ('');
        }
    }

    public function setStepper(nm:String, min:Int, max:Int, stp:Int):Bool {
        if (this._created) {
            if (this._inputs.exists(nm)) {
                if (Std.isOfType(this._inputs[nm], NumericStepper)) {
                    var nimp:NumericStepper = cast this._inputs[nm];
                    nimp.minimum = min;
                    nimp.maximum = max;
                    nimp.step = stp;
                    return (true);
                } else {
                    return (false);
                }
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    public function start(acok:Dynamic, accancel:Dynamic):Bool {
        if (this.ok) {
            this._ok = acok;
            this._cancel = accancel;
            if (!this._created) {
                for (el in this.elem) {
                    switch (el.type) {
                        case 'background':
                            this._graphics['background'] = new PictureImage();
                            this._graphics['background'].load(el.file);
                            this._graphics['background'].visible = true;
                        case 'btok':
                            this._graphics['btok'] = new PictureImage();
                            this._graphics['btok'].load(el.file);
                            this._graphics['btok'].visible = true;
                            this._graphics['btok'].x = el.x;
                            this._graphics['btok'].y = el.y;
                            this._graphics['btok'].addEventListener(MouseEvent.CLICK, onOk);
                            this._graphics['btok'].addEventListener(MouseEvent.MOUSE_OVER, onOkOver);
                            this._graphics['btok'].addEventListener(MouseEvent.MOUSE_OUT, onOkOut);
                        case 'btcancel':
                            this._graphics['btcancel'] = new PictureImage();
                            this._graphics['btcancel'].load(el.file);
                            this._graphics['btcancel'].visible = true;
                            this._graphics['btcancel'].x = el.x;
                            this._graphics['btcancel'].y = el.y;
                            this._graphics['btcancel'].addEventListener(MouseEvent.CLICK, onCancel);
                            this._graphics['btcancel'].addEventListener(MouseEvent.MOUSE_OVER, onCancelOver);
                            this._graphics['btcancel'].addEventListener(MouseEvent.MOUSE_OUT, onCancelOut);
                        case 'input':
                            this._inputs[el.name] = new TextInput();
                            this._inputs[el.name].x = el.x;
                            this._inputs[el.name].y = el.y;
                            this._inputs[el.name].width = el.width;
                        case 'select':
                            var selinput:PopUpListView = new PopUpListView();
                            var sellist:Array<String> = el.options.split(';');
                            if (sellist.length == 0) sellist.push('?');
                            var values:Array<Dynamic> = [ ];
                            for (val in sellist) values.push({ text: val });
                            selinput.dataProvider = new ArrayCollection(values);
                            selinput.itemToText = (item:Dynamic) -> {
                                return (item.text);
                            };
                            this._inputs[el.name] = selinput;
                            this._inputs[el.name].x = el.x;
                            this._inputs[el.name].y = el.y;
                            this._inputs[el.name].width = el.width;
                        case 'toggle':
                            this._inputs[el.name] = new ToggleButton();
                            this._inputs[el.name].x = el.x;
                            this._inputs[el.name].y = el.y;
                        case 'numeric':
                            var nst:NumericStepper = new NumericStepper();
                            nst.minimum = 0;
                            nst.maximum = 10000;
                            nst.step = 1;
                            this._inputs[el.name] = nst;
                            this._inputs[el.name].x = el.x;
                            this._inputs[el.name].y = el.y;
                            this._inputs[el.name].width = el.width; 
                        case 'password':
                            var tpass:TextInput = new TextInput();
                            tpass.displayAsPassword = true;
                            this._inputs[el.name] = tpass;
                            this._inputs[el.name].x = el.x;
                            this._inputs[el.name].y = el.y;
                            this._inputs[el.name].width = el.width;
                        case 'textarea':
                            this._inputs[el.name] = new TextArea();
                            this._inputs[el.name].x = el.x;
                            this._inputs[el.name].y = el.y;
                            this._inputs[el.name].width = el.width;
                    }
                }
                if (this._graphics.exists('background')) this.addChild(this._graphics['background']);
                if (this._graphics.exists('btok')) this.addChild(this._graphics['btok']);
                if (this._graphics.exists('btcancel')) this.addChild(this._graphics['btcancel']);
                for (k in this._inputs.keys()) this.addChild(this._inputs[k]);
            }
            this._created = true;
            return (true);
        } else {
            return (false);
        }
    }

    public function remove():Void {
        this.removeChildren();
        if (this.parent != null) this.parent.removeChild(this);
    }

    public function clone():FormContraption {
        return (new FormContraption(this.toObject()));
    }

    public function load(data:Dynamic):Bool {
        this.ok = false;
        while (this.elem.length > 0) this.elem.shift();
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'elem')) {
                var delem:Dynamic = Reflect.field(data, 'elem');
                for (el in Reflect.fields(delem)) {
                    var formel:FormElem = Reflect.field(delem, el);
                    this.elem.push(formel);
                }
                this.ok = true;
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    public function kill():Void {
        if (this.parent != null) this.parent.removeChild(this);
        this.removeChildren();
        this.id = null;
        while (this.elem.length > 0) this.elem.shift();
        this.elem = null;
        if (this._graphics.exists('btok')) {
            this._graphics['btok'].removeEventListener(MouseEvent.CLICK, onOk);
            this._graphics['btok'].removeEventListener(MouseEvent.MOUSE_OVER, onOkOver);
            this._graphics['btok'].removeEventListener(MouseEvent.MOUSE_OUT, onOkOut);
        }
        if (this._graphics.exists('btcancel')) {
            this._graphics['btcancel'].removeEventListener(MouseEvent.CLICK, onCancel);
            this._graphics['btcancel'].removeEventListener(MouseEvent.MOUSE_OVER, onCancelOver);
            this._graphics['btcancel'].removeEventListener(MouseEvent.MOUSE_OUT, onCancelOut);
        }
        for (k in this._graphics.keys()) {
            this._graphics[k].kill();
            this._graphics.remove(k);
        }
        this._graphics = null;
        this._ok = this._cancel = null;
        for (k in this._inputs.keys()) {
            this._inputs.remove(k);
        }
        this._inputs = null;
    }

    public function toObject():Dynamic {
        return({
            id: this.id, 
            elem: this.elem, 
        });
    }

    private function onOk(evt:MouseEvent):Void {
        this.onOkOut(null);
        this.onCancelOut(null);
        if (this._ok != null) GlobalPlayer.parser.run(this._ok, true);
        this._ok = this._cancel = null;
        GlobalPlayer.contraptions.hideForm();
    }

    private function onOkOver(evt:MouseEvent):Void {
        if (GlobalPlayer.mdata.highlight != '') {
            this._graphics['btok'].filters = [
                new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
            ];
        }
    }

    private function onOkOut(evt:MouseEvent):Void {
        this._graphics['btok'].filters = [ ];
    }

    private function onCancel(evt:MouseEvent):Void {
        this.onOkOut(null);
        this.onCancelOut(null);
        if (this._cancel != null) GlobalPlayer.parser.run(this._cancel, true);
        this._ok = this._cancel = null;
        GlobalPlayer.contraptions.hideForm();
    }

    private function onCancelOver(evt:MouseEvent):Void {
        if (GlobalPlayer.mdata.highlight != '') {
            this._graphics['btcancel'].filters = [
                new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
            ];
        }
    }

    private function onCancelOut(evt:MouseEvent):Void {
        this._graphics['btcancel'].filters = [ ];
    }
}

typedef FormElem = {
    var name:String;
    var type:String;
    var file:String;
    var options:String;
    var width:Int;
    var x:Int;
    var y:Int;
}