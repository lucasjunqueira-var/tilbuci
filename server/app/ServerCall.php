<?php

/** CLASS DEFINITIONS **/
require_once('Plugin.php');

/**
 * Plugin base.
 */
class ServerCall extends Plugin
{

	/**
	 * Constructor.
	 */
	public function __construct()
	{
		parent::__construct('server-call', 'ServerCall', '1', '0');
	}

	/**
	 * Calls an URL.
	 * @return	string|bool	the returned text or false on error
	 */
	public function callUrl($url) {
		$ch = curl_init();
		curl_setopt($ch, \CURLOPT_URL, $url);
		curl_setopt($ch, \CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, \CURLOPT_HTTPGET, 1);
		$res = curl_exec($ch);
		curl_close($ch);
		return ($res);
	}
	
	/**
	 * Calls an URL for data processing.
	 */
	public function callProcess($url, $data, $movieid, $sceneid, $movietitle, $scenetitle, $visitor) {
		$ch = curl_init();
		curl_setopt($ch, \CURLOPT_URL, $url);
		curl_setopt($ch, \CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
		curl_setopt($ch, CURLOPT_POSTFIELDS, implode('&', [
			'movieid='.urlencode($movieid), 
			'sceneid='.urlencode($sceneid), 
			'movietitle='.urlencode($movietitle), 
			'scenetitle='.urlencode($scenetitle), 
			'visitor='.urlencode($visitor), 
			'data='.urlencode($data), 
		]));
		$res = curl_exec($ch);
		curl_close($ch);
		$json = json_decode($res, true);
		if (json_last_error() == JSON_ERROR_NONE) {
			return (json_encode($json));
		} else {
			return (false);
		}
	}
}