/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.scene;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.display.PictureImage;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.ui.base.InterfaceContainer;
import com.tilbuci.ui.component.ActionArea;
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

class WindowSceneProperties extends PopupWindow {

    /**
        start-of-scene actions
    **/
    private var _acstart:ActionArea;

    /**
        end-of-keyframe actions
    **/
    private var _kfactions:ActionArea;

    /**
        current keyframe actions
    **/
    private var _kfactext:Array<String> = [ ];

    /**
        the share image display
    **/
    private var _image:PictureImage;

    /**
        available collections (for cache)
    **/
    private var _collections:Map<String, WSPCollection> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-sceneprop-windowtitle'), 1000, InterfaceFactory.pickValue(590, 660), true, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {

        // about
        this._image = new PictureImage(this.onImageLoaded);
        this._image.height = 130;
        this._image.visible = true;
        var image:InterfaceContainer = new InterfaceContainer('v', 10, 0x666666);
        image.width = 900;
        image.height = 140;
        image.addChild(this._image);
        this.addForm(Global.ln.get('window-sceneprop-about'), this.ui.forge('about', [
            { tp: 'Label', id: 'title', tx: Global.ln.get('window-sceneprop-title'), vr: '' }, 
            { tp: 'TInput', id: 'title', tx: GlobalPlayer.movie.scene.title, vr: '' },  
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-sceneprop-aboutscene'), vr: '' },
            { tp: 'TArea', id: 'about', tx: GlobalPlayer.movie.scene.about, vr: '', en: true, ht: 100 },  
            { tp: 'Label', id: 'static', tx: Global.ln.get('window-sceneprop-static'), vr: '' }, 
            { tp: 'Toggle', id: 'static', vl: false }, 
            { tp: 'Label', id: 'image', tx: Global.ln.get('window-sceneprop-image'), vr: '' }, 
            { tp: 'Button', id: 'image', tx: Global.ln.get('window-sceneprop-imagebt'), ac: this.onImage }, 
            { tp: 'Button', id: 'imagerm', tx: Global.ln.get('window-sceneprop-imagerm'), ac: this.onImageRemove }, 
            { tp: 'Custom', cont: image }, 
            //{ tp: 'Spacer', id: 'about', ht: 10, ln: false }, 
            { tp: 'Button', id: 'about', tx: Global.ln.get('window-sceneprop-setbt'), ac: this.onSave }, 
        ]));

        // navigation
        this.addForm(Global.ln.get('window-sceneprop-navigation'), this.ui.forge('navigation', [
            { tp: 'Label', id: 'nvup', tx: Global.ln.get('window-sceneprop-nvup'), vr: '' }, 
            { tp: 'Select', id: 'nvup', vl: [ ], sl: '' },
            { tp: 'Label', id: 'nvdown', tx: Global.ln.get('window-sceneprop-nvdown'), vr: '' }, 
            { tp: 'Select', id: 'nvdown', vl: [ ], sl: '' },
            { tp: 'Label', id: 'nvleft', tx: Global.ln.get('window-sceneprop-nvleft'), vr: '' }, 
            { tp: 'Select', id: 'nvleft', vl: [ ], sl: '' },
            { tp: 'Label', id: 'nvright', tx: Global.ln.get('window-sceneprop-nvright'), vr: '' }, 
            { tp: 'Select', id: 'nvright', vl: [ ], sl: '' },
            { tp: 'Label', id: 'nvin', tx: Global.ln.get('window-sceneprop-nvin'), vr: '' }, 
            { tp: 'Select', id: 'nvin', vl: [ ], sl: '' },
            { tp: 'Label', id: 'nvout', tx: Global.ln.get('window-sceneprop-nvout'), vr: '' }, 
            { tp: 'Select', id: 'nvout', vl: [ ], sl: '' },
            { tp: 'Spacer', id: 'navigation', ht: 148, ln: false }, 
            { tp: 'Button', id: 'navigation', tx: Global.ln.get('window-sceneprop-setbt'), ac: this.onSave }, 
        ]));

        // start actions
        var acstart:InterfaceContainer = this.ui.createContainer('acstart');
        acstart.addChild(this.ui.createLabel('acstartlabel', Global.ln.get('window-sceneprop-acstartabout'), Label.VARIANT_DETAIL));
        this._acstart = new ActionArea(956, 435);
        this._acstart.setText(GlobalPlayer.movie.scene.acstart);
        acstart.addChild(this._acstart);
        acstart.addChild(this.ui.createSpacer('acstartspacer', 15));
        acstart.addChild(this.ui.createButton('saveacstart', Global.ln.get('window-sceneprop-setbt'), this.onSave ));
        this.addForm(Global.ln.get('window-sceneprop-acstart'), acstart);

        // keyframes
        this._kfactions = new ActionArea(956, 320);
        this.addForm(Global.ln.get('window-sceneprop-keyframes'), this.ui.forge('keyframes', [
            { tp: 'Label', id: 'loop', tx: Global.ln.get('window-sceneprop-loop'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'loop', vl: [ ], sl: '' },
            { tp: 'Spacer', id: 'kfactions', ht: 20, ln: true }, 
            { tp: 'Label', id: 'kfactions', tx: Global.ln.get('window-sceneprop-kfactions'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'kfactions', vl: [ ], sl: '' },
            { tp: 'Spacer', id: 'keyframes', ht: 5, ln: false }, 
            { tp: 'Custom', cont: this._kfactions }, 
            { tp: 'Spacer', id: 'keyframes', ht: 15, ln: false }, 
            { tp: 'Button', id: 'keyframes', tx: Global.ln.get('window-sceneprop-setbt'), ac: this.onSave }, 
        ]));
        this.ui.selectChange('kfactions', onkfChange, onkfOpen);

        // remove
        this.addForm(Global.ln.get('window-sceneprop-scenedel'), this.ui.forge('remove', [
            { tp: 'Label', id: 'remove', tx: Global.ln.get('window-sceneprop-scenedelabout'), vr: '' }, 
            { tp: 'TInput', id: 'remove', tx: '', vr: '' },  
            { tp: 'Spacer', id: 'remove', ht: 20, ln: false }, 
            { tp: 'Button', id: 'remove', tx: Global.ln.get('window-sceneprop-scenedelbt'), ac: this.onRemove }, 
        ]));
        this.ui.labels['remove'].wordWrap = true;

        super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        this._kfactext = [ ];
        this._collections = [ ];
        for (i in 0...GlobalPlayer.movie.scene.keyframes.length) {
            if (GlobalPlayer.movie.scene.ackeyframes.length > i) {
                this._kfactext.push(GlobalPlayer.movie.scene.ackeyframes[i]);
            } else {
                this._kfactext.push('');
            }
        }
        Global.ws.send('Scene/List', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
        if (GlobalPlayer.movie.scene.image == '') {
            this._image.unload();
        } else {
            this._image.load(GlobalPlayer.movie.scene.image);
        }
        this.ui.inputs['title'].text = GlobalPlayer.movie.scene.title;
        this.ui.tareas['about'].text = GlobalPlayer.movie.scene.about;
        this.ui.toggles['static'].selected = GlobalPlayer.movie.scene.staticsc;
        this._acstart.setText(GlobalPlayer.movie.scene.acstart);
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'browsesceneimage':
                this._image.load(data['file']);
        }
    }

    /**
        The scenes list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-sceneprop-windowtitle'), Global.ln.get('window-sceneprop-nolist'), 300, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else{
            if (ld.map['e'] == 0) {
                // scenes list
                var sclist:Array<Dynamic> = [ { text: Global.ln.get('window-sceneprop-nvnone'), value: '' } ];
                var ar:Array<Dynamic> = cast ld.map['list'];
                if (ar.length > 0) {
                    for (i in ar) sclist.push({ text: Reflect.field(i, 'title'), value: Reflect.field(i, 'id') });
                }
                this.ui.setSelectOptions('nvup', sclist, GlobalPlayer.movie.scene.navigation['up']);
                this.ui.setSelectOptions('nvdown', sclist, GlobalPlayer.movie.scene.navigation['down']);
                this.ui.setSelectOptions('nvleft', sclist, GlobalPlayer.movie.scene.navigation['left']);
                this.ui.setSelectOptions('nvright', sclist, GlobalPlayer.movie.scene.navigation['right']);
                this.ui.setSelectOptions('nvin', sclist, GlobalPlayer.movie.scene.navigation['nin']);
                this.ui.setSelectOptions('nvout', sclist, GlobalPlayer.movie.scene.navigation['nout']);
                // keyframes
                var kflist:Array<Dynamic> = [ ];
                for (i in 0...GlobalPlayer.movie.scene.keyframes.length) {
                    kflist.push({ text: Std.string(i + 1), value: i });
                }
                this.ui.setSelectOptions('loop', kflist, GlobalPlayer.movie.scene.loop);
                this._kfactions.setText(this._kfactext[0]);
                this.ui.setSelectOptions('kfactions', kflist, 0);
            } else {
                this.ui.createWarning(Global.ln.get('window-sceneprop-windowtitle'), Global.ln.get('window-sceneprop-nolist'), 300, 180, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Current keyframe change.
    **/
    private function onkfChange(evt:Event):Void {
        this._kfactions.setText(this._kfactext[this.ui.selects['kfactions'].selectedItem.value]);
    }

    /**
        Keyframe select open.
    **/
    private function onkfOpen(evt:Event):Void {
        this._kfactext[this.ui.selects['kfactions'].selectedItem.value] = this._kfactions.getText();
    }

    /**
        Saves the scene propertis
    **/
    private function onSave(evt:TriggerEvent):Void {
        // checking keyframe actions
        this._kfactext[this.ui.selects['kfactions'].selectedItem.value] = this._kfactions.getText();
        var ok:Int = -1;
        for (i in 0...this._kfactext.length) {
            if (this._kfactext[i] != '') {
                var json:Dynamic = StringStatic.jsonParse(this._kfactext[i]);
                if (json == false) ok = i;
            }
        }
        if (ok >= 0) {
            this.ui.createWarning(Global.ln.get('window-sceneprop-windowtitle'), StringTools.replace(Global.ln.get('window-sceneprop-kfacerror'), '[NUMBER]', Std.string(ok + 1)), 300, 180, this.stage);
        } else {
            // checking scene actions
            var json2:Dynamic = StringStatic.jsonParse(this._acstart.getText());
            if ((json2 == false) && (this._acstart.getText() != '')) {
                this.ui.createWarning(Global.ln.get('window-sceneprop-windowtitle'), Global.ln.get('window-sceneprop-acerror'), 300, 180, this.stage);
            } else {
                // valid title?
                if (this.ui.inputs['title'].text == '') {
                    this.ui.createWarning(Global.ln.get('window-sceneprop-windowtitle'), Global.ln.get('window-sceneprop-notitle'), 300, 180, this.stage);
                } else {
                    // setting values
                    GlobalPlayer.movie.scene.title = this.ui.inputs['title'].text;
                    GlobalPlayer.movie.scene.about = this.ui.tareas['about'].text;
                    GlobalPlayer.movie.scene.image = this._image.lastMedia;
                    GlobalPlayer.movie.scene.staticsc = this.ui.toggles['static'].selected;
                    GlobalPlayer.movie.scene.navigation['up'] = this.ui.selects['nvup'].selectedItem.value;
                    GlobalPlayer.movie.scene.navigation['down'] = this.ui.selects['nvdown'].selectedItem.value;
                    GlobalPlayer.movie.scene.navigation['left'] = this.ui.selects['nvleft'].selectedItem.value;
                    GlobalPlayer.movie.scene.navigation['right'] = this.ui.selects['nvright'].selectedItem.value;
                    GlobalPlayer.movie.scene.navigation['nin'] = this.ui.selects['nvin'].selectedItem.value;
                    GlobalPlayer.movie.scene.navigation['nout'] = this.ui.selects['nvout'].selectedItem.value;
                    GlobalPlayer.movie.scene.acstart = this._acstart.getText();
                    GlobalPlayer.movie.scene.ackeyframes = [ ];
                    for (txt in this._kfactext) GlobalPlayer.movie.scene.ackeyframes.push(txt);
                    GlobalPlayer.movie.scene.loop = this.ui.selects['loop'].selectedItem.value;
                    Global.showMsg(Global.ln.get('window-sceneprop-sceneset'));
                    PopUpManager.removePopUp(this);
                }
            }
        }
    }

    /**
        Click on remove scene button.
    **/
    private function onRemove(evt:TriggerEvent):Void {
        if (this.ui.inputs['remove'].text == Global.ln.get('window-sceneprop-scenedeltype')) {
            this.ui.inputs['remove'].text = '';
            this.ui.createConfirm(Global.ln.get('window-sceneprop-scenedel'), Global.ln.get('window-sceneprop-scenedelconfirm'), 320, 240, this.onRemoveConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
        }
    }

    /**
        Remove scene confirmation.
    **/
    private function onRemoveConfirm(ok:Bool):Void {
        if (ok) {
            Global.ws.send('Scene/Remove', [ 'movie' => GlobalPlayer.movie.mvId, 'id' => GlobalPlayer.movie.scId ], this.onRemoveOk);
        }
    }

    /**
        Remove scene server return.
    **/
    private function onRemoveOk(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-sceneprop-scenedel'), Global.ln.get('window-sceneprop-scenedeler'), 300, 180, this.stage);
        } else {
            if (ld.map['e'] == 0) {
                GlobalPlayer.movie.scene.clear();
                GlobalPlayer.movie.noScene();
                GlobalPlayer.area.clear();
                PopUpManager.removePopUp(this);
                Global.showMsg(Global.ln.get('window-sceneprop-scenedelok'),);
            } else {
                this.ui.createWarning(Global.ln.get('window-sceneprop-scenedel'), Global.ln.get('window-sceneprop-scenedeler'), 300, 180, this.stage);
            }
        }
    }

    /**
        Selects the share image.
    **/
    private function onImage(evt:TriggerEvent):Void {
        this._ac('browsesceneimage');
    }

    /**
        Removes the share image.
    **/
    private function onImageRemove(evt:TriggerEvent):Void {
        this._image.unload();
    }

    /**
        The share image image was loaded.
    **/
    private function onImageLoaded(ok:Bool):Void {
        this._image.height = 190;
        this._image.width = this._image.oWidth * this._image.height / this._image.oHeight;
        this._image.visible = true;
    }

}

typedef WSPCollection = {
    var uid:String;
    var title:String;
    var assets:Map<String, WSPAsset>;
}

typedef WSPAsset = {
    var id:String;
    var name:String;
    var type:String;
    var file1:String;
    var file2:String;
    var file3:String;
    var file4:String;
    var file5:String;
}