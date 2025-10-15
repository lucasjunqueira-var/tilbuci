/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.movie;

/** HAXE **/
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.ui.component.Intercating.Interacting;
import feathers.controls.LayoutGroup;
import com.tilbuci.display.PictureImage;
import openfl.utils.ByteArray;
import openfl.net.URLRequest;
import com.tilbuci.script.ScriptParser.MovieAction;
import com.tilbuci.ui.component.ActionArea;
import com.tilbuci.font.EmbedFont;
import com.tilbuci.ui.base.HInterfaceContainer;

/** OPENFL **/
import openfl.events.Event;
import openfl.display.Stage;
import openfl.Lib;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.ui.component.CodeArea;
import com.tilbuci.ui.base.InterfaceContainer;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.ui.component.ActionArea;
import com.tilbuci.ui.base.HPanelContainer;
import com.tilbuci.display.SpritemapImage;

class WindowMovieProperties extends PopupWindow {

    /**
        CSS description area
    **/
    private var _cssArea:CodeArea;

    /**
        movie start actions
    **/
    private var _acstart:ActionArea;

    /**
        action snippets area
    **/
    private var _acsnippet:ActionArea;

    /**
        theme color names
    **/
    private var _thColors:Array<String> = [ 'themeColor', 'offsetThemeColor', 'headerFillColor', 'headerFontSize', 'headerFontName', 'headerTextColor', 'rootFillColor', 'fontSize', 'fontName', 'textColor', 'insetFillColor', 'disabledTextColor', 'footerFillColor', 'controlFillColor1', 'controlFillColor2', /*'listBackground', 'listItemBackground', 'listItemFont',*/ 'scrollBarThumbFillColor' ];

    /**
        favicon display
    **/
    private var _favicon:PictureImage;

    /**
        share image display
    **/
    private var _image:PictureImage;

    /**
        loading icon
    **/
    private var _loadingic:SpritemapImage;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-movieprop-title'), 1200, InterfaceFactory.pickValue(570, 620), true, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // about the movie
        this.ui.createHContainer('images');
        var favicon:InterfaceContainer = new InterfaceContainer('v', 10, 0x666666);
        favicon.width = 245;
        favicon.height = 210;
        this.ui.createLabel('favicon', Global.ln.get('window-movieprop-favicon'), Label.VARIANT_DETAIL, favicon);
        this.ui.createButton('favicon', Global.ln.get('window-movieprop-faviconset'), onFavicon, favicon);
        this.ui.createButton('faviconc', Global.ln.get('window-movieprop-faviconclear'), onFaviconClear, favicon);
        this._favicon = new PictureImage(onFaviconLoaded);
        this._favicon.width = this._favicon.height = 32;
        favicon.addChild(this._favicon);
        var image:InterfaceContainer = new InterfaceContainer('v', 10, 0x666666);
        image.width = 245;
        image.height = 210;
        this.ui.createLabel('image', Global.ln.get('window-movieprop-image'), Label.VARIANT_DETAIL, image);
        this.ui.createButton('image', Global.ln.get('window-movieprop-imageset'), onImage, image);
        this.ui.createButton('imagec', Global.ln.get('window-movieprop-imageclear'), onImageClear, image);
        this._image = new PictureImage(onImageLoaded);
        this._image.width = this._image.height = 32;
        image.addChild(this._image);
        this.ui.hcontainers['images'].addChild(favicon);
        this.ui.hcontainers['images'].addChild(image);
        this.ui.hcontainers['images'].width = 500;
        this.addForm(Global.ln.get('window-movieprop-about'), this.ui.createColumnHolder('about', 
            this.ui.forge('leftabout', [
                { tp: 'Label', id: 'moviename', tx: Global.ln.get('window-movienew-name'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'moviename', tx: '', vr: '' },  
                { tp: 'Label', id: 'movieauthor', tx: Global.ln.get('window-movienew-author'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'movieauthor', tx: '', vr: '' }, 
                { tp: 'Label', id: 'moviecopyright', tx: Global.ln.get('window-movienew-copyright'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'moviecopyright', tx: '', vr: '' }, 
                { tp: 'Label', id: 'moviecopyleft', tx: Global.ln.get('window-movienew-copyleft'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'moviecopyleft', tx: '', vr: '' }, 
                { tp: 'Label', id: 'movietags', tx: Global.ln.get('window-movieprop-tags'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'movietags', tx: '', vr: '' }, 
            ]), 
            this.ui.forge('rightabout', [
                { tp: 'Label', id: 'movieindex', tx: Global.ln.get('window-movieprop-index'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Select', id: 'movieindex', vl: [ ], sl: '' },
                { tp: 'Label', id: 'movieabout', tx: Global.ln.get('window-movienew-about'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TArea', id: 'movieabout', tx: '', vr: '', en: true, ht: 130 }, 
                { tp: 'Custom', cont: this.ui.hcontainers['images'] }, 
            ]), 
            this.ui.forge('bottomabout', [
                { tp: 'Button', id: 'saveabout', tx: Global.ln.get('window-movieprop-saveabout'), ac: this.onSaveAbout }
            ]), 440));

        // animation & interaction
        this.ui.createHContainer('imagesinteraction');

        var loadingic:InterfaceContainer = new InterfaceContainer('v', 0, 0x666666);
        loadingic.width = 395;
        loadingic.height = 210;
        this.ui.createLabel('loadingic', Global.ln.get('window-movieprop-loading'), Label.VARIANT_DETAIL, loadingic);
        this.ui.createButton('loadingic', Global.ln.get('window-movieprop-loadingset'), onLoadingIc, loadingic);
        this.ui.createButton('loadingicclear', Global.ln.get('window-movieprop-loadingclear'), onLoadingIcClear, loadingic);
        this._loadingic = new SpritemapImage(onLoadingLoaded);
        this._loadingic.width = this._loadingic.height = 32;
        loadingic.addChild(this._loadingic);
        this.ui.hcontainers['imagesinteraction'].addChild(loadingic);
        this.ui.hcontainers['imagesinteraction'].width = 405;
        this.addForm(Global.ln.get('window-movieprop-animation'), this.ui.forge('anim', [
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
            { tp: 'Label', id: 'movieorigin', tx: Global.ln.get('window-movieprop-origin'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'movieorigin', vl: [
                { text: Global.ln.get('window-movieprop-ornone'), value: "none" }, 
                { text: Global.ln.get('window-movieprop-oralpha'), value: "alpha" }, 
                { text: Global.ln.get('window-movieprop-orcenter'), value: "center" }, 
                { text: Global.ln.get('window-movieprop-ortop'), value: "top" }, 
                { text: Global.ln.get('window-movieprop-ortopkeep'), value: "topkeep" }, 
                { text: Global.ln.get('window-movieprop-orbottom'), value: "bottom" }, 
                { text: Global.ln.get('window-movieprop-orbottomkeep'), value: "bottomkeep" }, 
                { text: Global.ln.get('window-movieprop-orleft'), value: "left" }, 
                { text: Global.ln.get('window-movieprop-orleftkeep'), value: "leftkeep" }, 
                { text: Global.ln.get('window-movieprop-orright'), value: "right" }, 
                { text: Global.ln.get('window-movieprop-orrightkeep'), value: "rightkeep" }, 
                ], sl: 'alpha' }, 
            { tp: 'Label', id: 'movieanimation', tx: Global.ln.get('window-movieprop-interpolation'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'movieanimation', vl: [
                { text: 'Linear', value: "linear" }, 
                { text: 'Bounce.easeIn', value: "bounce.in" }, 
                { text: 'Bounce.easeOut', value: "bounce.out" }, 
                { text: 'Bounce.easeInOut', value: "bounce.inout" }, 
                { text: 'Cubic.easeIn', value: "cubic.in" }, 
                { text: 'Cubic.easeOut', value: "cubic.out" }, 
                { text: 'Cubic.easeInOut', value: "cubic.inout" }, 
                { text: 'Elastic.easeIn', value: "elastic.in" }, 
                { text: 'Elastic.easeOut', value: "elastic.out" }, 
                { text: 'Elastic.easeInOut', value: "elastic.inout" }, 
                { text: 'Expo.easeIn', value: "expo.in" }, 
                { text: 'Expo.easeOut', value: "expo.out" }, 
                { text: 'Expo.easeInOut', value: "expo.inout" }, 
                { text: 'Quad.easeIn', value: "quad.in" }, 
                { text: 'Quad.easeOut', value: "quad.out" }, 
                { text: 'Quad.easeInOut', value: "quad.inout" }, 
                { text: 'Quart.easeIn', value: "quart.in" }, 
                { text: 'Quart.easeOut', value: "quart.out" }, 
                { text: 'Quart.easeInOut', value: "quart.inout" }, 
                { text: 'Quint.easeIn', value: "quint.in" }, 
                { text: 'Quint.easeOut', value: "quint.out" }, 
                { text: 'Quint.easeInOut', value: "quint.inout" }, 
                { text: 'Sine.easeIn', value: "sine.in" }, 
                { text: 'Sine.easeOut', value: "sine.out" }, 
                { text: 'Sine.easeInOut', value: "sine.inout" }
                ], sl: 'linear' }, 

                { tp: 'Label', id: 'moviehighlight', tx: Global.ln.get('window-movieprop-highlight'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'moviehighlight', tx: '', vr: '' },  

                { tp: 'Custom', id: 'moveilodingbt', cont: this.ui.hcontainers['imagesinteraction'] },

                { tp: 'Spacer', id: 'animspacer', ht: 20 }, 
                { tp: 'Button', id: 'saveanim', tx: Global.ln.get('window-movieprop-saveanim'), ac: this.onSaveAnim }
        ]));

        // display area
        this.addForm(Global.ln.get('window-movieprop-display'), this.ui.forge('display', [
            { tp: 'Label', id: 'moviesizebig', tx: Global.ln.get('window-movienew-sizebig'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Numeric', id: 'moviesizebig', mn: Global.AREASIZE_MIN, mx: Global.AREASIZE_MAX, st: 50, vl: 1920 }, 
            { tp: 'Label', id: 'moviesizesmall', tx: Global.ln.get('window-movienew-sizesmall'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Numeric', id: 'moviesizesmall', mn: Global.AREASIZE_MIN, mx: Global.AREASIZE_MAX, st: 50, vl: 1080 }, 
            { tp: 'Label', id: 'moviesizetype', tx: Global.ln.get('window-movienew-sizetype'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'moviesizetype', vl: [
                    { text: Global.ln.get('window-movienew-sizeboth'), value: "both" }, 
                    { text: Global.ln.get('window-movienew-sizeportrait'), value: "portrait" }, 
                    { text: Global.ln.get('window-movienew-sizelandscape'), value: "landscape" }, 
                    //{ text: Global.ln.get('window-movienew-sizesquare'), value: "square" }
                ], sl: 'both' }, 
            { tp: 'Label', id: 'moviecolor', tx: Global.ln.get('window-movieprop-bgcolor'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'moviecolor', tx: '', vr: '' },  
            { tp: 'Spacer', id: 'displayspacer', ht: 210 }, 
            { tp: 'Button', id: 'savedisplay', tx: Global.ln.get('window-movieprop-savedisplay'), ac: this.onSaveDisplay }, 
            { tp: 'Label', id: 'savedisplay', tx: Global.ln.get('window-movieprop-savedisplayabout'), vr: Label.VARIANT_DETAIL }
        ]));
        this.ui.labels['savedisplay'].wordWrap = true;

        // styles
        var cssform:InterfaceContainer = this.ui.createContainer('css');
        cssform.addChild(this.ui.createLabel('csslabel', Global.ln.get('window-movieprop-cssabout'), Label.VARIANT_DETAIL));
        this._cssArea = new CodeArea('css');
        cssform.addChild(this._cssArea);
        this._cssArea.width = 1156;
        this._cssArea.height = 400;
        cssform.addChild(this.ui.createSpacer('cssspacer', 15));
        cssform.addChild(this.ui.createButton('savecss', Global.ln.get('window-movieprop-savecss'), this.onSaveCss ));
        this.addForm(Global.ln.get('window-movieprop-css'), cssform);

        // fonts
        var cont:HInterfaceContainer = new HInterfaceContainer();
        cont.addChild(this.ui.createButton('fontmoviecopy', Global.ln.get('window-movieprop-fontcopymv'), this.onFontMovie, null, false));
        cont.addChild(this.ui.createButton('fontmovieremove', Global.ln.get('window-movieprop-fontdeletemv'), this.onFontMovie, null, false));
        cont.setWidth(560);
        var upfont:HInterfaceContainer = new HInterfaceContainer();
        upfont.addChild(this.ui.createButton('fontadd', Global.ln.get('window-movieprop-fontselect'), this.onFontAdd, null, false));
        upfont.addChild(this.ui.createButton('fontupload', Global.ln.get('window-movieprop-fontupload'), this.onFontUpload, null, false));
        upfont.setWidth(560);
        var fnts:Array<Dynamic> = [ ];
        for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
        var arf:Array<Dynamic> = [ ];
        for (i in GlobalPlayer.mdata.fonts) arf.push({ text: i.name, value: i.name });
        this.addForm(Global.ln.get('window-movieprop-fonts'), this.ui.createColumnHolder('fonts', 
            this.ui.forge('systemfonts', [
                { tp: 'Label', id: 'fontssystem', tx: Global.ln.get('window-movieprop-systemfonts'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'fontssystemlist', vl: fnts, ht: 415, sl: '' }, 
                { tp: 'Button', id: 'fontssystembt', tx: Global.ln.get('window-movieprop-fontcopy'), ac: this.onFontSystem }
            ]),
            this.ui.forge('moviefonts', [
                { tp: 'Label', id: 'fontsmovie', tx: Global.ln.get('window-movieprop-moviefonts'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'fontsmovielist', vl: arf, ht: 252, sl: '' }, 
                { tp: 'Custom', cont: cont }, 
                { tp: 'Spacer', id: 'fontspacer', ht: 20, ln: false }, 
                { tp: 'Label', id: 'fontfile', tx: Global.ln.get('window-setup-font-file'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'fontfile', tx: '', vr: '' }, 
                { tp: 'Label', id: 'fontname', tx: Global.ln.get('window-setup-font-name'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'fontname', tx: '', vr: '' }, 
                { tp: 'Custom', cont: upfont }
            ])
            )
        );

        // action snippets
        var snlist:HInterfaceContainer = new HInterfaceContainer();
        snlist.addChild(this.ui.createButton('snippetsload', Global.ln.get('window-movieprop-snippetsload'), this.onSnLoad, null, false));
        snlist.addChild(this.ui.createButton('snippetsdel', Global.ln.get('window-movieprop-snippetsdel'), this.onSnDel, null, false));
        snlist.setWidth(560);
        this._acsnippet = new ActionArea(560, 314);
        this.addForm(Global.ln.get('window-movieprop-snippets'), this.ui.createColumnHolder('snippets', 
            this.ui.forge('leftsnippets', [
                { tp: 'Label', id: 'snippetslist', tx: Global.ln.get('window-movieprop-snippetslist'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'snippetslist', vl: [ ], ht:360, sl: '' },  
                { tp: 'Custom', cont: snlist }
            ]), 
            this.ui.forge('rightsnippets', [
                { tp: 'Label', id: 'snippetsname', tx: Global.ln.get('window-movieprop-snippetsname'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'snippetsname', tx: '', vr: '' },  
                { tp: 'Label', id: 'snippetscode', tx: Global.ln.get('window-movieprop-snippetscode'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Custom', cont: this._acsnippet }, 
                { tp: 'Button', id: 'snippetsadd', tx: Global.ln.get('window-movieprop-snippetsadd'), ac: this.onSnAdd }
            ]), 
            this.ui.forge('bottomsnippets', [
                { tp: 'Button', id: 'snippetssave', tx: Global.ln.get('window-movieprop-snippetssave'), ac: this.onSaveSnippets }
            ]), 440
        ));
        this.ui.containers['bottomsnippets'].width = 1200;
        this.snippetsList();

        // start actions
        var acstart:InterfaceContainer = this.ui.createContainer('acstart');
        acstart.addChild(this.ui.createLabel('acstartlabel', Global.ln.get('window-movieprop-acstartabout'), Label.VARIANT_DETAIL));
        this._acstart = new ActionArea(1156, 405);
        this._acstart.setText(GlobalPlayer.mdata.acstart);
        acstart.addChild(this._acstart);
        acstart.addChild(this.ui.createSpacer('acstartspacer', 15));
        acstart.addChild(this.ui.createButton('saveacstart', Global.ln.get('window-movieprop-acstartbt'), this.onSaveAcstart ));
        this.addForm(Global.ln.get('window-movieprop-acstart'), acstart);

        // texts
        var txlist:HInterfaceContainer = new HInterfaceContainer();
        txlist.addChild(this.ui.createButton('textsload', Global.ln.get('window-movieprop-textsload'), this.onTxtLoad, null, false));
        txlist.addChild(this.ui.createButton('textsdel', Global.ln.get('window-movieprop-textsdel'), this.onTxtDel, null, false));
        txlist.setWidth(560);
        this.addForm(Global.ln.get('window-movieprop-texts'), this.ui.createColumnHolder('texts', 
            this.ui.forge('lefttexts', [
                { tp: 'Label', id: 'textslist', tx: Global.ln.get('window-movieprop-textslist'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'textslist', vl: [ ], ht:360, sl: '' },  
                { tp: 'Custom', cont: txlist }
            ]), 
            this.ui.forge('righttexts', [
                { tp: 'Label', id: 'textsname', tx: Global.ln.get('window-movieprop-textsname'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'textsname', tx: '', vr: '' },  
                { tp: 'Label', id: 'textsvalue', tx: Global.ln.get('window-movieprop-textsvalue'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TArea', id: 'textsvalue', tx: '', vr: '', en: true, ht: 250 }, 
                { tp: 'Button', id: 'textsadd', tx: Global.ln.get('window-movieprop-textsadd'), ac: this.onTxtAdd },
                { tp: 'Button', id: 'stringssend', tx: Global.ln.get('window-movieprop-stringssend'), ac: this.onStrSend },
                { tp: 'Button', id: 'stringsget', tx: Global.ln.get('window-movieprop-stringsget'), ac: this.onStrGet }
            ]), 
            this.ui.forge('bottomtexts', [
                { tp: 'Button', id: 'textsssave', tx: Global.ln.get('window-movieprop-textssave'), ac: this.onSaveTexts }
            ]), 440
        ));
        this.ui.containers['bottomtexts'].width = 1200;
        this.textsList();

        // numbers
        var numlist:HInterfaceContainer = new HInterfaceContainer();
        numlist.addChild(this.ui.createButton('numbersload', Global.ln.get('window-movieprop-numbersload'), this.onNumLoad, null, false));
        numlist.addChild(this.ui.createButton('numbersdel', Global.ln.get('window-movieprop-numbersdel'), this.onNumDel, null, false));
        numlist.setWidth(560);
        this.addForm(Global.ln.get('window-movieprop-numbers'), this.ui.createColumnHolder('numbers', 
            this.ui.forge('leftnumbers', [
                { tp: 'Label', id: 'numberslist', tx: Global.ln.get('window-movieprop-numberslist'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'numberslist', vl: [ ], ht:360, sl: '' },  
                { tp: 'Custom', cont: numlist }
            ]), 
            this.ui.forge('rightnumbers', [
                { tp: 'Label', id: 'numbersname', tx: Global.ln.get('window-movieprop-numbersname'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'numbersname', tx: '', vr: '' },  
                { tp: 'Label', id: 'numbersvalue', tx: Global.ln.get('window-movieprop-numbersvalue'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Numeric', id: 'numbersvalue', mn:-1000000000, mx:1000000000, st:0.5, vl:0 }, 
                { tp: 'Spacer', id: 'fontspacer', ht: 20, ln: false }, 
                { tp: 'Button', id: 'numbersadd', tx: Global.ln.get('window-movieprop-numbersadd'), ac: this.onNumAdd }
            ]), 
            this.ui.forge('bottomnumbers', [
                { tp: 'Button', id: 'numbersssave', tx: Global.ln.get('window-movieprop-numberssave'), ac: this.onSaveNumbers }
            ]), 440
        ));
        this.ui.containers['bottomnumbers'].width = 1200;
        this.numbersList();

        // flags
        var flaglist:HInterfaceContainer = new HInterfaceContainer();
        flaglist.addChild(this.ui.createButton('flagsload', Global.ln.get('window-movieprop-flagsload'), this.onFlagLoad, null, false));
        flaglist.addChild(this.ui.createButton('flagsdel', Global.ln.get('window-movieprop-flagsdel'), this.onFlagDel, null, false));
        flaglist.setWidth(560);
        this.addForm(Global.ln.get('window-movieprop-flags'), this.ui.createColumnHolder('flags', 
            this.ui.forge('leftflags', [
                { tp: 'Label', id: 'flagslist', tx: Global.ln.get('window-movieprop-flagslist'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'flagslist', vl: [ ], ht:360, sl: '' },  
                { tp: 'Custom', cont: flaglist }
            ]), 
            this.ui.forge('rightflags', [
                { tp: 'Label', id: 'flagsname', tx: Global.ln.get('window-movieprop-flagsname'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'flagsname', tx: '', vr: '' },  
                { tp: 'Label', id: 'flagsvalue', tx: Global.ln.get('window-movieprop-flagsvalue'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Toggle', id: 'flagsvalue', vl: false }, 
                { tp: 'Spacer', id: 'flagspacer', ht: 20, ln: false }, 
                { tp: 'Button', id: 'flagsadd', tx: Global.ln.get('window-movieprop-flagsadd'), ac: this.onFlagAdd }
            ]), 
            this.ui.forge('bottomflags', [
                { tp: 'Button', id: 'flagsssave', tx: Global.ln.get('window-movieprop-flagssave'), ac: this.onSaveFlags }
            ]), 440
        ));
        this.ui.containers['bottomflags'].width = 1200;
        this.flagsList();

        // theme
        var thArea:InterfaceContainer = new InterfaceContainer('v', 10, 0x666666);
        for (fn in this._thColors) {
            this.ui.createLabel(fn, Global.ln.get('window-movieprop-theme-'+fn), Label.VARIANT_DETAIL, thArea);
            this.ui.createTInput(fn, '', '', thArea);
        }
        thArea.width = 1160;
        thArea.height = 400;
        this.addForm(Global.ln.get('window-movieprop-theme'), this.ui.forge('theme', [
            { tp: 'Label', id: 'themeabout', tx: Global.ln.get('window-movieprop-themeabout'), vr: '' }, 
            { tp: 'Custom', cont: thArea }, 
            { tp: 'Spacer', id: 'themespacer', ht: 10, ln: false }, 
            { tp: 'Button', id: 'themesave', tx: Global.ln.get('window-movieprop-themesave'), ac: this.onThemeSave }
        ]));
        this.ui.labels['themeabout'].wordWrap = true;

        // input
        var inOptions:Array<Dynamic> = [
            { text: Global.ln.get('window-movieprop-input-opnothing'), value: 'nothing' }, 
            { text: Global.ln.get('window-movieprop-input-opup'), value: 'up' }, 
            { text: Global.ln.get('window-movieprop-input-opdown'), value: 'down' }, 
            { text: Global.ln.get('window-movieprop-input-opleft'), value: 'left' }, 
            { text: Global.ln.get('window-movieprop-input-opright'), value: 'right' }, 
            { text: Global.ln.get('window-movieprop-input-opnin'), value: 'nin' }, 
            { text: Global.ln.get('window-movieprop-input-opnout'), value: 'nout' }, 
            { text: Global.ln.get('window-movieprop-input-opsnippet'), value: '' }, 
            { text: Global.ln.get('window-movieprop-input-opnextkf'), value: 'nextkf' }, 
            { text: Global.ln.get('window-movieprop-input-opprevkf'), value: 'prevkf' }, 
            { text: Global.ln.get('window-movieprop-input-opfirstkf'), value: 'firstkf' }, 
            { text: Global.ln.get('window-movieprop-input-oplastkf'), value: 'lastkf' }, 
            { text: Global.ln.get('window-movieprop-input-optarget'), value: 'target' }
        ];
        var inArea:InterfaceContainer = new InterfaceContainer('v', 0, 0x666666);
        for (k in GlobalPlayer.mdata.inputs.keys()) {
            this.ui.createLabel(('input-'+k), Global.ln.get('window-movieprop-input-'+k), Label.VARIANT_DETAIL, inArea);
            var inLine:HInterfaceContainer = new HInterfaceContainer();
            this.ui.createSelect(('input-'+k), inOptions, null, inLine, false);
            this.ui.createTInput(('input-'+k), '', '', inLine, false);
            inLine.setWidth(1140);
            inArea.addChild(inLine);
            this.ui.createSpacer(('input-'+k), 5, false, inArea);
        }
        inArea.width = 1160;
        inArea.height = 400;
        this.addForm(Global.ln.get('window-movieprop-input'), this.ui.forge('input', [
            { tp: 'Label', id: 'inputabout', tx: Global.ln.get('window-movieprop-inputabout'), vr: '' }, 
            { tp: 'Custom', cont: inArea }, 
            { tp: 'Spacer', id: 'inputspacer', ht: 10, ln: false }, 
            { tp: 'Button', id: 'inputsave', tx: Global.ln.get('window-movieprop-inputsave'), ac: this.onInputSave }
        ]));
        this.ui.labels['inputabout'].wordWrap = true;

        // plugins
        var plArea:InterfaceContainer = new InterfaceContainer('v', 10, 0x666666);
        for (pl in Global.plugins) {
            var active:Bool = false;
            if (GlobalPlayer.mdata.plugins.exists(pl.plname)) active = GlobalPlayer.mdata.plugins[pl.plname].active;
            this.ui.createLabel(('pl-' + pl.plname), pl.pltitle, Label.VARIANT_DETAIL, plArea);
            this.ui.createToggle(('pl-' + pl.plname), active, plArea);
        }
        plArea.width = 1060;
        plArea.height = 400;
        this.addForm(Global.ln.get('window-movieprop-plugins'), this.ui.forge('plugins', [
            { tp: 'Label', id: 'plugins', tx: Global.ln.get('window-movieprop-plavailable'), vr: '' }, 
            { tp: 'Custom', cont: plArea }, 
            { tp: 'Spacer', id: 'plugins', ht: 10, ln: false }, 
            { tp: 'Button', id: 'plugins', tx: Global.ln.get('window-movieprop-plbt'), ac: this.onPluginSave }
        ]));

        // content access
        this.addForm(Global.ln.get('window-movieprop-access'), this.ui.forge('access', [
            { tp: 'Label', id: 'moviekey', tx: Global.ln.get('window-movieprop-key'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'moviekey', tx: '', vr: '' }, 
            { tp: 'Label', id: 'login', tx: Global.ln.get('window-movieprop-accesslogin'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'login', vl: [
                { text: Global.ln.get('window-movieprop-accessno'), value: false }, 
                { text: Global.ln.get('window-movieprop-accessyes'), value: true }, 
            ], sl: null }, 
            { tp: 'Label', id: 'encrypt', tx: Global.ln.get('window-movieprop-encrypted'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'encrypt', vl: [
                { text: Global.ln.get('window-movieprop-accessno'), value: false }, 
                { text: Global.ln.get('window-movieprop-accessyes'), value: true }, 
            ], sl: null }, 
            { tp: 'Label', id: 'group', tx: Global.ln.get('window-movieprop-accessgroup'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'List', id: 'group', vl: [ ], sl: [ ], ht: 190 }, 
            { tp: 'Label', id: 'fallback', tx: Global.ln.get('window-movieprop-accessfallback'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'fallback', vl: [ ], sl: [ ] }, 
            { tp: 'Spacer', id: 'access', ht: 12, ln: false }, 
            { tp: 'Button', id: 'access', tx: Global.ln.get('window-movieprop-accessbt'), ac: this.onAccess }
        ]));
        this.ui.lists['group'].allowMultipleSelection = true;


        super.startInterface();
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'browsefavicon':
                this._favicon.load(data['file']);
            case 'browseimage':
                this._image.load(data['file']);
            case 'browseloadingic':
                this._loadingic.frames = data['frames'];
                this._loadingic.frtime = data['frtime'];
                this._loadingic.load(data['file']);
        }
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        // about the movie
        this.ui.inputs['moviename'].text = GlobalPlayer.mdata.title;
        this.ui.inputs['movieauthor'].text = GlobalPlayer.mdata.author;
        this.ui.inputs['moviecopyright'].text = GlobalPlayer.mdata.copyright;
        this.ui.inputs['moviecopyleft'].text = GlobalPlayer.mdata.copyleft;
        this.ui.inputs['movietags'].text = GlobalPlayer.mdata.tags.join(', ');
        this.ui.tareas['movieabout'].text = GlobalPlayer.mdata.description;
        var secretkey:String = '';
        if (GlobalPlayer.mdata.key != '') {
            secretkey = StringStatic.decryptKey(GlobalPlayer.mdata.key, 'skey', GlobalPlayer.secret);
        }
        this.ui.inputs['moviekey'].text = secretkey;
        if (GlobalPlayer.mdata.favicon == '') {
            this._favicon.unload();
        } else {
            this._favicon.load(GlobalPlayer.mdata.favicon);
        }
        if (GlobalPlayer.mdata.image == '') {
            this._image.unload();
        } else {
            this._image.load(GlobalPlayer.mdata.image);
        }
        if (GlobalPlayer.mdata.loadingic[0] == '') {
            this._loadingic.unload();
            this._loadingic.visible = false;
        } else {
            this._loadingic.frames = Std.parseInt(GlobalPlayer.mdata.loadingic[1]);
            this._loadingic.frtime = Std.parseInt(GlobalPlayer.mdata.loadingic[2]);
            this._loadingic.load(GlobalPlayer.mdata.loadingic[0]);
        }
        this.ui.setSelectOptions('movieindex', [ ]);
        Global.ws.send('Scene/List', [ 'movie' => GlobalPlayer.movie.mvId ], this.onSceneList);

        // animation
        this.ui.setSelectValue('movietime', GlobalPlayer.mdata.time);
        this.ui.setSelectValue('movieorigin', GlobalPlayer.mdata.origin);
        this.ui.setSelectValue('movieanimation', GlobalPlayer.mdata.animation);
        if (GlobalPlayer.mdata.highlightInt == null) {
            this.ui.inputs['moviehighlight'].text = '';
        } else {
            this.ui.inputs['moviehighlight'].text = '0x' + StringTools.hex(GlobalPlayer.mdata.highlightInt);
        }

        // diplay
        this.ui.numerics['moviesizebig'].value = GlobalPlayer.mdata.screen.big;
        this.ui.numerics['moviesizesmall'].value = GlobalPlayer.mdata.screen.small;
        this.ui.setSelectValue('moviesizetype', GlobalPlayer.mdata.screen.type);
        this.ui.inputs['moviecolor'].text = '0x' + StringTools.hex(GlobalPlayer.mdata.screen.bgcolor);

        // css
        this._cssArea.text = GlobalPlayer.mdata.style;

        // actions
        this._acstart.setText(GlobalPlayer.mdata.acstart);
        this.snippetsList();

        // theme
        var json:Dynamic = StringStatic.jsonParse(GlobalPlayer.mdata.theme);
        if (json != false) {
            for (n in Reflect.fields(json)) {
                if (this.ui.inputs.exists(n)) {
                    this.ui.inputs[n].text = Reflect.field(json, n);
                }
            }
        }

        // input
        for (k in GlobalPlayer.mdata.inputs.keys()) {
            switch (GlobalPlayer.mdata.inputs[k]) {
                case 'up':
                    this.ui.setSelectValue(('input-'+k), 'up');
                    this.ui.inputs['input-'+k].text = '';
                case 'down':
                    this.ui.setSelectValue(('input-'+k), 'down');
                    this.ui.inputs['input-'+k].text = '';
                case 'left':
                    this.ui.setSelectValue(('input-'+k), 'left');
                    this.ui.inputs['input-'+k].text = '';
                case 'right':
                    this.ui.setSelectValue(('input-'+k), 'right');
                    this.ui.inputs['input-'+k].text = '';
                case 'nin':
                    this.ui.setSelectValue(('input-'+k), 'nin');
                    this.ui.inputs['input-'+k].text = '';
                case 'nout':
                    this.ui.setSelectValue(('input-'+k), 'nout');
                    this.ui.inputs['input-'+k].text = '';
                case 'nothing':
                    this.ui.setSelectValue(('input-'+k), 'nothing');
                    this.ui.inputs['input-'+k].text = '';
                case 'nextkf':
                    this.ui.setSelectValue(('input-'+k), 'nextkf');
                    this.ui.inputs['input-'+k].text = '';
                case 'prevkf':
                    this.ui.setSelectValue(('input-'+k), 'prevkf');
                    this.ui.inputs['input-'+k].text = '';
                case 'firstkf':
                    this.ui.setSelectValue(('input-'+k), 'firstkf');
                    this.ui.inputs['input-'+k].text = '';
                case 'lastkf':
                    this.ui.setSelectValue(('input-'+k), 'lastkf');
                    this.ui.inputs['input-'+k].text = '';
                case 'target':
                    this.ui.setSelectValue(('input-'+k), 'target');
                    this.ui.inputs['input-'+k].text = '';
                default:
                    this.ui.setSelectValue(('input-'+k), '');
                    this.ui.inputs['input-'+k].text = GlobalPlayer.mdata.inputs[k];
            }
        }

        // plugins
        for (pl in Global.plugins) {
            var active:Bool = false;
            if (GlobalPlayer.mdata.plugins.exists(pl.plname)) active = GlobalPlayer.mdata.plugins[pl.plname].active;
            this.ui.toggles['pl-' + pl.plname].selected = active;
        }
        
    }

    /**
        Saves the new information about the movie.
    **/
    private function onSaveAbout(evt:TriggerEvent):Void {
        var index:String = '';
        if (this.ui.selects['movieindex'].selectedItem != null) index = this.ui.selects['movieindex'].selectedItem.value;
        var data:String = StringStatic.jsonStringify({
            author: this.ui.inputs['movieauthor'].text, 
            title: this.ui.inputs['moviename'].text, 
            copyright: this.ui.inputs['moviecopyright'].text, 
            copyleft: this.ui.inputs['moviecopyleft'].text, 
            tags: this.ui.inputs['movietags'].text, 
            about: this.ui.tareas['movieabout'].text, 
            start: index, 
            favicon: this._favicon.lastMedia, 
            image: this._image.lastMedia, 
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Saves the new display information.
    **/
    private function onSaveDisplay(evt:TriggerEvent):Void {
        var color:String = StringTools.replace(this.ui.inputs['moviecolor'].text, '#', '0x');
        if (color.substr(0, 2) != '0x') color = '0x' + color;
        if (Std.parseInt(color) == null) {
            this.ui.inputs['moviecolor'].text = '0x' + StringTools.hex(GlobalPlayer.mdata.screen.bgcolor);
        } else {
            this.ui.inputs['moviecolor'].text = color;
        }
        var data:String = StringStatic.jsonStringify({
            bigsize: Math.round(this.ui.numerics['moviesizebig'].value), 
            smallsize: Math.round(this.ui.numerics['moviesizesmall'].value), 
            typesize: this.ui.selects['moviesizetype'].selectedItem.value,
            bgcolor: this.ui.inputs['moviecolor'].text
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Saves the movie animation settings.
    **/
    private function onSaveAnim(evt:TriggerEvent):Void {
        var color:String = StringTools.replace(this.ui.inputs['moviehighlight'].text, '#', '0x');
        if (color.substr(0, 2) != '0x') color = '0x' + color;
        if (Std.parseInt(color) == null) {
            this.ui.inputs['moviehighlight'].text = '';
        } else {
            this.ui.inputs['moviehighlight'].text = color;
        }
        var loadingData:Array<String> = [ '', '', ''];
        if (this._loadingic.mediaLoaded) {
            loadingData = [
                this._loadingic.lastMedia, 
                Std.string(this._loadingic.frames), 
                Std.string(this._loadingic.frtime)
            ];
        }
        var data:String = StringStatic.jsonStringify({
            time: this.ui.selects['movietime'].selectedItem.value,
            origin: this.ui.selects['movieorigin'].selectedItem.value,
            animation: this.ui.selects['movieanimation'].selectedItem.value, 
            highlight: this.ui.inputs['moviehighlight'].text, 
            loadingic: StringStatic.jsonStringify(loadingData)
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Saves the CSS styles.
    **/
    private function onSaveCss(evt:TriggerEvent):Void {
        var data:String = StringStatic.jsonStringify({
            css: this._cssArea.text
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Saves the movie start actions.
    **/
    private function onSaveAcstart(evt:TriggerEvent):Void {
        var json:Dynamic = StringStatic.jsonParse(this._acstart.getText());
        if ((this._acstart.getText() != '') && (json == false)) {
            this.ui.createWarning(Global.ln.get('window-movieprop-acstart'), Global.ln.get('window-movieprop-acstarterror'), 300, 180, this.stage);
        } else {
            var data:String = StringStatic.jsonStringify({
                acstart: this._acstart.getText()
            });
            Global.ws.send(
                'Movie/Update', 
                [
                    'id' => GlobalPlayer.movie.mvId, 
                    'data' => data
                ], 
                this.onSaveReturn
            );
        }
    }

    /**
        Return on movie save.
    **/
    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-movieprop-popup'), Global.ln.get('window-movieprop-popuperror'), 420, 150, this.stage);
        } else{
            if (ld.map['e'] == 0) {
                var ar:Dynamic = cast ld.map['list'];
                for (k in Reflect.fields(ar)) {
                    switch (k) {
                        case 'author': GlobalPlayer.mdata.author = Reflect.field(ar, k);
                        case 'title': GlobalPlayer.mdata.title = Reflect.field(ar, k);
                        case 'copyright': GlobalPlayer.mdata.copyright = Reflect.field(ar, k);
                        case 'copyleft': GlobalPlayer.mdata.copyleft = Reflect.field(ar, k);
                        case 'tags': GlobalPlayer.mdata.tags = Reflect.field(ar, k).split(',');
                        case 'about': GlobalPlayer.mdata.description = Reflect.field(ar, k);
                        case 'start': GlobalPlayer.mdata.start = Reflect.field(ar, k);
                        case 'favicon': GlobalPlayer.mdata.favicon = Reflect.field(ar, k);
                        case 'image': GlobalPlayer.mdata.image = Reflect.field(ar, k);
                        case 'key': GlobalPlayer.mdata.key = Reflect.field(ar, k);
                        case 'fallback': GlobalPlayer.mdata.fallback = Reflect.field(ar, k);
                        case 'identify': GlobalPlayer.mdata.identify = Reflect.field(ar, k) == '1';
                        case 'vsgroups': GlobalPlayer.mdata.vsgroups = Reflect.field(ar, k).split(',');
                        case 'time': GlobalPlayer.mdata.time = Std.parseFloat(Reflect.field(ar, k));
                        case 'origin': GlobalPlayer.mdata.origin = Reflect.field(ar, k);
                        case 'animation': 
                            GlobalPlayer.mdata.animation = Reflect.field(ar, k);
                            GlobalPlayer.area.setAnimation(GlobalPlayer.mdata.animation);
                        case 'highlight': 
                            GlobalPlayer.mdata.highlight = Reflect.field(ar, k);
                            GlobalPlayer.mdata.highlightInt = Std.parseInt(GlobalPlayer.mdata.highlight);
                        case 'loadingic':
                            GlobalPlayer.mdata.loadingic = StringStatic.jsonParse(Reflect.field(ar, k));
                        case 'css':
                            GlobalPlayer.mdata.style = Reflect.field(ar, k);
                            GlobalPlayer.style.clear();
                            GlobalPlayer.style.parseCSS(GlobalPlayer.mdata.style);
                        case 'acstart':
                            GlobalPlayer.mdata.acstart = Reflect.field(ar, k);
                        case 'actions':
                            var json:Dynamic = StringStatic.jsonParse(Reflect.field(ar, k));
                            if (json != false) {
                                GlobalPlayer.mdata.actions = cast json;
                            }
                        case 'texts':
                            var json:Dynamic = StringStatic.jsonParse(Reflect.field(ar, k));
                            if (json != false) {
                                GlobalPlayer.mdata.texts = [ ];
                                for (n in Reflect.fields(json)) GlobalPlayer.mdata.texts[n] = cast(Reflect.field(json, n), String);
                            }
                        case 'numbers':
                            var json:Dynamic = StringStatic.jsonParse(Reflect.field(ar, k));
                            if (json != false) {
                                GlobalPlayer.mdata.numbers = [ ];
                                for (n in Reflect.fields(json)) GlobalPlayer.mdata.numbers[n] = cast(Reflect.field(json, n), Float);
                            }
                        case 'flags':
                            var json:Dynamic = StringStatic.jsonParse(Reflect.field(ar, k));
                            if (json != false) {
                                GlobalPlayer.mdata.flags = [ ];
                                for (n in Reflect.fields(json)) GlobalPlayer.mdata.flags[n] = cast(Reflect.field(json, n), Bool);
                            }
                        case 'theme':
                            GlobalPlayer.mdata.theme = Reflect.field(ar, k);
                        case 'inputs':
                            var json:Dynamic = StringStatic.jsonParse(Reflect.field(ar, k));
                            if (json != false) {
                                for (n in Reflect.fields(json)) {
                                    GlobalPlayer.mdata.inputs[n] = cast(Reflect.field(json, n), String);
                                }
                            }
                        case 'plugins':
                            for (n in GlobalPlayer.mdata.plugins.keys()) {
                                GlobalPlayer.mdata.plugins[n].active = false;
                            }
                            var pls:String = Reflect.field(ar, k);
                            if (pls != '') {
                                var plsar:Array<String> = pls.split(',');
                                for (i in 0...plsar.length) {
                                    if (GlobalPlayer.mdata.plugins.exists(plsar[i])) GlobalPlayer.mdata.plugins[plsar[i]].active = true;
                                }
                            }
                    }
                }
                if (ld.map['reload']) {
                    this._ac('movieload', ['id' => GlobalPlayer.movie.mvId]);
                    PopUpManager.removePopUp(this);
                } else {
                    this.ui.createWarning(Global.ln.get('window-movieprop-popup'), Global.ln.get('window-movieprop-popupok'), 420, 150, this.stage);
                }
            } else {
                this.ui.createWarning(Global.ln.get('window-movieprop-popup'), Global.ln.get('window-movieprop-popuperror'), 420, 150, this.stage);
            }
        }
    }

    /**
        Copies selected system font family name.
    **/
    private function onFontSystem(evt:TriggerEvent):Void {
        if (this.ui.lists['fontssystemlist'].selectedItem != null) {
            Global.copyText(this.ui.lists['fontssystemlist'].selectedItem.value);
        }
    }

    /**
        Copies selected movie font family name.
    **/
    private function onFontMovie(evt:TriggerEvent):Void {
        if (this.ui.lists['fontsmovielist'].selectedItem != null) {
            Global.copyText(this.ui.lists['fontsmovielist'].selectedItem.value);
        }
    }

    /**
        Selecting a font file.
    **/
    private function onFontAdd(evt:TriggerEvent):Void {
        Global.up.browseForFont(this.onFontSelected);
    }

    /**
        A new font file was selected.
        @param  ok  file correctly selected?
    **/
    private function onFontSelected(ok:Bool):Void {
        if (ok) {
            this.ui.inputs['fontfile'].text = Global.up.selectedName;
            if (this.ui.inputs['fontname'].text == '') {
                var fname:String = StringTools.replace(Global.up.selectedName, '.woff2', '');
                fname = StringTools.replace(fname, '.woff', '');
                fname = StringTools.replace(fname, '-', ' ');
                fname = StringTools.replace(fname, '_', ' ');
                this.ui.inputs['fontname'].text = fname;
            }
        } else {
            this.ui.inputs['fontfile'].text = this.ui.inputs['fontname'].text = '';
        }
    }

    /**
        Uploading the selected font
    **/
    private function onFontUpload(evt:TriggerEvent):Void {
        if ((this.ui.inputs['fontfile'].text == '') || (this.ui.inputs['fontname'].text == '')) {
            this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-nofilename'), 300, 180, this.stage);
        } else {
            if (!Global.up.uploadFont(this.fontReturn, [ 'name' => this.ui.inputs['fontname'].text, 'movie' => GlobalPlayer.movie.mvId ])) {
                this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-nofont'), 300, 180, this.stage);
            }
        }
    }

    /**
        Font file upload finished.
    **/
    private function fontReturn(ok:Bool, data:Map<String, Dynamic> = null):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-uploader'), 300, 180, this.stage);
        } else if (data['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-uploader'), 300, 180, this.stage);
        } else {
            new EmbedFont((Global.econfig.player + 'movie/' + GlobalPlayer.movie.mvId + '.movie/media/font/' + data['fname']), data['name'], this.fontLoaded, false);
            var fts:Array<FontInfo> = null;
            try {
                fts = cast(data['mfonts']);
            } catch (e) {
                fts = null;
            }
            if (fts != null) {
                GlobalPlayer.mdata.fonts = fts;
                var arf:Array<Dynamic> = [ ];
                for (i in fts) arf.push({ text: i.name, value: i.name });
                this.ui.setListValues('fontsmovielist', arf);
                this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-uploadok'), 300, 200, this.stage);
            } else {
                this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-uploader'), 300, 180, this.stage);
            }
        }
    }

    /**
        Font file load finish.
        @param  ok  correctly loaded?
        @param  ft  embed font reference
    **/
    private function fontLoaded(ok:Bool, ft:EmbedFont):Void {
        if (ok) {
            /*var fnts:Array<Dynamic> = [ ];
            fnts.push({ text: this.ui.inputs['fontname'].text, value: this.ui.inputs['fontname'].text });
            this.ui.setListValues('fontsmovie', fnts);*/
        }
    }

    /**
        Loads an action snippet text.
    **/
    private function onSnLoad(evt:TriggerEvent):Void {
        if (this.ui.lists['snippetslist'].selectedItem != null) {
            this._acsnippet.setText(this.ui.lists['snippetslist'].selectedItem.value);
            this.ui.inputs['snippetsname'].text = this.ui.lists['snippetslist'].selectedItem.text;
        }
    }

    /**
        Removes an action snippet from the list.
    **/
    private function onSnDel(evt:TriggerEvent):Void {
        if (this.ui.lists['snippetslist'].selectedItem != null) {
            var snar:Array<Dynamic> = [ ];
            for (i in 0...this.ui.lists['snippetslist'].dataProvider.length) {
                if (this.ui.lists['snippetslist'].selectedItem.text != this.ui.lists['snippetslist'].dataProvider.get(i).text) {
                    snar.push(this.ui.lists['snippetslist'].dataProvider.get(i));
                }
            }
            this.ui.setListValues('snippetslist', snar);
        }
    }

    /**
        Adds an action snippet to the list.
    **/
    private function onSnAdd(evt:TriggerEvent):Void {
        var scrtext:String = this._acsnippet.getText();
        if ((scrtext != '') && (this.ui.inputs['snippetsname'].text != '')) {
            var json:Dynamic = StringStatic.jsonParse(scrtext);
            if (json == false) {
                this.ui.createWarning(Global.ln.get('window-movieprop-snippets'), Global.ln.get('window-movieprop-snippetserror'), 300, 180, this.stage);
            } else {
                var snar:Array<Dynamic> = [ ];
                for (i in 0...this.ui.lists['snippetslist'].dataProvider.length) {
                    if (this.ui.lists['snippetslist'].dataProvider.get(i).text != this.ui.inputs['snippetsname'].text) {
                        snar.push({ text: this.ui.lists['snippetslist'].dataProvider.get(i).text, value: this.ui.lists['snippetslist'].dataProvider.get(i).value });
                    }
                }
                snar.push({ text: this.ui.inputs['snippetsname'].text, value: scrtext });
                this.ui.setListValues('snippetslist', snar);
                this.ui.inputs['snippetsname'].text = '';
                this._acsnippet.setText('');
            }
        }
    }

    /**
        Saves the action snippets
    **/
    private function onSaveSnippets(evt:TriggerEvent):Void {
        var arac:Array<MovieAction> = [ ];
        for (i in 0...this.ui.lists['snippetslist'].dataProvider.length) {
            arac.push({ name: this.ui.lists['snippetslist'].dataProvider.get(i).text, ac: this.ui.lists['snippetslist'].dataProvider.get(i).value });
        }
        var json:String = StringStatic.jsonStringify(arac);
        var data:String = StringStatic.jsonStringify({
            actions: json
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Loads the current snippets list.
    **/
    private function snippetsList():Void {
        var lst:Array<Dynamic> = [ ];
        for (i in 0...GlobalPlayer.mdata.actions.length) lst.push({ text: GlobalPlayer.mdata.actions[i].name, value: GlobalPlayer.mdata.actions[i].ac });
        this.ui.setListValues('snippetslist', lst);
        this._acsnippet.setText('');
        this.ui.inputs['snippetsname'].text = '';
    }

    /**
        Loads a text value.
    **/
    private function onTxtLoad(evt:TriggerEvent):Void {
        if (this.ui.lists['textslist'].selectedItem != null) {
            this.ui.inputs['textsname'].text = this.ui.lists['textslist'].selectedItem.text;
            this.ui.tareas['textsvalue'].text = this.ui.lists['textslist'].selectedItem.value;
        }
    }

    /**
        Removes an text value from the list.
    **/
    private function onTxtDel(evt:TriggerEvent):Void {
        if (this.ui.lists['textslist'].selectedItem != null) {
            var snar:Array<Dynamic> = [ ];
            for (i in 0...this.ui.lists['textslist'].dataProvider.length) {
                if (this.ui.lists['textslist'].selectedItem.text != this.ui.lists['textslist'].dataProvider.get(i).text) {
                    snar.push(this.ui.lists['textslist'].dataProvider.get(i));
                }
            }
            this.ui.setListValues('textslist', snar);
        }
    }

    /**
        Adds a text value to the list.
    **/
    private function onTxtAdd(evt:TriggerEvent):Void {
        var snar:Array<Dynamic> = [ ];
        for (i in 0...this.ui.lists['textslist'].dataProvider.length) {
            if (this.ui.lists['textslist'].dataProvider.get(i).text != this.ui.inputs['textsname'].text) {
                snar.push({ text: this.ui.lists['textslist'].dataProvider.get(i).text, value: this.ui.lists['textslist'].dataProvider.get(i).value });
            }
        }
        snar.push({ text: this.ui.inputs['textsname'].text, value: this.ui.tareas['textsvalue'].text });
        this.ui.inputs['textsname'].text = '';
        this.ui.tareas['textsvalue'].text = '';
        this.ui.setListValues('textslist', snar);
    }

    /**
        Downloads the current strings.json file.
    **/
    private function onStrGet(evt:TriggerEvent):Void {
        Global.ws.download([
            'file' => 'strings.json', 
            'movie' => GlobalPlayer.movie.mvId,  
        ]);
    }

    /**
        Selects and uploads a strings.json file.
    **/
    private function onStrSend(evt:TriggerEvent):Void {
        Global.up.selectFile(onStrSelected, 'strings.json file', '*.json');
    }

    /**
        A strings.json file was selected.
    **/
    private function onStrSelected(ok:Bool, data:ByteArray):Void {
        if (ok) {
            var str:String = data.toString();
            var json = StringStatic.jsonParse(str);
            if (json == false) {
                Global.showPopup(Global.ln.get('window-movieprop-stringssend'), Global.ln.get('window-movieprop-stringssendno'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.ws.send(
                    'Media/StringsJSON', 
                    [
                        'movie' => GlobalPlayer.movie.mvId, 
                        'strings' => str
                    ], 
                    onStrSent
                );
            }
        } else {
            Global.showMsg(Global.ln.get('window-movieprop-stringssender'));
        }
    }

    /**
        Strings.json upload finish.
    **/
    private function onStrSent(ok:Bool, ld:DataLoader = null):Void {
        if (!ok) {
            Global.showPopup(Global.ln.get('window-movieprop-stringssend'), Global.ln.get('window-movieprop-stringssendnosend'), 320, 150, Global.ln.get('default-ok'));
        } else if (ld.map['e'] != '0') {
            Global.showPopup(Global.ln.get('window-movieprop-stringssend'), Global.ln.get('window-movieprop-stringssendnosend'), 320, 150, Global.ln.get('default-ok'));
        } else {
            Global.showMsg(Global.ln.get('window-movieprop-stringssendok'));
        }
    }

    /**
        Saves the global texts.
    **/
    private function onSaveTexts(evt:TriggerEvent):Void {
        var txts:Map<String, String> = [ ];
        for (i in 0...this.ui.lists['textslist'].dataProvider.length) {
            txts[this.ui.lists['textslist'].dataProvider.get(i).text] = this.ui.lists['textslist'].dataProvider.get(i).value;
        }
        var data:String = StringStatic.jsonStringify({
            texts: StringStatic.jsonStringify(txts)
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Loads the current global texts list.
    **/
    private function textsList():Void {
        var lst:Array<Dynamic> = [ ];
        for (n in GlobalPlayer.mdata.texts.keys()) {
            lst.push({ text: n, value: GlobalPlayer.mdata.texts[n] });
        }
        this.ui.setListValues('textslist', lst);
    }

    /**
        Loads a number value.
    **/
    private function onNumLoad(evt:TriggerEvent):Void {
        if (this.ui.lists['numberslist'].selectedItem != null) {
            this.ui.inputs['numbersname'].text = this.ui.lists['numberslist'].selectedItem.text;
            this.ui.numerics['numbersvalue'].value = this.ui.lists['numberslist'].selectedItem.value;
        }
    }

    /**
        Removes a number value from the list.
    **/
    private function onNumDel(evt:TriggerEvent):Void {
        if (this.ui.lists['numberslist'].selectedItem != null) {
            var snar:Array<Dynamic> = [ ];
            for (i in 0...this.ui.lists['numberslist'].dataProvider.length) {
                if (this.ui.lists['numberslist'].selectedItem.text != this.ui.lists['numberslist'].dataProvider.get(i).text) {
                    snar.push(this.ui.lists['numberslist'].dataProvider.get(i));
                }
            }
            this.ui.setListValues('numberslist', snar);
        }
    }

    /**
        Adds a number value to the list.
    **/
    private function onNumAdd(evt:TriggerEvent):Void {
        var snar:Array<Dynamic> = [ ];
        for (i in 0...this.ui.lists['numberslist'].dataProvider.length) {
            if (this.ui.lists['numberslist'].dataProvider.get(i).text != this.ui.inputs['numbersname'].text) {
                snar.push({ text: this.ui.lists['numberslist'].dataProvider.get(i).text, value: this.ui.lists['numberslist'].dataProvider.get(i).value });
            }
        }
        snar.push({ text: this.ui.inputs['numbersname'].text, value: this.ui.numerics['numbersvalue'].value });
        this.ui.inputs['numbersname'].text = '';
        this.ui.numerics['numbersvalue'].value = 0;
        this.ui.setListValues('numberslist', snar);
    }

    /**
        Saves the global numbers.
    **/
    private function onSaveNumbers(evt:TriggerEvent):Void {
        var nums:Map<String, Float> = [ ];
        for (i in 0...this.ui.lists['numberslist'].dataProvider.length) {
            nums[this.ui.lists['numberslist'].dataProvider.get(i).text] = this.ui.lists['numberslist'].dataProvider.get(i).value;
        }
        var data:String = StringStatic.jsonStringify({
            numbers: StringStatic.jsonStringify(nums)
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Loads the current global numbers list.
    **/
    private function numbersList():Void {
        var lst:Array<Dynamic> = [ ];
        for (n in GlobalPlayer.mdata.numbers.keys()) {
            lst.push({ text: n, value: GlobalPlayer.mdata.numbers[n] });
        }
        this.ui.setListValues('numberslist', lst);
    }

    /**
        Loads a flag value.
    **/
    private function onFlagLoad(evt:TriggerEvent):Void {
        if (this.ui.lists['flagslist'].selectedItem != null) {
            this.ui.inputs['flagsname'].text = this.ui.lists['flagslist'].selectedItem.text;
            this.ui.toggles['flagsvalue'].selected = this.ui.lists['flagslist'].selectedItem.value;
        }
    }

    /**
        Removes a flag value from the list.
    **/
    private function onFlagDel(evt:TriggerEvent):Void {
        if (this.ui.lists['flagslist'].selectedItem != null) {
            var snar:Array<Dynamic> = [ ];
            for (i in 0...this.ui.lists['flagslist'].dataProvider.length) {
                if (this.ui.lists['flagslist'].selectedItem.text != this.ui.lists['flagslist'].dataProvider.get(i).text) {
                    snar.push(this.ui.lists['flagslist'].dataProvider.get(i));
                }
            }
            this.ui.setListValues('flagslist', snar);
        }
    }

    /**
        Adds a flag value to the list.
    **/
    private function onFlagAdd(evt:TriggerEvent):Void {
        var snar:Array<Dynamic> = [ ];
        for (i in 0...this.ui.lists['flagslist'].dataProvider.length) {
            if (this.ui.lists['flagslist'].dataProvider.get(i).text != this.ui.inputs['flagsname'].text) {
                snar.push({ text: this.ui.lists['flagslist'].dataProvider.get(i).text, value: this.ui.lists['flagslist'].dataProvider.get(i).value });
            }
        }
        snar.push({ text: this.ui.inputs['flagsname'].text, value: this.ui.toggles['flagsvalue'].selected });
        this.ui.inputs['flagsname'].text = '';
        this.ui.toggles['flagsvalue'].selected = false;
        this.ui.setListValues('flagslist', snar);
    }

    /**
        Saves the global flags.
    **/
    private function onSaveFlags(evt:TriggerEvent):Void {
        var flags:Map<String, Float> = [ ];
        for (i in 0...this.ui.lists['flagslist'].dataProvider.length) {
            flags[this.ui.lists['flagslist'].dataProvider.get(i).text] = this.ui.lists['flagslist'].dataProvider.get(i).value;
        }
        var data:String = StringStatic.jsonStringify({
            flags: StringStatic.jsonStringify(flags)
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Loads the current global flags list.
    **/
    private function flagsList():Void {
        var lst:Array<Dynamic> = [ ];
        for (n in GlobalPlayer.mdata.flags.keys()) {
            lst.push({ text: n, value: GlobalPlayer.mdata.flags[n] });
        }
        this.ui.setListValues('flagslist', lst);
    }

    /**
        Saves the ui theme.
    **/
    private function onThemeSave(evt:TriggerEvent):Void {
        var colors:Map<String, String> = [ ];
        for (n in this._thColors) {
            if (this.ui.inputs[n].text != '') {
                var str:String = StringTools.replace(this.ui.inputs[n].text, '#', '0x');
                colors[n] = str;
            }
        }
        var data:String = StringStatic.jsonStringify({
            theme: StringStatic.jsonStringify(colors)
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Saves the input settings.
    **/
    private function onInputSave(evt:TriggerEvent):Void {
        var inputs:Map<String, String> = [ ];
        for (k in GlobalPlayer.mdata.inputs.keys()) {
            switch (this.ui.selects[('input-'+k)].selectedItem.value) {
                case 'up':
                    inputs[k] = 'up';
                case 'down':
                    inputs[k] = 'down';
                case 'left':
                    inputs[k] = 'left';
                case 'right':
                    inputs[k] = 'right';
                case 'nin':
                    inputs[k] = 'nin';
                case 'nout':
                    inputs[k] = 'nout';
                case 'nothing':
                    inputs[k] = 'nothing';
                case 'nextkf':
                    inputs[k] = 'nextkf';
                case 'prevkf':
                    inputs[k] = 'prevkf';
                case 'firstkf':
                    inputs[k] = 'firstkf';
                case 'lastkf':
                    inputs[k] = 'lastkf';
                case 'target':
                    inputs[k] = 'target';
                default:
                    inputs[k] = this.ui.inputs[('input-'+k)].text;
            }
        }
        var data:String = StringStatic.jsonStringify({
            inputs: StringStatic.jsonStringify(inputs)
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Saves the plugins settings.
    **/
    private function onPluginSave(evt:TriggerEvent):Void {
        var pl:Array<String> = [ ];
        for (n in Global.plugins.keys()) {
            if (this.ui.toggles['pl-'+n].selected) pl.push(n);
        }
        var data:String = StringStatic.jsonStringify({
            plugins: pl.join(',')
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Saves the new information about the movie.
    **/
    private function onAccess(evt:TriggerEvent):Void {
        var secretkey:String = '';
        if (this.ui.inputs['moviekey'].text != '') {
            secretkey = StringStatic.encryptKey(this.ui.inputs['moviekey'].text, 'skey', GlobalPlayer.secret);
        }
        var identify:String = '0';
        if (this.ui.selects['login'].selectedItem.value == true) identify = '1';
        var encrypt:String = '0';
        if (this.ui.selects['encrypt'].selectedItem.value == true) encrypt = '1';
        var vsgroups:Array<String> = [ ];
        for (n in this.ui.lists['group'].selectedItems) vsgroups.push(n.value);
        var data:String = StringStatic.jsonStringify({
            key: secretkey, 
            identify: identify, 
            fallback: this.ui.selects['fallback'].selectedItem.value, 
            vsgroups: vsgroups.join(','), 
            encrypt: encrypt, 
        });
        Global.ws.send(
            'Movie/Update', 
            [
                'id' => GlobalPlayer.movie.mvId, 
                'data' => data
            ], 
            this.onSaveReturn
        );
    }

    /**
        Selects the favicon.
    **/
    private function onFavicon(evt:TriggerEvent):Void {
        this._ac('browsefavicon');
    }

    /**
        Clears the favicon.
    **/
    private function onFaviconClear(evt:TriggerEvent):Void {
        this._favicon.unload();
    }

    /**
        The favicon image was loaded.
    **/
    private function onFaviconLoaded(ok:Bool):Void {
        this._favicon.width = this._favicon.height = 80;
        this._favicon.visible = true;
    }

    /**
        Selects the share image.
    **/
    private function onImage(evt:TriggerEvent):Void {
        this._ac('browseimage');
    }

    /**
        Clears the share image.
    **/
    private function onImageClear(evt:TriggerEvent):Void {
        this._image.unload();
    }

    /**
        The share image image was loaded.
    **/
    private function onImageLoaded(ok:Bool):Void {
        this._image.height = 80;
        this._image.width = this._image.oWidth * this._image.height / this._image.oHeight;
        if (this._image.width > 210) {
            this._image.width = 210;
            this._image.height = this._image.oHeight * this._image.width / this._image.oWidth;
        }
        this._image.visible = true;
    }

    /**
        Selects the loading icon.
    **/
    private function onLoadingIc(evt:TriggerEvent):Void {
        this._ac('browseloadingic');
    }

    /**
        Clears the favicon.
    **/
    private function onLoadingIcClear(evt:TriggerEvent):Void {
        this._loadingic.visible = false;
        this._loadingic.unload();
    }

    /**
        The loading icon image was loaded.
    **/
    private function onLoadingLoaded(ok:Bool):Void {
        this._loadingic.height = 80;
        this._loadingic.width = this._loadingic.oWidth * this._loadingic.height / this._loadingic.oHeight;
        this._loadingic.visible = true;
    }

    /**
        The scenes list was just loaded.
    **/
    private function onSceneList(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 0) {
                for (n in Reflect.fields(ld.map['list'])) {
                    var it:Dynamic = Reflect.field(ld.map['list'], n);
                    if (Reflect.hasField(it, 'id')) {
                        list.push({
                            text: Reflect.field(it, 'title'), 
                            value: Reflect.field(it, 'id')
                        });
                    }
                }
            }
        }
        this.ui.setSelectOptions('movieindex', list);
        this.ui.setSelectValue('movieindex', GlobalPlayer.mdata.start);
        Global.ws.send('Visitor/Access', [ 'movie' => GlobalPlayer.movie.mvId ], this.onAccessList);
    }

    /**
        The access information was just loaded.
    **/
    private function onAccessList(ok:Bool, ld:DataLoader):Void {
        this.ui.setSelectValue('fallback', '');
        this.ui.setSelectValue('login', false);
        this.ui.setSelectValue('encrypt', false);
        this.ui.setListValues('group', [ ]);
        this.ui.setSelectOptions('fallback', [ { text: Global.ln.get('window-movieprop-accessnone') , value: '' } ]);
        if (ok) {
            if (ld.map['e'] == 0) {
                var list:Array<Dynamic> = [ { text: Global.ln.get('window-movieprop-accessnone') , value: '' } ];
                for (n in Reflect.fields(ld.map['list'])) {
                    var it:Dynamic = Reflect.field(ld.map['list'], n);
                    list.push({
                        text: Reflect.field(it, 'title'), 
                        value: Reflect.field(it, 'id'), 
                    });
                    this.ui.setSelectOptions('fallback', list);
                }
                this.ui.setSelectValue('fallback', GlobalPlayer.mdata.fallback);
                list = [ ];
                for (n in Reflect.fields(ld.map['group'])) {
                    var it:Dynamic = Reflect.field(ld.map['group'], n);
                    list.push({
                        text: Reflect.field(it, 'name'), 
                        value: Reflect.field(it, 'id'), 
                    });
                    this.ui.setListValues('group', list);
                }
                this.ui.setListMultiValue('group', GlobalPlayer.mdata.vsgroups);
                this.ui.setSelectValue('login', GlobalPlayer.mdata.identify);
                this.ui.setSelectValue('encrypt', GlobalPlayer.mdata.encrypted);
            }
        }
    }
}