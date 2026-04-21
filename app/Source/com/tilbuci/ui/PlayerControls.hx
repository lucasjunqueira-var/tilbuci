/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui;

/** OPENFL **/
import feathers.layout.HorizontalLayoutData;
import haxe.Timer;
import com.tilbuci.data.GlobalPlayer;
import feathers.controls.Panel;
import feathers.core.FeathersControl;
import feathers.core.MeasureSprite;
import com.tilbuci.ui.component.MovieInfoDisplay;
import openfl.display.Bitmap;
//import openfl.Assets;
import com.tilbuci.statictools.Assets;

/** FEATHERS UI **/
import feathers.layout.VerticalLayout;
import feathers.layout.HorizontalLayout;
import feathers.events.TriggerEvent;
import feathers.skins.RectangleSkin;
import feathers.layout.AnchorLayout;
import feathers.controls.ScrollContainer;
import feathers.layout.AnchorLayoutData;
import feathers.controls.HDividedBox;
import feathers.controls.VDividedBox;

/** TILBUCI **/
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.ui.PlayerHolder;
import com.tilbuci.data.Global;

class PlayerControls extends VDividedBox {

    /**
        callback action
    **/
    private var _ac:Dynamic;

    /**
        divided area content
    **/
    //private var _controls:ScrollContainer;
    private var _controls:HDividedBox;

    /**
        container for player area
    **/
    private var _scroller:ScrollContainer;

    /**
        the player area
    **/
    private var _player:PlayerHolder;

    /**
        movie information display
    **/
    private var _movieInfo:MovieInfoDisplay;

    /**
        button areas
    **/
    private var _displayArea:Panel;
    private var _zoomArea:Panel;
    private var _playArea:Panel;

    /**
        re-center timer
    **/
    private var _centerTimer:Timer;

    /**
        user interface
    **/
    public var ui:InterfaceFactory;

    public function new(pl:PlayerHolder, ac:Dynamic) {
        super();
        this._ac = ac;
        this._player = pl;
        this.ui = new InterfaceFactory();

        this.layoutData = AnchorLayoutData.fill();

        this._scroller = new ScrollContainer();
        this._scroller.autoHideScrollBars = false;
        this._scroller.fixedScrollBars = true;
        this._scroller.showScrollBars = true;
        this._scroller.layout = new VerticalLayout();
        var bgSkin:RectangleSkin = new RectangleSkin();
        bgSkin.fill = SolidColor(0x999999);
        this._scroller.backgroundSkin = bgSkin;
        this.addChild(this._scroller);
        this._scroller.addChild(this._player);

        this._controls = new HDividedBox();
        this._controls.layoutData = AnchorLayoutData.fill();
        var lay:HorizontalLayout = new HorizontalLayout();
        lay.gap = 5;
        lay.setPadding(10);
        this._controls.layout = lay;
        this._controls.backgroundSkin = bgSkin;
        this._controls.height = this._controls.maxHeight = this._controls.minHeight = 50;
        this.addChild(this._controls);    
        
        // display
        this._displayArea = this.ui.createHArea('left');
        this._controls.addChild(this._displayArea);
        this.ui.createIconButton('screen', this.onScreen, new Bitmap(Assets.getBitmapData('btScreen')), null, this._displayArea);
        this.ui.createSpacer('screen', 10, false, this._displayArea);
        this.ui.createIconButton('color', this.onColor, new Bitmap(Assets.getBitmapData('btColors')), null, this._displayArea);
        this.ui.createIconButton('focus', this.onFocus, new Bitmap(Assets.getBitmapData('btFocus')), null, this._displayArea);
        
        this._zoomArea = this.ui.createHArea('center');
        this._controls.addChild(this._zoomArea);
        this.ui.createIconButton('zoom+', this.onZoomP, new Bitmap(Assets.getBitmapData('btZoomP')), null, this._zoomArea);
        this.ui.createIconButton('zoom-', this.onZoomM, new Bitmap(Assets.getBitmapData('btZoomM')), null, this._zoomArea);
        this.ui.createIconButton('zoomfit', this.centerPlayer, new Bitmap(Assets.getBitmapData('btZoomFit')), null, this._zoomArea);
        this.ui.createIconButton('zoom100', this.onZoom100, new Bitmap(Assets.getBitmapData('btZoom100')), null, this._zoomArea);
        
        this._playArea = this.ui.createHArea('left');
        this._controls.addChild(this._playArea);
        this.ui.createIconButton('left', this.onLeft, new Bitmap(Assets.getBitmapData('btLeft')), null, this._playArea);
        this.ui.createLabel('keyframes', '', '', this._playArea);
        this.ui.createIconButton('right', this.onRight, new Bitmap(Assets.getBitmapData('btRight')), null, this._playArea);
        this.ui.createIconButton('actions', this.onActions, new Bitmap(Assets.getBitmapData('btSetup')), null, this._playArea);
        this.ui.createIconButton('play', this.onPlay, new Bitmap(Assets.getBitmapData('btPlay')), null, this._playArea);

        this._movieInfo = new MovieInfoDisplay(this.updateInfo);
        this._controls.addChild(this._movieInfo);

        // tooltips
        this.ui.buttons['screen'].toolTip = Global.ln.get('tooltip-playercontrols-screen');
        this.ui.buttons['color'].toolTip = Global.ln.get('tooltip-playercontrols-color');
        this.ui.buttons['focus'].toolTip = Global.ln.get('tooltip-playercontrols-focus');
        this.ui.buttons['zoom+'].toolTip = Global.ln.get('tooltip-playercontrols-zoomp');
        this.ui.buttons['zoom-'].toolTip = Global.ln.get('tooltip-playercontrols-zoomm');
        this.ui.buttons['zoomfit'].toolTip = Global.ln.get('tooltip-playercontrols-zoomfit');
        this.ui.buttons['zoom100'].toolTip = Global.ln.get('tooltip-playercontrols-zoom100');
        this.ui.buttons['left'].toolTip = Global.ln.get('tooltip-playercontrols-left');
        this.ui.buttons['right'].toolTip = Global.ln.get('tooltip-playercontrols-right');
        this.ui.buttons['actions'].toolTip = Global.ln.get('tooltip-playercontrols-actions');
        this.ui.buttons['play'].toolTip = Global.ln.get('tooltip-playercontrols-play');
    }

    /**
        Updates the information display.
    **/
    public function updateDisplay():Void {
        this._movieInfo.onUpdate();
        this.updateInfo();
    }

    /**
        Updates controls information.
    **/
    public function updateInfo():Void {

        this.updateSizes();

        if (GlobalPlayer.movie.scId == '') {
            this.ui.labels['keyframes'].text = '';
            this.ui.buttons['left'].enabled = false;
            this.ui.buttons['right'].enabled = false;
            this.ui.buttons['play'].enabled = false;
        } else {
            this.ui.labels['keyframes'].text = (GlobalPlayer.area.currentKf + 1) + ' / ' + GlobalPlayer.movie.scene.keyframes.length;
            this.ui.buttons['left'].enabled = !(GlobalPlayer.area.currentKf == 0);
            this.ui.buttons['right'].enabled = (GlobalPlayer.area.currentKf < (GlobalPlayer.movie.scene.keyframes.length - 1));
            this.ui.buttons['play'].enabled = true;
        }
        this.ui.buttons['screen'].enabled = (GlobalPlayer.mdata.screen.type == 'both');
    }

    /**
        Centers player on edit area.
    **/
    public function centerPlayer(evt:TriggerEvent = null):Void {
        if (Global.displayType == 'portrait') {
            this._player.setWidth(this.height - 150);
        } else {
            this._player.setWidth(this.width - 100);
        }
        this._scroller.scrollX = this._player.player.x - 50;
        this._scroller.scrollY = this._player.player.y - 50;

        // re-center?
        if (this._centerTimer == null) {
            this._centerTimer = new Timer(150);
            this._centerTimer.run = this.reCenter;
        } else {
            try { this._centerTimer.stop(); } catch (e) { }
            this._centerTimer = null;
        }

        this.updateSizes();
    }

    /**
        Adjusts the movie area cetering.
    **/
    public function reCenter():Void {
        if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf] != null) GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
        this.centerPlayer();
    }

    /**
        Rotates the screen.
    **/
    private function onScreen(evt:TriggerEvent = null):Void {
        if ((GlobalPlayer.movie.mvId != '') && (GlobalPlayer.movie.scId != '') && (GlobalPlayer.mdata.screen.type == 'both')) {
            GlobalPlayer.area.imgSelect();
            if (Global.displayType == 'portrait') {
                Global.displayType = 'landscape';
            } else {
                Global.displayType = 'portrait';
            }
            this._player.removeChild(this._player.player);
            this.centerPlayer();
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
            this._player.addChild(this._player.player);
            this.centerPlayer();
        }

        this.updateSizes();
    }

    /**
        Change color mode.
    **/
    private function onColor(evt:TriggerEvent = null):Void {
        GlobalPlayer.parser.run('{ "ac": "accessibility.changeshader", "param": [] }');
        switch (GlobalPlayer.currentShader) {
            case 1: this._movieInfo.showMsg(Global.ln.get('tooltip-accessibility-deuteranotopia'));
            case 2: this._movieInfo.showMsg(Global.ln.get('tooltip-accessibility-protonatopia'));
            case 3: this._movieInfo.showMsg(Global.ln.get('tooltip-accessibility-tritanotopia'));
            case 4: this._movieInfo.showMsg(Global.ln.get('tooltip-accessibility-contrast'));
            case 5: this._movieInfo.showMsg(Global.ln.get('tooltip-accessibility-grayscale'));
            default: this._movieInfo.showMsg(Global.ln.get('tooltip-accessibility-none'));
        }

        this.updateSizes();
    }

    /**
        Change focus mode.
    **/
    private function onFocus(evt:TriggerEvent = null):Void {
        GlobalPlayer.parser.run('{ "ac": "accessibility.focusswitch", "param": [] }');
        if (GlobalPlayer.focusMode) {
            this._movieInfo.showMsg(Global.ln.get('tooltip-accessibility-focuson'));
        } else {
            this._movieInfo.showMsg(Global.ln.get('tooltip-accessibility-focusoff'));
        }

        this.updateSizes();
    }

    /**
        Goes to the previous keyframe.
    **/
    private function onLeft(evt:TriggerEvent = null):Void {
        if (GlobalPlayer.area.currentKf > 0) {
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf - 1], (GlobalPlayer.area.currentKf - 1));
            Global.history.clear();
            this.updateInfo();
        }

        this.updateSizes();
    }

    /**
        Goes to the next keyframe.
    **/
    private function onRight(evt:TriggerEvent = null):Void {
        if (GlobalPlayer.area.currentKf < (GlobalPlayer.movie.scene.keyframes.length - 1)) {
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf + 1], (GlobalPlayer.area.currentKf + 1));
            Global.history.clear();
            this.updateInfo();
        }

        this.updateSizes();
    }

    /**
        Shows testing actions window.
    **/
    private function onActions(evt:TriggerEvent = null):Void {
        this._ac('testactions');
    }

    /**
        Plays/pauses the scene.
    **/
    private function onPlay(evt:TriggerEvent = null):Void {
        this._ac('play');
    }

    /**
        Increases player zoom.
    **/
    private function onZoomP(evt:TriggerEvent = null):Void {
        if (Global.displayType == 'portrait') {
            this._player.setWidth(this._player.player.rHeight * 1.1);
        } else {
            this._player.setWidth(this._player.player.rWidth * 1.1);
        }
    }

    /**
        Decreases player zoom.
    **/
    private function onZoomM(evt:TriggerEvent = null):Void {
        if (Global.displayType == 'portrait') {
            this._player.setWidth(this._player.player.rHeight * 0.9);
        } else {
            this._player.setWidth(this._player.player.rWidth * 0.9);
        }
    }

    /**
        Display player on actual size.
    **/
    private function onZoom100(evt:TriggerEvent = null):Void {
        if (Global.displayType == 'portrait') {
            this._player.setWidth(this._player.player.mHeight);
        } else {
            this._player.setWidth(this._player.player.mWidth);
        }
    }

    private function updateSizes():Void {
        var totWidth:Int = Math.round(this.width - 20);
        this._displayArea.width = Math.round(totWidth * 0.2);
        this._zoomArea.width = Math.round(totWidth * 0.2);
        this._playArea.width = Math.round(totWidth * 0.25);
        this._movieInfo.width = totWidth - (this._displayArea.width - this._zoomArea.width - this._playArea.width);
    }
}