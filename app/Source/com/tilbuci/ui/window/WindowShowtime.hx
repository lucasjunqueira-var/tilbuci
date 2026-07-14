/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window;

/** OPENFL **/
import openfl.events.Event;
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.data.GlobalPlayer;
import openfl.text.TextField;
import feathers.controls.TextArea;
//import openfl.Assets;
import com.tilbuci.statictools.Assets;
import openfl.display.Bitmap;
import openfl.text.TextFieldAutoSize;
import openfl.Lib;
import openfl.net.URLRequest;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.Global;
import com.tilbuci.data.DataLoader;

class WindowShowtime extends PopupWindow {

    /**
        original application name
    **/
    private var stName:String = '';

    /**
        Constructor.
        @param  ac  the menu action mehtod
        @param  build   Tilbuci build information
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-showtime-title'), 900, InterfaceFactory.pickValue(560, 640), true, true, true);

        // configuration
        this.ui.createHContainer('apptype');
        this.ui.createLabel('apptype', Global.ln.get('window-showtime-apptype'), '', this.ui.hcontainers['apptype']);
        this.ui.createTInput('apptype', '', '', this.ui.hcontainers['apptype']);
        this.ui.inputs['apptype'].enabled = false;

        this.ui.createHContainer('inimovie');
        this.ui.createLabel('inimovie', Global.ln.get('window-showtime-inimovie'), '', this.ui.hcontainers['inimovie']);
        this.ui.createSelect('inimovie', [], null, this.ui.hcontainers['inimovie']);

        this.ui.createHContainer('appid');
        this.ui.createLabel('appid', Global.ln.get('window-showtime-appid'), '', this.ui.hcontainers['appid']);
        this.ui.createTInput('appid', '', '', this.ui.hcontainers['appid']);

        this.ui.createHContainer('accessk');
        this.ui.createLabel('accessk', Global.ln.get('window-showtime-accessk'), '', this.ui.hcontainers['accessk']);
        this.ui.createTInput('accessk', '', '', this.ui.hcontainers['accessk']);

        this.ui.createHContainer('mouse');
        this.ui.createLabel('mouse', Global.ln.get('window-showtime-mouse'), '', this.ui.hcontainers['mouse']);
        this.ui.createToggle('mouse', false, this.ui.hcontainers['mouse']);
        this.ui.createLabel('mouse2', '', '', this.ui.hcontainers['mouse']);

        this.ui.createHContainer('startup');
        this.ui.createLabel('startup', Global.ln.get('window-showtime-startup'), '', this.ui.hcontainers['startup']);
        this.ui.createToggle('startup', false, this.ui.hcontainers['startup']);
        this.ui.createLabel('startup2', '', '', this.ui.hcontainers['startup']);

        this.ui.createHContainer('serial');
        this.ui.createLabel('serial', Global.ln.get('window-showtime-serial'), '', this.ui.hcontainers['serial']);
        this.ui.createTInput('serial', '', '', this.ui.hcontainers['serial']);

        this.ui.createHContainer('baud');
        this.ui.createLabel('baud', Global.ln.get('window-showtime-baud'), '', this.ui.hcontainers['baud']);
        this.ui.createSelect('baud', [
            { text: '9600', value: '9600' }, 
            { text: '19200', value: '19200' }, 
            { text: '38400', value: '38400' }, 
            { text: '57600', value: '57600' }, 
            { text: '115200', value: '115200' }
        ], null, this.ui.hcontainers['baud']);

        this.addForm(Global.ln.get('window-showtime-conf-title'), this.ui.forge('form-conf', [
            { tp: 'Label', id: 'confabout', tx: Global.ln.get('window-showtime-confabout'), vr: '' },
            { tp: 'Spacer', id: 'confabout', ht: 20, ln: false },
            { tp: 'Custom', cont: this.ui.hcontainers['apptype'] },  
            { tp: 'Custom', cont: this.ui.hcontainers['inimovie'] },  
            { tp: 'Custom', cont: this.ui.hcontainers['appid'] },  
            { tp: 'Custom', cont: this.ui.hcontainers['accessk'] },  
            { tp: 'Custom', cont: this.ui.hcontainers['mouse'] },  
            { tp: 'Custom', cont: this.ui.hcontainers['startup'] },  
            { tp: 'Custom', cont: this.ui.hcontainers['serial'] },  
            { tp: 'Custom', cont: this.ui.hcontainers['baud'] },  
            { tp: 'Spacer', id: 'confbt', ht: 120, ln: false },
            { tp: 'Button', id: 'confbt', tx: Global.ln.get('window-showtime-confbt'), ac: this.onConfig }, 
        ]));
        this.ui.labels['confabout'].wordWrap = true;

        // accesses
        this.addForm(Global.ln.get('window-showtime-access-title'), this.ui.forge('form-access', [
            { tp: 'Label', id: 'accessabout', tx: Global.ln.get('window-showtime-accessabout'), vr: '' }, 
            { tp: 'List', id: 'accesslist', vl: [ ], ht: 430, sl: '' }, 
        ]));
        this.ui.labels['accessabout'].wordWrap = true;

        // movies
        this.addForm(Global.ln.get('window-showtime-movies-title'), this.ui.forge('form-movie', [
            { tp: 'Label', id: 'remove', tx: Global.ln.get('window-showtime-removeabout'), vr: '' }, 
            { tp: 'Select', id: 'remove', vl: [ ], sl: '' }, 
            { tp: 'Button', id: 'remove', tx: Global.ln.get('window-showtime-removebt'), ac: this.onRemove }, 
            { tp: 'Spacer', id: 'remove', ht: 40, ln: true },
            { tp: 'Label', id: 'upload', tx: Global.ln.get('window-showtime-uploadabout'), vr: '' }, 
            { tp: 'Select', id: 'upload', vl: [ ], sl: '' }, 
            { tp: 'Button', id: 'upload', tx: Global.ln.get('window-showtime-uploadbt'), ac: this.onUpload }, 
        ]));
        this.ui.labels['remove'].wordWrap = true;
        this.ui.labels['upload'].wordWrap = true;

        // adjusting sizes
        this.redraw();
    }

    override public function action(ac:String, data:Map<String, Dynamic> = null) {
        switch (ac) {
            case 'load':
                this.stName = data['name'];
                Global.ws.send('Movie/ShowtimeInst', [
                    'name' => data['name']
                ], onInstData);
        }
    }

    /**
        New interface shown on tab navigator.
    **/
    override private function onTab(evt:Event):Void {
        super.onTab(evt);
        this.ui.hcontainers['apptype'].setWidth(860, [250, 575]);
        this.ui.hcontainers['inimovie'].setWidth(860, [250, 575]);
        this.ui.hcontainers['appid'].setWidth(860, [250, 575]);
        this.ui.hcontainers['accessk'].setWidth(860, [250, 575]);
        this.ui.hcontainers['mouse'].setWidth(860, [250, 75, 490]);
        this.ui.hcontainers['startup'].setWidth(860, [250, 75, 490]);
        this.ui.hcontainers['serial'].setWidth(860, [250, 575]);
        this.ui.hcontainers['baud'].setWidth(860, [250, 575]);
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        this.ui.hcontainers['apptype'].setWidth(860, [250, 575]);
        this.ui.hcontainers['inimovie'].setWidth(860, [250, 575]);
        this.ui.hcontainers['appid'].setWidth(860, [250, 575]);
        this.ui.hcontainers['accessk'].setWidth(860, [250, 575]);
        this.ui.hcontainers['mouse'].setWidth(860, [250, 75, 490]);
        this.ui.hcontainers['startup'].setWidth(860, [250, 75, 490]);
        this.ui.hcontainers['serial'].setWidth(860, [250, 575]);
        this.ui.hcontainers['baud'].setWidth(860, [250, 575]);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /** PRVATE METHODS **/

    /**
        Update application configuration.
    **/
    private function onConfig(evt:TriggerEvent):Void {
        if ((this.ui.inputs['appid'].text.length < 5) || (this.ui.inputs['accessk'].text.length != 5)) {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-confno'), 400, 180, this.stage);
        } else {
            var regex = ~/^[ABCD]{5}$/;
            if (regex.match(this.ui.inputs['accessk'].text)) {
                Global.ws.send('Movie/ShowtimeConf', [
                    'name' => this.stName, 
                    'movie' => this.ui.selects['inimovie'].selectedItem.value, 
                    'accesskey' => this.ui.inputs['accessk'].text, 
                    'identifier' => this.ui.inputs['appid'].text, 
                    'autoStart' => this.ui.toggles['startup'].selected, 
                    'hideCursor' => this.ui.toggles['mouse'].selected, 
                    'serialPort' => this.ui.inputs['serial'].text, 
                    'serialBaud' => this.ui.selects['baud'].selectedItem.value, 
                ], onConfigReturn);
            } else {
                this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-confnoakey'), 400, 180, this.stage);
            }
        }
    }

    /**
        Return for configuraiton setting.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onConfigReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-noconfig'), 400, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-noconfig'), 400, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-okconfig'), 400, 180, this.stage);
        }
    }

    /**
        Remove the selected movie.
    **/
    private function onRemove(evt:TriggerEvent):Void {
        if (this.ui.selects['remove'].selectedItem != null) {
            Global.ws.send('Movie/ShowtimeRemove', [
                'name' => this.stName, 
                'movie' => this.ui.selects['remove'].selectedItem.value, 
            ], onRemoveReturn);
        }
    }

    /**
        Return for remove movie.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onRemoveReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-removeer'), 400, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-removeer'), 400, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-removeok'), 400, 180, this.stage);
        }
    }

    /**
        Uploading a movie.
    **/
    private function onUpload(evt:TriggerEvent):Void {
        if (this.ui.selects['upload'].selectedItem != null) {
            Global.ws.send('Movie/ShowtimeUpload', [
                'name' => this.stName, 
                'movie' => this.ui.selects['upload'].selectedItem.value, 
            ], onUploadReturn);
        }
    }

    /**
        Return for upload movie.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onUploadReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-uploader'), 400, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-uploader'), 400, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-uploadok'), 400, 180, this.stage);
        }
    }

    /**
        Receiving data for the selected showtime instance.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onInstData(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-nodata'), 400, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-showtime-title'), Global.ln.get('window-showtime-nodata'), 400, 180, this.stage);
            PopUpManager.removePopUp(this);
        } else {
            // accesses
            var last:Array<Dynamic> = [ ];
            var lastlist:Array<String> = cast (ld.map['last']);
            for (i in 0...lastlist.length) {
                last.push({
                    text: lastlist[i], 
                    value: lastlist[i]
                });
            }
            this.ui.setListValues('accesslist', last);
            // movies
            var mv:Array<Dynamic> = [ ];
            var mv2:Array<Dynamic> = [ ];
            mv.push({ text: Global.ln.get('window-showtime-inimovienone'), value: '' });
            var mvlist:Array<String> = cast (ld.map['movies']);
            for (i in 0...mvlist.length) {
                mv.push({
                    text: mvlist[i], 
                    value: mvlist[i]
                });
                mv2.push({
                    text: mvlist[i], 
                    value: mvlist[i]
                });
            }
            this.ui.setSelectOptions('inimovie', mv);
            this.ui.setSelectOptions('remove', mv2);
            // available movies
            var av:Array<Dynamic> = [ ];
            var avlist:Array<Dynamic> = cast (ld.map['available']);
            for (i in 0...avlist.length) {
                av.push({
                    text: avlist[i].title, 
                    value: avlist[i].id, 
                });
            }
            this.ui.setSelectOptions('upload', av);
            // configuration
            this.ui.inputs['apptype'].text = '';
            this.ui.setSelectValue('inimovie', '');
            this.ui.setSelectValue('baud', '9600');
            this.ui.inputs['appid'].text = '';
            this.ui.inputs['serial'].text = '';
            this.ui.inputs['accessk'].text = '';
            this.ui.toggles['mouse'].selected = false;
            this.ui.toggles['startup'].selected = false;
            if (ld.map.exists('type')) {
                switch (ld.map['type']) {
                    case 'desktop':
                        this.ui.inputs['apptype'].text = Global.ln.get('window-showtime-typedesk');
                    case 'androidos':
                        this.ui.inputs['apptype'].text = Global.ln.get('window-showtime-typeandroid');
                    case 'raspberrypi':
                        this.ui.inputs['apptype'].text = Global.ln.get('window-showtime-typerpi');
                }
            }
            if (ld.map.exists('config')) {
                if (Reflect.hasField(ld.map['config'], 'movie')) {
                    this.ui.setSelectValue('inimovie', Reflect.field(ld.map['config'], 'movie'));
                }
                if (Reflect.hasField(ld.map['config'], 'accesskey')) {
                    this.ui.inputs['accessk'].text = Reflect.field(ld.map['config'], 'accesskey');
                }
                if (Reflect.hasField(ld.map['config'], 'identifier')) {
                    this.ui.inputs['appid'].text = Reflect.field(ld.map['config'], 'identifier');
                }
                if (Reflect.hasField(ld.map['config'], 'autoStart')) {
                    this.ui.toggles['startup'].selected = Reflect.field(ld.map['config'], 'autoStart');
                }
                if (Reflect.hasField(ld.map['config'], 'hideCursor')) {
                    this.ui.toggles['mouse'].selected = Reflect.field(ld.map['config'], 'hideCursor');
                }
                if (Reflect.hasField(ld.map['config'], 'serialPort')) {
                    this.ui.inputs['serial'].text = Reflect.field(ld.map['config'], 'serialPort');
                }
                if (Reflect.hasField(ld.map['config'], 'serialBaud')) {
                    this.ui.setSelectValue('baud', Reflect.field(ld.map['config'], 'serialBaud'));
                }
            }
        }
    }

    
}
