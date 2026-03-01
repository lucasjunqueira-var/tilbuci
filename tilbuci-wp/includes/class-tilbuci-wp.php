<?php
/**
 * Main plugin class
 *
 * @package TilBuci_WP
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Main TilBuci_WP class
 */
class TilBuci_WP {

    /**
     * Plugin version
     *
     * @var string
     */
    private $version;

    /**
     * Constructor
     */
    public function __construct() {
        $this->version = TILBUCI_WP_VERSION;
    }

    /**
     * Run the plugin
     */
    public function run() {
        $this->load_dependencies();
        $this->set_locale();
        $this->define_admin_hooks();
        $this->define_public_hooks();
        $this->register_shortcodes();
        $this->register_blocks();
        $this->register_rest_routes();
    }

    /**
     * Load required dependencies
     */
    private function load_dependencies() {
        // Dependencies are already loaded in the main plugin file
    }

    /**
     * Set locale for internationalization
     */
    private function set_locale() {
        add_action('plugins_loaded', array($this, 'load_plugin_textdomain'));
    }

    /**
     * Load plugin text domain
     */
    public function load_plugin_textdomain() {
        load_plugin_textdomain(
            'tilbuci-wp',
            false,
            dirname(TILBUCI_WP_BASENAME) . '/languages/'
        );
    }

    /**
     * Register admin hooks
     */
    private function define_admin_hooks() {
        if (is_admin()) {
            add_action('admin_menu', array($this, 'add_admin_menu'));
            add_action('admin_enqueue_scripts', array($this, 'enqueue_admin_scripts'));
        }
    }

    /**
     * Register public hooks
     */
    private function define_public_hooks() {
        add_action('wp_enqueue_scripts', array($this, 'enqueue_public_scripts'));
    }

    /**
     * Register shortcodes
     */
    private function register_shortcodes() {
        // Shortcode registration is handled by TilBuci_WP_Shortcode class
    }

    /**
     * Register Gutenberg blocks
     */
    private function register_blocks() {
        // Block registration will be handled by TilBuci_WP_Blocks class
        // For now, we'll add an action to init block registration
        add_action('init', array($this, 'register_tilbuci_block'));
    }

    /**
     * Register TilBuci Gutenberg block
     */
    public function register_tilbuci_block() {
        // Check if Gutenberg is active
        if (!function_exists('register_block_type')) {
            return;
        }

        // Register block script
        wp_register_script(
            'tilbuci-block',
            TILBUCI_WP_PLUGIN_URL . 'assets/js/block.js',
            array('wp-blocks', 'wp-element', 'wp-editor', 'wp-components', 'wp-i18n'),
            TILBUCI_WP_VERSION,
            true
        );

        // Register block
        register_block_type('tilbuci-wp/tilbuci-block', array(
            'editor_script' => 'tilbuci-block',
            'render_callback' => array($this, 'render_tilbuci_block'),
            'attributes' => array(
                'movieId' => array(
                    'type' => 'string',
                    'default' => '',
                ),
                'fullScreen' => array(
                    'type' => 'boolean',
                    'default' => false,
                ),
                'height' => array(
                    'type' => 'number',
                    'default' => 56,
                ),
            ),
        ));
    }

    /**
     * Render TilBuci block on frontend
     */
    public function render_tilbuci_block($attributes) {
        $movie_id = isset($attributes['movieId']) ? sanitize_text_field($attributes['movieId']) : '';
        
        // If no movie is selected, don't display anything to visitors
        if (empty($movie_id)) {
            return '';
        }

        // Visitor handling - if there is a logged WordPress user
        $user = '';
        $uk = '';
        if (is_user_logged_in()) {
            global $wpdb;
            
            // 1. Get user value (email or login)
            $current_user = wp_get_current_user();
            $user = $current_user->user_email;
            if (empty($user)) {
                $user = $current_user->user_login;
            }
            
            // 2. Generate random key using MD5
            $key = md5(wp_generate_password(32, true, true));
            
            // 3. Insert or update visitor record
            $visitors_table = 'tilbuci_visitors';
            $wpdb->query($wpdb->prepare(
                "INSERT INTO $visitors_table (vs_email, vs_key, vs_code) VALUES (%s, %s, 'A1B2C3') ON DUPLICATE KEY UPDATE vs_key=VALUES(vs_key)",
                $user,
                $key
            ));
            
            // 4. Check if user is associated with group 1
            $visitorassoc_table = 'tilbuci_visitorassoc';
            $existing_assoc = $wpdb->get_var($wpdb->prepare(
                "SELECT va_id FROM $visitorassoc_table WHERE va_visitor=%s AND va_group=1",
                $user
            ));
            
            // 5. If not associated, insert association
            if (empty($existing_assoc)) {
                $wpdb->insert(
                    $visitorassoc_table,
                    array(
                        'va_visitor' => $user,
                        'va_group' => 1
                    ),
                    array('%s', '%d')
                );
            }
            
            // Calculate uk parameter for iframe URL (MD5 of user + key)
            $uk = md5($user . $key);
        }

        $site_url = get_option('siteurl');
        $iframe_url = $site_url . '/wp-content/plugins/tilbuci-wp/tilbuci/public/app/?mv=' . urlencode($movie_id);
        
        // Append user parameters if user is logged in
        if (!empty($user) && !empty($uk)) {
            $iframe_url .= '&us=' . urlencode($user) . '&uk=' . $uk;
        }
        
        // Get display settings
        $full_screen = isset($attributes['fullScreen']) ? $attributes['fullScreen'] : false;
        $height_percentage = isset($attributes['height']) ? intval($attributes['height']) : 60;
        
        // Ensure height percentage is between 0 and 100
        if ($height_percentage < 0) $height_percentage = 0;
        if ($height_percentage > 100) $height_percentage = 100;
        
        // Start output
        $output = '';
        
        if ($full_screen) {
            // Full screen mode - iframe covers entire viewport
            $output .= '<div class="tilbuci-block-wrapper" style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 999999; margin: 0; padding: 0; overflow: unset; background: #000;">';
            $output .= '<iframe src="' . esc_url($iframe_url) . '" ';
            $output .= 'style="position: absolute; top: 0; left: 0; width: 100vw; height: 100vh; border: none; margin: 0; padding: 0;" ';
            $output .= 'title="' . esc_attr__('TilBuci Movie Player', 'tilbuci-wp') . '" ';
            $output .= 'allowfullscreen></iframe>';
            $output .= '</div>';
        } else {
            // Normal mode - iframe width is 100% of container, height will be calculated via JavaScript
            $wrapper_style = 'width: 100%; margin: 0 auto;';
            $iframe_style = 'border: none; width: 100%;';
            
            // Create wrapper with data attribute for height percentage
            $output .= '<div class="tilbuci-block-wrapper" style="' . $wrapper_style . '" data-height-percentage="' . esc_attr($height_percentage) . '">';
            $output .= '<iframe src="' . esc_url($iframe_url) . '" ';
            $output .= 'style="' . $iframe_style . '" ';
            $output .= 'title="' . esc_attr__('TilBuci Movie Player', 'tilbuci-wp') . '" ';
            $output .= 'allowfullscreen></iframe>';
            $output .= '</div>';
            
            // Add inline JavaScript to calculate height after page load
            $output .= '<script>';
            $output .= '(function() {';
            $output .= '    var wrapper = document.currentScript.previousElementSibling;';
            $output .= '    var iframe = wrapper.querySelector("iframe");';
            $output .= '    var heightPercentage = parseInt(wrapper.getAttribute("data-height-percentage")) || 60;';
            $output .= '    function updateHeight() {';
            $output .= '        var width = iframe.offsetWidth;';
            $output .= '        var height = (width * heightPercentage) / 100;';
            $output .= '        iframe.style.height = height + "px";';
            $output .= '    }';
            $output .= '    if (document.readyState === "loading") {';
            $output .= '        document.addEventListener("DOMContentLoaded", function() {';
            $output .= '            updateHeight();';
            $output .= '            window.addEventListener("resize", updateHeight);';
            $output .= '        });';
            $output .= '    } else {';
            $output .= '        updateHeight();';
            $output .= '        window.addEventListener("resize", updateHeight);';
            $output .= '    }';
            $output .= '})();';
            $output .= '</script>';
        }
        
        return $output;
    }

    /**
     * Add admin menu
     */
    public function add_admin_menu() {
        // Main menu - TilBuci (no submenus)
        add_menu_page(
            __('TilBuci', 'tilbuci-wp'),
            __('TilBuci', 'tilbuci-wp'),
            'manage_options',
            'tilbuci-wp',
            array($this, 'display_tilbuci_page'),
            'dashicons-pets',
            30
        );
    }

    /**
     * Display TilBuci main page
     */
    public function display_tilbuci_page() {
        global $wpdb;
        
        // Check and update plugin version before proceeding (as per specification)
        require_once dirname(__FILE__) . '/class-tilbuci-wp-db.php';
        TilBuci_WP_DB::check_and_update_version();
        
        // 1. Generate random key as MD5 of random string
        $random_string = wp_generate_password(32, false);
        $key = md5($random_string);
        
        // 2. Get current WordPress user email or login
        $current_user = wp_get_current_user();
        $user = $current_user->user_email;
        if (empty($user)) {
            $user = $current_user->user_login;
        }
        
        // 3. Remove existing record from tilbuci_users where us_email = user
        $table_name = 'tilbuci_users';
        $wpdb->delete($table_name, array('us_email' => $user));
        
        // 4. Insert new record
        $data = array(
            'us_email' => $user,
            'us_pass' => $key,
            'us_passtemp' => '',
            'us_key' => $key,
            'us_level' => 0,
            'us_created' => current_time('mysql'),
            'us_updated' => current_time('mysql')
        );
        $wpdb->insert($table_name, $data);
        
        // 5. Create URL for editor
        $site_url = get_option('siteurl');
        $editor_base_url = $site_url . '/wp-content/plugins/tilbuci-wp/tilbuci/public/editor/';
        $params = '?us=' . urlencode($user) . '&uk=' . md5($user . $key);
        $editor_url = $editor_base_url . $params;
        
        // Output minimal HTML with iframe covering entire #wpbody-content area
        ?>
        <style>
            /* Remove left padding from main content area */
            #wpcontent {
                padding-left: 0 !important;
            }
            
            /* Adjust #wpbody-content to cover entire available height of #wpbody */
            #wpbody {
                position: relative;
                height: calc(100vh - 32px); /* Subtract admin bar height */
                margin: 0;
                padding: 0;
            }
            
            #wpbody-content {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                width: 100%;
                height: 100%;
                margin: 0;
                padding: 0;
                overflow: hidden;
            }
            
            /* Hide all other elements inside #wpbody-content */
            #wpbody-content > *:not(#TilBuciArea) {
                display: none !important;
            }
            
            /* Hide WordPress footer */
            #wpfooter {
                display: none !important;
            }
            
            /* Container covering entire #wpbody-content */
            #TilBuciArea {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                margin: 0;
                padding: 0;
                width: 100%;
                height: 100%;
            }
            
            /* Iframe filling the container */
            #TilBuciArea iframe {
                width: 100%;
                height: 100%;
                border: none;
                display: block;
            }
            
            /* Ensure html and body have full height */
            html, body {
                height: 100%;
                overflow: hidden;
            }
            
            /* Adjust for WordPress admin bar */
            #wpadminbar {
                position: fixed;
                z-index: 9999;
            }
        </style>
        <div id="TilBuciArea">
            <iframe
                src="<?php echo esc_url($editor_url); ?>"
                title="<?php echo esc_attr__('TilBuci Editor', 'tilbuci-wp'); ?>"
                allow="fullscreen"
            ></iframe>
        </div>
        <?php
    }

    /**
     * Display Events page (blank for now)
     */
    public function display_events_page() {
        ?>
        <div class="wrap">
            <h1><?php echo esc_html__('Events', 'tilbuci-wp'); ?></h1>
            <div class="card">
                <p><?php echo esc_html__('This page is intentionally left blank for future functionality.', 'tilbuci-wp'); ?></p>
            </div>
        </div>
        <?php
    }

    /**
     * Display Visitors page (blank for now)
     */
    public function display_visitors_page() {
        ?>
        <div class="wrap">
            <h1><?php echo esc_html__('Visitors', 'tilbuci-wp'); ?></h1>
            <div class="card">
                <p><?php echo esc_html__('This page is intentionally left blank for future functionality.', 'tilbuci-wp'); ?></p>
            </div>
        </div>
        <?php
    }


    /**
     * Enqueue admin scripts and styles
     */
    public function enqueue_admin_scripts($hook) {
        $allowed_hooks = array(
            'toplevel_page_tilbuci-wp',
            'tilbuci-wp_page_tilbuci-wp-events',
            'tilbuci-wp_page_tilbuci-wp-visitors'
        );
        
        if (!in_array($hook, $allowed_hooks)) {
            return;
        }

        wp_enqueue_style(
            'tilbuci-wp-admin',
            TILBUCI_WP_PLUGIN_URL . 'admin/css/tilbuci-wp-admin.css',
            array(),
            $this->version
        );
    }

    /**
     * Enqueue public scripts and styles
     */
    public function enqueue_public_scripts() {
        // This method is kept for future use if public scripts are needed
        // Currently, TilBuci player scripts are loaded directly from the tilbuci/public directory
    }

    /**
     * Register REST API routes
     */
    private function register_rest_routes() {
        add_action('rest_api_init', array($this, 'register_rest_endpoints'));
    }

    /**
     * Register REST API endpoints
     */
    public function register_rest_endpoints() {
        register_rest_route('tilbuci-wp/v1', '/movies', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_movies_rest'),
            'permission_callback' => function () {
                // Allow any authenticated user (since block needs to fetch movies in editor)
                return current_user_can('read');
            },
        ));
    }

    /**
     * REST API callback to get movies from tilbuci_movies table
     */
    public function get_movies_rest($request) {
        global $wpdb;
        
        $table_name = 'tilbuci_movies';
        
        // Check if table exists
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") != $table_name) {
            return new WP_Error('table_not_found', __('Movies table does not exist', 'tilbuci-wp'), array('status' => 404));
        }
        
        // Get movies from database - use correct column names from table definition
        $movies = $wpdb->get_results(
            "SELECT mv_id, mv_title, mv_about, mv_created, mv_updated
             FROM $table_name
             ORDER BY mv_title ASC"
        );
        
        if (empty($movies)) {
            return new WP_REST_Response(array(), 200);
        }
        
        // Format response
        $formatted_movies = array();
        foreach ($movies as $movie) {
            $formatted_movies[] = array(
                'mv_id' => $movie->mv_id,
                'mv_title' => $movie->mv_title,
                'mv_description' => $movie->mv_about, // Map mv_about to description for frontend
                'mv_created' => $movie->mv_created,
                'mv_updated' => $movie->mv_updated,
            );
        }
        
        return new WP_REST_Response($formatted_movies, 200);
    }
}