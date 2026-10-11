<?php
/*
 * Headless installer wrapper for TilBuci.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * The TilBuci installer (setup.php) is a web script driven by $_POST and by
 * the $_SERVER request variables. This wrapper runs it without a browser by
 * simulating the request, so it can be used from the container entrypoint.
 *
 * Usage:
 *   php tilbuci-install.php --action=1 \
 *       --email=user@example.com --mode=multi \
 *       --url=http://localhost/ \
 *       --db-host=localhost --db-name=tilbuci --db-user=tilbuci --db-pass=secret
 *
 * Actions: 1 = new installation, 3 = update, 4 = override files.
 */

$options = getopt('', [
    'action:',
    'email::',
    'mode::',
    'url::',
    'db-host::',
    'db-name::',
    'db-user::',
    'db-pass::',
    'db-port::',
    'current::',
]);

$action = (string) ($options['action'] ?? '1');
$email  = (string) ($options['email']   ?? getenv('TILBUCI_EMAIL') ?: '');
$mode   = (string) ($options['mode']    ?? getenv('TILBUCI_INSTALL_MODE') ?: 'multi');
$url    = (string) ($options['url']     ?? getenv('TILBUCI_URL') ?: 'http://localhost/');

$dbHost = (string) ($options['db-host'] ?? 'localhost');
$dbPort = (string) ($options['db-port'] ?? '');
$dbName = (string) ($options['db-name'] ?? 'tilbuci');
$dbUser = (string) ($options['db-user'] ?? 'tilbuci');
$dbPass = (string) ($options['db-pass'] ?? '');
$current = (string) ($options['current'] ?? '');

$publicRoot = getenv('TILBUCI_PUBLIC') ?: '/var/www/tilbuci/public_html';
$installer = $publicRoot . '/setup.php';

if (!is_file($installer)) {
    fwrite(STDERR, "Installer not found at {$installer}\n");
    exit(2);
}

if ($action === '1' && $email === '') {
    fwrite(STDERR, "An administrator e-mail address is required for a new installation.\n");
    exit(2);
}

if ($action === '3' && $current === '') {
    fwrite(STDERR, "The current database version is required to update (--current).\n");
    exit(2);
}

// Derive scheme, host and path prefix from the public URL.
$parts  = parse_url($url);
$scheme = $parts['scheme'] ?? 'http';
$host   = $parts['host'] ?? 'localhost';
if (!empty($parts['port'])) {
    $host .= ':' . $parts['port'];
}
$prefix = isset($parts['path']) ? rtrim($parts['path'], '/') : '';

// Simulate the Apache request environment used by setup.php.
$_SERVER['HTTP_HOST']      = $host;
$_SERVER['SCRIPT_NAME']    = $prefix . '/setup.php';
$_SERVER['REQUEST_SCHEME'] = $scheme;
$_SERVER['SCRIPT_URI']     = $scheme . '://' . $host . $prefix . '/setup.php';
$_SERVER['REQUEST_URI']    = $prefix . '/setup.php';

// Simulate the installer form submission.
$_POST = [
    'ac'           => $action,
    'databaseServ' => $dbHost,
    'databasePort' => $dbPort,
    'databaseUser' => $dbUser,
    'databasePass' => $dbPass,
    'databaseName' => $dbName,
    'email'        => $email,
    'email2'       => $email,
    'mode'         => $mode,
    'current'      => $current,
];

chdir($publicRoot);

ob_start();
require $installer;   // Defines $iinfo and $warn as side effects.
$html = ob_get_clean();

$page = (int) ($iinfo['page'] ?? 0);
$warn = (string) ($warn ?? '');

// 1 = fresh installation succeeded; 7 = update/override succeeded.
if ($page === 1 || $page === 7) {
    fwrite(STDOUT, "TilBuci installer finished successfully (page={$page}).\n");
    exit(0);
}

$messages = [
    0 => 'The installer could not process the request',
    2 => 'An existing installation was found but cannot be updated by this installer',
    3 => 'The installation needs to be updated',
    4 => 'The installed version matches this installer (files can be overridden)',
    5 => 'The installed version is newer than this installer',
    6 => 'An error occurred while updating the installation',
];
$detail = $messages[$page] ?? 'Unknown installer state';
fwrite(STDERR, "TilBuci installer failed (page={$page}): {$detail}.\n");
if ($warn !== '') {
    fwrite(STDERR, "Installer message: {$warn}\n");
}
exit(1);
