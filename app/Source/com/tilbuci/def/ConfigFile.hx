/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.def;

class ConfigFile {
    /**
        Base URL for the application.
    **/
    public var base:String;

    /**
        Web service URL.
    **/
    public var ws:String;

    /**
        Array of interface language definitions.
    **/
    public var language:Array<InterfaceLang>;
}