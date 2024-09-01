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