package com.tilbuci.ui.component;


import com.tilbuci.statictools.StringStatic;
import openfl.Assets;
import openfl.display.Bitmap;
import com.tilbuci.display.InstanceImage;
import haxe.macro.Expr.Catch;
import haxe.Timer;
import feathers.layout.AnchorLayoutData;
import feathers.controls.ListView;
import feathers.data.ArrayCollection;
import openfl.events.Event;
import com.tilbuci.ui.base.HInterfaceContainer;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.Global;

class ActionPanel extends DropDownPanel {

    /**
        currently selected instance
    **/
    private var _current:InstanceImage = null;

    public function new(wd:Float) {
        super(Global.ln.get('rightbar-action'), wd);
        this._content = this.ui.forge('properties', [
            { tp: 'Button', id: 'trigget', tx: Global.ln.get('rightbar-action-trigger'), ac: setTrigger }, 
        ], 0x333333, (wd - 5));
        this.ui.containers['properties'].enabled = false;
        Global.history.propDisplay.push(this.updateValues);
    }

    override public function updateContent(data:Map<String, Dynamic> = null):Void {
        if (data.exists('nm')) {
            this._current = GlobalPlayer.area.instanceRef(data['nm']);
            this.updateValues();
        } else {
            this.clearValues();
        }
        
    }

    override public function reloadContent(data:Map<String, Dynamic> = null):Void {
        this.clearValues();
    }

    public function updateValues():Void {
        if (this._current != null) {
            this.ui.containers['properties'].enabled = true;
        }
    }

    private function clearValues():Void {
        this.ui.containers['properties'].enabled = false;
        this._current = null;
    }

    private function setTrigger(evt:Event = null):Void {
        Global.showActionWindow(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._current.getInstName()].action, onOk, onCancel);
    }

    private function onOk(newac:String):Void {
        if (Global.history.states.length == 0) Global.history.addState(Global.ln.get('rightbar-history-original'));
        GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][this._current.getInstName()].action = newac;
        Global.history.addState(Global.ln.get('rightbar-history-actrigger'));
    }

    private function onCancel():Void {
        // nothing to do
    }

}