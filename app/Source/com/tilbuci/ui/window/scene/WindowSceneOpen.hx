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

class WindowSceneOpen extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-sceneopen-title'), 800, 430, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-sceneopen-title'), this.ui.forge('window', [
            { tp: 'Label', id: 'openabout', tx: Global.ln.get('window-sceneopen-wait') }, 
            { tp: 'List', id: 'openlist', vl: [ ], ht: 295, sl: null }, 
            { tp: 'Button', id: 'okbutton', tx: Global.ln.get('window-sceneopen-button'), ac: this.onOpen }
        ]));
        super.startInterface();
        this.ui.listDbClick('openlist', onOpen);
        this.ui.setListToIcon('openlist');
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        this.loadScenes();
    }

    /**
        Loas the scenes list.
    **/
    public function loadScenes():Void {
        this.ui.labels['openabout'].text = Global.ln.get('window-sceneopen-wait');
        this.ui.setListValues('openlist', [ ]);
        Global.ws.send('Scene/List', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
    }

    /**
        The scenes list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.labels['openabout'].text = Global.ln.get('window-sceneopen-error');
        } else{
            if (ld.map['e'] == 0) {
                var ar:Array<Dynamic> = cast ld.map['list'];
                if (ar.length == 0) {
                    this.ui.labels['openabout'].text = Global.ln.get('window-sceneopen-noscenes');
                } else {
                    var items:Array<Dynamic> = [ ];
                    for (i in ar) {
                        if (Reflect.field(i, 'lock') == '') {
                            items.push({text: Reflect.field(i, 'title'), value: Reflect.field(i, 'id'), asset: '', user: null });
                        } else {
                            items.push({text: Reflect.field(i, 'title'), value: Reflect.field(i, 'id'), asset: 'btLock', user: Reflect.field(i, 'lock') });
                        }
                    }
                    this.ui.setListValues('openlist', items);
                    this.ui.labels['openabout'].text = Global.ln.get('window-sceneopen-about');
                }
            } else {
                this.ui.labels['openabout'].text = Global.ln.get('window-sceneopen-error');
            }
        }
    }

    /**
        Opens the selected scene.
    **/
    private function onOpen(evt:TriggerEvent = null):Void {
        if (this.ui.lists['openlist'].selectedItem != null) {
            if ((this.ui.lists['openlist'].selectedItem.user == null) || (this.ui.lists['openlist'].selectedItem.user == '')) {
                GlobalPlayer.area.imgSelect();
                this._ac('sceneload', ['id' => this.ui.lists['openlist'].selectedItem.value, 'movie' => GlobalPlayer.movie.mvId]);
                PopUpManager.removePopUp(this);
            } else {
                Global.showMsg(Global.ln.get('window-sceneopen-locked'));
            }
        }
    }

}