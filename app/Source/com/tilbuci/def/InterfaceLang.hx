/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.def;

class InterfaceLang {
    /**
        Language display name.
    **/
    public var name:String;

    /**
        Language file path.
    **/
    public var file:String;

    /**
        Creates a new InterfaceLang instance.
        @param  n   language display name (String)
        @param  f   language file path (String)
    **/
    public function new(n:String, f:String) {
        this.name = n;
        this.file = f;
    }
}