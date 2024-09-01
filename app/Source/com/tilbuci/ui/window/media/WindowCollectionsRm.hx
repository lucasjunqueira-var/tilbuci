package com.tilbuci.ui.window.media;

/** OPENFL **/
import com.tilbuci.def.AssetData;
import feathers.data.ArrayCollection;
import openfl.Assets;
import openfl.display.Bitmap;
import com.tilbuci.ui.base.InterfaceColumns;
import com.tilbuci.ui.base.InterfaceContainer;
import com.tilbuci.def.CollectionData;
import com.tilbuci.ui.base.HInterfaceContainer;
import com.tilbuci.ui.component.MediaPreview;
import openfl.events.MouseEvent;
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
import com.tilbuci.ui.window.media.WindowCollections;

class WindowCollectionsRm extends PopupWindow {

    /**
        collection insterface
    **/
    private var _colint:InterfaceColumns;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-collectionrm-title'), 1000, 600, false);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // create interface
        this._colint = this.ui.createColumnHolder('columns',
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'collections', tx: Global.ln.get('window-collectionrm-cols'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'collections', vl: [ ], ht: 470, sl: null, ch: this.onColChange },  
                { tp: 'Label', id: 'assets', tx: Global.ln.get('window-collectionrm-colsabout'), vr: Label.VARIANT_DETAIL },                
            ]),
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'assets', tx: Global.ln.get('window-collection-assets'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'assets', vl: [ ], ht: 470, sl: null }, 
                { tp: 'Button', id: 'assetstage', tx: Global.ln.get('window-collection-remove'), ac: this.onColRemove }, 
            ]));
        this.addForm(Global.ln.get('window-media-file'), this._colint);
        this.ui.setListToIcon('collections');
        this.ui.setListToIcon('assets');

        super.startInterface();
    }

    /**
        Loading initial file list.
    **/
    override public function acStart():Void {
        this.loadCollections();
    }

    /**
        Loads current movie collections.
    **/
    private function loadCollections():Void {
        this.ui.lists['collections'].selectedItem = null;
        this.ui.lists['assets'].selectedItem = null;
        this.ui.setListValues('collections', [ ]);
        this.ui.setListValues('assets', [ ]);
        Global.ws.send('Media/ListRmCollections', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
    }

    /**
        The collections list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-nolist'), 300, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else{
            if (ld.map['e'] == 0) {
                var clist:Array<CollectionInfo> = cast ld.map['list'];
                var list = [ ];
                for (i in clist) {
                    if (!GlobalPlayer.movie.scene.collections.contains(i.id)) {
                        list.push({ text: i.title, value: i, user: (i.num + ' ' + Global.ln.get('window-collection-numassets')) });
                    }
                }
                this.ui.setListValues('collections', list);
            } else {
                this.ui.createWarning(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-nolist'), 300, 180, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        A new collection was selected on the list.
    **/
    private function onColChange(evt:Event = null):Void {
        this.ui.lists['assets'].selectedItem = null;
        this.ui.setListValues('assets', [ ]);
        if (this.ui.lists['collections'].selectedItem != null) {
            Global.ws.send('Media/ListColAssets', [ 'uid' => this.ui.lists['collections'].selectedItem.value.uid ], this.onAssetList);
        }
    }

    /**
        The assets list is available.
    **/
    private function onAssetList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-nolist'), 300, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else{
            if (ld.map['e'] == 0) {
                var alist:Array<AssetInfo> = cast ld.map['list'];
                var list = [ ];
                for (i in alist) list.push({ text: i.name, user: Global.ln.get('menu-media-' + i.type), value: i });
                this.ui.setListValues('assets', list);
            } else {
                this.ui.createWarning(Global.ln.get('window-collection-title'), Global.ln.get('window-collection-nolist'), 300, 180, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Confirm collection remove.
    **/
    private function onColRemove(evt:TriggerEvent):Void {
        if (this.ui.lists['collections'].selectedItem != null) {
            Global.showPopup(Global.ln.get('window-collectionrm-title'), Global.ln.get('window-collectionrm-confirm'), 320, 220, Global.ln.get('default-ok'), onColRemoveConfirm, 'confirm', Global.ln.get('default-cancel'));
        }
    }

    /**
        Collection removal confirmation.
    **/
    private function onColRemoveConfirm(ok:Bool):Void {
        if (ok && (this.ui.lists['collections'].selectedItem != null)) {
            Global.ws.send('Media/RemoveCollection', [ 'movie' => GlobalPlayer.movie.mvId, 'col' => this.ui.lists['collections'].selectedItem.value.id ], this.onRemoveReturn);
        }
    }

    /**
        After collection removal.
    **/
    private function onRemoveReturn(ok:Bool, ld:DataLoader):Void {
        this.loadCollections();
    }
}