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

    /**
        Creates a new TBArray instance with empty data and cursor at -1.
    **/
    public function new() {
        this._data = [ ];
        this._cursor = -1;
    }

    /**
        Releases resources used by the object, clearing the internal array.
    **/
    public function kill():Void {
        while (this._data.length > 0) this._data.shift();
        this._data = null;
    }

    /**
        Returns the current element as a parsed string.
        If cursor is invalid and array not empty, cursor is set to 0.
        @return The parsed string at current cursor position, or empty string if out of bounds.
    **/
    public function current():String {
        if ((this._cursor < 0) && (this._data.length > 0)) this._cursor = 0;
        if ((this._cursor >= 0) && (this._data.length > this._cursor)) {
            return (GlobalPlayer.parser.parseString(this._data[this._cursor]));
        } else {
            return ('');
        }
    }

    /**
        Returns the current element as a parsed integer.
        If cursor is invalid and array not empty, cursor is set to 0.
        @return The parsed integer at current cursor position, or 0 if out of bounds.
    **/
    public function currentInt():Int {
        if ((this._cursor < 0) && (this._data.length > 0)) this._cursor = 0;
        if ((this._cursor >= 0) && (this._data.length > this._cursor)) {
            return (GlobalPlayer.parser.parseInt(this._data[this._cursor]));
        } else {
            return (0);
        }
    }

    /**
        Returns the current element as a parsed float.
        If cursor is invalid and array not empty, cursor is set to 0.
        @return The parsed float at current cursor position, or 0.0 if out of bounds.
    **/
    public function currentFloat():Float {
        if ((this._cursor < 0) && (this._data.length > 0)) this._cursor = 0;
        if ((this._cursor >= 0) && (this._data.length > this._cursor)) {
            return (GlobalPlayer.parser.parseFloat(this._data[this._cursor]));
        } else {
            return (0);
        }
    }

    /**
        Returns the current element as a parsed boolean.
        If cursor is invalid and array not empty, cursor is set to 0.
        @return The parsed boolean at current cursor position, or false if out of bounds.
    **/
    public function currentBool():Bool {
        if ((this._cursor < 0) && (this._data.length > 0)) this._cursor = 0;
        if ((this._cursor >= 0) && (this._data.length > this._cursor)) {
            return (GlobalPlayer.parser.parseBool(this._data[this._cursor]));
        } else {
            return (false);
        }
    }

    /**
        Moves cursor to the next element (circular) and returns its parsed string.
        If array is empty, cursor stays at -1.
        @return The parsed string at the new cursor position.
    **/
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

    /**
        Moves cursor to the next element (circular) and returns its parsed integer.
        If array is empty, cursor stays at -1.
        @return The parsed integer at the new cursor position.
    **/
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

    /**
        Moves cursor to the next element (circular) and returns its parsed float.
        If array is empty, cursor stays at -1.
        @return The parsed float at the new cursor position.
    **/
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

    /**
        Moves cursor to the next element (circular) and returns its parsed boolean.
        If array is empty, cursor stays at -1.
        @return The parsed boolean at the new cursor position.
    **/
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

    /**
        Moves cursor to the previous element (circular) and returns its parsed string.
        If array is empty, cursor stays at -1.
        @return The parsed string at the new cursor position.
    **/
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

    /**
        Moves cursor to the previous element (circular) and returns its parsed integer.
        If array is empty, cursor stays at -1.
        @return The parsed integer at the new cursor position.
    **/
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

    /**
        Moves cursor to the previous element (circular) and returns its parsed float.
        If array is empty, cursor stays at -1.
        @return The parsed float at the new cursor position.
    **/
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

    /**
        Moves cursor to the previous element (circular) and returns its parsed boolean.
        If array is empty, cursor stays at -1.
        @return The parsed boolean at the new cursor position.
    **/
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

    /**
        Sets the cursor to a specific index, clamping to valid range.
        If array is empty, cursor stays at -1.
        @param to The desired index (0-based).
    **/
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

    /**
        Returns the current cursor index.
        @return The current cursor index (0-based) or -1 if no element.
    **/
    public function currentIndex():Int {
        return (this._cursor);
    }

    /**
        Serializes the internal array to a JSON string.
        @return JSON representation of the array.
    **/
    public function toJson():String {
        return (StringStatic.jsonStringify(this._data));
    }

    /**
        Deserializes a JSON string into the internal array.
        @param txt JSON string representing an array of strings.
        @return True if parsing succeeded and array is non‑empty, false otherwise.
    **/
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

    /**
        Appends a string value to the end of the array.
        @param val The string to append.
    **/
    public function push(val:String):Void {
        this._data.push(val);
    }

    /**
        Removes all elements from the array and resets cursor to -1.
    **/
    public function clear():Void {
        while (this._data.length > 0) this._data.shift();
        this._cursor = -1;
    }

    /**
        Sets the element at a given index, expanding the array if necessary.
        @param index The index (0‑based) to set.
        @param val The string value to store.
    **/
    public function set(index:Int, val:String):Void {
        if (index >= 0) {
            while (this._data.length <= index) this._data.push('');
            this._data[index] = val;
        }
    }

    /**
        Retrieves the element at a given index as a parsed string.
        @param index The index (0‑based) to retrieve.
        @return The parsed string at that index, or empty string if out of bounds.
    **/
    public function get(index:Int):String {
        if ((index >= 0) && (this._data.length > index)) {
            return(GlobalPlayer.parser.parseString(this._data[index]));
        } else {
            return ('');
        }
    }

    /**
        Retrieves the element at a given index as a parsed integer.
        @param index The index (0‑based) to retrieve.
        @return The parsed integer at that index, or 0 if out of bounds.
    **/
    public function getInt(index:Int):Int {
        if ((index >= 0) && (this._data.length > index)) {
            return(GlobalPlayer.parser.parseInt(this._data[index]));
        } else {
            return (0);
        }
    }

    /**
        Retrieves the element at a given index as a parsed float.
        @param index The index (0‑based) to retrieve.
        @return The parsed float at that index, or 0.0 if out of bounds.
    **/
    public function getFloat(index:Int):Float {
        if ((index >= 0) && (this._data.length > index)) {
            return(GlobalPlayer.parser.parseFloat(this._data[index]));
        } else {
            return (0);
        }
    }

    /**
        Retrieves the element at a given index as a parsed boolean.
        @param index The index (0‑based) to retrieve.
        @return The parsed boolean at that index, or false if out of bounds.
    **/
    public function getBool(index:Int):Bool {
        if ((index >= 0) && (this._data.length > index)) {
            return(GlobalPlayer.parser.parseBool(this._data[index]));
        } else {
            return (false);
        }
    }

}