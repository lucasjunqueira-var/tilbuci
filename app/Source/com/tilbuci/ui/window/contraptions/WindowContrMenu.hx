package com.tilbuci.ui.window.contraptions;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.contraptions.MenuContraption;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.display.Stage;

/** FEATHERS UI **/
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.data.Global;
import com.tilbuci.data.GlobalPlayer;

class WindowContrMenu extends PopupWindow {

    // current layouts
    private var _list:Map<String, MenuContraption> = [ ];

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        // creating window
        super(ac, Global.ln.get('window-contrmenu-title'), 1000, 640, false, true, true);
    }

    /**
        Drawing the interface.
    **/
    override public function startInterface(evt:Event = null):Void {
        // picture inputs
        this.ui.createHContainer('imgbg');
        this.ui.createTInput('imgbg', '', '', this.ui.hcontainers['imgbg'], false);
        this.ui.createIconButton('imgbg', this.acImgbg, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgbg'], false);
        this.ui.createIconButton('imgbgdel', this.acImgbgdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgbg'], false);
        this.ui.inputs['imgbg'].enabled = false;
        this.ui.hcontainers['imgbg'].setWidth(460, [350, 50, 50]);
        this.ui.createHContainer('imgbt');
        this.ui.createTInput('imgbt', '', '', this.ui.hcontainers['imgbt'], false);
        this.ui.createIconButton('imgbt', this.acImgbt, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgbt'], false);
        this.ui.createIconButton('imgimgbtdel', this.acImgbtdel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgbt'], false);
        this.ui.inputs['imgbt'].enabled = false;
        this.ui.hcontainers['imgbt'].setWidth(460, [350, 50, 50]);
        this.ui.createHContainer('imgsl');
        this.ui.createTInput('imgsl', '', '', this.ui.hcontainers['imgsl'], false);
        this.ui.createIconButton('imgsl', this.acImgsl, new Bitmap(Assets.getBitmapData('btOpenfile')), this.ui.hcontainers['imgsl'], false);
        this.ui.createIconButton('imgsldel', this.acImgsldel, new Bitmap(Assets.getBitmapData('btDel')), this.ui.hcontainers['imgsl'], false);
        this.ui.inputs['imgsl'].enabled = false;
        this.ui.hcontainers['imgsl'].setWidth(460, [350, 50, 50]);

        // creating columns
        this.addForm(Global.ln.get('window-kfmanage-title'), this.ui.createColumnHolder('columns', 
            this.ui.forge('leftcol', [
                { tp: 'Label', id: 'registered', tx: Global.ln.get('window-contrmenu-registered'), vr: '' }, 
                { tp: 'List', id: 'registered', vl: [ ], sl: null, ht: 445 }, 
                { tp: 'Button', id: 'load', tx: Global.ln.get('window-contrmenu-load'), ac: loadMenu }, 
                { tp: 'Button', id: 'remove', tx: Global.ln.get('window-contrmenu-remove'), ac: removeMenu },
            ]), 
            this.ui.forge('rightcol', [
                { tp: 'Label', id: 'properties', tx: Global.ln.get('window-contrmenu-properties'), vr: '' }, 
                { tp: 'Label', id: 'name', tx: Global.ln.get('window-contrmenu-name'), vr: 'detail' }, 
                { tp: 'TInput', id: 'name', tx: '', vr: '' },  
                /*{ tp: 'Label', id: 'mode', tx: Global.ln.get('window-contrmenu-mode'), vr: 'detail' }, 
                { tp: 'Select', id: 'mode', vl: [
                    { text: Global.ln.get('window-contrmenu-modev'), value: 'v' }, 
                    { text: Global.ln.get('window-contrmenu-modeh'), value: 'h' }, 
                ], sl: null }, */
                { tp: 'Label', id: 'font', tx: Global.ln.get('window-contrmenu-font'), vr: 'detail' }, 
                { tp: 'Select', id: 'font', vl: [ ], sl: null }, 
                { tp: 'Label', id: 'fontsize', tx: Global.ln.get('window-contrmenu-fontsize'), vr: 'detail' },
                { tp: 'Numeric', id: 'fontsize', mn: 8, mx: 200, st: 1, vl: 0 }, 
                { tp: 'Label', id: 'fontc', tx: Global.ln.get('window-contrmenu-fontc'), vr: 'detail' }, 
                { tp: 'TInput', id: 'fontc', tx: '', vr: '' },  
                { tp: 'Label', id: 'cover', tx: Global.ln.get('window-contrmenu-cover'), vr: 'detail' }, 
                { tp: 'TInput', id: 'cover', tx: '', vr: '' },  
                { tp: 'Label', id: 'coveralpha', tx: Global.ln.get('window-contrmenu-coveralpha'), vr: 'detail' },
                { tp: 'Numeric', id: 'coveralpha', mn: 0, mx: 100, st: 1, vl: 0 }, 
                { tp: 'Label', id: 'imgbg', tx: Global.ln.get('window-contrmenu-imgbg'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['imgbg'] }, 
                { tp: 'Label', id: 'imgbt', tx: Global.ln.get('window-contrmenu-imgbt'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['imgbt'] }, 
                { tp: 'Label', id: 'imgsl', tx: Global.ln.get('window-contrmenu-imgsl'), vr: 'detail' },
                { tp: 'Custom', cont: this.ui.hcontainers['imgsl'] }, 
                { tp: 'Spacer', id: 'add', ht: 8, ln: false }, 
                { tp: 'Button', id: 'add', tx: Global.ln.get('window-contrmenu-add'), ac: addMenu },
            ]),
            this.ui.forge('bottom', [
                { tp: 'Button', id: 'save', tx: Global.ln.get('window-contrmenu-save'), ac: saveMenu },
            ])
            , 550));
            this.ui.listDbClick('registered', this.loadMenu);
            super.startInterface();
    }

    /**
        Load current information.
    **/
    override public function acStart():Void {
        for (mnk in this._list.keys()) {
            this._list[mnk].kill();
            this._list.remove(mnk);
        }
        for (mn in GlobalPlayer.contraptions.menus) {
            this._list[mn.id] = mn.clone();
        }
        this.clear();
    }

    /**
        Clears current layout data.
    **/
    private function clear():Void {
        this.ui.inputs['fontc'].text = '#FFFFFF';
        this.ui.inputs['cover'].text = '#000000';
        var list:Array<Dynamic> = [ ];
        for (mn in this._list) {
            list.push({text: mn.id, value: mn.id});
        }
        this.ui.setListValues('registered', list);
        this.ui.setListSelectValue('registered', null);
        this.ui.inputs['name'].text = '';
        var fnts:Array<Dynamic> = [ ];
        for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
        for (i in GlobalPlayer.mdata.fonts) fnts.push({ text: i.name, value: i.name });
        this.ui.setSelectOptions('font', fnts);
        this.ui.setSelectValue('font', null);
        //this.ui.setSelectValue('mode', 'v');
        this.ui.numerics['coveralpha'].value = 0;
        this.ui.numerics['fontsize'].value = 20;
        this.ui.inputs['imgbg'].text = '';
        this.ui.inputs['imgbt'].text = '';
        this.ui.inputs['imgsl'].text = '';
    }

    private function loadMenu(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.value)) {
                this.ui.inputs['name'].text = this._list[this.ui.lists['registered'].selectedItem.value].id;
                this.ui.inputs['fontc'].text = this._list[this.ui.lists['registered'].selectedItem.value].fontcolor;
                this.ui.inputs['cover'].text = this._list[this.ui.lists['registered'].selectedItem.value].bgcolor;
                this.ui.setSelectValue('font', this._list[this.ui.lists['registered'].selectedItem.value].font);
                //this.ui.setSelectValue('mode', this._list[this.ui.lists['registered'].selectedItem.value].mode);
                this.ui.numerics['coveralpha'].value = Math.round(this._list[this.ui.lists['registered'].selectedItem.value].bgalpha * 100);
                this.ui.numerics['fontsize'].value = Math.round(this._list[this.ui.lists['registered'].selectedItem.value].fontsize);
                this.ui.inputs['imgbg'].text = this._list[this.ui.lists['registered'].selectedItem.value].background;
                this.ui.inputs['imgbt'].text = this._list[this.ui.lists['registered'].selectedItem.value].buton;
                this.ui.inputs['imgsl'].text = this._list[this.ui.lists['registered'].selectedItem.value].selected;
            }
        }
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'menubrowseimgbg':
                this.ui.inputs['imgbg'].text = data['file'];
            case 'menubrowseimgbt':
                this.ui.inputs['imgbt'].text = data['file'];
            case 'menubrowseimgsl':
                this.ui.inputs['imgsl'].text = data['file'];
        }
    }

    private function removeMenu(evt:Event):Void {
        if (this.ui.lists['registered'].selectedItem != null) {
            if (this._list.exists(this.ui.lists['registered'].selectedItem.value)) {
                this._list[this.ui.lists['registered'].selectedItem.value].kill();
                this._list.remove(this.ui.lists['registered'].selectedItem.value);
                this.clear();
            }
        }
    }

    private function saveMenu(evt:Event):Void {
        for (mn in GlobalPlayer.contraptions.menus.keys()) {
            GlobalPlayer.contraptions.menus[mn].kill();
            GlobalPlayer.contraptions.menus.remove(mn);
        }
        for (mn in this._list.keys()) {
            GlobalPlayer.contraptions.menus[mn] = this._list[mn].clone();
        }
        this.clear();
        Global.ws.send('Movie/SaveContraptions', [
            'movie' => GlobalPlayer.movie.mvId, 
            'data' => GlobalPlayer.contraptions.getData()
        ], this.onSaveReturn);
    }

    private function addMenu(evt:Event):Void {
        if (this.ui.inputs['name'].text.length > 3) {
            if ((this.ui.inputs['imgbg'].text == '') || (this.ui.inputs['imgbt'].text == '')) {
                Global.showPopup(Global.ln.get('window-contrmenu-title'), Global.ln.get('window-contrmenu-nographics'), 320, 150, Global.ln.get('default-ok'));
            } else {
                var mn:MenuContraption;
                if (this._list.exists(this.ui.inputs['name'].text)) {
                    mn = this._list[this.ui.inputs['name'].text];
                } else {
                    mn = new MenuContraption();
                }
                mn.load({
                    id: this.ui.inputs['name'].text, 
                    mode: 'v', //this.ui.selects['mode'].selectedItem.value, 
                    font: this.ui.selects['font'].selectedItem.value, 
                    fontcolor: StringStatic.colorHex(this.ui.inputs['fontc'].text, '#FFFFFF'), 
                    fontsize: this.ui.numerics['fontsize'].value, 
                    background: this.ui.inputs['imgbg'].text, 
                    buton: this.ui.inputs['imgbt'].text, 
                    selected: this.ui.inputs['imgsl'].text, 
                    bgcolor: StringStatic.colorHex(this.ui.inputs['cover'].text, '#000000'), 
                    bgalpha: (this.ui.numerics['coveralpha'].value / 100), 
                });
                if (mn.bgalpha < 0) mn.bgalpha = 0;
                if (mn.bgalpha > 1) mn.bgalpha = 1;
                this._list[this.ui.inputs['name'].text] = mn;
                this.clear();
            }            
        } else {
            Global.showPopup(Global.ln.get('window-contrmenu-title'), Global.ln.get('window-contrmenu-noname'), 320, 150, Global.ln.get('default-ok'));
        }
    }

    private function acImgbg(evt:Event):Void {
        this._ac('menubrowseimgbg');
    }

    private function acImgbgdel(evt:Event):Void {
        this.ui.inputs['imgbg'].text = '';
    }

    private function acImgbt(evt:Event):Void {
        this._ac('menubrowseimgbt');
    }

    private function acImgbtdel(evt:Event):Void {
        this.ui.inputs['imgbt'].text = '';
    }

    private function acImgsl(evt:Event):Void {
        this._ac('menubrowseimgsl');
    }

    private function acImgsldel(evt:Event):Void {
        this.ui.inputs['imgsl'].text = '';
    }

    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (ok) {
            if (ld.map['e'] == 1) {
                Global.showPopup(Global.ln.get('window-contrmenu-title'), Global.ln.get('window-contrmenu-ersave1'), 320, 150, Global.ln.get('default-ok'));
            } else if (ld.map['e'] == 2) {
                Global.showPopup(Global.ln.get('window-contrmenu-title'), Global.ln.get('window-contrmenu-ersave'), 320, 150, Global.ln.get('default-ok'));
            } else {
                Global.showMsg(Global.ln.get('window-contrmenu-oksave'));
                PopUpManager.removePopUp(this);
            }
        } else {
            Global.showPopup(Global.ln.get('window-contrmenu-title'), Global.ln.get('window-contrmenu-ersave'), 320, 150, Global.ln.get('default-ok'));
        }
    }

}