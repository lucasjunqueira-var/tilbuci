package com.tilbuci.ui.component;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
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
import com.tilbuci.ui.component.ActionArea;
import com.tilbuci.ui.base.HInterfaceContainer;

class WindowActionBlock extends PopupWindow {

    private var _onOk:Dynamic;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic = null) {
        // creating window
        super(ac, Global.ln.get('window-actions-block'), 980, 530, false, true);

        // create columns
        this.addForm('blocks', this.ui.createColumnHolder('available',
            this.ui.forge('left', [
                { tp: 'Label', id: 'groups', tx: Global.ln.get('window-actions-blockgroups'), vr: '' }, 
                { tp: 'List', id: 'groups', vl: [ ], sl: '', ht: 440, ch: onGroupChange }, 
            ]), 
            this.ui.forge('right', [
                { tp: 'Label', id: 'available', tx: Global.ln.get('window-actions-blockavailable'), vr: '' }, 
                { tp: 'List', id: 'available', vl: [ ], sl: '', ht: 410 }, 
                { tp: 'Button', id: 'add', tx: Global.ln.get('window-actions-blockcreate'), ac: onCreate }, 
            ])
        ));
        this.ui.listDbClick('available', onCreate);
    }

    /**
        Window action to run on display (meant to override).
    **/
    override public function acStart():Void {
        var groups:Array<Dynamic> = [ ];
        var i:Int = 0;
        for (gr in Global.acInfo.groups) {
            groups.push({
                text: gr.name, 
                value: i, 
            });
            i++;
        }
        this.ui.setListValues('groups', groups);
        this.ui.setListValues('available', [ ]);
        this.ui.setListSelectValue('groups', null);
        this.ui.setListSelectValue('available', null);
    }

    /**
        Sets current content.
        @param  onOk    action to call on ok button click
    **/
    public function setContent(onOk:Dynamic):Void {
        this._onOk = onOk;
        this.acStart();
    }

    private function onCreate(evt:Event = null):Void {
        if (this.ui.lists['available'].selectedItem != null) {
            Global.showEditBlockWindow(this.ui.lists['available'].selectedItem.value, this._onOk);
            this._onOk = null;
            PopUpManager.removePopUp(this);
        }
    }

    private function onGroupChange(evt:Event):Void {
        this.ui.setListValues('available', [ ]);
        this.ui.setListSelectValue('available', null);
        if (this.ui.lists['groups'].selectedItem != null) {
            if (Global.acInfo.groups.length > this.ui.lists['groups'].selectedItem.value) {
                var av:Array<Dynamic> = [ ];
                for (ac in Global.acInfo.groups[this.ui.lists['groups'].selectedItem.value].actions) {
                    av.push({
                        text: ac.n, 
                        value: ac.a, 
                    });
                }
                this.ui.setListValues('available', av);
            }
        }
    }
}