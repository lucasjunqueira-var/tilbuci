/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.main;

/** OPENFL **/
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.StageDisplayState;

/** FEATHERS UI **/
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import feathers.controls.ScrollContainer;
import feathers.controls.Button;
import feathers.events.TriggerEvent;
import feathers.controls.VDividedBox;

/** TILBUCI **/
import com.tilbuci.ui.base.BackgroundSkin;
import com.tilbuci.data.Global;
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.js.ExternUpload;

/**
    The left interface area.
**/
class LeftInterface extends VDividedBox {

    /**
        upper buttons area
    **/
    private var _topArea:ScrollContainer;

    /**
        lower buttons area
    **/
    private var _bottomArea:ScrollContainer;

    /**
        action method reference
    **/
    private var _action:Dynamic;

    /**
        buttons add by actions
    **/
    private var _addButtons:Map<String, Button> = [ ];

    /**
        user interface
    **/
    public var ui:InterfaceFactory;

    /**
        Creator.
        @param  lang    the language object reference
        @param  ac  the method to call on actions
    **/
    public function new(ac:Dynamic) {

        // prepare display
        super();
        this.layoutData = AnchorLayoutData.fill();
        this.backgroundSkin = new BackgroundSkin();
        this.width = this.minWidth = this.maxWidth = 150;
        this.ui = new InterfaceFactory();

        // get values
        this._action = ac;

        // top container area
        this._topArea = new ScrollContainer();
        var laytop:VerticalLayout = new VerticalLayout();
        laytop.gap = 10;
        laytop.verticalAlign = TOP;
        this._topArea.layout = laytop;
        this._topArea.backgroundSkin = new BackgroundSkin();
        this._topArea.setPadding(10);
        this.addChild(this._topArea);

        // bottom container area
        this._bottomArea = new ScrollContainer();
        var laybot:VerticalLayout = new VerticalLayout();
        laybot.gap = 10;
        laybot.verticalAlign = BOTTOM;
        this._bottomArea.layout = laybot;
        this._bottomArea.backgroundSkin = new BackgroundSkin();
        this._bottomArea.setPadding(10);
        this._bottomArea.height = this._bottomArea.maxHeight = this._bottomArea.minHeight = 120;
        this.addChild(this._bottomArea);

        // create buttons
        this.createButton('btMovie', Global.ln.get('leftbar-movie'), 'btMovie', this.btMovie, this._topArea);
        this.createButton('btScene', Global.ln.get('leftbar-scene'), 'btScene', this.btScene, this._topArea);
        this.createButton('btKeyframe', Global.ln.get('leftbar-keyframe'), 'btKeyframe', this.btKeyframe, this._topArea);
        this.createButton('btMedia', Global.ln.get('leftbar-media'), 'btMedia', this.btMedia, this._topArea);
        this.createButton('btContraptions', Global.ln.get('leftbar-contraptions'), 'btContraptions', this.btContraption, this._topArea);
        this.createButton('btExchange', Global.ln.get('leftbar-exchange'), 'btExchange', this.btExchange, this._topArea);
        this.createButton('btVisitors', Global.ln.get('leftbar-visitors'), 'btVisitors', this.btVisitors, this._topArea);
        this.createButton('btSetup', Global.ln.get('leftbar-setup'), 'btSetup', this.btSetup, this._topArea);
        this.createButton('btFullscreen', Global.ln.get('leftbar-fullscreen'), 'btFullscreen', this.btFullscreen, this._bottomArea);
        this.createButton('btToggle', Global.ln.get('leftbar-toggle'), 'btToggle', this.btToggle, this._bottomArea);
    }

    /**
        Adds a button to the interface.
        @param  name    the button name/label
        @param  callback    button callback action
        @param  top add at the top buttons area?
        @param  asset   icon asset name
    **/
    public function addButton(name:String, callback:Dynamic, top:Bool = true, asset:String = 'btPlugin'):Void {
        if (top) {
            this._addButtons[name] = this.createButton(name, name, asset, callback, this._topArea);
        } else {
            this._addButtons[name] = this.createButton(name, name, asset, callback, this._bottomArea);
        }
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.removeChildren();
        this._topArea.removeChildren();
        this._bottomArea.removeChildren();
        this._topArea = null;
        this._bottomArea = null;
        this._action = null;
        this.ui.kill();
        this.ui = null;
    }

    /**
        Creates a new button.
        @param  name    the button name
        @param  txt the button label
        @param  ic  the icon asset id
        @param  ac  the button click action
        @param  holder  the button parent holder
        @return a reference to the created button
    **/
    private function createButton(name:String, txt:String, ic:String, ac:Dynamic, holder:ScrollContainer):Button {
        var bt:Button = this.ui.createIconButton(name, ac, new Bitmap(Assets.getBitmapData(ic)), txt, holder);
        bt.horizontalAlign = LEFT;
        bt.height = 30;
        bt.width = 130;
        return (bt);
    }

    /**
        Opens the movie menu.
    **/
    private function btMovie(evt:TriggerEvent):Void {
        this._action('movie');
    }

    /**
        Opens the scene menu.
    **/
    private function btScene(evt:TriggerEvent):Void {
        this._action('scene');
    }

    /**
        Opens the keyframe menu.
    **/
    private function btKeyframe(evt:TriggerEvent):Void {
        this._action('keyframe');
    }

    /**
        Opens the media menu.
    **/
    private function btMedia(evt:TriggerEvent):Void {
        this._action('media');
    }

    /**
        Opens the contraptions menu.
    **/
    private function btContraption(evt:TriggerEvent):Void {
        this._action('contraptions');
    }

    /**
        Opens the exchange data menu.
    **/
    private function btExchange(evt:TriggerEvent):Void {
        this._action('exchange');
    }

    /**
        Opens the visitors window.
    **/
    private function btVisitors(evt:TriggerEvent):Void {
        this._action('visitors');
    }

    /**
        Opens the setup window.
    **/
    private function btSetup(evt:TriggerEvent):Void {
        this._action('setup');
    }

    /**
        Opens/closes the left menu interface.
    **/
    private function btToggle(evt:TriggerEvent):Void {
        if (this.ui.buttons['btToggle'].width > 100) {
            this.width = this.minWidth = this.maxWidth = 60;
            this.setSize(60, this.height);
            for (b in this.ui.buttons.keys()) {
                this.ui.buttons[b].width = 40;
                this.ui.buttons[b].text = '';
            }
            this._action('close-interface');
        } else {
            this.width = this.minWidth = this.maxWidth = 150;
            this.setSize(150, this.height);
            for (b in this.ui.buttons.keys()) {
                this.ui.buttons[b].width = 130;
            }
            this.ui.buttons['btMovie'].text = Global.ln.get('leftbar-movie');
            this.ui.buttons['btScene'].text = Global.ln.get('leftbar-scene');
            this.ui.buttons['btKeyframe'].text = Global.ln.get('leftbar-keyframe');
            this.ui.buttons['btMedia'].text = Global.ln.get('leftbar-media');
            // this.ui.buttons['btContraptions'].text = Global.ln.get('leftbar-contraptions');
            this.ui.buttons['btSetup'].text = Global.ln.get('leftbar-setup');
            this.ui.buttons['btFullscreen'].text = Global.ln.get('leftbar-fullscreen');
            this.ui.buttons['btToggle'].text = Global.ln.get('leftbar-toggle');
            this.ui.buttons['btExchange'].text = Global.ln.get('leftbar-exchange');
            this.ui.buttons['btVisitors'].text = Global.ln.get('leftbar-visitors');
            for (nm in this._addButtons.keys()) this._addButtons[nm].text = nm;
            this._action('open-interface');
        }
    }

    /**
        Shows the interface on fullscreen?
    **/
    private function btFullscreen(evt:TriggerEvent):Void {
        if (this.stage.displayState == StageDisplayState.NORMAL) {
            this.stage.displayState = StageDisplayState.FULL_SCREEN;
        } else {
            this.stage.displayState = StageDisplayState.NORMAL;
        }
    }


}