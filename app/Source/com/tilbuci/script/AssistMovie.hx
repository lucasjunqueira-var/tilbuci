package com.tilbuci.script;

/** OPENFL **/
import openfl.events.Event;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.component.IDButton;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.DataLoader;

class AssistMovie extends PopupWindow {

    /**
        action buttons
    **/
    private var _idbuttons:Map<String, IDButton> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-acmovie-title'), 500, 550, false);
        this._idbuttons['btCopyId'] = new IDButton('copyid', onCopyId, Global.ln.get('window-acmovie-copyid'), Assets.getBitmapData('btCopy'));
        this._idbuttons['btCopyLoad'] = new IDButton('copyload', onCopyLoad, (Global.ln.get('window-acmovie-copyload') + '*'), Assets.getBitmapData('btCopy'));
        this.addForm(Global.ln.get('window-acmovie-title'), this.ui.forge('form', [
            { tp: "Label", id: 'list', tx: Global.ln.get('window-acmovie-list'), vr: '' }, 
            { tp: "List", id: 'list', vl: [ ], sl: [ ], ht: 340 }, 
            { tp: "Custom", cont: this._idbuttons['btCopyId'] }, 
            { tp: "Custom", cont: this._idbuttons['btCopyLoad'] }, 
            { tp: "Button", id: "close", tx: Global.ln.get('window-actions-close'), ac: onClose }, 
        ]));
        this.ui.listDbClick('list', onCopyLoad);
    }

    /**
        Window statup actions.
    **/
    override function acStart() {
        super.acStart();
        this.ui.setListValues('list', [ ]);
        this.ui.setListSelectValue('list', null);
        Global.ws.send('Movie/List', [ ], this.onList);
    }

    /**
        Interface initialize
    **/
    override function startInterface(evt:Event = null) {
        super.startInterface(evt);
        for (k in this._idbuttons.keys()) this._idbuttons[k].width = this.ui.buttons['close'].width;
    }

    /**
        Copies a scene ID.
    **/
    private function onCopyId(evt:TriggerEvent = null):Void {
        if (this.ui.lists['list'].selectedItem != null) {
            Global.copyText(this.ui.lists['list'].selectedItem.value);
            PopUpManager.removePopUp(this);
        }
    }

    /**
        Copies a scene load action.
    **/
    private function onCopyLoad(evt:TriggerEvent = null):Void {
        if (this.ui.lists['list'].selectedItem != null) {
            Global.copyText('{ "ac": "movie.load", "param": [ "' + this.ui.lists['list'].selectedItem.value + '" ] }');
            PopUpManager.removePopUp(this);
        }
    }

    /**
        Closes window.
    **/
    private function onClose(evt:TriggerEvent = null):Void {
        PopUpManager.removePopUp(this);
    }

    /**
        The list was just loaded.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 0) {
                for (n in Reflect.fields(ld.map['list'])) {
                    var it:Dynamic = Reflect.field(ld.map['list'], n);
                    if (Reflect.hasField(it, 'id')) {
                        list.push({
                            text: Reflect.field(it, 'title'), 
                            value: Reflect.field(it, 'id')
                        });
                    }
                }
            }
        }
        this.ui.setListValues('list', list);
    }

}