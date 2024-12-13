package com.tilbuci.ui.window.media;

/** OPENFL **/
import openfl.display.Shape;
import openfl.display.Sprite;
import feathers.layout.AnchorLayout;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.display.ShapeImage;
import feathers.core.FeathersControl;
import com.tilbuci.data.GlobalPlayer;
import openfl.events.Event;
import openfl.display.Stage;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.media.WindowMediaBase;
import com.tilbuci.data.Global;

class WindowMediaParagraph extends WindowMediaBase {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic, mode:String) {
        // creating window
        super(ac, Global.ln.get('window-mdparagraph-title'), 'paragraph', mode);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        super.startInterface();
        this.addForm(Global.ln.get('window-mdparagraph-title'), this.ui.forge('leftcol', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-mdparagraph-about'), vr: '' }, 
            { tp: 'TArea', id: 'text', tx: '', vr: '', en: true }, 
            { tp: 'Button', id: 'btadd', tx: Global.ln.get('window-mdparagraph-set'), ac: this.onOpen }, 
        ]));
        this.ui.tareas['text'].height = 530;
    }

    /**
        Loading initial file list.
    **/
    override public function acStart():Void {
        this._path = '';
        this.ui.tareas['text'].text = '';
        this.ui.tareas['text'].height = 530;
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Opens the current text.
    **/
    override private function onOpen(evt:TriggerEvent):Void {
        if (this.ui.tareas['text'].text != '') {
            if (this._mode == 'asset') {
                // set to asset
                this._mode = 'simple';
                this._ac('addasset', [ 'path' => '', 'type' => this._type, 'file' => this.ui.tareas['text'].text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime), 'num' => this._filenum ]);
                PopUpManager.removePopUp(this);
            } else if (this._mode == 'newasset') {
                // add new asset
                this._mode = 'simple';
                this._ac('addnewasset', [ 'path' => '', 'type' => this._type, 'file' => this.ui.tareas['text'].text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
                PopUpManager.removePopUp(this);
            } else {
                // add to stage
                this._ac('addstage', [ 'path' => '', 'type' => this._type, 'file' => this.ui.tareas['text'].text, 'frames' => Std.string(this._frames), 'frtime' => Std.string(this._frtime) ]);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        super.action(ac, data);
        this.ui.tareas['text'].text = data['current'];
    }

}