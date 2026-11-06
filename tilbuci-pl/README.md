# TilBuci Plugin for WordPress

Plugin for integrating the TilBuci interactive content creation tool into a WordPress installation.

TilBuci is a free, open source tool to create interactive content. From a visual web interface, you can gather your media, texts, and all content in the form of interactive "movies" that can be exported as websites, embedded via iframes, made available as PWA apps or even as mobile and desktop applications.

The specification followed by this plugin is described in [`models/tilbuci-pl.md`](../models/tilbuci-pl.md).

## Plugin structure

| Path | Description |
|------|-------------|
| `tilbuci-pl.php` | Plugin header, constants, activation/deactivation hooks |
| `includes/class-tilbuci-pl.php` | Dashboard menus, block registration/rendering, backups |
| `includes/class-tilbuci-pl-db.php` | Installation, SQL import, data restore, updates |
| `includes/class-tilbuci-pl-shortcode.php` | Legacy shortcode helper |
| `assets/js/block.js` | Gutenberg block editor UI |
| `admin/css/tilbuci-pl-admin.css` | Dashboard styles |
| `tilbuci/` | The TilBuci software itself (editor + player + PHP backend) |

> **`tilbuci/` is owned externally.** Its contents come from the official TilBuci
> release and are updated by hand. Plugin development must never modify files in
> that folder: the only things the plugin does there are the runtime files listed
> below and the movie folders under `tilbuci/public/movie/`, both mandated by the
> specification.

Runtime files generated when the plugin is activated (never edit them by hand):

- `tilbuci/app/Config.php` – database/site configuration used by the TilBuci PHP backend
- `tilbuci/public/app/editor.json` – editor URLs and language list
- `tilbuci/public/app/player.json` – player URLs, fonts and render defaults

The TilBuci backend runs in "WordPress" mode (`host` = `WordPress`), so it does not open its own
database connection: [`BaseClass.php`](tilbuci/app/BaseClass.php:45) locates the WordPress root and
uses the global `$wpdb` object for every query.

## Local development environment

The plugin is tested against a local WordPress Studio site:

- Site URL: `http://localhost:8884`
- Site files: `C:\Users\choki\Studio\tilbuci-wp`
- Plugin sources: this repository (`c:\TilBuci\tilbuciwp\tilbuci-pl`)

The plugin is published to the site as a **real copy** inside `wp-content/plugins/tilbuci-pl`.
Do not use a junction/symlink here: the TilBuci backend loads WordPress through the relative path
`../../../../../../wp-load.php`, which only resolves when the plugin files are physically inside
`wp-content/plugins`. After changing files in this repository, run:

```bat
tools\sync-to-site.cmd
```

The script mirrors the repository into the site (robocopy `/MIR`) and preserves the runtime data of
the installation: `tilbuci/app/Config.php`, `tilbuci/public/app/editor.json`,
`tilbuci/public/app/player.json` and everything under `tilbuci/public/movie/`.

The test site uses SQLite (WordPress Studio), so the plugin must keep its SQL portable:
no `SHOW CREATE TABLE` parsing, no assumption that `TRUNCATE` is supported, and every script is
executed statement by statement.

### Useful commands

Always run WP-CLI through the Studio CLI, from the site directory:

```bat
cd C:\Users\choki\Studio\tilbuci-wp
studio wp plugin activate tilbuci-pl
studio wp plugin deactivate tilbuci-pl
studio wp eval-file "c:\TilBuci\tilbuciwp\tools\inspect.php"
```

There are also helper scripts for manual verification (not shipped with the plugin):

| Script | Purpose |
|--------|---------|
| `tools/inspect.php` | Lists the `tilbuci` tables, row counts, `dbVersion` and generated files |
| `tools/ws-test.php` | Signs and calls the TilBuci webservices (`newmovie` also creates a movie) |
| `tools/post-test.php` | Creates/updates a published post containing the TilBuci block |
| `tools/rest-test.php` | Calls the plugin REST route `/tilbuci-pl/v1/movies` as an admin |
| `tools/block-test.php` | Shows the registered block (title, category, icon, script URL) |
| `tools/block-js-check.mjs` | Runs `block.js` in Node with a `window.wp` stub to prove it registers |
| `tools/url-test.php` | Prints `WP_PLUGIN_DIR`/`WP_PLUGIN_URL` and the generated plugin URL |
| `tools/schema-test.php` | Lists the columns of the main `tilbuci_*` tables |
| `tools/update-schema.php` | Applies the release update scripts and tests an `instances` INSERT |
| `tools/backup-test.php` | Runs the movie/database backup routine and lists the results |
| `tools/restore-test.php` | Clears the movies table and runs the activation restore routine |
| `tools/restore-movie.php` | Restores a single movie from `uploads/tilbuci` (files + row) |
| `tools/admin-cookie.php` | Prints `wordpress_logged_in_*` / `wordpress_*` cookies for `curl` |
| `tools/zip-check.php` | Validates a plugin ZIP against the updater rules |
| `tools/update-zip-test.php` | Runs the real update routine with a plugin ZIP |

### Release packaging

The plugin ZIP must contain a single `tilbuci-pl/` folder in its root, because
[`update_tilbuci_plugin()`](includes/class-tilbuci-pl-db.php:943) rejects any other layout. Build it from
the repository root (Windows `bsdtar` writes forward slashes and keeps empty folders):

```bat
tar -a -c -f dist\tilbuci-pl.zip -C . tilbuci-pl
studio wp eval-file "c:\TilBuci\tilbuciwp\tools\zip-check.php" "c:\TilBuci\tilbuciwp\dist\tilbuci-pl.zip"
studio wp eval-file "c:\TilBuci\tilbuciwp\tools\update-zip-test.php" "c:\TilBuci\tilbuciwp\dist\tilbuci-pl.zip"
```

The build must not include the runtime files (`tilbuci/app/Config.php`,
`tilbuci/public/app/editor.json`, `tilbuci/public/app/player.json`) nor the movie folders under
`tilbuci/public/movie/`; `tools/zip-check.php` reports them as errors if they are present.

### Manual checks in the browser

- Dashboard: `/wp-admin/admin.php?page=tilbuci-pl` (editor iframe), `-help`, `-backup`, `-version`
- Front-end: the post created by `tools/post-test.php`
- The TilBuci backend answers at
  `/wp-content/plugins/tilbuci-pl/tilbuci/public/ws/index.php` (POST with `a`, `r`, `u`, `s`)

## Troubleshooting

- **The "TilBuci Movie" block is missing from the editor** – the block is registered by
  `assets/js/block.js`; if that script is not served as JavaScript the registration never happens.
  Load `/wp-admin/post-new.php` and check the `src` of the `tilbuci-block-js` tag: it must be
  `.../wp-content/plugins/tilbuci-pl/assets/js/block.js`. `tools/block-test.php` and
  `tools/block-js-check.mjs` confirm the server and client registration.
- **Plugin URL with an absolute path (`.../plugins/C:/...`)** – `plugin_dir_url()` compares the real
  path of the folder with `WP_PLUGIN_DIR`; that breaks when the folder is a link/junction or when a
  long running PHP process keeps an old `realpath` cached. The plugin builds its URL from
  `WP_PLUGIN_URL` plus the folder name, but after relinking the folder restart the site
  (`studio stop && studio start --skip-browser`).
- **Editor iframe shows a blank page** – check that `Config.php`, `editor.json` and `player.json`
  exist inside `tilbuci/`; they are recreated when the plugin is activated.
- **"Access denied", "database connection" errors or `open_basedir` warnings from the TilBuci
  backend** – the backend loads WordPress with the relative path
  `../../../../../../wp-load.php`, so the plugin must be physically inside
  `wp-content/plugins/tilbuci-pl` (no junction/symlink). Run `tools\sync-to-site.cmd`.
- **PHP warnings/HTML before the webservice JSON** – a query from the TilBuci backend failed. On
  SQLite the emulation layer prints a warning and `Webservice.php` then cannot send its headers.
  The usual cause is a missing column: `tilbuci/tables.sql` is the **base** structure and the
  columns/tables added later live in `tilbuci/update/*.sql` (e.g. `in_alt` comes from `24.sql`).
  Activation applies all update scripts, and `tools/update-schema.php` can be run to repair an
  existing installation; `tools/schema-test.php` lists the current columns.
- **PHP fatal error on activation** – the `tilbuci` SQL scripts are executed statement by statement;
  inspect `wp-content/debug.log` after enabling `studio config set --debug-log`.
