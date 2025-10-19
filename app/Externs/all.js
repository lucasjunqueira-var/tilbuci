/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/**
 * Tilbuci javascript externs for browser handling.
 */

/**
 * Sets the browser address bar content.
 */
function TBB_setAddress(url, title) {
    window.history.pushState({
        "html": url, 
        "pageTitle": title
    }, title, url);
}

/**
 * Copies a content to the clipboard.
 */
function TBB_copyText(text) {
    navigator.clipboard.writeText(text);
}

/**
 * Shows the entire page on fullscreen.
 */
function TBB_fullscreen() {
    if (!document.fullscreenElement) {
        var elem = document.getElementById("TilBuciArea"); 
        if (elem.requestFullscreen) {
            elem.requestFullscreen();
        } else if (elem.webkitRequestFullscreen) {
            elem.webkitRequestFullscreen();
        } else if (elem.msRequestFullscreen) {
            elem.msRequestFullscreen();
        }
    } else {
        document.exitFullscreen();
    }
}

/**
 * Quits a desktop application.
 */
function TBB_appQuit() {
    window.electronAPI.quitApp();
}

/**
 * Checks if running from a mobile device.
 */
function TBB_isMobile() {
    let check = false;
    (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino|android|ipad|playbook|silk/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))) check = true;})(navigator.userAgent||navigator.vendor||window.opera);
    return check;
}

/**
 * Checks if running from an iPhone or an iPad.
 */
function TBB_isIos() {
    if (TBB_isMobile()) {
        const userAgent = window.navigator.userAgent.toLowerCase();
        return (/iphone|ipad|ipod/.test(userAgent));
    } else {
        return (false);
    }
}

/**
    Saves a text file from browser.
    @param  name    the file name
    @param  content the file content
**/
function TBB_saveFile(name, content) {
    const blob = new Blob([content], { type: "text/plain" });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = name;
    link.click();
    URL.revokeObjectURL(link.href);
}

/**
    Saves a text file from electron runtime.
    @param  name    the file name
    @param  content the file content
**/
function TBB_saveFileElectron(name, content) {
    window.electronAPI.saveFile(name, content);
}

/**
    Saves a text file from capacitor runtime.
    @param  name    the file name
    @param  content the file content
**/
function TBB_saveFileCapacitor(name, content) {
    TBB_Capacitor_Save(name, content);
}

/**
    Loads a text file from browser.
    @param  ext     the file extension
    @param  callback    method to call on file load
**/
function TBB_loadFile(ext, callback) {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.' + ext;
    input.style.display = 'none';
    input.addEventListener('change', function () {
        if (input.files.length === 0) {
            callback(false, '');
        } else {
            const arquivo = input.files[0];
            if (!arquivo) {
                callback(false, '');
            }
            const leitor = new FileReader();
            leitor.onload = function (e) {
                callback(true, e.target.result);
            };
            leitor.readAsText(arquivo, 'UTF-8');
        }
    });
    document.body.appendChild(input);
    input.click();
    document.body.removeChild(input);
}

/**
    Loads a text file from electron runtime.
    @param  name     the file name
    @param  callback    method to call on file load
**/
function TBB_loadFileElectron(name, callback) {
    window.electronAPI.readFile(name).then(ret => {
        if (ret == "") {
            callback(false, "");
        } else {
            callback(true, ret);
        }
    });
}

/**
    Loads a text file from capacitor runtime.
    @param  name     the file name
    @param  callback    method to call on file load
**/
function TBB_loadFileCapacitor(name, callback) {
    TBB_Capacitor_Load(name).then(ret => {
        if (ret == "") {
            callback(false, "");
        } else {
            callback(true, ret);
        }
    });
}

/**
    Checks if a file exists in user folder on electron runtime.
    @param  name    the file name
**/
function TBB_existsFileElectron(name) {
    window.electronAPI.existsFile(name).then(ok => {
        return (ok);
    });
}

/**
    Checks if a file exists in user folder on electron runtime.
    @param  name    the file name
**/
function TBB_existsFileCapacitor(name) {
    TBB_Capacitor_FileExists(name).then(ok => {
        return (ok);
    });
}

/**
 * Tilbuci javascript externs for HTML5 embed content.
 */

// embed variables
var embed_display = false;
var embed_area = null;
var embed_frame = null;
var tilbuci_resize = [ ];

/**
 * Places the embed area above the TilBuci player.
 * @param src URL to load on embed display
 */
function embed_place(src) {
	if (embed_area == null) embed_area = document.getElementById("embed_area");
	if (embed_frame == null) embed_frame = document.getElementById("embed_frame");
	if ((embed_area != null) && (embed_frame != null)) {
		embed_area.style.display = "block";
		embed_frame.style.width = (embed_area.clientWidth) + "px";
		embed_frame.style.height = (embed_area.clientHeight) + "px";
		embed_frame.style.display = "block";
		embed_frame.src = src;
		embed_display = true;
	}
}

/**
 * Sets the embed content position and size
 * @param {*} x x position
 * @param {*} y y position
 * @param {*} width new width
 * @param {*} height new height
 */
function embed_setposition(x, y, width, height) {
	if (embed_area == null) embed_area = document.getElementById("embed_area");
	if (embed_frame == null) embed_frame = document.getElementById("embed_frame");
	if ((embed_area != null) && (embed_frame != null)) {
		embed_area.style.marginLeft = (x + "px");
		embed_area.style.marginTop = (y + "px");
		embed_area.style.width = (width + "px");
		embed_area.style.height = (height + "px");
		embed_frame.style.width = (width + "px");
		embed_frame.style.height = (height + "px");
	}
}

/**
 * Sets the embed content in full area.
 */
function embed_setfull() {
	if (embed_area == null) embed_area = document.getElementById("embed_area");
	if (embed_frame == null) embed_frame = document.getElementById("embed_frame");
	if ((embed_area != null) && (embed_frame != null)) {
		embed_area.style.marginLeft = ("0px");
		embed_area.style.marginTop = ("0px");
		embed_area.style.width = ("100%");
		embed_area.style.height = ("100%");
		embed_frame.style.width = ("100%");
		embed_frame.style.height = ("100%");
	}
}

/**
 * Adjusts the embed area on stage resize.
 */
function embed_resize() {
	if (embed_display && (embed_area != null) && (embed_frame != null)) {
		embed_frame.style.width = (embed_area.clientWidth) + "px";
		embed_frame.style.height = (embed_area.clientHeight) + "px";
	}
}
tilbuci_resize.push(embed_resize);
window.onresize = function(e) {
    for (var i=0; i<tilbuci_resize.length; i++) {
        tilbuci_resize[i]();
    }
}

/**
 * Closes the overlay display.
 */
function embed_close() {
	if (embed_frame != null) {
		embed_frame.src = "about:blank";
        embed_frame.style.display = "none";
        embed_area.style.display = "none";
	}
}

/**
 * Tilbuci javascript externs for overlay plugin.
 */

// overlay variables
var overlay_display = false;
var overlay_area = null;
var overlay_frame = null;
var overlay_title = null;

/**
 * Places the overlay area above the TilBuci player.
 * @param src URL to load on overlay display
 * @param title the title to show above the overlay content
 */
function overlay_place(src, title) {
	if (overlay_area == null) overlay_area = document.getElementById("overlay_area");
	if (overlay_frame == null) overlay_frame = document.getElementById("overlay_frame");
	if (overlay_title == null) overlay_title = document.getElementById("overlay_title");
	if ((overlay_area != null) && (overlay_frame != null) && (overlay_title != null)) {
		overlay_area.style.display = "block";
		overlay_frame.style.width = (overlay_area.clientWidth - 120) + "px";
		overlay_frame.style.height = (overlay_area.clientHeight - 100) + "px";
		overlay_frame.style.display = "block";
		overlay_frame.src = src;
		overlay_display = true;
		overlay_title.innerHTML = title;
	}
}

/**
 * Adjusts the overlay area on stage resize.
 */
function overlay_resize() {
	if (overlay_display && (overlay_area != null) && (overlay_frame != null)) {
		overlay_frame.style.width = (overlay_area.clientWidth - 120) + "px";
		overlay_frame.style.height = (overlay_area.clientHeight - 100) + "px";
	}
}
tilbuci_resize.push(overlay_resize);

/**
 * Closes the overlay display.
 */
function overlay_close() {
	if (overlay_frame != null) {
		overlay_frame.src = "about:blank";
        overlay_frame.style.display = "none";
        overlay_area.style.display = "none";
        overlay_return();
	}
}

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