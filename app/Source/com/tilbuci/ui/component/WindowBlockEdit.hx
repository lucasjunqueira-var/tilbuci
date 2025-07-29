/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.ui.component.BlockArea.BlockAction;
import com.tilbuci.script.ActionInfo.ActionInfoAc;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.GlobalPlayer;
import openfl.events.Event;
import openfl.display.Stage;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;
import feathers.controls.navigators.TabItem;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.ui.component.ActionArea;
import com.tilbuci.ui.base.HInterfaceContainer;
import com.tilbuci.ui.component.IDButton;

class WindowBlockEdit extends PopupWindow {

    private var _blindex:Int = -1;

    private var _onOk:Dynamic;

    private var _acinfo:ActionInfoAc;

    private var _blac:BlockAction;

    private var _mvOrigins:Array<Dynamic> = [ ];

    private var _scDirections:Array<Dynamic> = [ ];

    private var _mnPlacement:Array<Dynamic> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic = null) {
        // creating window
        super(ac, '', 1100, InterfaceFactory.pickValue(570, 580), false, true);

        // select data
        this._mvOrigins = [
            { text: Global.ln.get('window-movieprop-oralpha'), value: 'alpha'}, 
            { text: Global.ln.get('window-movieprop-orcenter'), value: 'center'}, 
            { text: Global.ln.get('window-movieprop-ortop'), value: 'top'}, 
            { text: Global.ln.get('window-movieprop-ortopkeep'), value: 'topkeep'}, 
            { text: Global.ln.get('window-movieprop-orbottom'), value: 'bottom'}, 
            { text: Global.ln.get('window-movieprop-orbottomkeep'), value: 'bottomkeep'}, 
            { text: Global.ln.get('window-movieprop-orleft'), value: 'left'}, 
            { text: Global.ln.get('window-movieprop-orleftkeep'), value: 'leftkeep'}, 
            { text: Global.ln.get('window-movieprop-orright'), value: 'right'}, 
            { text: Global.ln.get('window-movieprop-orrightkeep'), value: 'rightkeep'}, 
        ];
        this._scDirections = [
            { text: Global.ln.get('window-movieprop-input-opup'), value: 'up'}, 
            { text: Global.ln.get('window-movieprop-input-opdown'), value: 'down'}, 
            { text: Global.ln.get('window-movieprop-input-opleft'), value: 'left'}, 
            { text: Global.ln.get('window-movieprop-input-opright'), value: 'right'}, 
            { text: Global.ln.get('window-movieprop-input-opnin'), value: 'nin'}, 
            { text: Global.ln.get('window-movieprop-input-opnout'), value: 'nout'}, 
        ];
        this._mnPlacement = [
            { text: Global.ln.get('placement-center'), value: 'center'},
            { text: Global.ln.get('placement-centerleft'), value: 'centerleft'},
            { text: Global.ln.get('placement-centerright'), value: 'centerright'},
            { text: Global.ln.get('placement-top'), value: 'top'},
            { text: Global.ln.get('placement-topleft'), value: 'topleft'},
            { text: Global.ln.get('placement-topright'), value: 'topright'},
            { text: Global.ln.get('placement-bottom'), value: 'bottom'},
            { text: Global.ln.get('placement-bottomleft'), value: 'bottomleft'},
            { text: Global.ln.get('placement-bottomright'), value: 'bottomright'},
            { text: Global.ln.get('placement-absolute'), value: 'absolute'},
        ];

        // custom elements
        this.ui.createHContainer('assets');
        this.ui.createSelect('assets', [ ], null, this.ui.hcontainers['assets'], false);
        this.ui.hcontainers['assets'].addChild(new IDButton('cpasset', onAsset, Global.ln.get('window-acinstance-cpasset'), Assets.getBitmapData('btCopy'), false));
        this.ui.createHContainer('ggeneral');
        this.ui.createSelect('ggeneral', [
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
        ], null, this.ui.hcontainers['ggeneral'], false);
        this.ui.hcontainers['ggeneral'].addChild(new IDButton('ggeneral', onGeneral, Global.ln.get('window-globals-get'), Assets.getBitmapData('btCopy'), false));
        this.ui.createHContainer('ginstancep');
        this.ui.createSelect('ginstancep', [
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
        ], null, this.ui.hcontainers['ginstancep'], false);
        this.ui.hcontainers['ginstancep'].addChild(new IDButton('instance', onInstance, Global.ln.get('window-globals-get'), Assets.getBitmapData('btCopy'), false));
        this.ui.createHContainer('gname');
        this.ui.createTInput('gname', '', '', this.ui.hcontainers['gname'], false);
        this.ui.hcontainers['gname'].addChild(new IDButton('movie', onMovie, Global.ln.get('window-globals-get'), Assets.getBitmapData('btCopy'), false));

        // parameters tab
        this.addForm(Global.ln.get('acblock-parameters'), this.ui.createColumnHolder('available',
            this.ui.forge('paramleft', [
                
            ]), 
            this.ui.forge('paramright', [
                { tp: "Label", id: 'collections', tx: Global.ln.get('window-acinstance-collections'), vr: '' }, 
                { tp: "Select", id: 'collections', vl: [ ], sl: [ ], ch: onCollection }, 
                { tp: "Label", id: 'assets', tx: Global.ln.get('window-acinstance-assets'), vr: Label.VARIANT_DETAIL }, 
                { tp: "Custom", cont: this.ui.hcontainers['assets'] }, 

                { tp: 'Spacer', id: 'assets', ht: 4, ln: false}, 

                { tp: "Label", id: 'ggeneral', tx: Global.ln.get('window-globals-general'), vr: '' }, 
                { tp: "Custom", cont: this.ui.hcontainers['ggeneral'] }, 

                { tp: 'Spacer', id: 'ggeneral', ht: 4, ln: false}, 

                { tp: "Label", id: 'ginstance', tx: Global.ln.get('window-globals-instance'), vr: '' }, 
                { tp: "Select", id: 'ginstancen', vl: [ ], sl: [ ] }, 
                { tp: "Custom", cont: this.ui.hcontainers['ginstancep'] }, 

                { tp: 'Spacer', id: 'gmovie', ht: 4, ln: false}, 

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
                { tp: "Label", id: 'gname', tx: Global.ln.get('window-globals-name'), vr: Label.VARIANT_DETAIL }, 
                { tp: "Custom", cont: this.ui.hcontainers['gname'] }, 
                { tp: 'Spacer', id: 'showAction', ht: 5, ln: false}, 
                { tp: "Label", id: 'showAction', tx: Global.ln.get('acblock-valcopy'), vr: '' }, 
                { tp: "TInput", id: 'showAction', tx: '' }, 
            ]),
            this.ui.forge('parambottom', [
                { tp: 'Button', id: 'blbutton', tx: Global.ln.get('acblock-button'), ac: onClick }
            ]),
            460
        ));
        this.ui.containers['parambottom'].width = 1100;
        this.ui.hcontainers['assets'].setWidth(510);
        this.ui.hcontainers['ggeneral'].setWidth(510);
        this.ui.hcontainers['ginstancep'].setWidth(510);
        this.ui.hcontainers['gname'].setWidth(510);

        // create input parameters
        for (i in 0...8) {
            this.ui.createLabel(('param-' + i), ('#' + (i+1)), Label.VARIANT_DETAIL);
            this.ui.createTInput('param-' + i);
            this.ui.createSelect(('param-' + i), [ ]);
            this.ui.labels['param-' + i].width = this.ui.inputs['param-' + i].width = this.ui.selects['param-' + i].width = 510;
        }
    }

    /**
        Window action to run on display (meant to override).
    **/
    override public function acStart():Void {
        this._head.text = this._acinfo.n;

        var collist:Array<Dynamic> = [ ];
        for (k in GlobalPlayer.movie.collections.keys()) {
            collist.push({ text: GlobalPlayer.movie.collections[k].name, value: k });
        }
        this.ui.setSelectOptions('collections', collist);
        this.onCollection();

        var instlist:Array<Dynamic> = [ ];
        for (k in GlobalPlayer.area.getInstances()) instlist.push({ text: k, value: k });
        this.ui.setListValues('list', instlist);
        this.ui.setSelectOptions('ginstancen', instlist);

        this.ui.containers['paramleft'].removeChildren();
        for (i in 0...8) {
            if (this._acinfo.p.length > i) {
                this.ui.labels['param-'+i].text = this._acinfo.p[i].n;
                this.ui.containers['paramleft'].addChild(this.ui.labels['param-'+i]);
                switch (this._acinfo.p[i].v) {
                    case 'movies':
                        this.ui.setSelectOptions(('param-'+i), Global.acInfo.selMovies);
                        this.ui.containers['paramleft'].addChild(this.ui.selects['param-'+i]);
                    case 'scenes':
                        this.ui.setSelectOptions(('param-'+i), Global.acInfo.selScenes);
                        this.ui.containers['paramleft'].addChild(this.ui.selects['param-'+i]);
                    case 'instances':
                        this.ui.setSelectOptions(('param-'+i), instlist);
                        this.ui.containers['paramleft'].addChild(this.ui.selects['param-'+i]);
                    case 'origins':
                        this.ui.setSelectOptions(('param-'+i), this._mvOrigins);
                        this.ui.containers['paramleft'].addChild(this.ui.selects['param-'+i]);
                    case 'navigation':
                        this.ui.setSelectOptions(('param-'+i), this._scDirections);
                        this.ui.containers['paramleft'].addChild(this.ui.selects['param-'+i]);
                    case 'placement':
                        this.ui.setSelectOptions(('param-'+i), this._mnPlacement);
                        this.ui.containers['paramleft'].addChild(this.ui.selects['param-'+i]);
                    default:
                        this.ui.inputs['param-'+i].text = '';
                        this.ui.containers['paramleft'].addChild(this.ui.inputs['param-'+i]);
                }
                if (this._blac != null) {
                    if (this._blac.param.length > i) {
                        if (this._acinfo.p[i].v == '') {
                            this.ui.inputs['param-'+i].text = this._blac.param[i];
                        } else {
                            this.ui.setSelectValue(('param-'+i), this._blac.param[i]);
                        }
                    }
                }
            } else {
                this.ui.labels['param-'+i].text = '#' + (i + 1);
                this.ui.containers['paramleft'].addChild(this.ui.labels['param-'+i]);
                this.ui.inputs['param-'+i].text = '';
                this.ui.containers['paramleft'].addChild(this.ui.inputs['param-'+i]);
                if (this._blac != null) {
                    if (this._blac.param.length > i) {
                        this.ui.inputs['param-'+i].text = this._blac.param[i];
                    }
                }
            }
        }
    }

    /**
        Sets current content.
        @param  onOk    action to call on ok button click
    **/
    public function setContent(ac:String, onOk:Dynamic, index:Int, current:BlockAction = null):Void {
        this._onOk = onOk;
        this._blindex = index;
        this._blac = current;
        this._acinfo = new ActionInfoAc({ n: ac, a: ac, p: [ ], e: [ ] });
        for (gr in Global.acInfo.groups) {
            if (gr.actions.exists(ac)) this._acinfo = gr.actions[ac];
        }
        this.acStart();
    }

    private function onClick(evt:Event):Void {
        var ok = true;
        var param:Array<String> = [ ];
        for (i in 0...8) {
            if (ok) {
                var vali:String = '';
                if (this._acinfo.p.length > i) {
                    if (this._acinfo.p[i].v == '') {
                        vali = this.ui.inputs['param-'+i].text;
                    } else {
                        vali = this.ui.selects['param-'+i].selectedItem.value;
                    }
                    if ((vali == '') && (this._acinfo.p[i].t != 'e')) {
                        ok = false;
                        Global.showPopup(Global.ln.get('acblock-errortitle'), (Global.ln.get('acblock-noparam') + this._acinfo.p[i].n), 480, 180, Global.ln.get('default-ok'));
                    } else {
                        switch (this._acinfo.p[i].t) {
                            case 'i':
                                if (vali.substr(0, 1) != '#') {
                                    if ((Std.parseFloat(vali) == null) || (Std.parseFloat(vali) == Math.NaN)) {
                                        ok = false;
                                        Global.showPopup(Global.ln.get('acblock-errortitle'), (Global.ln.get('acblock-paramtype') + this._acinfo.p[i].n + Global.ln.get('acblock-paramint')), 480, 180, Global.ln.get('default-ok'));
                                    }
                                }
                            case 'f':
                                if (vali.substr(0, 1) != '#') {
                                    if ((Std.parseFloat(vali) == null) || (Std.parseFloat(vali) == Math.NaN)) {
                                        ok = false;
                                        Global.showPopup(Global.ln.get('acblock-errortitle'), (Global.ln.get('acblock-paramtype') + this._acinfo.p[i].n + Global.ln.get('acblock-paramfloat')), 480, 180, Global.ln.get('default-ok'));
                                    }
                                }
                            case 'b':
                                if (vali.substr(0, 1) != '?') {
                                    vali = vali.toLowerCase();
                                    if ((vali == 'true') || (vali == 'false') || (vali == '1') || (vali == '0')) {
                                        // valid boolean value
                                    } else {
                                        ok = false;
                                        Global.showPopup(Global.ln.get('acblock-errortitle'), (Global.ln.get('acblock-paramtype') + this._acinfo.p[i].n + Global.ln.get('acblock-parambool')), 480, 180, Global.ln.get('default-ok'));
                                    }
                                }
                            case 's':
                                if ((vali.substr(0, 1) == '?') || (vali.substr(0, 1) == '#')) {
                                    ok = false;
                                    Global.showPopup(Global.ln.get('acblock-errortitle'), (Global.ln.get('acblock-paramtype') + this._acinfo.p[i].n + Global.ln.get('acblock-paramstring')), 480, 180, Global.ln.get('default-ok'));
                                }
                            case 'v':
                                if ((vali.substr(0, 1) == '?') || (vali.substr(0, 1) == '#') || (vali.substr(0, 1) == '$')) {
                                    // valid variable name
                                } else {
                                    ok = false;
                                    Global.showPopup(Global.ln.get('acblock-errortitle'), (Global.ln.get('acblock-paramtype') + this._acinfo.p[i].n + Global.ln.get('acblock-paramvariable')), 480, 180, Global.ln.get('default-ok'));
                                }
                        }
                        if (ok) param.push(vali);
                    }
                } else {
                    if (this.ui.inputs['param-'+i].text != '') param.push(this.ui.inputs['param-'+i].text);
                }
            }
        }
        if (ok) {
            if (this._blac != null) {
                this._blac.param = param;
                this._onOk(false);
            } else {
                var ac:Dynamic = {
                    ac: this._acinfo.a, 
                    param: param
                };
                if (this._acinfo.e.length > 0) Reflect.setField(ac, this._acinfo.e[0], "[ ]");
                if (this._acinfo.e.length > 1) Reflect.setField(ac, this._acinfo.e[1], "[ ]");
                this._onOk(ac);
            }
            this._blac = null;
            PopUpManager.removePopUp(this);
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
}