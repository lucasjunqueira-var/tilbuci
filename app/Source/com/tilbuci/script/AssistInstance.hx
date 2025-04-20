/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.script;

/** OPENFL **/
import openfl.events.Event;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;
import feathers.controls.Label;

/** TILBUCI **/
import com.tilbuci.ui.component.IDButton;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.DataLoader;
import com.tilbuci.data.GlobalPlayer;

class AssistInstance extends PopupWindow {

    /**
        action buttons
    **/
    private var _idbuttons:Map<String, IDButton> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-acinstance-title'), 800, 640, false);
        this._idbuttons['create'] = new IDButton('create', onCopy, Global.ln.get('window-acinstance-create'), Assets.getBitmapData('btCopy'));
        this._idbuttons['btShow'] = new IDButton('btShow', onShow, Global.ln.get('window-acvariable-show'));
        this._idbuttons['cpasset'] = new IDButton('cpasset', onAsset, Global.ln.get('window-acinstance-cpasset'), Assets.getBitmapData('btCopy'));
        this._idbuttons['ggeneral'] = new IDButton('ggeneral', onGeneral, Global.ln.get('window-globals-get'), Assets.getBitmapData('btCopy'));
        this._idbuttons['ginstance'] = new IDButton('instance', onInstance, Global.ln.get('window-globals-get'), Assets.getBitmapData('btCopy'));
        this._idbuttons['gmovie'] = new IDButton('movie', onMovie, Global.ln.get('window-globals-get'), Assets.getBitmapData('btCopy'));
        this.addForm(Global.ln.get('window-acinstance-title'), this.ui.createColumnHolder('form', 
            this.ui.forge('left', [
                { tp: "Label", id: 'list', tx: Global.ln.get('window-acinstance-current'), vr: '' }, 
                { tp: "List", id: 'list', vl: [ ], sl: [ ], ht: 108 }, 
                { tp: "Label", id: 'actions', tx: Global.ln.get('window-acinstance-action'), vr: '' }, 
                { tp: 'Select', id: 'actions', vl: [
                    { text: Global.ln.get('window-acinstance-set'), value: 'set' }, 
                    { text: Global.ln.get('window-acinstance-clear'), value: 'clear' }, 
                    { text: Global.ln.get('window-acinstance-clearall'), value: 'clearall' }, 
                    { text: Global.ln.get('window-acinstance-play'), value: 'play' }, 
                    { text: Global.ln.get('window-acinstance-pause'), value: 'pause' }, 
                    { text: Global.ln.get('window-acinstance-stop'), value: 'stop' }, 
                    { text: Global.ln.get('window-acinstance-next'), value: 'next' }, 
                    { text: Global.ln.get('window-acinstance-previous'), value: 'previous' }, 
                    { text: Global.ln.get('window-acinstance-seek'), value: 'seek' }, 
                    { text: Global.ln.get('window-acinstance-zoom'), value: 'zoom' }, 
                    { text: Global.ln.get('window-acinstance-scrollbottom'), value: 'scrollbottom' }, 
                    { text: Global.ln.get('window-acinstance-scrolltop'), value: 'scrolltop' }, 
                    { text: Global.ln.get('window-acinstance-scrolldown'), value: 'scrolldown' }, 
                    { text: Global.ln.get('window-acinstance-scrollup'), value: 'scrollup' }, 
                    { text: Global.ln.get('window-acinstance-loasasset'), value: 'loadasset' }, 
                ], sl: null }, 
                { tp: "Label", id: 'property', tx: Global.ln.get('window-acinstance-property'), vr: '' }, 
                { tp: 'Select', id: 'property', vl: [
                    { text: Global.ln.get('window-acinstance-px'), value: 'x' }, 
                    { text: Global.ln.get('window-acinstance-py'), value: 'y' }, 
                    { text: Global.ln.get('window-acinstance-pwidth'), value: 'width' }, 
                    { text: Global.ln.get('window-acinstance-pheight'), value: 'height' }, 
                    { text: Global.ln.get('window-acinstance-palpha'), value: 'alpha' }, 
                    { text: Global.ln.get('window-acinstance-porder'), value: 'order' }, 
                    { text: Global.ln.get('window-acinstance-pvisible'), value: 'visible' }, 
                    { text: Global.ln.get('window-acinstance-pcolor'), value: 'color' }, 
                    { text: Global.ln.get('window-acinstance-pcoloralpha'), value: 'coloralpha' }, 
                    { text: Global.ln.get('window-acinstance-pfont'), value: 'font' }, 
                    { text: Global.ln.get('window-acinstance-pfontsize'), value: 'fontsize' }, 
                    { text: Global.ln.get('window-acinstance-pfontalign'), value: 'fontalign' }, 
                    { text: Global.ln.get('window-acinstance-pfontbackground'), value: 'fontbackground' }, 
                    { text: Global.ln.get('window-acinstance-pfontcolor'), value: 'fontcolor' }, 
                    { text: Global.ln.get('window-acinstance-pfontbold'), value: 'fontbold' }, 
                    { text: Global.ln.get('window-acinstance-pfontitalic'), value: 'fontitalic' }, 
                    { text: Global.ln.get('window-acinstance-pfontleading'), value: 'fontleading' }, 
                    { text: Global.ln.get('window-acinstance-pparagraph'), value: 'paragraph' }, 
                    { text: Global.ln.get('window-acinstance-pvolume'), value: 'volume' }, 
                    { text: Global.ln.get('window-acinstance-protation'), value: 'rotation' }, 

                ], sl: null }, 
                { tp: "Label", id: 'horizontal', tx: Global.ln.get('window-acinstance-horizontal'), vr: '' }, 
                { tp: 'TInput', id: 'horizontal', vl: '', vr: '' }, 
                { tp: "Label", id: 'vertical', tx: Global.ln.get('window-acinstance-vertical'), vr: '' }, 
                { tp: 'TInput', id: 'vertical', vl: '', vr: '' }, 
                { tp: "Label", id: 'other', tx: Global.ln.get('window-acinstance-other'), vr: '' }, 
                { tp: 'TInput', id: 'other', vl: '', vr: '' }, 
                { tp: "Custom", cont: this._idbuttons['create'] }, 
                { tp: "Custom", cont: this._idbuttons['btShow'] }, 
                { tp: "Button", id: "close", tx: Global.ln.get('window-actions-close'), ac: onClose }, 
                { tp: 'Spacer', id: 'showAction', ht: 5, ln: false }, 
                { tp: "Label", id: 'showAction', tx: Global.ln.get('window-globals-showaction'), vr: Label.VARIANT_DETAIL }, 
                { tp: "TInput", id: 'showAction', tx: '' }, 
            ]), 
            this.ui.forge('right', [
                { tp: "Label", id: 'collections', tx: Global.ln.get('window-acinstance-collections'), vr: '' }, 
                { tp: "Select", id: 'collections', vl: [ ], sl: [ ], ch: onCollection }, 
                { tp: "Label", id: 'assets', tx: Global.ln.get('window-acinstance-assets'), vr: '' }, 
                { tp: "Select", id: 'assets', vl: [ ], sl: [ ] }, 
                { tp: "Custom", cont: this._idbuttons['cpasset'] }, 
                { tp: 'Spacer', id: 'cpasset', ht: 38, ln: true }, 

                { tp: "Label", id: 'ggeneral', tx: Global.ln.get('window-globals-general'), vr: '' }, 
                { tp: "Select", id: 'ggeneral', vl: [
                    { text: Global.ln.get('window-globals-playing'), value: "?_PLAYING", asset: 'btBool' }, 
                    { text: Global.ln.get('window-globals-userlogged'), value: "?_USERLOGGED", asset: 'btBool' }, 
                    { text: Global.ln.get('window-globals-hadinteraction'), value: "?_HADINTERACTION", asset: 'btBool' }, 
                    { text: Global.ln.get('window-globals-server'), value: "?_SERVER", asset: 'btBool' }, 
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
                ], sl: [ ] }, 
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
                    { text: Global.ln.get('window-acinstance-protation'), value: "#_INSTANCEROTATION:" }, 
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
            ])
        ));
    }

    /**
        Window startup actions.
    **/
    override function acStart() {
        super.acStart();
        var list:Array<Dynamic> = [ ];
        for (k in GlobalPlayer.area.getInstances()) list.push({ text: k, value: k });
        this.ui.setListValues('list', list);
        this.ui.setSelectOptions('ginstancen', list);
        var collist:Array<Dynamic> = [ ];
        for (k in GlobalPlayer.movie.collections.keys()) {
            collist.push({ text: GlobalPlayer.movie.collections[k].name, value: k });
        }
        this.ui.setSelectOptions('collections', collist);
        this.onCollection();
    }

    /**
        Interface initialize
    **/
    override function startInterface(evt:Event = null) {
        super.startInterface(evt);
        for (k in this._idbuttons.keys()) this._idbuttons[k].width = this.ui.buttons['close'].width;
    }

    /**
        Copies an instance action.
    **/
    private function onCopy(evt:TriggerEvent = null):Void {
        if (this.ui.lists['list'].selectedItem != null) {
            switch (this.ui.selects['actions'].selectedItem.value) {
                case 'set':
                    if (this.ui.selects['property'].selectedItem.value == 'paragraph') {
                        Global.copyText('{ "ac": "instance.setparagraph", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '", "' + this.ui.inputs['other'].text + '" ] }');
                        PopUpManager.removePopUp(this);
                    } else {
                        Global.copyText('{ "ac": "instance.set' + this.ui.selects['property'].selectedItem.value + '", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '", "' + this.ui.inputs['horizontal'].text + '", "' + this.ui.inputs['vertical'].text + '" ] }');
                        PopUpManager.removePopUp(this);
                    }
                case 'clear':
                    if (this.ui.selects['property'].selectedItem.value == 'paragraph') {
                        // nothing to do
                    } else {
                        Global.copyText('{ "ac": "instance.clear' + this.ui.selects['property'].selectedItem.value + '", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '" ] }');
                        PopUpManager.removePopUp(this);
                    }
                case 'seek':
                    Global.copyText('{ "ac": "instance.' + this.ui.selects['actions'].selectedItem.value  + '", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '", "' + this.ui.inputs['other'].text + '" ] }');
                    PopUpManager.removePopUp(this);
                case 'loadasset':
                    Global.copyText('{ "ac": "instance.' + this.ui.selects['actions'].selectedItem.value  + '", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '", "' + this.ui.inputs['other'].text + '" ] }');
                    PopUpManager.removePopUp(this);
                default:
                    Global.copyText('{ "ac": "instance.' + this.ui.selects['actions'].selectedItem.value  + '", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '" ] }');
                    PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Shows an instance action.
    **/
    private function onShow(evt:TriggerEvent = null):Void {
        if (this.ui.lists['list'].selectedItem != null) {
            switch (this.ui.selects['actions'].selectedItem.value) {
                case 'set':
                    if (this.ui.selects['property'].selectedItem.value == 'paragraph') {
                        this.ui.inputs['showAction'].text = '{ "ac": "instance.setparagraph", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '", "' + this.ui.inputs['other'].text + '" ] }';
                    } else {
                        this.ui.inputs['showAction'].text = '{ "ac": "instance.set' + this.ui.selects['property'].selectedItem.value + '", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '", "' + this.ui.inputs['horizontal'].text + '", "' + this.ui.inputs['vertical'].text + '" ] }';
                    }
                case 'clear':
                    if (this.ui.selects['property'].selectedItem.value == 'paragraph') {
                        // nothing to do
                    } else {
                        this.ui.inputs['showAction'].text = '{ "ac": "instance.clear' + this.ui.selects['property'].selectedItem.value + '", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '" ] }';
                    }
                case 'seek':
                    this.ui.inputs['showAction'].text = '{ "ac": "instance.' + this.ui.selects['actions'].selectedItem.value  + '", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '", "' + this.ui.inputs['other'].text + '" ] }';
                case 'loadasset':
                    this.ui.inputs['showAction'].text = '{ "ac": "instance.' + this.ui.selects['actions'].selectedItem.value  + '", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '", "' + this.ui.inputs['other'].text + '" ] }';
                default:
                    this.ui.inputs['showAction'].text = '{ "ac": "instance.' + this.ui.selects['actions'].selectedItem.value  + '", "param": [ "' +  this.ui.lists['list'].selectedItem.value + '" ] }';
            }
        }
    }

    /**
        A new collection was selected on list.
    **/
    private function onCollection(evt:Event = null):Void {
        if (this.ui.selects['collections'].selectedItem != null) {
            var list:Array<Dynamic> = [ ];
            for (k in GlobalPlayer.movie.collections[this.ui.selects['collections'].selectedItem.value].assets.keys()) {
                list.push({ text: GlobalPlayer.movie.collections[this.ui.selects['collections'].selectedItem.value].assets[k].name, value: k });
            }
            this.ui.setSelectOptions('assets', list);
            this.ui.setSelectValue('assets', null);
        }
    }

    /**
        Copies an asset id.
    **/
    private function onAsset(evt:TriggerEvent = null):Void {
        if (this.ui.selects['assets'].selectedItem != null) {
            this.ui.inputs['showAction'].text = this.ui.selects['assets'].selectedItem.value;
            Global.copyText(this.ui.selects['assets'].selectedItem.value);
        }
    }

    /**
        General globals.
    **/
    private function onGeneral(evt:TriggerEvent = null):Void {
        if (this.ui.selects['ggeneral'].selectedItem != null) {
            this.ui.inputs['showAction'].text = this.ui.selects['ggeneral'].selectedItem.value;
            Global.copyText(this.ui.selects['ggeneral'].selectedItem.value);
        }
    }

    /**
        Instance globals.
    **/
    private function onInstance(evt:TriggerEvent = null):Void {
        if (this.ui.selects['ginstancep'].selectedItem != null) {
            if (this.ui.selects['ginstancen'].selectedItem != null) {
                this.ui.inputs['showAction'].text = this.ui.selects['ginstancep'].selectedItem.value + this.ui.selects['ginstancen'].selectedItem.value;
                Global.copyText(this.ui.selects['ginstancep'].selectedItem.value + this.ui.selects['ginstancen'].selectedItem.value);
            }
        }
    }

    /**
        Movie globals.
    **/
    private function onMovie(evt:TriggerEvent = null):Void {
        if (this.ui.selects['gmovie'].selectedItem != null) {
            if (this.ui.inputs['gname'].text != '') {
                this.ui.inputs['showAction'].text = this.ui.selects['gmovie'].selectedItem.value + this.ui.inputs['gname'].text;
                Global.copyText(this.ui.selects['gmovie'].selectedItem.value + this.ui.inputs['gname'].text);
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