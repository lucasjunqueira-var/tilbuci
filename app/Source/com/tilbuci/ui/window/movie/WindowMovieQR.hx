/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window.movie;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
import haxe.io.Bytes;
import com.tilbuci.ui.base.InterfaceFactory;
import openfl.events.Event;
import openfl.display.Stage;
import com.tilbuci.statictools.Assets;
import haxe.crypto.Base64;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;

class WindowMovieQR extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-qr-title'), 800, InterfaceFactory.pickValue(490, 540), false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {

        this.ui.createHContainer('url');
        this.ui.createToggle('url', true, this.ui.hcontainers['url']);
        this.ui.createSpacer('url', 10, false, this.ui.hcontainers['url']);
        this.ui.createLabel('url', Global.ln.get('window-qr-addurl'), 'detail', this.ui.hcontainers['url']);
        
        this.ui.createHContainer('var1');
        this.ui.createLabel('var1n', Global.ln.get('window-qr-var1n'), 'detail', this.ui.hcontainers['var1']);
        this.ui.createTInput('var1n', '', '', this.ui.hcontainers['var1']);
        this.ui.createSpacer('var1', 10, false, this.ui.hcontainers['var1']);
        this.ui.createLabel('var1v', Global.ln.get('window-qr-var1v'), 'detail', this.ui.hcontainers['var1']);
        this.ui.createTInput('var1v', '', '', this.ui.hcontainers['var1']);

        this.ui.createHContainer('var2');
        this.ui.createLabel('var2n', Global.ln.get('window-qr-var2n'), 'detail', this.ui.hcontainers['var2']);
        this.ui.createTInput('var2n', '', '', this.ui.hcontainers['var2']);
        this.ui.createSpacer('var2', 10, false, this.ui.hcontainers['var2']);
        this.ui.createLabel('var2v', Global.ln.get('window-qr-var2v'), 'detail', this.ui.hcontainers['var2']);
        this.ui.createTInput('var2v', '', '', this.ui.hcontainers['var2']);

        this.addForm('intr', this.ui.forge('interface', [
            { tp: 'Label', id: 'about', tx: Global.ln.get('window-qr-about'), vr: '' }, 
            { tp: 'Spacer', id: 'about', ht: 10, ln: false }, 
            { tp: 'Label', id: 'scenes', tx: Global.ln.get('window-qr-scenes'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Select', id: 'scenes', vl: [ ], sl: '' }, 
            { tp: 'Spacer', id: 'scenes', ht: 10, ln: false }, 
            { tp: 'Label', id: 'snippet', tx: Global.ln.get('window-qr-snippet'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'TInput', id: 'snippet', tx: '', vr: '' }, 
            { tp: 'Spacer', id: 'snippet', ht: 10, ln: false },
            { tp: 'Label', id: 'variables', tx: Global.ln.get('window-qr-variables'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Custom', cont: this.ui.hcontainers['var1'] }, 
            { tp: 'Custom', cont: this.ui.hcontainers['var2'] }, 
            { tp: 'Spacer', id: 'variables', ht: 20, ln: false },
            { tp: 'Custom', cont: this.ui.hcontainers['url'] }, 
            { tp: 'Spacer', id: 'url', ht: 20, ln: false },
            { tp: 'Button', id: 'download', tx: Global.ln.get('window-qr-download'), ac: this.onDownload }
        ]));
        this.ui.labels['about'].wordWrap = true;
        super.startInterface();
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        this.ui.setSelectOptions('scenes', [ ]);
        this.ui.hcontainers['url'].setWidth(600, [50, 10, 510]);
        this.ui.hcontainers['var1'].setWidth(760, [110, 220, 60, 80, 250]);
        this.ui.hcontainers['var2'].setWidth(760, [110, 220, 60, 80, 250]);
        Global.ws.send('Scene/List', [ 'movie' => GlobalPlayer.movie.mvId ], this.onList);
    }

    /**
        The scenes list is available.
    **/
    private function onList(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-qr-title'), Global.ln.get('window-qr-nolist'), 420, 150, this.stage);
            PopUpManager.removePopUp(this);
        } else {
            if (ld.map['e'] == 0) {
                var ar:Array<Dynamic> = cast ld.map['list'];
                if (ar.length > 0) {
                    var items:Array<Dynamic> = [ ];
                    items.push({ text: Global.ln.get('window-qr-noscene'), value: '' });
                    for (i in ar) items.push({ text: Reflect.field(i, 'title'), value: Reflect.field(i, 'id') });
                    this.ui.setSelectOptions('scenes', items);
                }
            } else {
                this.ui.createWarning(Global.ln.get('window-qr-title'), Global.ln.get('window-qr-nolist'), 420, 150, this.stage);
                PopUpManager.removePopUp(this);
            }
        }
    }

    /**
        Downloads the QR code.
    **/
    private function onDownload(evt:TriggerEvent):Void {
        var sc:String = this.ui.selects['scenes'].selectedItem.value;
        if ((sc == '') && (this.ui.inputs['snippet'].text == '') && (this.ui.inputs['var1n'].text == '') && (this.ui.inputs['var2n'].text == '')) {
            this.ui.createWarning(Global.ln.get('window-qr-title'), Global.ln.get('window-qr-nodata'), 420, 150, this.stage);
        } else {
            var link:String = '';
            var name:String = '';
            if (sc != '') {
                if (this.ui.toggles['url'].selected) link += (GlobalPlayer.base + '?');
                link += 'mv=' + GlobalPlayer.movie.mvId + '&sc=' + sc;
                name = sc;
            }
            if (this.ui.inputs['snippet'].text != '') {
                link += '&sn=' + StringTools.urlEncode(this.ui.inputs['snippet'].text);
                name += StringTools.replace(this.ui.inputs['snippet'].text, ' ', '');
            }
            if ((this.ui.inputs['var1n'].text != '') || (this.ui.inputs['var2n'].text != '')) {
                var json:Dynamic = { };
                if (this.ui.inputs['var1n'].text != '') Reflect.setField(json, this.ui.inputs['var1n'].text, this.ui.inputs['var1v'].text);
                if (this.ui.inputs['var2n'].text != '') Reflect.setField(json, this.ui.inputs['var2n'].text, this.ui.inputs['var2v'].text);
                link += '&vars=' + Base64.encode(Bytes.ofString(StringStatic.jsonStringify(json)));
            }
            Global.ws.download([
                'file' => 'qrcode', 
                'link' => Base64.encode(Bytes.ofString(link)), 
                'name' => name
            ]);
        }
    }

}