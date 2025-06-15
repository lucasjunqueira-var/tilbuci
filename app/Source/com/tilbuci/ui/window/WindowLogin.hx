/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.ui.window;

/** FEATHERS UI **/
import com.tilbuci.data.DataLoader;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.events.TriggerEvent;

/** TILBUCI **/
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.Global;

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
        super(ac, Global.ln.get('window-login-title'), 500, 330, false, false);

        // creating interface
        this.ui.createContainer('form');
        this.ui.createLabel('username', Global.ln.get('window-login-username'), Label.VARIANT_DETAIL, this.ui.lastCont);
        this.ui.createTInput('username', '', '', this.ui.lastCont);
        this.ui.createLabel('password', Global.ln.get('window-login-password'), Label.VARIANT_DETAIL, this.ui.lastCont);
        this.ui.createTInput('userpass', '', '', this.ui.lastCont);
        this.ui.inputs['userpass'].displayAsPassword = true;
        this.ui.createSpacer('line-nomail', 10, false, this.ui.lastCont);
        this.ui.createButton('btlogin', Global.ln.get('window-login-button'), onEnter, this.ui.lastCont);

        // valid e-mail?
        if (!Global.validEmail) {
            this.ui.createSpacer('before-nomail', 30, true, this.ui.lastCont);
            this.ui.createDescription('about-nomail', Global.ln.get('window-login-noemail'), '', this.ui.lastCont);
        } else {
            this.ui.createSpacer('before-nomail', 50, true, this.ui.lastCont);
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