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

}

#end