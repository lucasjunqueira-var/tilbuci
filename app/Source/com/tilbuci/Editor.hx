package com.tilbuci;

/** HAXE **/
import com.tilbuci.script.AssistVariables;
import com.tilbuci.script.AssistScene;
import com.tilbuci.script.AssistInstance;
import com.tilbuci.script.AssistDataInput;
import com.tilbuci.script.AssistPlus;
import com.tilbuci.script.AssistPlugin;
import com.tilbuci.ui.window.media.WindowCollectionsAdd;
import com.tilbuci.ui.window.media.WindowCollectionsRm;
import com.tilbuci.ui.window.media.WindowCollections;
import com.tilbuci.ui.window.media.WindowMediaVideo;
import com.tilbuci.ui.window.media.WindowMediaEmbed;
import com.tilbuci.ui.window.media.WindowMediaAudio;
import com.tilbuci.ui.window.media.WindowMediaHtml;
import com.tilbuci.ui.window.media.WindowMediaSpritemap;
import com.tilbuci.ui.window.media.WindowMediaShape;
import com.tilbuci.ui.window.media.WindowMediaParagraph;
import com.tilbuci.ui.window.media.WindowMediaText;
import com.tilbuci.ui.window.exchange.WindowExchangeExport;
import com.tilbuci.ui.window.exchange.WindowExchangeImport;
import com.tilbuci.ui.window.exchange.WindowExchangeWebsite;
import com.tilbuci.ui.window.exchange.WindowExchangePwa;
import com.tilbuci.ui.window.exchange.WindowExchangePublish;
import com.tilbuci.ui.window.exchange.WindowExchangeDesktop;
import com.tilbuci.ui.window.exchange.WindowExchangeCordova;
import com.tilbuci.data.History;
import com.tilbuci.ui.component.EditorPlayback;
import com.tilbuci.ui.menu.MenuKeyframe;
import com.tilbuci.ui.window.scene.WindowSceneProperties;
import com.tilbuci.ui.window.scene.WindowSceneSaveas;
import com.tilbuci.ui.window.scene.WindowSceneVersions;
import com.tilbuci.statictools.StringStatic;
import haxe.Timer;

/** OPENFL **/
import openfl.events.Event;

/** FEATHERS UI **/
import feathers.controls.Drawer;
import feathers.skins.RectangleSkin;
import feathers.controls.HDividedBox;
import feathers.controls.ScrollContainer;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Label;
import feathers.layout.AnchorLayout;
import feathers.controls.Panel;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.Player;
import com.tilbuci.ws.Webservice;
import com.tilbuci.data.EditorConfig;
import com.tilbuci.ui.main.LeftInterface;
import com.tilbuci.ui.main.RightInterface;
import com.tilbuci.ui.base.BackgroundSkin;
import com.tilbuci.ui.menu.DrawerMenu;
import com.tilbuci.ui.menu.MenuMovie;
import com.tilbuci.ui.menu.MenuScene;
import com.tilbuci.ui.menu.MenuMedia;
import com.tilbuci.ui.menu.MenuExchange;
import com.tilbuci.ui.window.PopupWindow;
import com.tilbuci.ui.window.WindowSetup;
import com.tilbuci.ui.window.WindowVisitors;
import com.tilbuci.ui.window.movie.WindowMovieNew;
import com.tilbuci.ui.window.movie.WindowMovieOpen;
import com.tilbuci.ui.window.movie.WindowMovieProperties;
import com.tilbuci.ui.window.scene.WindowSceneNew;
import com.tilbuci.ui.window.keyframe.WindowKeyframeManage;
import com.tilbuci.ui.window.WindowLogin;
import com.tilbuci.data.Global;
import com.tilbuci.data.Language;
import com.tilbuci.data.FileUpload;
import com.tilbuci.data.DataLoader;
import com.tilbuci.js.ExternUpload;
import com.tilbuci.font.EmbedFont;
import com.tilbuci.data.BuildInfo;
import com.tilbuci.ui.PlayerHolder;
import com.tilbuci.ui.window.media.WindowMediaPicture;
import com.tilbuci.ui.window.scene.WindowSceneOpen;
import com.tilbuci.ui.window.movie.WindowMoviePlugins;
import com.tilbuci.plugin.Plugin;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.ui.window.movie.WindowMovieUsers;
import com.tilbuci.ui.PlayerControls;

/**
    The Tilbuci editor.
**/
class Editor extends Drawer {

    /**
        build information
    **/
    public var build:BuildInfo;

    /** PRIVATE VARS **/

    /**
        the Tilbuci player holder
    **/
    private var _player:PlayerHolder;

    /**
        add GET param to request to avoid cached data?
    **/
    private var _nocache:Bool = true;

    /**
        interface holder
    **/
    private var _interface:HDividedBox;

    /**
        left interface area
    **/
    private var _leftArea:LeftInterface;

    /**
        right interface area
    **/
    private var _rightArea:RightInterface;

    /**
        center interface area (player)
    **/
    private var _centertArea:ScrollContainer;

    /**
        player area/controls
    **/
    private var _playerControls:PlayerControls;

    /**
        drawer menus
    **/
    private var _menus:Map<String, DrawerMenu> = [ ];

    /**
        popup windows
    **/
    private var _windows:Map<String, PopupWindow> = [ ];

    /**
        timer for development related actions
    **/
    private var _devTimer:Timer;

    /**
        editor player display
    **/
    private var _playback:EditorPlayback;


    /**
        Constructor.
        @param  path    path to the configuration file
        @param  nocache add GET param to request to avoid cached data?
    **/
    public function new(path:String, nocache:Bool = true) {
        // start layout
        super();

        // get build information
        this.build = new BuildInfo();

        // editor configuration
        this._nocache = nocache;
        Global.econfig = new EditorConfig(path, this.onConfig, nocache);
    }

    /**
        Adds a plugin to the system.
        @param  pl  the plugin object
    **/
    public function registerPlugin(pl:Plugin):Void {
        Global.plugins[pl.plname] = pl;
        if (this._player != null) this._player.player.registerPlugin(pl);
    }

    /**
        Releases resources used by object.
    **/
    public function kill():Void {
        this.removeEventListener(Event.RESIZE, this.redraw);
        this.removeChildren();
        this.opened = false;
        this.drawer = null;
        this._interface.removeChildren();
        this._interface = null;
        this._leftArea.kill();
        this._leftArea = null;
        for (mn in this._menus) mn.kill();
        for (mn in this._menus.keys()) this._menus.remove(mn);
        this._menus = null;
        for (wd in this._windows) wd.kill();
        for (wd in this._windows.keys()) this._windows.remove(wd);
        this._windows = null;
        Global.econfig.kill();
        Global.econfig = null;
        Global.ln.kill();
        Global.ln = null;
        Global.ws.kill();
        Global.ws = null;
        Global.up.kill();
        Global.up = null;
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
            case 'config':
                Global.econfig.kill();
                Global.econfig = null;
                msg = 'Error while loading the basic system configuration.';
            case 'language':
                Global.econfig.kill();
                Global.econfig = null;
                Global.ln.kill();
                Global.ln = null;
                msg = 'Error while loading the default language file.';
            case 'sysconfig':
                Global.econfig.kill();
                Global.econfig = null;
                Global.ln.kill();
                Global.ln = null;
                Global.ws.kill();
                Global.ws = null;
                msg = 'Error while loading the system configuration.';
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


    /** EVENTS **/

    /**
        Checking configuration load.
    **/
    private function onConfig(ok:Bool):Void {
		// correclty loaded?
        if (ok) {
            // load language information
            Global.ln = new Language();
            if (Global.ln.ok) {
                // language load ok, preparing webservices
                Global.ws = new Webservice(Global.econfig.ws);
                Global.ws.send('System/GetConfig', [ ], this.onSysConfig);
            } else {
                // default language must be loaded to continue
                this.halt('language');
            }
        } else {
            // no configuration found: halt!
            this.halt('config');
        }
	}

    /**
        Loading system general configuration.
    **/
    private function onSysConfig(ok:Bool, ld:DataLoader):Void {
        // data received?
        if (!ok) {
            this.halt('sysconfig');
        } else {
            // error requesting config?
            if (ld.map['e'] != 0) {
                this.halt('sysconfig');
            } else {
                // save configutation
                Global.singleUser = ld.map['singleUser'];
                Global.validEmail = ld.map['validEmail'];
                Global.showWindow = this.showWindow;

                // available fonts
                var fnt:Array<Dynamic> = cast ld.map['fonts'];
                for (n in 0...fnt.length) new EmbedFont((Global.econfig.font + fnt[n].v), fnt[n].n);

                // initialize the interface
                this.startInterface();

                // single user?
                if (ld.map['singleUser']) {
                    Global.userLevel = 0;
                    Global.ws.setUser('single', ld.map['userKey'], 0);
                } else {
                    // ask for user login
                    this.showWindow('login');
                }

                // preparing uploader
                Global.up = new FileUpload(this.stage);

                // wait for development routines
                this._devTimer = new Timer(1000);
                this._devTimer.run = this.devStart;
            }
        }
    }

    /**
        Development routines.
    **/
    private function devStart():Void {
        try {
            this._devTimer.stop();
        } catch (e) { }
        this._devTimer = null;
        if (Global.ws.user == 'single') {
            if (Main.scene != '') {
                Global.sceneToLoad = Main.scene;
            }
            if (Main.movie != '') {
                this._player.player.load(Main.movie);
            }
        }
    }

    /**
        Starts the editor interface.
    **/
    private function startInterface():Void {
        // stage
        Global.stage = this.stage;

        // interface holder
        this._interface = new HDividedBox();
        this._interface.layoutData = AnchorLayoutData.fill();
        this._interface.backgroundSkin = new BackgroundSkin();
        this.content = this._interface;

        // left area
        this._leftArea = new LeftInterface(this.actionLeftInterface);

        // center area
        this._centertArea = new ScrollContainer();
        this._centertArea.layout = new AnchorLayout();
        var centerSkin:RectangleSkin = new RectangleSkin();
        centerSkin.fill = SolidColor(0x999999);
        this._centertArea.backgroundSkin = centerSkin;
        this._player = new PlayerHolder(Global.econfig.player, this.playerCallback);
        this._playerControls = new PlayerControls(this._player, this.playerCallback);
        this._centertArea.addChild(this._playerControls);
        for (pl in Global.plugins) this._player.player.registerPlugin(pl);

        // editor interface actions
        Global.editorActions = this.editorActions;

        // history
        Global.history = new History();

        // right area
        this._rightArea = new RightInterface(this._playerControls.centerPlayer);

        // menus
        this._menus['left-movie'] = new MenuMovie(actionMenuMovie);
        this._menus['left-scene'] = new MenuScene(actionMenuScene);
        this._menus['left-media'] = new MenuMedia(actionMenuMedia);
        this._menus['left-exchange'] = new MenuExchange(actionMenuExchange);
        this._menus['left-keyframe'] = new MenuKeyframe(actionMenuKeyframe);

        // player area
        this._playback = new EditorPlayback(this._playerControls.centerPlayer);

        // size adjust
        this.addEventListener(Event.RESIZE, this.redraw);
        this.redraw();
    }

    /**
        Actions to run at te editor interface.
        @param  name    action name
        @param  data    data for the action
        @return was the action found?
    **/
    private function editorActions(name:String, data:Map<String, Dynamic> = null):Bool {
        switch (name) {
            case 'addleftbutton':
                this._leftArea.addButton(data['name'], data['callback'], data['top'], data['asset']);
                return (true);
            case 'showwindow':
                var wd:PopupWindow = cast (data['wd']);
                PopUpManager.addPopUp(wd, this);
                wd.redraw();
                wd.acStart();
                return (true);
            case 'hidewindow':
                var wd:PopupWindow = cast (data['wd']);
                PopUpManager.removePopUp(wd);
                return (true);
            default:
                return (false);
        }
    }

    /**
        Left area actions.
        @param  ac  the action id
    **/
    private function actionLeftInterface(ac:String):Void {
        switch (ac) {
            case 'movie':
                this.drawer = this._menus['left-movie'];
                this.opened = true;
                this._menus['left-movie'].onShow();
            case 'scene':
                this.drawer = this._menus['left-scene'];
                this.opened = true;
                this._menus['left-scene'].onShow();
            case 'keyframe':
                this.drawer = this._menus['left-keyframe'];
                this.opened = true;
                this._menus['left-keyframe'].onShow();
            case 'media':
                this.drawer = this._menus['left-media'];
                this.opened = true;
                this._menus['left-media'].onShow();
            case 'exchange':
                this.drawer = this._menus['left-exchange'];
                this.opened = true;
                this._menus['left-exchange'].onShow();
            case 'setup':
                this.showWindow('setup');
            case 'visitors':
                this.showWindow('visitors');
            case 'close-interface':
                this.redraw();
            case 'open-interface':
                this.redraw();
        }
    }

    /**
        Movie menu actions.
        @param  ac  the action id
    **/
    private function actionMenuMovie(ac:String):Void {
        switch (ac) {
            case 'new':
                this.opened = false;
                this.showWindow('newmovie');
            case 'open':
                this.opened = false;
                this.showWindow('openmovie');
            case 'prop':
                this.opened = false;
                this.showWindow('propmovie');
            case 'users':
                this.opened = false;
                this.showWindow('usermovie');
            case 'plugins':
                this.opened = false;
                this.showWindow('pluginmovie');
            case 'menu-close':
                this.opened = false;
        }
    }

    /**
        Scene menu actions.
        @param  ac  the action id
    **/
    private function actionMenuScene(ac:String):Void {
        switch (ac) {
            case 'new':
                this.opened = false;
                this.showWindow('newscene');
            case 'open':
                this.opened = false;
                this.showWindow('openscene');
            case 'save':
                this.opened = false;
                this.saveScene();
            case 'publish':
                this.opened = false;
                this.saveScene(true);
            case 'saveas':
                this.opened = false;
                this.showWindow('saveasscene');
            case 'version':
                this.opened = false;
                this.showWindow('versionscene');
            case 'prop':
                this.opened = false;
                this.showWindow('propscene');
            case 'menu-close':
                this.opened = false;
        }
    }

    /**
        Keyframe menu actions.
        @param  ac  the action id
    **/
    private function actionMenuKeyframe(ac:String):Void {
        switch (ac) {
            case 'add':
                this._player.addKeyframe();
                this.opened = false;
            case 'remove':
                if (GlobalPlayer.movie.scene.keyframes.length > 1) {
                    this._player.removeKeyframe();
                } else {
                    Global.showMsg(Global.ln.get('window-kfmanage-onlyone'));
                }
                this._playerControls.updateInfo();
                this.opened = false;
            case 'manage':
                this.showWindow('kfmanage');
                this.opened = false;
            case 'menu-close':
                this.opened = false;
        }
    }

    /**
        Media menu actions.
        @param  ac  the action id
    **/
    private function actionMenuMedia(ac:String):Void {
        switch (ac) {
            case 'collection':
                this.opened = false;
                this.showWindow('mediacollection');
            case 'collectionadd':
                this.opened = false;
                this.showWindow('mediacollectionadd');
            case 'collectionrm':
                this.opened = false;
                this.showWindow('mediacollectionrm');
            case 'picture':
                this.opened = false;
                this.showWindow('mediapicture');
            case 'video':
                this.opened = false;
                this.showWindow('mediavideo');
            case 'embed':
                this.opened = false;
                this.showWindow('mediaembed');
            case 'audio':
                this.opened = false;
                this.showWindow('mediaaudio');
            case 'html':
                this.opened = false;
                this.showWindow('mediahtml');
            case 'spritemap':
                this.opened = false;
                this.showWindow('mediaspritemap');
            case 'shape':
                this.opened = false;
                this.showWindow('mediashape');
            case 'paragraph':
                this.opened = false;
                this.showWindow('mediaparagraph');
            case 'text':
                this.opened = false;
                this.showWindow('mediatext');
            case 'menu-close':
                this.opened = false;
        }
    }

    /**
        Exchange menu actions.
        @param  ac  the action id
    **/
    private function actionMenuExchange(ac:String):Void {
        switch (ac) {
            case 'export':
                this.opened = false;
                this.showWindow('exchangeexport');
            case 'import':
                this.opened = false;
                this.showWindow('exchangeimport');
            case 'website':
                this.opened = false;
                this.showWindow('exchangewebsite');
            case 'pwa':
                this.opened = false;
                this.showWindow('exchangepwa');
            case 'publish':
                this.opened = false;
                this.showWindow('exchangepub');
            case 'desktop':
                this.opened = false;
                this.showWindow('exchangedesk');
            case 'cordova':
                this.opened = false;
                this.showWindow('exchangecord');
            case 'menu-close':
                this.opened = false;
        }
    }

    /**
        Setup window actions.
        @param  ac  the action id
    **/
    private function actionWindowSetup(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'menu-close':
                this.opened = false;
        }
    }

    /**
        Visitors window actions.
        @param  ac  the action id
    **/
    private function actionWindowVisitors(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'menu-close':
                this.opened = false;
        }
    }

    /**
        Movie window actions.
        @param  ac  the action id
    **/
    private function actionMovie(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'menu-close':
                this.opened = false;
            case 'movieload':
                this._player.player.load(data['id']);
            case 'browsefavicon':
                Global.temp['Media/Single'] = [
                    'type' => '´picture', 
                    'call' => 'browsefavicon'
                ];
                this.showWindow('mediapicture');
                this._windows['mediapicture'].action('setmode', [
                    'mode' => 'single', 
                ]);
            case 'browseimage':
                Global.temp['Media/Single'] = [
                    'type' => '´picture', 
                    'call' => 'browseimage'
                ];
                this.showWindow('mediapicture');
                this._windows['mediapicture'].action('setmode', [
                    'mode' => 'single', 
                ]);
        }
    }

    /**
        Scene window actions.
        @param  ac  the action id
    **/
    private function actionScene(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'menu-close':
                this.opened = false;
            case 'sceneload':
                if (GlobalPlayer.movie.mvId != '') GlobalPlayer.movie.loadScene(data['id']);
            case 'sceneversionload':
                if (GlobalPlayer.movie.mvId != '') GlobalPlayer.movie.loadScene(null, data['id']);
            case 'browsesceneimage':
                Global.temp['Media/Single'] = [
                    'type' => '´picture', 
                    'call' => 'browsesceneimage'
                ];
                this.showWindow('mediapicture');
                this._windows['mediapicture'].action('setmode', [
                    'mode' => 'single', 
                ]);
        }
    }

    /**
        Exchange window actions.
        @param  ac  the action id
    **/
    private function actionExchange(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'menu-close':
                this.opened = false;
        }
    }

    /**
        Assistant windows actions.
        @param  ac  the action id
    **/
    private function actionAssistant(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'menu-close':
                this.opened = false;
        }
    }

    /**
        Keyframe manage window actions.
        @param  ac  the action id
    **/
    private function actionKeyframe(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'reload':
                this._playerControls.reCenter();
                this._playerControls.updateInfo();
            case 'add':
                this._player.addKeyframe();
                this._playerControls.reCenter();
                this._playerControls.updateInfo();
            case 'remove':
                this._player.removeKeyframe();
                this._playerControls.reCenter();
                this._playerControls.updateInfo();
            case 'menu-close':
                this.opened = false;
        }
    }

    /**
        Saves the current scene.
        @param  pub also publish the current version?
    **/
    private function saveScene(pub:Bool = false):Void {
        var cols:Dynamic = { };
        for (k in GlobalPlayer.movie.collections.keys()) Reflect.setField(cols, k, GlobalPlayer.movie.collections[k].toJson());
        Global.ws.send(
            'Scene/Save', 
            [
                'movie' => GlobalPlayer.movie.mvId, 
                'id' => GlobalPlayer.movie.scId, 
                'scene' => GlobalPlayer.movie.scene.toJson(), 
                'collections' => cols, 
                'pub' => pub
            ], 
            onSaveReturn
        );
    }

    /**
        Scene scene return.
    **/
    private function onSaveReturn(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            Global.showPopup(Global.ln.get('scene-save-windowtitle'), Global.ln.get('scene-save-error'), 300, 180, Global.ln.get('default-ok'));
        } else {
            if (ld.map['e'] == 0) {
                if (!ld.map['pub']) {
                    Global.showMsg(Global.ln.get('scene-save-ok'));
                } else {
                    Global.showMsg(Global.ln.get('scene-save-okpublish'));
                }
            } else {
                Global.showPopup(Global.ln.get('scene-save-windowtitle'), Global.ln.get('scene-save-error'), 300, 180, Global.ln.get('default-ok'));
            }
        }
    }

    /**
        Media windows actions.
        @param  ac  the action id
    **/
    private function actionMedia(ac:String, data:Map<String, Dynamic> = null):Void {
        switch (ac) {
            case 'menu-close':
                this.opened = false;
            case 'addstage':
                Global.temp['media/addstage'] = data;
                if (data['type'] == 'shape') {
                    this._player.createCollection((Global.ln.get('menu-media-shape') + ' ' + Date.now().toString()), onMediaAddStage, data['file']);
                } else if (data['type'] == 'paragraph') {
                        this._player.createCollection((Global.ln.get('menu-media-paragraph') + ' ' + Date.now().toString()), onMediaAddStage, data['file']);
                } else if (data['type'] == 'text') {
                    this._player.createCollection((Global.ln.get('menu-media-text') + ' ' + Date.now().toString()), onMediaAddStage, data['file']);
                } else {
                    this._player.createCollection(data['file'], onMediaAddStage, data['file']);
                }
            case 'addcollection':
            case 'newasset':
                switch (data['type']) {
                    case 'picture':
                        this.showWindow('mediapicture');
                        this._windows['mediapicture'].action('setmode', [
                            'mode' => 'newasset', 
                        ]);
                    case 'video':
                        this.showWindow('mediavideo');
                        this._windows['mediavideo'].action('setmode', [
                            'mode' => 'newasset', 
                        ]);
                    case 'audio':
                        this.showWindow('mediaaudio');
                        this._windows['mediaaudio'].action('setmode', [
                            'mode' => 'newasset', 
                        ]);
                    case 'html':
                        this.showWindow('mediahtml');
                        this._windows['mediahtml'].action('setmode', [
                            'mode' => 'newasset', 
                        ]);
                    case 'spritemap':
                        this.showWindow('mediaspritemap');
                        this._windows['mediaspritemap'].action('setmode', [
                            'mode' => 'newasset', 
                        ]);
                    case 'shape':
                        this.showWindow('mediashape');
                        this._windows['mediashape'].action('setmode', [
                            'mode' => 'newasset', 
                        ]);
                    case 'paragraph':
                        this.showWindow('mediaparagraph');
                        this._windows['mediaparagraph'].action('setmode', [
                            'mode' => 'newasset', 
                        ]);
                    case 'text':
                        this.showWindow('mediatext');
                        this._windows['mediatext'].action('setmode', [
                            'mode' => 'newasset', 
                        ]);
                }
            case 'file':
                switch (data['type']) {
                    case 'picture':
                        this.showWindow('mediapicture');
                        this._windows['mediapicture'].action('setmode', [
                            'mode' => 'asset', 
                            'num' => data['num']
                        ]);
                    case 'video':
                        this.showWindow('mediavideo');
                        this._windows['mediavideo'].action('setmode', [
                            'mode' => 'asset', 
                            'num' => data['num']
                        ]);
                    case 'audio':
                        this.showWindow('mediaaudio');
                        this._windows['mediaaudio'].action('setmode', [
                            'mode' => 'asset', 
                            'num' => data['num']
                        ]);
                    case 'html':
                        this.showWindow('mediahtml');
                        this._windows['mediahtml'].action('setmode', [
                            'mode' => 'asset', 
                            'num' => data['num']
                        ]);
                    case 'spritemap':
                        this.showWindow('mediaspritemap');
                        this._windows['mediaspritemap'].action('setmode', [
                            'mode' => 'asset', 
                            'num' => data['num']
                        ]);
                    case 'shape':
                        this.showWindow('mediashape');
                        this._windows['mediashape'].action('setmode', [
                            'mode' => 'asset', 
                            'num' => data['num'], 
                            'current' => data['current'], 
                        ]);
                    case 'paragraph':
                        this.showWindow('mediaparagraph');
                        this._windows['mediaparagraph'].action('setmode', [
                            'mode' => 'asset', 
                            'num' => data['num'], 
                            'current' => data['current'], 
                        ]);
                    case 'text':
                        this.showWindow('mediatext');
                        this._windows['mediatext'].action('setmode', [
                            'mode' => 'asset', 
                            'num' => data['num'], 
                            'current' => data['current'], 
                        ]);
                }
            case 'addasset':
                this._windows['mediacollection'].action('setfile', [
                    'file' => data['path'] + data['file'], 
                    'num' => data['num'], 
                    'frames' => data['frames'], 
                    'frtime' => data['frtime']
                ]);
            case 'addnewasset':
                this._windows['mediacollection'].action('addasset', [
                    'file' => data['path'] + data['file'], 
                    'type' => data['type'], 
                    'name' => data['file'], 
                    'frames' => data['frames'], 
                    'frtime' => data['frtime']
                ]);
            case 'single':
                if (Global.temp.exists('Media/Single')) {
                    switch (Global.temp['Media/Single']['call']) {
                        case 'browsefavicon':
                            this._windows['propmovie'].action('browsefavicon', [
                                'file' => data['path'] + data['file'], 
                                'type' => data['type'], 
                                'name' => data['file'], 
                            ]);
                        case 'browseimage':
                            this._windows['propmovie'].action('browseimage', [
                                'file' => data['path'] + data['file'], 
                                'type' => data['type'], 
                                'name' => data['file'], 
                            ]);
                        case 'browsesceneimage':
                            this._windows['propscene'].action('browsesceneimage', [
                                'file' => data['path'] + data['file'], 
                                'type' => data['type'], 
                                'name' => data['file'], 
                            ]);
                    }
                    Global.temp.remove('Media/Single');
                }
            case 'addinstance':
                var instid:String = StringStatic.md5(data['asset']).substr(0, 10);
                while (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].exists(instid)) {
                    instid = StringStatic.md5(instid).substr(0, 10);
                }
                var ordH:Int = -1;
                var ordV:Int = -1;
                if (Lambda.count(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf]) > 0) {
                    for (i in GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].keys()) {
                        if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][i].horizontal.order > ordH) ordH = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][i].horizontal.order + 1;
                        if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][i].vertical.order > ordV) ordV = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][i].vertical.order + 1;
                    }
                } else {
                    ordH = ordV = 0;
                }
                this._player.addInstance(instid, {
                    collection: data['collection'], 
                    asset: data['asset'], 
                    action: '', 
                    play: true, 
                    horizontal: {
                        order: ordH, 
                        x: 0, 
                        y: 0,
                        alpha: 1, 
                        width: 320, 
                        height: 320, 
                        rotation: 0, 
                        visible: true, 
                        color: '0xFFFFFF', 
                        colorAlpha: 0, 
                        volume: 1, 
                        pan: 0, 
                        blur: '', 
                        dropshadow: '', 
                        textFont: 'sans', 
                        textSize: 20, 
                        textColor: '0xFFFFFF', 
                        textBold: false, 
                        textItalic: false,
                        textLeading: 10, 
                        textSpacing: 0, 
                        textBackground: '', 
                        textAlign: 'left'
                    }, 
                    vertical: {
                        order: ordV, 
                        x: 0, 
                        y: 0,
                        alpha: 1, 
                        width: 320, 
                        height: 320, 
                        rotation: 0, 
                        visible: true, 
                        color: '0xFFFFFF', 
                        colorAlpha: 0, 
                        volume: 1, 
                        pan: 0, 
                        blur: '', 
                        dropshadow: '', 
                        textFont: 'sans', 
                        textSize: 20, 
                        textColor: '0xFFFFFF', 
                        textBold: false, 
                        textItalic: false,
                        textLeading: 10, 
                        textSpacing: 0, 
                        textBackground: '', 
                        textAlign: 'left'
                    }
                });
        }
    }

    /**
        A new media file was add to the stage.
    **/
    private function onMediaAddStage(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            if (ld.map['e'] == 0) {
                if (Global.temp.exists('media/addstage')) {
                    // check asset id
                    var aid:String = Global.temp['media/addstage']['file'];
                    // create collection
                    var instname:String = Global.temp['media/addstage']['file'];
                    if (Global.temp['media/addstage']['type'] == 'shape') {
                        instname = Global.ln.get('menu-media-shape');
                        //aid = Global.ln.get('menu-media-shape');
                    } else if (Global.temp['media/addstage']['type'] == 'paragraph') {
                        instname = Global.ln.get('menu-media-paragraph');
                        //aid = Global.ln.get('menu-media-paragraph');
                    } else if (Global.temp['media/addstage']['type'] == 'text') {
                        instname = Global.ln.get('menu-media-text');
                        //aid = Global.ln.get('menu-media-text');
                    }
                    aid = StringStatic.md5(aid).substr(0, 10);
                    this._player.setCollection(
                        ld.map['id'], 
                        ld.map['name'], 
                        'alpha', 
                        1, 
                        [
                           aid => {
                                name: instname, 
                                type: Global.temp['media/addstage']['type'], 
                                order: 0, 
                                time: 5, 
                                action: '', 
                                frames: Std.parseInt(Global.temp['media/addstage']['frames']), 
                                frtime: Std.parseInt(Global.temp['media/addstage']['frtime']), 
                                file: {
                                    '@1': Global.temp['media/addstage']['path'] + Global.temp['media/addstage']['file'], 
                                    '@2': Global.temp['media/addstage']['path'] + Global.temp['media/addstage']['file'], 
                                    '@3': Global.temp['media/addstage']['path'] + Global.temp['media/addstage']['file'], 
                                    '@4': Global.temp['media/addstage']['path'] + Global.temp['media/addstage']['file'], 
                                    '@5': Global.temp['media/addstage']['path'] + Global.temp['media/addstage']['file']
                                }
                            }
                        ]);
                        // checking instance order
                        var ordH:Int = -1;
                        var ordV:Int = -1;
                        if (Lambda.count(GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf]) > 0) {
                            for (i in GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].keys()) {
                                if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][i].horizontal.order > ordH) ordH = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][i].horizontal.order + 1;
                                if (GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][i].vertical.order > ordV) ordV = GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf][i].vertical.order + 1;
                            }
                        } else {
                            ordH = ordV = 0;
                        }
                        // adding instance
                        this._player.addInstance(aid, {
                            collection: ld.map['id'], 
                            asset: aid, 
                            action: '', 
                            play: true, 
                            horizontal: {
                                order: ordH, 
                                x: 0, 
                                y: 0,
                                alpha: 1, 
                                width: 320, 
                                height: 320, 
                                rotation: 0, 
                                visible: true, 
                                color: '0xFFFFFF', 
                                colorAlpha: 0, 
                                volume: 1, 
                                pan: 0, 
                                blur: '', 
                                dropshadow: '', 
                                textFont: 'sans', 
                                textSize: 20, 
                                textColor: '0xFFFFFF', 
                                textBold: false, 
                                textItalic: false,
                                textLeading: 10, 
                                textSpacing: 0, 
                                textBackground: '', 
                                textAlign: 'left'
                            }, 
                            vertical: {
                                order: ordV, 
                                x: 0, 
                                y: 0,
                                alpha: 1, 
                                width: 320, 
                                height: 320, 
                                rotation: 0, 
                                visible: true, 
                                color: '0xFFFFFF', 
                                colorAlpha: 0, 
                                volume: 1, 
                                pan: 0, 
                                blur: '', 
                                dropshadow: '', 
                                textFont: 'sans', 
                                textSize: 20, 
                                textColor: '0xFFFFFF', 
                                textBold: false, 
                                textItalic: false,
                                textLeading: 10, 
                                textSpacing: 0, 
                                textBackground: '', 
                                textAlign: 'left'
                            }
                        });

                        Global.temp.remove('media/addstage');
                } else {
                    Global.showPopup(Global.ln.get('window-media-title'), Global.ln.get('window-media-addstageer'), 300, 180, Global.ln.get('default-ok'));
                }
            } else {
                Global.showPopup(Global.ln.get('window-media-title'), Global.ln.get('window-media-addstageer'), 300, 180, Global.ln.get('default-ok'));
            }
        } else {
            Global.showPopup(Global.ln.get('window-media-title'), Global.ln.get('window-media-addstageer'), 300, 180, Global.ln.get('default-ok'));
        }
    }

    /**
        Login window actions.
        @param  ac  the action id
        @param  data    action data
    **/
    private function actionWindowLogin(ac:String, data:Map<String, Dynamic>):Void {
        switch (ac) {
            case 'check-login':
                Global.ws.send('System/Login', data, onLogin);
        }
    }

    /**
        Login finish.
    **/
    private function onLogin(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            this._windows['login'].action('login-error');
        } else {
            switch (ld.map['e']) {
                case 0:
                    Global.ws.setUser(ld.map['userMail'], ld.map['userKey'], ld.map['userLevel']);
                    this._windows['login'].action('login-ok');
                    PopUpManager.removePopUp(this._windows['login']);
                case 1:
                    this._windows['login'].action('login-notfound');
                case 2:
                    this._windows['login'].action('login-password');
                case 3:
                    this._windows['login'].action('login-nokey');
            }
        }
    }


    /**
        Redraws the editor interface.
    **/
    private function redraw(evt:Event = null):Void {
        // replace main interface
        this._interface.removeChildren();
        this._interface.addChild(this._leftArea);
        this._interface.addChild(this._centertArea);
        this._interface.addChild(this._rightArea);
        // set windows properties
        for (wd in this._windows) {
            wd.maxWidth = this.stage.stageWidth * 0.7;
            wd.maxHeight = this.stage.stageHeight * 0.6;
        }
    }

    /**
        Shows a popup window.
        @param  name    the window name
        @return is the requested window available?
    **/
    private function showWindow(name:String):Bool {
        if (this._windows.exists(name)) {
            // window already available
            PopUpManager.addPopUp(this._windows[name], this);
            this._windows[name].redraw();
            this._windows[name].acStart();
            return (true);
        } else {
            // valid window?
            var ok:Bool = true;
            switch (name) {
                case 'login': this._windows['login'] = new WindowLogin(actionWindowLogin);
                case 'newmovie': this._windows['newmovie'] = new WindowMovieNew(actionMovie);
                case 'openmovie': this._windows['openmovie'] = new WindowMovieOpen(actionMovie);
                case 'propmovie': this._windows['propmovie'] = new WindowMovieProperties(actionMovie);
                case 'usermovie': this._windows['usermovie'] = new WindowMovieUsers(actionMovie);
                case 'pluginmovie': this._windows['pluginmovie'] = new WindowMoviePlugins(actionMovie);

                case 'newscene': this._windows['newscene'] = new WindowSceneNew(actionScene);
                case 'openscene': this._windows['openscene'] = new WindowSceneOpen(actionScene);
                case 'versionscene': this._windows['versionscene'] = new WindowSceneVersions(actionScene);
                case 'saveasscene': this._windows['saveasscene'] = new WindowSceneSaveas(actionScene);
                case 'propscene': this._windows['propscene'] = new WindowSceneProperties(actionScene);

                case 'kfmanage': this._windows['kfmanage'] = new WindowKeyframeManage(actionKeyframe);

                case 'exchangeexport': this._windows['exchangeexport'] = new WindowExchangeExport(actionExchange);
                case 'exchangeimport': this._windows['exchangeimport'] = new WindowExchangeImport(actionExchange);
                case 'exchangewebsite': this._windows['exchangewebsite'] = new WindowExchangeWebsite(actionExchange);
                case 'exchangepwa': this._windows['exchangepwa'] = new WindowExchangePwa(actionExchange);
                case 'exchangepub': this._windows['exchangepub'] = new WindowExchangePublish(actionExchange);
                case 'exchangedesk': this._windows['exchangedesk'] = new WindowExchangeDesktop(actionExchange);
                case 'exchangecord': this._windows['exchangecord'] = new WindowExchangeCordova(actionExchange);

                case 'mediacollection': this._windows['mediacollection'] = new WindowCollections(actionMedia);
                case 'mediacollectionadd': this._windows['mediacollectionadd'] = new WindowCollectionsAdd(actionMedia);
                case 'mediacollectionrm': this._windows['mediacollectionrm'] = new WindowCollectionsRm(actionMedia);
                case 'mediapicture': this._windows['mediapicture'] = new WindowMediaPicture(actionMedia, 'simple');
                case 'mediavideo': this._windows['mediavideo'] = new WindowMediaVideo(actionMedia, 'simple');
                case 'mediaaudio': this._windows['mediaaudio'] = new WindowMediaAudio(actionMedia, 'simple');
                case 'mediahtml': this._windows['mediahtml'] = new WindowMediaHtml(actionMedia, 'simple');
                case 'mediaspritemap': this._windows['mediaspritemap'] = new WindowMediaSpritemap(actionMedia, 'simple');
                case 'mediashape': this._windows['mediashape'] = new WindowMediaShape(actionMedia, 'simple');
                case 'mediaparagraph': this._windows['mediaparagraph'] = new WindowMediaParagraph(actionMedia, 'simple');
                case 'mediatext': this._windows['mediatext'] = new WindowMediaText(actionMedia, 'simple');
                case 'mediaembed': this._windows['mediaembed'] = new WindowMediaEmbed(actionMedia);

                case 'assistantscene': this._windows['assistantscene'] = new AssistScene(actionAssistant);
                case 'assistantvariables': this._windows['assistantvariables'] = new AssistVariables(actionAssistant);
                case 'assistantinstance': this._windows['assistantinstance'] = new AssistInstance(actionAssistant);
                case 'assistantdata': this._windows['assistantdata'] = new AssistDataInput(actionAssistant);
                case 'assistantplus': this._windows['assistantplus'] = new AssistPlus(actionAssistant);
                case 'assistantplugin': this._windows['assistantplugin'] = new AssistPlugin(actionAssistant);

                case 'visitors': this._windows['visitors'] = new WindowVisitors(actionWindowVisitors, this.build);

                case 'setup': this._windows['setup'] = new WindowSetup(actionWindowSetup, this.build);
                default: ok = false;
            }
            if (ok) {
                PopUpManager.addPopUp(this._windows[name], this);
                this._windows[name].redraw();
                this._windows[name].acStart();
            }
            return (ok);
        }
    }

    /**
        Callback function for player events.
        @param  ev  player event
        @param  data    event data
    **/
    private function playerCallback(ev:String, data:Map<String, Dynamic> = null):Void {
        switch (ev) {
            case 'movieload':
                Global.ws.send('Movie/Info', [ 'id' => GlobalPlayer.movie.mvId ], this.onMovieInfo);
                if (GlobalPlayer.mdata.screen.type == 'portrait') {
                    Global.displayType = 'portrait';
                } else {
                    Global.displayType = 'landscape';
                }
                this._playerControls.centerPlayer();
                this._playerControls.updateDisplay();
            case 'sceneload':
                if (Global.sceneObj != null) {
                    GlobalPlayer.movie.scene.fromObject(Global.sceneObj);
                    Global.sceneObj = null;
                }
                if (Global.kfToLoad >= 0) {
                    GlobalPlayer.area.loadKeyframe(GlobalPlayer.movie.scene.keyframes[Global.kfToLoad], Global.kfToLoad);
                    Global.kfToLoad = -1;
                }
                this._playerControls.updateDisplay();
            case 'loadkeyframe':
                this._rightArea.updateInstances();
            case 'selectimage':
                this._rightArea.setInstance(data);
            case 'play':
                this._playback.show(this.stage, this._player);
        }
    }

    /**
        Getting information about the loaded movie.
    **/
    private function onMovieInfo(ok:Bool, ld:DataLoader):Void {
        Global.mvOwner = false;
        Global.mvCollaborator = false;
        if (ok) {
            if (ld.map['e'] == 0) {
                Global.mvOwner = cast(Reflect.field(ld.map['info'], 'isOwner'), Bool);
                Global.mvCollaborator = cast(Reflect.field(ld.map['info'], 'isCollaborator'), Bool);
            }
            this._playerControls.updateDisplay();
            if (Global.sceneToLoad != '') {
                GlobalPlayer.movie.loadScene(Global.sceneToLoad);
                Global.sceneToLoad = '';
            }
        }
    }

}