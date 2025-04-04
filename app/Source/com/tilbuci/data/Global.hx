/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.data;

/** OPENFL **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.ui.component.BlockArea.BlockAction;
import com.tilbuci.ui.component.WindowBlockEdit;
import com.tilbuci.ui.component.WindowActionBlock;
import com.tilbuci.script.ActionInfo;
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

/** HAXE PARSER **/
#if !tilbuciplayer
    import hscript.Interp;
    import hscript.Parser;
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
        available actions information
    **/
    public static var acInfo:ActionInfo;

    /**
        actions to run on editor interface
    **/
    public static var editorActions:Dynamic = null;

    /**
        multi use action edit window
    **/    
    public static var acwindow:WindowAction;

    /**
        multi use new block action window
    **/    
    public static var acblock:WindowActionBlock;

    /**
        multi use edit block action window
    **/    
    public static var edblock:WindowBlockEdit;

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
        Shows the new action block window.
        @param  onOk    action to call on ok button click
    **/
    public static function showNewBlockWindow(onOk:Dynamic):Void {
        if (Global.acblock == null) {
            Global.acblock = new WindowActionBlock();
            Global.acblock.startInterface();
        }
        Global.acInfo.loadInfo();
        Global.acblock.setContent(onOk);
        PopUpManager.addPopUp(Global.acblock, Global.stage);
    }

    /**
        Shows the edit action block window.
        @param  onOk    action to call on ok button click
        @param  index   the action index (-1 for new)
    **/
    public static function showEditBlockWindow(ac:String, onOk:Dynamic, index:Int = -1, current:BlockAction = null):Void {
        if (Global.edblock == null) {
            Global.edblock = new WindowBlockEdit();
            Global.edblock.startInterface();
        }
        Global.edblock.setContent(ac, onOk, index, current);
        PopUpManager.addPopUp(Global.edblock, Global.stage);
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
        Haxe expression parser.
    **/
    #if !tilbuciplayer
        public static var parser:Parser;
    #end

    /**
        Haxe expression interpreter.
    **/
    #if !tilbuciplayer
        public static var interp:Interp;
    #end

    /**
        Evaluates a haxe expression.
        @param  expr    the expression
        @return the result or null on failure
    **/
    public static function evaluate(expr:String):Dynamic {
        #if !tilbuciplayer
            if (Global.parser == null) Global.parser = new Parser();
            if (Global.interp == null) Global.interp = new Interp();
            var ret:Dynamic;
            try {
                ret = Global.interp.execute(Global.parser.parseString(expr));
            } catch (e) {
                ret = null;
            }
            return (ret);
        #else
            return (null);
        #end
    }

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