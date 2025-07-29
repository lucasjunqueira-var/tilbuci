/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.movie;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
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
import com.tilbuci.data.GlobalPlayer;

class WindowMovieNew extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-movienew-title'), 800, InterfaceFactory.pickValue(430, 475), false);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-movienew-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'moviename', tx: Global.ln.get('window-movienew-name'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'moviename', tx: '', vr: '' },  
                { tp: 'Label', id: 'movieid', tx: Global.ln.get('window-movienew-id'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'movieid', tx: '', vr: '' },  
                { tp: 'Label', id: 'movieauthor', tx: Global.ln.get('window-movienew-author'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'movieauthor', tx: '', vr: '' }, 
                { tp: 'Label', id: 'moviecopyright', tx: Global.ln.get('window-movienew-copyright'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'moviecopyright', tx: '', vr: '' }, 
                { tp: 'Label', id: 'moviecopyleft', tx: Global.ln.get('window-movienew-copyleft'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'moviecopyleft', tx: '', vr: '' }, 
                { tp: 'Label', id: 'movieabout', tx: Global.ln.get('window-movienew-about'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TArea', id: 'movieabout', tx: '', vr: '', en: true }, 
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'moviesizebig', tx: Global.ln.get('window-movienew-sizebig'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Numeric', id: 'moviesizebig', mn: Global.AREASIZE_MIN, mx: Global.AREASIZE_MAX, st: 50, vl: 1920 }, 
                { tp: 'Label', id: 'moviesizesmall', tx: Global.ln.get('window-movienew-sizesmall'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Numeric', id: 'moviesizesmall', mn: Global.AREASIZE_MIN, mx: Global.AREASIZE_MAX, st: 50, vl: 1080 }, 
                { tp: 'Label', id: 'moviesizetype', tx: Global.ln.get('window-movienew-sizetype'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Select', id: 'moviesizetype', vl: [
                        { text: Global.ln.get('window-movienew-sizeboth'), value: "both" }, 
                        { text: Global.ln.get('window-movienew-sizeportrait'), value: "portrait" }, 
                        { text: Global.ln.get('window-movienew-sizelandscape'), value: "landscape" }, 
                        { text: Global.ln.get('window-movienew-sizesquare'), value: "square" }
                    ], sl: 'both' }, 
                { tp: 'Label', id: 'movietime', tx: Global.ln.get('window-movienew-timeframe'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Select', id: 'movietime', vl: [
                    { text: Global.ln.get('window-movienew-time025'), value: "0.25" }, 
                    { text: Global.ln.get('window-movienew-time050'), value: "0.50" }, 
                    { text: Global.ln.get('window-movienew-time100'), value: "1.00" }, 
                    { text: Global.ln.get('window-movienew-time150'), value: "1.50" }, 
                    { text: Global.ln.get('window-movienew-time200'), value: "2.00" }, 
                    { text: Global.ln.get('window-movienew-time250'), value: "2.50" }, 
                    { text: Global.ln.get('window-movienew-time300'), value: "3.00" }, 
                    { text: Global.ln.get('window-movienew-time350'), value: "3.50" }, 
                    { text: Global.ln.get('window-movienew-time400'), value: "4.00" }, 
                    { text: Global.ln.get('window-movienew-time450'), value: "4.50" }, 
                    { text: Global.ln.get('window-movienew-time500'), value: "5.00" }, 
                    ], sl: '1.00' }, 
                    { tp: 'Spacer', id: 'font-spacer', ht: 120, ln: false }, 
                { tp: 'Button', id: 'moviecreate', tx: Global.ln.get('window-movienew-create'), ac: this.onCreateMovie }
            ])));
            super.startInterface();
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Asks for a movie creation on server.
    **/
    private function onCreateMovie(evt:TriggerEvent):Void {
        if ((this.ui.inputs['moviename'].text == '') || (this.ui.inputs['movieauthor'].text == '')) {
            this.ui.createWarning(Global.ln.get('window-movienew-title'), Global.ln.get('window-movienew-norequired'), 300, 180, this.stage);
        } else {
            if (this.ui.numerics['moviesizebig'].value < Global.AREASIZE_MIN) this.ui.numerics['moviesizebig'].value = Global.AREASIZE_MIN;
            if (this.ui.numerics['moviesizesmall'].value < Global.AREASIZE_MIN) this.ui.numerics['moviesizesmall'].value = Global.AREASIZE_MIN;
            if (this.ui.numerics['moviesizebig'].value > Global.AREASIZE_MAX) this.ui.numerics['moviesizebig'].value = Global.AREASIZE_MAX;
            if (this.ui.numerics['moviesizesmall'].value > Global.AREASIZE_MAX) this.ui.numerics['moviesizesmall'].value = Global.AREASIZE_MAX;
            Global.ws.send('Movie/New', [
                'title' => this.ui.inputs['moviename'].text, 
                'id' => this.ui.inputs['movieid'].text, 
                'author' => this.ui.inputs['movieauthor'].text, 
                'copyright' => this.ui.inputs['moviecopyright'].text, 
                'copyleft' => this.ui.inputs['moviecopyleft'].text, 
                'about' => this.ui.tareas['movieabout'].text, 
                'sizebig' => this.ui.numerics['moviesizebig'].value, 
                'sizesmall' => this.ui.numerics['moviesizesmall'].value, 
                'moviesizetype' => this.ui.selects['moviesizetype'].selectedItem.value, 
                'interval' => this.ui.selects['movietime'].selectedItem.value
            ], onCreateMovieReturn);
        }
    }

    /**
        Movie creration return.
    **/
    private function onCreateMovieReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-movienew-title'), Global.ln.get('window-movienew-createer'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-movienew-title'), Global.ln.get('window-movienew-createer'), 300, 180, this.stage);
        } else {
            GlobalPlayer.area.imgSelect();
            PopUpManager.removePopUp(this);
            this._ac('movieload', [ 'id' => ld.map['id'] ]);
        }
    }

}