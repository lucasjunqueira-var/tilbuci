/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

// ============================================================================
//  CardManager - SD card access
// ----------------------------------------------------------------------------
//  All storage access is concentrated in this class. To adapt the sketch to a
//  different card reader (SPI, 4-bit SDMMC, another board), just change this
//  class and section 4 of the config.h file.
//
//  NOTE: this class is designed for the ESP32 (native SD_MMC controller) and
//  may require adjustments (e.g. the SPI-based SD library) on other boards.
// ============================================================================

#ifndef CARD_MANAGER_H
#define CARD_MANAGER_H

#include <Arduino.h>
#include <FS.h>

class CardManager {
public:
  // Initializes and mounts the SD card. Returns true on success.
  bool begin();

  // Indicates whether the SD card is mounted.
  bool isMounted() const;

  // Checks whether the content folder (WEB_ROOT) exists on the card.
  bool hasWebRoot() const;

  // Opens a file inside the content folder.
  // 'path' must be relative to the content root (e.g.: "/index.html").
  // Returns a valid File object on success, or an empty File (evaluated as
  // false) if the file does not exist.
  fs::File openFile(const char* path);

  // Returns the filesystem instance used by the SD card (SD_MMC), so the async
  // web server can serve files directly (see ConnectionManager).
  fs::FS& fileSystem();

  // Returns the full path of a file inside the content folder
  // (WEB_ROOT + path), e.g. "/tilbuci/index.html".
  String fullPath(const char* path);

  // --- General SD card operations (paths relative to the SD card root) -------

  // Checks whether a folder exists on the SD card.
  bool folderExists(const char* path);

  // Creates a folder on the SD card (no-op if it already exists).
  bool createFolder(const char* path);

  // Creates or overwrites a text file with the given content.
  bool writeFile(const char* path, const String& content);

  // Reads a text file. Returns an empty string if the file does not exist.
  String readFile(const char* path);

  // Deletes a file. Returns true if it was removed.
  bool deleteFile(const char* path);

  // Deletes every file with the given extension (e.g. ".value") inside the
  // folder. Returns the number of deleted files (0 if none or on error).
  int deleteFilesWithExtension(const char* folderPath, const char* extension);

private:
  bool _mounted = false;

  // Returns only the last path component (the file/folder name).
  static String leafName(const char* path);
};

#endif // CARD_MANAGER_H
