<?php
/**
 * Global Tilbuci configuration.
 */
global $gconf;
$gconf = [
	// database setup
	'databaseServ' => 'sqlite', 
	'databaseUser' => '', 
	'databasePass' => '',
	'databaseName' => '', 
	'databasePort' => '',
	// system path
	'path' => 'http://localhost:51804/', 
	// user mode
    'singleUser' => true,
	// encryption info
	'encVec' => '1234567890123456', 
	'encKey' => '2a3756f78cb0889f1229e016aa4963a8',
	'secret' => '31323334353637383930313233343536', 
	// versioning
	'sceneVersions' => 10, 
];