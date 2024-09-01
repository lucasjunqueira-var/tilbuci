package com.tilbuci.ui.component;

/** FEATHERS UI **/
import com.tilbuci.data.Global;
import haxe.Timer;
import com.tilbuci.data.GlobalPlayer;
import openfl.events.MouseEvent;
import feathers.layout.RelativePosition;
import feathers.controls.TextCallout;
import feathers.events.TriggerEvent;
import openfl.Assets;
import openfl.display.Bitmap;
import feathers.skins.RectangleSkin;
import feathers.layout.HorizontalLayout;
import feathers.controls.Label;
import feathers.controls.Panel;

class MovieInfoDisplay extends Panel {

    /**
        movie name label
    **/
    private var _movie:Label;

    /**
        scene name label
    **/
    private var _scene:Label;

    /**
        movie icon
    **/
    private var _mvIcon:Bitmap;

    /**
        scene icon
    **/
    private var _scIcon:Bitmap;

    /**
        custom message label
    **/
    private var _msg:Label;

    /**
        message display timer
    **/
    private var _timer:Timer;

    /**
        action to call on display update
    **/
    private var _acupd:Dynamic = null;

    public function new(upd:Dynamic = null) {
        super();
        this._acupd = upd;

        var lay:HorizontalLayout = new HorizontalLayout();
        lay.gap = 2;
        lay.setPadding(10);
        lay.horizontalAlign = CENTER;
        this.layout = lay;
        var skin:RectangleSkin = new RectangleSkin();
        skin.fill = SolidColor(0x999999);
        this.backgroundSkin = skin;

        // movie display
        this._mvIcon = new Bitmap(Assets.getBitmapData('btMovie'));
        this._mvIcon.smoothing = true;
        this._mvIcon.width = this._mvIcon.height = 22;
        this._movie = new Label();
        this._movie.text = '';

        // scene display
        this._scIcon = new Bitmap(Assets.getBitmapData('btScene'));
        this._scIcon.smoothing = true;
        this._scIcon.width = this._scIcon.height = 22;
        this._scene = new Label();
        this._scene.text = '';

        // custom message
        this._msg = new Label();
        this._msg.text = '';

        // exposing show message
        Global.showMsg = this.showMsg;

        // deatil click
        this.addEventListener(MouseEvent.CLICK, onCallout);
    }

    /**
        Updates the information display.
    **/
    public function onUpdate():Void {
        if (this._timer != null) {
            try {
                this._timer.stop();
            } catch (e) { }
            this._timer = null;
        }
        this.removeChildren();
        if (GlobalPlayer.movie.mvId != '') {
            this._movie.text = GlobalPlayer.mdata.title;
            this.addChild(this._mvIcon);
            this.addChild(this._movie);
        }
        if (GlobalPlayer.movie.scId != '') {
            this._scene.text = GlobalPlayer.movie.scene.title;
            this.addChild(this._scIcon);
            this.addChild(this._scene);
        }
        if (this._acupd != null) this._acupd();
    }

    /**
        Shows a custom message.
        @param  txt the text to show
    **/
    public function showMsg(txt:String):Void {
        this.removeChildren();
        this._msg.text = txt;
        this.addChild(this._msg);
        if (this._timer != null) {
            try {
                this._timer.stop();
            } catch (e) { }
            this._timer = null;
        }
        this._timer = new Timer(2000);
        this._timer.run = this.onUpdate;
    }

    /**
        Shows details about loaded movie and scene.
    **/
    private function onCallout(evt:MouseEvent):Void {
        var calltxt:String = '';
        if (GlobalPlayer.movie.mvId != '') calltxt += GlobalPlayer.mdata.title + "\n(ID " + GlobalPlayer.movie.mvId + ')';
        if (GlobalPlayer.movie.scId != '') calltxt += "\n" + GlobalPlayer.movie.scene.title + "\n(ID " + GlobalPlayer.movie.scId + ')';
        if (calltxt != '') TextCallout.show(calltxt, this, RelativePosition.TOP);
    }

}