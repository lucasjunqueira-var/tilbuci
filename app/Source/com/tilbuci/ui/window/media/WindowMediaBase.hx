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

class WindowMediaBase extends PopupWindow {

    /**
        media file type
    **/
    private var _type:String;
    
    /**
        current media path
    **/
    private var _path:String;

    /**
        the media preview
    **/
    private var _preview:MediaPreview;

    /**
        media manager mode: simple or asset
    **/
    private var _mode:String;

    /**
        current asset file number
    **/
    private var _filenum:String = '1';

    /**
        spritemaop number of frames
    **/
    private var _frames:Int = 1;

    /**
        spritemaop frame time
    **/
    private var _frtime:Int = 100;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic, title:String, type:String, mode:String) {
        // creating window
        super(ac, title, 1000, 690, false);
        this._type = type;
        this._mode = mode;
        this._preview = new MediaPreview(type, 460, 460);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {

        // file-based media?
        if ((this._type == 'shape') || (this._type == 'paragraph') || (this._type == 'text')) {
            // don't add interface
        } else {
            // new folder interface
            var nf:HInterfaceContainer = this.ui.createHContainer('newfolder');
            nf.addChild(this.ui.createTInput('newfolder'));
            nf.addChild(this.ui.createButton('newfolder', Global.ln.get('window-media-newfolder'), onNewFolder));
            nf.width = 960;

            // create interface
            this.addForm(Global.ln.get('window-media-file'), this.ui.createColumnHolder('columns',
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'filestitle', tx: Global.ln.get('window-media-file'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'fileslist', vl: [ ], ht: 420, sl: null }, 
                { tp: 'Button', id: 'btadd', tx: '', ac: this.onOpen }, 
            ]),
            this.ui.forge('rightcol', [
                { tp: 'Custom', cont: this._preview }, 
                
            ]),
            this.ui.forge('bottom', [
                { tp: 'Custom', cont: nf }, 
                { tp: 'Button', id: 'btremove', tx: '', ac: this.onRemove }, 
                { tp: 'Button', id: 'btupload', tx: Global.ln.get('window-media-upload'), ac: this.onUpload }, 
            ]),
            500));
            this.ui.setListToIcon('fileslist');
            this.ui.listChange('fileslist', onChange);
            this.ui.listDbClick('fileslist', onDoubleClick);
        }

        super.startInterface();
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'setmode':
                if (data['mode'] == 'asset') {
                    this._mode = 'asset';
                    this._filenum = data['num'];
                } else if (data['mode'] == 'newasset') {
                    this._mode = 'newasset';
                } else if (data['mode'] == 'single') {
                    this._mode = 'single';
                } else {
                    this._mode = 'simple';
                }
        }
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
        this.ui.labels['filestitle'].text = Global.ln.get('window-media-wait');
        this.ui.buttons['btadd'].text = '';
        this.ui.buttons['btadd'].enabled = false;
        this.ui.buttons['btadd'].visible = false;
        this.ui.buttons['btremove'].enabled = false;
        this.ui.buttons['btremove'].visible = false;
        this._preview.hide();
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
                if (this._path != '') its.push({
                    text: Global.ln.get('window-media-uplevel'),
                    value: Global.ln.get('window-media-uplevel'),
                    type: 'up', 
                    asset: 'iconUpLevel'
                });
                for (it in Reflect.fields(ld.map['list'])) {
                    if (Reflect.field(Reflect.field(ld.map['list'], it), 't') == 'd') {
                        its.push({
                            text: Reflect.field(Reflect.field(ld.map['list'], it), 'n'), 
                            value: Reflect.field(Reflect.field(ld.map['list'], it), 'n'), 
                            type: 'd', 
                            asset: 'iconFolder'
                        });
                    } else {
                        its.push({
                            text: Reflect.field(Reflect.field(ld.map['list'], it), 'n'), 
                            value: Reflect.field(Reflect.field(ld.map['list'], it), 'n'), 
                            type: 'f', 
                            asset: ''
                        });
                    }
                }
                this.ui.setListValues('fileslist', its);
                this.ui.labels['filestitle'].text = '/' + this._path;
            } else {
                this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-nolist'), 300, 180, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Opens the selected item list.
    **/
    private function onOpen(evt:TriggerEvent):Void {
        this._preview.onStop(null);
        if (this.ui.lists['fileslist'].selectedItem.type == 'd') {
            this._path += this.ui.lists['fileslist'].selectedItem.text + '/';
            this.loadPath();
        } else if (this.ui.lists['fileslist'].selectedItem.type == 'up') {
            var par:Array<String> = this._path.split('/');
            this._path = '';
            if (par.length > 1) {
                for (i in 0...(par.length - 2)) {
                    if (par[i] != '') this._path += par[i] + '/';
                }
            }
            this.loadPath();
        } else if (this.ui.lists['fileslist'].selectedItem.type == 'f') {
            if (this._mode == 'asset') {
                // set to asset
                this._mode = 'simple';
                this._ac('addasset', [ 'path' => this._path, 'type' => this._type, 'file' => this.ui.lists['fileslist'].selectedItem.text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime), 'num' => this._filenum ]);
                PopUpManager.removePopUp(this);
            } else if (this._mode == 'newasset') {
                // set to asset
                this._mode = 'simple';
                this._ac('addnewasset', [ 'path' => this._path, 'type' => this._type, 'file' => this.ui.lists['fileslist'].selectedItem.text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
                PopUpManager.removePopUp(this);

            } else if (this._mode == 'single') {
                // set to asset
                this._mode = 'single';
                this._ac('single', [ 'path' => this._path, 'type' => this._type, 'file' => this.ui.lists['fileslist'].selectedItem.text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
                PopUpManager.removePopUp(this);

            } else {
                // add to stage
                this._ac('addstage', [ 'path' => this._path, 'type' => this._type, 'file' => this.ui.lists['fileslist'].selectedItem.text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Double click on an item element.
    **/
    private function onDoubleClick(evt:Event):Void {
        this.onOpen(null);
    }

    /**
        List element change.
    **/
    private function onChange(evt:Event):Void {
        if (this.ui.lists['fileslist'].selectedItem != null) {
            if (this.ui.lists['fileslist'].selectedItem.type == 'd') {
                this.ui.buttons['btadd'].text = Global.ln.get('window-media-openfolder');
                this.ui.buttons['btremove'].enabled = true;
                this.ui.buttons['btremove'].visible = true;
                this.ui.buttons['btremove'].text = Global.ln.get('window-media-removedir');
                this._preview.hide();
            } else if (this.ui.lists['fileslist'].selectedItem.type == 'up') {
                this.ui.buttons['btadd'].text = Global.ln.get('window-media-uplevel');
                this.ui.buttons['btremove'].enabled = false;
                this.ui.buttons['btremove'].visible = false;
                this._preview.hide();
            } else {
                if (this._mode == 'asset') {
                    this.ui.buttons['btadd'].text = Global.ln.get('window-media-addcol') + ' @' + this._filenum;
                } else if (this._mode == 'newasset') {
                    this.ui.buttons['btadd'].text = Global.ln.get('window-media-addast');
                } else if (this._mode == 'single') {
                    this.ui.buttons['btadd'].text = Global.ln.get('window-media-addsingle');
                } else {
                    this.ui.buttons['btadd'].text = Global.ln.get('window-media-addstage');
                }
                this.ui.buttons['btremove'].enabled = true;
                this.ui.buttons['btremove'].visible = true;
                this.ui.buttons['btremove'].text = Global.ln.get('window-media-removefile');
                this._preview.preview(Global.econfig.player + 'movie/' + GlobalPlayer.movie.mvId + '.movie/media/' + this._type + '/' + this._path + this.ui.lists['fileslist'].selectedItem.text);
            }
            this.ui.buttons['btadd'].enabled = true;
            this.ui.buttons['btadd'].visible = true;
        }
    }

    /**
        Creates a folder.
    **/
    private function onNewFolder(evt:TriggerEvent):Void {
        this._preview.onStop(null);
        if (this.ui.inputs['newfolder'].text == '') {
            this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-newfoldernoname'), 300, 180, this.stage);
        } else {
            this.ui.setListValues('fileslist', [ ]);
            this.ui.labels['filestitle'].text = Global.ln.get('window-media-wait');
            this.ui.buttons['btadd'].text = '';
            this.ui.buttons['btadd'].enabled = false;
            this.ui.buttons['btadd'].visible = false;
            this.ui.buttons['btremove'].enabled = false;
            this.ui.buttons['btremove'].visible = false;
            this._preview.hide();
            Global.ws.send('Media/NewFolder', [ 'movie' => GlobalPlayer.movie.mvId, 'type' => this._type, 'path' => this._path, 'name' => this.ui.inputs['newfolder'].text ], this.onNewFolderReturn);
            this.ui.inputs['newfolder'].text = '';
        }
    }

    /**
        New folder return.
    **/
    private function onNewFolderReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-newfolderer'), 300, 180, this.stage);
        } else {
            if (ld.map['e'] == 0) {
                this.onList(ok, ld);
            } else {
                this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-newfolderer'), 300, 180, this.stage);
            }
        }
    }

    /**
        Removes the selected file or folder?
    **/
    private function onRemove(evt:TriggerEvent):Void {
        this._preview.onStop(null);
        this.ui.createConfirm(Global.ln.get('window-media-title'), Global.ln.get('window-media-removewarn'), 400, 220, onRealRemove, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
    }

    /**
        Remove item confirmation.
    **/
    private function onRealRemove(ok:Bool):Void {
        if (ok) {
            if (this.ui.lists['fileslist'].selectedItem.type == 'd') {
                Global.ws.send('Media/DeleteFolder', [ 'movie' => GlobalPlayer.movie.mvId, 'type' => this._type, 'path' => this._path, 'name' => this.ui.lists['fileslist'].selectedItem.text ], this.onRemoveFolder);
            } else if (this.ui.lists['fileslist'].selectedItem.type == 'f') {
                Global.ws.send('Media/DeleteFile', [ 'movie' => GlobalPlayer.movie.mvId, 'type' => this._type, 'path' => this._path, 'name' => this.ui.lists['fileslist'].selectedItem.text ], this.onRemoveFile);
            }
        }
    }

    /**
        Remove folder return.
    **/
    private function onRemoveFolder(ok:Bool, ld:DataLoader):Void {
        this._preview.onStop(null);
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-removedirer'), 300, 180, this.stage);
        } else {
            if (ld.map['e'] == 0) {
                this.loadPath();
            } else {
                this.ui.createWarning(Global.ln.get('window-media-title'), Global.ln.get('window-media-removedirer'), 300, 180, this.stage);
            }
        }
    }

    /**
        Remove file return.
    **/
    private function onRemoveFile(ok:Bool, ld:DataLoader):Void {
        this._preview.onStop(null);
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
        this._preview.onStop(null);
        Global.up.browseForMedia(onFileSelcted, this._type);
    }

    /**
        A new file was selected.
        @param  ok  file correctly selected?
    **/
    private function onFileSelcted(ok:Bool):Void {
        this._preview.onStop(null);
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