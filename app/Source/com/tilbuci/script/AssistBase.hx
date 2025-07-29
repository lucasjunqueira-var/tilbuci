/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.script;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
import feathers.controls.Label;
import com.tilbuci.ui.base.HInterfaceContainer;
import openfl.events.Event;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.component.IDButton;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.DataLoader;

class AssistBase extends PopupWindow {

    /**
        action buttons
    **/
    private var _idbuttons:Map<String, IDButton> = [ ];

    /**
        actions list
    **/
    private var _actions:Map<String, VarAction> = [ ];


    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic, title:String, about:String) {
        // creating window
        super(ac, title, 800, InterfaceFactory.pickValue(700, 710), false);
        this._idbuttons['btCopy'] = new IDButton('btCopy', onCopy, Global.ln.get('window-acvariable-create'), Assets.getBitmapData('btCopy'));
        this._idbuttons['btShow'] = new IDButton('btShow', onShow, Global.ln.get('window-acvariable-show'));
        this._idbuttons['ggeneral'] = new IDButton('ggeneral', onGeneral, Global.ln.get('window-globals-get'), Assets.getBitmapData('btCopy'));
        this._idbuttons['ginstance'] = new IDButton('instance', onInstance, Global.ln.get('window-globals-get'), Assets.getBitmapData('btCopy'));
        this._idbuttons['gmovie'] = new IDButton('movie', onMovie, Global.ln.get('window-globals-get'), Assets.getBitmapData('btCopy'));
        this.addForm(title, this.ui.createColumnHolder('form', 
            this.ui.forge('left', [
                { tp: "Label", id: 'list', tx: about, vr: '' }, 
                { tp: "List", id: 'list', vl: [ ], sl: [ ], ht: 195 }, 
                { tp: "Label", id: 'params', tx: Global.ln.get('window-acvariable-param'), vr: '' }, 
                { tp: "TInput", id: 'p1', tx: '' }, 
                { tp: "TInput", id: 'p2', tx: '' }, 
                { tp: "TInput", id: 'p3', tx: '' }, 
                { tp: "TInput", id: 'p4', tx: '' }, 
                { tp: "TInput", id: 'p5', tx: '' }, 
                { tp: "TInput", id: 'p6', tx: '' }, 
                { tp: "TInput", id: 'p7', tx: '' }, 
                { tp: "Custom", cont: this._idbuttons['btCopy'] }, 
                { tp: "Custom", cont: this._idbuttons['btShow'] }, 
                { tp: "Button", id: "close", tx: Global.ln.get('window-actions-close'), ac: onClose }, 
            ]), 
            this.ui.forge('right', [
                { tp: "Label", id: 'ggeneral', tx: Global.ln.get('window-globals-general'), vr: '' }, 
                { tp: "List", id: 'ggeneral', vl: [
                    { text: Global.ln.get('window-globals-playing'), value: "?_PLAYING", asset: 'btBool' }, 
                    { text: Global.ln.get('window-globals-server'), value: "?_SERVER", asset: 'btBool' }, 
                    { text: Global.ln.get('window-globals-userlogged'), value: "?_USERLOGGED", asset: 'btBool' }, 
                    { text: Global.ln.get('window-globals-hadinteraction'), value: "?_HADINTERACTION", asset: 'btBool' }, 
                    { text: Global.ln.get('window-globals-keyframe'), value: "#_KEYFRAME", asset: 'btFloat' }, 
                    { text: Global.ln.get('window-globals-areabig'), value: "#_AREABIG", asset: 'btFloat' }, 
                    { text: Global.ln.get('window-globals-areasmall'), value: "#_AREASMALL", asset: 'btFloat' }, 
                    { text: Global.ln.get('window-globals-contentx'), value: "#_CONTENTX", asset: 'btFloat' }, 
                    { text: Global.ln.get('window-globals-contenty'), value: "#_CONTENTY", asset: 'btFloat' }, 
                    { text: Global.ln.get('window-globals-contentwidth'), value: "#_CONTENTWIDTH", asset: 'btFloat' }, 
                    { text: Global.ln.get('window-globals-contentheight'), value: "#_CONTENTHEIGHT", asset: 'btFloat' }, 
                    { text: Global.ln.get('window-globals-movietitle'), value: "$_MOVIETITLE", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-movieid'), value: "$_MOVIEID", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-scenetitle'), value: "$_SCENETITLE", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-sceneid'), value: "$_SCENEID", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-orientation'), value: "$_ORIENTATION", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-urlmovie'), value: "$_URLMOVIE", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-urlscene'), value: "$_URLSCENE", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-username'), value: "$_USERNAME", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-runtime'), value: "$_RUNTIME", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-wsserver'), value: "$_WSSERVER", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-version'), value: "$_VERSION", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-session'), value: "$_SESSION", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-date'), value: "$_DATE", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-time'), value: "$_TIME", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-year'), value: "$_YEAR", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-month'), value: "$_MONTH", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-day'), value: "$_DAY", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-hour'), value: "$_HOUR", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-minute'), value: "$_MINUTE", asset: 'btString' }, 
                    { text: Global.ln.get('window-globals-second'), value: "$_SECOND", asset: 'btString' }, 
                ], sl: [ ], ht: 184 }, 
                { tp: "Custom", cont: this._idbuttons['ggeneral'] }, 
                { tp: "Label", id: 'ginstance', tx: Global.ln.get('window-globals-instance'), vr: '' }, 
                { tp: "Label", id: 'ginstancep', tx: Global.ln.get('window-globals-instancep'), vr: Label.VARIANT_DETAIL }, 
                { tp: "Select", id: 'ginstancep', vl: [
                    { text: Global.ln.get('window-globals-instplaying'), value: "?_INSTANCEPLAYING:" }, 
                    { text: Global.ln.get('window-globals-instvisible'), value: "?_INSTANCEVISIBLE:" }, 
                    { text: Global.ln.get('window-globals-instfontbold'), value: "?_INSTANCEFONTBOLD:" }, 
                    { text: Global.ln.get('window-globals-instfontitalic'), value: "?_INSTANCEFONTITALIC:" }, 
                    { text: Global.ln.get('window-acinstance-px'), value: "#_INSTANCEX:" }, 
                    { text: Global.ln.get('window-acinstance-py'), value: "#_INSTANCEY:" }, 
                    { text: Global.ln.get('window-acinstance-pwidth'), value: "#_INSTANCEWIDTH:" }, 
                    { text: Global.ln.get('window-acinstance-pheight'), value: "#_INSTANCEHEIGHT:" }, 
                    { text: Global.ln.get('window-acinstance-palpha'), value: "#_INSTANCEALPHA:" }, 
                    { text: Global.ln.get('window-acinstance-pvolume'), value: "#_INSTANCEVOLUME:" }, 
                    { text: Global.ln.get('window-acinstance-porder'), value: "#_INSTANCEORDER:" }, 
                    { text: Global.ln.get('window-acinstance-pcoloralpha'), value: "#_INSTANCECOLORALPHA:" }, 
                    //{ text: Global.ln.get('window-acinstance-protation'), value: "#_INSTANCEROTATION:" }, 
                    { text: Global.ln.get('window-acinstance-pfontsize'), value: "#_INSTANCEFONTSIZE:" }, 
                    { text: Global.ln.get('window-acinstance-pfontleading'), value: "#_INSTANCEFONTLEADING:" }, 
                    { text: Global.ln.get('window-acinstance-pcolor'), value: "$_INSTANCECOLOR:" }, 
                    { text: Global.ln.get('window-globals-insttext'), value: "$_INSTANCETEXT:" }, 
                    { text: Global.ln.get('window-acinstance-pfont'), value: "$_INSTANCEFONT:" }, 
                    { text: Global.ln.get('window-acinstance-pfontcolor'), value: "$_INSTANCEFONTCOLOR:" }, 
                ], sl: [ ] }, 
                { tp: "Label", id: 'ginstancen', tx: Global.ln.get('window-globals-instancen'), vr: Label.VARIANT_DETAIL }, 
                { tp: "Select", id: 'ginstancen', vl: [ ], sl: [ ] }, 
                { tp: "Custom", cont: this._idbuttons['ginstance'] }, 
                { tp: "Label", id: 'gmovie', tx: Global.ln.get('window-globals-movie'), vr: '' }, 
                { tp: "Select", id: 'gmovie', vl: [
                    { text: Global.ln.get('window-globals-text'), value: "$_TEXTS:" }, 
                    { text: Global.ln.get('window-globals-number'), value: "#_NUMBERS:" }, 
                    { text: Global.ln.get('window-globals-flag'), value: "?_FLAGS:" }, 
                    { text: Global.ln.get('window-acinput-text'), value: "$_INPUT:" }, 
                    { text: Global.ln.get('window-acform-text'), value: "$_FORM:" }, 
                    { text: Global.ln.get('window-acnumeric-text'), value: "#_NUMERIC:" }, 
                    { text: Global.ln.get('window-actoggle-text'), value: "?_TOGGLE:" }, 
                ], sl: [ ], ht: 95 }, 
                { tp: "Label", id: 'gname', tx: Global.ln.get('window-globals-name'), vr: '' }, 
                { tp: "TInput", id: 'gname', tx: '', vr: '' }, 
                { tp: "Custom", cont: this._idbuttons['gmovie'] }, 
            ]), this.ui.forge('bottom', [
                { tp: "Label", id: 'showAction', tx: Global.ln.get('window-globals-showaction'), vr: Label.VARIANT_DETAIL }, 
                { tp: "TInput", id: 'showAction', tx: '' }, 
            ]), 565
        ));
        this.ui.listDbClick('list', onCopy);
        this.ui.setListToIcon('list');
        this.ui.setListToIcon('ggeneral');
    }

    /**
        Sets the window actions list.
    **/
    public function setActions(ac:Map<String, VarAction>):Void {
        this._actions = ac;
        var list:Array<Dynamic> = [ ];
        for (k in this._actions.keys()) {
            list.push({ text: k, value: k, asset: this._actions[k].ic });
        }
        this.ui.setListValues('list', list);
    }

    /**
        Window statup actions.
    **/
    override function acStart() {
        super.acStart();
        this.ui.setListSelectValue('list', null);
        this.ui.inputs['p1'].text = '';
        this.ui.inputs['p2'].text = '';
        this.ui.inputs['p3'].text = '';
        this.ui.inputs['p4'].text = '';
        this.ui.inputs['p5'].text = '';
        this.ui.inputs['p6'].text = '';
        this.ui.inputs['p7'].text = '';
        this.ui.inputs['showAction'].text = '';
        var list:Array<Dynamic> = [ ];
        for (k in GlobalPlayer.area.getInstances()) list.push({ text: k, value: k });
        this.ui.setSelectOptions('ginstancen', list);
    }

    /**
        Interface initialize
    **/
    override function startInterface(evt:Event = null) {
        super.startInterface(evt);
        for (k in this._idbuttons.keys()) this._idbuttons[k].width = this.ui.buttons['close'].width;
    }

    /**
        Copies the selected action.
    **/
    private function onCopy(evt:TriggerEvent = null):Void {
        if (this.ui.lists['list'].selectedItem != null) {
            var k:String = this.ui.lists['list'].selectedItem.value;
            if (this._actions.exists(k)) {
                var ac:String = '{ "ac": "' + k + '", ';
                if (this._actions[k].p.length == 0) {
                    ac += '"param": [ ] ';
                } else if (this._actions[k].p.length == 1) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '" ]';
                } else if (this._actions[k].p.length == 2) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '" ]';
                } else if (this._actions[k].p.length == 3) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '", "' + this.ui.inputs['p3'].text + '" ]';
                } else if (this._actions[k].p.length == 4) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '", "' + this.ui.inputs['p3'].text + '", "' + this.ui.inputs['p4'].text + '" ]';
                } else if (this._actions[k].p.length == 5) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '", "' + this.ui.inputs['p3'].text + '", "' + this.ui.inputs['p4'].text + '", "' + this.ui.inputs['p5'].text + '" ]';
                } else if (this._actions[k].p.length == 6) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '", "' + this.ui.inputs['p3'].text + '", "' + this.ui.inputs['p4'].text + '", "' + this.ui.inputs['p5'].text + '", "' + this.ui.inputs['p6'].text + '" ]';
                } else {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '", "' + this.ui.inputs['p3'].text + '", "' + this.ui.inputs['p4'].text + '", "' + this.ui.inputs['p5'].text + '", "' + this.ui.inputs['p6'].text + '", "' + this.ui.inputs['p7'].text + '" ]';
                }
                if (this._actions[k].c) {
                    ac += ', "then": [ ], "else": [ ]';
                }
                if (this._actions[k].t) {
                    ac += ', "tick": [ ], "end": [ ]';
                }
                if (this._actions[k].i) {
                    ac += ', "ok": [ ], "cancel": [ ]';
                }
                if (this._actions[k].d) {
                    ac += ', "success": [ ], "error": [ ]';
                }
                if (this._actions[k].s) {
                    ac += ', "select": [ ]';
                }
                ac += ' }';
                Global.copyText(ac);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Shows the selected action.
    **/
    private function onShow(evt:TriggerEvent = null):Void {
        if (this.ui.lists['list'].selectedItem != null) {
            var k:String = this.ui.lists['list'].selectedItem.value;
            if (this._actions.exists(k)) {
                var ac:String = '{ "ac": "' + k + '", ';
                if (this._actions[k].p.length == 0) {
                    ac += '"param": [ ] ';
                } else if (this._actions[k].p.length == 1) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '" ]';
                } else if (this._actions[k].p.length == 2) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '" ]';
                } else if (this._actions[k].p.length == 3) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '", "' + this.ui.inputs['p3'].text + '" ]';
                } else if (this._actions[k].p.length == 4) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '", "' + this.ui.inputs['p3'].text + '", "' + this.ui.inputs['p4'].text + '" ]';
                } else if (this._actions[k].p.length == 5) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '", "' + this.ui.inputs['p3'].text + '", "' + this.ui.inputs['p4'].text + '", "' + this.ui.inputs['p5'].text + '" ]';
                } else if (this._actions[k].p.length == 6) {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '", "' + this.ui.inputs['p3'].text + '", "' + this.ui.inputs['p4'].text + '", "' + this.ui.inputs['p5'].text + '", "' + this.ui.inputs['p6'].text + '" ]';
                } else {
                    ac += '"param": [ "' + this.ui.inputs['p1'].text + '", "' + this.ui.inputs['p2'].text + '", "' + this.ui.inputs['p3'].text + '", "' + this.ui.inputs['p4'].text + '", "' + this.ui.inputs['p5'].text + '", "' + this.ui.inputs['p6'].text + '", "' + this.ui.inputs['p7'].text + '" ]';
                }
                if (this._actions[k].c) {
                    ac += ', "then": [ ], "else": [ ]';
                }
                if (this._actions[k].t) {
                    ac += ', "tick": [ ], "end": [ ]';
                }
                if (this._actions[k].i) {
                    ac += ', "ok": [ ], "cancel": [ ]';
                }
                if (this._actions[k].d) {
                    ac += ', "success": [ ], "error": [ ]';
                }
                if (this._actions[k].s) {
                    ac += ', "select": [ ]';
                }
                ac += ' }';
                this.ui.inputs['showAction'].text = ac;
            }
        }
    }

    /**
        General globals.
    **/
    private function onGeneral(evt:TriggerEvent = null):Void {
        if (this.ui.lists['ggeneral'].selectedItem != null) {
            this.ui.inputs['showAction'].text = this.ui.lists['ggeneral'].selectedItem.value;
            Global.copyText(this.ui.lists['ggeneral'].selectedItem.value);
        }
    }

    /**
        Instance globals.
    **/
    private function onInstance(evt:TriggerEvent = null):Void {
        if (this.ui.selects['ginstancep'].selectedItem != null) {
            if (this.ui.selects['ginstancen'].selectedItem != null) {
                Global.copyText(this.ui.selects['ginstancep'].selectedItem.value + this.ui.selects['ginstancen'].selectedItem.value);
                this.ui.inputs['showAction'].text = this.ui.selects['ginstancep'].selectedItem.value + this.ui.selects['ginstancen'].selectedItem.value;
            }
        }
    }

    /**
        Movie globals.
    **/
    private function onMovie(evt:TriggerEvent = null):Void {
        if (this.ui.selects['gmovie'].selectedItem != null) {
            if (this.ui.inputs['gname'].text != '') {
                Global.copyText(this.ui.selects['gmovie'].selectedItem.value + this.ui.inputs['gname'].text);
                this.ui.inputs['showAction'].text = this.ui.selects['gmovie'].selectedItem.value + this.ui.inputs['gname'].text;
            }
        }
    }

    /**
        Closes window.
    **/
    private function onClose(evt:TriggerEvent = null):Void {
        PopUpManager.removePopUp(this);
    }
}

typedef VarAction = {
    var p:Array<String>;
    var c:Bool;
    var t:Bool;
    var i:Bool;
    var d:Bool;
    var s:Bool;
    var ic:String;
}