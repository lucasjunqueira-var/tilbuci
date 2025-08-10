/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.js;

#if (js && html5)

@:native("window")
extern class ExternUpload {
    
    /**
        Start browsing for a file.
        @param  accept  extensions to accept
    **/
    static function TBU_browse(accept:String):Void;

    /**
        Starts a selected file upload.
        @param  a   action for upload webservice
        @param  r   upload request
        @param  u   system user
        @param  s   request signature
        @param  url webservice url
    **/
    static function TBU_upload(a:String, r:String, u:String, s:String, url:String):Void;

    /**
        Cancels the current upload process.
    **/
    static function TBU_cancelUpload():Void;

    /**
		Receiving information from external javascript.
		@param	type	the call type
		@param	data	json-encoded string with the passed information
		@return	json-encoded string with error code and additional information
	**/
	/*@:expose("MNU_callback")
    public static function MNU_callback(type:String, data:String):String {
        var ret:String = '{ e: 0 }';
		switch (type) {
			case 'MNU_fileSelected':
				trace ('MNU_fileSelected', data);
			default:
				ret = '{ e: 1 }';
		}
		return (ret);
    }*/
}

#end