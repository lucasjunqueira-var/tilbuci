<?php

/** CLASS DEFINITIONS **/
require_once('Data.php');

/**
 * Plugin base.
 */
class Plugin extends Data
{
	
	/**
	 * plugin id
	 */
	private $id = '';
	
	/**
	 * plugin configuration
	 */
	public $config = [ ];

	/**
	 * Constructor.
	 * @param	string	$id	the plugin id
	 * @param	string	$file	plugin PHP file name
	 * @param	string	$index	should plugin manipulate the index page? ('0' or '1')
	 * @param	string	$ws	does the plugin have its own webservice? ('0' or '1')
	 */
	public function __construct($id, $file, $index = '0', $ws = '0')
	{
		// create plugin
		parent::__construct();
		$this->id = $id;
		
		// get configuration
		$ck = $this->queryAll('SELECT pc_setup FROM pluginconfig WHERE pc_id=:id', [ ':id' => $this->id ]);
		if (count($ck) > 0) {
			if ($ck[0]['pc_setup'] != '') {
				$json = json_decode($ck[0]['pc_setup'], true);
				if (json_last_error() == JSON_ERROR_NONE) {
					$this->config = $json;
				}
			}
		} else {
			// create configuration
			$this->execute('INSERT INTO pluginconfig (pc_id, pc_active, pc_setup, pc_file, pc_index, pc_ws) VALUES (:id, :ac, :st, :fl, :in, :ws)', [
				':id' => $id, 
				':ac' => '1', 
				':st' => '', 
				':fl' => $file, 
				':in' => $index, 
				':ws' => $ws, 
			]);
		}
	}
	
	/**
	 * Updates the plugin configuration.
	 * @param	string	$conf	JSON-encoded configurations settings
	 * @param	string	$file	plugin file name
	 * @param	string	$index	should plugin manipulate the index page? ('0' or '1')
	 * @param	string	$ws	does the plugin have its own webservice? ('0' or '1')
	 */
	public function setPluginConfig($conf, $file, $index, $ws) {
		$this->execute('UPDATE pluginconfig SET pc_setup=:cf, pc_file=:fl, pc_index=:in, pc_ws=:ws WHERE pc_id=:id', [
			':cf' => $conf, 
			':fl' => $file,
			':in' => $index, 
			':ws' => $ws, 
			':id' => $this->id, 
		]);
		$this->config = json_decode($conf, true);
	}

	/**
	 * Content to be add to the head part of the page index.
	 * @return	string	the content to be placed at head
	 */
	public function indexHead() {
		return("<!-- head " . $this->id . " -->\r\n");
	}
	
	/**
	 * Content to be add to the end of body part of the page index.
	 * @return	string	the content to be placed at body end
	 */
	public function indexEndBody() {
		return("<!-- body end " . $this->id . " -->\r\n");
	}
	
}