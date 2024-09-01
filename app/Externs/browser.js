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
 * Quits a desktop application.
 */
function TBB_appQuit() {
    nw.App.closeAllWindows();
}