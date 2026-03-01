<?php
/**
 * Plugin Name: TilBuci WP
 * Plugin URI: https://github.com/lucasjunqueira-var/tilbuci
 * Description: Integrate TilBuci interactive content creation tool into WordPress.
 * Version: 20.0.0
 * Author: Lucas Junqueira
 * License: GPLv2 or above
 * License URI: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
 * Text Domain: tilbuci-wp
 * Domain Path: /languages
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Define plugin constants
define('TILBUCI_WP_VERSION', '1.0.0');
define('TILBUCI_WP_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('TILBUCI_WP_PLUGIN_URL', plugin_dir_url(__FILE__));
define('TILBUCI_WP_BASENAME', plugin_basename(__FILE__));

// Include required files
require_once TILBUCI_WP_PLUGIN_DIR . 'includes/class-tilbuci-wp.php';
require_once TILBUCI_WP_PLUGIN_DIR . 'includes/class-tilbuci-wp-db.php';
require_once TILBUCI_WP_PLUGIN_DIR . 'includes/class-tilbuci-wp-shortcode.php';

// Initialize the plugin
function tilbuci_wp_init() {
    $plugin = new TilBuci_WP();
    $plugin->run();
}
add_action('plugins_loaded', 'tilbuci_wp_init');

// Activation and deactivation hooks
register_activation_hook(__FILE__, array('TilBuci_WP_DB', 'activate'));
register_deactivation_hook(__FILE__, array('TilBuci_WP_DB', 'deactivate'));

// Add a settings link on the plugin page
function tilbuci_wp_settings_link($links) {
    $settings_link = '<a href="admin.php?page=tilbuci-wp-settings">' . __('Settings', 'tilbuci-wp') . '</a>';
    array_unshift($links, $settings_link);
    return $links;
}
add_filter('plugin_action_links_' . TILBUCI_WP_BASENAME, 'tilbuci_wp_settings_link');