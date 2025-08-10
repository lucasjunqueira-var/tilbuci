/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window;

/** OPENFL **/
import com.tilbuci.ui.base.InterfaceFactory;
import com.tilbuci.data.GlobalPlayer;
import openfl.text.TextField;
import feathers.controls.TextArea;
import openfl.Assets;
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
import com.tilbuci.data.BuildInfo;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.Global;
import com.tilbuci.font.EmbedFont;
import com.tilbuci.data.DataLoader;

class WindowSetup extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
        @param  build   Tilbuci build information
    **/
    public function new(ac:Dynamic, build:BuildInfo) {

        // creating window
        super(ac, Global.ln.get('window-setup-title'), 900, InterfaceFactory.pickValue(560, 640), true, true, true);

        // user account (only on multiple user mode)
        if (!Global.singleUser) {
            this.addForm(Global.ln.get('window-setup-user-title'), this.ui.forge('form-user', [
                { tp: 'Label', id: 'user-pass', tx: Global.ln.get('window-setup-user-pass'), vr: '' }, 
                { tp: 'TInput', id: 'user-pass', tx: '', vr: '' }, 
                { tp: 'Button', id: 'user-pass', tx: Global.ln.get('window-setup-user-passchange'), ac: this.onPassChange }, 
                { tp: 'Spacer', id: 'user-pass', ht: 30, ln: true }, 
                { tp: 'Button', id: 'user-logout', tx: Global.ln.get('window-setup-user-logout'), ac: this.onLogout }
            ]));
            // can manage users?
            if (Global.ws.level <= 20) {
                var levelval:Array<Dynamic> = [
                    { text: Global.ln.get('window-setup-users-listauthor'), value: 75 }, 
                    { text: Global.ln.get('window-setup-users-listaeditor'), value: 25 }
                ];
                if (Global.ws.level == 0) levelval.push({ text: Global.ln.get('window-setup-users-listadmin'), value: 0 });

                this.ui.createHContainer('users-setpass');
                this.ui.createTInput('users-setpass', '', '', this.ui.hcontainers['users-setpass'], false);
                this.ui.createButton('users-setpass', Global.ln.get('window-setup-users-setpass'), onSetUserPass, this.ui.hcontainers['users-setpass'], false);
                this.ui.hcontainers['users-setpass'].setWidth(860);

                this.addForm(Global.ln.get('window-setup-users-title'), this.ui.forge('form-users', [
                    { tp: 'Label', id: 'users-list', tx: Global.ln.get('window-setup-users-list'), vr: '' }, 
                    { tp: 'List', id: 'users-list', vl: [ ], ht: 190, sl: '' }, 
                    { tp: 'Button', id: 'users-remove', tx: Global.ln.get('window-setup-users-btremove'), ac: this.onRemoveUser }, 
                    { tp: 'Custom', cont: this.ui.hcontainers['users-setpass'] }, 
                    { tp: 'Spacer', id: 'users-new', ht: 30, ln: true }, 
                    { tp: 'Label', id: 'users-new', tx: Global.ln.get('window-setup-users-new'), vr: '' }, 
                    { tp: 'Label', id: 'users-newemail', tx: Global.ln.get('window-setup-users-newemail'), vr: Label.VARIANT_DETAIL }, 
                    { tp: 'TInput', id: 'users-newemail', tx: '', vr: '' }, 
                    { tp: 'Label', id: 'users-newpass', tx: Global.ln.get('window-setup-users-newpass'), vr: Label.VARIANT_DETAIL }, 
                    { tp: 'TInput', id: 'users-newpass', tx: '', vr: '' }, 
                    { tp: 'Label', id: 'users-newlevel', tx: Global.ln.get('window-setup-users-newlevel'), vr: Label.VARIANT_DETAIL }, 
                    { tp: 'Select', id: 'users-newlevel', vl: levelval, sl: 75 }, 
                    { tp: 'Button', id: 'users-create', tx: Global.ln.get('window-setup-users-newbt'), ac: this.onCreateUser }, 
                    { tp: 'Spacer', id: 'users-end', ht: 10, ln: false }, 
                ]));
                this.ui.setListToIcon('users-list');
            }
        }

        // admin level?
        if (Global.userLevel == 0) {
            // config
            this.addForm(Global.ln.get('window-setup-config-title'), this.ui.forge('form-movie', [
                { tp: 'Label', id: 'movie-index', tx: Global.ln.get('window-setup-config-index'), vr: '' }, 
                { tp: 'Select', id: 'movie-index', vl: [ ], sl: '' }, 
                { tp: 'Button', id: 'movie-index', tx: Global.ln.get('window-setup-config-indexset'), ac: this.onMovieIndex }, 
                { tp: 'Spacer', id: 'render', ht: 5, ln: false }, 
                { tp: 'Label', id: 'render', tx: Global.ln.get('window-setup-config-render'), vr: '' }, 
                { tp: 'Select', id: 'render', vl: [
                    { text: Global.ln.get('window-setup-config-rdopt'), value: 'webgl' }, 
                    { text: Global.ln.get('window-setup-config-rdsite'), value: 'dom' }
                ], sl: GlobalPlayer.render }, 
                { tp: 'Label', id: 'renderabout', tx: Global.ln.get('window-setup-config-rdabout'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Button', id: 'render', tx: Global.ln.get('window-setup-config-rdset'), ac: this.onRenderSet }, 
                { tp: 'Spacer', id: 'share', ht: 5, ln: false }, 
                { tp: 'Label', id: 'share', tx: Global.ln.get('window-setup-config-share'), vr: '' }, 
                { tp: 'Select', id: 'share', vl: [
                    { text: Global.ln.get('window-setup-config-shscene'), value: 'scene' }, 
                    { text: Global.ln.get('window-setup-config-shmovie'), value: 'movie' }, 
                    { text: Global.ln.get('window-setup-config-shnever'), value: 'never' }
                ], sl: GlobalPlayer.share }, 
                { tp: 'Button', id: 'share', tx: Global.ln.get('window-setup-config-rdset'), ac: this.onShareSet }, 
                { tp: 'Spacer', id: 'fps', ht: 5, ln: false }, 
                { tp: 'Label', id: 'fps', tx: Global.ln.get('window-setup-config-fps'), vr: '' }, 
                { tp: 'Select', id: 'fps', vl: [
                    { text: Global.ln.get('window-setup-config-fps60'), value: '60' }, 
                    { text: Global.ln.get('window-setup-config-fps50'), value: '50' }, 
                    { text: Global.ln.get('window-setup-config-fps40'), value: '40' }, 
                    { text: Global.ln.get('window-setup-config-fps30'), value: '30' }, 
                    { text: Global.ln.get('window-setup-config-fps20'), value: '20' }, 
                    { text: Global.ln.get('window-setup-config-fpsfree'), value: 'free' }, 
                    { text: Global.ln.get('window-setup-config-fpscalc'), value: 'calc' }, 
                ], sl: GlobalPlayer.fps }, 
                { tp: 'Button', id: 'fps', tx: Global.ln.get('window-setup-config-fpssave'), ac: this.onFpsSet },
            ]));
            this.ui.labels['renderabout'].wordWrap = true;

            // email
            this.addForm(Global.ln.get('window-setup-email-title'), this.ui.forge('form-email', [
                { tp: 'Label', id: 'email-sender', tx: Global.ln.get('window-setup-email-sender'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'email-sender', tx: '', vr: '' }, 
                { tp: 'Label', id: 'email-email', tx: Global.ln.get('window-setup-email-email'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'email-email', tx: '', vr: '' }, 
                { tp: 'Label', id: 'email-server', tx: Global.ln.get('window-setup-email-server'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'email-server', tx: '', vr: '' }, 
                { tp: 'Label', id: 'email-user', tx: Global.ln.get('window-setup-email-user'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'email-user', tx: '', vr: '' }, 
                { tp: 'Label', id: 'email-password', tx: Global.ln.get('window-setup-email-password'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'email-password', tx: '', vr: '' }, 
                { tp: 'Label', id: 'email-port', tx: Global.ln.get('window-setup-email-port'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'email-port', tx: '', vr: '' }, 
                { tp: 'Label', id: 'email-security', tx: Global.ln.get('window-setup-email-security'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'Select', id: 'email-security', vl: [
                        { text: "SSL", value: "ssl" }, 
                        { text: "TLS", value: "tcp" }, 
                        { text: "None", value: "" }, 
                    ], sl: 'ssl' }, 
                { tp: 'Spacer', id: 'email-button', ht: 10, ln: false }, 
                { tp: 'Button', id: 'email-save', tx: Global.ln.get('window-setup-email-save'), ac: this.onEmailSave }, 
                { tp: 'Spacer', id: 'email-end', ht: 10, ln: false }, 
            ]));
            this.ui.inputs['email-password'].displayAsPassword = true;
            this.ui.createDescription('email-codeabout', Global.ln.get('window-setup-email-codeabout'));
            this.ui.createTInput('email-code');
            this.ui.createButton('email-codebutton', Global.ln.get('window-setup-email-codecheck'), this.checkEmailCode);
            this.ui.createSpacer('email-codespace', 20, true);
            this.ui.createDescription('email-codevalid', Global.ln.get('window-setup-email-codevalid'));

            // fonts
            var fnts:Array<Dynamic> = [ ];
            for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
            this.addForm(Global.ln.get('window-setup-font-title'), this.ui.forge('form-fonts', [
                { tp: 'List', id: 'font-list', vl: fnts, ht: 240, sl: '' }, 
                { tp: 'Button', id: 'font-delete', tx: Global.ln.get('window-setup-font-delete'), ac: this.onFontDelete }, 
                { tp: 'Spacer', id: 'font-spacer', ht: 20, ln: true }, 
                { tp: 'Button', id: 'font-add', tx: Global.ln.get('window-setup-font-add'), ac: this.onFontAdd },
                { tp: 'Label', id: 'font-file', tx: Global.ln.get('window-setup-font-file'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'font-file', tx: '', vr: '' }, 
                { tp: 'Label', id: 'font-name', tx: Global.ln.get('window-setup-font-name'), vr: Label.VARIANT_DETAIL }, 
                { tp: 'TInput', id: 'font-name', tx: '', vr: '' }, 
                { tp: 'Button', id: 'font-upload', tx: Global.ln.get('window-setup-font-upload'), ac: this.onFontUpload }
            ]));
            this.ui.inputs['font-file'].enabled = false;

            // update
            this.addForm(Global.ln.get('window-setup-update-title'), this.ui.forge('form-update', [
                { tp: 'Label', id: 'update-about', tx: Global.ln.get('window-setup-update-about'), vr: '' }, 
                { tp: 'Spacer', id: 'update-about', ht: 20, ln: false }, 
                { tp: 'Button', id: 'update-check', tx: Global.ln.get('window-setup-update-check'), ac: this.onRelase }, 
                { tp: 'Spacer', id: 'update-check', ht: 20, ln: false }, 
                { tp: 'Button', id: 'update-upload', tx: Global.ln.get('window-setup-update-upload'), ac: this.onSelectUpdate }
            ]));
            this.ui.labels['update-about'].wordWrap = true;
        }

        // about form
        var langs:Array<String> = [ ];
        for (n in build.languages) langs.push(n);
        var buci:Bitmap = new Bitmap(Assets.getBitmapData('buci'));
        buci.smoothing = true;
        buci.width = 800;
        buci.scaleY = buci.scaleX;
        this.addForm(Global.ln.get('window-setup-about'), this.ui.forge('form-about', [
            { tp: 'Label', id: 'about-title', tx: Global.ln.get('window-setup-about-title'), vr: Label.VARIANT_HEADING }, 
            { tp: 'Label', id: 'about-lucas', tx: StringTools.replace(Global.ln.get('window-setup-created'), '[NAME]', 'Lucas Junqueira <lucas@var.art.br>'), vr: '' }, 
            { tp: 'Label', id: 'about-version', tx: Global.ln.get('window-setup-about-version'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Label', id: 'about-versionnum', tx: build.version, vr: '' }, 
            { tp: 'Label', id: 'about-build', tx: Global.ln.get('window-setup-about-build'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Label', id: 'about-buildnum', tx: build.build, vr: '' }, 
            { tp: 'Label', id: 'about-languages', tx: Global.ln.get('window-setup-about-languages'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Label', id: 'about-langlist', tx: langs.join(', '), vr: '' }, 
            { tp: 'Label', id: 'about-thanks', tx: Global.ln.get('window-setup-about-thanks'), vr: Label.VARIANT_DETAIL }, 
            { tp: 'Label', id: 'about-thankslist', tx: build.thanks.join(', '), vr: '' }, 
            { tp: 'Spacer', id: 'about-tilbuci', ht: 30, ln: true }, 
            { tp: 'Label', id: 'about-tilbuci', tx: Global.ln.get('window-setup-tilbuci'), vr: '' }, 
            { tp: 'Custom', cont: buci }
        ]));
        this.ui.labels['about-lucas'].wordWrap = true;

        // license
        var license:TextField = new TextField();
        license.wordWrap = true;
        license.condenseWhite = true;
        license.width = 860;
        license.autoSize = TextFieldAutoSize.LEFT;
        license.htmlText = Assets.getText('license');
        this.addForm(Global.ln.get('window-setup-license'), this.ui.forge('license', [
            { tp: 'Custom', cont: license }, 
            { tp: 'Spacer', id: 'license', ht: 10, ln: false }, 
        ]));

        // adjusting sizes
        this.redraw();
    }

    /**
        Window action to run on display.
    **/
    override public function acStart():Void {
        if (Global.userLevel == 0) {
            Global.ws.send('Email/GetConfig', [ ], onEmailSettings);
            Global.ws.send('Movie/SetList', [ ], onMovieList);
        }
        if (!Global.singleUser && (Global.ws.level <= 50)) Global.ws.send('User/List', [ ], onUserList);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /** PRVATE METHODS **/

    /**
        Deleting the selected font.
    **/
    private function onFontDelete(evt:TriggerEvent):Void {
        if (this.ui.lists['font-list'].selectedIndex < 0) {
            this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-noneslected'), 300, 180, this.stage);
        } else {
            this.ui.createConfirm(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-removecheck'), 400, 210, this.removeFont, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
        }
    }

    /**
        Removes the selected font.
    **/
    private function removeFont(ok:Bool):Void {
        if (ok) {
            Global.ws.send('File/RemoveFont', [ 'name' => this.ui.lists['font-list'].selectedItem.value ], onFontRemoved);
        }
    }

    /**
        A font was just removed.
    **/
    private function onFontRemoved(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            Global.fonts.remove(ld.map['name']);
            var fnts:Array<Dynamic> = [ ];
            for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
            this.ui.setListValues('font-list', fnts);
        }
    }

    /**
        Selecting an update file.
    **/
    private function onSelectUpdate(evt:TriggerEvent):Void {
        Global.up.browseForMedia(onUpdateFile, 'update');
    }

    /**
        Selecting a font file.
    **/
    private function onFontAdd(evt:TriggerEvent):Void {
        Global.up.browseForFont(this.onFontSelected);
    }

    /**
        A new font file was selected.
        @param  ok  file correctly selected?
    **/
    private function onFontSelected(ok:Bool):Void {
        if (ok) {
            this.ui.inputs['font-file'].text = Global.up.selectedName;
            if (this.ui.inputs['font-name'].text == '') {
                var fname:String = StringTools.replace(Global.up.selectedName, '.woff2', '');
                fname = StringTools.replace(fname, '.woff', '');
                fname = StringTools.replace(fname, '-', ' ');
                fname = StringTools.replace(fname, '_', ' ');
                this.ui.inputs['font-name'].text = fname;
            }
        } else {
            this.ui.inputs['font-file'].text = this.ui.inputs['font-name'].text = '';
        }
    }

    /**
        The update file was uploaded.
        @param  ok  file correctly selected?
    **/
    private function onUpdateFile(ok:Bool):Void {
        if (ok) {
            if ((Global.up.selectedName.substr(0, 7) != 'TilBuci') || (Global.up.selectedName.substr(-3) != 'zip')) {
                this.ui.createWarning(Global.ln.get('window-setup-update-title'), Global.ln.get('window-setup-update-invalid'), 300, 150, this.stage);
            } else {
                Global.up.uploadMedia(onUpdateReturn, [
                    'type' => 'update', 
                    'path' => '', 
                    'movie' => ''
                ]);
            }
        }
    }

    /**
        Update upload return.
    **/
    private function onUpdateReturn(ok:Bool, data:Map<String, Dynamic> = null):Void {
        if (ok) {
            Global.ws.send('System/Update', [ ], onZipReturn);
        } else {
            this.ui.createWarning(Global.ln.get('window-setup-update-title'), Global.ln.get('window-setup-update-uploader'), 300, 180, this.stage);
        }
    }

    /**
       Zip import return.
    **/
    private function onZipReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-update-title'), Global.ln.get('window-setup-update-uploader'), 300, 180, this.stage);
        } else if (ld.map['e'] == 0) {
            var req:URLRequest = new URLRequest(Global.econfig.player + 'setup.php');
            req.method = 'GET';
            Lib.getURL(req);
            this.ui.createWarning(Global.ln.get('window-setup-update-title'), Global.ln.get('window-setup-update-uploadok'), 300, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-setup-update-title'), Global.ln.get('window-setup-update-uploader'), 300, 180, this.stage);
        }
    }

    /**
        Uploading the selected font
    **/
    private function onFontUpload(evt:TriggerEvent):Void {
        if ((this.ui.inputs['font-file'].text == '') || (this.ui.inputs['font-name'].text == '')) {
            this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-nofilename'), 300, 180, this.stage);
        } else {
            if (!Global.up.uploadFont(this.fontReturn, [ 'name' => this.ui.inputs['font-name'].text ])) {
                this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-nofont'), 300, 180, this.stage);
            }
        }
    }

    /**
        Font file upload finished.
    **/
    private function fontReturn(ok:Bool, data:Map<String, Dynamic> = null):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-uploader'), 300, 180, this.stage);
        } else if (data['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-uploader'), 300, 180, this.stage);
        } else {
            new EmbedFont((Global.econfig.font + data['fname']), data['name'], this.fontLoaded);
            this.ui.createWarning(Global.ln.get('window-setup-font-title'), Global.ln.get('window-setup-font-uploadok'), 300, 200, this.stage);
        }
    }

    /**
        Font file load finish.
        @param  ok  correctly loaded?
        @param  ft  embed font reference
    **/
    private function fontLoaded(ok:Bool, ft:EmbedFont):Void {
        if (ok) {
            var fnts:Array<Dynamic> = [ ];
            for (n in 0...Global.fonts.length) fnts.push({ text: Global.fonts[n], value: Global.fonts[n] });
            this.ui.setListValues('font-list', fnts);
        }
    }

    /**
        Receiving e-mail settings.
        @param  ok  settings loaded?
        @param  ld  loader information
    **/
    private function onEmailSettings(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                this.ui.inputs['email-server'].text = ld.map['server'];
                this.ui.inputs['email-sender'].text = ld.map['sender'];
                this.ui.inputs['email-email'].text = ld.map['email'];
                this.ui.inputs['email-user'].text = ld.map['user'];
                this.ui.inputs['email-password'].text = ld.map['password'];
                this.ui.inputs['email-port'].text = ld.map['port'];
                this.ui.setSelectValue('email-security', ld.map['security']);
                if (ld.map['attempt']) {
                    this.addEmailCodeConfirm();
                } else if (ld.map['valid']) {
                    Global.validEmail = true;
                    this.addEmailCodeValid();
                }
            }
        }
    }

    /**
        Asks for password change.
    **/
    private function onPassChange(evt:TriggerEvent):Void {
        if (this.ui.inputs['user-pass'].text.length < 8) {
            this.ui.createWarning(Global.ln.get('window-setup-user-title'), Global.ln.get('window-setup-user-passminimum'), 300, 180, this.stage);
        } else {
            Global.ws.send('User/SetPassword', [
                'user' => Global.ws.user, 
                'pass' => this.ui.inputs['user-pass'].text
            ], onPasswordSet);
        }
    }

    /**
        Update password return.
    **/
    private function onPasswordSet(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-user-title'), Global.ln.get('window-setup-user-passerror'), 300, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-setup-user-title'), Global.ln.get('window-setup-user-passerror'), 300, 180, this.stage);
        } else {
            this.ui.inputs['user-pass'].text = '';
            this.ui.createWarning(Global.ln.get('window-setup-user-title'), Global.ln.get('window-setup-user-passok'), 300, 180, this.stage);
        }
    }

    /**
        Logs out.
    **/
    private function onLogout(evt:TriggerEvent):Void {
        Global.ws.logout();
        PopUpManager.removePopUp(this);
        Global.showWindow('login');
    }

    /**
        Click on save email settings.
    **/
    private function onEmailSave(evt:TriggerEvent):Void {
        if ((this.ui.inputs['email-sender'].text == '') || (this.ui.inputs['email-email'].text == '') || (this.ui.inputs['email-server'].text == '') || (this.ui.inputs['email-user'].text == '') || (this.ui.inputs['email-password'].text == '') || (this.ui.inputs['email-port'].text == '')) {
            this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-savenofields'), 300, 180, this.stage);
        } else if (!StringStatic.validateEmail(this.ui.inputs['email-email'].text)) {
            this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-savenoemail'), 300, 180, this.stage);
        } else {
            this.ui.createConfirm(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-saveabout'), 420, 280, this.onEmailSaveConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
        }
    }

    /**
        Confirming the email settings save.
    **/
    private function onEmailSaveConfirm(ok:Bool):Void {
        if (ok) {
            this.ui.disableButton('email-save', Global.ln.get('default-wait'));
            Global.ws.send('Email/Save', [
                'sender' => this.ui.inputs['email-sender'].text, 
                'email' => this.ui.inputs['email-email'].text, 
                'server' => this.ui.inputs['email-server'].text, 
                'user' => this.ui.inputs['email-user'].text, 
                'password' => this.ui.inputs['email-password'].text, 
                'port' => this.ui.inputs['email-port'].text, 
                'security' => this.ui.selects['email-security'].selectedItem.value, 
                'lang' => Global.ln.current, 
            ], onEmailSaveReturn);
        }
    }

    /**
        Response from save e-mail settings.
        @param  ok  ws correctly connected?
        @param  data    response received
    **/
    private function onEmailSaveReturn(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-saveok'), 400, 190, this.stage);
                this.addEmailCodeConfirm();
            } else {
                this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-saveerror'), 400, 190, this.stage);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-saveerror'), 400, 190, this.stage);
        }
        this.ui.enableButton('email-save', Global.ln.get('window-setup-email-save'));
    }

    /**
        Adds the code confirmation fields to the e-mail settings form.
    **/
    private function addEmailCodeConfirm():Void {
        this.ui.containers['form-email'].replaceChildren([
            this.ui.labels['email-codeabout'], 
            this.ui.inputs['email-code'], 
            this.ui.buttons['email-codebutton'], 
            this.ui.spacers['email-codespace'], 
            this.ui.labels['email-sender'], 
            this.ui.inputs['email-sender'], 
            this.ui.labels['email-email'], 
            this.ui.inputs['email-email'], 
            this.ui.labels['email-server'], 
            this.ui.inputs['email-server'], 
            this.ui.labels['email-user'], 
            this.ui.inputs['email-user'], 
            this.ui.labels['email-password'], 
            this.ui.inputs['email-password'], 
            this.ui.labels['email-port'], 
            this.ui.inputs['email-port'], 
            this.ui.labels['email-security'], 
            this.ui.selects['email-security'], 
            this.ui.spacers['email-button'], 
            this.ui.buttons['email-save']
        ]);
        this.redraw();
    }

    /**
        Adds the code valid fields to the e-mail settings form.
    **/
    private function addEmailCodeValid():Void {
        this.ui.containers['form-email'].replaceChildren([
            this.ui.labels['email-codevalid'], 
            this.ui.spacers['email-codespace'], 
            this.ui.labels['email-sender'], 
            this.ui.inputs['email-sender'], 
            this.ui.labels['email-email'], 
            this.ui.inputs['email-email'], 
            this.ui.labels['email-server'], 
            this.ui.inputs['email-server'], 
            this.ui.labels['email-user'], 
            this.ui.inputs['email-user'], 
            this.ui.labels['email-password'], 
            this.ui.inputs['email-password'], 
            this.ui.labels['email-port'], 
            this.ui.inputs['email-port'], 
            this.ui.labels['email-security'], 
            this.ui.selects['email-security'], 
            this.ui.spacers['email-button'], 
            this.ui.buttons['email-save']
        ]);
        this.redraw();
    }

    /**
        Checks the provided e-mail confirmation code.
    **/
    private function checkEmailCode(evt:TriggerEvent):Void {
        if (this.ui.inputs['email-code'].text.length != 6) {
            this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-codeno6'), 400, 150, this.stage);
        } else {
            this.ui.buttons['email-codebutton'].text = Global.ln.get('default-wait');
            Global.ws.send('Email/CheckCode', [ 'code' => this.ui.inputs['email-code'].text ], this.onEmailCodeCheck);
        }
    }

    /**
        Checks the return for e-mail validation code.
    **/
    private function onEmailCodeCheck(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('default-serverconerror'), 400, 180, this.stage);
        } else {
            if (ld.map['e'] == 1) {
                this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-codenoset'), 400, 150, this.stage);
            } else if (ld.map['e'] == 2) {
                this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-codecorrupt'), 400, 190, this.stage);
            } else if (ld.map['e'] == 3) {
                this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-codewrong'), 400, 190, this.stage);
            } else {
                this.ui.createWarning(Global.ln.get('window-setup-email-title'), Global.ln.get('window-setup-email-codeok'), 400, 150, this.stage);
                this.ui.containers['form-email'].replaceChildren([
                    this.ui.labels['email-codevalid'], 
                    this.ui.spacers['email-codespace'], 
                    this.ui.labels['email-sender'], 
                    this.ui.inputs['email-sender'], 
                    this.ui.labels['email-email'], 
                    this.ui.inputs['email-email'], 
                    this.ui.labels['email-server'], 
                    this.ui.inputs['email-server'], 
                    this.ui.labels['email-user'], 
                    this.ui.inputs['email-user'], 
                    this.ui.labels['email-password'], 
                    this.ui.inputs['email-password'], 
                    this.ui.labels['email-port'], 
                    this.ui.inputs['email-port'], 
                    this.ui.labels['email-security'], 
                    this.ui.selects['email-security'], 
                    this.ui.spacers['email-button'], 
                    this.ui.buttons['email-save']
                ]);
                this.redraw();
                Global.validEmail = true;
            }
        }
        this.ui.buttons['email-codebutton'].text = Global.ln.get('window-setup-email-codecheck');
    }

    /**
        Receiving users list.
        @param  ok  list loaded?
        @param  ld  loader information
    **/
    private function onUserList(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        if (!ok) {
            // nothing to do
        } else if (ld.map['e'] != 0) {
            // nothing to fo
        } else {
            // get available users
            var userlist:Array<UserList> = cast (ld.map['list']);
            for (i in 0...userlist.length) {
                var lvl:String = '';
                if (userlist[i].level == 0) lvl = Global.ln.get('window-setup-users-listadmin');
                else if (userlist[i].level <= 50) lvl = Global.ln.get('window-setup-users-listaeditor');
                else lvl = Global.ln.get('window-setup-users-listauthor');
                list.push({
                    text: userlist[i].user, 
                    value: userlist[i].user, 
                    user: lvl
                });
            }
        }
        this.ui.setListValues('users-list', list);
    }

    /**
        Click on create user button
    **/
    private function onCreateUser(evt:TriggerEvent):Void {
        if ((this.ui.inputs['users-newemail'].text == '') || (this.ui.inputs['users-newpass'].text.length < 8)) {
            this.ui.createWarning(Global.ln.get('window-setup-users-new'), Global.ln.get('window-setup-users-newno'), 400, 250, this.stage);
        } else if (!StringStatic.validateEmail(this.ui.inputs['users-newemail'].text)) {
            this.ui.createWarning(Global.ln.get('window-setup-users-new'), Global.ln.get('window-setup-users-newno'), 400, 250, this.stage);
        } else {
            // call user creation
            Global.ws.send('User/Create', [
                'email' => this.ui.inputs['users-newemail'].text, 
                'pass' => this.ui.inputs['users-newpass'].text, 
                'level' => this.ui.selects['users-newlevel'].selectedItem.value
            ], onCreateReturn);
        }
    }

    /**
        User creation return.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onCreateReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-users-new'), Global.ln.get('window-setup-users-newerror'), 400, 150, this.stage);
        } else if (ld.map['e'] == 1) {
            this.ui.createWarning(Global.ln.get('window-setup-users-new'), Global.ln.get('window-setup-users-newalready'), 400, 200, this.stage);
        } else if (ld.map['e'] == 0) {
            this.ui.setListValues('users-list', [ ]);
            this.ui.inputs['users-newemail'].text = '';
            this.ui.inputs['users-newpass'].text = '';
            Global.ws.send('User/List', [ ], onUserList);
            Global.showMsg(Global.ln.get('window-setup-users-newok'));
        } else {
            this.ui.createWarning(Global.ln.get('window-setup-users-new'), Global.ln.get('window-setup-users-newerror'), 400, 150, this.stage);
        }
    }

    /**
        Click on remove user button
    **/
    private function onRemoveUser(evt:TriggerEvent):Void {
        if (this.ui.lists['users-list'].selectedItem != null) {
            this.ui.createConfirm(Global.ln.get('window-setup-users-title'), Global.ln.get('window-setup-users-btremsure'), 400, 230, onRemoveConfirm, Global.ln.get('default-ok'), Global.ln.get('default-cancel'), this.stage);
        }
    }

    /**
        Remove user confirmation.
    **/
    private function onRemoveConfirm(ok:Bool):Void {
        if (ok && (this.ui.lists['users-list'].selectedItem != null)) {
            Global.ws.send('User/Remove', [
                'email' => this.ui.lists['users-list'].selectedItem.value
            ], onUserRemoved);
        }
    }

    /**
        User removal return.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onUserRemoved(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-users-title'), Global.ln.get('window-setup-users-btremer'), 400, 150, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-setup-users-title'), Global.ln.get('window-setup-users-btremer'), 400, 150, this.stage);
        } else {
            Global.ws.send('User/List', [ ], onUserList);
            Global.showMsg(Global.ln.get('window-setup-users-btremok'));
        }
    }

    /**
        Click on set user password button
    **/
    private function onSetUserPass(evt:TriggerEvent):Void {
        if (this.ui.lists['users-list'].selectedItem != null) {
            if (this.ui.inputs['users-setpass'].text.length < 8) {
                this.ui.createWarning(Global.ln.get('window-setup-users-title'), Global.ln.get('window-setup-users-setpassno'), 400, 150, this.stage);
            } else {
                Global.ws.send('User/SetUserPassword', [
                    'email' => this.ui.lists['users-list'].selectedItem.value, 
                    'pass' => this.ui.inputs['users-setpass'].text
                ], onSetUserPassReturn);
            }
        }
    }

    /**
        User set password return.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onSetUserPassReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-users-title'), Global.ln.get('window-setup-users-setpasser'), 400, 150, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-setup-users-title'), Global.ln.get('window-setup-users-setpasser'), 400, 150, this.stage);
        } else {
            this.ui.inputs['users-setpass'].text = '';
            this.ui.createWarning(Global.ln.get('window-setup-users-title'), Global.ln.get('window-setup-users-setpassok'), 400, 150, this.stage);
        }
    }

    /**
        Click on set movie index button.
    **/
    private function onMovieIndex(evt:TriggerEvent):Void {
        if (this.ui.selects['movie-index'].selectedItem != null) {
            Global.ws.send('Movie/SetIndex', [
                'movie' => this.ui.selects['movie-index'].selectedItem.value
            ], onMovieIndexReturn);
        }
    }

    /**
        Click on render mode button.
    **/
    private function onRenderSet(evt:TriggerEvent):Void {
        if (this.ui.selects['render'].selectedItem != null) {
            Global.ws.send('Movie/SetRender', [
                'rd' => this.ui.selects['render'].selectedItem.value
            ], onRenderReturn);
        }
    }

    /**
        Click on share mode button.
    **/
    private function onShareSet(evt:TriggerEvent):Void {
        if (this.ui.selects['share'].selectedItem != null) {
            Global.ws.send('Movie/SetShare', [
                'sh' => this.ui.selects['share'].selectedItem.value
            ], onShareReturn);
        }
    }

    /**
        Click on fps mode button.
    **/
    private function onFpsSet(evt:TriggerEvent):Void {
        if (this.ui.selects['fps'].selectedItem != null) {
            Global.ws.send('Movie/SetFPS', [
                'fps' => this.ui.selects['fps'].selectedItem.value
            ], onFpsReturn);
        }
    }

    /**
        Movie index set return.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onMovieIndexReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-indexer'), 400, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-indexer'), 400, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-indexok'), 400, 180, this.stage);
        }
    }

    /**
        Render set return.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onRenderReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-rder'), 400, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-rder'), 400, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-rdok'), 400, 180, this.stage);
            GlobalPlayer.render = this.ui.selects['render'].selectedItem.value;
        }
    }

    /**
        Share set return.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onShareReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-sher'), 400, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-sher'), 400, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-shok'), 400, 180, this.stage);
            GlobalPlayer.share = this.ui.selects['share'].selectedItem.value;
        }
    }

    /**
        FPS set return.
        @param  ok  response received?
        @param  ld  loader information
    **/
    private function onFpsReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-fpser'), 400, 180, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-fpser'), 400, 180, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-setup-config-index'), Global.ln.get('window-setup-config-fpsok'), 400, 180, this.stage);
            GlobalPlayer.fps = this.ui.selects['fps'].selectedItem.value;
        }
    }

    /**
        Receiving users list.
        @param  ok  list loaded?
        @param  ld  loader information
    **/
    private function onMovieList(ok:Bool, ld:DataLoader):Void {
        var list:Array<Dynamic> = [ ];
        var current:String = '';
        if (!ok) {
            // nothing to do
        } else if (ld.map['e'] != 0) {
            // nothing to fo
        } else {
            // get available movies
            var movielist:Array<MovieList> = cast (ld.map['list']);
            for (i in 0...movielist.length) {
                list.push({
                    text: movielist[i].name, 
                    value: movielist[i].id
                });
            }
            // get current
            current = ld.map['current'];
        }
        this.ui.setSelectOptions('movie-index', list);
        this.ui.setSelectValue('movie-index', current);
    }

    /**
        Open TilBuci latest release page.
    **/
    private function onRelase(evt:TriggerEvent):Void {
        var req:URLRequest = new URLRequest('https://tilbuci.com.br/site/latest-version/');
        req.method = 'GET';
        Lib.getURL(req);
    }
    
}

/**
    returned user list item
**/
typedef UserList = {
    var user:String;
    var level:Int;
}

/**
    returned movie list item
**/
typedef MovieList = {
    var name:String;
    var id:String;
}