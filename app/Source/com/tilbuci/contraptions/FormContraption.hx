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

/**
 * A contraption that represents a form with various input elements (text, numeric, toggle, select, etc.)
 * and optional OK/Cancel buttons. Used for data entry and configuration dialogs.
 */
class FormContraption extends Sprite {

    /** Indicates whether the contraption is properly loaded and ready. */
    public var ok:Bool = false;

    /** Unique identifier for this form contraption. */
    public var id:String;

    /** Array of form element definitions (inputs, buttons, backgrounds). */
    public var elem:Array<FormElem> = [ ];

    private var _created:Bool = false;

    private var _graphics:Map<String, PictureImage> = [ ];

    private var _ok:Dynamic;

    private var _cancel:Dynamic;

    private var _inputs:Map<String, FeathersControl> = [ ];

    /**
     * Creates a new FormContraption instance.
     * @param data Optional initialization data (as returned by `toObject`).
     */
    public function new(data:Dynamic = null) {
        super();
        if (data != null) this.load(data);
    }

    /**
     * Sets the value of a named input element.
     * @param nm Name of the input element.
     * @param value New value as a string (will be parsed according to input type).
     * @return True if the element exists and the value was set, false otherwise.
     */
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

    /**
     * Retrieves the current value of a named input element.
     * @param nm Name of the input element.
     * @return The value as a string, or empty string if the element does not exist.
     */
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

    /**
     * Configures the range and step of a numeric stepper input.
     * @param nm Name of the numeric stepper element.
     * @param min Minimum allowed value.
     * @param max Maximum allowed value.
     * @param stp Step increment.
     * @return True if the element exists and is a numeric stepper, false otherwise.
     */
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

    /**
     * Starts the form, creating all visual elements and attaching event listeners.
     * @param acok Callback to execute when the OK button is clicked.
     * @param accancel Callback to execute when the Cancel button is clicked.
     * @return True if the contraption is loaded (ok = true), false otherwise.
     */
    public function start(acok:Dynamic, accancel:Dynamic):Bool {
        if (this.ok) {
            this._ok = acok;
            this._cancel = accancel;
            if (!this._created) {
                for (el in this.elem) {
                    switch (el.type) {
                        case 'background':
                            if (el.file != '') {
                                this._graphics['background'] = new PictureImage();
                                this._graphics['background'].load(el.file);
                                this._graphics['background'].visible = true;
                            }
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
                            if (el.file != '') {
                                this._graphics['btcancel'] = new PictureImage();
                                this._graphics['btcancel'].load(el.file);
                                this._graphics['btcancel'].visible = true;
                                this._graphics['btcancel'].x = el.x;
                                this._graphics['btcancel'].y = el.y;
                                this._graphics['btcancel'].addEventListener(MouseEvent.CLICK, onCancel);
                                this._graphics['btcancel'].addEventListener(MouseEvent.MOUSE_OVER, onCancelOver);
                                this._graphics['btcancel'].addEventListener(MouseEvent.MOUSE_OUT, onCancelOut);
                            }
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

    /**
     * Removes the form from its parent and clears its children.
     */
    public function remove():Void {
        this.removeChildren();
        if (this.parent != null) this.parent.removeChild(this);
    }

    /**
     * Creates a deep copy of this form contraption.
     * @return A new FormContraption with the same properties.
     */
    public function clone():FormContraption {
        return (new FormContraption(this.toObject()));
    }

    /**
     * Loads form configuration data.
     * @param data Dynamic object containing id and elem fields.
     * @return True if the data contains an 'id' and an 'elem' field, false otherwise.
     */
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

    /**
     * Completely destroys the form contraption, releasing all resources and removing event listeners.
     */
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

    /**
     * Serializes the form contraption to a plain object.
     * @return Dynamic object containing id and elem fields.
     */
    public function toObject():Dynamic {
        return({
            id: this.id,
            elem: this.elem,
        });
    }

    /**
     * OK button click handler. Executes the OK callback and hides the form.
     * @param evt MouseEvent object.
     */
    private function onOk(evt:MouseEvent):Void {
        this.onOkOut(null);
        this.onCancelOut(null);
        if (this._ok != null) GlobalPlayer.parser.run(this._ok, true);
        this._ok = this._cancel = null;
        GlobalPlayer.contraptions.hideForm();
    }

    /**
     * OK button mouse‑over handler. Applies a highlight glow if highlighting is enabled.
     * @param evt MouseEvent object.
     */
    private function onOkOver(evt:MouseEvent):Void {
        if (GlobalPlayer.cursorVisible) if (GlobalPlayer.mdata.highlight != '') {
            this._graphics['btok'].filters = [
                new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
            ];
        }
    }

    /**
     * OK button mouse‑out handler. Removes the highlight glow.
     * @param evt MouseEvent object.
     */
    private function onOkOut(evt:MouseEvent):Void {
        this._graphics['btok'].filters = [ ];
    }

    /**
     * Cancel button click handler. Executes the Cancel callback and hides the form.
     * @param evt MouseEvent object.
     */
    private function onCancel(evt:MouseEvent):Void {
        this.onOkOut(null);
        this.onCancelOut(null);
        if (this._cancel != null) GlobalPlayer.parser.run(this._cancel, true);
        this._ok = this._cancel = null;
        GlobalPlayer.contraptions.hideForm();
    }

    /**
     * Cancel button mouse‑over handler. Applies a highlight glow if highlighting is enabled.
     * @param evt MouseEvent object.
     */
    private function onCancelOver(evt:MouseEvent):Void {
        if (GlobalPlayer.cursorVisible) if (GlobalPlayer.mdata.highlight != '') {
            this._graphics['btcancel'].filters = [
                new GlowFilter(GlobalPlayer.mdata.highlightInt, 1, 4, 4, 255, 1, true)
            ];
        }
    }

    /**
     * Cancel button mouse‑out handler. Removes the highlight glow.
     * @param evt MouseEvent object.
     */
    private function onCancelOut(evt:MouseEvent):Void {
        this._graphics['btcancel'].filters = [ ];
    }
}

/**
 * Structure defining a single form element.
 */
typedef FormElem = {
    /** Element name (used to reference it in `setValue`/`getValue`). */
    var name:String;
    /** Element type: 'background', 'btok', 'btcancel', 'input', 'select', 'toggle', 'numeric', 'password', 'textarea'. */
    var type:String;
    /** Path or URL to an image file (for background, btok, btcancel). */
    var file:String;
    /** Semicolon‑separated list of options (for 'select' type). */
    var options:String;
    /** Width of the input element in pixels. */
    var width:Int;
    /** X coordinate of the element. */
    var x:Int;
    /** Y coordinate of the element. */
    var y:Int;
}