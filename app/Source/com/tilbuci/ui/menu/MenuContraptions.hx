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
        this.addButton('btMenus', Global.ln.get('menu-contraptions-menus'), onMenus);
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
        } else {
            this.ui.buttons['btMenus'].enabled = true;
            this.ui.buttons['btMenus'].toolTip = null;
            this.ui.buttons['btCover'].enabled = true;
            this.ui.buttons['btCover'].toolTip = null;
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

}