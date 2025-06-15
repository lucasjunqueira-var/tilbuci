/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.movie;

/** OPENFL **/
import com.tilbuci.ui.component.IDButton;
import com.tilbuci.ui.base.HInterfaceContainer;
import openfl.events.Event;
import openfl.display.Stage;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;

class WindowMovieSequences extends PopupWindow {

    /**
        current sequence
    **/
    private var _sequence:Array<Dynamic> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-movieseq-title'), 800, 650, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        var order:HInterfaceContainer = this.ui.createHContainer('order');
        order.addChild(new IDButton('orderup', onUp, null, Assets.getBitmapData('btUp'), false));
        order.addChild(new IDButton('orderdown', onDown, null, Assets.getBitmapData('btDown'), false));
        order.setWidth(360);
        this.addForm(Global.ln.get('window-movieseq-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'scenes', tx: Global.ln.get('window-movieseq-scenes'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'scenes', vl: [ ], sl: null, ht: 337 }, 
                { tp: 'Button', id: 'scenes', tx: Global.ln.get('window-movieseq-add'), ac: this.onAdd }
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'sequence', tx: Global.ln.get('window-movieseq-sequence'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'sequence', vl: [ ], sl: null, ht: 280 }, 
                { tp: 'Custom', cont: order }, 
                { tp: 'Button', id: 'sequenceremove', tx: Global.ln.get('window-movieseq-remove'), ac: this.onRemove },
                { tp: 'Button', id: 'sequenceclear', tx: Global.ln.get('window-movieseq-clear'), ac: this.onClear }
            ]),
            this.ui.forge('bottom', [
                { tp: 'Label', id: 'direction', tx: Global.ln.get('window-movieseq-direction'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Select', id: 'direction', vl: [
                    { text: Global.ln.get('window-movieseq-dirx'), value: 'x' }, 
                    { text: Global.ln.get('window-movieseq-diry'), value: 'y' }, 
                    { text: Global.ln.get('window-movieseq-dirz'), value: 'z' }, 
                ], sl: 'x' }, 
                { tp: 'Label', id: 'connect', tx: Global.ln.get('window-movieseq-connect'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Toggle', id: 'connect', vl: true }, 
                { tp: 'Spacer', id: 'connect', ht: 10, ln: false }, 
                { tp: 'Button', id: 'create', tx: Global.ln.get('window-movieseq-create'), ac: this.onCreate }
            ]), 410));
            this.ui.listDbClick('scenes', this.onAdd);
            this.ui.listDbClick('sequence', this.onRemove);
            super.startInterface();
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        this.ui.setListValues('scenes', [ ]);
        this.ui.setListValues('sequence', [ ]);
        while (this._sequence.length > 0) this._sequence.shift();
        Global.ws.send('Scene/List', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
    }

    /**
        Adds a scene to the sequence.
    **/
    private function onAdd(evt:TriggerEvent):Void {
        if (this.ui.lists['scenes'].selectedItem != null) {
            this._sequence.push({
                text: this.ui.lists['scenes'].selectedItem.text, 
                value: this.ui.lists['scenes'].selectedItem.value, 
            });
            this.ui.setListSelectValue('sequence', null);
            this.ui.setListValues('sequence', this._sequence);
            var available:Array<Dynamic> = [ ];
            for (n in 0...this.ui.lists['scenes'].dataProvider.length) {
                if (this.ui.lists['scenes'].selectedItem.value != this.ui.lists['scenes'].dataProvider.get(n).value) {
                    available.push({
                        text: this.ui.lists['scenes'].dataProvider.get(n).text, 
                        value: this.ui.lists['scenes'].dataProvider.get(n).value
                    });
                }
            }
            this.ui.setListSelectValue('scenes', null);
            this.ui.setListValues('scenes', available);
        }
    }

    /**
        Moves scene up on sequence.
    **/
    private function onUp(evt:TriggerEvent):Void {
        if (this.ui.lists['sequence'].selectedItem != null) {
            var index:Int = this.ui.lists['sequence'].selectedIndex;
            if (index > 0) {
                var val:String = this.ui.lists['sequence'].dataProvider.get(index).value;
                var list:Array<Dynamic> = [ ];
                for (n in 0...this.ui.lists['sequence'].dataProvider.length) {
                    if (n == (index - 1)) {
                        list.push({
                            text: this.ui.lists['sequence'].dataProvider.get(index).text, 
                            value: this.ui.lists['sequence'].dataProvider.get(index).value
                        });
                        list.push({
                            text: this.ui.lists['sequence'].dataProvider.get(n).text, 
                            value: this.ui.lists['sequence'].dataProvider.get(n).value
                        });
                    } else if (n != index) {
                        list.push({
                            text: this.ui.lists['sequence'].dataProvider.get(n).text, 
                            value: this.ui.lists['sequence'].dataProvider.get(n).value
                        });
                    }
                }
                while (this._sequence.length > 0) this._sequence.shift();
                this._sequence = list;
                this.ui.setListValues('sequence', this._sequence);
                this.ui.setListSelectValue('sequence', val);
            }
        }
    }

    /**
        Moves scene down on sequence.
    **/
    private function onDown(evt:TriggerEvent):Void {
        if (this.ui.lists['sequence'].selectedItem != null) {
            var index:Int = this.ui.lists['sequence'].selectedIndex;
            if (index < (this.ui.lists['sequence'].dataProvider.length - 1)) {
                var val:String = this.ui.lists['sequence'].dataProvider.get(index).value;
                var list:Array<Dynamic> = [ ];
                for (n in 0...this.ui.lists['sequence'].dataProvider.length) {
                    if (n == index + 1) {
                        list.push({
                            text: this.ui.lists['sequence'].dataProvider.get(n).text, 
                            value: this.ui.lists['sequence'].dataProvider.get(n).value
                        });
                        list.push({
                            text: this.ui.lists['sequence'].dataProvider.get(index).text, 
                            value: this.ui.lists['sequence'].dataProvider.get(index).value
                        });
                    } else if (n != index) {
                        list.push({
                            text: this.ui.lists['sequence'].dataProvider.get(n).text, 
                            value: this.ui.lists['sequence'].dataProvider.get(n).value
                        });
                    }
                }
                while (this._sequence.length > 0) this._sequence.shift();
                this._sequence = list;
                this.ui.setListValues('sequence', this._sequence);
                this.ui.setListSelectValue('sequence', val);
            }
        }
    }

    /**
        Removes a scene from the sequence.
    **/
    private function onRemove(evt:TriggerEvent):Void {
        if (this.ui.lists['sequence'].selectedItem != null) {
            var list:Array<Dynamic> = [ ];
            list.push({
                text: this.ui.lists['sequence'].selectedItem.text, 
                value: this.ui.lists['sequence'].selectedItem.value
            });
            for (n in 0...this.ui.lists['scenes'].dataProvider.length) {
                list.push({
                    text: this.ui.lists['scenes'].dataProvider.get(n).text, 
                    value: this.ui.lists['scenes'].dataProvider.get(n).value
                });
            }
            this.ui.setListSelectValue('scenes', null);
            this.ui.setListValues('scenes', list);
            list = [ ];
            for (n in 0...this.ui.lists['sequence'].dataProvider.length) {
                if (this.ui.lists['sequence'].selectedItem.value != this.ui.lists['sequence'].dataProvider.get(n).value) {
                    list.push({
                        text: this.ui.lists['sequence'].dataProvider.get(n).text, 
                        value: this.ui.lists['sequence'].dataProvider.get(n).value
                    });
                }
            }
            while (this._sequence.length > 0) this._sequence.shift();
            this._sequence = list;
            this.ui.setListSelectValue('sequence', null);
            this.ui.setListValues('sequence', this._sequence);
        }
    }

    /**
        Clears the sequence.
    **/
    private function onClear(evt:TriggerEvent):Void {
        this.ui.setListValues('scenes', [ ]);
        this.ui.setListValues('sequence', [ ]);
        while (this._sequence.length > 0) this._sequence.shift();
        Global.ws.send('Scene/List', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
    }

    /**
        Creates the sequence.
    **/
    private function onCreate(evt:TriggerEvent):Void {
        if (this._sequence.length > 1) {
            var list:Array<String> = [ ];
            for (seq in this._sequence) list.push(seq.value);
            var connect:String = 'false';
            if (this.ui.toggles['connect'].selected) connect = 'true';
            Global.ws.send('Movie/Navigation', [
                'movie' => GlobalPlayer.movie.mvId, 
                'seq' => list.join(';'), 
                'con' => connect, 
                'axis' => this.ui.selects['direction'].selectedItem.value, 
            ], this.onCreated);
        }
    }

    /**
        Return from sequence creation.
    **/
    private function onCreated(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-movieseq-title'), Global.ln.get('window-movieseq-error'), 420, 150, this.stage);
        } else {
            if (ld.map['e'] == 0) {
                this.ui.createWarning(Global.ln.get('window-movieseq-title'), Global.ln.get('window-movieseq-created'), 420, 150, this.stage);
            } else {
                this.ui.createWarning(Global.ln.get('window-movieseq-title'), Global.ln.get('window-movieseq-error'), 420, 150, this.stage);
            }
        }
    }

    /**
        The scenes list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-movieseq-title'), Global.ln.get('window-movieseq-nolist'), 420, 150, this.stage);
            PopUpManager.removePopUp(this);
        } else {
            if (ld.map['e'] == 0) {
                var ar:Array<Dynamic> = cast ld.map['list'];
                if (ar.length > 0) {
                    var items:Array<Dynamic> = [ ];
                    for (i in ar) items.push({ text: Reflect.field(i, 'title'), value: Reflect.field(i, 'id') });
                    this.ui.setListValues('scenes', items);
                    this.ui.setListValues('sequences', [ ]);
                    while (this._sequence.length > 0) this._sequence.shift();
                }
            } else {
                this.ui.createWarning(Global.ln.get('window-movieseq-title'), Global.ln.get('window-movieseq-nolist'), 420, 150, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

}