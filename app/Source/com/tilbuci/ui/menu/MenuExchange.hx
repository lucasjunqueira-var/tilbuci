package com.tilbuci.ui.menu;

/** FEATHERS UI **/
import feathers.text.TextFormat;
import com.tilbuci.data.GlobalPlayer;
import feathers.events.TriggerEvent;

/** TILBUCI **/
import com.tilbuci.ui.menu.DrawerMenu;
import com.tilbuci.data.Global;

class MenuExchange extends DrawerMenu {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        super(ac, Global.ln.get('menu-exhange-title'));
        this.addButton('btExport', Global.ln.get('menu-exchange-export'), onExport);
        this.addButton('btWebsite', Global.ln.get('menu-exchange-site'), onWebsite);
        this.addButton('btPwa', Global.ln.get('menu-exchange-pwa'), onPwa);
        this.addButton('btPublish', Global.ln.get('menu-exchange-publish'), onPublish);
        this.addButton('btDesktop', Global.ln.get('menu-exchange-desktop'), onDesktop);
        this.addButton('btCordova', Global.ln.get('menu-exchange-cordova'), onCordova);
        this.addButton('btImport', Global.ln.get('menu-exchange-import'), onImport);
    }

    /**
        The menu was just open.
    **/
    override public function onShow():Void {
        super.onShow();
        this.ui.buttons['btExport'].enabled = ((GlobalPlayer.movie.mvId != '') && (Global.mvOwner));
        this.ui.buttons['btWebsite'].enabled = ((GlobalPlayer.movie.mvId != '') && (Global.mvOwner));
        this.ui.buttons['btPwa'].enabled = ((GlobalPlayer.movie.mvId != '') && (Global.mvOwner));
        this.ui.buttons['btPublish'].enabled = ((GlobalPlayer.movie.mvId != '') && (Global.mvOwner));
        this.ui.buttons['btDesktop'].enabled = ((GlobalPlayer.movie.mvId != '') && (Global.mvOwner));
        this.ui.buttons['btCordova'].enabled = ((GlobalPlayer.movie.mvId != '') && (Global.mvOwner));
        this.ui.buttons['btImport'].enabled = Global.ws.level <= 50;
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Export current movie.
    **/
    private  function onExport(evt:TriggerEvent):Void {
        this._ac('export');
    }

    /**
        Export current movie as a website.
    **/
    private  function onWebsite(evt:TriggerEvent):Void {
        this._ac('website');
    }

    /**
        Export current movie as a pwa app.
    **/
    private  function onPwa(evt:TriggerEvent):Void {
        this._ac('pwa');
    }

    /**
        Export current movie for publish services.
    **/
    private  function onPublish(evt:TriggerEvent):Void {
        this._ac('publish');
    }

    /**
        Export current movie as desktop app.
    **/
    private  function onDesktop(evt:TriggerEvent):Void {
        this._ac('desktop');
    }

    /**
        Export current movie as an Apache Cordova project.
    **/
    private  function onCordova(evt:TriggerEvent):Void {
        this._ac('cordova');
    }

    /**
       Import a movie.
    **/
    private  function onImport(evt:TriggerEvent):Void {
        this._ac('import');
    }

}