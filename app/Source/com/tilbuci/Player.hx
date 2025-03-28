/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci;

/** HAXE **/
import com.tilbuci.statictools.StringStatic;
import openfl.geom.Point;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import feathers.controls.ToggleSwitch;
import feathers.controls.NumericStepper;
import feathers.controls.TextInput;
import com.tilbuci.font.EmbedFont;
import com.tilbuci.font.EmbedFont.FontInfo;
import haxe.Timer;
import haxe.io.Bytes;

/** OPENFL **/
import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.text.StyleSheet;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.display.Stage;

/** FEATHERS UI **/
import feathers.style.Theme;
import feathers.controls.LayoutGroup;
import feathers.controls.Header;
import feathers.style.IStyleProvider;
import feathers.controls.Panel;
import feathers.layout.AnchorLayout;
import feathers.controls.Label;
import feathers.layout.AnchorLayoutData;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.ui.PlayerTheme;
import com.tilbuci.player.MovieArea;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.BuildInfo;
import com.tilbuci.data.DataLoader;
import com.tilbuci.ws.WebserviceP;
import com.tilbuci.data.Language;
import com.tilbuci.data.MovieInfo;
import com.tilbuci.script.ScriptParser;
import com.tilbuci.plugin.Plugin;
import com.tilbuci.plugin.PluginAccess;
import com.tilbuci.event.TilBuciEvent;
#if (js && html5)
    import com.tilbuci.js.ExternBrowser;
#end

/**
    The Tilbuci player.
**/
class Player extends Sprite {
    
    /** CONSTANTS **/

    /**
        screen oriantation: landscape
    **/
    public static inline var ORIENTATION_LANDSCAPE:String = 'landscape';

    /**
        screen oriantation: portrait
    **/
    public static inline var ORIENTATION_PORTRAIT:String = 'portrait';

    /**
        player mode: playing content
    **/
    public static inline var MODE_PLAYER:String = 'player';

    /**
        player mode: creating content
    **/
    public static inline var MODE_EDITOR:String = 'editor';

    /**
        player mode: just coming from editor and waiting for the first "play" command
    **/
    public static inline var MODE_EDPLAYERWAIT:String = 'editorplayerwait';

    /**
        player mode: playing while creating content
    **/
    public static inline var MODE_EDPLAYER:String = 'editorplayer';

    /** VARIABLES **/

    /**
        real width in pixels
    **/
    public var rWidth(get, null):Float;
    private var _rWidth:Float = 0;
    private function get_rWidth():Float { return (this._rWidth); }

    /**
        real height in pixels
    **/
    public var rHeight(get, null):Float;
    private var _rHeight:Float = 0;
    private function get_rHeight():Float { return (this._rHeight); }

    public var tHeight(get, null):Float;
    private function get_tHeight():Float {
        GlobalPlayer.area.setOverlay(false);
        this.removeChild(this._uiArea);
        var ht:Float = this.height;
        GlobalPlayer.area.setOverlay(true);
        this.addChild(this._uiArea);
        return (ht);
    }

    /**
        movie width
    **/
    public var mWidth(get, null):Float;
    private function get_mWidth():Float { return (GlobalPlayer.area.aWidth); }

    /**
        movie height
    **/
    public var mHeight(get, null):Float;
    private function get_mHeight():Float { return (GlobalPlayer.area.aHeight); }

    /**
        global background
    **/
    private var _bgarea:Sprite;

    /**
        first movie loaded?
    **/
    private var _firstMovie:Bool = false;

    /**
        last movie ID loaded
    **/
    private var _lastMovie:String = '';

    /**
        first scene loaded?
    **/
    private var _firstScene:Bool = false;

    /**
        display object
    **/
    private var _display:Sprite;

    /**
        display mask
    **/
    private var _mask:Shape;

    /**
        display background
    **/
    private var _background:Shape;

    /**
        screen orientation
    **/
    private var _scrOrient:String;

    /**
        frames counted since last second
    **/
    private var _frames:Int = 0;

    /**
        timer for fps count
    **/
    private var _frameTimer:Timer;

    /**
        timer to start fps count
    **/
    private var _fpsStart:Timer;

    /**
        user interface area
    **/
    private var _uiArea:Sprite;

    /**
        input elements area
    **/
    public var inputArea:Sprite = null;

    /**
        text inputs
    **/
    private var _inputs:Map<String, TextInput> = [ ];

    /**
        numeric inputs
    **/
    private var _numerics:Map<String, NumericStepper> = [ ];

    /**
        toggle inputs
    **/
    private var _toggles:Map<String, ToggleSwitch> = [ ];

    /**
        touch start position
    **/
    private var _touchStart:Point = new Point();

    /**
        touch start time
    **/
    private var _touchStartTime:Float = 0;

    /**
        tomer to end touch event
    **/
    private var _touchTimer:Timer;

    /**
        last tme a mouse wheel move was detected
    **/
    private var _lastmwheel:Float = 0.0;

    /**
        Constructor.
        @param  path    path to the configuration file
        @param  mode    player mode
        @param  sOrient current display orientation
        @param  nocache add GET param to request to avoid cached data?
        @param  callback    callback function for events
    **/
    public function new(path:String = null, mode:String = null, sOrient:String = null, nocache:Bool = true, callback:Dynamic = null) {
        super();

        // session identifier
        GlobalPlayer.session = DateTools.format(Date.now(), "%Y-%m-%d_%H:%M:%S") + '_' + StringStatic.random();
        GlobalPlayer.session = GlobalPlayer.session.substr(0, 32);

        // adjust values
        if (sOrient == null) sOrient = Player.ORIENTATION_LANDSCAPE;
        if (mode == null) mode = Player.MODE_PLAYER;

        // setting values
        this.setMode(mode);
        GlobalPlayer.build = new BuildInfo((mode == Player.MODE_PLAYER) && (path != null));
        GlobalPlayer.nocache = nocache;
        GlobalPlayer.callback = callback;
        
        // load configuration
        if (path == null) {
            GlobalPlayer.nocache = nocache = false;
            this.onPlayerConf(true, null, true);
        } else {
            var cache:Map<String, Dynamic> = null;
            if (nocache) cache = [ 'rand' => Math.ceil(Math.random()*10000) ];
            new DataLoader(true, path, 'GET', cache, DataLoader.MODEMAP, onPlayerConf);
        }

        // keyboard listen
        if (this.stage == null) {
            this.addEventListener(Event.ADDED_TO_STAGE, onStage);
        } else {
            this.onStage(null);
        }
    }

    /**
        Sets the current player mode.
        @param  md  the new mode (player/editor)
    **/
    public function setMode(md:String):Void {
        if (md == Player.MODE_EDITOR) {
            GlobalPlayer.mode = Player.MODE_EDITOR;
        } else {
            GlobalPlayer.mode = Player.MODE_PLAYER;
        }
    }

    /**
        Sets the player real size in pixels.
        @param  w   width
        @param  h   height
    **/
    public function setSize(w:Float, h:Float):Void {
        this._rWidth = w;
        this._rHeight = h;
        if (GlobalPlayer.area != null) GlobalPlayer.area.setArea();
    }

    /**
        Loads a movie folder.
        @param  path    path to the movie folder
    **/
    public function load(path:String):Void {
        this._lastMovie = GlobalPlayer.movie.mvId;
        this._firstScene = true;
        GlobalPlayer.movie.loadMovie(path);
    }

    /**
        Registers a plugin.
        @param  obj the plugin object
    **/
    public function registerPlugin(obj:Plugin):Void {
        // save plugin
        GlobalPlayer.plugins[obj.plname] = obj;
        // system already running?
        if (GlobalPlayer.ready) this.initializePlugins();
    }

    /**
        Removes a registered plugin.
        @param  name    the plugin unique name
        @return was the plugin found and removed?
    **/
    public function removePlugin(name:String):Bool {
        if (GlobalPlayer.plugins.exists(name)) {
            GlobalPlayer.plugins[name].kill();
            GlobalPlayer.plugins.remove(name);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Initializes the available plugins.
    **/
    private function initializePlugins():Void {
        for (pl in GlobalPlayer.plugins) {
            if (!pl.ready) pl.initialize(new PluginAccess(
                GlobalPlayer.parser.getVarRef('string'), 
                GlobalPlayer.parser.getVarRef('float'), 
                GlobalPlayer.parser.getVarRef('int'), 
                GlobalPlayer.parser.getVarRef('bool'), 
                GlobalPlayer.parser
            ));
        }
    }

    /** PRIVATE METHODS **/

    /**
        Halts system.
        @param  cause   the halt cause
    **/
    private function halt(cause:String):Void {
        this.removeChildren();
        var msg:String = 'System down :-(';
        switch (cause) {
            case 'noconf':
                msg = 'Error while loading the basic system configuration.';
            case 'language':
                msg = 'Error while loading the default language file.';
            case 'nomovie':
                msg = GlobalPlayer.ln.get('player-nomovie');
            case 'noscene':
                msg = GlobalPlayer.ln.get('player-noscene');
        }
        // show halt message
        var popup:Panel = new Panel();
		popup.layout = new AnchorLayout();
		popup.setPadding(10);
        var message = new Label();
        message.text = msg;
        message.layoutData = AnchorLayoutData.center();
        popup.addChild(message);
        PopUpManager.addPopUp(popup, this);
    }

    /**
        Initial player configuration loaded.
        @param  ok  configuraiton really loaded?
        @param  ld  loader information
        @param  local   running local?
    **/
    private function onPlayerConf(ok:Bool, ld:DataLoader, local:Bool = false):Void {
        if (local) {
            GlobalPlayer.ln = new Language();
            GlobalPlayer.base = './';
            GlobalPlayer.font = './font/';
            GlobalPlayer.render = 'webgl';
            #if runtimewebsite
                GlobalPlayer.share = 'website';
            #else
                GlobalPlayer.share = 'never';
            #end
            GlobalPlayer.fps = 'free';
            GlobalPlayer.secret = Bytes.ofHex('');
            if (Reflect.hasField(Main, 'ws') && (Reflect.field(Main, 'ws') != '')) {
                GlobalPlayer.ws = new WebserviceP(Reflect.field(Main, 'ws'), '');
                GlobalPlayer.server = true;
            } else {
                GlobalPlayer.ws = new WebserviceP('./ws/', '');
                GlobalPlayer.server = false;
            }
            GlobalPlayer.movie = new MovieInfo(this.onMovie, this.onScene);
            GlobalPlayer.parser = new ScriptParser();
            GlobalPlayer.parser.eventSend = this.warnListeners;
            GlobalPlayer.ready = true;
            // creating the display area
            this._bgarea = new Sprite();
            if (GlobalPlayer.mode != Player.MODE_EDITOR) this.addChild(this._bgarea);
            this._uiArea = new Sprite();
            GlobalPlayer.area = new MovieArea(this, this._bgarea, this._uiArea);
            this.addChild(GlobalPlayer.area);
            this.addChild(this._uiArea);
            // initialialize plugins
            this.initializePlugins();
            // loading initial movie?
            if (GlobalPlayer.mode == Player.MODE_PLAYER) {
                this._firstMovie = true;
                this._firstScene = true;
            }
        } else if (!ok) {
            this.halt('noconf');
        } else {
            // loading language file
            GlobalPlayer.ln = new Language();
            if (GlobalPlayer.ln.ok) {
                // getting values
                GlobalPlayer.server = ld.map['server'];
                GlobalPlayer.base = ld.map['base'];
                GlobalPlayer.font = ld.map['font'];
                GlobalPlayer.render = ld.map['render'];
                GlobalPlayer.share = ld.map['share'];
                GlobalPlayer.fps = ld.map['fps'];
                GlobalPlayer.secret = Bytes.ofHex(ld.map['secret']);
                GlobalPlayer.ws = new WebserviceP(ld.map['ws'], '');
                GlobalPlayer.movie = new MovieInfo(this.onMovie, this.onScene);
                GlobalPlayer.parser = new ScriptParser();
                GlobalPlayer.parser.eventSend = this.warnListeners;
                if (GlobalPlayer.mode == Player.MODE_PLAYER) {
                    if (ld.map.exists('systemfonts')) {
                        var sysfonts:Array<FontInfo> = ld.map['systemfonts'];
                        for (i in 0...sysfonts.length) {
                            new EmbedFont((GlobalPlayer.font + sysfonts[i].file), sysfonts[i].name);
                        }
                    }
                }
                GlobalPlayer.ready = true;
                // creating the display area
                this._bgarea = new Sprite();
                if (GlobalPlayer.mode != Player.MODE_EDITOR) this.addChild(this._bgarea);
                this._uiArea = new Sprite();
                GlobalPlayer.area = new MovieArea(this, this._bgarea, this._uiArea);
                this.addChild(GlobalPlayer.area);
                this.addChild(this._uiArea);
                // initialialize plugins
                this.initializePlugins();
                // loading initial movie?
                if (GlobalPlayer.mode == Player.MODE_PLAYER) {
                    this._firstMovie = true;
                    this._firstScene = true;
                    var mainMovie:String = '';
                    if (Reflect.hasField(Main, 'movie')) mainMovie = Reflect.field(Main, 'movie');
                    if (mainMovie == '') {
                        this.load(ld.map['start']);
                    } else {
                        this.load(mainMovie);
                        if (Reflect.hasField(Main, 'movie')) {
                            Reflect.setField(Main, 'movie', '');
                        }
                    }
                }
                // set fps
                if ((GlobalPlayer.fps != 'free') && (GlobalPlayer.fps != 'calc')) {
                    var fps:Int = Std.parseInt(GlobalPlayer.fps);
                    this.stage.window.frameRate = fps;
                }
            } else {
                // default language must be loaded to continue
                this.halt('language');
            }
        }
    }
    
    /**
        A new movie was loaded.
        @param  ok  successful load?
    **/
    private function onMovie(ok:Bool):Void {
        // first movie?
        if ((GlobalPlayer.mode == Player.MODE_PLAYER) && !ok) {
            if (this._firstMovie) {
                this.halt('nomovie');
            } else {
                if (this._lastMovie != '') {
                    this._firstMovie = true;
                    this.load(this._lastMovie);
                } else {
                    this.halt('nomovie');
                }
            }
        } else if (ok) {
            // draw movie area
            GlobalPlayer.area.setArea();
            // secret key
            if ((GlobalPlayer.mdata.key != '') && (GlobalPlayer.mode == Player.MODE_PLAYER)) {
                if (GlobalPlayer.mdata.key != GlobalPlayer.secretKey) {
                    var msg:String = 'Please type the access key.';
                    if (GlobalPlayer.mdata.texts.exists('secretkey')) msg = GlobalPlayer.mdata.texts['secretkey'];
                    GlobalPlayer.area.showSecretKeyInput(msg);
                }
            }
            // movie start actions
            if (GlobalPlayer.mode == Player.MODE_PLAYER) if (GlobalPlayer.movie.data.acstart != '') GlobalPlayer.parser.run(GlobalPlayer.movie.data.acstart);
            // warn plugins
            //if (GlobalPlayer.mode == Player.MODE_PLAYER) for (p in GlobalPlayer.plugins) {
            if (true) for (p in GlobalPlayer.plugins) {
                if (p.active && p.ready) p.info.onNewMovie(GlobalPlayer.mdata.title, GlobalPlayer.movie.mvId, GlobalPlayer.mdata.screen.big, GlobalPlayer.mdata.screen.small);
            }
            // callback
            if (GlobalPlayer.callback != null) {
                GlobalPlayer.callback('movieload', ['id' => GlobalPlayer.movie.mvId]);
            }
            // event
            this.dispatchEvent(new TilBuciEvent(TilBuciEvent.MOVIE_LOADED, [
                'id' => GlobalPlayer.movie.mvId, 
                'title' => GlobalPlayer.mdata.title
            ]));
        }
    }

    /**
        A new scene was loaded.
        @param  ok  successful load?
    **/
    private function onScene(ok:Bool):Void {
        if ((GlobalPlayer.mode == Player.MODE_PLAYER) && !ok && this._firstScene) {
            this.halt('noscene');
        } else {
            this._firstMovie = false;
            this._firstScene = false;
        }

        // hide mouse over
        GlobalPlayer.area.noMouseOver();

        // warn plugins
        for (p in GlobalPlayer.plugins) {
            if (p.active && p.ready) p.info.onNewScene(GlobalPlayer.movie.scene.title, GlobalPlayer.movie.scId, GlobalPlayer.movie.scene.keyframes.length);
        }

        // browser title/url
        #if (js && html5)
            if (GlobalPlayer.mode == Player.MODE_PLAYER) {
                if (GlobalPlayer.share == 'scene') {
                    ExternBrowser.TBB_setAddress(
                        (GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId + '&sc=' + GlobalPlayer.movie.scId), 
                        (GlobalPlayer.mdata.title + ' > ' + GlobalPlayer.movie.scene.title)
                    );
                } else if (GlobalPlayer.share == 'movie') {
                    ExternBrowser.TBB_setAddress(
                        (GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId), 
                        (GlobalPlayer.mdata.title)
                    );
                } else if (GlobalPlayer.share == 'website') {
                    if (GlobalPlayer.mdata.start == GlobalPlayer.movie.scId) {
                        ExternBrowser.TBB_setAddress(
                            (GlobalPlayer.base), 
                            (GlobalPlayer.mdata.title)
                        );
                    } else {
                        ExternBrowser.TBB_setAddress(
                            (GlobalPlayer.base + GlobalPlayer.movie.scId + '.html'), 
                            (GlobalPlayer.mdata.title)
                        );
                    }
                }
            }
        #end

        // display scene
        GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[0], 0);

        // scene start actions
        if (GlobalPlayer.movie.scene.acstart != '') GlobalPlayer.parser.run(GlobalPlayer.movie.scene.acstart);

        // start counting fps
        if ((GlobalPlayer.mode == Player.MODE_PLAYER) && (GlobalPlayer.fps == 'calc')) {
            if (this._frameTimer != null) {
                try { this._frameTimer.stop(); } catch (e) { }
                this._frameTimer = null;
            }
            this._fpsStart = new Timer(2000);
            this._fpsStart.run = this.fpsCount;
        }

        // callback
        if (GlobalPlayer.callback != null) {
            GlobalPlayer.callback('sceneload', ['id' => GlobalPlayer.movie.scId]);
        }

        // event
        this.dispatchEvent(new TilBuciEvent(TilBuciEvent.SCENE_LOADED, [
            'id' => GlobalPlayer.movie.scId, 
            'title' => GlobalPlayer.movie.scene.title
        ]));
    }

    /**
        Starts the fps count routine.
    **/
    private function fpsCount():Void {
        if ((GlobalPlayer.mode == Player.MODE_PLAYER) && (GlobalPlayer.fps == 'calc')) {
            if (this._fpsStart != null) {
                try { this._fpsStart.stop(); } catch (e) { }
                this._fpsStart = null;
            }
            if (this.stage.hasEventListener(Event.ENTER_FRAME)) this.removeEventListener(Event.ENTER_FRAME, onFrame);
            if (this._fpsStart != null) {
                try { this._fpsStart.stop(); } catch (e) { }
                this._fpsStart = null;
            }
            if (this.stage != null) {
                this.stage.window.frameRate = 80;
                this._frames = 0;
                this.addEventListener(Event.ENTER_FRAME, this.onFrame);
                this._frameTimer = new Timer(2000);
                this._frameTimer.run = function() {
                    try { this._frameTimer.stop(); } catch (e) { }
                    this._frameTimer = null;
                    if (this.stage.hasEventListener(Event.ENTER_FRAME)) this.removeEventListener(Event.ENTER_FRAME, this.onFrame);
                    var sum:Int = Math.round(this._frames/2);
                    if (sum <= 29) {
                        this.stage.window.frameRate = 20;
                    } else if (sum <= 39) {
                        this.stage.window.frameRate = 30;
                    } else if (sum <= 49) {
                        this.stage.window.frameRate = 40;
                    } else if (sum <= 59) {
                        this.stage.window.frameRate = 50;
                    } else {
                        this.stage.window.frameRate = 60;
                    }
                }
            }
        } else if (GlobalPlayer.fps != 'free') {
            var fps:Int = Std.parseInt(GlobalPlayer.fps);
            this.stage.window.frameRate = fps;
        }
    }

    /**
        New frame on fps counting.
    **/
    private function onFrame(e:Event):Void {
        this._frames++;
    }

    /**
        Player add to the stage.
    **/
    private function onStage(evt:Event):Void {
        if (this.hasEventListener(Event.ADDED_TO_STAGE)) this.removeEventListener(Event.ADDED_TO_STAGE, onStage);
        if (GlobalPlayer.mode == Player.MODE_PLAYER) {
            this.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
            this.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
            this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboard);
            this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            this.stage.addEventListener(MouseEvent.MIDDLE_CLICK, onMouseMiddle);
            this.stage.addEventListener(MouseEvent.RIGHT_CLICK, onMouseRight);
            this.stage.addEventListener(MouseEvent.CLICK, onLeftClick);
        }
    }

    private function onTouchBegin(evt:TouchEvent):Void {
        this._touchStart.x = evt.stageX;
        this._touchStart.y = evt.stageY;
        this._touchStartTime = Date.now().getTime();
    }

    private function onTouchEnd(evt:TouchEvent):Void {
        if ((Date.now().getTime() - this._touchStartTime) < 300) {
            var difx:Float = this._touchStart.x - evt.stageX;
            var dify:Float = this._touchStart.y - evt.stageY;
            if (Math.abs(difx) > Math.abs(dify)) {
                if (Math.abs(difx) > (this.stage.stageWidth / 15)) {
                    GlobalPlayer.canTrigger = false;
                    if (difx > 0) {
                        GlobalPlayer.parser.runInput('swiperight');
                    } else {
                        GlobalPlayer.parser.runInput('swipeleft');
                    }
                    if (this._touchTimer != null) {
                        try { this._touchTimer.stop(); } catch (e) { }
                        this._touchTimer = null;
                    }
                    this._touchTimer = new Timer(300);
                    this._touchTimer.run = this.endTouch;
                }
            } else {
                if (Math.abs(dify) > (this.stage.stageHeight / 15)) {
                    GlobalPlayer.canTrigger = false;
                    if (dify > 0) {
                        GlobalPlayer.parser.runInput('swipebottom');
                    } else {
                        GlobalPlayer.parser.runInput('swipetop');
                    }
                    if (this._touchTimer != null) {
                        try { this._touchTimer.stop(); } catch (e) { }
                        this._touchTimer = null;
                    }
                    this._touchTimer = new Timer(300);
                    this._touchTimer.run = this.endTouch;
                }
            }
        }
    }

    /**
        Finishing a touch event.
    **/
    private function endTouch():Void {
        if (this._touchTimer != null) {
            try { this._touchTimer.stop(); } catch (e) { }
            this._touchTimer = null;
        }
        GlobalPlayer.canTrigger = true;
    }

    /**
        A key was pressed.
    **/
    private function onKeyboard(evt:KeyboardEvent):Void {
        if (this.stage.focus is Stage) {
            var found:Bool = GlobalPlayer.parser.checkKeyboard(evt.keyCode);
            if (!found) {
                for (p in GlobalPlayer.plugins) {
                    if (p.active && !found) found = p.checkKeyboard(evt.keyCode);
                }
            }
        }
    }

    /**
        Mouse wheel moved.
    **/
    private function onMouseWheel(evt:MouseEvent):Void {
        if (this.stage.focus is Stage) {
            if (this._lastmwheel < (Date.now().getTime() - 750)) {
                this._lastmwheel = Date.now().getTime();
                if (evt.delta < 0) {
                    GlobalPlayer.parser.checkMouse('mousewheeldown');
                } else if (evt.delta > 0) {
                    GlobalPlayer.parser.checkMouse('mousewheelup');
                }
            }
        }
    }

    /**
        Mouse middle click.
    **/
    private function onMouseMiddle(evt:MouseEvent):Void {
        if (this.stage.focus is Stage) {
            GlobalPlayer.parser.checkMouse('mousemiddle');
            GlobalPlayer.parser.hadInteraction = true;
        }
    }

    /**
        Mouse right click.
    **/
    private function onMouseRight(evt:MouseEvent):Void {
        this.stage.showDefaultContextMenu = true;
        if (this.stage.focus is Stage) {
            if (GlobalPlayer.parser.checkMouse('mouseright')) {
                this.stage.showDefaultContextMenu = false;
                GlobalPlayer.parser.hadInteraction = true;
            }
        }
    }

    /**
        Mouse left click.
    **/
    private function onLeftClick(evt:MouseEvent):Void {
        this.stage.removeEventListener(MouseEvent.CLICK, onLeftClick);
        GlobalPlayer.parser.hadInteraction = true;
    }

    /**
        Warns listenters with a custom event.
        @param  data    custom event information
    **/
    private function warnListeners(data:Map<String, String>):Void {
        // event
        this.dispatchEvent(new TilBuciEvent(TilBuciEvent.EVENT, data));
        // callback
        if (GlobalPlayer.callback != null) {
            GlobalPlayer.callback('custom', data);
        }
    }

    /**
        Retrieves a string variable value.
        @param  name    the variable name
        @return the current value or empty string if not set
    **/
    public function getStringValue(name:String):String {
        return (GlobalPlayer.parser.getString(name));
    }

    /**
        Retrieves a float variable value.
        @param  name    the variable name
        @return the current value or 0.0 if not set
    **/
    public function getFloatValue(name:String):Float {
        return (GlobalPlayer.parser.getFloat(name));
    }

    /**
        Retrieves an int variable value.
        @param  name    the variable name
        @return the current value or 0 if not set
    **/
    public function getIntValue(name:String):Int {
        return (GlobalPlayer.parser.getInt(name));
    }

    /**
        Retrieves a boolean variable value.
        @param  name    the variable name
        @return the current value or false if not set
    **/
    public function getBoolValue(name:String):Bool {
        return (GlobalPlayer.parser.getBool(name));
    }

    /**
        Runs a JSON-formatted action description.
        @param  ac  json-encoded action string
        @return were the action completed?
    **/
    public function runAction(ac:String):Bool {
        return (GlobalPlayer.parser.run(ac));
    }

    /**
        Adds a text input.
        @param  name    the input name
        @param  px  x position
        @param  py  y position
        @param  width   input width
        @param  placeholder placeholder text
    **/
    public function addInput(name:String, px:Float, py:Float, width:Float, placeholder:String = ''):Void {
        if (this.inputArea != null) {
            if (!this._inputs.exists(name)) {
                this._inputs[name] = new TextInput();
                if (placeholder != '') this._inputs[name].prompt = placeholder;
                this.inputArea.addChild(this._inputs[name]);
            }
            this.placeInput(name, px, py, width);
        }   
    }

    /**
        Places an existing text input.
        @param  name    the input name
        @param  px  x position
        @param  py  y position
        @param  width   input width
    **/
    public function placeInput(name:String, px:Float, py:Float, width:Float):Void {
        if (this.inputArea != null) {
            if (this._inputs.exists(name)) {
                this._inputs[name].x = px;
                this._inputs[name].y = py;
                this._inputs[name].width = width;
            }
        }
    }

    /**
        Removes a text input.
        @param  name    the input name
    **/
    public function removeInput(name:String):Void {
        if (this.inputArea != null) {
            if (this._inputs.exists(name)) {
                this.inputArea.removeChild(this._inputs[name]);
                this._inputs.remove(name);
            }
        }
    }

    /**
        Removes all text inputs.
    **/
    public function removeAllInputs():Void {
        if (this.inputArea != null) {
            for (k in this._inputs.keys()) this.removeInput(k);
        }
    }

    /**
        Gets a text input current value.
        @param  name    the input name
    **/
    public function getInputText(name:String):String {
        if (this._inputs.exists(name)) {
            return (this._inputs[name].text);
        } else {
            return ('');
        }
    }

    /**
        Sets a text input value.
        @param  name    the input name
        @param  value   the new text
    **/
    public function setInputText(name:String, value:String):Void {
        if (this._inputs.exists(name)) {
            this._inputs[name].text = value;
        }
    }

    /**
        Sets an input password mask display.
        @param  name    the input name
        @param  pass    show as password?
    **/
    public function setInputPassword(name:String, pass:Bool):Void {
        if (this._inputs.exists(name)) {
            this._inputs[name].displayAsPassword = pass;
        }
    }

    /**
        Adds a numeric input.
        @param  name    the input name
        @param  value   inicial value
        @param  minimum stepper minimum
        @param  maximum stepper maximum
        @param  step    stepper increase
    **/
    public function addNumeric(name:String, value:Int, minimum:Int, maximum:Int, step:Int):Void {
        if (this.inputArea != null) {
            if (!this._numerics.exists(name)) {
                this._numerics[name] = new NumericStepper(value, minimum, maximum);
                this._numerics[name].step = step;
                this._numerics[name].value = value;
                this.inputArea.addChild(this._numerics[name]);
            }
        }   
    }

    /**
        Places an existing numeric input.
        @param  name    the input name
        @param  px  x position
        @param  py  y position
        @param  width   input width
    **/
    public function placeNumeric(name:String, px:Float, py:Float, width:Float):Void {
        if (this.inputArea != null) {
            if (this._numerics.exists(name)) {
                this._numerics[name].x = px;
                this._numerics[name].y = py;
                this._numerics[name].width = width;
            }
        }
    }

    /**
        Removes a numeric input.
        @param  name    the input name
    **/
    public function removeNumeric(name:String):Void {
        if (this.inputArea != null) {
            if (this._numerics.exists(name)) {
                this.inputArea.removeChild(this._numerics[name]);
                this._numerics.remove(name);
            }
        }
    }

    /**
        Removes all numeric inputs.
    **/
    public function removeAllNumerics():Void {
        if (this.inputArea != null) {
            for (k in this._numerics.keys()) this.removeNumeric(k);
        }
    }

    /**
        Gets a numeric input current value.
        @param  name    the input name
    **/
    public function getNumericValue(name:String):Int {
        if (this._numerics.exists(name)) {
            return (Math.round(this._numerics[name].value));
        } else {
            return (0);
        }
    }

    /**
        Sets a numeric input value.
        @param  name    the input name
        @param  value   the new value
    **/
    public function setNumericValue(name:String, value:Int):Void {
        if (this._numerics.exists(name)) {
            this._numerics[name].value = value;
        }
    }

    /**
        Sets a numeric input bounds.
        @param  name    the input name
        @param  minimum stepper minimum
        @param  maximum stepper maximum
        @param  step    stepper increase
    **/
    public function setNumericBounds(name:String, minimum:Int, maximum:Int, step:Int):Void {
        if (this._numerics.exists(name)) {
            this._numerics[name].minimum = minimum;
            this._numerics[name].maximum = maximum;
            this._numerics[name].step = step;
        }
    }

    /**
        Adds a toggle input.
        @param  name    the input name
        @param  value   the toggle value
        @param  px  x position
        @param  py  y position
    **/
    public function addToggle(name:String, value:Bool, px:Float, py:Float):Void {
        if (this.inputArea != null) {
            if (!this._toggles.exists(name)) {
                this._toggles[name] = new ToggleSwitch(value);
                this.inputArea.addChild(this._toggles[name]);
            }
            this.placeToggle(name, px, py);
        }   
    }

    /**
        Places an existing toggle input.
        @param  name    the input name
        @param  px  x position
        @param  py  y position
    **/
    public function placeToggle(name:String, px:Float, py:Float):Void {
        if (this.inputArea != null) {
            if (this._toggles.exists(name)) {
                this._toggles[name].x = px;
                this._toggles[name].y = py;
            }
        }
    }

    /**
        Removes a toggle input.
        @param  name    the input name
    **/
    public function removeToggle(name:String):Void {
        if (this.inputArea != null) {
            if (this._toggles.exists(name)) {
                this.inputArea.removeChild(this._toggles[name]);
                this._toggles.remove(name);
            }
        }
    }

    /**
        Removes all toggle inputs.
    **/
    public function removeAllToggles():Void {
        if (this.inputArea != null) {
            for (k in this._toggles.keys()) this.removeToggle(k);
        }
    }

    /**
        Gets a toggle input current value.
        @param  name    the input name
    **/
    public function getToggleValue(name:String):Bool {
        if (this._toggles.exists(name)) {
            return (this._toggles[name].selected);
        } else {
            return (false);
        }
    }

    /**
        Sets a toggle input value.
        @param  name    the input name
        @param  value   the new text
    **/
    public function setToggleValue(name:String, value:Bool):Void {
        if (this._toggles.exists(name)) {
            this._toggles[name].selected = value;
        }
    }

    /**
        Inverts a toggle input value.
        @param  name    the input name
    **/
    public function invertToggle(name:String):Void {
        if (this._toggles.exists(name)) {
            this._toggles[name].selected = !this._toggles[name].selected;
        }
    }
}