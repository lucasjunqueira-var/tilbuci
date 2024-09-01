package plugins;

/** OPENFL **/
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.data.DataLoader;
import feathers.events.TriggerEvent;
import com.tilbuci.Player;
import openfl.net.URLRequest;
import openfl.display.Sprite;
import openfl.Lib;

/** TILBUCI **/
import com.tilbuci.plugin.PluginEvent;
import com.tilbuci.plugin.Plugin;
import com.tilbuci.plugin.PluginAccess;
import com.tilbuci.plugin.PluginWindow;
import com.tilbuci.data.Global;
import com.tilbuci.script.ScriptParser;

class GoogleAnalyticsPlugin extends Plugin {

    /**
        the configuration window
    **/
    private var _confWindow:PluginWindow;

    /**
        first loaded movie information sent (it may take some time to prepare gtag interface)
    **/
    private var _firstsent:Bool = false;

    /**
        Constructor.
    **/
    public function new() {
        super('google-analytics', 'Google Analytics',  'GoogleAnalytics', true, false);
    }

    /**
        Initializes the plugin.
        @param  ac  initialization data
    **/
    override public function initialize(ac:PluginAccess):Void {
        super.initialize(ac);
        // add plugin button
        this.addMenu('Analytics', onAnalytics);
        // create plugin config window
        this._confWindow = new PluginWindow('Google Analytics', 500, 180);
        this._confWindow.addForm('config', this._confWindow.ui.forge('config', [
            { tp: 'Label', id: 'measurement', tx: 'Measurement ID', vr: '' }, 
            { tp: 'TInput', id: 'measurement', tx: '', vr: '' }, 
            { tp: 'Button', id: 'measurement', tx: 'Update configuration', ac: onUpdate }
        ]));
        this._confWindow.startInterface();
        // listen to player
        this.info.addEventListener(PluginEvent.MOVIELOAD, onMovieLoad);
        this.info.addEventListener(PluginEvent.SCENELOAD, onSceneLoad);
        // custom events
        this.setAction('analytics.event', this.acEvent);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
        this.info.removeEventListener(PluginEvent.MOVIELOAD, onMovieLoad);
        this.info.removeEventListener(PluginEvent.SCENELOAD, onSceneLoad);
        this._confWindow.kill();
        this._confWindow = null;
    }

    /**
        Sends a custom event to Analytics.
    **/
    private function acEvent(param:Array<String>):Bool {
        if (param.length >= 2) {
            ExternGoogleAnalytics.gtag('event', this._access.parser.parseString(param[0]), {
                'movie_name': GlobalPlayer.mdata.title, 
                'scene_name': GlobalPlayer.movie.scene.title,  
                'movie_id': GlobalPlayer.movie.mvId, 
                'scene_id': GlobalPlayer.movie.scId, 
                'about': this._access.parser.parseString(param[1]), 
            });
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Opens the configuration window.
    **/
    private function onAnalytics(evt:TriggerEvent):Void {
        if (Global.ws.level == 0) {
            if (this.config.exists('measurementid')) {
                this._confWindow.ui.inputs['measurement'].text = this.config['measurementid'];
            }
            this.showWindow(this._confWindow);
        } else {
            Global.showPopup('Google Analytics', 'This configuration is only available to system administrators.', 320, 180, 'OK', 'warn');
        }
        
    }

    /**
        Updates the plugin configuration.
    **/
    private function onUpdate(evt:TriggerEvent):Void {
        this.config['measurementid'] = this._confWindow.ui.inputs['measurement'].text;
        this.updateConfig(this.onUpdateFinish);
    }

    /**
        Plugin config update return.
    **/
    private function onUpdateFinish(ok:Bool, ld:DataLoader):Void {
        if (!ok) {
            Global.showPopup('Google Analytics', 'Error while saving the plugin configuration.', 320, 180, 'OK');
        } else if (ld.map['e'] != 0) {
            Global.showPopup('Google Analytics', 'Error while saving the plugin configuration.', 320, 180, 'OK');
        } else {
            Global.showMsg('The Google Analytics configuration was updated.');
            this.hideWindow(this._confWindow);
        }
    }

    /**
        A movie was just loaded.
    **/
    private function onMovieLoad(evt:PluginEvent):Void {
        if ((GlobalPlayer.mode == Player.MODE_PLAYER) && this.config.exists('measurementid')) {
            this._firstsent = true;
            ExternGoogleAnalytics.gtag('set', 'campaign', {
                'id': GlobalPlayer.movie.mvId, 
                'name': GlobalPlayer.mdata.title, 
                'source': GlobalPlayer.base
            });
            ExternGoogleAnalytics.gtag('event', 'movie.load', {
                'movie_id': GlobalPlayer.movie.mvId, 
                'movie_name': GlobalPlayer.mdata.title
            });
        }
    }

    /**
        A scene was just loaded.
    **/
    private function onSceneLoad(evt:PluginEvent):Void {
        if (!this._firstsent) this.onMovieLoad(null);
        if ((GlobalPlayer.mode == Player.MODE_PLAYER) && this.config.exists('measurementid')) {
            ExternGoogleAnalytics.gtag('event', 'scene.load', {
                'scene_id': GlobalPlayer.movie.scId, 
                'scene_name': GlobalPlayer.movie.scene.title, 
                'movie_id': GlobalPlayer.movie.mvId, 
                'movie_name': GlobalPlayer.mdata.title
            });
        }
    }
}

/**
    Google Analytics gtag call.
**/
#if (js && html5)
@:native("window")
extern class ExternGoogleAnalytics {
    /**
        Calls Analytics gtag function.
    **/
    static function gtag(...arguments:Dynamic):Void;
}
#else
class ExternGoogleAnalytics {
    /**
        Replacement for Analytics gtag function.
    **/
    static function gtag(...arguments:Dynamic):Void {
        // do nothing
    }
}
#end