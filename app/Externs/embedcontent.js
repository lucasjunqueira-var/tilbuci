/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

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