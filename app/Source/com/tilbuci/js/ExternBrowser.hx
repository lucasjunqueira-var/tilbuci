/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.js;

#if (js && html5)

@:native("window")
extern class ExternBrowser {
    
    /**
        Sets the browser address bar content.
        @param  url the new address
        @param  title   the new title
    **/
    static function TBB_setAddress(url:String, title:String):Void;

    /**
        Copies a text to the clipboard.
        @param  text    the text to copy
    **/
    static function TBB_copyText(text:String):Void;

    /**
        Quits a desktop application.
    **/
    static function TBB_appQuit():Void;

    /**
        Shows the entire page on fullscreen.
    **/
    static function TBB_fullscreen():Void;

    /**
        Checks if running from a mobile device.
    **/
    static function TBB_isMobile():Bool;

    /**
        Checks if running from an iPhone or an iPad.
    **/
    static function TBB_isIos():Bool;

    /**
        Shows a PWA install prompt.
    **/
    static function TBB_showInstallPrompt():Void;

    /**
       Running from an installed pwa?
    **/
    static function TBB_installedPwa():Bool;

    /**
        Saves a text file from browser.
        @param  name    the file name
        @param  content the file content
    **/
    static function TBB_saveFile(name:String, content:String):Bool;

    /**
        Saves a text file from electron runtime.
        @param  name    the file name
        @param  content the file content
    **/
    static function TBB_saveFileElectron(name:String, content:String):Void;

    /**
        Loads a text file from browser.
        @param  ext     the file extension
        @param  callback    method to call on file load
    **/
    static function TBB_loadFile(ext:String, callback:Dynamic):Void;

    /**
        Loads a text file from electron runtime.
        @param  ext     the file name
        @param  callback    method to call on file load
    **/
    static function TBB_loadFileElectron(name:String, callback:Dynamic):Void;

    /**
        Checks if a file exists in user folder on electron runtime.
        @param  name    the file name
    **/
    static function TBB_existsFileElectron(name:String):Bool;

}

#end