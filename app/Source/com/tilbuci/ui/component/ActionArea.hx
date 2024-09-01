package com.tilbuci.ui.component;

/** FEATHERS UI **/
import com.tilbuci.ui.base.BackgroundSkin;
import feathers.layout.VerticalLayout;
import feathers.events.TriggerEvent;
import com.tilbuci.ui.base.HInterfaceContainer;
import feathers.controls.ScrollContainer;
import openfl.Assets;
import com.tilbuci.data.Global;

class ActionArea extends ScrollContainer {

    /**
        action script area
    **/
    private var _code:CodeArea;

    /**
        buttons interface
    **/
    private var _buttons:HInterfaceContainer;

    //private var _btCopy:IDButton;

    //private var _btScene:IDButton;

    public function new(wd:Float = 760, ht:Float = 250) {
        super();

        var lay:VerticalLayout = new VerticalLayout();
        lay.gap = 5;
        lay.setPadding(0);
        this.layout = lay;

        this.backgroundSkin =new BackgroundSkin();

        this._code = new CodeArea('js');
        this._code.width = wd;
        this._code.height = ht - 35;
        this.addChild(this._code);
        this._buttons = new HInterfaceContainer();
        this._buttons.width = wd;
        this._buttons.addChild(new IDButton('copy', onCopy, null, Assets.getBitmapData('btCopy')));
        this._buttons.addChild(new IDButton('scene', onScene, null, Assets.getBitmapData('btMovieScene')));
        this._buttons.addChild(new IDButton('instance', onInstance, null, Assets.getBitmapData('btMedia')));
        this._buttons.addChild(new IDButton('variables', onVariables, null, Assets.getBitmapData('btVariables')));
        this._buttons.addChild(new IDButton('data', onData, null, Assets.getBitmapData('btData')));
        this._buttons.addChild(new IDButton('plus', onPlus, null, Assets.getBitmapData('btPlus')));
        this._buttons.addChild(new IDButton('plugin', onPlugin, null, Assets.getBitmapData('btPlugin')));
        this.addChild(this._buttons);

    }

    /**
        Sets the action text.
        @param  txt action text
    **/
    public function setText(txt:String):Void {
        this._code.text = txt;
    }

    /**
        Retrieves the action text.
        @return the current text
    **/
    public function getText():String {
        return (this._code.text);
    }

    /**
        Copies the action script.
    **/
    private function onCopy(evt:TriggerEvent = null):Void {
        Global.copyText(this._code.text);
    }

    /**
        Opens the variable actions assistant.
    **/
    private function onVariables(evt:TriggerEvent = null):Void {
        Global.showWindow('assistantvariables');
    }

    /**
        Opens the scene and movie actions assistant.
    **/
    private function onScene(evt:TriggerEvent = null):Void {
        Global.showWindow('assistantscene');
    }

    /**
        Opens the instances actions assistant.
    **/
    private function onInstance(evt:TriggerEvent = null):Void {
        Global.showWindow('assistantinstance');
    }

    /**
        Opens the data actions assistant.
    **/
    private function onData(evt:TriggerEvent = null):Void {
        Global.showWindow('assistantdata');
    }

    /**
        Opens the plus actions assistant.
    **/
    private function onPlus(evt:TriggerEvent = null):Void {
        Global.showWindow('assistantplus');
    }

    /**
        Opens the plugin actions assistant.
    **/
    private function onPlugin(evt:TriggerEvent = null):Void {
        Global.showWindow('assistantplugin');
    }

}