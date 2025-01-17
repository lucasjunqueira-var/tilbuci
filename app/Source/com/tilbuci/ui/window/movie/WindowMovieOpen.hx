/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.movie;

/** OPENFL **/
import com.tilbuci.data.GlobalPlayer;
import openfl.events.Event;
import openfl.display.Stage;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;

class WindowMovieOpen extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-movieopen-title'), 800, 430, false);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-movieopen-title'), this.ui.forge('window', [
            { tp: 'Label', id: 'openabout', tx: Global.ln.get('window-movieopen-wait') }, 
            { tp: 'List', id: 'openlist', vl: [ ], ht: 275, sl: null }, 
            { tp: 'Label', id: 'openowner', tx: Global.ln.get('window-movieopen-owner'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Button', id: 'okbutton', tx: Global.ln.get('window-movieopen-button'), ac: this.onOpen }
        ]));
        super.startInterface();
        this.ui.listDbClick('openlist', onOpen);
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
        this.loadMovies();
    }

    /**
        Loas the movies list.
    **/
    public function loadMovies():Void {
        this.ui.labels['openabout'].text = Global.ln.get('window-movieopen-wait');
        this.ui.setListValues('openlist', [ ]);
        Global.ws.send('Movie/List', [ ], this.onList);
    }

    /**
        The movies list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.labels['openabout'].text = Global.ln.get('window-movieopen-error');
        } else{
            if (ld.map['e'] == 0) {
                var ar:Array<Dynamic> = cast ld.map['list'];
                if (ar.length == 0) {
                    this.ui.labels['openabout'].text = Global.ln.get('window-movieopen-nomovies');
                } else {
                    var items:Array<Dynamic> = [ ];
                    for (i in ar) items.push({ text: Reflect.field(i, 'title'), value: Reflect.field(i, 'id') });
                    this.ui.setListValues('openlist', items);
                    this.ui.labels['openabout'].text = Global.ln.get('window-movieopen-about');
                }
            } else {
                this.ui.labels['openabout'].text = Global.ln.get('window-movieopen-error');
            }
        }
    }

    /**
        Opens the selected movie.
    **/
    private function onOpen(evt:TriggerEvent = null):Void {
        if (this.ui.lists['openlist'].selectedItem != null) {
            this._ac('movieload', ['id' => this.ui.lists['openlist'].selectedItem.value]);
            GlobalPlayer.area.imgSelect();
            PopUpManager.removePopUp(this);
        }
    }

}