/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.data;

/** HAXE **/
import com.tilbuci.narrative.Narrative;
import com.tilbuci.contraptions.Contraptions;
import openfl.geom.Point;
import com.tilbuci.ui.PlayerTheme;
import haxe.io.Bytes;

/** OPENFL **/
import openfl.text.StyleSheet;

/** TILBUCI **/
import com.tilbuci.def.MovieData;
import com.tilbuci.plugin.Plugin;
import com.tilbuci.ws.WebserviceP;
import com.tilbuci.data.BuildInfo;
import com.tilbuci.data.MovieInfo;
import com.tilbuci.script.ScriptParser;
import com.tilbuci.player.MovieArea;
#if (js && html5)
    import com.tilbuci.js.ExternBrowser;
#end

/**
    Values/objects required everywhere.
**/
class GlobalPlayer {

    /**
        current player session identifier
    **/
    public static var session:String = '';

    /**
        system ready?
    **/
    public static var ready:Bool = false;

    /**
        player current mode
    **/
    public static var mode:String = 'player';

    /**
        web render mode
    **/
    public static var render:String = 'webgl';

    /**
        browser url and share mode
    **/
    public static var share:String = 'scene';

    /**
        fps handling mode
    **/
    public static var fps:String = 'free';

    /**
        build information
    **/
    public static var build:BuildInfo = null;

    /**
        avoid cache on server requests?
    **/
    public static var nocache:Bool = true;

    /**
        server available?
    **/
    public static var server:Bool = false;

    /**
        base url
    **/
    public static var base:String = '';

    /**
        font url
    **/
    public static var font:String = '';

    /**
        decryption secret
    **/
    public static var secret:Bytes = null;

    /**
        webservice
    **/
    public static var ws:WebserviceP = null;

    /**
        language data
    **/
    public static var ln:Language = null;

    /**
        current movie info
    **/
    public static var movie:MovieInfo = null;

    /**
        movie being loaded
    **/
    public static var loadingMovie:String = '';

    /**
        current movie data
    **/
    public static var mdata:MovieData = null;

    /**
        movie display area
    **/
    public static var area:MovieArea = null;

    /**
        action script parser
    **/
    public static var parser:ScriptParser = null;

    /**
        display size multiply level
    **/
    public static var multiply:Int = 1;

    /**
        display orientation
    **/
    public static var orientation:String = 'horizontal';

    /**
        current movie path
    **/
    public static var path:String = '';

    /**
        current secret key set
    **/
    public static var secretKey:String = '';

    /**
        loaded plugins
    **/
    public static var plugins:Map<String, Plugin> = [ ];

    /**
        html text styles
    **/
    public static var style:StyleSheet = new StyleSheet();

    /**
        contraptions information
    **/
    public static var contraptions:Contraptions = new Contraptions();

    /**
        narrative information
    **/
    public static var narrative:Narrative = new Narrative();

    /**
        current movie ui theme
    **/
    public static var theme:PlayerTheme = null;

    /**
        movie named actions
    **/
    public static var mvActions:Map<String, String> = [ ];

    /**
        callback function for events
    **/
    public static var callback:Dynamic = null;

    /**
        actual content position relative to the stage area
    **/
    public static var contentPosition:Point = new Point();

    /**
        actual content width
    **/
    public static var contentWidth:Float = 0;

    /**
        actual content height
    **/
    public static var contentHeight:Float = 0;

    /**
        target interaction move step
    **/
    public static var usingTarget:Int = 0;

    /**
        is the mouse cursor visible?
    **/
    public static var cursorVisible:Bool = true;

    /**
        can the content trigger actions?
    **/
    public static var canTrigger:Bool = true;

    /**
        scene load history
    **/
    public static var history:Array<String> = [ ];

    /**
        Copies a text to the clipboard.
        @param  text    the text to copy
        @return was the text copied?
    **/
    public static function copyText(text:String):Bool {
        #if (js && html5)
            var ok:Bool = false;
            try {
                ExternBrowser.TBB_copyText(text);
                ok = true;
            } catch (e) { 
                trace (text);
                ok = false;
            }
            return (ok);
        #else 
            return (false);
        #end
    }

    /**
        Is runing from a mobice device?
    **/
    public static function isMobile():Bool {
        #if (js && html5)
            var ok:Bool = true;
            try {
                ok = ExternBrowser.TBB_isMobile();
            } catch (e) { 
                ok = true;
            }
            return (ok);
        #else 
            return (true);
        #end
    }

    /**
        Quits a desktop application.
        @return was the quit command sent?
    **/
    public static function appQuit():Bool {
        #if (js && html5)
            var ok:Bool = false;
            try {
                #if runtimedesktop
                    ExternBrowser.TBB_appQuit();
                    ok = true;
                #elseif runtimemobile
                    ExternBrowser.TBB_appQuitCapacitor();
                    ok = true;
                #else
                    ok = false;
                #end
            } catch (e) { 
                ok = false;
            }
            return (ok);
        #else 
            return (false);
        #end
    }

    /**
        Quits a desktop application.
        @return was the quit command sent?
    **/
    public static function pwaInstall():Bool {
        #if (js && html5)
            var ok:Bool = false;
            try {
                ExternBrowser.TBB_showInstallPrompt();
                ok = true;
            } catch (e) { 
                ok = false;
            }
            return (ok);
        #else 
            return (false);
        #end
    }

    /**
        Enters fullscreen.
        @return was the quit command sent?
    **/
    public static function fullscreen():Bool {
        #if (js && html5)
            var ok:Bool = false;
            try {
                ExternBrowser.TBB_fullscreen();
                ok = true;
            } catch (e) { 
                ok = false;
            }
            return (ok);
        #else 
            return (false);
        #end
    }

    /**
        Saves a text file.
        @param  name    the file name
        @param  content the file content
        @return was the file saved?
    **/
    public static function saveFile(name:String, content:String):Bool {
        var ok:Bool = false;
        #if runtimedesktop
            try {
                ExternBrowser.TBB_saveFileElectron(name, content);
                ok = true;
            } catch (e) { 
                ok = false;
            }
        #elseif runtimemobile
            try {
                ExternBrowser.TBB_saveFileCapacitor(name, content);
                ok = true;
            } catch (e) { 
                ok = false;
            }
        #else
            try {
                ExternBrowser.TBB_saveFile(name, content);
                ok = true;
            } catch (e) { 
                ok = false;
            }
        #end
        return (ok);
    }

    /**
        Checks if a file exists at the user folder.
        @param  name    the file name
        @return does the file exist and can be readed?
    **/
    public static function existsFile(name:String):Bool {
        var ok:Bool = false;
        #if runtimedesktop
            try {
                ok = ExternBrowser.TBB_existsFileElectron(name);
            } catch (e) { 
                ok = false;
            }
        #elseif runtimemobile
            try {
                ok = ExternBrowser.TBB_existsFileCapacitor(name);
            } catch (e) { 
                ok = false;
            }    
        #end
        return (ok);
    }

    /**
        Loads a text file.
        @param  name        the file name
        @param  ext         the file extension
        @param  callback    method to call on file load
        @return was the load process started?
    **/
    public static function loadFile(name:String, ext:String, callback:Dynamic):Bool {
        var ok:Bool = false;
        #if runtimedesktop
            try {
                ExternBrowser.TBB_loadFileElectron(name, callback);
                ok = true;
            } catch (e) { 
                ok = false;
            }
        #elseif runtimemobile
            try {
                ExternBrowser.TBB_loadFileCapacitor(name, callback);
                ok = true;
            } catch (e) { 
                ok = false;
            }
        #else
            try {
                ExternBrowser.TBB_loadFile(ext, callback);
                ok = true;
            } catch (e) { 
                ok = false;
            }
        #end
        return (ok);
    }

}