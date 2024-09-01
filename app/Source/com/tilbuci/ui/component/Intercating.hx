package com.tilbuci.ui.component;

/** HAXE **/
import feathers.skins.RectangleSkin;
import haxe.Timer;

/** OPENFL **/
import openfl.Assets;
import openfl.display.Bitmap;

/** FEATHERS UI **/
import feathers.controls.Panel;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.Global;

class Interacting extends Panel {

    /**
        icons
    **/
    private var _icons:Array<Bitmap> = [ ];

    /**
        current icon
    **/
    private var _current:Int = 0;

    /**
        animation timer
    **/
    private var _timer:Timer;

    public function new() {
        super();
        this.width = this.height = 150;

        var skin:RectangleSkin = new RectangleSkin();
        skin.fill = SolidColor(0x000000, 0);
        this.backgroundSkin = skin;

        for (i in 1...5) {
            var bmp:Bitmap = new Bitmap(Assets.getBitmapData('tilBuci0' + i));
            bmp.smoothing = true;
            bmp.alpha = 0.8;
            bmp.x = (150 - bmp.width) / 2;
            bmp.y = (150 - bmp.height) / 2;
            this._icons.push(bmp);
        }
    }

    /**
        Starts the animation.
    **/
    public function start():Void {
        if (this._timer != null) {
            try {
                this._timer.stop();
            } catch (e) { }
            this._timer = null;
        }
        this._timer = new Timer(250);
        this._timer.run = function() {
            this._current++;
            if (this._current >= this._icons.length) this._current = 0;
            this.removeChildren();
            this.addChild(this._icons[this._current]);
        };
        if (Global.stage != null) {
            PopUpManager.addPopUp(this, Global.stage);
        }
    }

    /**
        Stops the animation.
    **/
    public function stop():Void {
        if (this._timer != null) {
            try {
                this._timer.stop();
            } catch (e) { }
            this._timer = null;
        }
        if (Global.stage != null) {
            PopUpManager.removePopUp(this);
        }
    }

}