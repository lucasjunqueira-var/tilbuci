<?php

/** CLASS DEFINITIONS **/
require_once('Plugin.php');

/**
 * Plugin base.
 */
class GoogleAnalytics extends Plugin
{

	/**
	 * Constructor.
	 */
	public function __construct()
	{
		parent::__construct('google-analytics', 'GoogleAnalytics', '1', '0');
	}

	/**
	 * Content to be add to the head part of the page index.
	 * @return	string	the content to be placed at head
	 */
	public function indexHead() {
		$text = parent::indexHead();
		if (isset($this->config['measurementid'])) {
			$text .= '<script async src="https://www.googletagmanager.com/gtag/js?id=G-SZX51EYVF0"></script><script> window.dataLayer = window.dataLayer || []; function gtag(){dataLayer.push(arguments);} gtag("js", new Date()); gtag("config", "' . $this->config['measurementid'] . '", { cookie_flags: "SameSite=None;Secure" });</script>';
		}
		return ($text);
	}
	
}