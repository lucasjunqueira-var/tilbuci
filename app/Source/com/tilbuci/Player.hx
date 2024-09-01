package com.tilbuci;

/** HAXE **/
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
        Constructor.
        @param  path    path to the configuration file
        @param  mode    player mode
        @param  sOrient current display orientation
        @param  nocache add GET param to request to avoid cached data?
        @param  callback    callback function for events
    **/
    public function new(path:String = null, mode:String = null, sOrient:String = null, nocache:Bool = true, callback:Dynamic = null) {
        super();

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
            GlobalPlayer.share = 'never';
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

        // scene start actions
        if (GlobalPlayer.movie.scene.acstart != '') GlobalPlayer.parser.run(GlobalPlayer.movie.scene.acstart);

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
                }
            }
        #end

        // display scene
        GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[0], 0);

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
        if (GlobalPlayer.mode == Player.MODE_PLAYER) this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboard);
    }

    /**
        A key was pressed.
    **/
    private function onKeyboard(evt:KeyboardEvent):Void {
        var found:Bool = false;
        switch (evt.keyCode) {
            default:
                found = false;
        }
        if (!found) {
            for (p in GlobalPlayer.plugins) {
                if (p.active && !found) found = p.checkKeyboard(evt.keyCode);
            }
        }
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
}