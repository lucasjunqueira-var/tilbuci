<?php
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