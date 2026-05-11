/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window;

/** FEATHERS UI **/
import openfl.display.Bitmap;
import com.tilbuci.data.DataLoader;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import openfl.Lib;
import openfl.net.URLRequest;

/** TILBUCI **/
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.Global;
import com.tilbuci.statictools.Assets;

class WindowLogin extends PopupWindow {

    /**
        enter button
    **/
    private var _btEnter:Button;


    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {

        // creating window
        if (!Global.validEmail) {
            super(ac, Global.ln.get('window-login-title'), 500, 560, false, false);
        } else {
            super(ac, Global.ln.get('window-login-title'), 500, 530, false, false);
        }

        // welcome graphic
        var buci:Bitmap = new Bitmap(Assets.getBitmapData('welcome'));
        buci.smoothing = true;
        buci.width = 460;
        buci.scaleY = buci.scaleX;

        // welcome buttons
        this.ui.createHContainer('welcome');
        this.ui.createButton('welcomesite', Global.ln.get('window-login-site'), onSite, this.ui.hcontainers['welcome'], false);
        this.ui.createButton('welcomediscord', Global.ln.get('window-login-discord'), onDiscord, this.ui.hcontainers['welcome'], false);
        this.ui.hcontainers['welcome'].setWidth(460, [ 220, 220 ]);

        // creating interface
        this.ui.createContainer('form');
        this.ui.lastCont.addChild(buci);
        this.ui.createLabel('about', Global.ln.get('window-login-about'), '', this.ui.lastCont);
        this.ui.labels['about'].wordWrap = true;
        this.ui.lastCont.addChild(this.ui.hcontainers['welcome']);
        this.ui.createSpacer('line-about', 20, true, this.ui.lastCont);
        this.ui.createLabel('username', Global.ln.get('window-login-username'), Label.VARIANT_DETAIL, this.ui.lastCont);
        this.ui.createTInput('username', '', '', this.ui.lastCont);
        this.ui.createLabel('password', Global.ln.get('window-login-password'), Label.VARIANT_DETAIL, this.ui.lastCont);
        this.ui.createTInput('userpass', '', '', this.ui.lastCont);
        this.ui.inputs['userpass'].displayAsPassword = true;
        this.ui.createSpacer('line-nomail', 5, false, this.ui.lastCont);
        this.ui.createButton('btlogin', Global.ln.get('window-login-button'), onEnter, this.ui.lastCont);
        this.ui.createSpacer('before-nomail', 20, true, this.ui.lastCont);

        // valid e-mail?
        if (!Global.validEmail) {
            this.ui.createDescription('about-nomail', Global.ln.get('window-login-noemail'), '', this.ui.lastCont);
        } else {
            this.ui.createButton('btrecover', Global.ln.get('window-login-recover'), onRecover, this.ui.lastCont);
        }

        // showing interface
        this.addForm(Global.ln.get('window-login-title'), this.ui.lastCont);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Window custom actions.
    **/
    override public function action(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'login-error':
                this.ui.createWarning(Global.ln.get('window-login-title'), Global.ln.get('window-login-loginerror'), 250, 170, this.stage);
            case 'login-notfound':
                this.ui.createWarning(Global.ln.get('window-login-title'), Global.ln.get('window-login-notfound'), 250, 170, this.stage);
            case 'login-password':
                this.ui.createWarning(Global.ln.get('window-login-title'), Global.ln.get('window-login-passwordno'), 250, 170, this.stage);
            case 'login-nokey':
                this.ui.createWarning(Global.ln.get('window-login-title'), Global.ln.get('window-login-nokey'), 250, 170, this.stage);
            case 'login-ok':
                this.ui.inputs['username'].text = '';
                this.ui.inputs['userpass'].text = '';
        }
    }

    /** EVENTS **/

    private function onSite(evt:TriggerEvent) {
        var req:URLRequest = new URLRequest('https://tilbuci.com.br/');
        req.method = 'GET';
        Lib.getURL(req);
    }

    private function onDiscord(evt:TriggerEvent) {
        var req:URLRequest = new URLRequest('http://discord.tilbuci.com.br/');
        req.method = 'GET';
        Lib.getURL(req);
    }

    /**
        Calls the login.
    **/
    private function onEnter(evt:TriggerEvent) {
        if ((this.ui.inputs['username'].text != '') && (this.ui.inputs['userpass'].text != '')) {
            if (StringStatic.validateEmail(this.ui.inputs['username'].text)) {
                this._ac('check-login', [
                    'user' => this.ui.inputs['username'].text, 
                    'pass' => this.ui.inputs['userpass'].text
                ]);
            } else {
                this.ui.createWarning(Global.ln.get('window-login-title'), Global.ln.get('window-login-emailer'), 250, 170, this.stage);
            }
        } else {
            this.ui.createWarning(Global.ln.get('window-login-title'), Global.ln.get('window-login-noinput'), 250, 170, this.stage);
        }
    }

    /**
        Starts account recover.
    **/
    private function onRecover(evt:TriggerEvent) {
        if (this.ui.inputs['username'].text == '') {
            this.ui.createWarning(Global.ln.get('window-login-title'), Global.ln.get('window-login-nouserrecover'), 250, 170, this.stage);
        } else {
            Global.ws.send('System/LoginRecover', [
                'user' => this.ui.inputs['username'].text
            ], onLoginRecover);
        }
    }

    /**
        Login recover server call return.
    **/
    private function onLoginRecover(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this.ui.createWarning(Global.ln.get('window-login-title'), Global.ln.get('window-login-recovererror'), 250, 170, this.stage);
        } else if (ld.map['e'] != 0) {
            this.ui.createWarning(Global.ln.get('window-login-title'), Global.ln.get('window-login-recovererror'), 250, 170, this.stage);
        } else {
            this.ui.createWarning(Global.ln.get('window-login-title'), Global.ln.get('window-login-recoversent'), 250, 170, this.stage);
        }
    }

}