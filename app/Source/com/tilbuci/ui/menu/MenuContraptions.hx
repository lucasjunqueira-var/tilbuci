package com.tilbuci.ui.menu;

/** FEATHERS UI **/
import com.tilbuci.data.GlobalPlayer;
import feathers.controls.Button;
import feathers.events.TriggerEvent;

/** TILBUCI **/
import com.tilbuci.ui.menu.DrawerMenu;
import com.tilbuci.data.Global;

class MenuContraptions extends DrawerMenu {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        super(ac, Global.ln.get('menu-contraptions-title'));
        this.addButton('btCover', Global.ln.get('menu-contraptions-cover'), onCover);
        this.addButton('btBackground', Global.ln.get('menu-contraptions-background'), onBackground);
        this.addButton('btMenus', Global.ln.get('menu-contraptions-menus'), onMenus);
        this.addButton('btMusic', Global.ln.get('menu-contraptions-music'), onMusic);
        this.addButton('btForms', Global.ln.get('menu-contraptions-forms'), onForms);
        this.addButton('btInterfaces', Global.ln.get('menu-contraptions-interfaces'), onInterfaces);
        this.addButton('btTargets', Global.ln.get('menu-contraptions-targets'), onTargets);
        this.addButton('btMessages', Global.ln.get('menu-contraptions-messages'), onMessages);
    }

    /**
        The menu was just open.
    **/
    override public function onShow():Void {
        super.onShow();
        if ((GlobalPlayer.movie.mvId == '') || (Global.ws.level > 50))  {
            this.ui.buttons['btMenus'].enabled = false;
            this.ui.buttons['btCover'].enabled = false;
            this.ui.buttons['btMenus'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
            this.ui.buttons['btCover'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
            this.ui.buttons['btMusic'].enabled = false;
            this.ui.buttons['btMusic'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
            this.ui.buttons['btForms'].enabled = false;
            this.ui.buttons['btForms'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
            this.ui.buttons['btInterfaces'].enabled = false;
            this.ui.buttons['btInterfaces'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
            this.ui.buttons['btTargets'].enabled = false;
            this.ui.buttons['btTargets'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
            this.ui.buttons['btMessages'].enabled = false;
            this.ui.buttons['btMessages'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
            this.ui.buttons['btBackground'].enabled = false;
            this.ui.buttons['btBackground'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
        } else {
            this.ui.buttons['btMenus'].enabled = true;
            this.ui.buttons['btMenus'].toolTip = null;
            this.ui.buttons['btCover'].enabled = true;
            this.ui.buttons['btCover'].toolTip = null;
            this.ui.buttons['btMusic'].enabled = true;
            this.ui.buttons['btMusic'].toolTip = null;
            this.ui.buttons['btForms'].enabled = true;
            this.ui.buttons['btForms'].toolTip = null;
            this.ui.buttons['btInterfaces'].enabled = true;
            this.ui.buttons['btInterfaces'].toolTip = null;
            this.ui.buttons['btTargets'].enabled = true;
            this.ui.buttons['btTargets'].toolTip = null;
            this.ui.buttons['btMessages'].enabled = true;
            this.ui.buttons['btMessages'].toolTip = null;
            this.ui.buttons['btBackground'].enabled = true;
            this.ui.buttons['btBackground'].toolTip = null;
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Menus
    **/
    private  function onMenus(evt:TriggerEvent):Void {
        this._ac('menus');
    }

    /**
        Cover
    **/
    private  function onCover(evt:TriggerEvent):Void {
        this._ac('cover');
    }

    /**
        Music
    **/
    private  function onMusic(evt:TriggerEvent):Void {
        this._ac('music');
    }

    /**
        Forms
    **/
    private  function onForms(evt:TriggerEvent):Void {
        this._ac('form');
    }

    /**
        Interfaces
    **/
    private  function onInterfaces(evt:TriggerEvent):Void {
        this._ac('interfaces');
    }

    /**
        Targets
    **/
    private  function onTargets(evt:TriggerEvent):Void {
        this._ac('targets');
    }

    /**
        Messages
    **/
    private  function onMessages(evt:TriggerEvent):Void {
        this._ac('messages');
    }

    /**
        Background
    **/
    private  function onBackground(evt:TriggerEvent):Void {
        this._ac('background');
    }

}