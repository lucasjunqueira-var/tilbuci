/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

import openfl.events.MouseEvent;
import com.tilbuci.display.InstanceImage;
import com.tilbuci.display.VideoImage;
import com.tilbuci.display.PictureImage;
import com.tilbuci.display.SpritemapImage;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class Contraptions {

    // menu contraption
    public var menus:Map<String, MenuContraption> = [ ];
    private var _menusOverlay:Sprite;
    private var _menuAction:Dynamic;
    private var _menuVariable:String;

    // scene loading icon
    private var _loadingOverlay:Sprite;
    private var _loadingIc:SpritemapImage;

    // image zoom
    private var _zoomOverlay:Sprite;
    private var _zoomPicture:PictureImage;
    private var _zoomVideo:VideoImage;

    public function new() {

    }

    public function clear():Void {
        for (k in this.menus.keys()) {
            this.menus[k].kill();
            this.menus.remove(k);
        }
        if (this._menusOverlay == null) {
            this._menusOverlay = GlobalPlayer.area.getOverlay('contraptions-menu');
        }
        this._menusOverlay.graphics.clear();
    }

    public function getData():String {
        var data:Map<String, Array<Dynamic>> = [ ];
        data['menus'] = new Array<Dynamic>();
        for (mn in this.menus) {
            data['menus'].push(mn.toObject());
        }
        return(StringStatic.jsonStringify(data));
    }

    public function menuShow(name:String, options:Array<String>, variable:String, actions:Dynamic, pos:String, px:Int, py:Int):Bool {
        this.menuHide();
        if (this.menus.exists(name)) {
            var mn:MenuContraption = this.menus[name];
            if (mn.ok) {
                this._menusOverlay.graphics.clear();
                if (mn.bgalpha > 0) {
                    this._menusOverlay.graphics.beginFill(Std.parseInt(StringTools.replace('#', '0x', mn.bgcolor)), mn.bgalpha);
                    this._menusOverlay.graphics.drawRect(0, 0, GlobalPlayer.area.aWidth, GlobalPlayer.area.aHeight);
                    this._menusOverlay.graphics.endFill();
                }
                this._menusOverlay.addChild(mn.create(options, this.onMenuSelect));
                switch (pos) {
                    case 'top':
                        mn.x = ((GlobalPlayer.area.aWidth - mn.width) / 2);
                        mn.y = py;
                    case 'topleft':
                        mn.x = px;
                        mn.y = py;
                    case 'topright':
                        mn.x = GlobalPlayer.area.aWidth - mn.width - px;
                        mn.y = py;
                    case 'centerleft':
                        mn.x = px;
                        mn.y = ((GlobalPlayer.area.aHeight - mn.height) / 2);
                    case 'centerright':
                        mn.x = GlobalPlayer.area.aWidth - mn.width - px;
                        mn.y = ((GlobalPlayer.area.aHeight - mn.height) / 2);
                    case 'bottom':
                        mn.x = ((GlobalPlayer.area.aWidth - mn.width) / 2);
                        mn.y = GlobalPlayer.area.aHeight - mn.height - py;
                    case 'bottomleft':
                        mn.x = px;
                        mn.y = GlobalPlayer.area.aHeight - mn.height - py;
                    case 'bottomright':
                        mn.x = GlobalPlayer.area.aWidth - mn.width - px;
                        mn.y = GlobalPlayer.area.aHeight - mn.height - py;
                    case 'absolute':
                        mn.x = px;
                        mn.y = py;
                    default: // center
                        mn.x = (GlobalPlayer.area.aWidth - mn.width) / 2;
                        mn.y = (GlobalPlayer.area.aHeight - mn.height) / 2;
                }
                this._menuAction = actions;
                this._menuVariable = variable;
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    public function removeContraptions():Void {
        this.menuHide();
    }

    public function menuHide():Void {
        for (mn in this.menus) mn.remove();
        if (this._menusOverlay == null) {
            this._menusOverlay = GlobalPlayer.area.getOverlay('contraptions-menu');
        }
        this._menusOverlay.graphics.clear();
    }

    private function onMenuSelect(val:String):Void {
        GlobalPlayer.parser.setInt(this._menuVariable, val);
        if (this._menuAction != null) GlobalPlayer.parser.run(this._menuAction, true);
    }

    public function loadLoadingIc() {
        if (this._loadingOverlay == null) {
            this._loadingOverlay = GlobalPlayer.area.getOverlay('contraptions-loading');
            this._loadingOverlay.visible = false;
            this._loadingIc = new SpritemapImage(onLoadingIc);
            this._loadingOverlay.addChild(this._loadingIc);
        }
        this._loadingIc.visible = false;
        this._loadingOverlay.visible = false;
        this._loadingIc.unload();
        if (GlobalPlayer.mdata.loadingic[0] != '') {
            this._loadingIc.frames = Std.parseInt(GlobalPlayer.mdata.loadingic[1]);
            this._loadingIc.frtime = Std.parseInt(GlobalPlayer.mdata.loadingic[2]);
            this._loadingIc.load(GlobalPlayer.mdata.loadingic[0]);
        }
    }

    public function showLoadingIc():Void{
        if (this._loadingIc.mediaLoaded) {
            this._loadingIc.visible = true;
            this._loadingOverlay.visible = true;
        } else {
            this._loadingIc.visible = false;
            this._loadingOverlay.visible = false;
        }
    }

    public function hideLoadingIc():Void{
        this._loadingIc.visible = false;
        this._loadingOverlay.visible = false;
    }

    private function onLoadingIc(ok:Bool):Void
    {
        if (ok) {
            this._loadingIc.x = (GlobalPlayer.area.aWidth - this._loadingIc.width) / 2;
            this._loadingIc.y = (GlobalPlayer.area.aHeight - this._loadingIc.height) / 2;
        } else {
            this._loadingIc.visible = false;
            this._loadingOverlay.visible = false;
        }
    }

    public function zoomInstance(inst:String):Bool {
        if (this._zoomOverlay == null) {
            this._zoomOverlay = GlobalPlayer.area.getOverlay('contraptions-zoom');
            this._zoomOverlay.visible = false;
            this._zoomPicture = new PictureImage(onZoomPic);
            this._zoomPicture.visible = false;
            this._zoomOverlay.addChild(this._zoomPicture);
            this._zoomVideo = new VideoImage(onZoomVideo, onZoomVideoEnd);
            this._zoomVideo.visible = false;
            this._zoomOverlay.addChild(this._zoomVideo);
        }
        var inst:InstanceImage = GlobalPlayer.area.pickInstance(inst);
        if (inst == null) {
            this._zoomOverlay.visible = false;
            this._zoomPicture.visible = false;
            this._zoomVideo.visible = false;
            this._zoomPicture.unload();
            this._zoomVideo.unload();
            return (false);
        } else {
            if (inst.currentType == 'picture') {
                this._zoomPicture.load(inst.currentMedia);
                return (true);
            } else if (inst.currentType == 'video') {
                this._zoomVideo.load(inst.currentMedia);
                return (true);
            } else {
                this._zoomOverlay.visible = false;
                this._zoomPicture.visible = false;
                this._zoomVideo.visible = false;
                this._zoomPicture.unload();
                this._zoomVideo.unload();
                return (false);
            }
        }
    }

    private function onZoomPic(ok:Bool):Void {
        this._zoomOverlay.visible = false;
        this._zoomPicture.visible = false;
        this._zoomVideo.visible = false;
        if (ok) {
            this._zoomOverlay.graphics.clear();
            this._zoomOverlay.graphics.beginFill(0, 0.5);
            this._zoomOverlay.graphics.drawRect(0, 0, GlobalPlayer.area.aWidth, GlobalPlayer.area.aHeight);
            this._zoomOverlay.graphics.endFill();
            GlobalPlayer.area.pause();
            this._zoomPicture.width = GlobalPlayer.area.aWidth - 10;
            this._zoomPicture.height = this._zoomPicture.width * (this._zoomPicture.oHeight / this._zoomPicture.oWidth);
            if (this._zoomPicture.height > (GlobalPlayer.area.aHeight - 10)) {
                this._zoomPicture.height = GlobalPlayer.area.aHeight - 10;
                this._zoomPicture.width = this._zoomPicture.height * (this._zoomPicture.oWidth / this._zoomPicture.oHeight);
            }
            this._zoomPicture.visible = true;
            this._zoomOverlay.visible = true;    
            this._zoomPicture.x = (GlobalPlayer.area.aWidth - this._zoomPicture.width) / 2;
            this._zoomPicture.y = (GlobalPlayer.area.aHeight - this._zoomPicture.height) / 2;
            this._zoomPicture.addEventListener(MouseEvent.CLICK, onZoomPClick);
        } else {
            this._zoomPicture.unload();
            this._zoomVideo.unload();
        }
    }

    private function onZoomVideo(ok:Bool):Void {
        this._zoomOverlay.visible = false;
        this._zoomPicture.visible = false;
        this._zoomVideo.visible = false;
        if (ok) {
            this._zoomOverlay.graphics.clear();
            this._zoomOverlay.graphics.beginFill(0, 0.5);
            this._zoomOverlay.graphics.drawRect(0, 0, GlobalPlayer.area.aWidth, GlobalPlayer.area.aHeight);
            this._zoomOverlay.graphics.endFill();
            GlobalPlayer.area.pause();
            this._zoomVideo.width = GlobalPlayer.area.aWidth - 10;
            this._zoomVideo.height = this._zoomVideo.width * (this._zoomVideo.oHeight / this._zoomVideo.oWidth);
            if (this._zoomVideo.height > (GlobalPlayer.area.aHeight - 10)) {
                this._zoomVideo.height = GlobalPlayer.area.aHeight - 10;
                this._zoomVideo.width = this._zoomVideo.height * (this._zoomVideo.oWidth / this._zoomVideo.oHeight);
            }
            this._zoomVideo.visible = true;
            this._zoomOverlay.visible = true;
            this._zoomVideo.play();
            this._zoomVideo.addEventListener(MouseEvent.CLICK, onZoomVClick);
        } else {
            this._zoomPicture.unload();
            this._zoomVideo.unload();
        }
    }

    private function onZoomVideoEnd():Void {
        this._zoomVideo.setTime(0);
        this._zoomVideo.play();
    }

    private function onZoomPClick(evt:MouseEvent):Void {
        this._zoomPicture.removeEventListener(MouseEvent.CLICK, onZoomPClick);
        this._zoomOverlay.visible = false;
        this._zoomPicture.visible = false;
        this._zoomVideo.visible = false;
        this._zoomPicture.unload();
        this._zoomVideo.unload();
        GlobalPlayer.area.play();
    }

    private function onZoomVClick(evt:MouseEvent):Void {
        this._zoomVideo.removeEventListener(MouseEvent.CLICK, onZoomVClick);
        this._zoomOverlay.visible = false;
        this._zoomPicture.visible = false;
        this._zoomVideo.visible = false;
        this._zoomPicture.unload();
        this._zoomVideo.unload();
        GlobalPlayer.area.play();
    }

}