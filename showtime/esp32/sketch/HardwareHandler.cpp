/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 // ============================================================================
//  HardwareHandler - user-customizable hardware reactions (implementation)
// ============================================================================
//
//  INSTRUCTIONS (READ ME):
//  ---------------------------------------------------------------------------
//  This file is the place to customize how the board's hardware reacts to the
//  "/api/hardware" command sent by the content page running in the browser.
//  Edit this file manually to add or change the reactions.
//
//  The "handle()" method below receives the "command" GET parameter already
//  split by the "|" character in a vector called "parts":
//    parts[0]       -> the switch key (the first element)
//    parts[1..n]    -> extra parameters for the selected case
//  The vector size is variable.
//
//  HOW TO ADD A REACTION:
//    Add a new "else if (key == ...)" block inside handle(). Example:
//
//      // /api/hardware?command=led|on  -> turns the built-in LED on
//      else if (key == "led") {
//        bool on = parts.size() > 1 && parts[1] == "on";
//        digitalWrite(13, on ? HIGH : LOW);
//      }
// ============================================================================

#include "HardwareHandler.h"
#include "SseManager.h"

void HardwareHandler::handle(const std::vector<String>& parts) {
  if (parts.empty()) {
    return;
  }

  // Switch key: the first element of the array.
  const String& key = parts[0];

  // ---------------------------------------------------------------------------
  // Add your hardware reactions below (edit this file manually).
  // Replace the example below with the reactions your hardware needs.
  // ---------------------------------------------------------------------------

  // Example reaction:
  //   /api/hardware?command=led|on  /  /api/hardware?command=led|off
  if (key == "led") {
    bool on = parts.size() > 1 && parts[1] == "on";
    digitalWrite(13, on ? HIGH : LOW);
  } /*else if (key == "other") {
    Serial.println("=== other hardware command ===");
  }*/
 
  // Add more "else if" blocks here, for example:
  //   else if (key == "servo") {
  //     int angle = parts.size() > 1 ? parts[1].toInt() : 0;
  //     // ... move a servo to 'angle' ...
  //   }
  //   else if (key == "relay") {
  //     // ... toggle a relay using parts[1] ...
  //   }
}
