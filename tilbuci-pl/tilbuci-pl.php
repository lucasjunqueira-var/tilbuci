<?php
/**
 * Plugin Name: TilBuci
 * Plugin URI: https://plugin.tilbuci.com.br/
 * Description: Integrate TilBuci interactive content creation tool into WordPress.
 * Version: 21.0.0
 * Author: Lucas Junqueira
 * License: MPL-2.0
 * License URI: https://mozilla.org/MPL/2.0/
 * Text Domain: tilbuci-pl
 * Requires at least: 6.7.2
 * Tested up to: 6.9.1
 * Requires PHP: 8.1
 */

/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Define plugin constants
define('TILBUCI_WP_VERSION', '21.0.0');
define('TILBUCI_WP_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('TILBUCI_WP_PLUGIN_URL', plugin_dir_url(__FILE__));
define('TILBUCI_WP_BASENAME', plugin_basename(__FILE__));

// Include required files
require_once TILBUCI_WP_PLUGIN_DIR . 'includes/class-tilbuci-pl.php';
require_once TILBUCI_WP_PLUGIN_DIR . 'includes/class-tilbuci-pl-db.php';
require_once TILBUCI_WP_PLUGIN_DIR . 'includes/class-tilbuci-pl-shortcode.php';

// Initialize the plugin
function tilbuci_wp_init() {
    $plugin = new TilBuci_WP();
    $plugin->run();
}
add_action('plugins_loaded', 'tilbuci_wp_init');

// Activation and deactivation hooks
register_activation_hook(__FILE__, array('TilBuci_WP_DB', 'activate'));
register_deactivation_hook(__FILE__, array('TilBuci_WP_DB', 'deactivate'));

// Add an about link on the plugin page
function tilbuci_wp_about_link($links) {
    $about_link = '<a href="https://plugin.tilbuci.com.br/" target="_blank">' . __('About', 'tilbuci-pl') . '</a>';
    array_unshift($links, $about_link);
    $repository_link = '<a href="https://github.com/lucasjunqueira-var/tilbuci" target="_blank">' . __('Code Repository', 'tilbuci-pl') . '</a>';
    array_unshift($links, $repository_link);
    return $links;
}
add_filter('plugin_action_links_' . TILBUCI_WP_BASENAME, 'tilbuci_wp_about_link');