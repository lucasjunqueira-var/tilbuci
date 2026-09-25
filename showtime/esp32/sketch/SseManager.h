/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

// ============================================================================
//  SseManager - global sendAction() helper for the SSE channel
// ----------------------------------------------------------------------------
//  Declares the sendAction() function used to push an action string to all
//  connected pages through the SSE channel. The page receives the text and
//  passes it to "tilbuci_runaction".
//
//  Include this header in any file that needs to call sendAction().
// ============================================================================

#ifndef SSE_MANAGER_H
#define SSE_MANAGER_H

#include <Arduino.h>

// Sends a command string to all connected pages through the SSE channel. The
// page receives the text and passes it to "tilbuci_runaction". This function
// can be called from anywhere in the sketch.
void sendAction(const String& text);

#endif // SSE_MANAGER_H
