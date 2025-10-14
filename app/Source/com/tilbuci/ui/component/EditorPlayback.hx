/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.component;

/** OPENFL **/
import openfl.ui.Mouse;
import feathers.layout.AnchorLayout;
import haxe.Timer;
import com.tilbuci.data.GlobalPlayer;
import feathers.events.TriggerEvent;
import openfl.display.Stage;
import openfl.Assets;
import openfl.display.Bitmap;

/** FEATHERS UI **/
import feathers.controls.Panel;
import feathers.core.PopUpManager;
import feathers.layout.HorizontalLayout;
import feathers.skins.RectangleSkin;
import feathers.layout.VerticalLayout;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayoutData;
import feathers.controls.VDividedBox;

/** TLBUCI **/
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.data.Global;


class EditorPlayback extends Panel {

    /**
        display areas
    **/
    private var _div:VDividedBox;

    /**
        player area
    **/
    private var _top:LayoutGroup;

    /**
        buttons area
    **/
    private var _bottom:LayoutGroup;

    /**
        the player holder
    **/
    private var _player:PlayerHolder;

    /**
        editor display movie area center method
    **/
    private var _acCenter:Dynamic;

    private var _recenter:Timer;

    /**
        information about the player
    **/
    public var info:PlayerInfo;

    /**
        user interface
    **/
    public var ui:InterfaceFactory;

    public function new(acCenter:Dynamic) {
        super();
        this._acCenter = acCenter;

        var wdLay:VerticalLayout = new VerticalLayout();
        wdLay.gap = 0;
        wdLay.setPadding(0);
        wdLay.verticalAlign = TOP;
        wdLay.horizontalAlign = CENTER;
        this.layout = wdLay;

        this._div = new VDividedBox();
        this._div.layoutData = AnchorLayoutData.fill();
        this._div.liveDragging = false;
        this.addChild(this._div);
        
        var tpskin:RectangleSkin = new RectangleSkin();
        tpskin.fill = SolidColor(0xcccccc);

        var topLay:AnchorLayout = new AnchorLayout();

        this._top = new LayoutGroup();
        this._top.layout = topLay;
        this._top.layoutData = AnchorLayoutData.fill();
        this._top.backgroundSkin = tpskin;
        this._div.addChild(this._top);

        var btskin:RectangleSkin = new RectangleSkin();
        btskin.fill = SolidColor(0x999999);
        var bottomLay:HorizontalLayout = new HorizontalLayout();
        bottomLay.gap = 10;
        bottomLay.setPadding(10);
        bottomLay.verticalAlign = MIDDLE;
        bottomLay.horizontalAlign = CENTER;
        this._bottom = new LayoutGroup();
        this._bottom.layout = bottomLay;
        this._bottom.layoutData = AnchorLayoutData.fill();
        this._bottom.backgroundSkin = btskin;
        this._bottom.minHeight = this._bottom.maxHeight = this._bottom.height = 50;
        this._div.addChild(this._bottom);

        this.ui = new InterfaceFactory();

        this.ui.createIconButton('play', this.onPlay, new Bitmap(Assets.getBitmapData('btPlay')), null, this._bottom);
        this.ui.createSpacer('play', 10, false, this._bottom);
        this.ui.createIconButton('screen', this.onScreen, new Bitmap(Assets.getBitmapData('btScreen')), null, this._bottom);
        this.ui.createSpacer('screen', 10, false, this._bottom);
        this.ui.createIconButton('close', onClose, new Bitmap(Assets.getBitmapData('btClose')), null, this._bottom);

        this.info = {
            x: 0, 
            y: 0, 
            width: 0, 
            height: 0,
            orientation: Global.displayType, 
            keyframe: 0, 
            scene: '', 
            sceneobj: null, 
            movie: '', 
        };
    }

    /**
        Shows the playback area.
        @param  st  reference to the display stage
        @param  hd  the player holder
    **/
    public function show(st:Stage, hd:PlayerHolder):Void {
        GlobalPlayer.area.maskArea(true);
        GlobalPlayer.area.pause();
        GlobalPlayer.movie.data.applySets(true);
        /*if (GlobalPlayer.movie.data.acstart != '') GlobalPlayer.parser.run(GlobalPlayer.movie.data.acstart);
        if (GlobalPlayer.movie.scene.acstart != '') GlobalPlayer.parser.run(GlobalPlayer.movie.scene.acstart);*/
        GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
        this.width = st.stageWidth;
        this.height = st.stageHeight;
        this._top.minHeight = this._top.maxHeight = this._top.height = (this.height - this._bottom.height - 10);
        this._top.width = this.width;
        this._bottom.width = this.width;
        this._player = hd;
        var curkf:Int = GlobalPlayer.area.currentKf;
        this.info = {
            x: this._player.player.x, 
            y: this._player.player.y,
            width: this._player.player.width, 
            height: this._player.player.height, 
            orientation: Global.displayType, 
            keyframe: GlobalPlayer.area.currentKf, 
            scene: GlobalPlayer.movie.scId, 
            sceneobj: GlobalPlayer.movie.scene.toObject(), 
            movie: GlobalPlayer.movie.mvId, 
        };
        this._player.removeChild(this._player.player);
        this._top.addChild(this._player.player);
        this.centerPlayer();

        this.ui.buttons['screen'].enabled = (GlobalPlayer.mdata.screen.type == 'both');

        PopUpManager.addPopUp(this, st);

        GlobalPlayer.mode = Player.MODE_EDPLAYERWAIT;
        if (GlobalPlayer.movie.data.acstart != '') GlobalPlayer.parser.run(GlobalPlayer.movie.data.acstart);
        if (GlobalPlayer.movie.scene.acstart != '') GlobalPlayer.parser.run(GlobalPlayer.movie.scene.acstart);
        GlobalPlayer.area.play();

        if (GlobalPlayer.movie.scene.staticsc) {
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[curkf], curkf);
        }

        this.ui.buttons['play'].icon = new Bitmap(Assets.getBitmapData('btPause'));
        this.ui.buttons['play'].icon.width = this.ui.buttons['play'].icon.height = 20;

        this._player.player.listenInput();
    }

    /**
        Centers the player display on window.
    **/
    private function centerPlayer():Void {
        var ht:Float = this._top.minHeight - 20;
        var wd:Float = ht * (GlobalPlayer.mdata.screen.big / GlobalPlayer.mdata.screen.small);
        if (Global.displayType == 'portrait') {
            wd = ht * (GlobalPlayer.mdata.screen.small / GlobalPlayer.mdata.screen.big);
        }
        this._player.player.setSize(wd, ht);

        this._player.x = 0;
        this._player.y = 0;
        this._player.player.x = ((this._top.width - this._player.player.width) / 2) + ((this._player.player.width - this._player.player.rWidth));
        this._player.player.y = ((this._top.minHeight - this._player.player.rHeight) / 2) + ((this._player.player.tHeight - this._player.player.rHeight) / 2);
        this._player.player.x = (Global.stage.stageWidth - this._player.player.rWidth) / 2;
        this._player.player.y = 10;

        if (this._recenter == null) {
            this._recenter = new Timer(150);
            this._recenter.run = this.centerPlayer;
        } else {
            try { this._recenter.stop(); } catch (e) { }
            this._recenter = null;
        }
    }

    /**
        Playes/pauses.
    **/
    private function onPlay(evt:TriggerEvent):Void {
        if (GlobalPlayer.area.playing) {
            GlobalPlayer.mode = Player.MODE_EDITOR;
            GlobalPlayer.area.pause();
            this.ui.buttons['play'].icon = new Bitmap(Assets.getBitmapData('btPlay'));
        } else {
            GlobalPlayer.mode = Player.MODE_EDPLAYERWAIT;
            GlobalPlayer.area.play();
            this.ui.buttons['play'].icon = new Bitmap(Assets.getBitmapData('btPause'));
        }
        this.ui.buttons['play'].icon.width = this.ui.buttons['play'].icon.height = 20;
    }

    /**
        Changes screen display.
    **/
    private function onScreen(evt:TriggerEvent):Void {
        if (GlobalPlayer.mdata.screen.type == 'both') {
            var pause:Bool = !GlobalPlayer.area.playing;
            this._top.removeChild(this._player.player);
            if (Global.displayType == 'portrait') {
                Global.displayType = 'landscape';
            } else {
                Global.displayType = 'portrait';
            }
            this.centerPlayer();
            this._top.addChild(this._player.player);
            if (pause) {
                GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
                GlobalPlayer.area.pause();
            } else {
                GlobalPlayer.area.pause();
                GlobalPlayer.mode = Player.MODE_EDITOR;
                GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
                this.centerPlayer();
                GlobalPlayer.mode = Player.MODE_EDPLAYERWAIT;
                //GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf], GlobalPlayer.area.currentKf);
                GlobalPlayer.area.play();
            }
            this.centerPlayer();
        }
    }

    /**
        Closes the playback area.
    **/
    private function onClose(evt:TriggerEvent):Void {
        GlobalPlayer.contraptions.removeContraptions(true);
        GlobalPlayer.area.removeInputInterfaces();
        GlobalPlayer.mode = Player.MODE_EDITOR;
        GlobalPlayer.area.maskArea(false);
        GlobalPlayer.area.pause();
        GlobalPlayer.area.releaseAllProperties();
        GlobalPlayer.area.hideTarget();
        Mouse.show();
        this._player.player.listenInputRemove();
        this._top.removeChild(this._player.player);
        this._player.addChild(this._player.player);
        Global.displayType = this.info.orientation;
        this._player.player.x = this.info.x;
        this._player.player.y = this.info.y;
        this._player.player.setSize(this.info.width, this.info.height);
        if (this.info.movie != GlobalPlayer.movie.mvId) {
            Global.sceneObj = this.info.sceneobj;
            Global.sceneToLoad = this.info.scene;
            Global.kfToLoad = this.info.keyframe;
            this._player.player.load(this.info.movie);
        } else if (this.info.scene != GlobalPlayer.movie.scId) {
            Global.sceneObj = this.info.sceneobj;
            Global.kfToLoad = this.info.keyframe;
            GlobalPlayer.movie.loadScene(this.info.scene);
        } else {
            GlobalPlayer.movie.scene.fromObject(this.info.sceneobj);
            GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[this.info.keyframe], this.info.keyframe);
        }
        this._acCenter();
        PopUpManager.removePopUp(this);
    }

}

/**
    Player information.
**/
typedef PlayerInfo = {
    var x:Float;
    var y:Float;
    var width:Float;
    var height:Float;
    var orientation:String;
    var keyframe:Int;
    var scene:String;
    var sceneobj:Dynamic;
    var movie:String;
}