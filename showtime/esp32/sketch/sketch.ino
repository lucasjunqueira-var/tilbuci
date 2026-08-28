/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

// ============================================================================
//  TilBuci Showtime for Makers
// ----------------------------------------------------------------------------
//  Local web server that acts as a WiFi access point and serves the content
//  created in TilBuci from an SD card.
//
//  Startup flow:
//    1. Starts the WiFi access point (SSID/password configurable in config.h).
//    2. Validates access to the storage (SD card).
//    3. Locates the "tilbuci" folder on the card.
//    4. Starts the web server serving the files from that folder.
//
//  The code is split into modules to make it easy to adapt to other boards
//  with different controllers and card readers:
//    - ConnectionManager : WiFi (access point) + web server + captive portal + SSE
//    - CardManager       : SD card access
//    - CommandHandler    : "/api/[command]" communication commands
//    - HardwareHandler   : user-customizable reactions to "/api/hardware"
//    - config.h          : adjustable parameters (network, port, folders, etc.)
//
//  NOTE: this sketch is designed for the ESP32. Running it on other WiFi
//  controllers may require adjustments (see ConnectionManager.h, CardManager.h
//  and config.h).
//
//  sendAction() - pushing actions to the connected devices
//  ---------------------------------------------------------------------------
//  Use the global function sendAction(text) (declared in SseManager.h) to push
//  a command to every connected device through the SSE channel. The pages
//  receive the text and pass it to "tilbuci_runaction", which executes it.
//
//  IMPORTANT: the single string parameter MUST be a valid TilBuci action
//  command, otherwise it will not be executed by the content running on the
//  connected devices. Example:
//    sendAction("{\"ac\": \"scene.load\",\"param\":[\"thesceneid\"]}");
//
//  To call sendAction() from any file, just include "SseManager.h" first.
// ============================================================================

#include "config.h"
#include "CardManager.h"
#include "CommandHandler.h"
#include "ConnectionManager.h"

// Global module instances.
CardManager card;
CommandHandler commandHandler(&card);
ConnectionManager connection(&card, &commandHandler);

void setup() {
  Serial.begin(115200);
  delay(500);

  Serial.println();
  Serial.println("=== TilBuci Showtime for Makers ===");

  // 1. Starts the WiFi access point.
  connection.beginAccessPoint();

  // 2. Validates access to the storage (SD card).
  if (!card.begin()) {
    Serial.println("ERROR: SD card unavailable.");
    Serial.println("      Check the card and the settings in config.h.");
    return;
  }

  // 3. Locates the content folder.
  if (!card.hasWebRoot()) {
    Serial.printf("ERROR: folder '%s' not found on the SD card root.\n",
                  WEB_ROOT);
    return;
  }
  Serial.printf("Content folder '%s' found.\n", WEB_ROOT);

  // 4. Sets up the communication folders ("names" and "global").
  commandHandler.begin();

  // 5. Starts the web server.
  connection.beginWebServer();
}

void loop() {
  // Processes pending HTTP requests.
  connection.handleClient();
}
