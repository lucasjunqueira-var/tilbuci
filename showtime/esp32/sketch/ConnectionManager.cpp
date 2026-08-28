/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 // ============================================================================
//  ConnectionManager - WiFi access point and web server (implementation)
// ============================================================================

#include "ConnectionManager.h"
#include <WiFi.h>
#include <map>
#include "CommandHandler.h"
#include "SseManager.h"
#include "config.h"

// SSE event source used by the global sendAction() helper.
static AsyncEventSource* sseEvents = nullptr;

// File extension -> content type (MIME) map.
// Formats supported by the project: HTML, CSS, JS, JSON, TXT, JPG/JPEG, PNG,
// WEBP, MP3, M4A, MP4 and WEBM.
static const char* getContentType(const String& path) {
  if (path.endsWith(".html")) return "text/html; charset=utf-8";
  if (path.endsWith(".htm"))  return "text/html; charset=utf-8";
  if (path.endsWith(".css"))  return "text/css; charset=utf-8";
  if (path.endsWith(".js"))   return "application/javascript; charset=utf-8";
  if (path.endsWith(".json")) return "application/json; charset=utf-8";
  if (path.endsWith(".txt"))  return "text/plain; charset=utf-8";
  if (path.endsWith(".jpg"))  return "image/jpeg";
  if (path.endsWith(".jpeg")) return "image/jpeg";
  if (path.endsWith(".png"))  return "image/png";
  if (path.endsWith(".webp")) return "image/webp";
  if (path.endsWith(".mp3"))  return "audio/mpeg";
  if (path.endsWith(".m4a"))  return "audio/mp4";
  if (path.endsWith(".mp4"))  return "video/mp4";
  if (path.endsWith(".webm")) return "video/webm";
  return "application/octet-stream";
}

ConnectionManager::ConnectionManager(CardManager* card, CommandHandler* handler)
    : _card(card), _handler(handler), _server(WEB_PORT), _events(SSE_PATH) {}

void ConnectionManager::beginAccessPoint() {
  Serial.printf("Starting WiFi access point: '%s'\n", AP_SSID);
  WiFi.mode(WIFI_AP);

  // Forces the access point to always use the fixed IP 192.168.4.1.
  // Maintaining this IP guarantees the expected behavior of the whole
  // "TilBuci Showtime for Makers" system: DNS interception, captive portal
  // redirect and client configuration all rely on this address.
  WiFi.softAPConfig(IPAddress(192, 168, 4, 1), IPAddress(192, 168, 4, 1),
                    IPAddress(255, 255, 255, 0));

  // SSID, password, channel, max_connection (maximum simultaneous clients).
  WiFi.softAP(AP_SSID, AP_PASSWORD, 1, AP_MAX_CLIENTS);

  delay(100);
  _apIp = WiFi.softAPIP().toString();
  Serial.printf("Access point active. Connect to the network '%s' "
                "(max %d clients).\n",
                AP_SSID, AP_MAX_CLIENTS);
  Serial.printf("Server address: http://%s\n", _apIp.c_str());

  // Captive portal DNS: answers every DNS query from connected devices with
  // the access point IP, so any URL typed (or probed) resolves to this device.
  if (CAPTIVE_PORTAL_ENABLED) {
    if (_dnsServer.start(53, "*", WiFi.softAPIP())) {
      Serial.println("Captive portal DNS started (all domains -> AP IP).");
    } else {
      Serial.println("ERROR: could not start the captive portal DNS.");
    }
  }
}

void ConnectionManager::beginWebServer() {
  // Registers the SSE channel and the not-found handler (captive portal,
  // "/api/" commands and static files).
  sseEvents = &_events;
  _server.addHandler(&_events);

  _server.onNotFound([this](AsyncWebServerRequest* request) {
    handleRequest(request);
  });
  _server.begin();

  Serial.printf("Web server started on port %d.\n", WEB_PORT);
  Serial.printf("SSE channel ready at http://%s%s\n", _apIp.c_str(), SSE_PATH);
  Serial.printf("Open http://%s/ in a browser.\n", _apIp.c_str());
}

void ConnectionManager::handleClient() {
  // Answers pending DNS queries (captive portal). The async web server handles
  // HTTP requests on its own in the background.
  _dnsServer.processNextRequest();

  // SSE heartbeat: sends a "ping" event (ignored by the pages) periodically to
  // keep the event channel open.
  static unsigned long lastPing = 0;
  if (millis() - lastPing >= SSE_PING_INTERVAL_MS) {
    lastPing = millis();
    if (_events.count() > 0) {
      _events.send("", "ping");
    }
  }
}

void ConnectionManager::handleRequest(AsyncWebServerRequest* request) {
  String path = urlDecode(request->url());

  // Removes the query string, if any.
  int queryPos = path.indexOf('?');
  if (queryPos >= 0) {
    path = path.substring(0, queryPos);
  }

  Serial.printf("Request: %s\n", path.c_str());

  // Captive portal: redirects requests that are not addressed to this device
  // (e.g. captive portal probes or any domain typed by the user) to the access
  // point IP. Requests addressed to the AP IP are served normally.
  if (CAPTIVE_PORTAL_ENABLED && isCaptivePortalRequest(request)) {
    Serial.printf("  -> captive portal redirect to http://%s/\n",
                  _apIp.c_str());
    // Sends a 302 response with the "Location" header set to the AP IP.
    request->redirect("http://" + _apIp + "/");
    return;
  }

  // "/api/[command]" route: forwards the call to the command handler.
  if (path.startsWith(WS_PATH "/")) {
    String command = path.substring(strlen(WS_PATH) + 1); // after "/api/"
    if (command.endsWith("/")) {
      command.remove(command.length() - 1);
    }

    // Collects the REST/GET parameters (already URL-decoded by the server).
    std::map<String, String> params;
    for (int i = 0; i < request->args(); i++) {
      params[request->argName(i)] = request->arg(i);
    }

    String response = _handler->handle(command, params);
    Serial.printf("  -> command '%s' response: '%s'\n", command.c_str(),
                  response.c_str());
    request->send(200, "text/plain", response);
    return;
  }

  // The root "/" serves the initial file (index.html).
  if (path == "/") {
    path = WEB_INDEX_FILE;
  }

  // Resolves the full path on the SD card and serves the file inline (not as
  // a download) using the filesystem-based send overload of the async server.
  String fullPath = _card->fullPath(path.c_str());
  if (!_card->fileSystem().exists(fullPath.c_str())) {
    request->send(404, "text/plain", "File not found");
    Serial.printf("  -> file not found: %s\n", path.c_str());
    return;
  }
  request->send(_card->fileSystem(), fullPath, getContentType(path));
}

bool ConnectionManager::isCaptivePortalRequest(AsyncWebServerRequest* request) {
  String host = request->host();
  host.trim();
  if (host.length() == 0) {
    return false;
  }

  // Removes the port, if present in the Host header.
  int colon = host.indexOf(':');
  if (colon >= 0) {
    host = host.substring(0, colon);
  }

  // Requests addressed to this device are served normally.
  if (host == _apIp) {
    return false;
  }

  return true;
}

String ConnectionManager::urlDecode(const String& input) const {
  String decoded;
  decoded.reserve(input.length());

  for (size_t i = 0; i < input.length(); i++) {
    char c = input[i];

    if (c == '%') {
      if (i + 2 < input.length()) {
        char high = input[i + 1];
        char low = input[i + 2];
        if (isHexadecimalDigit(high) && isHexadecimalDigit(low)) {
          char hex[3] = { high, low, '\0' };
          decoded += (char)strtol(hex, nullptr, 16);
          i += 2;
          continue;
        }
      }
      decoded += c;
    } else if (c == '+') {
      decoded += ' ';
    } else {
      decoded += c;
    }
  }
  return decoded;
}

void sendAction(const String& text) {
  // Sends the text to every connected page through the SSE channel. The page
  // receives it and passes it to "tilbuci_runaction".
  if (sseEvents != nullptr) {
    sseEvents->send(text.c_str(), "message", millis());
  }
}
