/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window;

/** OPENFL **/
import feathers.layout.VerticalAlign;
import feathers.layout.AutoSizeMode;
import feathers.layout.HorizontalLayout;
import feathers.controls.LayoutGroup;
import feathers.core.FeathersControl;
import feathers.core.MeasureSprite;
import feathers.data.ArrayCollection;
import feathers.controls.navigators.TabNavigator;
import feathers.controls.navigators.TabItem;
import feathers.layout.AnchorLayout;
import openfl.events.Event;
import openfl.display.DisplayObject;
import openfl.display.Bitmap;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.layout.AnchorLayoutData;
import feathers.controls.Header;
import feathers.layout.VerticalLayout;
import feathers.controls.Button;
import feathers.controls.ScrollContainer;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.base.BackgroundSkin;
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.ui.base.InterfaceColumns;

/**
    Basic popup window.
**/
class PopupWindow extends Panel {

    /**
        the window header
    **/
    private var _head:Header;

    /**
        close button
    **/
    private var _btClose:Button;

    /**
        notes button
    **/
    private var _btNotes:Button;

    /**
        tab navigator
    **/
    private var _tabs:TabNavigator;

    /**
        forms container
    **/
    private var _forms:ScrollContainer;

    /**
        all add interfaces
    **/
    private var _interfaces:Array<MeasureSprite> = [ ];

    /**
        action function
    **/
    private var _ac:Dynamic;

    /**
        default layout for window forms
    **/
    private var _vLayout:VerticalLayout;

    /**
        default layout padding
    **/
    private var _padding:Int = 10;

    /**
        using tab navigation buttons?
    **/
    private var _withTabs:Bool = false;

    /**
        the interface factory
    **/
    public var ui:InterfaceFactory;

    /**
        Constructor.
        @param  ac  method to call on actions
        @param  tit the window title
        @param  wd  window witdh (0 for automatic)
        @param  ht  window height (0 for automatic)
        @param  tabs    show the tabs interface?
        @param  ws  reference to the webservices
    **/
    public function new(ac:Dynamic, tit:String, wd:Int = 0, ht:Int = 0, tabs:Bool = true, close:Bool = true, notes:Bool = false) {
        super();
        this.ui = new InterfaceFactory(this._padding);
        this.backgroundSkin = new BackgroundSkin(0x383838);
        this.layout = new AnchorLayout();        
        this.setPadding(0);
        this._ac = ac;
        if (wd > 0) {
            this.width = wd;
        } else {
            this.width = 500;
        }
        if (ht > 0) {
            this.height = ht;
        } else {
            this.height = 400;
        }

        this._head = new Header();
        this._head.text = tit;
        this.header = this._head;

        var hdbuttons:LayoutGroup = new LayoutGroup();
        var btlay:HorizontalLayout = new HorizontalLayout();
        btlay.gap = 10;
        hdbuttons.layout = btlay;

        if (notes) {
            this._btNotes = new Button();
            var bmp:Bitmap = new Bitmap(Assets.getBitmapData('btNotes'));
            bmp.width = bmp.height = 20;
            bmp.smoothing = true;
            this._btNotes.icon = bmp;
            this._btNotes.width = 40;
            this._btNotes.height = 30;
            this._btNotes.addEventListener(TriggerEvent.TRIGGER, notesWindow);
            hdbuttons.addChild(this._btNotes);
        }

        if (close) {
            this._btClose = new Button();
            var bmp:Bitmap = new Bitmap(Assets.getBitmapData('btClose'));
            bmp.width = bmp.height = 20;
            bmp.smoothing = true;
            this._btClose.icon = bmp;
            this._btClose.width = 40;
            this._btClose.height = 30;
            this._btClose.addEventListener(TriggerEvent.TRIGGER, closeWindow);
            hdbuttons.addChild(this._btClose);
        }

        this._head.rightView = hdbuttons;

        this._tabs = new TabNavigator();
        this._tabs.dataProvider = new ArrayCollection();
        this._tabs.layoutData = AnchorLayoutData.fill();
        this._tabs.addEventListener(Event.CHANGE, onTab);
        if (tabs) this.addChild(this._tabs);

        this._vLayout = new VerticalLayout();
        this._vLayout.setPadding(0);
        this._vLayout.gap = 0;
        this._vLayout.verticalAlign = TOP;
        this._vLayout.horizontalAlign = LEFT;

        this._forms = new ScrollContainer();
        this._forms.backgroundSkin = new BackgroundSkin();
        this._forms.layout =  this._vLayout;
        this._forms.width = this.width;
        if (!tabs) this.addChild(this._forms);
        
        this._withTabs = tabs;

        if (this.stage != null) {
            this.initialize();
        } else {
            this.addEventListener(Event.ADDED_TO_STAGE, this.startInterface);
        }
    }

    /**
        Window action to run on display.
    **/
    public function acStart():Void {
    }

    /**
        Creates the window interface.
    **/
    public function startInterface(evt:Event = null):Void {
        if (this.hasEventListener(Event.ADDED_TO_STAGE)) this.removeEventListener(Event.ADDED_TO_STAGE, this.startInterface);
        this.redraw();
    }

    /**
        Adds a form to the window.
        @param  tit the form title
        @param  form    the form content
    **/
    public function addForm(tit:String, form:MeasureSprite):Void {
        // set form size
        form.width = this.width;
        form.minHeight = this.height - (2 * this._padding);
        // columns?
        if (Type.getClassName(Type.getClass(form)) == 'com.tilbuci.ui.base.InterfaceColumns') {
            var cols:InterfaceColumns = cast form;
            cols.left.width = cols.right.width = this.width / 2;
        }
        // add form
        this._interfaces.push(form);
        if (this._withTabs) {
            this._tabs.dataProvider.add(TabItem.withDisplayObject(tit, form));
        } else {
            this._forms.addChild(form);
        }
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.removeEventListener(Event.ADDED_TO_STAGE, this.redraw);
        this._tabs.removeEventListener(Event.CHANGE, onTab);
        this.removeChildren();
        while (this._interfaces.length > 0) this._interfaces.shift();
        this._interfaces = null;
        this._head.removeChildren();
        this._head = null;
        this._btClose.removeChildren();
        this._btClose = null;
        this._tabs.removeChildren();
        this._tabs.removeAllItems();
        this._tabs = null;
        this._forms.removeChildren();
        this._forms = null;
        this.ui.kill();
        this.ui = null;
        this._ac = null;
    }

    /**
        Redraws the window.

    **/
    public function redraw(evt:Event = null):Void {
        for (n in 0...this._interfaces.length) {
            this._interfaces[n].width = this.width;
            this._interfaces[n].minHeight = this.height - (2 * this._padding);
            if (Type.getClassName(Type.getClass(this._interfaces[n])) == 'com.tilbuci.ui.base.InterfaceColumns') {
                var cols:InterfaceColumns = cast this._interfaces[n];
                cols.left.width = cols.right.width = this.width / 2;
            }
        }
        this.ui.redraw();
    }

    /**
        Window custom actions (to override).
    **/
    public function action(ac:String, data:Map<String, Dynamic> = null):Void {

    }

    /**
        Calls the close menu action.
    **/
    private function closeWindow(evt:TriggerEvent):Void {
        PopUpManager.removePopUp(this);
        if (this._ac != null) this._ac('window-close');
    }

    /**
        Shows the notes window.
    **/
    private function notesWindow(evt:TriggerEvent):Void {
        if (this._ac != null) this._ac('window-notes');
    }

    /**
        New interface shown on tab navigator.
    **/
    private function onTab(evt:Event):Void {
        this.redraw();
    }

}