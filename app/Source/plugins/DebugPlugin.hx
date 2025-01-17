/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package plugins;

/** HAXE **/
import haxe.Json;

/** OPENFL **/
import openfl.events.MouseEvent;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.TextFormatAlign;
import openfl.display.Sprite;
import openfl.text.TextFieldType;
import openfl.display.FPS;
import openfl.ui.Keyboard;

/** TILBUCI **/
import com.tilbuci.plugin.PluginEvent;
import com.tilbuci.plugin.Plugin;
import com.tilbuci.plugin.PluginAccess;
import com.tilbuci.script.ScriptParser;

class DebugPlugin extends Plugin {

    /**
        overlay layer
    **/
    private var _overlay:Sprite;

    /**
        information area
    **/
    private var _infoArea:Sprite;

    /**
        information text
    **/
    private var _infoText:TextField;

    /**
        format for regular texts
    **/
    private var _txFormat:TextFormat;

    /**
        format for button texts
    **/
    private var _btFormat:TextFormat;

    /**
        format for input texts
    **/
    private var _inFormat:TextFormat;

    /**
        hide interface button
    **/
    private var _hideBt:TextField;

    /**
        cycle interface button
    **/
    private var _cycleBt:TextField;

    /**
        scene interface button
    **/
    private var _sceneIBt:TextField;

    /**
        movie interface button
    **/
    private var _movieIBt:TextField;

    /**
        variables interface button
    **/
    private var _varIBt:TextField;

    /**
        action interface button
    **/
    private var _actionIBt:TextField;

    /**
        stats interface button
    **/
    private var _statsIBt:TextField;

    /**
        interface position
    **/
    private var _intPos:Int = 3;

    /**
        scene load button
    **/
    private var _sceneBt:TextField;

    /**
        scene load interface
    **/
    private var _interfaceScene:Sprite;

    /**
        scene id input
    **/
    private var _sceneInput:TextField;

    /**
        scene interface text
    **/
    private var _sceneTxt:TextField;

    /**
        movie load button
    **/
    private var _movieBt:TextField;

    /**
        movie load interface
    **/
    private var _interfaceMovie:Sprite;

    /**
        movie id input
    **/
    private var _movieInput:TextField;

    /**
        movie interface text
    **/
    private var _movieTxt:TextField;

    /**
        variables interface
    **/
    private var _interfaceVar:Sprite;

    /**
        variables about text
    **/
    private var _varTxt:TextField;

    /**
        variables list text
    **/
    private var _varList:TextField;

    /**
        set var text
    **/
    private var _setvarTxt:TextField;

    /**
        current var type
    **/
    private var _varType:String = 'string';

    /**
        new var name
    **/
    private var _setVarName:TextField;

    /**
        var equal text
    **/
    private var _setVarEqual:TextField;

    /**
        new var value
    **/
    private var _setVarValue:TextField;

    /**
        set var button
    **/
    private var _setVarButton:TextField;

    /**
        refresh var list button
    **/
    private var _refreshVarButton:TextField;

    /**
        trace vars button
    **/
    private var _traceVarButton:TextField;

    /**
        set var to string button
    **/
    private var _setVarString:TextField;

    /**
        set var to float button
    **/
    private var _setVarFloat:TextField;

    /**
        set var to int button
    **/
    private var _setVarInt:TextField;

    /**
        set var to boolean button
    **/
    private var _setVarBool:TextField;

    /**
        action run interface
    **/
    private var _intarfaceAction:Sprite;

    /**
        action run text
    **/
    private var _actionTxt:TextField;

    /**
        action input area
    **/
    private var _actionArea:TextField;

    /**
        action run button
    **/
    private var _actionRun:TextField;

    /**
        fps diplay
    **/
    private var _fps:FPS;

    /**
        fps display holder
    **/
    private var _fpsHolder:Sprite;

    /**
        use F8 key to show debug display?
    **/
    private var _useF8:Bool = true;


    /**
        Constructor.
    **/
    public function new() {
        super('original.debug', 'Debug');

        // text formatting
        this._txFormat = new TextFormat('_sans', 10, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.LEFT);
        this._btFormat = new TextFormat('_sans', 9, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
        this._inFormat = new TextFormat('_sans', 10, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.LEFT);

        // information area
        this._infoArea = new Sprite();
        this._infoArea.graphics.beginFill(0, 0.5);
        this._infoArea.graphics.drawRect(0, 0, 350, 110);
        this._infoArea.graphics.endFill();
        this._infoArea.x = this._infoArea.y = 10;
        this._infoText = this.createTxInterface(true, '', 5, 5, (this._infoArea.width - 10), (this._infoArea.height - 19));
        this._infoArea.addChild(this._infoText);

        // interface buttons
        var wd:Float = (this._infoArea.width - (8 * 5)) / 7;
        this._hideBt = this.createBtInterface('hide', onInterfaceHide);
        this._hideBt.x = 5;
        this._hideBt.y = this._infoText.height - 2;
        this._hideBt.width = wd;
        this._infoArea.addChild(this._hideBt);
        this._cycleBt = this.createBtInterface('cycle', onInterfaceCycle);
        this._cycleBt.x = this._hideBt.x + wd + 5;
        this._cycleBt.y = this._hideBt.y;
        this._cycleBt.width = wd;
        this._infoArea.addChild(this._cycleBt);
        this._movieIBt = this.createBtInterface('movie', onInterfaceMovie);
        this._movieIBt.x = this._cycleBt.x + wd + 5;
        this._movieIBt.y = this._hideBt.y;
        this._movieIBt.width = wd;
        this._infoArea.addChild(this._movieIBt);
        this._sceneIBt = this.createBtInterface('scene', onInterfaceScene);
        this._sceneIBt.x = this._movieIBt.x + wd + 5;
        this._sceneIBt.y = this._hideBt.y;
        this._sceneIBt.width = wd;
        this._infoArea.addChild(this._sceneIBt);
        this._varIBt = this.createBtInterface('vars', onInterfaceVar);
        this._varIBt.x = this._sceneIBt.x + wd + 5;
        this._varIBt.y = this._hideBt.y;
        this._varIBt.width = wd;
        this._infoArea.addChild(this._varIBt);
        this._actionIBt = this.createBtInterface('action', onInterfaceAction);
        this._actionIBt.x = this._varIBt.x + wd + 5;
        this._actionIBt.y = this._hideBt.y;
        this._actionIBt.width = wd;
        this._infoArea.addChild(this._actionIBt);
        this._statsIBt = this.createBtInterface('stats', onInterfaceStats);
        this._statsIBt.x = this._actionIBt.x + wd + 5;
        this._statsIBt.y = this._hideBt.y;
        this._statsIBt.width = wd;
        this._infoArea.addChild(this._statsIBt);

        // movie interface
        this._interfaceMovie = new Sprite();
        this._interfaceMovie.graphics.beginFill(0, 0.5);
        this._interfaceMovie.graphics.drawRect(0, 0, this._infoArea.width, 75);
        this._interfaceMovie.graphics.endFill();
        this._interfaceMovie.x = 0;
        this._interfaceMovie.y = this._infoArea.height + 2;
        this._movieTxt = this.createTxInterface(true, '<b>New movie load:</b> enter the movie ID', 5, 5, (this._interfaceMovie.width - 10), 24);
        this._interfaceMovie.addChild(this._movieTxt);
        this._movieInput = this.createInputInterface(this._interfaceMovie.width - 10);
        this._movieInput.x = 5;
        this._movieInput.y = this._movieTxt.y + this._movieTxt.height;
        this._interfaceMovie.addChild(this._movieInput);
        this._movieBt = this.createBtInterface('load movie', this.onLoadMovie);
        this._movieBt.x = 5;
        this._movieBt.y = this._movieInput.y + this._movieInput.height + 5;
        this._movieBt.width = this._movieInput.width;
        this._interfaceMovie.addChild(this._movieBt);

        // scene interface
        this._interfaceScene = new Sprite();
        this._interfaceScene.graphics.beginFill(0, 0.5);
        this._interfaceScene.graphics.drawRect(0, 0, this._infoArea.width, 75);
        this._interfaceScene.graphics.endFill();
        this._interfaceScene.x = 0;
        this._interfaceScene.y = this._infoArea.height + 2;
        this._sceneTxt = this.createTxInterface(true, '<b>New scene load:</b> enter the scene ID', 5, 5, (this._interfaceScene.width - 10), 24);
        this._interfaceScene.addChild(this._sceneTxt);
        this._sceneInput = this.createInputInterface(this._interfaceScene.width - 10);
        this._sceneInput.x = 5;
        this._sceneInput.y = this._sceneTxt.y + this._sceneTxt.height;
        this._interfaceScene.addChild(this._sceneInput);
        this._sceneBt = this.createBtInterface('load scene', this.onLoadScene);
        this._sceneBt.x = 5;
        this._sceneBt.y = this._sceneInput.y + this._sceneInput.height + 5;
        this._sceneBt.width = this._sceneInput.width;
        this._interfaceScene.addChild(this._sceneBt);

        // variables interface
        this._interfaceVar = new Sprite();
        this._interfaceVar.graphics.beginFill(0, 0.5);
        this._interfaceVar.graphics.drawRect(0, 0, this._infoArea.width, 200);
        this._interfaceVar.graphics.endFill();
        this._interfaceVar.x = 0;
        this._interfaceVar.y = this._infoArea.height + 2;
        this._varTxt = this.createTxInterface(false, '<b>String variables</b>', 5, 5, (this._interfaceVar.width - 10), 24);
        this._varTxt.defaultTextFormat = this._txFormat;
        this._interfaceVar.addChild(this._varTxt);
        this._varList = this.createTxInterface(true, '', 5, (this._varTxt.y + this._varTxt.height), this._varTxt.width, 100);
        this._varList.selectable = true;
        this._varList.type = TextFieldType.INPUT;
        this._varList.border = true;
        this._varList.borderColor = 0xFFFFFF;
        this._varList.addEventListener(MouseEvent.CLICK, onInputClick);
        this._interfaceVar.addChild(this._varList);
        this._setvarTxt = this.createTxInterface(false, '<b>Set string value (set to empty field to remove it)</b>', 5, (this._varList.y + this._varList.height + 5), (this._interfaceVar.width - 10), 18);
        this._interfaceVar.addChild(this._setvarTxt);
        this._setVarName = this.createInputInterface(this._interfaceVar.width / 3);
        this._setVarName.x = 5;
        this._setVarName.y = this._setvarTxt.y + this._setvarTxt.height + 5;
        this._interfaceVar.addChild(this._setVarName);
        this._setVarEqual = this.createTxInterface(false, '=', (this._setVarName.x + this._setVarName.width + 5), this._setVarName.y, 20, 15);
        this._interfaceVar.addChild(this._setVarEqual);
        this._setVarValue = this.createInputInterface(this._interfaceVar.width / 3);
        this._setVarValue.x = this._setVarEqual.x + this._setVarEqual.width + 2;
        this._setVarValue.y = this._setVarName.y;
        this._interfaceVar.addChild(this._setVarValue);
        this._setVarButton = this.createBtInterface('set', this.onSetVar);
        this._setVarButton.x = this._interfaceVar.width - this._setVarButton.width - 5;
        this._setVarButton.y = this._setVarName.y;
        this._interfaceVar.addChild(this._setVarButton);
        this._traceVarButton = this.createBtInterface('trace', this.onTraceVar);
        this._traceVarButton.x = this._interfaceVar.width - this._traceVarButton.width - 5;
        this._traceVarButton.y = this._setVarButton.y + this._setVarButton.height + 5;
        this._interfaceVar.addChild(this._traceVarButton);
        this._refreshVarButton = this.createBtInterface('refresh', this.onRefreshVar);
        this._refreshVarButton.x = this._traceVarButton.x - this._refreshVarButton.width - 5;
        this._refreshVarButton.y = this._traceVarButton.y;
        this._interfaceVar.addChild(this._refreshVarButton);
        this._setVarString = this.createBtInterface('string', this.onSetString);
        this._setVarString.x = 5;
        this._setVarString.y = this._traceVarButton.y;
        this._interfaceVar.addChild(this._setVarString);
        this._setVarFloat = this.createBtInterface('float', this.onSetFloat);
        this._setVarFloat.x = this._setVarString.x + this._setVarString.width + 5;
        this._setVarFloat.y = this._traceVarButton.y;
        this._interfaceVar.addChild(this._setVarFloat);
        this._setVarInt = this.createBtInterface('int', this.onSetInt);
        this._setVarInt.x = this._setVarFloat.x + this._setVarFloat.width + 5;
        this._setVarInt.y = this._traceVarButton.y;
        this._interfaceVar.addChild(this._setVarInt);
        this._setVarBool = this.createBtInterface('bool', this.onSetBool);
        this._setVarBool.x = this._setVarInt.x + this._setVarInt.width + 5;
        this._setVarBool.y = this._traceVarButton.y;
        this._interfaceVar.addChild(this._setVarBool);


        // action interface
        this._intarfaceAction = new Sprite();
        this._intarfaceAction.graphics.beginFill(0, 0.5);
        this._intarfaceAction.graphics.drawRect(0, 0, this._infoArea.width, 200);
        this._intarfaceAction.graphics.endFill();
        this._intarfaceAction.x = 0;
        this._intarfaceAction.y = this._infoArea.height + 2;
        this._actionTxt = this.createTxInterface(true, '<b>Write/paste the action JSON below</b>', 5, 5, (this._intarfaceAction.width - 10), 24);
        this._intarfaceAction.addChild(this._actionTxt);
        this._actionArea = this.createInputInterface(this._intarfaceAction.width - 10);
        this._actionArea.x = 5;
        this._actionArea.y = this._actionTxt.y + this._actionTxt.height;
        this._actionArea.height = 140;
        this._intarfaceAction.addChild(this._actionArea);
        this._actionRun = this.createBtInterface('run', this.onRunAction);
        this._actionRun.x = 5;
        this._actionRun.y = this._actionArea.y + this._actionArea.height + 5;
        this._actionRun.width = this._actionArea.width;
        this._intarfaceAction.addChild(this._actionRun);

        // stats
        this._fpsHolder = new Sprite();
        this._fpsHolder.graphics.beginFill(0, 0.5);
        #if !gl_stats
            this._fpsHolder.graphics.drawRect(0, 0, 65, 30);
        #else
            this._fpsHolder.graphics.drawRect(0, 0, 100, 75);
        #end
        this._fpsHolder.graphics.endFill();
    }

    /**
        Initializes the plugin.
        @param  ac  initialization data
    **/
    override public function initialize(ac:PluginAccess):Void {
        super.initialize(ac);

        // getting a layer to display
        this._overlay = this.getOverlay('original.debug');

        // setting plugin actions
        this.setAction('trace', this.acTrace);
        this.setAction('trace.strings', this.acTraceStrings);
        this.setAction('trace.floats', this.acTraceFloats);
        this.setAction('trace.ints', this.acTraceInts);
        this.setAction('trace.bools', this.acTraceBools);
        this.setAction('trace.vars', this.acTraceVars);
        this.setAction('debuginfo.show', this.acInfoShow);
        this.setAction('debuginfo.hide', this.acInfoHide);

        // getting system informartion
        this.info.addEventListener(PluginEvent.MOVIELOAD, onMovieLoad);
        this.info.addEventListener(PluginEvent.SCENELOAD, onSceneLoad);
        this.info.addEventListener(PluginEvent.KEYFRAMELOAD, onKeyframeLoad);
        this.info.addEventListener(PluginEvent.DISPLAYRESIZE, onDisplayResize);

        // adding plugin actions to the descriptor
        this.addActionGroupDescription({
            n: 'Original Debug', 
            d: 'Actions from the original debug plugin.', 
            a: [
                {
                    n: 'Trace', 
                    a: 'trace', 
                    c: false, 
                    d: 'Outputs text to the system console.', 
                    p: [
                        {
                            n: 'Text to output', 
                            t: 'string', 
                            d: 'The text to output.', 
                            o: false, 
                        }
                    ]
                }
            ]
        });

        // adding global variables descriptor
        this.addGlobalVarGroupDescription({
            n: 'Original Debug Variables', 
            v: [
                {
                    d: 'Is the debug area shown?', 
                    t: 'bool', 
                    c: "?_DEBUGDISPLAY"
                }
            ]
        });
    }

    /**
        Checks for action on keyboard press.
        @param  code    code for the key pressed
        @return a related action was found?
    **/
    override public function checkKeyboard(code:Int):Bool {
        if (this._useF8 && (code == Keyboard.F8)) {
            if (this._infoArea.parent == null) {
                this._overlay.addChild(this._infoArea);
                this.overlayTop('original.debug');
            } else {
                this._overlay.removeChild(this._infoArea);
            }
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Global variables parse.
        @param  str the string to parse
        @return information about found (or not) value
    **/
    override public function parseBool(str:String):ParsedBool {
        switch (str) {
            case "?_DEBUGDISPLAY":
                return ({ found: true, value: (this._infoArea.parent != null) });
            default:
                return ({ found: false, value: false });
        }
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill() {
        this.info.removeEventListener(PluginEvent.MOVIELOAD, onMovieLoad);
        this.info.removeEventListener(PluginEvent.SCENELOAD, onSceneLoad);
        this.info.removeEventListener(PluginEvent.KEYFRAMELOAD, onKeyframeLoad);
        this.info.removeEventListener(PluginEvent.DISPLAYRESIZE, onDisplayResize);
        this.acInfoHide([]);
        this._infoArea.graphics.clear();
        this._infoArea.removeChildren();
        this._infoArea = null;
        this._infoText = null;
        this.killBtInterface(this._hideBt, this.onInterfaceHide);
        this.killBtInterface(this._cycleBt, this.onInterfaceCycle);
        this.killBtInterface(this._sceneIBt, this.onInterfaceScene);
        this.killBtInterface(this._movieIBt, this.onInterfaceMovie);
        this.killBtInterface(this._varIBt, this.onInterfaceVar);
        this.killBtInterface(this._actionIBt, this.onInterfaceAction);
        this.killBtInterface(this._statsIBt, this.onInterfaceStats);
        this._hideBt = this._cycleBt = this._sceneIBt = this._movieIBt = this._varIBt = this._actionIBt = this._statsIBt = null;
        this._interfaceMovie.graphics.clear();
        this._interfaceMovie.removeChildren();
        this._interfaceMovie = null;
        this._movieTxt = null;
        this._movieInput.removeEventListener(MouseEvent.CLICK, onInputClick);
        this._movieInput = null;
        this.killBtInterface(this._movieBt, this.onLoadMovie);
        this._movieBt = null;
        this._interfaceScene.graphics.clear();
        this._interfaceScene.removeChildren();
        this._interfaceScene = null;
        this._sceneTxt = null;
        this._sceneInput.removeEventListener(MouseEvent.CLICK, onInputClick);
        this._sceneInput = null;
        this.killBtInterface(this._sceneBt, this.onLoadScene);
        this._sceneBt = null;
        this._interfaceVar.graphics.clear();
        this._interfaceVar.removeChildren();
        this._interfaceVar = null;
        this._varTxt = null;
        this._varList.removeEventListener(MouseEvent.CLICK, onInputClick);
        this._varList = null;
        this._setvarTxt = null;
        this._setVarName.removeEventListener(MouseEvent.CLICK, onInputClick);
        this._setVarName = null;
        this._setVarValue.removeEventListener(MouseEvent.CLICK, onInputClick);
        this._setVarValue = null;
        this._setVarEqual = null;
        this.killBtInterface(this._setVarButton, this.onSetVar);
        this._setVarButton = null;
        this.killBtInterface(this._traceVarButton, this.onTraceVar);
        this._traceVarButton = null;
        this.killBtInterface(this._refreshVarButton, this.onRefreshVar);
        this._refreshVarButton = null;
        this.killBtInterface(this._setVarString, this.onSetString);
        this._setVarString = null;
        this.killBtInterface(this._setVarFloat, this.onSetFloat);
        this._setVarFloat = null;
        this.killBtInterface(this._setVarInt, this.onSetInt);
        this._setVarInt = null;
        this.killBtInterface(this._setVarBool, this.onSetBool);
        this._setVarBool = null;
        this._intarfaceAction.graphics.clear();
        this._intarfaceAction.removeChildren();
        this._intarfaceAction = null;
        this._actionTxt = null;
        this._actionArea.removeEventListener(MouseEvent.CLICK, onInputClick);
        this._actionArea = null;
        this.killBtInterface(this._actionRun, this.onRunAction);
        this._actionRun = null;
        this._txFormat = this._btFormat = this._inFormat = null;
        this._fpsHolder.removeChildren();
        this._fpsHolder.graphics.clear();
        this._fpsHolder = null;
        this._fps = null;
        this.removeOverlay('original.debug');
        this._overlay = null;
        super.kill();
    }

    /**
        Gets the plugin current movie configuration.
        @param  interf  load values from settings interface?
        @return current configuration (Dynanmic data for JSON ecnoding)
    **/
    override public function getConfig(interf:Bool = true):Dynamic {
        if (interf) {
            this._useF8 = true;//this.ui.toggles['usef8'].selected;
        }
        return ({
            usef8: this._useF8
        });
    }

    /**
        Sets the plugin current movie configuration.
        @param  to  the confguration (Dynamic object)
    **/
    override public function setConfig(to:Dynamic):Void {
        if (Reflect.hasField(to, 'usef8')) {
            this._useF8 = true;//Reflect.field(to, 'usef8');
        }
    }

    /**
        Traces the given strings.
        @param  param   the strings to trace
        @return always true
    **/
    private function acTrace(param:Array<String>):Bool {
        for (i in param) trace(this._access.parser.parseString(i));
        return (true);
    }

    /**
        Traces the string variables.
        @param  param   not used
        @return always true
    **/
    private function acTraceStrings(param:Array<String>):Bool {
        trace(Json.stringify({
            string: this._access.varString
        }));
        return (true);
    }

    /**
        Traces the float variables.
        @param  param   not used
        @return always true
    **/
    private function acTraceFloats(param:Array<String>):Bool {
        trace(Json.stringify({
            float: this._access.varFloat
        }));
        return (true);
    }

    /**
        Traces the int variables.
        @param  param   not used
        @return always true
    **/
    private function acTraceInts(param:Array<String>):Bool {
        trace(Json.stringify({
            int: this._access.varInt
        }));
        return (true);
    }

    /**
        Traces the boolean variables.
        @param  param   not used
        @return always true
    **/
    private function acTraceBools(param:Array<String>):Bool {
        trace(Json.stringify({
            bool: this._access.varBool
        }));
        return (true);
    }

    /**
        Traces the registered variables.
        @param  param   not used
        @return always true
    **/
    private function acTraceVars(param:Array<String>):Bool {
        trace(Json.stringify({
            string: this._access.varString, 
            float: this._access.varFloat, 
            int: this._access.varInt, 
            bool: this._access.varBool
        }));
        return (true);
    }

    /**
        Shows the information overlay box.
    **/
    private function acInfoShow(param:Array<String>):Bool {
        this._overlay.addChild(this._infoArea);
        return (true);
    }

    /**
        Shows the information overlay box.
    **/
    private function acInfoHide(param:Array<String>):Bool {
        if (this._infoArea.parent != null) this._overlay.removeChild(this._infoArea);
        return (true);
    }

    /**
        Sets the content of the interface information text.
    **/
    private function setInfoText():Void {
        this._infoText.htmlText = '<b>Movie:</b> ' + this.info.movieName + ' (' + this.info.movieId + ')' + '<br><b>Scene:</b> ' + this.info.sceneName + ' (' + this.info.sceneId + ')' + '<br><b>Keyframe:</b> ' + (this.info.keyframeCurrent+1) + '/' + this.info.keyframeTotal + '<br><b>Asset multiply:</b> ' + this.info.displayMultiply + '<br><b>Orientation:</b> ' + this.info.orientation + '<br><b>Screen area:</b> ';
        if (this.info.orientation == 'vertical') {
            this._infoText.htmlText += this.info.displaySmaller + 'x' + this.info.displayBigger;
        } else {
            this._infoText.htmlText += this.info.displayBigger + 'x' + this.info.displaySmaller;
        }
    }

    /**
        Sets the variables text to current values.
    **/
    private function setVarText():Void {
        this._varList.htmlText = '';
        switch (this._varType) {
            case 'float':
                for (i in this._access.varFloat.keys()) this._varList.htmlText += '<b>' + i + '</b> => ' + this._access.varFloat[i] + '<br>';
            case 'int':
                for (i in this._access.varInt.keys()) this._varList.htmlText += '<b>' + i + '</b> => ' + this._access.varInt[i] + '<br>';
            case 'bool':
                for (i in this._access.varBool.keys()) this._varList.htmlText += '<b>' + i + '</b> => ' + this._access.varBool[i] + '<br>';
            default: // string
                for (i in this._access.varString.keys()) this._varList.htmlText += '<b>' + i + '</b> => ' + this._access.varString[i] + '<br>';
        }
    }

    /**
        Creates an interface text.
        @param  txt the button label
        @param  ac  action to call on button click
        @return a reference to the button
    **/
    private function createTxInterface(multi:Bool, txt:String, px:Float, py:Float, wd:Float, ht:Float):TextField {
        var tx:TextField = new TextField();
        tx.defaultTextFormat = this._txFormat;
        tx.multiline = multi;
        tx.selectable = false;
        tx.htmlText = txt;
        tx.x = px;
        tx.y = py;
        tx.width = wd;
        tx.height = ht;
        return (tx);
    }

    /**
        Creates an interface button.
        @param  txt the button label
        @param  ac  action to call on button click
        @return a reference to the button
    **/
    private function createBtInterface(txt:String, ac:Dynamic):TextField {
        var bt:TextField = new TextField();
        bt.defaultTextFormat = this._btFormat;
        bt.background = true;
        bt.backgroundColor = 0xFFFFFF;
        bt.border = true;
        bt.borderColor = 0xFFFFFF;
        bt.width = 50;
        bt.height = 15;
        bt.text = txt;
        bt.selectable = false;
        bt.addEventListener(MouseEvent.CLICK, ac);
        return(bt);
    }

    /**
        Creates an interface input field.
        @param  wd  input width
        @return a reference to the button
    **/
    private function createInputInterface(wd:Float):TextField {
        var inp:TextField = new TextField();
        inp.type = TextFieldType.INPUT;
        inp.defaultTextFormat = this._inFormat;
        inp.background = true;
        inp.backgroundColor = 0x000000;
        inp.border = true;
        inp.borderColor = 0x000000;
        inp.width = wd;
        inp.height = 15;
        inp.text = '';
        inp.addEventListener(MouseEvent.CLICK, onInputClick);
        return(inp);
    }

    /**
        An input field was clicked.
    **/
    private function onInputClick(evt:MouseEvent):Void {
        this._infoArea.stage.focus = evt.target;
    }

    /**
        Releases resources used by a text field.
        @param  bt  the text field
        @param  ac  field click action

    **/
    private function killBtInterface(bt:TextField, ac:Dynamic):Void {
        if (ac != null) bt.removeEventListener(MouseEvent.CLICK, ac);
        bt.text = null;
        bt.htmlText = null;
        bt.defaultTextFormat = null;
    }

    /** EVENTS **/

    /**
        A movie was just loaded.
    **/
    private function onMovieLoad(evt:PluginEvent):Void {
        this.setInfoText();
        this.placeInterface();
    }

    /**
        A scene was just loaded.
    **/
    private function onSceneLoad(evt:PluginEvent):Void {
        this.setInfoText();
    }

    /**
        A keyframe was just loaded.
    **/
    private function onKeyframeLoad(evt:PluginEvent):Void {
        this.setInfoText();
    }

    /**
        The display area was just resized.
    **/
    private function onDisplayResize(evt:PluginEvent):Void {
        this.setInfoText();
        this.placeInterface();
    }

    /**
        Hides the debug interface.
    **/
    private function onInterfaceHide(evt:MouseEvent):Void {
        this.acInfoHide([]);
    }

    /**
        Cycles the debug interface.
    **/
    private function onInterfaceCycle(evt:MouseEvent):Void {
        this._intPos++;
        if (this._intPos > 3) this._intPos = 0;
        this.placeInterface();
        trace (openfl.display._internal.stats.Context3DStats.totalDrawCalls());
    }

    /**
        Shows/hides the movie load interface.
    **/
    private function onInterfaceMovie(evt:MouseEvent):Void {
        if (this._interfaceScene.parent != null) this._infoArea.removeChild(this._interfaceScene);
        if (this._interfaceVar.parent != null) this._infoArea.removeChild(this._interfaceVar);
        if (this._intarfaceAction.parent != null) this._infoArea.removeChild(this._intarfaceAction);
        if (this._interfaceMovie.parent == null) {
            this._infoArea.addChild(this._interfaceMovie);
        } else {
            this._infoArea.removeChild(this._interfaceMovie);
        }
        this.placeInterface();
    }

    /**
        Shows/hides the scene load interface.
    **/
    private function onInterfaceScene(evt:MouseEvent):Void {
        if (this._interfaceMovie.parent != null) this._infoArea.removeChild(this._interfaceMovie);
        if (this._interfaceVar.parent != null) this._infoArea.removeChild(this._interfaceVar);
        if (this._intarfaceAction.parent != null) this._infoArea.removeChild(this._intarfaceAction);
        if (this._interfaceScene.parent == null) {
            this._infoArea.addChild(this._interfaceScene);
        } else {
            this._infoArea.removeChild(this._interfaceScene);
        }
        this.placeInterface();
    }

    /**
        Shows/hides the variables interface.
    **/
    private function onInterfaceVar(evt:MouseEvent):Void {
        if (this._interfaceMovie.parent != null) this._infoArea.removeChild(this._interfaceMovie);
        if (this._interfaceScene.parent != null) this._infoArea.removeChild(this._interfaceScene);
        if (this._intarfaceAction.parent != null) this._infoArea.removeChild(this._intarfaceAction);
        if (this._interfaceVar.parent == null) {
            this.setVarText();
            this._infoArea.addChild(this._interfaceVar);
        } else {
            this._infoArea.removeChild(this._interfaceVar);
        }
        this.placeInterface();
    }

    /**
        Shows/hides the action interface.
    **/
    private function onInterfaceAction(evt:MouseEvent):Void {
        if (this._interfaceMovie.parent != null) this._infoArea.removeChild(this._interfaceMovie);
        if (this._interfaceScene.parent != null) this._infoArea.removeChild(this._interfaceScene);
        if (this._interfaceVar.parent != null) this._infoArea.removeChild(this._interfaceVar);
        if (this._intarfaceAction.parent == null) {
            this._infoArea.addChild(this._intarfaceAction);
        } else {
            this._infoArea.removeChild(this._intarfaceAction);
        }
        this.placeInterface();
    }

    /**
        Starts/stops tracing status.
    **/
    private function onInterfaceStats(evt:MouseEvent):Void {
        #if !gl_stats
            trace ('build with -D gl_stats to check out draw calls as well');
        #end
        if (this._fps == null) {
            this._fps = new FPS(5, 5, 0xFFFFFF);
            this._fpsHolder.addChild(this._fps);
            this._overlay.addChild(this._fpsHolder);
            this.placeInterface();
        } else {
            this._overlay.removeChild(this._fpsHolder);
            this._fpsHolder.removeChild(this._fps);
            this._fps = null;
        }
    }

    /**
        Loads a movie.
    **/
    private function onLoadMovie(evt:MouseEvent):Void {
        if (this._movieInput.text != '') {
            this._access.parser.run(Json.stringify({
                ac: 'movie.load', 
                param: [ this._movieInput.text ]
            }));
        }
    }

    /**
        Loads a scene.
    **/
    private function onLoadScene(evt:MouseEvent):Void {
        if (this._sceneInput.text != '') {
            this._access.parser.run(Json.stringify({
                ac: 'scene.load', 
                param: [ this._sceneInput.text ]
            }));
        }
    }

    /**
        Sets a variable value.
    **/
    private function onSetVar(evt:MouseEvent):Void {
        if (this._setVarName.text != '') {
            switch (this._varType) {
                case 'float':
                    if (this._setVarValue.text == '') {
                        if (this._access.varFloat.exists(this._access.parser.parseString(this._setVarName.text))) {
                            this._access.varFloat.remove(this._access.parser.parseString(this._setVarName.text));
                        }
                    } else {
                        this._access.varFloat[this._access.parser.parseString(this._setVarName.text)] = this._access.parser.parseFloat(this._setVarValue.text);
                    }
                case 'int':
                    if (this._setVarValue.text == '') {
                        if (this._access.varInt.exists(this._access.parser.parseString(this._setVarName.text))) {
                            this._access.varInt.remove(this._access.parser.parseString(this._setVarName.text));
                        }
                    } else {
                        this._access.varInt[this._access.parser.parseString(this._setVarName.text)] = this._access.parser.parseInt(this._setVarValue.text);
                    }
                case 'bool':
                    if (this._setVarValue.text == '') {
                        if (this._access.varBool.exists(this._access.parser.parseString(this._setVarName.text))) {
                            this._access.varBool.remove(this._access.parser.parseString(this._setVarName.text));
                        }
                    } else {
                        this._access.varBool[this._access.parser.parseString(this._setVarName.text)] = this._access.parser.parseBool(this._setVarValue.text);
                    }
                default: // string
                    if (this._setVarValue.text == '') {
                        if (this._access.varString.exists(this._access.parser.parseString(this._setVarName.text))) {
                            this._access.varString.remove(this._access.parser.parseString(this._setVarName.text));
                        }
                    } else {
                        this._access.varString[this._access.parser.parseString(this._setVarName.text)] = this._access.parser.parseString(this._setVarValue.text);
                    }   
            }
        }
        this.setVarText();
    }

    /**
        Traces a JSON with all variable values.
    **/
    private function onTraceVar(evt:MouseEvent):Void {
        trace(Json.stringify({
            string: this._access.varString, 
            float: this._access.varFloat, 
            int: this._access.varInt, 
            bool: this._access.varBool
        }));
    }

    /**
        Refreshed the var display..
    **/
    private function onRefreshVar(evt:MouseEvent):Void {
        this.setVarText();
    }

    /**
        Shows string values
    **/
    private function onSetString(evt:MouseEvent):Void {
        this._varType = 'string';
        this._varTxt.htmlText = '<b>String variables</b>';
        this._setvarTxt.htmlText = '<b>Set string value (set to empty field to remove it)</b>';
        this._setVarName.text = '';
        this._setVarValue.text = '';
        this.setVarText();
    }

    /**
        Shows float values
    **/
    private function onSetFloat(evt:MouseEvent):Void {
        this._varType = 'float';
        this._varTxt.htmlText = '<b>Float variables</b>';
        this._setvarTxt.htmlText = '<b>Set float value (set to empty field to remove it)</b>';
        this._setVarName.text = '';
        this._setVarValue.text = '';
        this.setVarText();
    }

    /**
        Shows int values
    **/
    private function onSetInt(evt:MouseEvent):Void {
        this._varType = 'int';
        this._varTxt.htmlText = '<b>Int variables</b>';
        this._setvarTxt.htmlText = '<b>Set int value (set to empty field to remove it)</b>';
        this._setVarName.text = '';
        this._setVarValue.text = '';
        this.setVarText();
    }

    /**
        Shows boolean values
    **/
    private function onSetBool(evt:MouseEvent):Void {
        this._varType = 'bool';
        this._varTxt.htmlText = '<b>Bool variables</b>';
        this._setvarTxt.htmlText = '<b>Set bool value (set to empty field to remove it)</b>';
        this._setVarName.text = '';
        this._setVarValue.text = '';
        this.setVarText();
    }

    /**
        Runs a custom action.
    **/
    private function onRunAction(evt:MouseEvent):Void {
        if (this._actionArea.text != '') this._access.parser.run(this._actionArea.text);
    }

    /**
        Places the interface window.
    **/
    private function placeInterface():Void {
        switch (this._intPos) {
            case 0:
                this._infoArea.x = 10;
                this._infoArea.y = 10;
                if (this.info.orientation == 'vertical') {
                    this._fpsHolder.x = 10;
                    #if !gl_stats
                        this._fpsHolder.y = this.info.displayBigger - 30 - 10;
                    #else
                        this._fpsHolder.y = this.info.displayBigger - 75 - 10;
                    #end
                } else {
                    this._fpsHolder.x = 10;
                    #if !gl_stats
                        this._fpsHolder.y = this.info.displaySmaller - 30 - 10;
                    #else 
                    this._fpsHolder.y = this.info.displaySmaller - 75 - 10;
                    #end
                }
            case 1:
                if (this.info.orientation == 'vertical') {
                    this._infoArea.x = this.info.displaySmaller - this._infoArea.width - 10;
                    this._infoArea.y = 10;
                } else {
                    this._infoArea.x = this.info.displayBigger - this._infoArea.width - 10;
                    this._infoArea.y = 10;
                }
                this._fpsHolder.x = 10;
                this._fpsHolder.y = 10;
            case 2:
                if (this.info.orientation == 'vertical') {
                    this._infoArea.x = this.info.displaySmaller - this._infoArea.width - 10;
                    this._infoArea.y = this.info.displayBigger - this._infoArea.height - 10;
                    #if !gl_stats
                        this._fpsHolder.x = this.info.displaySmaller - 65 - 10;
                    #else 
                    this._fpsHolder.x = this.info.displaySmaller - 100 - 10;
                    #end
                    this._fpsHolder.y = 10;
                } else {
                    this._infoArea.x = this.info.displayBigger - this._infoArea.width - 10;
                    this._infoArea.y = this.info.displaySmaller - this._infoArea.height - 10;
                    #if !gl_stats
                        this._fpsHolder.x = this.info.displayBigger - 65 - 10;
                    #else 
                    this._fpsHolder.x = this.info.displayBigger - 100 - 10;
                    #end
                    this._fpsHolder.y = 10;
                }
            case 3:
                if (this.info.orientation == 'vertical') {
                    this._infoArea.x = 10;
                    this._infoArea.y = this.info.displayBigger - this._infoArea.height - 10;
                    #if !gl_stats
                        this._fpsHolder.x = this.info.displaySmaller - 65 - 10;
                        this._fpsHolder.y = this.info.displayBigger - 30 - 10;
                    #else 
                        this._fpsHolder.x = this.info.displaySmaller - 100 - 10;
                        this._fpsHolder.y = this.info.displayBigger - 75 - 10;
                    #end
                } else {
                    this._infoArea.x = 10;
                    this._infoArea.y = this.info.displaySmaller - this._infoArea.height - 10;
                    #if !gl_stats
                        this._fpsHolder.x = this.info.displayBigger - 65 - 10;
                        this._fpsHolder.y = this.info.displaySmaller - 30 - 10;
                    #else 
                        this._fpsHolder.x = this.info.displayBigger - 100 - 10;
                        this._fpsHolder.y = this.info.displaySmaller - 75 - 10;
                    #end
                }
        }
    }

}