package com.tilbuci.plugin;

import com.tilbuci.ui.window.PopupWindow;

class PluginWindow extends PopupWindow {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(title:String, wd:Int, ht:Int, tabs:Bool = false) {
        super(null, title, wd, ht, tabs);
    }

}