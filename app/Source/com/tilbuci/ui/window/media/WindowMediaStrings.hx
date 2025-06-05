/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.media;

/** OPENFL **/
import feathers.core.FeathersControl;
import feathers.utils.Scroller;
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

class WindowMediaStrings extends PopupWindow {

    /**
        media file type
    **/
    private var _type:String;
    
    /**
        current media path
    **/
    private var _path:String;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-mdstrings-title'), 1000, 530, false, true, true);
        this._type = 'strings';
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.addForm('files', this.ui.forge('strings', [
            { tp: 'List', id: 'fileslist', vl: [ ], ht: 380, sl: null }, 
            { tp: 'Button', id: 'btremove', tx: Global.ln.get('window-media-removefile'), ac: this.onRemove }, 
            { tp: 'Button', id: 'btdownload', tx: Global.ln.get('window-media-download'), ac: this.onDownload }, 
            { tp: 'Button', id: 'btupload', tx: Global.ln.get('window-media-upload'), ac: this.onUpload }, 
        ]));
        this.ui.listChange('fileslist', onChange);
        super.startInterface();
    }


    /**
        Loading initial file list.
    **/
    override public function acStart():Void {
        this._path = '';
        this.loadPath();
    }

    /**
        Loads a media folder files list.
    **/
    private function loadPath():Void {
        this.ui.setListValues('fileslist', [ ]);
        this.ui.buttons['btremove'].enabled = false;
        this.ui.buttons['btremove'].visible = false;
        this.ui.buttons['btdownload'].enabled = false;
        this.ui.buttons['btdownload'].visible = false;
        Global.ws.send('Media/List', [ 'movie' => GlobalPlayer.movie.mvId, 'type' => this._type, 'path' => this._path ], this.onList);
    }

    /**
        The files list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-nolist'), 300, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else{
            if (ld.map['e'] == 0) {
                var its:Array<Dynamic> = [ ];
                for (it in Reflect.fields(ld.map['list'])) {
                    its.push({
                        text: Reflect.field(Reflect.field(ld.map['list'], it), 'n'), 
                        value: Reflect.field(Reflect.field(ld.map['list'], it), 'n'), 
                        type: 'f', 
                        asset: ''
                    });
                }
                this.ui.setListValues('fileslist', its);
            } else {
                this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-nolist'), 300, 180, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        List element change.
    **/
    private function onChange(evt:Event):Void {
        if (this.ui.lists['fileslist'].selectedItem != null) {
            this.ui.buttons['btremove'].enabled = true;
            this.ui.buttons['btremove'].visible = true;
            this.ui.buttons['btdownload'].enabled = true;
            this.ui.buttons['btdownload'].visible = true;
        }
    }

    /**
        Download the selected file?
    **/
    private function onDownload(evt:TriggerEvent):Void {
        if (this.ui.lists['fileslist'].selectedItem != null) {
            Global.ws.download([
                'file' => 'strings', 
                'media' => this.ui.lists['fileslist'].selectedItem.text, 
                'movie' => GlobalPlayer.movie.mvId,  
            ]);
        }
    }

    /**
        Remove the selected file?
    **/
    private function onRemove(evt:TriggerEvent):Void {
        this.ui.createConfirm(Global.ln.get('window-media-title'), Global.ln.get('window-media-removewarn'), 400, 220, onRealRemove, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
    }

    /**
        Remove item confirmation.
    **/
    private function onRealRemove(ok:Bool):Void {
        if (ok) {
            Global.ws.send('Media/DeleteFile', [ 'movie' => GlobalPlayer.movie.mvId, 'type' => this._type, 'path' => this._path, 'name' => this.ui.lists['fileslist'].selectedItem.text ], this.onRemoveFile);
        }
    }

    /**
        Remove file return.
    **/
    private function onRemoveFile(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-removefileer'), 300, 180, this.stage);
        } else {
            if (ld.map['e'] == 0) {
                this.loadPath();
            } else {
                this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-removefileer'), 300, 180, this.stage);
            }
        }
    }

    /**
        Uploads a file.
    **/
    private function onUpload(evt:TriggerEvent):Void {
        Global.up.browseForMedia(onFileSelcted, this._type);
    }

    /**
        A new file was selected.
        @param  ok  file correctly selected?
    **/
    private function onFileSelcted(ok:Bool):Void {
        if (ok) {
            Global.up.uploadMedia(onUploadReturn, [
                'movie' => GlobalPlayer.movie.mvId, 
                'type' => this._type, 
                'path' => this._path
            ]);
        }
    }

    /**
        Upload return.
    **/
    private function onUploadReturn(ok:Bool, data:Map<String, Dynamic> = null):Void {
        if (ok) {
            this.loadPath();
        } else {
            this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-uploader'), 300, 180, this.stage);
        }
    }

}