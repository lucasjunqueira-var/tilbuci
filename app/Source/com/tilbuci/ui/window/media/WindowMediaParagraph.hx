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

class WindowMediaParagraph extends WindowMediaBase {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic, mode:String) {
        // creating window
        super(ac, Global.ln.get('window-mdparagraph-title'), 'paragraph', mode);
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

        this.addForm(Global.ln.get('window-mdparagraph-title'), this.ui.forge('leftcol', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-mdparagraph-about'), vr: '' }, 
            { tp: 'TArea', id: 'text', tx: '', vr: '', en: true }, 
            { tp: 'Button', id: 'btadd', tx: Global.ln.get('window-mdparagraph-set'), ac: this.onOpen }, 
            { tp: 'Custom', cont: this.ui.hcontainers['addtocol'] }
        ]));
        this.ui.tareas['text'].height = 530;
    }

    /**
        Loading initial file list.
    **/
    override public function acStart():Void {
        this._path = '';
        this.ui.tareas['text'].text = '';
        this.ui.hcontainers['addtocol'].setWidth(960, [ 260, 260, 260, 40, 100]);
        var list:Array<Dynamic> = [ ];
        for (k in GlobalPlayer.movie.collections.keys()) {
            list.push({
                text: GlobalPlayer.movie.collections[k].name, 
                value: k
            });
        }
        this.ui.setSelectOptions('addtocol', list);
        if (list.length > 0) {
            this.ui.hcontainers['addtocol'].visible = true;
            this.ui.tareas['text'].height = 500;
        } else {
            this.ui.hcontainers['addtocol'].visible = false;
            this.ui.tareas['text'].height = 530;
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Opens the current text.
    **/
    override private function onOpen(evt:TriggerEvent):Void {
        if (this.ui.tareas['text'].text != '') {
            if (this._mode == 'asset') {
                // set to asset
                this._mode = 'simple';
                this._ac('addasset', [ 'path' => '', 'type' => this._type, 'file' => this.ui.tareas['text'].text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime), 'num' => this._filenum ]);
                PopUpManager.removePopUp(this);
            } else if (this._mode == 'assetsingle') {
                // set to asset
                this._mode = 'simple';
                this._ac('assetsingle', [ 'path' => '', 'type' => this._type, 'file' => this.ui.tareas['text'].text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime), 'num' => this._filenum ]);
                PopUpManager.removePopUp(this);
            } else if (this._mode == 'newasset') {
                // add new asset
                this._mode = 'simple';
                this._ac('addnewasset', [ 'path' => '', 'type' => this._type, 'file' => this.ui.tareas['text'].text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
                PopUpManager.removePopUp(this);
            } else {
                // add to stage
                this._ac('addstage', [ 'path' => '', 'type' => this._type, 'file' => this.ui.tareas['text'].text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
                PopUpManager.removePopUp(this);
            }
        }
    }

    override private function onAddToCol(evt:TriggerEvent):Void {
        if ((this.ui.tareas['text'].text != '') && (this.ui.selects['addtocol'].selectedItem != null)) {
            this._ac('addtocol', [ 'stage' => 'true', 'col' => this.ui.selects['addtocol'].selectedItem.value, 'path' => '', 'type' => this._type, 'file' => this.ui.tareas['text'].text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
            if (this.ui.toggles['close'].selected) {
                PopUpManager.removePopUp(this);
            } else {
                this.ui.tareas['text'].text = '';
                Global.showMsg(Global.ln.get('window-media-addedstage'));
            }
        }
    }

    override private function onAddAsset(evt:TriggerEvent):Void {
        if ((this.ui.tareas['text'].text != '') && (this.ui.selects['addtocol'].selectedItem != null)) {
            this._ac('addtocol', [ 'stage' => 'false', 'col' => this.ui.selects['addtocol'].selectedItem.value, 'path' => '', 'type' => this._type, 'file' => this.ui.tareas['text'].text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
            if (this.ui.toggles['close'].selected) {
                PopUpManager.removePopUp(this);
            } else {
                this.ui.tareas['text'].text = '';
                Global.showMsg(Global.ln.get('window-media-addedcol'));
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        super.action(ac, data);
        this.ui.tareas['text'].text = data['current'];
        if ((data['mode'] == 'asset') || (data['mode'] == 'assetsingle') || (data['mode'] == 'newasset') || (data['mode'] == 'single')) {
            this.ui.tareas['text'].height = 530;
            this.ui.hcontainers['addtocol'].visible = false;
        } else {
            if (this.ui.selects['addtocol'].dataProvider.length > 0) {
                this.ui.hcontainers['addtocol'].visible = true;
                this.ui.tareas['text'].height = 500;
            } else {
                this.ui.hcontainers['addtocol'].visible = false;
                this.ui.tareas['text'].height = 530;
            }
        }
    }

}