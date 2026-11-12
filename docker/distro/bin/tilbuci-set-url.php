<?php
/*
 * TilBuci base URL updater.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Rewrites the public base URL stored in the persisted configuration files:
 *   - app/Config.php      (key: path)
 *   - public_html/app/player.json  (base, ws, font)
 *   - public_html/app/editor.json  (base, player, ws, font)
 *
 * All other values (secrets, database credentials, etc.) are preserved.
 *
 * Usage:
 *   php tilbuci-set-url.php http://localhost:8080/
 */

$url = isset($argv[1]) ? trim((string) $argv[1]) : '';
if ($url === '') {
    fwrite(STDERR, "Usage: tilbuci-set-url <url>\n");
    exit(2);
}
if (!preg_match('#^https?://#i', $url)) {
    fwrite(STDERR, "Invalid URL '{$url}': it must start with http:// or https://\n");
    exit(2);
}
if (substr($url, -1) !== '/') {
    $url .= '/';
}

$root       = getenv('TILBUCI_ROOT') ?: '/var/www/tilbuci';
$publicRoot = getenv('TILBUCI_PUBLIC') ?: ($root . '/public_html');

$configFile = $root . '/app/Config.php';
$playerFile = $publicRoot . '/app/player.json';
$editorFile = $publicRoot . '/app/editor.json';

// --- Config.php -----------------------------------------------------------
if (!is_file($configFile) || filesize($configFile) === 0) {
    fwrite(STDERR, "Config file not found or empty: {$configFile}\n");
    exit(1);
}

$gconf = null;
include $configFile; // Defines the global $gconf.
if (!is_array($gconf)) {
    fwrite(STDERR, "Could not read the configuration from {$configFile}\n");
    exit(1);
}
$gconf['path'] = $url;

$out  = "<?php \r\n";
$out .= 'global $gconf;' . "\r\n";
$out .= '$gconf = [' . "\r\n";
foreach ($gconf as $key => $value) {
    if (is_bool($value)) {
        $out .= "'{$key}' => " . ($value ? 'true' : 'false') . ", \r\n";
    } elseif (is_int($value)) {
        $out .= "'{$key}' => {$value}, \r\n";
    } else {
        $out .= "'{$key}' => '{$value}', \r\n";
    }
}
$out .= ']; ';
file_put_contents($configFile, $out);

// --- player.json / editor.json -------------------------------------------
$errors  = 0;
$errors += update_json($playerFile, [
    'base' => $url,
    'ws'   => $url . 'ws/',
    'font' => $url . 'font/',
]);
$errors += update_json($editorFile, [
    'base'   => $url . 'editor/',
    'player' => $url,
    'ws'     => $url . 'ws/',
    'font'   => $url . 'font/',
]);

echo "TilBuci base URL set to {$url}\n";
exit($errors > 0 ? 1 : 0);

/**
 * Update a set of keys inside a JSON file, preserving everything else.
 *
 * @return int 0 on success, 1 when the file is missing, empty or invalid.
 */
function update_json(string $file, array $values): int
{
    if (!is_file($file) || filesize($file) === 0) {
        fwrite(STDERR, "Warning: {$file} not found or empty, skipped.\n");
        return 1;
    }
    $data = json_decode((string) file_get_contents($file), true);
    if (!is_array($data)) {
        fwrite(STDERR, "Warning: {$file} is not valid JSON, skipped.\n");
        return 1;
    }
    foreach ($values as $key => $value) {
        $data[$key] = $value;
    }
    file_put_contents($file, json_encode($data));
    return 0;
}
