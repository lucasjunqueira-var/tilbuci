# TilBuci WP Plugin

WordPress plugin for integrating TilBuci interactive content creation tool.

## Description

TilBuci is an interactive content creation tool that includes an editor and a player that work in browsers using Javascript code. This plugin allows the TilBuci editor and player to be integrated into a standard WordPress installation.

## Features

- Embed TilBuci editor and player in WordPress posts/pages via shortcode
- Automatic database setup on activation (creates required tables using `tables.sql` and `data.sql`)
- Config.php automatic configuration with WordPress database settings
- Admin settings page for configuration
- Support for multiple TilBuci projects

## Installation

1. Upload the `tilbuci-wp` folder to the `/wp-content/plugins/` directory
2. Activate the plugin through the 'Plugins' menu in WordPress
3. The plugin will automatically:
   - Create the necessary database tables
   - Configure the TilBuci Config.php file with your WordPress database settings
4. Use the `[tilbuci]` shortcode in your posts/pages

## Database Setup

On activation, the plugin executes:
1. `tables.sql` - Creates all required database tables
2. Checks if `dbVersion` record exists in `config` table
3. If not found, executes `data.sql` to populate initial data

## Configuration

The plugin automatically configures the following settings in `tilbuci/app/Config.php`:

- `databaseServ` → WordPress `DB_HOST`
- `databaseUser` → WordPress `DB_USER`
- `databasePass` → Base64 encoded `DB_PASSWORD` (if not empty)
- `path` → `siteurl` + `/wp-content/plugins/tilbuci-wp/tilbuci/public`

## Usage

### Shortcode

Basic usage:
```
[tilbuci project="my-project"]
```

Advanced attributes:
```
[tilbuci project="my-project" width="800" height="600" mode="player"]
```

### PHP Function

You can also use the PHP function in your templates:
```php
<?php echo do_shortcode('[tilbuci project="my-project"]'); ?>
```

## Requirements

- WordPress 5.0 or higher
- PHP 7.4 or higher
- MySQL 5.6 or higher / MariaDB 10.0 or higher

## License

This plugin is licensed under the Mozilla Public License 2.0 (MPL-2.0).

## Changelog

### 1.0.0
- Initial release
- Complete integration with TilBuci
- Automatic database setup and configuration
- Shortcode support

## Support

For support, please open an issue on the GitHub repository.
