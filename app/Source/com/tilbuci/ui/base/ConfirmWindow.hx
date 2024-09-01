package com.tilbuci.ui.base;

/** FEATHERS UI **/
import feathers.events.TriggerEvent;
import feathers.controls.Label;
import feathers.controls.Header;
import feathers.layout.VerticalLayout;
import feathers.controls.Button;
import feathers.controls.Panel;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.base.BackgroundSkin;

class ConfirmWindow extends Panel {

    /**
        warn mode: just ok button
    **/
    public static inline var MODEWARN:String = 'warn';

    /**
        confirm mode: ok/cancel buttons
    **/
    public static inline var MODECONFIRM:String = 'confirm';

    /**
        ok button
    **/
    private var _btOk:Button;

    /**
        cancel button
    **/
    private var _btCancel:Button;

    /**
        button click action
    **/
    private var _ac:Dynamic;

    /**
        Constructor.
        @param  tit popup title
        @param  txt popup text 
        @param  wd  popup width
        @param  ht  popup height
        @param  oktxt   ok button text
        @param  ac  action to call on button click (receives a single bool parameter)
        @param  mode    the window mode (just warning or confirm)
        @param  canceltxt   cancel button text
    **/
    public function new(tit:String, txt:String, wd:Int, ht:Int, oktxt:String, ac:Dynamic = null, mode:String = 'warn', canceltxt:String = '') {
        super();

        var lay:VerticalLayout = new VerticalLayout();
        lay.setPadding(10);
        lay.gap = 20;
        lay.verticalAlign = TOP;
        lay.horizontalAlign = LEFT;
        this.backgroundSkin = new BackgroundSkin(0x383838);
        this.layout = lay;
        this.width = wd;
        this.height = ht;

        var hd:Header = new Header();
        hd.text = tit;
        this.header = hd;

        var lb:Label = new Label();
        lb.text = txt;
        lb.wordWrap = true;
        lb.width = wd - 30;
        this.addChild(lb);
        
        this._btOk = new Button();
        this._btOk.text = oktxt;
        this._btOk.addEventListener(TriggerEvent.TRIGGER, onBtOk);
        this._btOk.width = lb.width;
        this.addChild(this._btOk);
        
        this._ac = ac;

        this._btCancel = new Button();
        this._btCancel.text = canceltxt;
        this._btCancel.addEventListener(TriggerEvent.TRIGGER, onBtCancel);
        this._btCancel.width = lb.width;
        if (mode == ConfirmWindow.MODECONFIRM) this.addChild(this._btCancel);
    }

    /**
        Click on OK button.
    **/
    private function onBtOk(evt:TriggerEvent):Void {
        this._btOk.removeEventListener(TriggerEvent.TRIGGER, onBtOk);
        this._btCancel.removeEventListener(TriggerEvent.TRIGGER, onBtCancel);
        this._btOk = null;
        this._btCancel = null;
        this.removeChildren();
        PopUpManager.removePopUp(this);
        if (this._ac != null) this._ac(true);
        this._ac = null;
    }

    /**
        Click on CANCEL button.
    **/
    private function onBtCancel(evt:TriggerEvent):Void {
        this._btOk.removeEventListener(TriggerEvent.TRIGGER, onBtOk);
        this._btCancel.removeEventListener(TriggerEvent.TRIGGER, onBtCancel);
        this._btOk = null;
        this._btCancel = null;
        this.removeChildren();
        PopUpManager.removePopUp(this);
        if (this._ac != null) this._ac(false);
        this._ac = null;
    }

}