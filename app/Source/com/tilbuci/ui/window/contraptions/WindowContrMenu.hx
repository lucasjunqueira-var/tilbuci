package com.tilbuci.ui.window.contraptions;

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

class WindowContrMenu extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-contrmenu-title'), 1000, 510, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // creating columns
        this.addForm(Global.ln.get('window-kfmanage-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'registered', tx: Global.ln.get('window-contrmenu-registered'), vr: 'detail' }, 
                { tp: 'List', id: 'registered', vl: [ ], sl: null, ht: 332 }, 
                { tp: 'Button', id: 'load', tx: Global.ln.get('window-contrmenu-load'), ac: loadMenu }, 
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-contrmenu-remove'), ac: removeMenu },
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'properties', tx: Global.ln.get('window-contrmenu-properties'), vr: '' }, 
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-contrmenu-name'), vr: 'detail' }, 
                { tp: 'TInput', id: 'name', tx: '', vr: '' },  
                { tp: 'Label', id: 'font', tx: Global.ln.get('window-contrmenu-font'), vr: 'detail' }, 


                /*{ tp: 'List', id: 'instances', vl: [ ], sl: null, ht: 390 },
                { tp: 'Button', id: 'removeinst', tx: Global.ln.get('window-kfmanage-instremove'), ac: removeInst }, */
            ]),
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'save', tx: Global.ln.get('window-contrmenu-save'), ac: saveMenu },
            ])
            , 460));
            super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {

    }

    private function loadMenu(evt:Event):Void {

    }

    private function removeMenu(evt:Event):Void {
        
    }

    private function saveMenu(evt:Event):Void {
        
    }

}