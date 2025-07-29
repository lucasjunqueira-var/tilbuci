/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
import openfl.events.Event;
import com.tilbuci.data.GlobalPlayer;
import openfl.text.TextField;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.text.TextFieldAutoSize;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.BuildInfo;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.Global;
import com.tilbuci.font.EmbedFont;
import com.tilbuci.data.DataLoader;

class WindowNotes extends PopupWindow {

    // guideline notes
    private var _guideline:Array<NoteItem> = [ ];

    // movie notes
    private var _movie:Array<NoteItem> = [ ];

    // scene notes
    private var _scene:Array<NoteItem> = [ ];

    // personal notes
    private var _own:Array<NoteItem> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {

        // creating window
        super(ac, Global.ln.get('window-notes-title'), 1000, InterfaceFactory.pickValue(570, 600), true, true);

        // movie gudelines
        this.addForm(Global.ln.get('window-notes-movie'), this.ui.forge('guidelines', [
            { tp: 'TArea', id: 'guidelines', ht: 400, tx: '', vr: ''}, 
            { tp: 'Select', id: 'guidelines', vl: [ ], sl: [ ], ch: onGuideChange }, 
            { tp: 'Spacer', id: 'guidelines', ht: 10, ln: false }, 
            { tp: 'Button', id: 'guidelines', tx: Global.ln.get('window-notes-btguidelines'), vr: '', ac: onGuidelines }, 
        ]));

        // movie notes
        this.addForm(Global.ln.get('window-notes-movienotes'), this.ui.forge('movienotes', [
            { tp: 'TArea', id: 'movie', ht: 400, tx: '', vr: ''}, 
            { tp: 'Select', id: 'movie', vl: [ ], sl: [ ], ch: onMovieChange }, 
            { tp: 'Spacer', id: 'movie', ht: 10, ln: false }, 
            { tp: 'Button', id: 'movie', tx: Global.ln.get('window-notes-btmovie'), vr: '', ac: onMovie }, 
        ]));

        // scene notes
        this.addForm(Global.ln.get('window-notes-scenenotes'), this.ui.forge('scenenotes', [
            { tp: 'TArea', id: 'scene', ht: 400, tx: '', vr: ''}, 
            { tp: 'Select', id: 'scene', vl: [ ], sl: [ ], ch: onSceneChange }, 
            { tp: 'Spacer', id: 'scene', ht: 10, ln: false }, 
            { tp: 'Button', id: 'scene', tx: Global.ln.get('window-notes-btscene'), vr: '', ac: onScene }, 
        ]));

        // personal notes
        this.addForm(Global.ln.get('window-notes-ownnotes'), this.ui.forge('ownnotes', [
            { tp: 'TArea', id: 'own', ht: 400, tx: '', vr: ''}, 
            { tp: 'Select', id: 'own', vl: [ ], sl: [ ], ch: onOwnChange }, 
            { tp: 'Spacer', id: 'own', ht: 10, ln: false }, 
            { tp: 'Button', id: 'own', tx: Global.ln.get('window-notes-btown'), vr: '', ac: onOwn }, 
        ]));

        // adjusting sizes
        this.redraw();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        Global.ws.send('Movie/Notes', [
            'movie' => GlobalPlayer.movie.mvId, 
            'scene' => GlobalPlayer.movie.scId
        ], this.onReceived);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /** PRVATE METHODS **/

    /**
        The notes were received.
    **/
    private function onReceived(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                this.setContent(ld);
            } else {
                this.ui.createWarning(Global.ln.get('window-notes-title'), Global.ln.get('window-notes-nonotes'), 300, 150, this.stage);    
                PopUpManager.removePopUp(this);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-notes-title'), Global.ln.get('window-notes-nonotes'), 300, 150, this.stage);
            PopUpManager.removePopUp(this);
        }
    }

    private function onGuideChange(evt:Event):Void {
        if (this._guideline.length > 0) {
            this.ui.tareas['guidelines'].text = this._guideline[this.ui.selects['guidelines'].selectedIndex].text;
        } else {
            this.ui.tareas['guidelines'].text = '';
        }
    }

    private function onMovieChange(evt:Event):Void {
        if (this._movie.length > 0) {
            this.ui.tareas['movie'].text = this._movie[this.ui.selects['movie'].selectedIndex].text;
        } else {
            this.ui.tareas['movie'].text = '';
        }
    }

    private function onSceneChange(evt:Event):Void {
        if (this._scene.length > 0) {
            this.ui.tareas['scene'].text = this._scene[this.ui.selects['scene'].selectedIndex].text;
        } else {
            this.ui.tareas['scene'].text = '';
        }
    }

    private function onOwnChange(evt:Event):Void {
        if (this._own.length > 0) {
            this.ui.tareas['own'].text = this._own[this.ui.selects['own'].selectedIndex].text;
        } else {
            this.ui.tareas['own'].text = '';
        }
    }

    /**
        Save guidelines button click.
    **/
    private function onGuidelines(evt:TriggerEvent):Void {
        if (Global.mvOwner) {
            Global.ws.send('Movie/SaveNote', [
                'movie' => GlobalPlayer.movie.mvId, 
                'scene' => GlobalPlayer.movie.scId, 
                'type' => 'guide', 
                'text' => this.ui.tareas['guidelines'].text, 
            ], this.onSaved);
        }
    }

    /**
        Save movie button click.
    **/
    private function onMovie(evt:TriggerEvent):Void {
        if (GlobalPlayer.movie.mvId != '') {
            Global.ws.send('Movie/SaveNote', [
                'movie' => GlobalPlayer.movie.mvId, 
                'scene' => GlobalPlayer.movie.scId, 
                'type' => 'movie', 
                'text' => this.ui.tareas['movie'].text, 
            ], this.onSaved);
        }
    }

    /**
        Save scene button click.
    **/
    private function onScene(evt:TriggerEvent):Void {
        if (GlobalPlayer.movie.scId != '') {
            Global.ws.send('Movie/SaveNote', [
                'movie' => GlobalPlayer.movie.mvId, 
                'scene' => GlobalPlayer.movie.scId, 
                'type' => 'scene', 
                'text' => this.ui.tareas['scene'].text, 
            ], this.onSaved);
        }
    }

    /**
        Save personal button click.
    **/
    private function onOwn(evt:TriggerEvent):Void {
        Global.ws.send('Movie/SaveNote', [
            'movie' => GlobalPlayer.movie.mvId, 
            'scene' => GlobalPlayer.movie.scId, 
            'type' => 'own', 
            'text' => this.ui.tareas['own'].text, 
        ], this.onSaved);
    }

    /**
        The note was saved.
    **/
    private function onSaved(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                Global.showMsg(Global.ln.get('window-notes-oksave'));
                this.setContent(ld);
            } else {
                this.ui.createWarning(Global.ln.get('window-notes-title'), Global.ln.get('window-notes-nosave'), 300, 150, this.stage);    
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-notes-title'), Global.ln.get('window-notes-nosave'), 300, 150, this.stage);
        }
    }

    /**
        Sets the window content
    **/
    private function setContent(ld:DataLoader):Void {
        while (this._guideline.length > 0) this._guideline.shift();
        while (this._movie.length > 0) this._movie.shift();
        while (this._scene.length > 0) this._scene.shift();
        while (this._own.length > 0) this._own.shift();

        this._guideline = cast(Reflect.field(ld.map['notes'], 'guidelines'));
        this._movie = cast(Reflect.field(ld.map['notes'], 'movie'));
        this._scene = cast(Reflect.field(ld.map['notes'], 'scene'));
        this._own = cast(Reflect.field(ld.map['notes'], 'own'));

        if (this._guideline.length > 0) {
            var list:Array<Dynamic> = [ ];
            for (n in this._guideline) {
                var bytxt:String = Global.ln.get('window-notes-bywhen');
                bytxt = StringTools.replace(bytxt, '[AUTHOR]', n.author);
                bytxt = StringTools.replace(bytxt, '[TIME]', n.time);
                list.push({
                    text: bytxt, 
                    value: n.id
                });
            }
            this.ui.setSelectOptions('guidelines', list);
            this.ui.selects['guidelines'].selectedIndex = 0;
            this.ui.tareas['guidelines'].text = this._guideline[0].text;
        } else {
            this.ui.tareas['guidelines'].text = '';
            this.ui.setSelectOptions('guidelines', [ ]);
            this.ui.setSelectValue('guidelines', null);
        }
        this.ui.buttons['guidelines'].enabled = Global.mvOwner;

        if (this._movie.length > 0) {
            var listm:Array<Dynamic> = [ ];
            for (n in this._movie) {
                var bytxt:String = Global.ln.get('window-notes-bywhen');
                bytxt = StringTools.replace(bytxt, '[AUTHOR]', n.author);
                bytxt = StringTools.replace(bytxt, '[TIME]', n.time);
                listm.push({
                    text: bytxt, 
                    value: n.id
                });
            }
            this.ui.setSelectOptions('movie', listm);
            this.ui.selects['movie'].selectedIndex = 0;
            this.ui.tareas['movie'].text = this._movie[0].text;
        } else {
            this.ui.tareas['movie'].text = '';
            this.ui.setSelectOptions('movie', [ ]);
            this.ui.setSelectValue('movie', null);
        }
        this.ui.buttons['movie'].enabled = (Global.mvOwner || (Global.ws.level < 50));

        if (this._scene.length > 0) {
            var lists:Array<Dynamic> = [ ];
            for (n in this._scene) {
                var bytxt:String = Global.ln.get('window-notes-bywhen');
                bytxt = StringTools.replace(bytxt, '[AUTHOR]', n.author);
                bytxt = StringTools.replace(bytxt, '[TIME]', n.time);
                lists.push({
                    text: bytxt, 
                    value: n.id
                });
            }
            this.ui.setSelectOptions('scene', lists);
            this.ui.selects['scene'].selectedIndex = 0;
            this.ui.tareas['scene'].text = this._scene[0].text;
        } else {
            this.ui.tareas['scene'].text = '';
            this.ui.setSelectOptions('scene', [ ]);
            this.ui.setSelectValue('scene', null);
        }
        this.ui.buttons['scene'].enabled = GlobalPlayer.movie.scId != '';

        if (this._own.length > 0) {
            var listo:Array<Dynamic> = [ ];
            for (n in this._own) {
                listo.push({
                    text: n.time, 
                    value: n.id
                });
            }
            this.ui.setSelectOptions('own', listo);
            this.ui.selects['own'].selectedIndex = 0;
            this.ui.tareas['own'].text = this._own[0].text;
        } else {
            this.ui.tareas['own'].text = '';
            this.ui.setSelectOptions('own', [ ]);
            this.ui.setSelectValue('own', null);
        }
        this.ui.buttons['own'].enabled = true;
    }
}

typedef NoteItem = {
    var id:Int;
    var text:String;
    var author:String;
    var time:String;
}