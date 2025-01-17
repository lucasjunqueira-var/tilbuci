/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

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