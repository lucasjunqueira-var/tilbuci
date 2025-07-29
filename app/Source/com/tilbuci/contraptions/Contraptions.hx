/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.contraptions;

import com.tilbuci.player.MovieArea;
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

    // cover contraption
    public var covers:Map<String, CoverContraption> = [ ];
    private var _coverOverlay:Sprite;

    // background contraption
    public var backgrounds:Map<String, BackgroundContraption> = [ ];
    private var _backgroundOverlay:Sprite;

    // scene loading icon
    private var _loadingOverlay:Sprite;
    private var _loadingIc:SpritemapImage;

    // image zoom
    private var _zoomOverlay:Sprite;
    private var _zoomPicture:PictureImage;
    private var _zoomVideo:VideoImage;

    // music
    public var musics:Map<String, MusicContraption> = [ ];

    // forms
    public var forms:Map<String, FormContraption> = [ ];
    private var _formsOverlay:Sprite;
    private var _formcurrent:String = '';

    // interface
    public var interf:Map<String, InterfaceContraption> = [ ];
    private var _interfaceOverlay:Sprite;

    public function new() {

    }

    private function getLayers():Void {
        if (this._coverOverlay == null) this._coverOverlay = GlobalPlayer.area.getOverlay('contraptions-cover');
        this._coverOverlay.mouseEnabled = false;
        if (this._backgroundOverlay == null) this._backgroundOverlay = GlobalPlayer.area.getOverlay('contraptions-background', true);
        this._backgroundOverlay.mouseEnabled = false;
        if (this._zoomOverlay == null) this._zoomOverlay = GlobalPlayer.area.getOverlay('contraptions-zoom');
        if (this._formsOverlay == null) this._formsOverlay = GlobalPlayer.area.getOverlay('contraptions-forms');
        if (this._menusOverlay == null) this._menusOverlay = GlobalPlayer.area.getOverlay('contraptions-menu');
        if (this._interfaceOverlay == null) this._interfaceOverlay = GlobalPlayer.area.getOverlay('contraptions-interface');
        if (this._loadingOverlay == null) this._loadingOverlay = GlobalPlayer.area.getOverlay('contraptions-loading');
        this._loadingOverlay.mouseEnabled = false;
    }

    public function clear():Void {
        this.getLayers();
        for (k in this.covers.keys()) {
            this.covers[k].kill();
            this.covers.remove(k);
        }
        this._coverOverlay.graphics.clear();
        for (k in this.backgrounds.keys()) {
            this.backgrounds[k].kill();
            this.backgrounds.remove(k);
        }
        this._backgroundOverlay.graphics.clear();
        for (k in this.menus.keys()) {
            this.menus[k].kill();
            this.menus.remove(k);
        }
        this._menusOverlay.graphics.clear();
        for (k in this.forms.keys()) {
            this.forms[k].kill();
            this.forms.remove(k);
        }
        this._formsOverlay.graphics.clear();
        for (k in this.interf.keys()) {
            this.interf[k].kill();
            this.interf.remove(k);
        }
        this._interfaceOverlay.graphics.clear();
    }

    public function removeAll():Void {
        for (k in this.menus.keys()) {
            this.menus[k].kill();
            this.menus.remove(k);
        }
        for (k in this.covers.keys()) {
            this.covers[k].kill();
            this.covers.remove(k);
        }
        for (k in this.backgrounds.keys()) {
            this.backgrounds[k].kill();
            this.backgrounds.remove(k);
        }
        for (k in this.musics.keys()) {
            this.musics[k].kill();
            this.musics.remove(k);
        }
        for (k in this.forms.keys()) {
            this.forms[k].kill();
            this.forms.remove(k);
        }
        for (k in this.interf.keys()) {
            this.interf[k].kill();
            this.interf.remove(k);
        }
    }

    public function getData():String {
        var data:Map<String, Array<Dynamic>> = [ ];
        data['covers'] = new Array<Dynamic>();
        for (cv in this.covers) {
            data['covers'].push(cv.toObject());
        }
        data['backgrounds'] = new Array<Dynamic>();
        for (cv in this.backgrounds) {
            data['backgrounds'].push(cv.toObject());
        }
        data['menus'] = new Array<Dynamic>();
        for (mn in this.menus) {
            data['menus'].push(mn.toObject());
        }
        data['musics'] = new Array<Dynamic>();
        for (ms in this.musics) {
            data['musics'].push(ms.toObject());
        }
        data['forms'] = new Array<Dynamic>();
        for (ms in this.forms) {
            data['forms'].push(ms.toObject());
        }
        data['interf'] = new Array<Dynamic>();
        for (ms in this.interf) {
            data['interf'].push(ms.toObject());
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

    public function changeDisplay()
    {
        if (this._backgroundOverlay.visible && (this._backgroundOverlay.numChildren > 0)) {
            var bcg:BackgroundContraption = cast(this._backgroundOverlay.getChildAt(0));
            bcg.getCover();
        }
        if (this._coverOverlay.visible && (this._coverOverlay.numChildren > 0)) {
            var cov:CoverContraption = cast(this._coverOverlay.getChildAt(0));
            cov.getCover();
        }
    }

    public function removeContraptions(all:Bool = false):Void {
        this.menuHide();
        this.hideForm();
        this.hideLoadingIc();
        this.removeZoom();
        if (all) {
            this.musicStop();
            this.hideCover();
            this.hideBackground();
            this.hideAllInterfaces();
        }
    }

    public function musicPlay(name:String):Bool {
        if (this.musics.exists(name)) {
            for (ms in this.musics) {
                if (ms.id == name) ms.play();
                    else ms.pause();
            }
            return (true);
        } else {
            return (false);
        }
    }

    public function musicPause():Void {
        for (ms in this.musics) ms.pause();
    }

    public function musicStop():Void {
        for (ms in this.musics) ms.stop();
    }

    public function musicVolume(vol:Int):Void {
        for (ms in this.musics) ms.volume(vol);
    }

    public function menuHide():Void {
        if (this._coverOverlay == null) this._coverOverlay = GlobalPlayer.area.getOverlay('contraptions-cover');
        for (mn in this.menus) mn.remove();
        this.getLayers();
        this._menusOverlay.graphics.clear();
    }

    private function onMenuSelect(val:String):Void {
        GlobalPlayer.parser.setInt(this._menuVariable, val);
        if (this._menuAction != null) GlobalPlayer.parser.run(this._menuAction, true);
    }

    public function loadLoadingIc() {
        if (this._loadingOverlay == null) {
            this.getLayers();
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
            this.getLayers();
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

    private function removeZoom():Void {
        if (this._zoomOverlay != null) {
            if (this._zoomPicture != null) {
                if (this._zoomPicture.hasEventListener(MouseEvent.CLICK)) this._zoomPicture.removeEventListener(MouseEvent.CLICK, onZoomPClick);
                this._zoomPicture.visible = false;
                this._zoomPicture.unload();
            }
            if (this._zoomVideo != null) {
                if (this._zoomVideo.hasEventListener(MouseEvent.CLICK)) this._zoomVideo.removeEventListener(MouseEvent.CLICK, onZoomVClick);
                this._zoomVideo.visible = false;
                this._zoomVideo.unload();
            }
            this._zoomOverlay.visible = false;
        }
    }

    public function showCover(name:String):Bool {
        this.getLayers();
        if (this.covers.exists(name)) {
            this._coverOverlay.removeChildren();
            this._coverOverlay.addChild(this.covers[name].getCover());
            this._coverOverlay.mouseEnabled = this.covers[name].holdClick;
            this._coverOverlay.visible = true;
            return (true);
        } else {
            return (false);
        }
    }

    public function hideCover():Void {
        this.getLayers();
        this._coverOverlay.removeChildren();
        this._coverOverlay.visible = false;
        this._coverOverlay.mouseEnabled = false;
    }

    public function showBackground(name:String):Bool {
        this.getLayers();
        if (this.backgrounds.exists(name)) {
            this._backgroundOverlay.removeChildren();
            this._backgroundOverlay.addChild(this.backgrounds[name].getCover());
            this._backgroundOverlay.visible = true;
            return (true);
        } else {
            return (false);
        }
    }

    public function hideBackground():Void {
        this.getLayers();
        this._backgroundOverlay.removeChildren();
        this._backgroundOverlay.visible = false;
        this._backgroundOverlay.mouseEnabled = false;
    }

    public function hideForm():Void {
        this._formsOverlay.removeChildren();
        this._formsOverlay.visible = false;
    }

    public function showForm(nm:String, px:Int, py:Int, acok:Dynamic = null, accancel:Dynamic = null):Bool {
        this.hideForm();
        if (this.forms.exists(nm)) {
            this.forms[nm].start(acok, accancel);
            this.forms[nm].x = px;
            this.forms[nm].y = py;
            this._formsOverlay.addChild(this.forms[nm]);
            this._formsOverlay.visible = true;
            this._formcurrent = nm;
            return (true);
        } else {
            return (false);
        }
    }

    public function setFormValue(nm:String, val:String):Bool {
        if (this._formcurrent == '') {
            return (false);
        } else {
            return (this.forms[this._formcurrent].setValue(nm, val));
        }
    }

    public function setFormStepper(nm:String, min:Int, max:Int, stp:Int):Bool {
        if (this._formcurrent == '') {
            return (false);
        } else {
            return (this.forms[this._formcurrent].setStepper(nm, min, max, stp));
        }
    }

    public function getFormValue(nm:String):String {
        if (this._formcurrent == '') {
            return ('');
        } else {
            return (this.forms[this._formcurrent].getValue(nm));
        }
    }

    public function hideAllInterfaces():Void {
        this._interfaceOverlay.removeChildren();
        this._interfaceOverlay.visible = false;
    }

    public function hideInterface(nm:String):Void {
        if (this.interf.exists(nm)) {
            this.interf[nm].remove();
        }
        if (this._interfaceOverlay.numChildren == 0) this._interfaceOverlay.visible = false;
    }

    public function showInterface(nm:String, px:Int, py:Int):Bool {
        this.hideInterface(nm);
        if (this.interf.exists(nm)) {
            this.interf[nm].start();
            this.interf[nm].x = px;
            this.interf[nm].y = py;
            this._interfaceOverlay.addChild(this.interf[nm]);
            this._interfaceOverlay.visible = true;
            return (true);
        } else {
            return (false);
        }
    }

    public function setInterfaceText(nm:String, tx:String):Bool {
        if (this.interf.exists(nm)) {
            return (this.interf[nm].setText(tx));
        } else {
            return (false);
        }
    }

    public function setInterfaceFrame(nm:String, fr:Int):Bool {
        if (this.interf.exists(nm)) {
            return (this.interf[nm].setMapFrame(fr));
        } else {
            return (false);
        }
    }

    public function pauseInterface(nm:String):Bool {
        if (this.interf.exists(nm)) {
            return (this.interf[nm].pauseMap());
        } else {
            return (false);
        }
    }

    public function playInterface(nm:String):Bool {
        if (this.interf.exists(nm)) {
            return (this.interf[nm].playMap());
        } else {
            return (false);
        }
    }

}