/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/**
 * Tilbuci javascript externs for file upload.
 */

// preparing javascript api
window.BlobBuilder = window.MozBlobBuilder || window.WebKitBlobBuilder || window.BlobBuilder;

// upload variables
var TBU_filedata;				// selected file data
var TBU_piecesize = 524288;		// file "piece" size (512kb)
var TBU_originalsize;			// file original size
var TBU_start;					// file data start position
var TBU_end;					// file data end position
var TBU_part;					// file piece number
var TBU_total;					// file piece total number
var TBU_chunk;					// current file data piece
var TBU_xhr;					// uploader request
var TBU_info_a;					// Tilbuci upload information: action
var TBU_info_r;					// Tilbuci upload information: request
var TBU_info_u;					// Tilbuci upload information: user
var TBU_info_s;					// Tilbuci upload information: signature
var TBU_info_url				// upload script url
var TBU_uploading = false;		// currently uploading a file?


// creating the file input element
var TBU_input = document.createElement("input");
TBU_input.setAttribute("type", "file");
TBU_input.setAttribute("name", "TBU_input");
TBU_input.setAttribute("onChange", "TBU_fileSelected();");

/**
 * Start browsing for a file.
 * @param	accept	file extensions to accept
 */
function TBU_browse(accept) {
	TBU_input.accept = accept;
	TBU_input.click();
}

/**
 * A new file was selected.
 */
function TBU_fileSelected() {
	var file = TBU_input.files[0];
	if (file) {
		var fileSize = 0;
		if (file.size > 1024 * 1024) {
			fileSize = (Math.round(file.size * 100 / (1024 * 1024)) / 100).toString() + "MB";
		} else {
			fileSize = (Math.round(file.size * 100 / 1024) / 100).toString() + "KB";
		}
		TBU_total = Math.ceil(file.size / TBU_piecesize);
		TBU_setFile(file.name, fileSize, file.type, TBU_total);
	}
}

/**
 * Upload the selected file.
 */
function TBU_upload(a, r, u, s, url) {
	TBU_uploading = true;
	TBU_info_a = a;
	TBU_info_r = r;
	TBU_info_u = u;
	TBU_info_s = s;
	TBU_info_url = url;
    TBU_filedata = TBU_input.files[0];
	TBU_originalsize = TBU_filedata.size;
	TBU_start = 0;                
	TBU_part = 0;
	TBU_end = TBU_piecesize;
    TBU_chunk = TBU_filedata.slice(TBU_start, TBU_end);
    TBU_uploadFile(TBU_chunk, TBU_part);
    TBU_start = TBU_end;
    TBU_end = TBU_start + TBU_piecesize;
    TBU_part = TBU_part + 1;
}

/**
 * Upload a file piece.
 */
function TBU_uploadFile(fileData, part) {
	var file = TBU_input.files[0];  
	var fd = new FormData();
	fd.append("TBU_file", fileData);
	fd.append("a", TBU_info_a);
	fd.append("r", TBU_info_r);
	fd.append("u", TBU_info_u);
	fd.append("s", TBU_info_s);
	fd.append("p", TBU_part);
	fd.append("t", TBU_total);
	fd.append("b", TBU_piecesize);
	fd.append("remove", '0');
	TBU_xhr = new XMLHttpRequest();
	TBU_xhr.addEventListener("load", TBU_uploadComplete, false);
	TBU_xhr.addEventListener("error", TBU_uploadFailed, false);
	TBU_xhr.addEventListener("abort", TBU_uploadAborted, false);
	TBU_xhr.open("POST", TBU_info_url);
	TBU_xhr.onload = function(e) { /* nothing to do */ };
	TBU_xhr.setRequestHeader("Cache-Control", "no-cache");
	TBU_xhr.send(fd);
	return;
}

/**
 * File piece upload completed.
 */
function TBU_uploadComplete(evt) {
	TBU_xhr.removeEventListener("load", TBU_uploadComplete, false);
	TBU_xhr.removeEventListener("error", TBU_uploadFailed, false);
	TBU_xhr.removeEventListener("abort", TBU_uploadAborted, false);
	var e = 0;
	try {
		var json = JSON.parse(TBU_xhr.responseText);
		e = 0;
	} catch (error) {
		e = -1;
	}
	TBU_xhr = null;
	if (e == 0) {
		e = json.e;
	}
	if (e == 0) {
		if (TBU_uploading) {
			if (TBU_start < TBU_originalsize) {
				TBU_chunk = TBU_filedata.slice(TBU_start, TBU_end);
				TBU_uploadFile(TBU_chunk, TBU_part);
				TBU_start = TBU_end;
				TBU_end = TBU_start + TBU_piecesize;
				TBU_setProgress(TBU_part, TBU_total, false);
				TBU_part = TBU_part + 1;
			} else {
				TBU_uploading = false;
				TBU_setProgress(TBU_part, TBU_total, true, JSON.stringify(json));
			}
		}
	} else {
		TBU_removeIncomplete();
		TBU_setFailed();
	}
}

/**
 * Remove incomplete file uploads.
 */
function TBU_removeIncomplete() {
	TBU_uploading = false;
	var fd = new FormData();
	fd.append("a", TBU_info_a);
	fd.append("r", TBU_info_r);
	fd.append("u", TBU_info_u);
	fd.append("s", TBU_info_s);
	fd.append("remove", '1');
	xhr = new XMLHttpRequest();
	xhr.open("POST", TBU_info_url);
	xhr.onload = function(e) { /* nothing to do */ };
	xhr.setRequestHeader("Cache-Control", "no-cache");
	xhr.send(fd);
	return;
}

/**
 * File uploaded failed.
 */
function TBU_uploadFailed(evt) {
	TBU_uploading = false;
	TBU_xhr.removeEventListener("load", TBU_uploadComplete, false);
	TBU_xhr.removeEventListener("error", TBU_uploadFailed, false);
	TBU_xhr.removeEventListener("abort", TBU_uploadAborted, false);
	TBU_xhr = null;
	TBU_removeIncomplete();
	TBU_setFailed();
}

/**
 * File upload aborted.
 */
function TBU_uploadAborted(evt) {
	TBU_uploading = false;
	TBU_xhr.abort();
	TBU_xhr.removeEventListener("load", TBU_uploadComplete, false);
	TBU_xhr.removeEventListener("error", TBU_uploadFailed, false);
	TBU_xhr.removeEventListener("abort", TBU_uploadAborted, false);
	TBU_xhr = null;
	TBU_removeIncomplete();
	TBU_setAborted();
}

/**
 * Stops the current upload.
 */
function TBU_cancelUpload() {
	TBU_uploading = false;
	if (TBU_xhr != null) TBU_xhr.abort();
	TBU_removeIncomplete();
	TBU_setAborted();
}