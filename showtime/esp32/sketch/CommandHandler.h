/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 // ============================================================================
//  CommandHandler - "/api/[command]" route handling
// ----------------------------------------------------------------------------
//  This module processes the calls made by connected devices to the
//  "/api/[command]" route of the web server (e.g.
//  "http://192.168.4.1/api/setval?set=foo&value=bar").
//
//  HOW TO ADD A NEW COMMAND:
//    1. Add a dispatch entry for the command name in handle().
//    2. Implement the command logic in a private method of this class.
//    3. Document the command (parameters, action, return value) in the comment
//       above the method.
//
//  Rules applied to every command:
//    * REST/GET parameters arrive already URL-decoded in the 'params' map.
//    * If any mandatory parameter is missing, the command action is NOT
//      executed and the method returns an empty string.
//    * The returned string is sent back to the caller as "text/plain".
// ============================================================================

#ifndef COMMAND_HANDLER_H
#define COMMAND_HANDLER_H

#include <Arduino.h>
#include <map>
#include "CardManager.h"
#include "HardwareHandler.h"

class CommandHandler {
public:
  explicit CommandHandler(CardManager* card);

  // Sets up the communication folders ("names", "global" and "events") at
  // startup.
  void begin();

  // Dispatches a "/api/[command]" call.
  // 'command' is the command name (the text after "/api/").
  // 'params' holds the REST/GET parameters (name -> decoded value).
  // Returns the response text (may be empty).
  String handle(const String& command, const std::map<String, String>& params);

private:
  CardManager* _card;

  // ----- Standard commands ---------------------------------------------------

  // /api/name : no parameters.
  //   Creates a random 8-character client folder inside "names".
  //   Returns the generated client name.
  String cmdName();

  // /api/setval : set (required), value (required), name (optional).
  //   Writes/overwrites "names/[name]/[set].value".
  //   Returns "ok" or "error".
  String cmdSetval(const std::map<String, String>& params);

  // /api/getval : get (required), name (optional).
  //   Reads "names/[name]/[get].value" without removing it.
  //   Returns the content, or "" if not found.
  String cmdGetval(const std::map<String, String>& params);

  // /api/delval : get (required), name (optional).
  //   Removes "names/[name]/[get].value".
  //   Always returns "".
  String cmdDelval(const std::map<String, String>& params);

  // /api/setglobal : set (required), value (required).
  //   Writes/overwrites "global/[set].value".
  //   Returns "ok" or "error".
  String cmdSetglobal(const std::map<String, String>& params);

  // /api/getglobal : get (required).
  //   Reads "global/[get].value" without removing it.
  //   Returns the content, or "" if not found.
  String cmdGetglobal(const std::map<String, String>& params);

  // /api/delglobal : get (required).
  //   Removes "global/[get].value".
  //   Always returns "".
  String cmdDelglobal(const std::map<String, String>& params);

  // /api/delallval : name (optional, default "all").
  //   Deletes every ".value" file from "names/[name]".
  //   Always returns "".
  String cmdDelallval(const std::map<String, String>& params);

  // /api/delallglobal : no parameters.
  //   Deletes every ".value" file from "global".
  //   Always returns "".
  String cmdDelallglobal();

  // /api/setevent : set (required), value (required).
  //   Writes/overwrites "events/[set].json".
  //   Returns "ok" or "error".
  String cmdSetevent(const std::map<String, String>& params);

  // /api/hardware : command (required).
  //   Splits the "command" GET parameter by "|" and forwards the resulting
  //   array to the user-customizable hardware reaction handler.
  //   Always returns "".
  String cmdHardware(const std::map<String, String>& params);

  // User-customizable hardware reactions (edit HardwareHandler.cpp).
  HardwareHandler _hardware;
};

#endif // COMMAND_HANDLER_H
