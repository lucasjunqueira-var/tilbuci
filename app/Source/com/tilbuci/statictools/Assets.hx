/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package com.tilbuci.statictools;

import openfl.net.URLLoader;
import openfl.display.Bitmap;
import openfl.net.URLRequest;
import openfl.events.Event;
import openfl.display.BitmapData;
import openfl.events.EventDispatcher;
import openfl.Lib;
import openfl.display.Loader;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;

class Assets extends EventDispatcher {

    public static var graphics:Map<String, TBAsset> = [ ];

    public static var texts:Map<String, String> = [ ];

    private var _edAssets:Array<String> = [
        'buci',
        'tilBuci01',
        'tilBuci02',
        'tilBuci03',
        'tilBuci04',
        'tilBuci05',
        'btBack',
        'btClose',
        'btOk',
        'btMovie',
        'btScene',
        'btMovieScene',
        'btData',
        'icData',
        'icInput',
        'icSystem',
        'icReplace',
        'icSnippets',
        'icText',
        'icTimer',
        'icUser',
        'icDebug',
        'icShare',
        'icGoogle',
        'icContraption',
        'icNarrative',
        'icServer',
        'btPlus',
        'btPlugin',
        'btSetup',
        'btToggle',
        'btZoomP',
        'btZoomM',
        'btZoomFit',
        'btZoom100',
        'btMedia',
        'btFolder',
        'iconFolder',
        'iconUpLevel',
        'iconPublished',
        'btPlay',
        'btPause',
        'btStop',
        'btLeft',
        'btRight',
        'btUp',
        'btDown',
        'btKeyframe',
        'btFullscreen',
        'btWorkspace',
        'btScreen',
        'btFocus',
        'btColors',
        'btOpenfile',
        'btCopy',
        'btPaste',
        'btNone',
        'btAll',
        'btStageLeft',
        'btStageCenter',
        'btStageRight',
        'btStageTop',
        'btStageMiddle',
        'btStageBottom',
        'btSelectionLeft',
        'btSelectionCenter',
        'btSelectionRight',
        'btSelectionTop',
        'btSelectionMiddle',
        'btSelectionBottom',
        'btDistributeH',
        'btDistributeV',
        'btBool',
        'btInteger',
        'btFloat',
        'btString',
        'btVariables',
        'btToLeft',
        'btToRight',
        'btToCenter',
        'btToTop',
        'btToDown',
        'btToMiddle',
        'btExchange',
        'btVisitors',
        'btContraptions',
        'btNarrative',
        'iconMove',
        'iconResizeH',
        'iconResizeV',
        'iconResize',
        'iconPlus',
        'iconMinus',
        'iconDown',
        'iconUp',
        'iconLock',
        'iconLandscape',
        'iconPortrait',
        'btBlocks',
        'btCode',
        'btDel',
        'btEdit',
        'btExpand',
        'btCompress',
        'btNotes',
        'btLock',
        'icTarget'
    ];

    private var _edTexts:Array<TbTxtAsset> = [
        { name: 'buildInfo', path: 'assets/build.json' }, 
        { name: 'license', path: 'assets/license.html' }, 
        { name: 'langDefault', path: 'assets/language/default.json' }
    ];

    private var _plAssets:Array<String> = [
        'btClose', 
	    'btOk', 
	    'icTarget'
    ]; 

    private var _plTexts:Array<TbTxtAsset> = [
        { name: 'langDefault', path: 'assets/language/default.json' }
    ];

    private var _reaAssets:Array<String>; 

    private var _realTexts:Array<TbTxtAsset>;

    private var _path:String = 'assets/icons/';

    private var _curLoad:Int = -1;

    private var _curTxtLoad:Int = -1;

    private var _bmpLoader:Loader;

    private var _txtLoader:URLLoader;

    public var complete:Int = 0;

    public function new() {
        super();
        if (Reflect.hasField(Lib.current.stage.application.window.parameters, 'mode')) {
            if (Lib.current.stage.application.window.parameters.mode == 'editor') {
                this._reaAssets = this._edAssets;
                this._realTexts = this._edTexts;
            } else {
                this._reaAssets = this._plAssets;
                this._realTexts = this._plTexts;
            }
        } else {
            // failsafe
            this._reaAssets = this._edAssets;
            this._realTexts = this._edTexts;
        }

        if (Reflect.hasField(Lib.current.stage.application.window.parameters, 'assets')) {
            this._path = Lib.current.stage.application.window.parameters.assets + this._path;
            for (i in 0...this._realTexts.length) {
                this._realTexts[i].path = Lib.current.stage.application.window.parameters.assets + this._realTexts[i].path;
            }
        }

        this._txtLoader = new URLLoader();
        this._txtLoader.addEventListener(Event.COMPLETE, onTxtOk);
        this._txtLoader.addEventListener(IOErrorEvent.IO_ERROR, onTxtError);
        this._txtLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onTxtError);
        this.loadNextTxt();

        this._bmpLoader = new Loader();
        this._bmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onOk);
        this._bmpLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        this._bmpLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
        this.loadNext();
    }

    private function loadNext():Void {
        this._curLoad++;
        if (this._curLoad < this._reaAssets.length) {
            this.complete = Math.round((100 * this._curLoad) / this._reaAssets.length);
            this._bmpLoader.load(new URLRequest(this._path + this._reaAssets[this._curLoad] + '.png'));
        } else {
            this._bmpLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onOk);
            this._bmpLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
            this._bmpLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            this._bmpLoader.unload();
            this._bmpLoader = null;
            this.complete = 100;
            this.dispatchEvent(new Event(openfl.events.Event.COMPLETE));
        }
    }

    private function loadNextTxt():Void {
        this._curTxtLoad++;
        if (this._curTxtLoad < this._realTexts.length) {
            this._txtLoader.load(new URLRequest(this._realTexts[this._curTxtLoad].path));
        } else {
            this._txtLoader.removeEventListener(Event.COMPLETE, onTxtOk);
            this._txtLoader.removeEventListener(IOErrorEvent.IO_ERROR, onTxtError);
            this._txtLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onTxtError);
            this._txtLoader = null;
        }
    }

    private function onOk(evt:Event):Void {
        var bmp:Bitmap = cast this._bmpLoader.content;
        Assets.graphics.set(this._reaAssets[this._curLoad], {
            data: bmp.bitmapData.clone(), 
            loaded: true, 
        });
        this._bmpLoader.unload();
        this.dispatchEvent(new Event(Event.CHANGE));
        this.loadNext();
    }

    private function onError(evt:Event):Void {
        this.loadNext();
    }

    private function onTxtOk(evt:Event):Void {
        var txt:String = cast this._txtLoader.data;
        Assets.texts.set(this._realTexts[this._curTxtLoad].name, txt);
        this.loadNextTxt();
    }

    private function onTxtError(evt:Event):Void {
        this.loadNextTxt();
    }

    public static function getBitmapData(name:String, comp:Bool = true):BitmapData {
        if (Assets.graphics.exists(name)) {
            return (Assets.graphics[name].data);
        } else {
            return (new BitmapData(32, 32, false));
        }
    }

    public static function getText(name:String, comp:Bool = true):String {
        if (Assets.texts.exists(name)) {
            return (Assets.texts[name]);
        } else {
            return ('');
        }
    }

}

typedef TBAsset = {
    var data:BitmapData;
    var loaded:Bool;
};

typedef TbTxtAsset = {
    var name:String;
    var path:String;
}