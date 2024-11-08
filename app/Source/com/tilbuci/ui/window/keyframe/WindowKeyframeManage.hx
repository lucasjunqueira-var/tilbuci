package com.tilbuci.ui.window.keyframe;

/** OPENFL **/
import openfl.events.Event;
import openfl.display.Stage;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;

class WindowKeyframeManage extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-kfmanage-title'), 1000, 510, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-kfmanage-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'keyframes', tx: Global.ln.get('window-kfmanage-keyframes'), vr: 'detail' }, 
                { tp: 'List', id: 'keyframes', vl: [ ], sl: null, ht: 332 }, 
                { tp: 'Button', id: 'actions', tx: Global.ln.get('window-kfmanage-actions'), ac: setActions }, 
                { tp: 'Button', id: 'add', tx: Global.ln.get('window-kfmanage-add'), ac: addKeyframe }, 
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-kfmanage-remove'), ac: remove }, 
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'instances', tx: Global.ln.get('window-kfmanage-instances'), vr: 'detail' }, 
                { tp: 'List', id: 'instances', vl: [ ], sl: null, ht: 390 },
                { tp: 'Button', id: 'removeinst', tx: Global.ln.get('window-kfmanage-instremove'), ac: removeInst }, 
            ])));
            super.startInterface();
            this.ui.listChange('keyframes', onKfChange);
            this.loadKfs();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        this.loadKfs();
    }

    /**
        Loads the current keyframes list.
    **/
    private function loadKfs():Void {
        var kfs = [ ];
        for (kf in 0...GlobalPlayer.movie.scene.keyframes.length) {
            kfs.push({
                text: Std.string(kf + 1), 
                value: kf
            });
        }
        this.ui.setListValues('keyframes', kfs);
        this.ui.setListValues('instances', [ ]);
    }

    /**
        New keyframe selected.
    **/
    private function onKfChange(evt:Event = null):Void {
        var insts = [ ];
        if (this.ui.lists['keyframes'].selectedItem != null) {
            for (k in GlobalPlayer.movie.scene.keyframes[this.ui.lists['keyframes'].selectedItem.value].keys()) {
                insts.push({ text: k, value: k });
            }
        }
        this.ui.setListValues('instances', insts);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Removes selected keyframe.
    **/
    private function remove(evt:Event = null): Void {
        if (this.ui.lists['keyframes'].selectedItem != null) {
            if (GlobalPlayer.movie.scene.keyframes.length > 1) {
                GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[this.ui.lists['keyframes'].selectedItem.value], this.ui.lists['keyframes'].selectedItem.value);
                this._ac('remove');
                this.loadKfs();
            } else {
                Global.showMsg(Global.ln.get('window-kfmanage-onlyone'));
            }
        }
    }

    /**
        Sets selected keyframe end actions.
    **/
    private function setActions(evt:Event = null): Void {
        if (this.ui.lists['keyframes'].selectedItem != null) {
            Global.showActionWindow(GlobalPlayer.movie.scene.ackeyframes[this.ui.lists['keyframes'].selectedItem.value], onNewAction);
        }
    }

    /**
        New actions text available.
        @param  newac   the new action text
    **/
    private function onNewAction(newac:String):Void {
        GlobalPlayer.movie.scene.ackeyframes[this.ui.lists['keyframes'].selectedItem.value] = newac;
    }

    /**
        Adds a keyframe.
    **/
    private function addKeyframe(evt:Event = null): Void {
        if (this.ui.lists['keyframes'].selectedItem != null) {
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[this.ui.lists['keyframes'].selectedItem.value], this.ui.lists['keyframes'].selectedItem.value);
            this._ac('add');
            this.loadKfs();
        }
    }

    /**
        Removes selected instance.
    **/
    private function removeInst(evt:Event = null): Void {
        if ((this.ui.lists['keyframes'].selectedItem != null) && (this.ui.lists['instances'].selectedItem != null)) {
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[this.ui.lists['keyframes'].selectedItem.value], this.ui.lists['keyframes'].selectedItem.value);
            GlobalPlayer.area.removeInstance(this.ui.lists['instances'].selectedItem.value);
            this.onKfChange();
            this._ac('reload');
        }
    }

}