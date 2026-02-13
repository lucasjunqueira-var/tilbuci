# TilBuci Development Guide

This document provides detailed instructions for setting up a development environment for TilBuci, building from source, and contributing to the project. It expands upon the information found in `models/develop.md` with additional context, links, and explanations.

## Introduction

TilBuci is a free, open-source tool for creating interactive content, built with [Haxe](https://haxe.org/), [OpenFL](https://www.openfl.org/), [FeathersUI](https://feathersui.com/), and PHP. The project compiles to JavaScript for web deployment and can also export to desktop, mobile, PWA, and other runtime formats.

This guide is intended for developers who wish to modify TilBuci's source code, contribute improvements, or create custom builds.

## Development Environment Setup

### 1. Install Haxe

Haxe is the primary programming language used for TilBuci. Download and install the latest stable version from the official website:

- **Download**: [https://haxe.org/download/](https://haxe.org/download/)
- **Documentation**: [https://haxe.org/documentation/](https://haxe.org/documentation/)

After installation, verify that Haxe is available in your terminal:

```bash
haxe --version
```

### 2. Install OpenFL

OpenFL is a framework for cross-platform multimedia development. Install it via Haxelib:

```bash
haxelib install openfl
```

Then install the OpenFL command-line tools:

```bash
haxelib run openfl setup
```

- **OpenFL Website**: [https://www.openfl.org/](https://www.openfl.org/)
- **OpenFL Documentation**: [https://www.openfl.org/learn/documentation/](https://www.openfl.org/learn/documentation/)

### 3. Install Actuate

Actuate is a Haxe tweening library used for animations. Install it with:

```bash
haxelib install actuate
```

- **GitHub Repository**: [https://github.com/jgranick/actuate](https://github.com/jgranick/actuate)

### 4. Install FeathersUI

FeathersUI is a cross-platform UI framework for Haxe and OpenFL. Install it via Haxelib:

```bash
haxelib install feathersui
```

- **FeathersUI Website**: [https://feathersui.com/](https://feathersui.com/)
- **Documentation**: [https://feathersui.com/learn/haxe-openfl/](https://feathersui.com/learn/haxe-openfl/)

### 5. Install Haxe Crypto

The Crypto library provides cryptographic functions. Install it with:

```bash
haxelib install crypto
```

- **Haxelib Page**: [https://lib.haxe.org/p/crypto/](https://lib.haxe.org/p/crypto/)

### 6. Install Haxe hscript

hscript is a scripting library that allows runtime interpretation of Haxe-like expressions. Install it with:

```bash
haxelib install hscript
```

- **GitHub Repository**: [https://github.com/HaxeFoundation/hscript](https://github.com/HaxeFoundation/hscript)

### 7. Install the Moonshine Text Editor Library

TilBuci uses a custom text editor component based on the Moonshine IDE's FeathersUI text editor. Install it via Git:

```bash
haxelib git moonshine-feathersui-text-editor https://github.com/Moonshine-IDE/moonshine-feathersui-text-editor.git
```

- **Blog Post**: [Moonshine IDE Feathers UI Code Text Editor](https://feathersui.com/blog/2021/11/09/moonshine-ide-feathers-ui-code-text-editor/)
- **GitHub Repository**: [https://github.com/Moonshine-IDE/moonshine-feathersui-text-editor](https://github.com/Moonshine-IDE/moonshine-feathersui-text-editor)

### 8. Set Up a Local Web Server

TilBuci is a web-based application, so a local web server is required for development and testing. The server must be configured to serve the `server/public_html` folder.

#### Apache Configuration Example

Create a virtual host that points to the project's `server/public_html` directory. For example, on Apache:

```apache
<VirtualHost *:80>
  DocumentRoot "C:/TilBuci/tilbuci/server/public_html"
  ServerName tilbuci
  <Directory "C:/TilBuci/tilbuci/server/public_html">
    Options Indexes FollowSymLinks Includes ExecCGI
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
```

Then add `tilbuci` to your hosts file (`C:\Windows\System32\drivers\etc\hosts` on Windows, `/etc/hosts` on Linux/macOS):

```
127.0.0.1   tilbuci
```

#### Linux-Specific Notes

On Ubuntu-based systems, you may need to adjust folder permissions for the web server user (typically `www-data`):

```bash
sudo chown -R www-data:www-data /path/to/tilbuci/server/public_html
sudo chmod -R 755 /path/to/tilbuci/server/public_html
```

If you use AppArmor, you may need to adjust its profile to allow Apache/PHP to access the project directories.

#### Install PHP and MariaDB/MySQL

TilBuci's server-side components require PHP and a MySQL-compatible database.

- **PHP**: Install PHP 7.4 or later with extensions `mysqli`, `pdo_mysql`, `gd`, `zip`, and `mbstring`.
- **MariaDB/MySQL**: Install MariaDB or MySQL and create a database named `tilbuci`.

Import the initial database schema:

```bash
mysql -u root -p tilbuci < server/database/tilbuci.sql
```

The default credentials in the example configuration are:
- Database: `tilbuci`
- User: `root`
- Password: (empty)

Adjust these according to your local setup.

## Configuration Files

TilBciu requires three configuration files that are created during installation. The repository includes example files that you can copy and modify.

| File | Example Location | Target Location | Purpose |
|------|------------------|-----------------|---------|
| Server Configuration | `server/app/Config - example.php` | `server/app/Config.php` | Database connection, server settings, and paths. |
| Editor Configuration | `server/public_html/app/editor - example.json` | `server/public_html/app/editor.json` | Editor‑side settings (UI, defaults, etc.). |
| Player Configuration | `server/public_html/app/player - example.json` | `server/public_html/app/player.json` | Player‑side settings (runtime behavior, plugins, etc.). |

**Important**: The example files assume you are accessing TilBuci via `http://tilbuci/` with a database `tilbuci` on `localhost` using user `root` and no password. Update these values to match your environment.

## Build Scripts

The project includes several automation scripts for building, deploying, and packaging. They are available in both `.sh` (Linux/macOS) and `.cmd` (Windows) formats.

### `build-full`

Builds a fresh JavaScript version of the TilBuci editor and player, then opens `http://tilbuci/` in your default browser.

```bash
./build-full.sh        # Linux/macOS
build-full.cmd         # Windows
```

### `deploy-full`

Builds the editor and player JavaScript without launching the browser afterward. Use this when you only need to update the compiled assets.

```bash
./deploy-full.sh
deploy-full.cmd
```

### `deploy-runtime`

Uses the current player code to generate the various exported runtimes: desktop, mobile, PWA, web, and publish services.

```bash
./deploy-runtime.sh
deploy-runtime.cmd
```

### `minimize-js`

Minifies all TilBuci JavaScript files (editor, player, and runtimes) using the Google Closure Compiler. Requires Java and the Closure Compiler JAR.

**Prerequisites**:
- Java (OpenJDK or Oracle JDK) installed and in PATH.
- Download the latest Closure Compiler JAR from [https://github.com/google/closure-compiler](https://github.com/google/closure-compiler) and place it as `third/closure-compiler.jar` in the project root.

```bash
./minimize-js.sh
minimize-js.cmd
```

### `create-installer`

Generates the TilBuci web installer from the current codebase.

```bash
./create-installer.sh
create-installer.cmd
```

## Testing and Deployment

### Running the Development Server

After setting up the web server and configuration files, you can access TilBuci at:

- Editor: `http://tilbuci/editor/`
- Player: `http://tilbuci/`

### Building for Production

1. Run `deploy-full` to compile the latest Haxe source to JavaScript.
2. Optionally run `minimize-js` to minify the JavaScript files for production.
3. The compiled assets will be placed in `server/public_html/app/`.

### Exporting Runtimes

Use `deploy-runtime` to generate platform‑specific packages:

- **Desktop**: Electron‑based packages for Windows, macOS, and Linux.
- **Mobile**: Capacitor projects for iOS and Android.
- **PWA**: Progressive Web App with service worker and manifest.
- **Website**: Static website with SEO‑friendly sitemap.
- **Publish**: Packages optimized for itch.io, Game Jolt, etc.

The output is placed in `server/export/`.

## Additional Resources

- **Official Website**: [https://tilbuci.com.br/](https://tilbuci.com.br/)
- **Online Demo**: [https://try.tilbuci.com.br/](https://try.tilbuci.com.br/)
- **Tutorials & Examples**: [https://tilbuci.com.br/site/tutorials/](https://tilbuci.com.br/site/tutorials/)
- **Scripting Actions Manual**: [https://tilbuci.com.br/files/TilBuci-ScriptingActions.pdf](https://tilbuci.com.br/files/TilBuci-ScriptingActions.pdf)
- **GitHub Repository**: [https://github.com/tilbuci/tilbuci](https://github.com/tilbuci/tilbuci)
- **License**: MPL 2.0 (see `LICENSE` file)

## Contributing

TilBuci is an open‑source project and welcomes contributions. To contribute:

1. Fork the repository on GitHub.
2. Create a feature branch.
3. Make your changes, ensuring they follow the existing code style.
4. Test your changes thoroughly.
5. Submit a pull request with a clear description of the changes.

For questions or discussions, contact the maintainers at [doggo@tilbuci.com.br](mailto:doggo@tilbuci.com.br).

---

*This document was generated from `models/develop.md` with additional details and links. Last updated: February 2026.*