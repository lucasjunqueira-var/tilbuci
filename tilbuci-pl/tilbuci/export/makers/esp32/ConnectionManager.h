/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 // ============================================================================
//  ConnectionManager - WiFi access point, async web server, captive portal and
//  SSE
// ----------------------------------------------------------------------------
//  Concentrates the connection parts of the sketch: WiFi (access point mode),
//  the captive portal (DNS interception + redirect to the AP IP), the HTTP
//  server that serves files from the SD card and the SSE channel used to push
//  actions to the connected pages (see SseManager.h). To adapt the sketch to
//  another controller, the network settings live in config.h and in this
//  class.
//
//  NOTE: this class is designed for the ESP32 (WiFi, AsyncWebServer and
//  DNSServer APIs). AsyncWebServer comes from the third-party
//  "ESPAsyncWebServer" library plus its dependency "AsyncTCP"; both must be
//  installed for the sketch to compile (see the include note below). It may
//  require adjustments on other controllers.
// ============================================================================

#ifndef CONNECTION_MANAGER_H
#define CONNECTION_MANAGER_H

#include <Arduino.h>

// NOTE: the async web server requires two third-party libraries that MUST be
// installed (Arduino Library Manager or .ZIP import), otherwise compilation
// fails with "ESPAsyncWebServer.h: No such file or directory":
//   - ESPAsyncWebServer : https://github.com/ESP32Async/ESPAsyncWebServer
//   - AsyncTCP          : https://github.com/ESP32Async/AsyncTCP
#include <ESPAsyncWebServer.h>
#include <DNSServer.h>
#include "CardManager.h"

class CommandHandler;

class ConnectionManager {
public:
  // 'card' provides the SD card access; 'handler' processes the "/api/"
  // communication commands from connected devices.
  ConnectionManager(CardManager* card, CommandHandler* handler);

  // Starts the WiFi access point (SSID/password defined in config.h).
  void beginAccessPoint();

  // Starts the web server (call after confirming storage access).
  void beginWebServer();

  // Processes pending DNS requests and sends the SSE heartbeat. The async web
  // server handles HTTP requests on its own in the background. Call from
  // loop().
  void handleClient();

private:
  CardManager* _card;
  CommandHandler* _handler;
  AsyncWebServer _server;
  AsyncEventSource _events;
  DNSServer _dnsServer;
  String _apIp;

  // Handles an HTTP request: routes "/api/" commands or sends a file.
  void handleRequest(AsyncWebServerRequest* request);

  // Indicates whether the request should be redirected to the access point IP
  // (captive portal). Only requests not addressed to this device are
  // redirected, so "/api/" and file requests are served normally.
  bool isCaptivePortalRequest(AsyncWebServerRequest* request);

  // Converts URL-encoded characters (%20, +, etc.) back to plain text.
  String urlDecode(const String& input) const;
};

#endif // CONNECTION_MANAGER_H
