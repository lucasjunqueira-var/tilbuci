package com.tilbuci.data;

/** OPENFL **/
import openfl.display.Stage;

/** FEATHERS UI **/
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.plugin.Plugin;
import com.tilbuci.ws.Webservice;
import com.tilbuci.data.Language;
import com.tilbuci.data.FileUpload;
import com.tilbuci.data.EditorConfig;
import com.tilbuci.ui.base.ConfirmWindow;
import com.tilbuci.ui.component.WindowAction;
#if (js && html5)
    import com.tilbuci.js.ExternBrowser;
#end

/**
    Values/objects required everywhere.
**/
class Global {

    /** GLOBAL SETS **/

    /**
        maximum  area size
    **/
    public static inline var AREASIZE_MAX:Float = 3840;    

    /**
        minimum  area size
    **/
    public static inline var AREASIZE_MIN:Float = 100;

    /** GLOBAL VARIABLES **/

    /**
        editor configuration
    **/
    public static var econfig:EditorConfig = null;

    /**
        single user?
    **/
    public static var singleUser:Bool = false;

    /**
        current user access level
    **/
    public static var userLevel:Int = -1;

    /**
        valid e-mail configuration?
    **/
    public static var validEmail:Bool = false;

    /**
        available fonts
    **/
    public static var fonts:Array<String> = [ ];

    /**
        language reference
    **/
    public static var ln:Language = null;

    /**
        webservice access
    **/
    public static var ws:Webservice = null;

    /**
        file uploader
    **/
    public static var up:FileUpload = null;

    /**
        is the current use the movie owner?
    **/
    public static var mvOwner:Bool = false;

    /**
        is the current use a movie collaborator?
    **/
    public static var mvCollaborator:Bool = false;

    /**
        available plugins
    **/
    public static var plugins:Map<String, Plugin> = [ ];

    /**
        display stage
    **/
    public static var stage:Stage;

    /**
        temporary information
    **/
    public static var temp:Map<String, Map<String, Dynamic>> = [ ];

    /**
        current display type
    **/
    public static var displayType:String = 'landscape';

    /**
        scene to open after a movie load
    **/
    public static var sceneToLoad:String = '';

    /**
        current scene information
    **/
    public static var sceneObj:Dynamic = null;

    /**
        keyframe to open after a scene load
    **/
    public static var kfToLoad:Int = -1;

    /**
        state history
    **/
    public static var history:History;

    /**
        actions to run on editor interface
    **/
    public static var editorActions:Dynamic = null;

    /**
        multi use action edit window
    **/    
    public static var acwindow:WindowAction;

    /**
        Shows the action editing window.
        @param  current current action text
        @param  onOk    action to call on ok button click (must receive a string parameter with the new action text)
        @param  onCancel    action to call on cancel button click
    **/
    public static function showActionWindow(current:String, onOk:Dynamic, onCancel:Dynamic = null):Void {
        if (Global.acwindow == null) {
            Global.acwindow = new WindowAction();
            Global.acwindow.startInterface();
        }
        Global.acwindow.setContent(current, onOk, onCancel);
        PopUpManager.addPopUp(Global.acwindow, Global.stage);
    }

    /**
        Shows a popup window.
        @param  tit popup title
        @param  txt popup text 
        @param  wd  popup width
        @param  ht  popup height
        @param  oktxt   ok button text
        @param  ac  action to call on button click (receives a single bool parameter)
        @param  mode    the window mode (just warning or confirm)
        @param  canceltxt   cancel button text
    **/
    public static function showPopup(tit:String, txt:String, wd:Int, ht:Int, oktxt:String, ac:Dynamic = null, mode:String = 'warn', canceltxt:String = ''):Void {
        var cf:ConfirmWindow = new ConfirmWindow(tit, txt, wd, ht, oktxt, ac, mode, canceltxt);
        PopUpManager.addPopUp(cf, Global.stage);
    }

    /**
        Shows a small message on screen bottom.
        @param  txt the text to show
    **/
    public static var showMsg:Dynamic = null;

    /**
        Shows a system window.
        @param  txt the window id.
    **/
    public static var showWindow:Dynamic = null;

    /**
        Sets the browser address bar content.
        @param  url the new address
        @param  title   the new title
        @return was the address changed?
    **/
    public static function setBrowserAddress(url:String, title:String):Bool {
        #if (js && html5)
            ExternBrowser.TBB_setAddress(url, title);
            return (true);
        #else 
            return (false);
        #end
    }

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

}