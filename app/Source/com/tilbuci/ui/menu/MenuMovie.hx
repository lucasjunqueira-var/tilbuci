package com.tilbuci.ui.menu;

/** FEATHERS UI **/
import com.tilbuci.data.GlobalPlayer;
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
        this.addButton('btRemove', Global.ln.get('menu-movie-remove'), onRemove);
    }

    /**
        The menu was just open.
    **/
    override public function onShow():Void {
        super.onShow();
        if (Global.ws.level <= 50) {
            this.ui.buttons['btNew'].enabled = true;
            this.ui.buttons['btNew'].toolTip = null;
        } else {
            this.ui.buttons['btNew'].enabled = false;
            this.ui.buttons['btNew'].toolTip = Global.ln.get('tooltip-movie-nolevel');
        }
        if (GlobalPlayer.movie.mvId != '') {
            this.ui.buttons['btRemove'].toolTip = Global.ln.get('tooltip-movie-remove');
            this.ui.buttons['btRemove'].enabled = false;
            if (Global.mvOwner) {
                this.ui.buttons['btProperties'].enabled = true;
                this.ui.buttons['btUsers'].enabled = true;
                this.ui.buttons['btProperties'].toolTip = null;
                this.ui.buttons['btUsers'].toolTip = null;
            } else {
                this.ui.buttons['btProperties'].enabled = false;
                this.ui.buttons['btUsers'].enabled = false;
                this.ui.buttons['btProperties'].toolTip = Global.ln.get('tooltip-movie-noowner');
                this.ui.buttons['btUsers'].toolTip = Global.ln.get('tooltip-movie-noowner');
            }
        } else {
            if (Global.ws.level <= 50) {
                this.ui.buttons['btRemove'].enabled = true;
                this.ui.buttons['btRemove'].toolTip = null;
            } else {
                this.ui.buttons['btRemove'].enabled = false;
                this.ui.buttons['btRemove'].toolTip = Global.ln.get('tooltip-movie-nolevel');
            }
            this.ui.buttons['btProperties'].enabled = false;
            this.ui.buttons['btUsers'].enabled = false;
            this.ui.buttons['btProperties'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btUsers'].toolTip = Global.ln.get('tooltip-movie-nomovie');
        }
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
        Shows the movie removal window.
    **/
    private  function onRemove(evt:TriggerEvent):Void {
        this._ac('remove');
    }

}