/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 // ============================================================================
//  HardwareHandler - user-customizable hardware reactions
// ----------------------------------------------------------------------------
//  This module handles the reactions triggered by the "/api/hardware" command.
//  It is MEANT TO BE EDITED MANUALLY to customize how the board's hardware
//  behaves when the content page sends a "hardware" command.
//
//  HOW IT WORKS:
//    The CommandHandler receives "/api/hardware?command=...", splits the
//    "command" parameter by the "|" character into a vector and calls
//    handle(parts):
//      - parts[0]       -> the switch key (first element)
//      - parts[1..n]    -> additional parameters for the selected case
//    The number of elements is variable.
//
//  HOW TO ADD A REACTION:
//    Open HardwareHandler.cpp and add a new "else if" block following the
//    example provided in the instructions there.
// ============================================================================

#ifndef HARDWARE_HANDLER_H
#define HARDWARE_HANDLER_H

#include <Arduino.h>
#include <vector>

class HardwareHandler {
public:
  // Processes a hardware command. 'parts' is the "command" parameter split by
  // "|": parts[0] is the switch key and the remaining elements are the extra
  // parameters for the selected case.
  void handle(const std::vector<String>& parts);
};

#endif // HARDWARE_HANDLER_H
