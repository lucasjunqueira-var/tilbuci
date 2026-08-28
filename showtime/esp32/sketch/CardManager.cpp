/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

// ============================================================================
//  CardManager - SD card access (implementation)
// ============================================================================

#include "CardManager.h"
#include <SD_MMC.h>
#include "config.h"

bool CardManager::begin() {
  Serial.println("Validating SD card access...");

  // ESP32-CAM (AI-Thinker): native SDMMC in 1-bit mode
  // (CLK = GPIO 14, CMD = GPIO 15, D0 = GPIO 2).
  // For 4-bit SDMMC, change the second parameter to false.
  //
  // NOTE: the native SD_MMC controller is designed for the ESP32; other
  // controllers may require the SPI-based SD library instead.
  if (!SD_MMC.begin("/sdcard", true)) {
    Serial.println("ERROR: could not mount the SD card.");
    _mounted = false;
    return false;
  }

  _mounted = true;
  Serial.printf("SD card mounted: %llu MB available.\n",
                SD_MMC.totalBytes() / (1024 * 1024));
  return true;
}

bool CardManager::isMounted() const {
  return _mounted;
}

bool CardManager::hasWebRoot() const {
  if (!_mounted) {
    return false;
  }
  return SD_MMC.exists(WEB_ROOT);
}

fs::File CardManager::openFile(const char* path) {
  if (!_mounted) {
    return fs::File();
  }

  // Builds the full path from the content root (e.g.: "/tilbuci/...").
  char fullPath[160];
  snprintf(fullPath, sizeof(fullPath), "%s%s", WEB_ROOT, path);

  return SD_MMC.open(fullPath, FILE_READ);
}

fs::FS& CardManager::fileSystem() {
  return SD_MMC;
}

String CardManager::fullPath(const char* path) {
  String full;
  full.reserve(strlen(WEB_ROOT) + strlen(path) + 1);
  full += WEB_ROOT;
  full += path;
  return full;
}

bool CardManager::folderExists(const char* path) {
  if (!_mounted) {
    return false;
  }
  return SD_MMC.exists(path);
}

bool CardManager::createFolder(const char* path) {
  if (!_mounted) {
    return false;
  }
  return SD_MMC.mkdir(path);
}

bool CardManager::writeFile(const char* path, const String& content) {
  if (!_mounted) {
    return false;
  }

  File file = SD_MMC.open(path, FILE_WRITE);
  if (!file) {
    return false;
  }
  size_t written = file.print(content);
  file.close();
  return written == content.length();
}

String CardManager::readFile(const char* path) {
  if (!_mounted) {
    return "";
  }

  File file = SD_MMC.open(path, FILE_READ);
  if (!file) {
    return "";
  }

  String content;
  while (file.available()) {
    content += (char)file.read();
  }
  file.close();
  return content;
}

bool CardManager::deleteFile(const char* path) {
  if (!_mounted) {
    return false;
  }
  return SD_MMC.remove(path);
}

int CardManager::deleteFilesWithExtension(const char* folderPath,
                                          const char* extension) {
  if (!_mounted || !folderExists(folderPath)) {
    return 0;
  }

  File dir = SD_MMC.open(folderPath);
  if (!dir || !dir.isDirectory()) {
    if (dir) {
      dir.close();
    }
    return 0;
  }

  int deleted = 0;
  while (true) {
    File entry = dir.openNextFile();
    if (!entry) {
      break;
    }

    String entryPath = String(folderPath) + "/" + leafName(entry.name());
    bool isDirectory = entry.isDirectory();
    entry.close();

    if (isDirectory || !entryPath.endsWith(extension)) {
      continue;
    }
    if (SD_MMC.remove(entryPath.c_str())) {
      deleted++;
    }
  }
  dir.close();

  return deleted;
}

String CardManager::leafName(const char* path) {
  String value = path;
  int pos = value.lastIndexOf('/');
  if (pos >= 0) {
    return value.substring(pos + 1);
  }
  return value;
}
