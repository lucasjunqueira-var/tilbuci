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
	'databaseServ' => '', 
	'databaseUser' => '', 
	'databasePass' => '',
	'databaseName' => '', 
	'databasePort' => '',
	// system path
	'path' => 'http://tilbuci/', 
	// user mode
    'singleUser' => true,
	// encryption info
	'encVec' => '', 
	'encKey' => '',
	'secret' => '', 
	// versioning
	'sceneVersions' => 10, 
];