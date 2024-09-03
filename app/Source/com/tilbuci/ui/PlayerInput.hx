package com.tilbuci.ui;

/** OPENFL **/
import feathers.core.FocusManager;
import com.tilbuci.ui.component.IDButton;
import feathers.skins.RectangleSkin;
import feathers.text.TextFormat;
import feathers.controls.Check;
import com.tilbuci.statictools.StringStatic;
import feathers.controls.TextArea;
import com.tilbuci.data.DataLoader;
import feathers.controls.Label;
import feathers.controls.NumericStepper;
import feathers.data.ArrayCollection;
import feathers.controls.ListView;
import feathers.controls.TextInput;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.display.Shape;

/** ACTUATE **/
import motion.Actuate;

/** FEATHERS UI **/
import feathers.controls.Panel;
import feathers.layout.VerticalLayout;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.Header;
import feathers.layout.HorizontalLayout;
import feathers.controls.Header;
import feathers.events.TriggerEvent;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.utils.DisplayObjectRecycler;
import feathers.data.ListViewItemState;

/** TILBUCI **/
import com.tilbuci.data.GlobalPlayer;

class PlayerInput extends Panel {

    /**
        input background courtain
    **/
    private var _uiBg:Shape;

    /**
        input panel ok button
    **/
    private var _inputBtOk:Button;

    /**
        input panel cancel button
    **/
    private var _inputBtCancel:Button;

    /**
        variable name to receive input entry
    **/
    private var _inputVar:String;

    /**
        current input type
    **/
    private var _inputType:String;

    /**
        action on input entry confirm
    **/
    private var _inputOkAction:Dynamic;

    /**
        action on input entry cancel
    **/
    private var _inputCancelAction:Dynamic;

    /**
        interface layout gap
    **/
    private var _gap:Int = 10;

    /**
        panel header
    **/
    private var _pheader:Header;

    /**
        panel footer
    **/
    private var _pfooter:LayoutGroup;

    /**
        the text input
    **/
    private var _inputText:TextInput;

    /**
        pick list
    **/
    private var _inputList:ListView;

    /**
        numeric input
    **/
    private var _inputNumeric:NumericStepper;

    /**
        interafce label text
    **/
    private var _inputLabel:Label;

    /**
        large text area
    **/
    private var _inputArea:TextArea;

    /**
        checkbox
    **/
    private var _inputCheck:Check;

    /**
        texts used for visitor login
    **/
    private var _logintexts:Map<String, String> = [ ];

    /**
        texts used for visitor state selection
    **/
    private var _statetexts:Map<String, String> = [ ];

    /**
        additional buttons
    **/
    private var _buttons:Array<IDButton> = [ ];


    public function new(bg:Shape) {
        super();
        this._uiBg = bg;

        var pnLayout:VerticalLayout = new VerticalLayout();
        pnLayout.gap = this._gap;
        pnLayout.setPadding(this._gap);
        this.layout = pnLayout;
        this.y = -500;

        this._pheader = new Header();
        this._pheader.text = '';
        this.header = this._pheader;

        this._pfooter = new LayoutGroup();
        var ftLayout:HorizontalLayout = new HorizontalLayout();
        ftLayout.horizontalAlign = CENTER;
        ftLayout.gap = this._gap;
        ftLayout.setPadding(this._gap);
        this._pfooter.layout = ftLayout;
        this.footer = this._pfooter;

        this._inputBtCancel = new Button();
        var cancelIcon:Bitmap = new Bitmap(Assets.getBitmapData('btClose'));
        cancelIcon.smoothing = true;
        cancelIcon.width = cancelIcon.height = (3 * this._gap);
        this._inputBtCancel.icon = cancelIcon;
        this._pfooter.addChild(this._inputBtCancel);

        this._inputBtOk = new Button();
        var okIcon:Bitmap = new Bitmap(Assets.getBitmapData('btOk'));
        okIcon.smoothing = true;
        okIcon.width = okIcon.height = (3 * this._gap);
        this._inputBtOk.icon = okIcon;
        this._pfooter.addChild(this._inputBtOk);

        this._inputText = new TextInput();
        this._inputText.setPadding(this._gap);

        this._inputList = new ListView();
        this._inputList.itemToText = (item:Dynamic) -> { return (item.text); }

        this._inputNumeric = new NumericStepper();

        this._inputLabel = new Label();
        this._inputLabel.wordWrap = true;

        this._inputArea = new TextArea();
        this._inputArea.selectable = false;
        this._inputArea.enabled = false;
        this._inputArea.wordWrap = true;

        this._inputCheck = new Check();

        this.visible = false;
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.removeChildren();
        this._pheader.removeChildren();
        this._pheader = null;
        this._pfooter.removeChildren();
        this._pfooter = null;
        this._inputBtCancel = null;
        this._inputBtOk = null;
        this._inputText = null;
        this._inputType = null;
        this._inputVar = null;
        this._inputCancelAction = null;
        this._inputOkAction = null;
        this._inputList = null;
        this._inputNumeric = null;
        for (t in this._logintexts.keys()) this._logintexts.remove(t);
        this._logintexts = null;
    }

    /**
        Asks for a movie secret key.
        @param  title   the input box title
    **/
    public function askSecret(title:String):Void {
        this._inputType = 'secretkey';
        this.y = -500;
        this._inputOkAction = null;
        this._inputCancelAction = null;
        this._pheader.text = title;
        this.width = GlobalPlayer.area.width;
        this.x = 0;
        this._inputBtOk.width = this.width - (2 * this._gap);
        this.removeChildren();
        this._inputText.width = this._inputBtOk.width;
        this._inputText.text = '';
        this.addChild(this._inputText);
        this._pfooter.removeChildren();
        this._pfooter.addChild(this._inputBtOk);
        this._inputBtOk.addEventListener(TriggerEvent.TRIGGER, inputBtOk);
        this.visible = true;
        this._uiBg.visible = true;
        Actuate.tween(this, 0.3, { y: 50 });
        Actuate.tween(this._uiBg, 0.3, { alpha: 1}).autoVisible(false);
    }

    public function askStates(title:String, waistates:String, selectstate:String, nostates:String, dateformat:String, acOk:Dynamic, acCancel:Dynamic):Void {
        this._inputType = 'states';
        this._statetexts['title'] = title;
        this._statetexts['waistates'] = waistates;
        this._statetexts['selectstate'] = selectstate;
        this._statetexts['nostates'] = nostates;
        this._statetexts['dateformat'] = dateformat;
        this.prepare('states', this._statetexts['title'], acOk, acCancel);
        this._inputLabel.text = this._statetexts['waistates'];
        this._inputLabel.width = this.width - (2 * this._gap);
        this.addChild(this._inputLabel);
        this._pfooter.removeChildren();
        GlobalPlayer.ws.stateList(dateformat, this.onStateList);
    }

    /**
        Opens the text input interface.
        @param  varname the variable name to receive the input
        @param  title   the input box title
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click
    **/
    public function askLogin(logintitle:String, logintext:String, termsagree:String, invalidemail:String, emailwait:String, noemailsent:String, checkforcode:String, codewait:String, invalidcode:String, emailsubject:String, emailbody:String, emailsender:String, acOk:Dynamic, acCancel:Dynamic):Void {
        this._logintexts['logintitle'] = logintitle;
        this._logintexts['logintext'] = logintext;
        this._logintexts['termsagree'] = termsagree;
        this._logintexts['invalidemail'] = invalidemail;
        this._logintexts['emailwait'] = emailwait;
        this._logintexts['noemailsent'] = noemailsent;
        this._logintexts['checkforcode'] = checkforcode;
        this._logintexts['codewait'] = codewait;
        this._logintexts['invalidcode'] = invalidcode;
        this._logintexts['emailsubject'] = emailsubject;
        this._logintexts['emailbody'] = emailbody;
        this._logintexts['emailsender'] = emailsender;
        this._inputType = 'login';
        this.prepare('login', this._logintexts['logintitle'], acOk, acCancel);
        this._inputLabel.text = this._logintexts['logintext'];
        this._inputLabel.width = this.width - (2 * this._gap);
        this.addChild(this._inputLabel);
        this._inputText.width = this.width - (2 * this._gap);
        this._inputText.text = '';
        this.addChild(this._inputText);
        this._inputArea.width = this.width - (2 * this._gap);
        new DataLoader(true, (GlobalPlayer.base + 'VisitorTerms.txt'), 'GET', null, DataLoader.MODETEXT, onTerms);
        this.addChild(this._inputArea);
        this._inputCheck.selected = false;
        this._inputCheck.text = this._logintexts['termsagree'];
        this._inputCheck.maxWidth = this.width - (2 * this._gap);
        this.addChild(this._inputCheck);
    }

    /**
        Opens the text input interface.
        @param  varname the variable name to receive the input
        @param  title   the input box title
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click
    **/
    public function askText(varname:String, title:String, acOk:Dynamic, acCancel:Dynamic):Void {
        this._inputType = 'text';
        this.prepare(varname, title, acOk, acCancel);
        this._inputText.width = this.width - (2 * this._gap);
        this._inputText.text = GlobalPlayer.parser.getString(varname);
        this.addChild(this._inputText);
    }

    /**
        Opens a message box,
        @param  title   the warn box title
        @param  text   the warn box message
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click (null to avoid showing cancel button)
    **/
    public function setWarn(title:String, text:String, acOk:Dynamic, acCancel:Dynamic):Void {
        this._inputType = 'warn';
        this.prepare('warn', title, acOk, acCancel);
        this._inputLabel.width = this.width - (2 * this._gap);
        this._inputLabel.text = text;
        this.addChild(this._inputLabel);
        if (acCancel == null) {
            this._pfooter.removeChildren();
            this._inputBtOk.width = this.width - (3 * this._gap) - 2;
            this._pfooter.addChild(this._inputBtOk);
        }
    }

    /**
        Opens the text input interface.
        @param  varname the variable name to receive the input
        @param  title   the input box title
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click
    **/
    public function askNumeric(type:String, varname:String, title:String, acOk:Dynamic, acCancel:Dynamic, step:Float = 0, min:Float = 0, max:Float = 100):Void {
        this._inputType = type;
        this.prepare(varname, title, acOk, acCancel);
        if (type == 'int') {
            if (step == 0) this._inputNumeric.step = 1
                else this._inputNumeric.step = Math.round(step);
            this._inputNumeric.minimum = Math.round(min);
            this._inputNumeric.maximum = Math.round(max);
            this._inputNumeric.value = GlobalPlayer.parser.getInt(varname);
        } else {
            if (step == 0) this._inputNumeric.step = 0.5
                else this._inputNumeric.step = step;
            this._inputNumeric.minimum = min;
            this._inputNumeric.maximum = max;
            this._inputNumeric.value = GlobalPlayer.parser.getFloat(varname);
        }
        this._inputNumeric.width = this.width - (2 * this._gap);
        this.addChild(this._inputNumeric);
    }

    /**
        Opens the list input interface.
        @param  varname the variable name to receive the input
        @param  title   the input box title
        @param  options list options
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click
    **/
    public function askList(varname:String, title:String, options:Array<String>, acOk:Dynamic, acCancel:Dynamic):Void {
        this._inputType = 'list';
        this.prepare(varname, title, acOk, acCancel);
        var items = [ ];
        for (i in 0...options.length) items.push({ text: options[i] });
        this._inputList.dataProvider = new ArrayCollection(items);
        this._inputList.width = this.width - (2 * this._gap);
        this.addChild(this._inputList);
    }

    /**
        Opens the email input interface.
        @param  varname the variable name to receive the input
        @param  title   the input box title
        @param  domains automatic fill domains
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click
    **/
    public function askEmail(varname:String, title:String, domains:Array<String>, acOk:Dynamic, acCancel:Dynamic):Void {
        this._inputType = 'email';
        this.prepare(varname, title, acOk, acCancel);
        this._inputText.width = this.width - (2 * this._gap);
        this._inputText.text = GlobalPlayer.parser.getString(varname);
        this.addChild(this._inputText);
        this.clearButtons();
        for (i in 0...domains.length) {
            var idbt:IDButton = new IDButton(domains[i], this.onEmailDomain, domains[i]);
            idbt.width = this._inputText.width;
            this.addChild(idbt);
            this._buttons.push(idbt);
        }
        FocusManager.setFocus(this._inputText);
    }

    private function onEmailDomain(evt:TriggerEvent):Void {
        var idbt:IDButton = cast evt.target;
        if (idbt != null) {
            this._inputText.text = this._inputText.text + idbt.btid;
        }
    }

    /**
        Clear additional buttons.
    **/
    private function clearButtons():Void {
        while (this._buttons.length > 0) {
            this._buttons.shift().kill();
        }
    }

    /**
        Prepares the interface.
        @param  varname the variable name to receive the input
        @param  title   the input box title
        @param  acOk    actions to call on ok button click
        @param  acCancel    actions to call on cancel button click
    **/
    private function prepare(varname:String, title:String, acOk:Dynamic, acCancel:Dynamic):Void {

        if (GlobalPlayer.theme != null) {
            if (GlobalPlayer.theme.headerBackground != null) {
                this._pheader.backgroundSkin = new RectangleSkin(SolidColor(GlobalPlayer.theme.headerBackground));
            }
            if (GlobalPlayer.theme.windowBackground != null) {
                this.backgroundSkin = new RectangleSkin(SolidColor(GlobalPlayer.theme.windowBackground));
            }
            if (GlobalPlayer.theme.footerFillColor != null) {
                this._pfooter.backgroundSkin = new RectangleSkin(SolidColor(GlobalPlayer.theme.footerFillColor));
            }
            this._pheader.textFormat = new TextFormat(GlobalPlayer.theme.headerFont, GlobalPlayer.theme.headerSize, GlobalPlayer.theme.headerFontColor);
            this._pheader.embedFonts = GlobalPlayer.theme.headerFont != '_sans';
            if (GlobalPlayer.theme.listBackground != null) {
                this._inputList.backgroundSkin = new RectangleSkin(SolidColor(GlobalPlayer.theme.listBackground));
            }
            if ((GlobalPlayer.theme.listItemBackground != null) || (GlobalPlayer.theme.listItemFont != null) || (GlobalPlayer.theme.windowFontName != '_sans') || (GlobalPlayer.theme.windowFontSize != 14)) {
                var recycler = DisplayObjectRecycler.withFunction(() -> {
                    var itemRenderer = new ItemRenderer();
                    itemRenderer.backgroundSkin = new RectangleSkin(SolidColor(GlobalPlayer.theme.listItemBackground));
                    itemRenderer.textFormat = new TextFormat(GlobalPlayer.theme.windowFontName, GlobalPlayer.theme.windowFontSize, GlobalPlayer.theme.listItemFont);
                    return (itemRenderer);
                });
                this._inputList.itemRendererRecycler = recycler;
                recycler.update = (itemRenderer:ItemRenderer, state:ListViewItemState) -> {
                    itemRenderer.text = state.text;
                };
            }
        }

        this.y = -500;
        this._inputVar = varname;
        this._inputOkAction = acOk;
        this._inputCancelAction = acCancel;
        this._pheader.text = title;
        if (this._uiBg.width < this._uiBg.height) {
            this.width = 3 * this._uiBg.width / 4;
        } else {
            this.width = 2 * this._uiBg.width / 3;
        }
        this.x = (this._uiBg.width - this.width) / 2;
        this.removeChildren();
        this._inputBtCancel.width = this._inputBtOk.width = ((this.width - (3 * this._gap)) / 2) - 1;
        this._pfooter.removeChildren();
        this._pfooter.addChild(this._inputBtCancel);
        this._pfooter.addChild(this._inputBtOk);
        this._inputBtCancel.addEventListener(TriggerEvent.TRIGGER, inputBtCancel);
        this._inputBtOk.addEventListener(TriggerEvent.TRIGGER, inputBtOk);
        this.visible = true;
        this._uiBg.visible = true;
        Actuate.tween(this, 0.3, { y: 50 });
        Actuate.tween(this._uiBg, 0.3, { alpha: 1}).autoVisible(false);
    }

    /**
        Ok button clicked.
    **/
    private function inputBtOk(evt:TriggerEvent):Void {
        if (this._inputType == 'secretkey') {
            var secretkey:String = '';
            if (GlobalPlayer.mdata.key != '') {
                secretkey = StringStatic.decrypt(GlobalPlayer.mdata.key, 'skey', GlobalPlayer.secret);
            }
            if ((this._inputText.text == secretkey) || (GlobalPlayer.mdata.key == '')) {
                GlobalPlayer.secretKey = GlobalPlayer.mdata.key;
                this._inputBtOk.removeEventListener(TriggerEvent.TRIGGER, inputBtOk);
                Actuate.tween(this, 0.1, { y: -500}).onComplete(this.inputClose);
                Actuate.tween(this._uiBg, 0.1, { alpha: 0}).autoVisible(false);
            }
        } else if (this._inputType == 'login') {
            if (this._inputCheck.selected) {
                var ereg = ~/.+@.+/i;
                if (!ereg.match(this._inputText.text)) {
                    this._inputLabel.text = this._logintexts['invalidemail'];
                } else {
                    this._inputLabel.text = this._logintexts['emailwait'];
                    this.removeChildren();
                    this.addChild(this._inputLabel);
                    this._inputType = 'waitemail';
                    this._logintexts['visitoremail'] = this._inputText.text;
                    GlobalPlayer.ws.loginVisitor(this._inputText.text, this._logintexts['emailsubject'], this._logintexts['emailbody'], this._logintexts['emailsender'], this.onLoginSent);
                    this._inputText.text = '';
                    this._pfooter.removeChildren();
                }
            }
        } else if (this._inputType == 'waitforcode') {
            GlobalPlayer.ws.checkVisitorCode(this._logintexts['visitoremail'], this._inputText.text, this.onCodeCheck);
            this._pfooter.removeChildren();
            this.removeChildren();
            this._inputLabel.text = this._logintexts['codewait'];
            this.addChild(this._inputLabel);
        } else if (this._inputType == 'states') {
            if (this._inputList.selectedItem != null) {
                GlobalPlayer.parser.run({
                    ac: 'data.loadstate', 
                    param: [ this._inputList.selectedItem.id ], 
                    success: this._inputOkAction, 
                    error: this._inputCancelAction
                }, true);
                this._inputBtCancel.removeEventListener(TriggerEvent.TRIGGER, inputBtCancel);
                this._inputBtOk.removeEventListener(TriggerEvent.TRIGGER, inputBtOk);
                Actuate.tween(this, 0.1, { y: -500}).onComplete(this.inputClose);
                Actuate.tween(this._uiBg, 0.1, { alpha: 0}).autoVisible(false);
            }
        } else if (this._inputType == 'email') {
            // check for valid e-mail
            if (StringStatic.validateEmail(this._inputText.text)) {
                GlobalPlayer.parser.setString(this._inputVar, this._inputText.text);
                this._inputBtCancel.removeEventListener(TriggerEvent.TRIGGER, inputBtCancel);
                this._inputBtOk.removeEventListener(TriggerEvent.TRIGGER, inputBtOk);
                this.clearButtons();
                Actuate.tween(this, 0.1, { y: -500}).onComplete(this.inputClose);
                Actuate.tween(this._uiBg, 0.1, { alpha: 0}).autoVisible(false);
                GlobalPlayer.parser.run(this._inputOkAction, true);
            } else {
                // nothing to do
            }
        } else {
            switch (this._inputType) {
                case 'text':
                    GlobalPlayer.parser.setString(this._inputVar, this._inputText.text);
                case 'list':
                    if (this._inputList.selectedItem != null) GlobalPlayer.parser.setString(this._inputVar, this._inputList.selectedItem.text);
                case 'int':
                    GlobalPlayer.parser.setInt(this._inputVar, Math.round(this._inputNumeric.value));
                case 'float':
                    GlobalPlayer.parser.setFloat(this._inputVar, this._inputNumeric.value);
                case 'warn':
                    // nothing to do
            }
            this._inputBtCancel.removeEventListener(TriggerEvent.TRIGGER, inputBtCancel);
            this._inputBtOk.removeEventListener(TriggerEvent.TRIGGER, inputBtOk);
            Actuate.tween(this, 0.1, { y: -500}).onComplete(this.inputClose);
            Actuate.tween(this._uiBg, 0.1, { alpha: 0}).autoVisible(false);
            GlobalPlayer.parser.run(this._inputOkAction, true);
        }
    }

    /**
        Result for login message sending received.
    **/
    private function onLoginSent(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                this._inputLabel.text = this._logintexts['checkforcode'];
                this._inputText.text = '';
                this.addChild(this._inputText);
                this._inputType = 'waitforcode';
                this._inputBtCancel.width = this._inputBtOk.width = ((this.width - (3 * this._gap)) / 2) - 1;
                this._pfooter.removeChildren();
                this._pfooter.addChild(this._inputBtCancel);
                this._pfooter.addChild(this._inputBtOk);
            } else {
                this._inputLabel.text = this._logintexts['noemailsent'];    
                this._pfooter.removeChildren();
                this._pfooter.addChild(this._inputBtCancel);
                this._inputBtCancel.width = this.width - (2 * this._gap) - 2;
            }
        } else {
            this._inputLabel.text = this._logintexts['noemailsent'];
            this._pfooter.removeChildren();
            this._pfooter.addChild(this._inputBtCancel);
            this._inputBtCancel.width = this.width - (2 * this._gap) - 2;
        }
    }

    /**
        Result for login code check.
    **/
    private function onCodeCheck(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                GlobalPlayer.ws.setUser(this._logintexts['visitoremail'], ld.map['key'], ld.map['groups']);
                this._inputType = 'codeok';
                this.inputBtOk(null);
            } else {
                this._inputType = 'waitforcode';
                this._inputLabel.text = this._logintexts['invalidcode'];    
                this.addChild(this._inputText);
                this._pfooter.removeChildren();
                this._pfooter.addChild(this._inputBtCancel);
                this._pfooter.addChild(this._inputBtOk);
                this._inputBtOk.width = this._inputBtCancel.width = ((this.width - (3 * this._gap)) / 2) - 1;
            }
        } else {
            this._inputType = 'waitforcode';
            this._inputLabel.text = this._logintexts['invalidcode'];    
            this.addChild(this._inputText);
            this._pfooter.removeChildren();
            this._pfooter.addChild(this._inputBtCancel);
            this._pfooter.addChild(this._inputBtOk);
            this._inputBtOk.width = this._inputBtCancel.width = ((this.width - (3 * this._gap)) / 2) - 1;
        }
    }

    /**
        The terms of use were just loaded.
    **/
    private function onTerms(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            this._inputArea.text = StringTools.replace(ld.rawtext, "\r\n", "\n");
        } else {
            this._inputArea.text = 'ERROR LOADING THE TERMS';
        }
    }

    /**
        A list of available save states is ready.
    **/
    private function onStateList(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                this._inputLabel.text = this._statetexts['selectstate'];
                var items = [ ];
                for (num in Reflect.fields(ld.map['states'])) {
                    var obj:Dynamic = Reflect.field(ld.map['states'], num);
                    var text:String = Reflect.field(obj, 'date');
                    var about:String = Reflect.field(obj, 'about');
                    if (about != '') text = text + ' : ' + about;
                    items.push({ text: text, id: Reflect.field(obj, 'id') });
                }
                this._inputList.dataProvider = new ArrayCollection(items);
                this._inputList.width = this.width - (2 * this._gap);
                this.addChild(this._inputList);
                this._inputBtCancel.width = this._inputBtOk.width = ((this.width - (3 * this._gap)) / 2) - 1;
                this._pfooter.addChild(this._inputBtCancel);
                this._pfooter.addChild(this._inputBtOk);
            } else {
                this._inputLabel.text = this._statetexts['nostates'];
                this._inputBtCancel.width = this.width - (2 * this._gap) - 2;
                this._pfooter.addChild(this._inputBtCancel);
            }
        } else {
            this._inputLabel.text = this._statetexts['nostates'];
            this._inputBtCancel.width = this.width - (2 * this._gap) - 2;
            this._pfooter.addChild(this._inputBtCancel);
        }
    }

    /**
        Cancel button clicked.
    **/
    private function inputBtCancel(evt:TriggerEvent):Void {
        this._inputBtCancel.removeEventListener(TriggerEvent.TRIGGER, inputBtCancel);
        this._inputBtOk.removeEventListener(TriggerEvent.TRIGGER, inputBtOk);
        this.clearButtons();
        Actuate.tween(this, 0.1, { y: -500}).onComplete(this.inputClose);
        Actuate.tween(this._uiBg, 0.1, { alpha: 0}).autoVisible(false);
        GlobalPlayer.parser.run(this._inputCancelAction, true);
    }
    
    /**
        Close interface animation finished.
    **/
    private function inputClose():Void {
        this._uiBg.visible = false;
        this.visible = false;
    }

}