/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.data;

/** OPENFL **/
import openfl.Assets;

/** TILBUCI **/
import com.tilbuci.statictools.StringStatic;

class BuildInfo {

    /**
        software version
    **/
    public var version(get, null):String;
    private function get_version():String { return (this._version); }
    private var _version:String = '';

    /**
        build version
    **/
    public var build(get, null):String;
    private function get_build():String { return (this._build); }
    private var _build:String = '';

    /**
        available languages
    **/
    public var languages(get, null):Map<String, String>;
    private function get_languages():Map<String, String> { return (this._languages); }
    private var _languages:Map<String, String> = [ ];

    /**
        available thanks
    **/
    public var thanks(get, null):Array<String>;
    private function get_thanks():Array<String> { return (this._thanks); }
    private var _thanks:Array<String> = [ ];

    /**
        Constructor.
    **/
    public function new(showinfo:Bool = true) {
        if (showinfo) {
            var str:String = Assets.getText('buildInfo');
            var file:Dynamic = StringStatic.jsonParse(str);
            if (file == false) {
                // nothing to do
            } else {
                this._version = Reflect.field(file, 'version');
                this._build = Reflect.field(file, 'build');
                for (n in Reflect.fields(Reflect.field(file, 'languages'))) {
                    this._languages[n] = Reflect.field(Reflect.field(file, 'languages'), n);
                }
                for (n in Reflect.fields(Reflect.field(file, 'thanks'))) this._thanks.push(Reflect.field(Reflect.field(file, 'thanks'), n));
                trace ('Tilbuci player ' + this._version + ' build ' + this._build + '.');
            }
        } else {
            this._version = 'custom';
            this._build = 'custom';
        }
    }

}