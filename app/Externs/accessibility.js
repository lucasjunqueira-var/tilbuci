/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/**
 * Tilbuci javascript externs for accessibility.
 */

/**
 * Sets the alt text for an HTML element.
 * @param {*} element   the element type
 * @param {*} path      the loaded file path 
 * @param {*} alt       the alt text
 */
function TBA_setAlt(element, path, alt) {
    var elems = document.querySelectorAll('#TilBuciArea ' + element + '[src$="' + path + '"]');
    elems.forEach(function(el) {
        el.alt = alt;
    });
}