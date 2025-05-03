package com.tilbuci.ui.menu;

/** FEATHERS UI **/
import com.tilbuci.ui.window.WindowNotes.NoteItem;
import com.tilbuci.data.GlobalPlayer;
import feathers.controls.Button;
import feathers.events.TriggerEvent;
import openfl.Lib;
import openfl.net.URLRequest;

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
        this.addButton('btNavigation', Global.ln.get('menu-movie-navigation'), onNavigation);
        this.addButton('btRepublish', Global.ln.get('menu-movie-republish'), onRepublish);
        this.addButton('btNotes', Global.ln.get('menu-movie-notes'), onNotes);
        this.addButton('btPlayer', Global.ln.get('menu-movie-player'), onPlayer);
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
            this.ui.buttons['btPlayer'].enabled = true;
            this.ui.buttons['btPlayer'].toolTip = null;
            this.ui.buttons['btNavigation'].enabled = true;
            this.ui.buttons['btNavigation'].toolTip = null;
            this.ui.buttons['btNotes'].enabled = true;
            this.ui.buttons['btNotes'].toolTip = null;
            this.ui.buttons['btRepublish'].enabled = true;
            this.ui.buttons['btRepublish'].toolTip = null;
        } else {
            if (Global.ws.level <= 50) {
                this.ui.buttons['btRemove'].enabled = true;
                this.ui.buttons['btRemove'].toolTip = null;
            } else {
                this.ui.buttons['btRemove'].enabled = false;
                this.ui.buttons['btRemove'].toolTip = Global.ln.get('tooltip-movie-nolevel');
            }
            this.ui.buttons['btPlayer'].enabled = false;
            this.ui.buttons['btNavigation'].enabled = false;
            this.ui.buttons['btNotes'].enabled = false;
            this.ui.buttons['btProperties'].enabled = false;
            this.ui.buttons['btUsers'].enabled = false;
            this.ui.buttons['btRepublish'].enabled = false;
            this.ui.buttons['btProperties'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btUsers'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btPlayer'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btNavigation'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btNotes'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btRepublish'].toolTip = Global.ln.get('tooltip-movie-nomovie');
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

    /**
        Shows the navigation sequences window.
    **/
    private  function onNavigation(evt:TriggerEvent):Void {
        this._ac('navigation');
    }

    /**
        Shows the republish window.
    **/
    private  function onRepublish(evt:TriggerEvent):Void {
        this._ac('republish');
    }

    /**
        Shows the design notes window.
    **/
    private  function onNotes(evt:TriggerEvent):Void {
        this._ac('notes');
    }

    /**
        Opens the movie on player.
    **/
    private  function onPlayer(evt:TriggerEvent):Void {
        var request:URLRequest = new URLRequest(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId);
        request.method = 'GET';
        Lib.getURL(request);
    }

}