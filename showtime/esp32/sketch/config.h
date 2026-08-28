/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 // ============================================================================
//  General settings for the TilBuci Showtime for Makers
// ----------------------------------------------------------------------------
//  Edit this file to adjust the device behavior without changing the rest of
//  the code. Sections are separated to make it easy to adapt to other boards
//  (different controllers and card readers).
// ============================================================================

#ifndef CONFIG_H
#define CONFIG_H

// ----------------------------------------------------------------------------
// 1. WiFi access point
// ----------------------------------------------------------------------------
// Network name (SSID) of the WiFi access point.
#define AP_SSID "tilbuci"

// Password of the WiFi access point.
//
// WARNING: an empty password ("") creates an OPEN network with NO security --
// any nearby device can connect and access the served content. Leave it empty
// only when an open network is intentional (e.g. public displays at events).
// If you set a password, keep in mind that WPA2 requires at least 8
// characters: empty or shorter values make the ESP32 create an open network.
#define AP_PASSWORD ""

// Maximum number of clients allowed to connect simultaneously.
// The default limit of the ESP32 softAP is 4.
#define AP_MAX_CLIENTS 4

// ----------------------------------------------------------------------------
// 2. Web server
// ----------------------------------------------------------------------------
// TCP port of the web server (80 = standard HTTP).
#define WEB_PORT 80

// Initial file served when the browser accesses the root ("/").
#define WEB_INDEX_FILE "/index.html"

// Captive portal: when enabled (1), every DNS query from connected devices
// resolves to the access point IP, and requests with an unexpected host are
// redirected to "http://<AP IP>/". This opens the served content automatically
// when a device joins the network. 1 = enabled, 0 = disabled.
#define CAPTIVE_PORTAL_ENABLED 1

// ----------------------------------------------------------------------------
// 3. Content on the SD card
// ----------------------------------------------------------------------------
// Folder (on the SD card root) that contains the files to be served.
// This is where the sketch looks for the TilBuci content.
#define WEB_ROOT "/tilbuci"

// ----------------------------------------------------------------------------
// 4. Communication with connected devices
// ----------------------------------------------------------------------------
// HTTP route prefix used by connected devices to send commands to the sketch
// ("/api/[command]", e.g. "http://192.168.4.1/api/setval?set=foo&value=bar").
// The command handling is implemented in CommandHandler.h/.cpp.
#define WS_PATH "/api"

// Extension used for the value files created by the setval/getval commands.
#define WS_VALUE_EXT ".value"

// Extension used for the event files created by the setevent command.
#define WS_EVENT_EXT ".json"

// Default client name used when no "name" parameter is received.
#define WS_ALL_NAME "all"

// Communication folders on the SD card (relative to the SD card root).
// "names" is cleared on every startup and holds one folder per client.
// "global" and "events" hold values that must persist across startups.
#define NAMES_DIR "/names"
#define GLOBAL_DIR "/global"
#define EVENTS_DIR "/events"

// SSE (Server-Sent Events) channel used by the board to push actions to the
// connected pages. The page opens this route with an EventSource and delivers
// each received text to "tilbuci_runaction" (see the model "Comunicação SSE").
#define SSE_PATH "/events"

// Interval (ms) of the SSE heartbeat ("ping") used to keep the channel open.
#define SSE_PING_INTERVAL_MS 10000

// ----------------------------------------------------------------------------
// 5. SD card reader
// ----------------------------------------------------------------------------
// The ESP32-CAM (AI-Thinker) uses the native SDMMC controller in 1-bit mode:
//   - CLK = GPIO 14
//   - CMD = GPIO 15
//   - D0  = GPIO 2
// These pins are fixed on the board hardware and do not need to be configured
// in the code.
//
// ADAPTING TO OTHER BOARDS:
//  * If your board uses the SD card via SPI, change the CardManager class to
//    use the SD (SPI) library and define the chip-select (CS) pin here:
//      #define SD_CS_PIN 4
//    (the SCK, MOSI and MISO pins can also be customized via SPI).
//  * If your board uses SDMMC in 4-bit mode, change the second parameter of
//    SD_MMC.begin() to false (see CardManager.cpp).
// ----------------------------------------------------------------------------

#endif // CONFIG_H
