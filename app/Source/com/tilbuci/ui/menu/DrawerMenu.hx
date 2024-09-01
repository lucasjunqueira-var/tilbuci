package com.tilbuci.ui.menu;

/** OPENFL **/
import openfl.display.Bitmap;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.layout.AnchorLayout;
import feathers.controls.Header;
import feathers.layout.VerticalLayout;
import feathers.controls.Button;
import feathers.controls.ScrollContainer;
import feathers.controls.Panel;
import feathers.events.TriggerEvent;

/** TILBUCI **/
import com.tilbuci.ui.base.BackgroundSkin;
import com.tilbuci.ui.base.InterfaceFactory;

/**
    Basic action menu.
**/
class DrawerMenu extends Panel {

    /**
        the menu header
    **/
    private var _head:Header;

    /**
        menu container
    **/
    private var _holder:ScrollContainer;

    /**
        action function
    **/
    private var _ac:Dynamic;

    /**
        user interface
    **/
    public var ui:InterfaceFactory;

    /**
        Constructor.
        @param  ac  the mthod to call for actions
        @param  tit the menu title
    **/
    public function new(ac:Dynamic, tit:String) {
        super();
        this.backgroundSkin = new BackgroundSkin(0x666666);
        this._ac = ac;
        this.ui = new InterfaceFactory();

        this._head = new Header();
        this._head.text = tit;
        this.header = this._head;

        var btBack:Button = this.ui.createIconButton('btBack', closeMenu, new Bitmap(Assets.getBitmapData('btBack')));
        btBack.horizontalAlign = LEFT;
        btBack.width = 40;
        btBack.height = 30;
        this._head.leftView = btBack;


        this._holder = new ScrollContainer();
        this._holder.layout = new AnchorLayout();
        this._holder.backgroundSkin = new BackgroundSkin(0x666666);
        var lay:VerticalLayout = new VerticalLayout();
        lay.setPadding(10);
        lay.gap = 10;
        lay.verticalAlign = TOP;
        this._holder.layout = lay;
        this.addChild(this._holder);
    }

    /**
        The menu was just open.
    **/
    public function onShow():Void {
        
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.removeChildren();
        this._head.leftView = null;
        this._head = null;
        this._holder.removeChildren();
        this._holder = null;
        this.ui.kill();
        this.ui = null;
    }

    /**
        Adds a button to the menu.
        @param  txt the button label
        @param  ac  the click funcion
        @return the created button reference
    **/
    private function addButton(name:String, txt:String, ac:Dynamic, icon:Bitmap = null):Button {
        var bt:Button;
        if (icon == null) {
            bt = this.ui.createButton(name, txt, ac, this._holder);
        } else {
            bt = this.ui.createIconButton(name, ac, icon, txt, this._holder);
        }
        bt.width = 200;
        bt.horizontalAlign = LEFT;
        return (bt);
    }

    /**
        Calls the close menu action.
    **/
    private function closeMenu(evt:TriggerEvent):Void {
        this._ac('menu-close');
    }

}