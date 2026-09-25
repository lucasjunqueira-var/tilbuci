/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 // ============================================================================
//  CommandHandler - "/api/[command]" route handling (implementation)
// ============================================================================

#include "CommandHandler.h"
#include <esp_system.h> // esp_random() - ESP32 specific; on other controllers
                        // use a generic seed (e.g. analogRead) in begin().
#include "config.h"

// Returns the value of a parameter, or "" if it was not received.
static String getParam(const std::map<String, String>& params,
                       const String& key) {
  auto it = params.find(key);
  if (it != params.end()) {
    return it->second;
  }
  return "";
}

// Indicates whether a parameter was received.
static bool hasParam(const std::map<String, String>& params,
                     const String& key) {
  return params.count(key) > 0;
}

CommandHandler::CommandHandler(CardManager* card) : _card(card) {}

void CommandHandler::begin() {
  // Seeds the pseudo-random generator used by /api/name.
  // NOTE: esp_random() is ESP32 specific; on other controllers, replace it
  // with a generic seed such as randomSeed(analogRead(0)).
  randomSeed(esp_random());

  // "names" folder: create it if missing; existing contents are preserved.
  if (!_card->folderExists(NAMES_DIR)) {
    Serial.printf("CommandHandler: creating folder '%s'.\n", NAMES_DIR);
    _card->createFolder(NAMES_DIR);
  } else {
    Serial.printf("CommandHandler: folder '%s' already exists (kept).\n",
                  NAMES_DIR);
  }

  // "all" subfolder inside "names": create it if missing.
  String allPath = String(NAMES_DIR) + "/" + WS_ALL_NAME;
  if (!_card->folderExists(allPath.c_str())) {
    _card->createFolder(allPath.c_str());
  }
  Serial.printf("CommandHandler: folder '%s' ready.\n", allPath.c_str());

  // "global" folder: create it if missing; its contents are preserved.
  if (!_card->folderExists(GLOBAL_DIR)) {
    Serial.printf("CommandHandler: creating folder '%s'.\n", GLOBAL_DIR);
    _card->createFolder(GLOBAL_DIR);
  } else {
    Serial.printf("CommandHandler: folder '%s' already exists (kept).\n",
                  GLOBAL_DIR);
  }

  // "events" folder: create it if missing; its contents are preserved.
  if (!_card->folderExists(EVENTS_DIR)) {
    Serial.printf("CommandHandler: creating folder '%s'.\n", EVENTS_DIR);
    _card->createFolder(EVENTS_DIR);
  } else {
    Serial.printf("CommandHandler: folder '%s' already exists (kept).\n",
                  EVENTS_DIR);
  }
}

String CommandHandler::handle(const String& command,
                              const std::map<String, String>& params) {
  Serial.printf("CommandHandler: received command '%s'.\n", command.c_str());

  if (command == "name") {
    return cmdName();
  }
  if (command == "setval") {
    return cmdSetval(params);
  }
  if (command == "getval") {
    return cmdGetval(params);
  }
  if (command == "delval") {
    return cmdDelval(params);
  }
  if (command == "setglobal") {
    return cmdSetglobal(params);
  }
  if (command == "getglobal") {
    return cmdGetglobal(params);
  }
  if (command == "delglobal") {
    return cmdDelglobal(params);
  }
  if (command == "delallval") {
    return cmdDelallval(params);
  }
  if (command == "delallglobal") {
    return cmdDelallglobal();
  }
  if (command == "setevent") {
    return cmdSetevent(params);
  }
  if (command == "hardware") {
    return cmdHardware(params);
  }

  // Unknown command: return an empty string.
  Serial.printf("CommandHandler: unknown command '%s'.\n", command.c_str());
  return "";
}

String CommandHandler::cmdName() {
  const char charset[] =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const int charsetLen = sizeof(charset) - 1; // 62 characters

  // Tries a few times to generate a name that is not already in use.
  for (int attempt = 0; attempt < 20; attempt++) {
    String name;
    for (int i = 0; i < 8; i++) {
      name += charset[random(0, charsetLen)];
    }

    String folder = String(NAMES_DIR) + "/" + name;
    if (!_card->folderExists(folder.c_str())) {
      if (_card->createFolder(folder.c_str())) {
        Serial.printf("CommandHandler: created client folder '%s'.\n",
                      folder.c_str());
        return name;
      }
    }
  }

  Serial.println("CommandHandler: could not create a unique client folder.");
  return "";
}

String CommandHandler::cmdSetval(const std::map<String, String>& params) {
  if (!hasParam(params, "set") || !hasParam(params, "value")) {
    return "";
  }
  String set = getParam(params, "set");
  String value = getParam(params, "value");
  String name = getParam(params, "name");
  if (name.isEmpty()) {
    name = WS_ALL_NAME;
  }

  // Ensures the target client folder exists.
  String folder = String(NAMES_DIR) + "/" + name;
  if (!_card->folderExists(folder.c_str())) {
    _card->createFolder(folder.c_str());
  }

  String filePath = folder + "/" + set + WS_VALUE_EXT;
  bool ok = _card->writeFile(filePath.c_str(), value);
  Serial.printf("CommandHandler: setval '%s' -> %s.\n", filePath.c_str(),
                ok ? "ok" : "error");
  return ok ? "ok" : "error";
}

String CommandHandler::cmdGetval(const std::map<String, String>& params) {
  if (!hasParam(params, "get")) {
    return "";
  }
  String get = getParam(params, "get");
  String name = getParam(params, "name");
  if (name.isEmpty()) {
    name = WS_ALL_NAME;
  }

  String filePath =
      String(NAMES_DIR) + "/" + name + "/" + get + WS_VALUE_EXT;
  return _card->readFile(filePath.c_str());
}

String CommandHandler::cmdDelval(const std::map<String, String>& params) {
  if (!hasParam(params, "get")) {
    return "";
  }
  String get = getParam(params, "get");
  String name = getParam(params, "name");
  if (name.isEmpty()) {
    name = WS_ALL_NAME;
  }

  String filePath =
      String(NAMES_DIR) + "/" + name + "/" + get + WS_VALUE_EXT;
  _card->deleteFile(filePath.c_str());
  return "";
}

String CommandHandler::cmdSetglobal(const std::map<String, String>& params) {
  if (!hasParam(params, "set") || !hasParam(params, "value")) {
    return "";
  }
  String set = getParam(params, "set");
  String value = getParam(params, "value");

  String filePath = String(GLOBAL_DIR) + "/" + set + WS_VALUE_EXT;
  bool ok = _card->writeFile(filePath.c_str(), value);
  Serial.printf("CommandHandler: setglobal '%s' -> %s.\n", filePath.c_str(),
                ok ? "ok" : "error");
  return ok ? "ok" : "error";
}

String CommandHandler::cmdGetglobal(const std::map<String, String>& params) {
  if (!hasParam(params, "get")) {
    return "";
  }
  String get = getParam(params, "get");
  String filePath = String(GLOBAL_DIR) + "/" + get + WS_VALUE_EXT;
  return _card->readFile(filePath.c_str());
}

String CommandHandler::cmdDelglobal(const std::map<String, String>& params) {
  if (!hasParam(params, "get")) {
    return "";
  }
  String get = getParam(params, "get");
  String filePath = String(GLOBAL_DIR) + "/" + get + WS_VALUE_EXT;
  _card->deleteFile(filePath.c_str());
  return "";
}

String CommandHandler::cmdDelallval(const std::map<String, String>& params) {
  String name = getParam(params, "name");
  if (name.isEmpty()) {
    name = WS_ALL_NAME;
  }

  String folder = String(NAMES_DIR) + "/" + name;
  int deleted = _card->deleteFilesWithExtension(folder.c_str(), WS_VALUE_EXT);
  Serial.printf("CommandHandler: delallval removed %d file(s) from '%s'.\n",
                deleted, folder.c_str());
  return "";
}

String CommandHandler::cmdDelallglobal() {
  int deleted = _card->deleteFilesWithExtension(GLOBAL_DIR, WS_VALUE_EXT);
  Serial.printf("CommandHandler: delallglobal removed %d file(s) from '%s'.\n",
                deleted, GLOBAL_DIR);
  return "";
}

String CommandHandler::cmdSetevent(const std::map<String, String>& params) {
  if (!hasParam(params, "set") || !hasParam(params, "value")) {
    return "";
  }
  String set = getParam(params, "set");
  String value = getParam(params, "value");

  String filePath = String(EVENTS_DIR) + "/" + set + WS_EVENT_EXT;
  bool ok = _card->writeFile(filePath.c_str(), value);
  Serial.printf("CommandHandler: setevent '%s' -> %s.\n", filePath.c_str(),
                ok ? "ok" : "error");
  return ok ? "ok" : "error";
}

String CommandHandler::cmdHardware(const std::map<String, String>& params) {
  // The "command" GET parameter is mandatory.
  if (!hasParam(params, "command")) {
    return "";
  }
  String command = getParam(params, "command");

  // Splits the command by "|" into an array of variable size.
  std::vector<String> parts;
  int start = 0;
  while (true) {
    int sep = command.indexOf('|', start);
    if (sep < 0) {
      parts.push_back(command.substring(start));
      break;
    }
    parts.push_back(command.substring(start, sep));
    start = sep + 1;
  }

  Serial.printf("CommandHandler: hardware command with %d element(s).\n",
                (int)parts.size());

  // Forwards the split array to the user-customizable hardware handler.
  _hardware.handle(parts);

  // The "/api/hardware" call always returns an empty string.
  return "";
}
