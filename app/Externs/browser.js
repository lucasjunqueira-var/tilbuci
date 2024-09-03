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
    var elem = document.getElementById("TilBuciArea"); 
    if (elem.requestFullscreen) {
        elem.requestFullscreen();
    } else if (elem.webkitRequestFullscreen) {
        elem.webkitRequestFullscreen();
    } else if (elem.msRequestFullscreen) {
        elem.msRequestFullscreen();
    }
}

/**
 * Quits a desktop application.
 */
function TBB_appQuit() {
    nw.App.closeAllWindows();
}