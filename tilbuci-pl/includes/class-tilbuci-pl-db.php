<?php
/**
 * Database handling for TilBuci WP
 *
 * @package TilBuci_WP
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

/**
 * Database class for TilBuci WP
 */
class TilBuci_WP_DB {

    /**
     * Activate the plugin - create database tables and populate data
     */
    public static function activate() {
        global $wpdb;

        // Create tables using dbDelta (WordPress recommended method)
        self::create_tables_with_dbdelta();

        // Check if dbVersion record exists in tilbuci_config table
        $table_prefix = $wpdb->prefix;
        $config_table = $table_prefix . 'tilbuci_config';
        $db_version_exists = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM %i WHERE %i = %s", 
            $config_table, 'cf_key', 'dbVersion'
        ));
        
        if (!$db_version_exists) {
            // Execute data.sql using regular query execution
            self::execute_sql_file('data.sql');
        }

        // Update Config.php with WordPress database settings (just failsafe - on WordPress, use $wpdb instead)
        self::update_config_file();

        // Update editor.json and player.json files
        self::update_json_files();

        // Restore previous data from backup folder (data.sql and zip files)
        self::restore_previous_data();

        // Add plugin version option
        add_option('tilbuci_wp_version', TILBUCI_WP_VERSION);
    }

    /**
     * Deactivate the plugin - remove tables, configuration files, and movie folders
     */
    public static function deactivate() {
        global $wpdb;

        // 0. Create backups of movie folders before removing anything
        if (class_exists('TilBuci_WP')) {
            $plugin = new TilBuci_WP();
            $plugin->create_movie_backups();
        }

        // 1. Remove all tables containing "tilbuci_" in the name
        $tables = $wpdb->get_col($wpdb->prepare("SHOW TABLES LIKE %s", '%tilbuci_%'));
        foreach ($tables as $table) {
            $wpdb->query($wpdb->prepare("DROP TABLE IF EXISTS %i", $table));
        }

        // 2. Delete configuration files
        $plugin_dir = dirname(dirname(__FILE__));
        
        // Config.php
        $config_file = $plugin_dir . '/tilbuci/app/Config.php';
        if (file_exists($config_file)) {
            wp_delete_file($config_file);
        }
        
        // editor.json
        $editor_file = $plugin_dir . '/tilbuci/public/app/editor.json';
        if (file_exists($editor_file)) {
            wp_delete_file($editor_file);
        }
        
        // player.json
        $player_file = $plugin_dir . '/tilbuci/public/app/player.json';
        if (file_exists($player_file)) {
            wp_delete_file($player_file);
        }

        // 3. Remove all folders inside public/movie/
        $movie_dir = $plugin_dir . '/tilbuci/public/movie/';
        if (is_dir($movie_dir)) {
            $folders = glob($movie_dir . '*', GLOB_ONLYDIR);
            foreach ($folders as $folder) {
                self::delete_directory($folder);
            }
        }

        // Remove plugin version option
        delete_option('tilbuci_wp_version');
    }

    /**
     * Restore previous data from backup folder (data.sql and zip files)
     * Should be called during plugin activation after tables are created
     */
    public static function restore_previous_data() {
        global $wpdb;
        
        // Ensure uploads/tilbuci directory exists
        $upload_dir = wp_upload_dir();
        $backup_dir = trailingslashit($upload_dir['basedir']) . 'tilbuci/';
        
        if (!is_dir($backup_dir)) {
            // No backup directory, nothing to restore
            return;
        }
        
        // 1. Restore data.sql if exists
        $data_sql_file = $backup_dir . 'data.sql';
        if (file_exists($data_sql_file)) {
            self::restore_data_sql($data_sql_file);
        }
        
        // 2. Restore zip files (movie backups)
        $zip_files = glob($backup_dir . '*.zip');
        foreach ($zip_files as $zip_file) {
            self::restore_movie_zip($zip_file);
        }
    }

    /**
     * Restore database from data.sql backup file
     *
     * @param string $sql_file Path to data.sql file
     */
    private static function restore_data_sql($sql_file) {
        global $wpdb;
        
        $sql_content = file_get_contents($sql_file);
        if ($sql_content === false) {
            return;
        }
        
        // Replace {PR} placeholder with actual table prefix
        $table_prefix = $wpdb->prefix;
        $sql_content = str_replace('{PR}', $table_prefix, $sql_content);
        
        // Split SQL statements by semicolon, handling multi-line statements
        // First normalize line endings
        $sql_content = str_replace(["\r\n", "\r"], "\n", $sql_content);
        
        // Remove SQL comments (-- comment)
        $sql_content = preg_replace('/--.*$/m', '', $sql_content);
        
        // Split SQL statements by semicolon, being careful with semicolons inside strings
        // Simple approach: split by semicolon at line end or followed by whitespace and newline
        $statements = preg_split('/;(?=\s*\n|$)/', $sql_content);
        
        // Group INSERT statements by table
        $inserts_by_table = [];
        
        foreach ($statements as $stmt) {
            $stmt = trim($stmt);
            if (empty($stmt)) {
                continue;
            }
            
            // Skip lines that are just table names (e.g., "tb_tilbuci_assets;")
            if (preg_match('/^[a-z_]+$/i', $stmt)) {
                continue;
            }
            
            // Skip CREATE TABLE statements entirely
            if (stripos($stmt, 'CREATE TABLE') === 0) {
                continue;
            }
            
            // Skip TRUNCATE TABLE statements (we'll handle truncation ourselves)
            if (stripos($stmt, 'TRUNCATE TABLE') === 0) {
                continue;
            }
            
            // Process INSERT INTO statements
            if (stripos($stmt, 'INSERT INTO') === 0) {
                // Extract table name with backticks
                if (preg_match('/INSERT INTO\s+`([^`]+)`/i', $stmt, $matches)) {
                    $table_name = $matches[1];
                } elseif (preg_match('/INSERT INTO\s+([^\s\(]+)/i', $stmt, $matches)) {
                    $table_name = $matches[1];
                } else {
                    continue;
                }
                
                // Check if it's a tilbuci table
                if (strpos($table_name, 'tilbuci_') !== false) {
                    if (!isset($inserts_by_table[$table_name])) {
                        $inserts_by_table[$table_name] = [];
                    }
                    // Ensure statement ends with semicolon
                    if (substr($stmt, -1) !== ';') {
                        $stmt .= ';';
                    }
                    $inserts_by_table[$table_name][] = $stmt;
                }
            }
        }
        
        // For each table, truncate once then execute all INSERTs
        foreach ($inserts_by_table as $table_name => $inserts) {
            // Truncate table (clear existing data)
            $wpdb->query($wpdb->prepare("TRUNCATE TABLE %i", $table_name));
            
            // Execute all INSERTs for this table
            foreach ($inserts as $insert_stmt) {
                $result = $wpdb->query($insert_stmt);
                // Optional: log errors for debugging
                if ($result === false) {
                    error_log("Failed to execute SQL for table $table_name: " . $wpdb->last_error . " - Statement: " . substr($insert_stmt, 0, 200));
                }
            }
        }
    }

    /**
     * Restore movie from zip backup file
     *
     * @param string $zip_file Path to zip file
     */
    private static function restore_movie_zip($zip_file) {
        $plugin_dir = dirname(dirname(__FILE__));
        $movie_base = $plugin_dir . '/tilbuci/public/movie/';
        
        // Extract movie ID from filename (e.g., "123.zip" -> "123")
        $filename = basename($zip_file, '.zip');
        
        // Create movie folder
        $movie_folder = $movie_base . $filename . '.movie/';
        
        if (!is_dir($movie_folder)) {
            wp_mkdir_p($movie_folder);
        }
        
        // Check if ZipArchive is available
        if (!class_exists('ZipArchive')) {
            return;
        }
        
        $zip = new ZipArchive();
        if ($zip->open($zip_file) === TRUE) {
            // Extract all contents to movie folder
            $zip->extractTo($movie_folder);
            $zip->close();
        }
    }

    /**
     * Recursively delete a directory and its contents
     *
     * @param string $dir Directory path
     */
    private static function delete_directory( $dir ) {
        global $wp_filesystem;
        if ( ! function_exists( 'WP_Filesystem' ) ) {
            require_once ABSPATH . 'wp-admin/includes/file.php';
        }
        WP_Filesystem();
        if ( ! $wp_filesystem->is_dir( $dir ) ) {
            return;
        }
        $items = $wp_filesystem->dirlist( $dir );
        if ( is_array( $items ) ) {
            foreach ( $items as $item => $details ) {
                $path = trailingslashit( $dir ) . $item;
                if ( 'f' === $details['type'] ) {
                    $wp_filesystem->delete( $path );
                } elseif ( 'd' === $details['type'] ) {
                    self::delete_directory( $path );
                }
            }
        }
        $wp_filesystem->rmdir( $dir, true );
    }

    /**
     * Recursively copy a directory and its contents
     *
     * @param string $source Source directory path
     * @param string $destination Destination directory path
     * @return bool True on success, false on failure
     */
    private static function copy_directory( $source, $destination ) {
        global $wp_filesystem;
        if ( ! function_exists( 'WP_Filesystem' ) ) {
            require_once ABSPATH . 'wp-admin/includes/file.php';
        }
        WP_Filesystem();
        
        // Check if source exists
        if ( ! $wp_filesystem->is_dir( $source ) ) {
            return false;
        }
        
        // Ensure destination directory exists
        if ( ! $wp_filesystem->is_dir( $destination ) ) {
            $wp_filesystem->mkdir( $destination, FS_CHMOD_DIR );
        }
        
        // Get list of items in source directory
        $items = $wp_filesystem->dirlist( $source );
        if ( is_array( $items ) ) {
            foreach ( $items as $item => $details ) {
                $source_path = trailingslashit( $source ) . $item;
                $dest_path = trailingslashit( $destination ) . $item;
                
                if ( 'f' === $details['type'] ) {
                    // Copy file
                    if ( ! $wp_filesystem->copy( $source_path, $dest_path, true, FS_CHMOD_FILE ) ) {
                        return false;
                    }
                } elseif ( 'd' === $details['type'] ) {
                    // Recursively copy directory
                    if ( ! self::copy_directory( $source_path, $dest_path ) ) {
                        return false;
                    }
                }
            }
        }
        
        return true;
    }

    /**
     * Create database tables using WordPress dbDelta method
     * This ensures tables are created or updated safely
     */
    private static function create_tables_with_dbdelta() {
        global $wpdb;
        
        // Include WordPress upgrade functions for dbDelta
        require_once ABSPATH . 'wp-admin/includes/upgrade.php';
        
        $sql_file = dirname(dirname(__FILE__)) . '/tilbuci/tables.sql';
        
        if (!file_exists($sql_file)) {
            // debug only: error_log('TilBuci WP: SQL file not found: ' . $sql_file);
            return;
        }

        // Read SQL file
        $sql = file_get_contents($sql_file);
        if ($sql === false) {
            // debug only: error_log('TilBuci WP: Failed to read SQL file: ' . $sql_file);
            return;
        }

        // Get WordPress table prefix and replace {PR} placeholder
        $table_prefix = $wpdb->prefix;
        $sql = str_replace('{PR}', $table_prefix, $sql);        
        $queries = explode(';', $sql);
        
        foreach ($queries as $query) {
            $query = trim($query);
            if (!empty($query)) {
                // Remove trailing semicolon if present
                $query = rtrim($query, ';');
                // Remove "IF NOT EXISTS" clause for dbDelta compatibility
                $query = preg_replace('/CREATE TABLE IF NOT EXISTS/i', 'CREATE TABLE', $query);
                // Execute dbDelta
                dbDelta($query);
            }
        }
        
        // Log any errors
        if (!empty($wpdb->last_error)) {
            // debug only: error_log('TilBuci WP: dbDelta error: ' . $wpdb->last_error);
        }
    }

    /**
     * Execute SQL file from tilbuci directory 
     *
     * @param string $filename SQL file name (tables.sql or data.sql)
     */
    private static function execute_sql_file($filename) {
        global $wpdb;

        $sql_file = dirname(dirname(__FILE__)) . '/tilbuci/' . $filename;
        
        if (!file_exists($sql_file)) {
            // debug only: error_log('TilBuci WP: SQL file not found: ' . $sql_file);
            return;
        }

        // Read SQL file
        $sql = file_get_contents($sql_file);
        if ($sql === false) {
            // debug only: error_log('TilBuci WP: Failed to read SQL file: ' . $sql_file);
            return;
        }

        // Get WordPress table prefix and replace {PR} placeholder
        $table_prefix = $wpdb->prefix;
        $sql = str_replace('{PR}', $table_prefix, $sql);

        // Split SQL statements (assuming each statement ends with ; and newline)
        $queries = explode(';', $sql);
        
        foreach ($queries as $query) {
            $query = trim($query);
            if (!empty($query)) {
                // Execute query as-is (table names must be preserved as per specification)
                $wpdb->query($wpdb->prepare($query));
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
\'databasePrefix\' => \'{PR}tilbuci_\',
\'path\' => \'\',
\'singleUser\' => false,
\'encVec\' => \'1234567890123456\',
\'encKey\' => \'b8f983e2c5d052da195646d79bb3af1e\',
\'secret\' => \'dbfa29a53f4b366c1b8e9ae0402439e3\',
\'sceneVersions\' => 10,
\'host\' => \'WordPress\',
];
?>';

        // Create file with default content if it doesn't exist
        if (!file_exists($config_file)) {
            $result = file_put_contents($config_file, $default_content);
            if ($result === false) {
                // debug only: error_log('TilBuci WP: Failed to create Config.php');
                return;
            }
            $content = $default_content;
        } else {
            // Read the current content
            $content = file_get_contents($config_file);
            if ($content === false) {
                // debug only: error_log('TilBuci WP: Failed to read Config.php');
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
        $path = $site_url . '/wp-content/plugins/tilbuci-pl/tilbuci/public';
        // Ensure path ends with a slash
        $path = trailingslashit($path);
        
        // Get WordPress table prefix
        global $wpdb;
        $table_prefix = $wpdb->prefix;
        $database_prefix = '{PR}tilbuci_';
        $database_prefix = str_replace('{PR}', $table_prefix, $database_prefix);

        // Replace the values in the array (looking for empty strings)
        $replacements = [
            "'databaseServ' => ''" => "'databaseServ' => '" . addslashes($db_host) . "'",
            "'databaseUser' => ''" => "'databaseUser' => '" . addslashes($db_user) . "'",
            "'databaseName' => ''" => "'databaseName' => '" . addslashes($db_name) . "'",
            "'databasePass' => ''" => "'databasePass' => '" . addslashes($database_pass) . "'",
            "'path' => ''" => "'path' => '" . addslashes($path) . "'",
            "'databasePrefix' => '{PR}tilbuci_'" => "'databasePrefix' => '" . addslashes($database_prefix) . "'",
        ];

        foreach ($replacements as $search => $replace) {
            $content = str_replace($search, $replace, $content);
        }

        // Write back to file
        $result = file_put_contents($config_file, $content);
        if ($result === false) {
            // debug only: error_log('TilBuci WP: Failed to write Config.php');
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
                // debug only: error_log('TilBuci WP: Failed to create editor.json');
                return;
            }
            $editor_content = $default_editor_json;
        } else {
            $editor_content = file_get_contents($editor_file);
            if ($editor_content === false) {
                // debug only: error_log('TilBuci WP: Failed to read editor.json');
                return;
            }
        }
        
        // Replace empty strings with actual URLs
        $editor_content = preg_replace(
            '/"base":\s*""/',
            '"base":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-pl/tilbuci/public/editor/"',
            $editor_content
        );
        $editor_content = preg_replace(
            '/"player":\s*""/',
            '"player":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-pl/tilbuci/public/"',
            $editor_content
        );
        $editor_content = preg_replace(
            '/"ws":\s*""/',
            '"ws":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-pl/tilbuci/public/ws/"',
            $editor_content
        );
        $editor_content = preg_replace(
            '/"font":\s*""/',
            '"font":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-pl/tilbuci/public/font/"',
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
                // debug only: error_log('TilBuci WP: Failed to create player.json');
                return;
            }
            $player_content = $default_player_json;
        } else {
            $player_content = file_get_contents($player_file);
            if ($player_content === false) {
                // debug only: error_log('TilBuci WP: Failed to read player.json');
                return;
            }
        }
        
        // Replace empty strings with actual URLs
        $player_content = preg_replace(
            '/"base":\s*""/',
            '"base":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-pl/tilbuci/public/"',
            $player_content
        );
        $player_content = preg_replace(
            '/"ws":\s*""/',
            '"ws":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-pl/tilbuci/public/ws/"',
            $player_content
        );
        $player_content = preg_replace(
            '/"font":\s*""/',
            '"font":"' . addslashes($site_url) . '/wp-content/plugins/tilbuci-pl/tilbuci/public/font/"',
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
        
        // Get WordPress table prefix
        $table_prefix = $wpdb->prefix;
        $config_table = $table_prefix . 'tilbuci_config';
        
        // Get current version from database
        $current_version = $wpdb->get_var($wpdb->prepare(
            "SELECT %i FROM %i WHERE %i = %s", 
            'cf_value', $config_table, 'cf_key', 'dbVersion'
        ));
        
        // If no version found, assume version 0 (initial installation)
        if ($current_version === null) {
            $current_version = 0;
        } else {
            $current_version = intval($current_version);
        }
        
        // Get latest version from version.md file
        $version_file = dirname(dirname(__FILE__)) . '/tilbuci/version.md';
        if (!file_exists($version_file)) {
            // debug only: error_log('TilBuci WP: version.md file not found');
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
                    $wpdb->query($wpdb->prepare(
                        "INSERT INTO %i (%i, %i) VALUES (%s, %d)
                         ON DUPLICATE KEY UPDATE %i = %d",
                        $config_table, 'cf_key', 'cf_value', 'dbVersion', $version, 'cf_value', $version
                    ));
                    
                    // Clear query cache to ensure immediate reflection of version update
                    $wpdb->flush();
                    
                    // debug only: error_log('TilBuci WP: Updated to version ' . $version);
                } else {
                    // debug only: error_log('TilBuci WP: Update file not found for version ' . $version);
                }
            }
        }
    }

    /**
     * Check remote version for updates (Update method)
     *
     * This method checks the remote version at plugin.tilbuci.com.br/versions/latest.md
     * and compares it with the local database version.
     *
     * @return int|false Returns the remote version number if available and valid,
     *                   false if check failed or version is invalid
     */
    public static function check_remote_version() {
        global $wpdb;
        
        // Get current version from database
        $table_prefix = $wpdb->prefix;
        $config_table = $table_prefix . 'tilbuci_config';
        
        $current_version = $wpdb->get_var($wpdb->prepare(
            "SELECT %i FROM %i WHERE %i = %s",
            'cf_value', $config_table, 'cf_key', 'dbVersion'
        ));
        
        if ($current_version === null) {
            $current_version = 0;
        } else {
            $current_version = intval($current_version);
        }
        
        // Try to fetch remote version - add cache-busting parameter to avoid cached responses
        $remote_url = 'https://plugin.tilbuci.com.br/versions/latest.md';
        // Add timestamp to prevent caching
        $remote_url = add_query_arg('t', time(), $remote_url);
        $response = wp_remote_get($remote_url, array(
            'timeout' => 10,
            'sslverify' => true,
            'reject_unsafe_urls' => false,
            'cache' => false
        ));
        
        // Check for errors
        if (is_wp_error($response)) {
            // debug only: error_log('TilBuci WP: Failed to fetch remote version: ' . $response->get_error_message());
            return false;
        }
        
        $status_code = wp_remote_retrieve_response_code($response);
        if ($status_code !== 200) {
            // debug only: error_log('TilBuci WP: Remote version check returned status code: ' . $status_code);
            return false;
        }
        
        $body = wp_remote_retrieve_body($response);
        $remote_version = trim($body);
        
        // Validate that content is a valid number (integer or decimal)
        if (!is_numeric($remote_version)) {
            // debug only: error_log('TilBuci WP: Remote version is not a valid number: ' . $remote_version);
            return false;
        }
        
        $remote_version = floatval($remote_version);
        
        // Return remote version for comparison
        return $remote_version;
    }

    /**
     * Execute SQL update file (similar to execute_sql_file but for update files)
     *
     * @param string $filename Full path to SQL update file
     */
    private static function execute_sql_update_file($filename) {
        global $wpdb;
        
        if (!file_exists($filename)) {
            // debug only: error_log('TilBuci WP: SQL update file not found: ' . $filename);
            return;
        }

        // Read SQL file
        $sql = file_get_contents($filename);
        if ($sql === false) {
            // debug only: error_log('TilBuci WP: Failed to read SQL update file: ' . $filename);
            return;
        }

        // Get WordPress table prefix and replace {PR} placeholder
        $table_prefix = $wpdb->prefix;
        $sql = str_replace('{PR}', $table_prefix, $sql);

        // Split SQL statements (assuming each statement ends with ; and newline)
        $queries = explode(';', $sql);
        
        foreach ($queries as $query) {
            $query = trim($query);
            if (!empty($query)) {
                // Execute query as-is (table names must be preserved as per specification)
                $wpdb->query($wpdb->prepare($query));
            }
        }
    }

    /**
     * Update TilBuci plugin from ZIP file
     *
     * This function follows the "Running the update" specification:
     * 1. If no ZIP file is provided, download latest.zip from plugin.tilbuci.com.br
     * 2. Verify ZIP contains only "tilbuci-pl" folder in root
     * 3. Extract contents to plugin folder, overwriting existing files
     *
     * @param string|null $uploaded_zip_path Path to uploaded ZIP file (optional)
     * @return array Result with 'success' boolean and 'message' string
     */
    public static function update_tilbuci_plugin($uploaded_zip_path = null) {
        global $wpdb;
        
        // Step 1: Get ZIP file
        $zip_path = null;
        
        if (!empty($uploaded_zip_path) && file_exists($uploaded_zip_path)) {
            $zip_path = $uploaded_zip_path;
        } else {
            // Download latest.zip
            $download_url = 'https://plugin.tilbuci.com.br/versions/latest.zip';
            $response = wp_remote_get($download_url, array(
                'timeout' => 60,
                'sslverify' => true
            ));
            
            if (is_wp_error($response)) {
                return array(
                    'success' => false,
                    'message' => __('Failed to download update: ', 'tilbuci-pl') . $response->get_error_message()
                );
            }
            
            $status_code = wp_remote_retrieve_response_code($response);
            if ($status_code !== 200) {
                return array(
                    'success' => false,
                    'message' => sprintf(__('Download failed with status code: %d', 'tilbuci-pl'), $status_code)
                );
            }
            
            $zip_content = wp_remote_retrieve_body($response);
            
            // Save to temporary file
            $temp_dir = get_temp_dir();
            $zip_path = $temp_dir . 'tilbuci-latest-' . time() . '.zip';
            $result = file_put_contents($zip_path, $zip_content);
            
            if ($result === false) {
                return array(
                    'success' => false,
                    'message' => __('Failed to save downloaded ZIP file', 'tilbuci-pl')
                );
            }
        }
        
        // Step 2: Verify ZIP structure
        if (!class_exists('ZipArchive')) {
            return array(
                'success' => false,
                'message' => __('ZipArchive class not available. PHP zip extension is required.', 'tilbuci-pl')
            );
        }
        
        $zip = new ZipArchive();
        if ($zip->open($zip_path) !== true) {
            return array(
                'success' => false,
                'message' => __('Failed to open ZIP file', 'tilbuci-pl')
            );
        }
        
        // Check that root contains only "tilbuci-pl" folder
        $valid_structure = true;
        $found_tilbuci_pl = false;
        
        for ($i = 0; $i < $zip->numFiles; $i++) {
            $filename = $zip->getNameIndex($i);
            $parts = explode('/', $filename);
            
            // Skip empty entries
            if (empty($parts[0])) {
                continue;
            }
            
            // Check if root entry is "tilbuci-pl" folder
            if ($parts[0] === 'tilbuci-pl') {
                $found_tilbuci_pl = true;
            } else {
                // Found something else in root
                $valid_structure = false;
                break;
            }
        }
        
        if (!$valid_structure || !$found_tilbuci_pl) {
            $zip->close();
            return array(
                'success' => false,
                'message' => __('ZIP file must contain only "tilbuci-pl" folder in root', 'tilbuci-pl')
            );
        }
        
        // Step 3: Extract contents of tilbuci-pl folder to plugin folder
        $plugin_dir = dirname(dirname(__FILE__)); // tilbuci-pl directory
        
        // Create temporary directory for extraction
        $temp_dir = get_temp_dir() . 'tilbuci-extract-' . time() . '/';
        if (!mkdir($temp_dir, 0755, true)) {
            $zip->close();
            return array(
                'success' => false,
                'message' => __('Failed to create temporary directory', 'tilbuci-pl')
            );
        }
        
        // Extract entire ZIP to temporary directory
        if (!$zip->extractTo($temp_dir)) {
            $zip->close();
            self::delete_directory($temp_dir);
            return array(
                'success' => false,
                'message' => __('Failed to extract ZIP file', 'tilbuci-pl')
            );
        }
        
        $zip->close();
        
        // Check if tilbuci-pl folder exists in temp directory
        $source_folder = $temp_dir . 'tilbuci-pl/';
        if (!is_dir($source_folder)) {
            self::delete_directory($temp_dir);
            return array(
                'success' => false,
                'message' => __('ZIP file does not contain tilbuci-pl folder', 'tilbuci-pl')
            );
        }
        
        // Copy all files from source folder to plugin directory, overwriting existing files
        $copy_result = self::copy_directory($source_folder, $plugin_dir);
        
        // Clean up temporary directory
        self::delete_directory($temp_dir);
        
        if (!$copy_result) {
            return array(
                'success' => false,
                'message' => __('Failed to copy files to plugin directory', 'tilbuci-pl')
            );
        }
        
        // Clean up temporary file if we downloaded it
        if (empty($uploaded_zip_path) && file_exists($zip_path)) {
            unlink($zip_path);
        }
        
        // Execute version update checks and SQL update files
        self::check_and_update_version();
        
        return array(
            'success' => true,
            'message' => __('Plugin updated successfully', 'tilbuci-pl')
        );
    }
}
