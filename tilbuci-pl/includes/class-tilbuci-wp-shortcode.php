<?php
/**
 * Shortcode handling for TilBuci WP
 *
 * @package TilBuci_WP
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Shortcode class for TilBuci WP
 */
class TilBuci_WP_Shortcode {

    /**
     * Register shortcodes
     */
    public static function init() {
        add_shortcode('tilbuci', array(__CLASS__, 'render_tilbuci_shortcode'));
    }

    /**
     * Render TilBuci shortcode
     *
     * @param array $atts Shortcode attributes
     * @return string HTML output
     */
    public static function render_tilbuci_shortcode($atts) {
        // Default attributes
        $defaults = array(
            'project'   => '',
            'width'     => '100%',
            'height'    => '600',
            'mode'      => 'player', // 'player' or 'editor'
            'autoplay'  => 'false',
            'controls'  => 'true',
        );

        // Parse attributes
        $atts = shortcode_atts($defaults, $atts, 'tilbuci');

        // Validate project
        if (empty($atts['project'])) {
            return '<div class="tilbuci-error">' . __('Please specify a project ID', 'tilbuci-wp') . '</div>';
        }

        // Sanitize attributes
        $project_id = sanitize_text_field($atts['project']);
        $width = self::sanitize_size($atts['width']);
        $height = self::sanitize_size($atts['height']);
        $mode = in_array($atts['mode'], array('player', 'editor')) ? $atts['mode'] : 'player';
        $autoplay = filter_var($atts['autoplay'], FILTER_VALIDATE_BOOLEAN);
        $controls = filter_var($atts['controls'], FILTER_VALIDATE_BOOLEAN);

        // Generate container ID
        $container_id = 'tilbuci-container-' . sanitize_html_class($project_id) . '-' . uniqid();

        // Build HTML
        $html = '<div class="tilbuci-wrapper">';
        $html .= '<div id="' . esc_attr($container_id) . '" class="tilbuci-container" ';
        $html .= 'data-project="' . esc_attr($project_id) . '" ';
        $html .= 'data-mode="' . esc_attr($mode) . '" ';
        $html .= 'data-autoplay="' . ($autoplay ? 'true' : 'false') . '" ';
        $html .= 'data-controls="' . ($controls ? 'true' : 'false') . '" ';
        $html .= 'style="width: ' . esc_attr($width) . '; height: ' . esc_attr($height) . ';"></div>';
        $html .= '</div>';

        // Enqueue scripts
        self::enqueue_tilbuci_scripts($project_id, $mode);

        return $html;
    }

    /**
     * Sanitize size value (px, %, em, rem, vh, vw)
     *
     * @param string $size Size value
     * @return string Sanitized size
     */
    private static function sanitize_size($size) {
        if (is_numeric($size)) {
            return $size . 'px';
        }

        // Check if it ends with valid unit
        $units = array('px', '%', 'em', 'rem', 'vh', 'vw');
        foreach ($units as $unit) {
            if (substr($size, -strlen($unit)) === $unit) {
                $numeric = substr($size, 0, -strlen($unit));
                if (is_numeric($numeric)) {
                    return $size;
                }
            }
        }

        // Default to px
        if (is_numeric($size)) {
            return $size . 'px';
        }

        return '100%';
    }

    /**
     * Enqueue TilBuci scripts
     *
     * @param string $project_id Project ID
     * @param string $mode Player or editor mode
     */
    private static function enqueue_tilbuci_scripts($project_id, $mode) {
        // Determine which script to load based on mode
        if ($mode === 'editor') {
            $script_handle = 'tilbuci-editor';
            $script_url = TILBUCI_WP_PLUGIN_URL . 'tilbuci/public/app/TilBuci.js';
        } else {
            $script_handle = 'tilbuci-player';
            $script_url = TILBUCI_WP_PLUGIN_URL . 'tilbuci/public/app/TilBuci-min.js';
        }

        // Enqueue main script
        wp_enqueue_script(
            $script_handle,
            $script_url,
            array('jquery'),
            TILBUCI_WP_VERSION,
            true
        );

        // Localize script with project data
        wp_localize_script(
            $script_handle,
            'tilbuci_vars',
            array(
                'ajax_url' => admin_url('admin-ajax.php'),
                'project_id' => $project_id,
                'nonce' => wp_create_nonce('tilbuci_nonce'),
            )
        );

        // Enqueue styles
        wp_enqueue_style(
            'tilbuci-styles',
            TILBUCI_WP_PLUGIN_URL . 'public/css/tilbuci-styles.css',
            array(),
            TILBUCI_WP_VERSION
        );
    }

    /**
     * Get project data
     *
     * @param string $project_id Project ID
     * @return array|false Project data or false if not found
     */
    public static function get_project_data($project_id) {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'tilbuci_movies';
        $project = $wpdb->get_row(
            $wpdb->prepare(
                "SELECT * FROM %i WHERE %i = %d OR %i = %s",
                $table_name, 'id', $project_id, 'name', $project_id
            )
        );

        return $project;
    }

    /**
     * Get all projects
     *
     * @return array List of projects
     */
    public static function get_all_projects() {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'tilbuci_movies';
        $projects = $wpdb->get_results($wpdb->prepare(
            "SELECT %i, %i, %i, %i FROM %i ORDER BY %i DESC", 
            'id', 'name', 'description', 'created_at', $table_name, 'created_at'
        ));

        return $projects;
    }
}

// Initialize shortcodes
TilBuci_WP_Shortcode::init();