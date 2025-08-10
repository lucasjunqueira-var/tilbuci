/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.data;

/** HAXE **/
import openfl.events.SecurityErrorEvent;
import js.html.FileReader;
import feathers.controls.HProgressBar;
import haxe.crypto.Base64;

/** OPENFL **/
import openfl.events.IOErrorEvent;
import openfl.display.Stage;
import openfl.events.EventDispatcher;
import openfl.net.FileReference;
import openfl.net.FileFilter;
import openfl.events.Event;

/** FEATHERS UI **/
import feathers.events.TriggerEvent;
import feathers.controls.Label;
import feathers.controls.Header;
import feathers.layout.VerticalLayout;
import feathers.controls.Button;
import feathers.controls.Panel;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.Global;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.base.BackgroundSkin;
#if (js && html5)
    import com.tilbuci.js.ExternUpload;
#end

class FileUpload extends EventDispatcher {

    /**
        the file reference object
    **/
    private var _ref:FileReference;

    /**
        action to call after seleciont a file
    **/
    private var _ac:Dynamic;

    /**
        extra fields to send on file upload
    **/
    private var _extra:Map<String, Dynamic> = [ ];

    /**
        file type to upload
    **/
    private var _uploadType = '';

    /**
        a reference to the display stage
    **/
    private var _stage:Stage;

    /**
        the upload interface
    **/
    private var _interface:Panel;

    /**
        the file name label
    **/
    private var _fname:Label;

    /**
        the progress bar
    **/
    private var _bar:HProgressBar;

    /**
        the cancel button
    **/
    private var _bt:Button;

    /**
        the data loader
    **/
    private var _loader:DataLoader;

    /**
        a loader for local files
    **/
    private var _localLoad:FileReference;

    /**
        function to call on local load complete
    **/
    private var _llComplete:Dynamic;

    #if (js && html5)

        /**
            external interface selected file name
        **/
        private var _externName:String = '';

    #end

    /**
        selected file name
    **/
    public var selectedName(get, null):String;
    private function get_selectedName():String { 
        var nm:String = '';
        #if (js && html5)
            nm = this._externName;
        #else
            try {
                nm = this._ref.name;
            } catch (e) {
                nm = '';
            }
        #end
        return (nm);
    }

    /**
        Creator.
    **/
    public function new(st:Stage) {
        super();
        this._ref = new FileReference();
        this._ref.addEventListener(Event.SELECT, onFileSelect);
        this._ref.addEventListener(Event.CANCEL, onFileCancel);
        this._ref.addEventListener(Event.COMPLETE, onLoadComplete);
        this._ref.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
        this._stage = st;

        // interface
        this._interface = new Panel();
        var lay:VerticalLayout = new VerticalLayout();
        lay.setPadding(10);
        lay.gap = 20;
        lay.verticalAlign = TOP;
        lay.horizontalAlign = LEFT;
        this._interface.backgroundSkin = new BackgroundSkin(0x383838);
        this._interface.layout = lay;
        this._interface.width = 500;
        this._interface.height = 180;
        var hd:Header = new Header();
        hd.text = Global.ln.get('uploader-title');
        this._interface.header = hd;
        this._fname = new Label();
        this._fname.text = '';
        this._fname.wordWrap = false;
        this._fname.width = this._interface.width - 30;
        this._interface.addChild(this._fname);
        this._bar = new HProgressBar(0, 0, 1);
        this._bar.width = this._interface.width - 30;
        this._interface.addChild(this._bar);
        this._bt = new Button();
        this._bt.text = Global.ln.get('default-cancel');
        this._bt.addEventListener(TriggerEvent.TRIGGER, onCancel);
        this._bt.width = this._interface.width - 30;
        this._interface.addChild(this._bt);

        // local loader
        this._localLoad = new FileReference();
        this._localLoad.addEventListener(Event.SELECT, onLocalLoaded);
        this._localLoad.addEventListener(Event.COMPLETE, onLocalComplete);
        this._localLoad.addEventListener(IOErrorEvent.IO_ERROR, onLocalError);
        this._localLoad.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLocalError);
    }

    /**
        Selectting a font file.
        @param  ac  action to call after file select
    **/
    public function browseForFont(ac:Dynamic):Bool {
        this._ac = ac;
        #if (js && html5)
            ExternUpload.TBU_browse('.woff2,.woff');
            return (true);
        #else
            return (this._ref.browse([ new FileFilter(Global.ln.get('uploader-fontname'), "*.woff2,*.woff") ]));
        #end
    }

    /**
        Uploads a font file.
        @param  ac  method to call on upload update
        @return upload started (font selected)?
    **/
    public function uploadFont(ac:Dynamic, extra:Map<String, Dynamic>):Bool {
        if (StringStatic.stringContains(this.selectedName, ['.woff'])) {
            this._uploadType = 'Font';
            this._ac = ac;
            this._extra = extra;
            if (this._extra.exists('movie')) {
                this._extra['path'] = '../movie/' + this._extra['movie'] + '.movie/media/font/';
            } else {
                this._extra['path'] = '../font/';
            }
            this._fname.text = this.selectedName;
            this._bar.minimum = this._bar.value = 0;
            this._bar.maximum = 100;
            PopUpManager.addPopUp(this._interface, this._stage);
            #if (js && html5)
                this.sendExtern('File/ExtFont');
            #else
                this._ref.load();
            #end
            return (true);
        } else {
            // not a font
            return (false);
        }
    }

    /**
        Selectting a media file.
        @param  ac  action to call after file select
        @param  type    the media type
    **/
    public function browseForMedia(ac:Dynamic, type:String):Bool {
        var ext:String = '';
        var title:String = '';
        switch (type) {
            case 'picture':
                ext = '.jpg,.png,.jpeg';
                title = Global.ln.get('uploader-picturename');
            case 'audio':
                ext = '.mp3,.m4a';
                title = Global.ln.get('uploader-audioname');
            case 'video':
                ext = '.mp4,.webm';
                title = Global.ln.get('uploader-videoname');
            case 'html':
                ext = '.html,.htm';
                title = Global.ln.get('uploader-htmlname');
            case 'spritemap':
                ext = '.png';
                title = Global.ln.get('uploader-spritemapname');
            case 'movie':
                ext = '.zip';
                title = Global.ln.get('uploader-moviename');
            case 'embed':
                ext = '.zip';
                title = Global.ln.get('uploader-embedname');
            case 'strings':
                ext = '.json';
                title = Global.ln.get('uploader-stringsname');
            case 'update':
                ext = '.zip';
                title = Global.ln.get('uploader-updatename');
        }
        if (ext != '') {
            this._ac = ac;
            #if (js && html5)
                ExternUpload.TBU_browse(ext);
                return (true);
            #else
                return (this._ref.browse([ new FileFilter(title, ext) ]));
            #end
        } else {
            return (false);
        }
    }

    /**
        Uploads a media file.
        @param  ac  method to call on upload update
    **/
    public function uploadMedia(ac:Dynamic, extra:Map<String, Dynamic>):Void {
        this._uploadType = extra['type'];
        this._ac = ac;
        this._extra = extra;
        this._fname.text = this.selectedName;
        this._bar.minimum = this._bar.value = 0;
        this._bar.maximum = 100;
        PopUpManager.addPopUp(this._interface, this._stage);
        #if (js && html5)
            this.sendExtern('Media/ExtUpload');
        #else
            this._ref.load();
        #end
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this._ref.removeEventListener(Event.SELECT, onFileSelect);
        this._ref.removeEventListener(Event.CANCEL, onFileCancel);
        this._ref.removeEventListener(Event.COMPLETE, onLoadComplete);
        this._ref.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
        this._ref = null;
        this._ac = null;
        this._extra = null;
        this._loader = null;
        this._stage = null;
        this._interface.removeChildren();
        this._interface = null;
        this._fname = null;
        this._bar = null;
        this._bt.removeEventListener(TriggerEvent.TRIGGER, onCancel);
        this._bt = null;
    }

    /**
        Sends a file to the server.
        @param  to  service to receive the file
        @param  ac  method to call on upload update
        @param  req additional parameters to send on request
    **/
    private function send(to:String, content:String):Void {
        var req:Map<String, String> = [
            'fname' => this.selectedName, 
            'fcontent' => content
        ];
        if (this._extra != null) for (name in this._extra.keys()) req[name] = this._extra[name];
        var txt:String = StringStatic.jsonStringify(req);
        this._loader = new DataLoader(true, Global.ws.url, 'POST', [
            'r' => txt, 
            's' => StringStatic.md5(Global.ws.key + txt), 
            'u' => Global.ws.user, 
            'a' => to
        ], DataLoader.MODEMAP, onUpload, onProgress);
    }

    #if (js && html5)
        /**
            Sends a file to the server.
            @param  ac  method to call on upload update
            @param  req additional parameters to send on request
        **/
        private function sendExtern(to:String):Void {
            var req:Map<String, String> = [
                'fname' => this.selectedName
            ];
            if (this._extra != null) for (name in this._extra.keys()) req[name] = this._extra[name];
            var txt:String = StringStatic.jsonStringify(req);
            ExternUpload.TBU_upload(to, txt, Global.ws.user, StringStatic.md5(Global.ws.key + txt), Global.ws.url);
        }
    #end

    /** EVENTS **/

    /**
        Upload completed.
    **/
    private function onUpload(ok:Bool, ld:DataLoader):Void {
        PopUpManager.removePopUp(this._interface);
        this._loader = null;
        if (ok) {
            this._ac(true, ld.map);
        } else {
            this._ac(false, null);
        }
        this._ac = null;
    }

    #if (js && html5)
        /**
            Upload completed.
        **/
        public function onUploadExtern(ok:Bool, data:String):Void {
            PopUpManager.removePopUp(this._interface);
            if (ok) {
                this._ac(true, StringStatic.jsonAsMap(data));
            } else {
                this._ac(false, null);
            }
            this._ac = null;
        }
    #end

    /**
        Upload progress.
    **/
    private function onProgress(loaded:Float, total:Float):Void {
        if (total > 0) {
            this._bar.minimum = 0;
            this._bar.value = loaded;
            this._bar.maximum = total;
        }
    }

    #if (js && html5)
        /**
            Upload progress.
        **/
        public function onProgressExtern(current:Int, total:Int):Void {
            if (total > 0) {
                this._bar.minimum = 0;
                this._bar.value = current;
                this._bar.maximum = total;
            }
        }
    #end

    /**
        Upload cancelled.
    **/
    private function onCancel(evt:TriggerEvent):Void {
        #if (js && html5)
            ExternUpload.TBU_cancelUpload();
        #else
            this._ref.cancel();
            this._ac = null;
            this._extra = null;
            if (this._loader != null) this._loader.cancel();
            this._loader = null;
            PopUpManager.removePopUp(this._interface);
        #end
    }

    #if (js && html5)
        /**
            Upload cancelled.
        **/
        public function onCancelExtern():Void {
            this._extra = null;
            PopUpManager.removePopUp(this._interface);
            this._ac(false);
            this._ac = null;
        }
    #end

    /**
        File browse cancelled.
    **/
    private function onFileCancel(evt:Event):Void {
        this._ac(false);
    }

    /**
        A file was selected for upload.
    **/
    private function onFileSelect(evt:Event):Void {
        this._ac(true);
    }

    #if (js && html5)
        /**
            A file was selected at the external interface.
            @param  name    the selected file name
        **/
        public function onFileSelectExtern(name:String):Void {
            this._externName = name;
            this._ac(true);
        }
    #end

    /**
        File load complete.
    **/
    private function onLoadComplete(evt:Event):Void {
        this.send(('File/'+this._uploadType), Base64.encode(this._ref.data));
    }

    /**
        File load error.
    **/
    private function onLoadIOError(evt:IOErrorEvent):Void {
        this._uploadType = '';
        this._ac(false);
        this._ac = null;
    }

    /**
        Selects a local file.
        @param  ac  action to call after load process
        @param  name    file name for browse window
        @param  ext file extension for browse window
    **/
    public function selectFile(ac:Dynamic, name:String, ext:String):Void {
        this._llComplete = ac;
        var filter:FileFilter = new FileFilter(name, ext);
        this._localLoad.browse([filter]);
    }

    /**
        Local file selected.
    **/
    private function onLocalLoaded(evt:Event):Void {
        this._localLoad.load();
    }

    /**
        Local file loaded.
    **/
    private function onLocalComplete(evt:Event):Void {
        this._llComplete(true, this._localLoad.data);
    }

    /**
        Local file load error.
    **/
    private function onLocalError(evt:Event):Void {
        this._llComplete(false);
    }

    #if (js && html5)

        /**
            Sets the selected file information.
            @param  name    the file name
            @param  size    the file size (text)
            @param  type    the file type
            @param  pieces  number of parts for upload
        **/
        @:expose("TBU_setFile")
        public static function TBU_setFile(name:String, size:String, type:String, pieces:Int):Void {
            Global.up.onFileSelectExtern(name);
        }

        /**
            Sets the current upload progress display.
            @param  part    current upload part
            @param  total   total number of parts
            @param  complete    file completely uploaded?
            @param  data    addition data
        **/
        @:expose("TBU_setProgress")
        public static function TBU_setProgress(part:Int, total:Int, complete:Bool, data:String = ''):Void {
            Global.up.onProgressExtern(part, total);
            if (complete) Global.up.onUploadExtern(true, data);
        }

        /**
            Upload failed.
        **/
        @:expose("TBU_setFailed")
        public static function TBU_setFailed():Void {
            Global.up.onCancelExtern();
        }

        /**
            Upload aborted.
        **/
        @:expose("TBU_setAborted")
        public static function TBU_setAborted():Void {
            Global.up.onCancelExtern();
        }

    #end

}