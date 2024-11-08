package com.tilbuci.ui.window.scene;

/** OPENFL **/
import com.tilbuci.data.GlobalPlayer;
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

class WindowSceneSaveas extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-scenesaveas-title'), 800, 200, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-scenesaveas-title'), this.ui.forge('leftcol', [
            { tp: 'Label', id: 'scenename', tx: Global.ln.get('window-scenesaveas-name'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'scenename', tx: '', vr: '' },  
            //{ tp: 'Label', id: 'sceneid', tx: Global.ln.get('window-scenesaveas-id'), vr: Label.VARIANT_DETAIL }, 
            //{ tp: 'TInput', id: 'sceneid', tx: '', vr: '' },  
            { tp: 'Spacer', id: 'scenenew', ht: 20 },  
            { tp: 'Button', id: 'scenecreate', tx: Global.ln.get('window-scenesaveas-create'), ac: this.onSaveScene }
            
        ]));
        super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        this.ui.inputs['scenename'].text = GlobalPlayer.movie.scene.title;
        //this.ui.inputs['sceneid'].text = '';
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Saves the current scene.
    **/
    private function onSaveScene(evt:TriggerEvent):Void {
        if (this.ui.inputs['scenename'].text == '') {
            this.ui.createWarning(Global.ln.get('window-scenesaveas-title'), Global.ln.get('window-scenesaveas-norequired'), 300, 180, this.stage);
        } else {
            var cols:Dynamic = { };
            for (k in GlobalPlayer.movie.collections.keys()) Reflect.setField(cols, k, GlobalPlayer.movie.collections[k].toJson());
            Global.ws.send(
                'Scene/SaveAs', 
                [
                    'movie' => GlobalPlayer.movie.mvId, 
                    'id' => '', //this.ui.inputs['sceneid'].text, 
                    'scene' => GlobalPlayer.movie.scene.toJson(), 
                    'collections' => cols, 
                    'title' => this.ui.inputs['scenename'].text
                ], 
                onSaveReturn
            );
        }
    }

    /**
        Scene creation return.
    **/
    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-scenesaveas-title'), Global.ln.get('window-scenesaveas-createer'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-scenesaveas-title'), Global.ln.get('window-scenesaveas-createer'), 300, 180, this.stage);
        } else {
            //this.ui.inputs['scenename'].text = this.ui.inputs['sceneid'].text = '';
            Global.showMsg(Global.ln.get('window-scenesaveas-createok'));
            PopUpManager.removePopUp(this);
            this._ac('sceneload', [ 'id' => ld.map['id'] ]);
        }
    }

}