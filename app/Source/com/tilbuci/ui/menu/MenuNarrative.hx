package com.tilbuci.ui.menu;

/** FEATHERS UI **/
import com.tilbuci.data.GlobalPlayer;
import feathers.controls.Button;
import feathers.events.TriggerEvent;

/** TILBUCI **/
import com.tilbuci.ui.menu.DrawerMenu;
import com.tilbuci.data.Global;

class MenuNarrative extends DrawerMenu {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        super(ac, Global.ln.get('menu-narrative-title'));
        this.addButton('btChar', Global.ln.get('menu-narrative-characters'), onChar);
        this.addButton('btDiag', Global.ln.get('menu-narrative-dialogues'), onDiag);
        this.addButton('btDflow', Global.ln.get('menu-narrative-dflow'), onDflow);
    }

    /**
        The menu was just open.
    **/
    override public function onShow():Void {
        super.onShow();
        if ((GlobalPlayer.movie.mvId == '') || (Global.ws.level > 50))  {
            this.ui.buttons['btChar'].enabled = false;
            this.ui.buttons['btChar'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
            this.ui.buttons['btDiag'].enabled = false;
            this.ui.buttons['btDiag'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
            this.ui.buttons['btDflow'].enabled = false;
            this.ui.buttons['btDflow'].toolTip = Global.ln.get('tooltip-movie-nomovieaccess');
        } else {
            this.ui.buttons['btChar'].enabled = true;
            this.ui.buttons['btChar'].toolTip = null;
            this.ui.buttons['btDiag'].enabled = true;
            this.ui.buttons['btDiag'].toolTip = null;
            this.ui.buttons['btDflow'].enabled = true;
            this.ui.buttons['btDflow'].toolTip = null;
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Characters
    **/
    private  function onChar(evt:TriggerEvent):Void {
        this._ac('char');
    }

    /**
        Dialogues
    **/
    private  function onDiag(evt:TriggerEvent):Void {
        this._ac('diag');
    }

    /**
        Decision flow
    **/
    private  function onDflow(evt:TriggerEvent):Void {
        this._ac('dflow');
    }

}