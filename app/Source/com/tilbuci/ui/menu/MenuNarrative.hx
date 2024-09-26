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
        this.addButton('btprotagonists', Global.ln.get('menu-narrative-protagonists'), onprotagonists);
        this.addButton('btcharacters', Global.ln.get('menu-narrative-characters'), oncharacters);
        this.addButton('btdialogues', Global.ln.get('menu-narrative-dialogues'), ondialogues);
        this.addButton('btfoes', Global.ln.get('menu-narrative-foes'), onfoes);
        this.addButton('btinventory', Global.ln.get('menu-narrative-inventory'), oninventory);
        this.addButton('btskills', Global.ln.get('menu-narrative-skills'), onskills);
    }

    /**
        The menu was just open.
    **/
    override public function onShow():Void {
        super.onShow();
        if (GlobalPlayer.movie.mvId == '') {
            this.ui.buttons['btprotagonists'].enabled = false;
            this.ui.buttons['btprotagonists'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btcharacters'].enabled = false;
            this.ui.buttons['btcharacters'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btdialogues'].enabled = false;
            this.ui.buttons['btdialogues'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btfoes'].enabled = false;
            this.ui.buttons['btfoes'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btinventory'].enabled = false;
            this.ui.buttons['btinventory'].toolTip = Global.ln.get('tooltip-movie-nomovie');
            this.ui.buttons['btskills'].enabled = false;
            this.ui.buttons['btskills'].toolTip = Global.ln.get('tooltip-movie-nomovie');
        } else {
            this.ui.buttons['btprotagonists'].enabled = true;
            this.ui.buttons['btprotagonists'].toolTip = null;
            this.ui.buttons['btcharacters'].enabled = true;
            this.ui.buttons['btcharacters'].toolTip = null;
            this.ui.buttons['btdialogues'].enabled = true;
            this.ui.buttons['btdialogues'].toolTip = null;
            this.ui.buttons['btfoes'].enabled = true;
            this.ui.buttons['btfoes'].toolTip = null;
            this.ui.buttons['btinventory'].enabled = true;
            this.ui.buttons['btinventory'].toolTip = null;
            this.ui.buttons['btskills'].enabled = true;
            this.ui.buttons['btskills'].toolTip = null;
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        protagonists
    **/
    private  function onprotagonists(evt:TriggerEvent):Void {
        this._ac('protagonists');
    }

    /**
        characters
    **/
    private  function oncharacters(evt:TriggerEvent):Void {
        this._ac('characters');
    }

    /**
        dialogues
    **/
    private  function ondialogues(evt:TriggerEvent):Void {
        this._ac('dialogues');
    }

    /**
        foes
    **/
    private  function onfoes(evt:TriggerEvent):Void {
        this._ac('foes');
    }

    /**
        inventory
    **/
    private  function oninventory(evt:TriggerEvent):Void {
        this._ac('inventory');
    }

    /**
        skills
    **/
    private  function onskills(evt:TriggerEvent):Void {
        this._ac('skills');
    }

}