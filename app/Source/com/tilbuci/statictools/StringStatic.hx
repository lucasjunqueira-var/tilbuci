/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.statictools;

/** HAXE **/
import haxe.macro.Expr.Catch;
import haxe.crypto.Aes;
import haxe.io.Bytes;
import haxe.crypto.mode.Mode;
import haxe.crypto.padding.Padding;
import haxe.crypto.Md5;
import haxe.Json;
import haxe.crypto.Base64;

/**
    String-related static tools.
**/
class StringStatic
{
    /**
        Checks an URL for ending slash.
        @param  url the url to check
        @return the url with an ending slash
    **/
    public static function slashURL(url:String):String {
        if (url.charAt(url.length - 1) == '/') {
            return (url);
        } else {
            return (url + '/');
        }
    }

    /**
        Parses a json-encoded string.
        @param  txt the text to parse
        @return the parsed object or false on error
    **/
    public static function jsonParse(txt:String):Dynamic {
        var json:Dynamic = null;
        try {
            json = haxe.Json.parse(txt);
        } catch (e) {
            json = false;
        }
        return (json);
    }

    /**
        Converts an objet do JSON notation.
        @param  data    the object to convert
        @param  space   pretty-print the json ident char (null for none)
        @return a json-formatted string
    **/
    public static function jsonStringify(data:Dynamic, space:String = null):String {
        return (Json.stringify(data, null, space));
    }

    /**
        Created a map (String, Dybamic) from a json-encoded string.
        @param  data    the json string
        @return the values map
    **/
    public static function jsonAsMap(data:String):Map<String, Dynamic> {
        var map:Map<String, Dynamic> = [ ];
        var js:Dynamic = StringStatic.jsonParse(data);
        if (js == false) {
            // nothing to do
        } else {
            for (k in Reflect.fields(js)) map[k] = Reflect.field(js, k);
        }
        return (map);
    }

    /**
        Produces a MD5 hash from the given string.
        @param  txt the text to hash
        @return the MD5 hash
    **/
    public static function md5(txt:String):String {
        return(Md5.encode(txt));
    }

    /**
        Validates an e-mail address.
        @param  email   the string to check
        @return is the sring a valid e-mail address?
    **/
    public static function validateEmail(email:String):Bool {
        var ereg = ~/.+@.+/i;
        return (ereg.match(email));
    }

    /**
        Checks if a string contains any of the provided substrings (cas insensitive).
        @param  str the string to check
        @param  check a list of substrings to check
        @return any of the provided substrings were found?
    **/
    public static function stringContains(str:String, check:Array<String>):Bool {
        str = str.toLowerCase();
        var has:Bool = false;
        for (n in 0...check.length) {
            if (StringTools.contains(str, check[n].toLowerCase())) has = true;
        }
        return (has);
    }

    /**
        Encrypts a movie key.
        @param  txt the string to encrypt
        @param  key the encryption key
        @param  secret  the system "secret"
        @return the encrypted string in HEX form
    **/
    public static function encryptKey(txt:String, key:String, secret:Bytes):String {
        var bytestxt:Bytes = Bytes.ofString(txt);
        var byteskey:Bytes = Bytes.ofString(key);
        var aes:Aes = new Aes(byteskey, secret);
        return (aes.encrypt(Mode.CTR, bytestxt, Padding.NoPadding).toHex());
    }

    /**
        Decrypts a movie key.
        @param  txt the encrypted string (HEX form)
        @param  key the encryption key
        @return the decrypted string
    **/
    public static function decryptKey(txt:String, key:String, secret:Bytes):String {
        var bytestxt:Bytes = Bytes.ofHex(txt);
        var byteskey:Bytes = Bytes.ofString(key);
        var aes:Aes = new Aes(byteskey, secret);
        return (aes.decrypt(Mode.CTR, bytestxt, Padding.NoPadding).toString());
    }

    /**
        Decrypts a loaded string.
        @param  txt the encrypted string (HEX form)
        @param  key the encryption key
        @return the decrypted string
    **/
    public static function decrypt(txt:String, key:String):String {
        txt = txt.substr(0, (txt.length - 10)) + txt.substr(-9);
        txt = txt.substr(2);
        try {
            var combined = Base64.decode(txt);
            var iv = combined.sub(0, 16);
            var ciphertext = combined.sub(16, combined.length - 16);
            var keyBytes = Bytes.ofString(key);
            var aes = new Aes();
            aes.init(keyBytes, iv);
            var decrypted = aes.decrypt(Mode.CBC, ciphertext, Padding.PKCS7);
            txt = decrypted.toString();
        } catch (e) {
            txt = '';
        }
        return (txt);
    }

    /**
        Encrypts a string.
        @param  txt the string to encrypt.
        @param  key the encryption key
        @return the encrypted string
    **/
    public static function encrypt(txt:String, key:String):String {
        var aes = new Aes();
        var keyBytes = Bytes.ofString(key);
        var iv = Bytes.ofString(StringStatic.random().substr(0, 16));
        aes.init(keyBytes, iv);
        var txtbytes = Bytes.ofString(txt);
        var combined = Bytes.alloc(iv.length + txtbytes.length);
        combined.blit(0, iv, 0, iv.length);
        combined.blit(iv.length, txtbytes, 0, txtbytes.length);
        var encrypted = aes.encrypt(Mode.CBC, combined, Padding.PKCS7);
        txt = Base64.encode(encrypted);
        txt = 'TB' + txt.substr(0, (txt.length - 9)) + 'b' + txt.substr(-9);
        return (txt);
    }

    /**
        Convert color components (red, gree, blue) to hex notation (0x000000).
        @param  red the red component
        @param  green   the green component
        @param  blue    the blue component
        @return hex notation
    **/
    public static function rgbToHex(red:Float, green:Float, blue:Float):String {
        var hex:String = '0x';
        if (red < 16) {
            hex += '0' + StringTools.hex(Math.round(red));
        } else if (red > 255) {
            hex += 'FF';
        } else {
            hex += StringTools.hex(Math.round(red));
        }
        if (green < 16) {
            hex += '0' + StringTools.hex(Math.round(green));
        } else if (green > 255) {
            hex += 'FF';
        } else {
            hex += StringTools.hex(Math.round(green));
        }
        if (blue < 16) {
            hex += '0' + StringTools.hex(Math.round(blue));
        } else if (blue > 255) {
            hex += 'FF';
        } else {
            hex += StringTools.hex(Math.round(blue));
        }
        return (hex);
    }

    /**
        Converts a color string to HEX format.
        @param  color   the color string
        @param  onerror default color to return on conversion error
        @return a valid color string starting with #
    **/
    public static function colorHex(color:String, onerror:String = '#FFFFFF'):String {
        if (color == null) color = onerror;
        color = StringTools.replace(color, '#', '0x');
        if (color.substr(0, 2) != '0x') color = '0x' + color;
        var col:Int = Std.parseInt(color);
        if (col == null) {
            color = onerror;
        } else {
            color = '#' + StringTools.hex(col, 6);
        }
        return (color.toUpperCase());
    }

    /**
        Converts a string to a color int value.
        @param  colorstr    the color string to covert
        @param  onerror color to set on error
        @return an int color value
    **/
    public static function colorInt(colorstr:String, onerror:String = '0xFFFFFF'):Int {
        colorstr = StringTools.replace(colorstr, '#', '0x');
        if ((colorstr.substr(0, 2) != '0x') && (colorstr.substr(0, 2) != '0X')) {
            colorstr = '0x' + colorstr;
        }
        var colorint:Int = Std.parseInt(colorstr);
        if (colorint == null) colorint = Std.parseInt(onerror);
        return (colorint);
    }

    /**
        Creates a random string with 32 chars.
        @return a random string
    **/
    public static function random():String {
        return(StringStatic.md5(Std.string(Math.random() * 100000)));
    }
}