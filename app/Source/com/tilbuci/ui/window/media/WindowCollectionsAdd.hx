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

class WindowCollectionsAdd extends PopupWindow {

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
        super(ac, Global.ln.get('window-collectionadd-title'), 1000, 600, false);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // create interface
        this._colint = this.ui.createColumnHolder('columns',
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'collections', tx: Global.ln.get('window-collectionadd-cols'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'collections', vl: [ ], ht: 470, sl: null, ch: this.onColChange },  
                { tp: 'Label', id: 'assets', tx: Global.ln.get('window-collectionadd-colsabout'), vr: Label.VARIANT_DETAIL },                
            ]),
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'assets', tx: Global.ln.get('window-collection-assets'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'assets', vl: [ ], ht: 470, sl: null }, 
                { tp: 'Button', id: 'assetstage', tx: Global.ln.get('window-collection-assetstagenew'), ac: this.onAssetAdd }, 
            ]));
        this.addForm(Global.ln.get('window-media-file'), this._colint);
        this.ui.setListToIcon('collections');
        this.ui.setListToIcon('assets');
        this.ui.listDbClick('assets', this.onAssetAdd);

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
        Global.ws.send('Media/ListCollections', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
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
        Adds an asset to stage.
    **/
    private function onAssetAdd(evt:TriggerEvent):Void {
        if (this.ui.lists['assets'].selectedItem != null) {
            var col:CollectionInfo = this.ui.lists['collections'].selectedItem.value;
            var cdata:CollectionData = new CollectionData(col.id, null, false);
            cdata.name = col.title;
            cdata.transition = col.transition;
            cdata.time = col.time;
            for (i in 0...this.ui.lists['assets'].dataProvider.length) {
                var ast:AssetInfo = cast this.ui.lists['assets'].dataProvider.get(i).value;
                var adata:AssetData = 
                cdata.assets[ast.id] = new AssetData({
                    order: ast.order, 
                    name: ast.name, 
                    type: ast.type, 
                    time: ast.time, 
                    action: ast.action, 
                    frames: ast.frames, 
                    frtime: ast.frtime, 
                    file: {
                        '@1': ast.file1, 
                        '@2': ast.file2, 
                        '@3': ast.file3, 
                        '@4': ast.file4, 
                        '@5': ast.file5, 
                    }
                });
                cdata.assetOrder.push(ast.id);
            }
            cdata.ok = true;
            GlobalPlayer.movie.collections[col.id] = cdata;
            GlobalPlayer.movie.scene.collections.push(col.id);
            this._ac('addinstance', [
                'collection' => col.id, 
                'asset' => this.ui.lists['assets'].selectedItem.value.id
            ]);
            PopUpManager.removePopUp(this);
        }
    }
}