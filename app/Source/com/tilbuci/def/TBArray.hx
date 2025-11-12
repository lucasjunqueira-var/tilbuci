/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package com.tilbuci.def;

import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.GlobalPlayer;

class TBArray {

    private var _data:Array<String> = [ ];

    private var _cursor:Int = -1;

    public function new() {
        this._data = [ ];
        this._cursor = -1;
    }

    public function kill():Void {
        while (this._data.length > 0) this._data.shift();
        this._data = null;
    }

    public function current():String {
        if ((this._cursor < 0) && (this._data.length > 0)) this._cursor = 0;
        if ((this._cursor >= 0) && (this._data.length > this._cursor)) {
            return (GlobalPlayer.parser.parseString(this._data[this._cursor]));
        } else {
            return ('');
        }
    }

    public function currentInt():Int {
        if ((this._cursor < 0) && (this._data.length > 0)) this._cursor = 0;
        if ((this._cursor >= 0) && (this._data.length > this._cursor)) {
            return (GlobalPlayer.parser.parseInt(this._data[this._cursor]));
        } else {
            return (0);
        }
    }

    public function currentFloat():Float {
        if ((this._cursor < 0) && (this._data.length > 0)) this._cursor = 0;
        if ((this._cursor >= 0) && (this._data.length > this._cursor)) {
            return (GlobalPlayer.parser.parseFloat(this._data[this._cursor]));
        } else {
            return (0);
        }
    }

    public function currentBool():Bool {
        if ((this._cursor < 0) && (this._data.length > 0)) this._cursor = 0;
        if ((this._cursor >= 0) && (this._data.length > this._cursor)) {
            return (GlobalPlayer.parser.parseBool(this._data[this._cursor]));
        } else {
            return (false);
        }
    }

    public function next():String {
        this._cursor++;
        if (this._data.length == 0) {
            this._cursor = -1;
        } else if (this._cursor >= this._data.length) {
            this._cursor = 0;
        } else if (this._cursor < 0) {
            this._cursor = this._data.length - 1;
        }
        return (this.current());
    }

    public function nextInt():Int {
        this._cursor++;
        if (this._data.length == 0) {
            this._cursor = -1;
        } else if (this._cursor >= this._data.length) {
            this._cursor = 0;
        } else if (this._cursor < 0) {
            this._cursor = this._data.length - 1;
        }
        return (this.currentInt());
    }

    public function nextFloat():Float {
        this._cursor++;
        if (this._data.length == 0) {
            this._cursor = -1;
        } else if (this._cursor >= this._data.length) {
            this._cursor = 0;
        } else if (this._cursor < 0) {
            this._cursor = this._data.length - 1;
        }
        return (this.currentFloat());
    }

    public function nextBool():Bool {
        this._cursor++;
        if (this._data.length == 0) {
            this._cursor = -1;
        } else if (this._cursor >= this._data.length) {
            this._cursor = 0;
        } else if (this._cursor < 0) {
            this._cursor = this._data.length - 1;
        }
        return (this.currentBool());
    }

    public function previous():String {
        this._cursor--;
        if (this._data.length == 0) {
            this._cursor = -1;
        } else if (this._cursor >= this._data.length) {
            this._cursor = 0;
        } else if (this._cursor < 0) {
            this._cursor = this._data.length - 1;
        }
        return (this.current());
    }

    public function previousInt():Int {
        this._cursor--;
        if (this._data.length == 0) {
            this._cursor = -1;
        } else if (this._cursor >= this._data.length) {
            this._cursor = 0;
        } else if (this._cursor < 0) {
            this._cursor = this._data.length - 1;
        }
        return (this.currentInt());
    }

    public function previousFloat():Float {
        this._cursor--;
        if (this._data.length == 0) {
            this._cursor = -1;
        } else if (this._cursor >= this._data.length) {
            this._cursor = 0;
        } else if (this._cursor < 0) {
            this._cursor = this._data.length - 1;
        }
        return (this.currentFloat());
    }

    public function previousBool():Bool {
        this._cursor--;
        if (this._data.length == 0) {
            this._cursor = -1;
        } else if (this._cursor >= this._data.length) {
            this._cursor = 0;
        } else if (this._cursor < 0) {
            this._cursor = this._data.length - 1;
        }
        return (this.currentBool());
    }

    public function setIndex(to:Int):Void {
        if (this._data.length == 0) {
            this._cursor = -1;
        } else if (to >= this._data.length) {
            this._cursor = this._data.length - 1;
        } else if (to < 0) {
            this._cursor = 0;
        } else {
            this._cursor = to;
        }
    }

    public function currentIndex():Int {
        return (this._cursor);
    }

    public function toJson():String {
        return (StringStatic.jsonStringify(this._data));
    }

    public function fromJson(txt:String):Bool {
        this._data = cast StringStatic.jsonParse(txt);
        if (this._data == null) {
            this._data = [ ];
            this._cursor = -1;
            return (false);
        } else {
            if (this._data.length > 0) {
                this._cursor = 0;
                return (true);
            } else {
                this._cursor = -1;
                return (false);
            }
        }
    }

    public function push(val:String):Void {
        this._data.push(val);
    }

    public function clear():Void {
        while (this._data.length > 0) this._data.shift();
        this._cursor = -1;
    }

    public function set(index:Int, val:String):Void {
        if (index >= 0) {
            while (this._data.length <= index) this._data.push('');
            this._data[index] = val;
        }
    }

    public function get(index:Int):String {
        if ((index >= 0) && (this._data.length > index)) {
            return(GlobalPlayer.parser.parseString(this._data[index]));
        } else {
            return ('');
        }
    }

    public function getInt(index:Int):Int {
        if ((index >= 0) && (this._data.length > index)) {
            return(GlobalPlayer.parser.parseInt(this._data[index]));
        } else {
            return (0);
        }
    }

    public function getFloat(index:Int):Float {
        if ((index >= 0) && (this._data.length > index)) {
            return(GlobalPlayer.parser.parseFloat(this._data[index]));
        } else {
            return (0);
        }
    }

    public function getBool(index:Int):Bool {
        if ((index >= 0) && (this._data.length > index)) {
            return(GlobalPlayer.parser.parseBool(this._data[index]));
        } else {
            return (false);
        }
    }

}