/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

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