/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.movie;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
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

class WindowMovieUsers extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-movieusers-title'), 700, InterfaceFactory.pickValue(580, 420), true, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.addForm(Global.ln.get('window-movieusers-collaborators'), this.ui.forge('colab', [
            { tp: 'Label', id: 'colabout', tx: Global.ln.get('window-movieusers-colabout'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'List', id: 'collist', vl: [ ], ht:120, sl: '' },  
            { tp: 'Button', id: 'colrem', tx: Global.ln.get('window-movieusers-colrem'), ac: this.onColRem }, 
            { tp: 'Spacer', id: 'themespacer', ht: 20, ln: false }, 
            { tp: 'Label', id: 'colnew', tx: Global.ln.get('window-movieusers-colnew'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'colnew', tx: '', vr: '' },  
            { tp: 'Button', id: 'coladd', tx: Global.ln.get('window-movieusers-coladd'), ac: this.onColAdd }
        ]));

        this.addForm(Global.ln.get('window-movieusers-owner'), this.ui.forge('owner', [
            { tp: 'Label', id: 'colabout', tx: Global.ln.get('window-movieusers-ownerabout'), vr: Label.VARIANT_DETAIL, wrap: true }, 
            { tp: 'Spacer', id: 'themespacer', ht: 20, ln: false }, 
            { tp: 'Label', id: 'ownernew', tx: Global.ln.get('window-movieusers-ownernew'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'ownernew', tx: '', vr: '' },  
            { tp: 'Label', id: 'ownernew', tx: Global.ln.get('window-movieusers-ownernew2'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'ownernew2', tx: '', vr: '' },  
            { tp: 'Spacer', id: 'themespacer2', ht: 80, ln: false }, 
            { tp: 'Button', id: 'ownerchange', tx: Global.ln.get('window-movieusers-ownerchange'), ac: this.onChangeOwner }
        ]));

        this.addForm(Global.ln.get('window-movieusers-lock'), this.ui.forge('lock', [ 
            { tp: 'Label', id: 'unlock', tx: Global.ln.get('window-movieusers-unlockabout'), vr: '', wrap: true }, 
            { tp: 'Spacer', id: 'unlock', ht: 20, ln: false }, 
            { tp: 'Button', id: 'unlock', tx: Global.ln.get('window-movieusers-unlock'), ac: this.onUnlock }
        ]));

        super.startInterface();
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
        Global.ws.send('Movie/Collaborators', [ 'id' => GlobalPlayer.movie.mvId ], this.onList);
    }

    /**
        The collaborators list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.setListValues('collist', [ ]);
            this.ui.createWarning(Global.ln.get('window-movieusers-title'), Global.ln.get('window-movieusers-errorlist'), 300, 150, this.stage);
        } else{
            if (ld.map['e'] == 0) {
                var ar:Array<Dynamic> = [ ] ;
                for (us in Reflect.fields(ld.map['list'])) ar.push({text: Reflect.field(ld.map['list'], us), value: Reflect.field(ld.map['list'], us)});
                this.ui.setListValues('collist', ar);
            } else {
                this.ui.setListValues('collist', [ ]);
                this.ui.createWarning(Global.ln.get('window-movieusers-title'), Global.ln.get('window-movieusers-errorlist'), 300, 150, this.stage);
            }
        }
        this.ui.inputs['colnew'].text = '';
    }

    /**
        Adds a collaborator.
    **/
    private function onColAdd(evt:TriggerEvent):Void {
        if (this.ui.inputs['colnew'].text != '') {
            Global.ws.send('Movie/CollaboratorAdd', [
                'id' => GlobalPlayer.movie.mvId, 
                'email' => this.ui.inputs['colnew'].text, 
            ], this.onList);
        }
    }

    /**
        Removes a collaborator.
    **/
    private function onColRem(evt:TriggerEvent):Void {
        if (this.ui.lists['collist'].selectedItem != null) {
            Global.ws.send('Movie/CollaboratorRemove', [
                'id' => GlobalPlayer.movie.mvId, 
                'email' => this.ui.lists['collist'].selectedItem.text, 
            ], this.onList);
        }
    }

    /**
        Changes movie owner.
    **/
    private function onChangeOwner(evt:TriggerEvent):Void {
        if (this.ui.inputs['ownernew'].text != '') {
            if (this.ui.inputs['ownernew'].text != this.ui.inputs['ownernew2'].text) {
                this.ui.createWarning(Global.ln.get('window-movieusers-title'), Global.ln.get('window-movieusers-ownermatch'), 300, 180, this.stage);
            } else {
                Global.ws.send('Movie/OwnerChange', [
                    'id' => GlobalPlayer.movie.mvId, 
                    'email' =>this.ui.inputs['ownernew'].text, 
                ], this.onOwner);
            }
        }
    }

    /**
        Unlock movie scenes.
    **/
    private function onUnlock(evt:TriggerEvent):Void {
        Global.ws.send('Movie/UnlockScenes', [
            'id' => GlobalPlayer.movie.mvId
        ], this.onUnlockReturn);
    }

    /**
        Owner change results.
    **/
    private function onOwner(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-movieusers-title'), Global.ln.get('window-movieusers-ownererror'), 300, 180, this.stage);
        } else{
            if (ld.map['e'] == 0) {
                this.ui.createWarning(Global.ln.get('window-movieusers-title'), Global.ln.get('window-movieusers-ownerok'), 300, 180, this.stage);
            } else if (ld.map['e'] == 2) {
                this.ui.createWarning(Global.ln.get('window-movieusers-title'), Global.ln.get('window-movieusers-ownernomail'), 300, 180, this.stage);
            } else {
                this.ui.createWarning(Global.ln.get('window-movieusers-title'), Global.ln.get('window-movieusers-ownererror'), 300, 180, this.stage);
            }
        }
    }

    /**
        Unlock scene results.
    **/
    private function onUnlockReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-movieusers-title'), Global.ln.get('window-movieusers-erlock'), 300, 180, this.stage);
        } else{
            if (ld.map['e'] == 0) {
                Global.showMsg(Global.ln.get('window-movieusers-oklock'));
            } else {
                this.ui.createWarning(Global.ln.get('window-movieusers-title'), Global.ln.get('window-movieusers-erlock'), 300, 180, this.stage);
            }
        }
    }

}