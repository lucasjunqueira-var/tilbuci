<?php
/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
 
/**
 * Global Tilbuci configuration.
 */
global $gconf;
$gconf = [
	// database setup
	'databaseServ' => 'localhost', 
	'databaseUser' => 'root', 
	'databasePass' => '',
	'databaseName' => 'tilbuci', 
	'databasePort' => '',
	// system path
	'path' => 'http://tilbuci/', 
	// user mode
    'singleUser' => true,
	// encryption info
	'encVec' => '1234567890123456', 
	'encKey' => '2a3756f78cb0889f1229e016aa4963a8',
	'secret' => '31323334353637383930313233343536', 
	// versioning
	'sceneVersions' => 10, 
];