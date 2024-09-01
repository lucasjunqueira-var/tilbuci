package com.tilbuci.ui.menu;

/** FEATHERS UI **/
import feathers.controls.Button;
import feathers.events.TriggerEvent;

/** TILBUCI **/
import com.tilbuci.ui.menu.DrawerMenu;
import com.tilbuci.data.Global;

class MenuMovie extends DrawerMenu {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        super(ac, Global.ln.get('menu-movie-title'));
        this.addButton('btNew', Global.ln.get('menu-movie-new'), onNew);
        this.addButton('btOpen', Global.ln.get('menu-movie-open'), onOpen);
        this.addButton('btProperties', Global.ln.get('menu-movie-properties'), onProp);
        this.addButton('btUsers', Global.ln.get('menu-movie-users'), onUsers);
        //this.addButton('btPlugins', Global.ln.get('menu-movie-plugins'), onPlugins);
    }

    /**
        The menu was just open.
    **/
    override public function onShow():Void {
        super.onShow();
        this.ui.buttons['btNew'].enabled = Global.ws.level <= 50;
        this.ui.buttons['btProperties'].enabled = Global.mvOwner;
        this.ui.buttons['btUsers'].enabled = Global.mvOwner;
        //this.ui.buttons['btPlugins'].enabled = Global.mvOwner;
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Shows the new movie window.
    **/
    private  function onNew(evt:TriggerEvent):Void {
        this._ac('new');
    }

    /**
        Shows the open movie window.
    **/
    private  function onOpen(evt:TriggerEvent):Void {
        this._ac('open');
    }

    /**
        Shows the properties movie window.
    **/
    private  function onProp(evt:TriggerEvent):Void {
        this._ac('prop');
    }

    /**
        Shows the movie users manager.
    **/
    private  function onUsers(evt:TriggerEvent):Void {
        this._ac('users');
    }

    /**
        Shows the movie plugin setup.
    **/
    private  function onPlugins(evt:TriggerEvent):Void {
        this._ac('plugins');
    }

}