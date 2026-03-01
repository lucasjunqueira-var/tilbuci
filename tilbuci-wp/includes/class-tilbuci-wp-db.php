<?php
/**
 * Database handling for TilBuci WP
 *
 * @package TilBuci_WP
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Database class for TilBuci WP
 */
class TilBuci_WP_DB {

    /**
     * Activate the plugin - create database tables and populate data
     */
    public static function activate() {
        global $wpdb;

        // Execute tables.sql
        self::execute_sql_file('tables.sql');

        // Check if dbVersion record exists in tilbuci_config table (as per specification)
        $db_version_exists = $wpdb->get_var("SELECT COUNT(*) FROM tilbuci_config WHERE cf_key = 'dbVersion'");
        
        if (!$db_version_exists) {
            // Execute data.sql
            self::execute_sql_file('data.sql');
        }

        // Update Config.php with WordPress database settings
        self::update_config_file();

        // Update editor.json and player.json files
        self::update_json_files();

        // Add plugin version option
        add_option('tilbuci_wp_version', TILBUCI_WP_VERSION);
    }

    /**
     * Execute SQL file from tilbuci directory (as per specification)
     *
     * @param string $filename SQL file name (tables.sql or data.sql)
     */
    private static function execute_sql_file($filename) {
        global $wpdb;

        $sql_file = dirname(dirname(__FILE__)) . '/tilbuci/' . $filename;
        
        if (!file_exists($sql_file)) {
            error_log('TilBuci WP: SQL file not found: ' . $sql_file);
            return;
        }

        // Read SQL file
        $sql = file_get_contents($sql_file);
        if ($sql === false) {
            error_log('TilBuci WP: Failed to read SQL file: ' . $sql_file);
            return;
        }

        // Split SQL statements (assuming each statement ends with ; and newline)
        $queries = explode(';', $sql);
        
        foreach ($queries as $query) {
            $query = trim($query);
            if (!empty($query)) {
                // Execute query as-is (table names must be preserved as per specification)
                $wpdb->query($query);
            }
        }
    }

    /**
     * Update Config.php file with WordPress database settings
     */
    private static function update_config_file() {
        $config_file = dirname(dirname(__FILE__)) . '/tilbuci/app/Config.php';
        
        // Default content as per specification
        $default_content = '<?php
global $gconf;
$gconf = [
\'databaseServ\' => \'\',
\'databaseUser\' => \'\',
\'databasePass\' => \'\',
\'databaseName\' => \'\',
\'databasePort\' => \'\',
\'databasePrefix\' => \'tilbuci_\',
\'path\' => \'\',
\'singleUser\' => false,
\'encVec\' => \'1234567890123456\',
\'encKey\' => \'b8f983e2c5d052da195646d79bb3af1e\',
\'secret\' => \'dbfa29a53f4b366c1b8e9ae0402439e3\',
\'sceneVersions\' => 10,
];
?>';

        // Create file with default content if it doesn't exist
        if (!file_exists($config_file)) {
            $result = file_put_contents($config_file, $default_content);
            if ($result === false) {
                error_log('TilBuci WP: Failed to create Config.php');
                return;
            }
            $content = $default_content;
        } else {
            // Read the current content
            $content = file_get_contents($config_file);
            if ($content === false) {
                error_log('TilBuci WP: Failed to read Config.php');
                return;
            }
        }

        // Get WordPress database settings
        $db_host = DB_HOST;
        $db_user = DB_USER;
        $db_name = DB_NAME;
        $db_password = DB_PASSWORD;
        
        // Encode password if not empty
        $database_pass = '';
        if (!empty($db_password)) {
            $database_pass = base64_encode($db_password);
        }
        
        // Get site URL
        $site_url = get_option('siteurl');
        $path = $site_url . '/wp-content/plugins/tilbuci-wp/tilbuci/public';
        // Ensure path ends with a slash
        $path = trailingslashit($path);

        // Replace the values in the array (looking for empty strings)
        $replacements = [
            "'databaseServ' => ''" => "'databaseServ' => '" . addslashes($db_host) . "'",
            "'databaseUser' => ''" => "'databaseUser' => '" . addslashes($db_user) . "'",
            "'databaseName' => ''" => "'databaseName' => '" . addslashes($db_name) . "'",
            "'databasePass' => ''" => "'databasePass' => '" . addslashes($database_pass) . "'",
            "'path' => ''" => "'path' => '" . addslashes($path) . "'",
        ];

        foreach ($replacements as $search => $replace) {
            $content = str_replace($search, $replace, $content);
        }

        // Write back to file
        $result = file_put_contents($config_file, $content);
        if ($result === false) {
            error_log('TilBuci WP: Failed to write Config.php');
        }
    }

    /**
     * Update editor.json and player.json files with WordPress site URL
     */
    private static function update_json_files() {
        $site_url = get_option('siteurl');
        
        // Default editor.json content as per specification
        $default_editor_json = '{
    "base": "",
    "player": "",
    "ws": "",
    "font": "",
    "secret": "dbfa29a53f4b366c1b8e9ae0402439e3",
    "language": [{
            "name": "English",
            "file": "default"
        }
    ]
}';
        
        // Update editor.json
        $editor_file = dirname(dirname(__FILE__)) . '/tilbuci/public/app/editor.json';
        if (!file_exists($editor_file)) {
            // Create file with default content
            $result = file_put_contents($editor_file, $default_editor_json);
            if ($result === false) {
                error_log('TilBuci WP: Failed to create editor.json');
                return;
            }
            $editor_content = $default_editor_json;
        } else {
            $editor_content = file_get_contents($editor_file);
            if ($editor_content === false) {
                error_log('TilBuci WP: Failed to read editor.json');
                return;
            }
        }
        
        // Replace empty strings with actual URLs
        $editor_content = preg_replace(
            '/"base":\s*""/',
            '"base":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-wp/tilbuci/public/editor/"',
            $editor_content
        );
        $editor_content = preg_replace(
            '/"player":\s*""/',
            '"player":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-wp/tilbuci/public/"',
            $editor_content
        );
        $editor_content = preg_replace(
            '/"ws":\s*""/',
            '"ws":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-wp/tilbuci/public/ws/"',
            $editor_content
        );
        $editor_content = preg_replace(
            '/"font":\s*""/',
            '"font":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-wp/tilbuci/public/font/"',
            $editor_content
        );
        
        file_put_contents($editor_file, $editor_content);
        
        // Default player.json content as per specification
        $default_player_json = '{
    "server": true,
    "base": "",
    "ws": "",
    "font": "",
    "systemfonts": [{
            "name": "Averia Serif GWF",
            "file": "averiaserifgwf.woff2"
        }, {
            "name": "Liberation Serif",
            "file": "liberationserif.woff2"
        }, {
            "name": "Libra Sans",
            "file": "librasans.woff2"
        }, {
            "name": "Roboto Sans",
            "file": "roboto.woff2"
        }
    ],
    "start": "",
    "render": "webgl",
    "share": "scene",
    "fps": "free",
    "secret": "dbfa29a53f4b366c1b8e9ae0402439e3"
}';
        
        // Update player.json
        $player_file = dirname(dirname(__FILE__)) . '/tilbuci/public/app/player.json';
        if (!file_exists($player_file)) {
            // Create file with default content
            $result = file_put_contents($player_file, $default_player_json);
            if ($result === false) {
                error_log('TilBuci WP: Failed to create player.json');
                return;
            }
            $player_content = $default_player_json;
        } else {
            $player_content = file_get_contents($player_file);
            if ($player_content === false) {
                error_log('TilBuci WP: Failed to read player.json');
                return;
            }
        }
        
        // Replace empty strings with actual URLs
        $player_content = preg_replace(
            '/"base":\s*""/',
            '"base":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-wp/tilbuci/public/"',
            $player_content
        );
        $player_content = preg_replace(
            '/"ws":\s*""/',
            '"ws":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-wp/tilbuci/public/ws/"',
            $player_content
        );
        $player_content = preg_replace(
            '/"font":\s*""/',
            '"font":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-wp/tilbuci/public/font/"',
            $player_content
        );
        
        file_put_contents($player_file, $player_content);
    }
/**
 * Check and update plugin version by executing SQL update files
 * This should be called when the plugin page loads in WordPress dashboard
 */
public static function check_and_update_version() {
    global $wpdb;
    
    // Get current version from database (correct query as per specification)
    $current_version = $wpdb->get_var("SELECT cf_value FROM tilbuci_config WHERE cf_key = 'dbVersion'");
    
    // If no version found, assume version 0 (initial installation)
    if ($current_version === null) {
        $current_version = 0;
    } else {
        $current_version = intval($current_version);
    }
    
    // Get latest version from version.md file
    $version_file = dirname(dirname(__FILE__)) . '/tilbuci/version.md';
    if (!file_exists($version_file)) {
        error_log('TilBuci WP: version.md file not found');
        return;
    }
    
    $latest_version = intval(trim(file_get_contents($version_file)));
    
    // If latest version is greater than current version, execute update files
    if ($latest_version > $current_version) {
        // Loop through version numbers from current+1 to latest
        for ($version = $current_version + 1; $version <= $latest_version; $version++) {
            $update_file = dirname(dirname(__FILE__)) . '/tilbuci/update/' . $version . '.sql';
            
            if (file_exists($update_file)) {
                // Execute the SQL update file
                self::execute_sql_update_file($update_file);
                
                // Update version in database after successful execution
                // Use INSERT ... ON DUPLICATE KEY UPDATE to handle both insert and update
                $wpdb->query($wpdb->prepare(
                    "INSERT INTO tilbuci_config (cf_key, cf_value) VALUES ('dbVersion', %d)
                     ON DUPLICATE KEY UPDATE cf_value = %d",
                    $version, $version
                ));
                
                error_log('TilBuci WP: Updated to version ' . $version);
            } else {
                error_log('TilBuci WP: Update file not found for version ' . $version);
            }
        }
    }
}

/**
 * Execute SQL update file (similar to execute_sql_file but for update files)
 *
 * @param string $filename Full path to SQL update file
 */
private static function execute_sql_update_file($filename) {
    global $wpdb;
    
    if (!file_exists($filename)) {
        error_log('TilBuci WP: SQL update file not found: ' . $filename);
        return;
    }

    // Read SQL file
    $sql = file_get_contents($filename);
    if ($sql === false) {
        error_log('TilBuci WP: Failed to read SQL update file: ' . $filename);
        return;
    }

    // Split SQL statements (assuming each statement ends with ; and newline)
    $queries = explode(';', $sql);
    
    foreach ($queries as $query) {
        $query = trim($query);
        if (!empty($query)) {
            // Execute query as-is (table names must be preserved as per specification)
            $wpdb->query($query);
        }
    }
}

/**
 * Deactivate the plugin
 */
public static function deactivate() {
    // Remove plugin options
    delete_option('tilbuci_wp_version');
    delete_option('tilbuci_wp_remove_tables_on_deactivate');
}
}
