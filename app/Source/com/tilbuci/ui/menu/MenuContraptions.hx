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
        this.addButton('btMenus', Global.ln.get('menu-contraptions-menus'), onMenus);
        this.addButton('btDialogues', Global.ln.get('menu-contraptions-dialogues'), onDialogues);
    }

    /**
        The menu was just open.
    **/
    override public function onShow():Void {
        super.onShow();
        if (GlobalPlayer.movie.mvId == '') {
            this.ui.buttons['btMenus'].enabled = false;
            this.ui.buttons['btMenus'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btDialogues'].enabled = false;
            this.ui.buttons['btDialogues'].toolTip = Global.ln.get('tooltip-movie-nomovie');
        } else {
            this.ui.buttons['btMenus'].enabled = true;
            this.ui.buttons['btMenus'].toolTip = null;
            this.ui.buttons['btDialogues'].enabled = true;
            this.ui.buttons['btDialogues'].toolTip = null;
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
        Dialogues
    **/
    private  function onDialogues(evt:TriggerEvent):Void {
        this._ac('dialogues');
    }

}