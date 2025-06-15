/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.media;

/** OPENFL **/
import feathers.controls.Label;
import com.tilbuci.data.GlobalPlayer;
import openfl.events.Event;
import feathers.events.TriggerEvent;
import openfl.Lib;
import openfl.net.URLRequest;

/** TILBUCI **/
import com.tilbuci.data.Global;
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;

class WindowMediaEmbed extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-mdembed-title'), 1000, 430, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        this.addForm('embed', this.ui.createColumnHolder('embedcol',
            this.ui.forge('left', [
                { tp: 'Label', id: 'available', tx: Global.ln.get('window-mdembed-available'), vr: '' }, 
                { tp: 'List', id: 'available', vl: [ ], sl: null, ht: 260 }, 
                { tp: 'Button', id: 'show', tx: Global.ln.get('window-mdembed-show'), ac: this.onShow },
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-mdembed-remove'), ac: this.onRemove },
            ]),
            this.ui.forge('right', [
                { tp: 'Label', id: 'add', tx: Global.ln.get('window-mdembed-add'), vr: '' }, 
                { tp: 'Label', id: 'addabout', tx: Global.ln.get('window-mdembed-addabout'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Spacer', id: 'addabout', ht: 152, ln: false }, 
                { tp: 'Label', id: 'addname', tx: Global.ln.get('window-mdembed-addname'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'addname', vl: '', vr: '' }, 
                { tp: 'Button', id: 'addselect', tx: Global.ln.get('window-mdembed-addselect'), ac: this.onSelectZip },
            ]),
        ));
        this.ui.labels['addabout'].wordWrap = true;
    }

    /**
        Opening the window.
    **/
    override public function acStart():Void {
        this.loadList();
    }

    /**
        Loading initial list.
    **/
    private function loadList():Void {
        this.ui.setListValues('available', [ ]);
        this.ui.inputs['addname'].text = '';
        Global.ws.send('Media/Embed', [
            'movie' => GlobalPlayer.movie.mvId, 
        ], onList);
    }

    /**
        Embed content list received.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                var list:Array<String> = cast ld.map['list'];
                if (list == null) {
                    Global.showMsg(Global.ln.get('window-mdembed-listerror'));
                } else if (list.length == 0) {
                    Global.showMsg(Global.ln.get('window-mdembed-listempty'));
                } else {
                    var av:Array<Dynamic> = [ ];
                    for (l in list) av.push({
                        text: l, 
                        value: l
                    });
                    this.ui.setListValues('available', av);
                }
            } else {
                Global.showMsg(Global.ln.get('window-mdembed-listerror'));
            }
        } else {
            Global.showMsg(Global.ln.get('window-mdembed-listerror'));
        }
    }

    /**
        Selects a zip file to upload.
    **/
    private function onSelectZip(evt:TriggerEvent):Void {
        this.ui.inputs['addname'].text = StringTools.replace(this.ui.inputs['addname'].text, ' ', '');
        this.ui.inputs['addname'].text = StringTools.trim(this.ui.inputs['addname'].text);
        if (this.ui.inputs['addname'].text.length < 5) {
            this.ui.createWarning(Global.ln.get('window-mdembed-title'), Global.ln.get('window-mdembed-smallname'), 300, 180, this.stage);
        } else {
            Global.up.browseForMedia(onFileSelected, 'embed');
        }
    }

    /**
        A new file was selected.
        @param  ok  file correctly selected?
    **/
    private function onFileSelected(ok:Bool):Void {
        if (ok) {
            Global.up.uploadMedia(onUploadReturn, [
                'movie' => GlobalPlayer.movie.mvId,  
                'type' => 'embed', 
                'path' => this.ui.inputs['addname'].text, 
            ]);
        }
    }

    /**
        Upload return.
    **/
    private function onUploadReturn(ok:Bool, data:Map<String, Dynamic> = null):Void {
        if (ok) {
            Global.ws.send('Media/EmbedImport', [
                'movie' => GlobalPlayer.movie.mvId,  
                'name' => this.ui.inputs['addname'].text, 
            ], onZipReturn);
        } else {
            this.ui.createWarning(Global.ln.get('window-mdembed-title'), Global.ln.get('window-mdembed-uperror'), 320, 180, this.stage);
        }
    }

    /**
       Zip import return.
    **/
    private function onZipReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                this.loadList();
            } else {
                this.ui.createWarning(Global.ln.get('window-mdembed-title'), Global.ln.get('window-mdembed-uperror'), 320, 180, this.stage);    
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-mdembed-title'), Global.ln.get('window-mdembed-uperror'), 320, 180, this.stage);
        }
    }

    /**
        Shows an embed content.
    **/
    private function onShow(evt:TriggerEvent):Void {
        if (this.ui.lists['available'].selectedItem != null) {
            var url:String = StringTools.replace(Global.ws.url, '/ws', '/movie') + '/' + GlobalPlayer.movie.mvId + '.movie/media/embed/' + this.ui.lists['available'].selectedItem.value + '/index.html';
            var req:URLRequest = new URLRequest(url);
            req.method = 'GET';
            Lib.getURL(req);
        }
    }

    /**
        Ask for content removal confirmation.
    **/
    private function onRemove(evt:TriggerEvent):Void {
        if (this.ui.lists['available'].selectedItem != null) {
            this.ui.createConfirm(Global.ln.get('window-mdembed-title'), Global.ln.get('window-mdembed-removeconfirm'), 320, 230, onRemoveConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
        }
    }

    /**
        Check for actual content removal.
    **/
    private function onRemoveConfirm(ok:Bool):Void {
        if (ok) {
            Global.ws.send('Media/EmbedRemove', [
                'movie' => GlobalPlayer.movie.mvId, 
                'name' => this.ui.lists['available'].selectedItem.value,
            ], onRemoveReturn);
        }
    }

    /**
        Remove content return.
    **/
    private function onRemoveReturn(ok:Bool, ld:DataLoader):Void {
        this.loadList();
    }

}