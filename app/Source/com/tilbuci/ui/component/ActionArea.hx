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
        visual blocks area
    **/
    private var _block:BlockArea;

    /**
        buttons interface
    **/
    private var _buttons:HInterfaceContainer;

    /**
        block buttons interface
    **/
    private var _blockbuttons:HInterfaceContainer;

    /**
        assist buttons
    **/
    private var _idbuttons:Map<String, IDButton> = [ ];

    /**
        using code mode?
    **/
    private var _codemode:Bool = false;

    public function new(wd:Float = 760, ht:Float = 250, blonly:Bool = false) {
        super();

        var lay:VerticalLayout = new VerticalLayout();
        lay.gap = 5;
        lay.setPadding(0);
        this.layout = lay;

        this.backgroundSkin =new BackgroundSkin();

        this._code = new CodeArea('js');
        this._code.width = wd;
        this._code.height = ht - 35;
        
        this._block = new BlockArea(this._code);
        this._block.width = wd;
        this._block.height = ht - 35;
        this.addChild(this._block);

        this._buttons = new HInterfaceContainer();
        this._buttons.width = wd;

        this._idbuttons['switch'] = new IDButton('switch', onSwitch, null, Assets.getBitmapData('btBlocks'));
        this._idbuttons['copy'] = new IDButton('copy', onCopy, null, Assets.getBitmapData('btCopy'));
        this._idbuttons['scene'] = new IDButton('scene', onScene, null, Assets.getBitmapData('btMovieScene'));
        this._idbuttons['instance'] = new IDButton('instance', onInstance, null, Assets.getBitmapData('btMedia'));
        this._idbuttons['variables'] = new IDButton('variables', onVariables, null, Assets.getBitmapData('btVariables'));
        this._idbuttons['data'] = new IDButton('data', onData, null, Assets.getBitmapData('btData'));
        this._idbuttons['plus'] = new IDButton('plus', onPlus, null, Assets.getBitmapData('btPlus'));
        this._idbuttons['plugin'] = new IDButton('plugin', onPlugin, null, Assets.getBitmapData('btPlugin'));

        this._buttons.addChild(this._idbuttons['switch']);
        this._buttons.addChild(this._idbuttons['copy']);
        this._buttons.addChild(this._idbuttons['scene']);
        this._buttons.addChild(this._idbuttons['instance']);
        this._buttons.addChild(this._idbuttons['variables']);
        this._buttons.addChild(this._idbuttons['data']);
        this._buttons.addChild(this._idbuttons['plus']);
        this._buttons.addChild(this._idbuttons['plugin']);
        //this.addChild(this._buttons);

        this._idbuttons['switch'].toolTip = Global.ln.get('tooltip-action-switch');
        this._idbuttons['copy'].toolTip = Global.ln.get('tooltip-action-copy');
        this._idbuttons['scene'].toolTip = Global.ln.get('tooltip-action-scene');
        this._idbuttons['instance'].toolTip = Global.ln.get('tooltip-action-instance');
        this._idbuttons['variables'].toolTip = Global.ln.get('tooltip-action-variables');
        this._idbuttons['data'].toolTip = Global.ln.get('tooltip-action-data');
        this._idbuttons['plus'].toolTip = Global.ln.get('tooltip-action-plus');
        this._idbuttons['plugin'].toolTip = Global.ln.get('tooltip-action-plugin');

        this._blockbuttons = new HInterfaceContainer();
        this._blockbuttons.width = wd;

        this._idbuttons['blswitch'] = new IDButton('blswitch', onSwitch, null, Assets.getBitmapData('btCode'));
        this._idbuttons['bldel'] = new IDButton('bldel', onDel, null, Assets.getBitmapData('btDel'));
        this._idbuttons['bledit'] = new IDButton('bledit', onEdit, null, Assets.getBitmapData('btEdit'));
        this._idbuttons['blopen'] = new IDButton('blopen', onOpen, null, Assets.getBitmapData('btExpand'));
        this._idbuttons['blclose'] = new IDButton('blclose', onClose, null, Assets.getBitmapData('btCompress'));
        this._idbuttons['blup'] = new IDButton('blup', onUp, null, Assets.getBitmapData('btUp'));
        this._idbuttons['bldown'] = new IDButton('bldown', onDown, null, Assets.getBitmapData('btDown'));

        this._idbuttons['blswitch'].toolTip = Global.ln.get('tooltip-action-switch');
        this._idbuttons['bldel'].toolTip = Global.ln.get('tooltip-action-bldel');
        this._idbuttons['bledit'].toolTip = Global.ln.get('tooltip-action-bledit');
        this._idbuttons['blopen'].toolTip = Global.ln.get('tooltip-action-blopen');
        this._idbuttons['blclose'].toolTip = Global.ln.get('tooltip-action-blclose');
        this._idbuttons['blup'].toolTip = Global.ln.get('tooltip-action-blup');
        this._idbuttons['bldown'].toolTip = Global.ln.get('tooltip-action-bldown');

        if (!blonly) this._blockbuttons.addChild(this._idbuttons['blswitch']);
        this._blockbuttons.addChild(this._idbuttons['bldel']);
        this._blockbuttons.addChild(this._idbuttons['bledit']);
        this._blockbuttons.addChild(this._idbuttons['blopen']);
        this._blockbuttons.addChild(this._idbuttons['blclose']);
        this._blockbuttons.addChild(this._idbuttons['blup']);
        this._blockbuttons.addChild(this._idbuttons['bldown']);
        this.addChild(this._blockbuttons);
    }

    /**
        Sets the action text.
        @param  txt action text
    **/
    public function setText(txt:String):Void {
        this._code.text = txt;
        this._block.refresh();
    }

    /**
        Retrieves the action text.
        @return the current text
    **/
    public function getText():String {
        if (this._codemode) {
            return (this._code.text);
        } else {
            return (this._block.toJson());
        }
    }

    /**
        Switches the input mode.
    **/
    private function onSwitch(evt:TriggerEvent = null):Void {
        this._codemode = !this._codemode;
        this.removeChildren();
        if (!this._codemode) {
            if (!this._block.refresh()) {
                this._codemode = true;
                this._block.clear();
                this.addChild(this._code);
                this.addChild(this._buttons);
                Global.showPopup(Global.ln.get('window-actions-title'), Global.ln.get('window-actions-error'), 300, 180, Global.ln.get('default-ok'));
            } else {
                this.addChild(this._block);
                this.addChild(this._blockbuttons);
            }
        } else {
            this._code.text = this._block.toJson();
            this._block.clear();
            this.addChild(this._code);
            this.addChild(this._buttons);
        }
    }

    /**
        Copies the action script.
    **/
    private function onCopy(evt:TriggerEvent = null):Void {
        if (!this._codemode) {
            Global.copyText(this._block.toJson());
        } else {
            Global.copyText(this._code.text);
        }
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

    /**
        Opens a block display.
    **/
    private function onOpen(evt:TriggerEvent = null):Void {
        this._block.openAll();
    }

    /**
        Closes a block display.
    **/
    private function onClose(evt:TriggerEvent = null):Void {
        this._block.closeAll();
    }

    /**
        Moves a block up.
    **/
    private function onUp(evt:TriggerEvent = null):Void {
        this._block.upAction();
    }

    /**
        Moves a block down.
    **/
    private function onDown(evt:TriggerEvent = null):Void {
        this._block.downAction();
    }

    /**
       Adjusts a block. 
    **/
    private function onEdit(evt:TriggerEvent = null):Void {
        this._block.editAction();
    }

    /**
        Removes a block.
    **/
    private function onDel(evt:TriggerEvent = null):Void {
        this._block.removeAction();
    }

}