package com.tilbuci.ui.menu;

/** FEATHERS UI **/
import com.tilbuci.data.GlobalPlayer;
import feathers.controls.Button;
import feathers.events.TriggerEvent;
import openfl.net.URLRequest;
import openfl.Lib;

/** TILBUCI **/
import com.tilbuci.ui.menu.DrawerMenu;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;

class MenuScene extends DrawerMenu {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        super(ac, Global.ln.get('menu-scene-title'));
        this.addButton('btNew', Global.ln.get('menu-scene-new'), onNew);
        this.addButton('btOpen', Global.ln.get('menu-scene-open'), onOpen);
        this.addButton('btProperties', Global.ln.get('menu-scene-properties'), onProp);
        this.addButton('btDflow', Global.ln.get('menu-scene-dflow'), onDflow);
        this.addButton('btSave', Global.ln.get('menu-scene-save'), onSave);
        this.addButton('btSaveAs', Global.ln.get('menu-scene-saveas'), onSaveAs);
        this.addButton('btPublish', Global.ln.get('menu-scene-publish'), onPublish);
        this.addButton('btVersions', Global.ln.get('menu-scene-versions'), onVersions);
        this.addButton('btPlayer', Global.ln.get('menu-scene-player'), onPlayer);
    }

    /**
        The menu was just open.
    **/
    override public function onShow():Void {
        super.onShow();
        if (GlobalPlayer.movie.mvId == '') {
            this.ui.buttons['btNew'].enabled = false;
            this.ui.buttons['btOpen'].enabled = false;
            this.ui.buttons['btProperties'].enabled = false;
            this.ui.buttons['btDflow'].enabled = false;
            this.ui.buttons['btSave'].enabled = false;
            this.ui.buttons['btSaveAs'].enabled = false;
            this.ui.buttons['btPublish'].enabled = false;
            this.ui.buttons['btVersions'].enabled = false;
            this.ui.buttons['btPlayer'].enabled = false;
            for (b in this.ui.buttons) {
                b.toolTip = Global.ln.get('tooltip-movie-nomovie');
            }
        } else {
            this.ui.buttons['btNew'].enabled = true;
            this.ui.buttons['btOpen'].enabled = true;
            this.ui.buttons['btNew'].toolTip = null;
            this.ui.buttons['btOpen'].toolTip = null;
            if (GlobalPlayer.movie.scId == '') {
                this.ui.buttons['btProperties'].enabled = false;
                this.ui.buttons['btDflow'].enabled = false;
                this.ui.buttons['btSave'].enabled = false;
                this.ui.buttons['btSaveAs'].enabled = false;
                this.ui.buttons['btPublish'].enabled = false;
                this.ui.buttons['btVersions'].enabled = false;
                this.ui.buttons['btPlayer'].enabled = false;
                this.ui.buttons['btProperties'].toolTip = Global.ln.get('tooltip-movie-noscene');
                this.ui.buttons['btDflow'].toolTip = Global.ln.get('tooltip-movie-noscene');
                this.ui.buttons['btSave'].toolTip = Global.ln.get('tooltip-movie-noscene');
                this.ui.buttons['btSaveAs'].toolTip = Global.ln.get('tooltip-movie-noscene');
                this.ui.buttons['btPublish'].toolTip = Global.ln.get('tooltip-movie-noscene');
                this.ui.buttons['btVersions'].toolTip = Global.ln.get('tooltip-movie-noscene');
                this.ui.buttons['btPlayer'].toolTip = Global.ln.get('tooltip-movie-noscene');
            } else {
                this.ui.buttons['btProperties'].enabled = true;
                this.ui.buttons['btDflow'].enabled = true;
                this.ui.buttons['btSave'].enabled = true;
                this.ui.buttons['btSaveAs'].enabled = true;
                this.ui.buttons['btPublish'].enabled = true;
                this.ui.buttons['btVersions'].enabled = true;
                this.ui.buttons['btPlayer'].enabled = true;
                this.ui.buttons['btProperties'].toolTip = null;
                this.ui.buttons['btDflow'].toolTip = null;
                this.ui.buttons['btSave'].toolTip = null;
                this.ui.buttons['btSaveAs'].toolTip = null;
                this.ui.buttons['btPublish'].toolTip = null;
                this.ui.buttons['btVersions'].toolTip = null;
                this.ui.buttons['btPlayer'].toolTip = null;
            }
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
        Saves the current scene.
    **/
    private  function onSave(evt:TriggerEvent):Void {
        this._ac('save');
    }

    /**
        Saves the current scene with another ID.
    **/
    private  function onSaveAs(evt:TriggerEvent):Void {
        this._ac('saveas');
    }

    /**
        Saves the current an published it.
    **/
    private  function onPublish(evt:TriggerEvent):Void {
        this._ac('publish');
    }

    /**
        Opens version select window.
    **/
    private  function onVersions(evt:TriggerEvent):Void {
        this._ac('version');
    }

    /**
        Shows the properties window.
    **/
    private  function onProp(evt:TriggerEvent):Void {
        this._ac('prop');
    }

    /**
        Shows the decision flow window.
    **/
    private  function onDflow(evt:TriggerEvent):Void {
        this._ac('dflow');
    }

    /**
        Shows the movie users manager.
    **/
    private  function onUsers(evt:TriggerEvent):Void {
        this._ac('users');
    }

    /**
        Opens the published version on player.
    **/
    private  function onPlayer(evt:TriggerEvent):Void {
        var request:URLRequest = new URLRequest(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId + '&sc=' + GlobalPlayer.movie.scId);
        request.method = 'GET';
        Lib.getURL(request);
    }

}