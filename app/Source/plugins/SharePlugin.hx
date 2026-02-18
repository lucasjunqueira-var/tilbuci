/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package plugins;

/** OPENFL **/
import openfl.net.URLRequest;
import openfl.display.Sprite;
import openfl.Lib;

/** TILBUCI **/
import com.tilbuci.plugin.PluginEvent;
import com.tilbuci.plugin.Plugin;
import com.tilbuci.plugin.PluginAccess;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.script.ScriptParser;

class SharePlugin extends Plugin {

    /**
        overlay layer
    **/
    private var _overlay:Sprite;

    /**
        Constructor.
    **/
    public function new() {
        super('original.share', 'Share');
    }

    /**
        Initializes the plugin.
        @param  ac  initialization data
    **/
    override public function initialize(ac:PluginAccess):Void {
        super.initialize(ac);

        // getting a layer to display
        this._overlay = this.getOverlay('original.share');

        // setting plugin actions
        this.setAction('share.facebook', this.acFacebook);
        this.setAction('share.linkedin', this.acLinkedin);
        this.setAction('share.pinterest', this.acPinterest);
        this.setAction('share.reddit', this.acReddit);
        this.setAction('share.x', this.acX);
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        this.removeOverlay('original.share');
        this._overlay = null;
        super.kill();
    }

    /**
        Opens a Facebook share dialog for the current movie or scene.
        @param param Array of strings where:
            - param[0]: if true, shares the movie URL; otherwise uses the global share setting.
        @param after AfterScript (unused).
        @return Always true.
    **/
    private function acFacebook(param:Array<String>, after:AfterScript):Bool {
        if ((param.length > 0) && (this._access.parser.parseBool(param[0]))) {
            var req:URLRequest = new URLRequest('https://www.facebook.com/sharer/sharer.php?u=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId));
            req.method = 'GET';
            Lib.getURL(req);
        } else if (GlobalPlayer.share == 'scene') {
            var req:URLRequest = new URLRequest('https://www.facebook.com/sharer/sharer.php?u=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId + '&sc=' + GlobalPlayer.movie.scId));
            req.method = 'GET';
            Lib.getURL(req);
        } else {
            var req:URLRequest = new URLRequest('https://www.facebook.com/sharer/sharer.php?u=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId));
            req.method = 'GET';
            Lib.getURL(req);
        }
        return (true);
    }

    /**
        Opens a LinkedIn share dialog for the current movie or scene.
        @param param Array of strings where:
            - param[0]: if true, shares the movie URL; otherwise uses the global share setting.
        @param after AfterScript (unused).
        @return Always true.
    **/
    private function acLinkedin(param:Array<String>, after:AfterScript):Bool {
        if ((param.length > 0) && (this._access.parser.parseBool(param[0]))) {
            var req:URLRequest = new URLRequest('https://www.linkedin.com/shareArticle?mini=true&url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId));
            req.method = 'GET';
            Lib.getURL(req);
        } else if (GlobalPlayer.share == 'scene') {
            var req:URLRequest = new URLRequest('https://www.linkedin.com/shareArticle?mini=true&url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId + '&sc=' + GlobalPlayer.movie.scId));
            req.method = 'GET';
            Lib.getURL(req);
        } else {
            var req:URLRequest = new URLRequest('https://www.linkedin.com/shareArticle?mini=true&url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId));
            req.method = 'GET';
            Lib.getURL(req);
        }
        return (true);
    }

    /**
        Opens a Pinterest share dialog for the current movie or scene.
        @param param Array of strings where:
            - param[0]: if true, shares the movie URL; otherwise uses the global share setting.
        @param after AfterScript (unused).
        @return Always true.
    **/
    private function acPinterest(param:Array<String>, after:AfterScript):Bool {
        if ((param.length > 0) && (this._access.parser.parseBool(param[0]))) {
            var req:URLRequest = new URLRequest('https://pinterest.com/pin/create/button/?url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId));
            req.method = 'GET';
            Lib.getURL(req);
        } else if (GlobalPlayer.share == 'scene') {
            var req:URLRequest = new URLRequest('https://pinterest.com/pin/create/button/?url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId + '&sc=' + GlobalPlayer.movie.scId));
            req.method = 'GET';
            Lib.getURL(req);
        } else {
            var req:URLRequest = new URLRequest('https://pinterest.com/pin/create/button/?url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId));
            req.method = 'GET';
            Lib.getURL(req);
        }
        return (true);
    }

    /**
        Opens a Reddit submit dialog for the current movie or scene.
        @param param Array of strings where:
            - param[0]: if true, shares the movie URL; otherwise uses the global share setting.
        @param after AfterScript (unused).
        @return Always true.
    **/
    private function acReddit(param:Array<String>, after:AfterScript):Bool {
        if ((param.length > 0) && (this._access.parser.parseBool(param[0]))) {
            var req:URLRequest = new URLRequest('https://www.reddit.com/submit?url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId));
            req.method = 'GET';
            Lib.getURL(req);
        } else if (GlobalPlayer.share == 'scene') {
            var req:URLRequest = new URLRequest('https://www.reddit.com/submit?url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId + '&sc=' + GlobalPlayer.movie.scId));
            req.method = 'GET';
            Lib.getURL(req);
        } else {
            var req:URLRequest = new URLRequest('https://www.reddit.com/submit?url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId));
            req.method = 'GET';
            Lib.getURL(req);
        }
        return (true);
    }

    /**
        Opens a Twitter (X) share dialog for the current movie or scene.
        @param param Array of strings where:
            - param[0]: if true, shares the movie URL; otherwise uses the global share setting.
        @param after AfterScript (unused).
        @return Always true.
    **/
    private function acX(param:Array<String>, after:AfterScript):Bool {
        if ((param.length > 0) && (this._access.parser.parseBool(param[0]))) {
            var req:URLRequest = new URLRequest('https://twitter.com/intent/tweet?url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId));
            req.method = 'GET';
            Lib.getURL(req);
        } else if (GlobalPlayer.share == 'scene') {
            var req:URLRequest = new URLRequest('https://twitter.com/intent/tweet?url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId + '&sc=' + GlobalPlayer.movie.scId));
            req.method = 'GET';
            Lib.getURL(req);
        } else {
            var req:URLRequest = new URLRequest('https://twitter.com/intent/tweet?url=' + StringTools.urlEncode(GlobalPlayer.base + 'app/?mv=' + GlobalPlayer.movie.mvId));
            req.method = 'GET';
            Lib.getURL(req);
        }
        return (true);
    }

}