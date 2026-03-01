<?php

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

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
	public function indexHead($mode = '') {
		$text = parent::indexHead($mode);
		if ($mode != 'editor') {
			if (isset($this->config['measurementid'])) {
				$text .= '<script async src="https://www.googletagmanager.com/gtag/js?id=' . $this->config['measurementid'] . '"></script><script> window.dataLayer = window.dataLayer || []; function gtag(){dataLayer.push(arguments);} gtag("js", new Date()); gtag("config", "' . $this->config['measurementid'] . '", { cookie_flags: "SameSite=None;Secure" });</script>';
			}
		}
		return ($text);
	}
	
}