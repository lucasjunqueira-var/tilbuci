/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.movie;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.ui.component.IDButton;
import com.tilbuci.ui.base.HInterfaceContainer;
import openfl.events.Event;
import openfl.display.Stage;
import openfl.Assets;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.ui.component.ActionArea;

class WindowMovieSnippets extends PopupWindow {

    /**
        block editor
    **/
    private var _acarea:ActionArea;

    /**
        current snippets
    **/
    private var _snippets:Map<String, String>;

    /**
        warn about files?
    **/
    private var _warn:Bool = false;

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-moviesnip-title'), 1100, InterfaceFactory.pickValue(630, 660), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // preparing containers
        var grname:HInterfaceContainer = this.ui.createHContainer('grname');
        this.ui.createTInput('grname', '', '', grname);
        this.ui.createButton('grname', Global.ln.get('window-moviesnip-savegr'), onSaveGr, grname);
        grname.setWidth(510);
        var grhandle:HInterfaceContainer = this.ui.createHContainer('grhandle');
        this.ui.createButton('groupdel', Global.ln.get('window-moviesnip-del'), onDel, grhandle);
        this.ui.createButton('groupup', Global.ln.get('window-moviesnip-upload'), onUpload, grhandle);
        this.ui.createButton('groupdown', Global.ln.get('window-moviesnip-download'), onDownload, grhandle);
        grhandle.setWidth(510);
        var snname:HInterfaceContainer = this.ui.createHContainer('snname');
        this.ui.createTInput('name', '', '', snname);
        this.ui.createButton('name', Global.ln.get('window-moviesnip-setcode'), onSetCode, snname);
        snname.setWidth(510);
        this._acarea = new ActionArea(510, 442);
        // creating columns
        this.addForm(Global.ln.get('window-moviesnip-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'groups', tx: Global.ln.get('window-moviesnip-available'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'groups', vl: [ ], sl: null, ht: 150, ch: this.onLoad },  
                { tp: 'Custom', cont: grname }, 
                { tp: 'Custom', cont: grhandle }, 
                { tp: 'Spacer', id: 'groups', ht: 15, ln: true },
                { tp: 'Label', id: 'snippets', tx: Global.ln.get('window-moviesnip-snippets'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'List', id: 'snippets', vl: [ ], sl: null, ht: 247, ch: this.onLoadSnip },  
                { tp: 'Button', id: 'snippetsdel', tx: Global.ln.get('window-moviesnip-delsnip'), ac: this.onDelSnip }, 
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'code', tx: Global.ln.get('window-moviesnip-code'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Custom', cont: this._acarea }, 
                { tp: 'Spacer', id: 'code', ht: 10, ln: false },
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-moviesnip-name'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Custom', cont: snname },
                { tp: 'Button', id: 'set', tx: Global.ln.get('window-moviesnip-clear'), ac: this.onClear },
            ])));
            this.ui.listDbClick('snippets', this.onLoadSnip);
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
        this.ui.hcontainers['grname'].setWidth(510);
        this.ui.hcontainers['grhandle'].setWidth(510);
        this.ui.hcontainers['snname'].setWidth(510);
        this._acarea.setText('');
        this.ui.setListValues('groups', [ ]);
        this.ui.setListSelectValue('groups', null);
        this.ui.setListValues('snippets', [ ]);
        this.ui.setListSelectValue('snippets', null);
        this.ui.inputs['name'].text = '';
        this.ui.inputs['grname'].text = '';
        this._snippets = [ ];
        Global.ws.send('Movie/ListSnippets', [ 
            'movie' => GlobalPlayer.movie.mvId, 
        ], this.onList);
    }

    /**
        The snippets list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-nosnippets'), 420, 150, this.stage);
        } else {
            if (ld.map['e'] == 0) {
                var ar:Array<String> = cast ld.map['list'];
                if (ar != null) {
                    var list:Array<Dynamic> = [ ];
                    for (l in ar) {
                        list.push({ text: l, value: l });
                    }
                    this.ui.setListValues('groups', list);
                }
            } else {
                this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-nosnippets'), 420, 150, this.stage);
            }
        }
    }

    /**
        Loads a snippets group.
    **/
    private function onLoad(evt:TriggerEvent = null):Void {
        if (this.ui.lists['groups'].selectedItem != null) {
            Global.ws.send('Movie/LoadSnippets', [ 
                'movie' => GlobalPlayer.movie.mvId, 
                'name' => this.ui.lists['groups'].selectedItem.value, 
            ], this.onLoaded);
        }
    }

    /**
        Return from tha load snippets call.
    **/
    private function onLoaded(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-notfound'), 420, 150, this.stage);
        } else {
            if (ld.map['e'] == 0) {
                var code:String = cast ld.map['code'];
                if (code == null) {
                    this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-noload'), 420, 150, this.stage);
                } else {
                    var map:Map<String, Dynamic> = StringStatic.jsonAsMap(code);
                    if (Lambda.count(map) == 0) {
                        this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-noload'), 420, 150, this.stage);
                    } else {
                        var list:Array<Dynamic> = [ ];
                        this._snippets = [ ];
                        for (k in map.keys()) {
                            list.push({ text: k, value: k });
                            this._snippets[k] = cast map[k];
                        }
                        this.ui.setListValues('snippets', list);
                        this.ui.setListSelectValue('snippets', null);
                        this.ui.inputs['name'].text = '';
                        this._acarea.setText('');
                        this.ui.inputs['grname'].text = this.ui.lists['groups'].selectedItem.value;
                    }
                }
            } else {
                this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-noload'), 420, 150, this.stage);
            }
        }
    }

    /**
        Removes a snippets group.
    **/
    private function onDel(evt:TriggerEvent = null):Void {
        if (this.ui.lists['groups'].selectedItem != null) {
            this.ui.createConfirm(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-delconfirm'), 320, 240, this.onRemoveConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
        }
    }

    /**
        Remove group confirmation.
    **/
    private function onRemoveConfirm(ok:Bool):Void {
        if (ok) {
            Global.ws.send('Movie/RemoveSnippets', [ 
                'movie' => GlobalPlayer.movie.mvId, 
                'name' => this.ui.lists['groups'].selectedItem.value, 
            ], this.onRemoved);
        }
    }

    /**
        Return from tha remove group call.
    **/
    private function onRemoved(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-nosnippets'), 420, 150, this.stage);
        } else {
            if (ld.map['e'] == 0) {
                var ar:Array<String> = cast ld.map['list'];
                if (ar != null) {
                    var list:Array<Dynamic> = [ ];
                    for (l in ar) {
                        list.push({ text: l, value: l });
                    }
                    this.ui.setListValues('groups', list);
                    this.ui.setListSelectValue('groups', null);
                    this.ui.setListValues('snippets', [ ]);
                    this.ui.setListSelectValue('snippets', null);
                    this.ui.inputs['name'].text = '';
                    this.ui.inputs['grname'].text = '';
                    this._acarea.setText('');
                    this._snippets = [ ];
                }
            } else {
                this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-nosnippets'), 420, 150, this.stage);
            }
        }
    }

    /**
        Uploads a snippets group.
    **/
    private function onUpload(evt:TriggerEvent = null):Void {
        if (!this._warn) {
            this._warn = true;
            this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-files'), 420, 180, this.stage);
        } else {
            Global.up.browseForMedia(onFileSelected, 'snippets');
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
                'type' => 'snippets', 
                'path' => '', 
            ]);
        }
    }

    /**
        Upload return.
    **/
    private function onUploadReturn(ok:Bool, data:Map<String, Dynamic> = null):Void {
        if (ok) {
            this.ui.hcontainers['grname'].setWidth(510);
            this.ui.hcontainers['grhandle'].setWidth(510);
            this.ui.hcontainers['snname'].setWidth(510);
            this._acarea.setText('');
            this.ui.setListValues('groups', [ ]);
            this.ui.setListSelectValue('groups', null);
            this.ui.setListValues('snippets', [ ]);
            this.ui.setListSelectValue('snippets', null);
            this.ui.inputs['name'].text = '';
            this.ui.inputs['grname'].text = '';
            this._snippets = [ ];
            Global.ws.send('Movie/ListSnippets', [ 
                'movie' => GlobalPlayer.movie.mvId, 
            ], this.onList);
        } else {
            this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-erupload'), 420, 150, this.stage);
        }
    }

    /**
        Downloads a snippets group.
    **/
    private function onDownload(evt:TriggerEvent = null):Void {
        if (!this._warn) {
            this._warn = true;
            this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-files'), 420, 180, this.stage);
        } else {
            if (this.ui.lists['groups'].selectedItem != null) {
                Global.ws.download([
                    'file' => 'snippets', 
                    'media' => this.ui.lists['groups'].selectedItem.value, 
                    'movie' => GlobalPlayer.movie.mvId,  
                ]);
            }
        }
    }

    /**
        Loads a snippet.
    **/
    private function onLoadSnip(evt:TriggerEvent = null):Void {
        if (this.ui.lists['snippets'].selectedItem != null) {
            if (this._snippets.exists(this.ui.lists['snippets'].selectedItem.value)) {
                this.ui.inputs['name'].text = this.ui.lists['snippets'].selectedItem.value;
                this._acarea.setText(this._snippets[this.ui.lists['snippets'].selectedItem.value]);
            }
        }
    }

    /**
        Removes a snippet.
    **/
    private function onDelSnip(evt:TriggerEvent = null):Void {
        if (this.ui.lists['snippets'].selectedItem != null) {
            this.ui.createConfirm(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-delsnconfirm'), 320, 240, this.onRemoveSnConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
        }
    }

    /**
        Remove snippet confirmation.
    **/
    private function onRemoveSnConfirm(ok:Bool):Void {
        if (ok) {
            if (this._snippets.exists(this.ui.lists['snippets'].selectedItem.value)) {
                this._snippets.remove(this.ui.lists['snippets'].selectedItem.value);
                this.updateSnippetsList();
            }
        }
    }

    /**
        Sets a snippet code.
    **/
    private function onSetCode(evt:TriggerEvent = null):Void {
        if (StringTools.replace(this.ui.inputs['name'].text, ' ', '').length < 3) {
            this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-shortsnname'), 420, 150, this.stage);
        } else {
            var actext:String = this._acarea.getText();
            if (actext != '') {
                this._snippets[StringTools.replace(this.ui.inputs['name'].text, ' ', '')] = actext;
                this._acarea.setText('');
                this.ui.inputs['name'].text = '';
                this.updateSnippetsList();
            }
        }
    }

    /**
        Clears the snippet code.
    **/
    private function onClear(evt:TriggerEvent = null):Void {
        this._acarea.setText('');
        this.ui.inputs['name'].text = '';
        this.updateSnippetsList();
    }

    /**
        Updates the snippets list.
    **/
    private function updateSnippetsList():Void {
        var list:Array<Dynamic> = [ ];
        for (k in this._snippets.keys()) {
            list.push({ text: k, value: k });
        }
        this.ui.setListValues('snippets', list);
        this.ui.setListSelectValue('snippets', null);
    }

    /**
        Saves the current snippet group.
    **/
    private function onSaveGr(evt:TriggerEvent = null):Void {
        if (StringTools.replace(this.ui.inputs['grname'].text, ' ', '').length < 3) {
            this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-shortgrname'), 420, 150, this.stage);
        } else if (Lambda.count(this._snippets) < 1) {
            this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-nogrsnip'), 420, 150, this.stage);
        } else {
            Global.ws.send('Movie/SaveSnippets', [ 
                'movie' => GlobalPlayer.movie.mvId, 
                'name' => StringTools.replace(this.ui.inputs['grname'].text, ' ', ''), 
                'code' => StringStatic.jsonStringify(this._snippets), 
            ], this.onGrSaved);
        }
    }

    /**
        Return from tha save group call.
    **/
    private function onGrSaved(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-nosnippets'), 420, 150, this.stage);
        } else {
            if (ld.map['e'] == 0) {
                this.ui.setListValues('groups', [ ]);
                this.ui.setListSelectValue('groups', null);
                this.ui.setListValues('snippets', [ ]);
                this.ui.setListSelectValue('snippets', null);
                this.ui.inputs['name'].text = '';
                this._acarea.setText('');
                this.ui.inputs['grname'].text = '';
                var ar:Array<String> = cast ld.map['list'];
                if (ar != null) {
                    var list:Array<Dynamic> = [ ];
                    for (l in ar) list.push({ text: l, value: l });
                    this.ui.setListValues('groups', list);
                }
            } else {
                this.ui.createWarning(Global.ln.get('window-moviesnip-title'), Global.ln.get('window-moviesnip-nosnippets'), 420, 150, this.stage);
            }
        }
    }

}