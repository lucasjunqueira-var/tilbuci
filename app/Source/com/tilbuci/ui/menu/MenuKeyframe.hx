package com.tilbuci.ui.menu;

/** FEATHERS UI **/
import com.tilbuci.data.GlobalPlayer;
import feathers.controls.Button;
import feathers.events.TriggerEvent;

/** TILBUCI **/
import com.tilbuci.ui.menu.DrawerMenu;
import com.tilbuci.data.Global;

class MenuKeyframe extends DrawerMenu {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        super(ac, Global.ln.get('menu-keyframe-title'));
        this.addButton('btAdd', Global.ln.get('menu-keyframe-add'), onAdd);
        this.addButton('btRemove', Global.ln.get('menu-keyframe-remove'), onRemove);
        this.addButton('btManage', Global.ln.get('menu-keyframe-manage'), onManage);
    }

    /**
        The menu was just open.
    **/
    override public function onShow():Void {
        super.onShow();
        if ((GlobalPlayer.movie.mvId == '') || (GlobalPlayer.movie.scId == '')) {
            this.ui.buttons['btAdd'].enabled = false;
            this.ui.buttons['btRemove'].enabled = false;
            this.ui.buttons['btManage'].enabled = false;
        } else {
            this.ui.buttons['btAdd'].enabled = true;
            this.ui.buttons['btRemove'].enabled = true;
            this.ui.buttons['btManage'].enabled = true;
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Adds a keyframe.
    **/
    private  function onAdd(evt:TriggerEvent):Void {
        this._ac('add');
    }

    /**
        Removes the current keyframe.
    **/
    private  function onRemove(evt:TriggerEvent):Void {
        this._ac('remove');
    }

    /**
        Manages keyframes.
    **/
    private  function onManage(evt:TriggerEvent):Void {
        this._ac('manage');
    }

}