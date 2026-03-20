# DDEV WordPress Setup Script

This installation script automatically sets up a development Docker server with DDEV and installs a WordPress site with clean defaults on that server.

> [!NOTE]
> The following software must be installed for the `ddev-wp-local-setup` package to work:
>
> 1. [DDEV](https://ddev.com/) - Install with homebrew: `brew install ddev/ddev/ddev`.
> 2. [Orbstack](https://orbstack.dev/) (or another Docker provider) - Install with homebrew: `brew install orbstack docker`.
> 3. [NPM](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
> 4. [Composer](https://getcomposer.org/download/)

## Quick Start

1. Clone this [repo](https://github.com/cassidydc/ddev-wp-local-setup) to your (preferably empty) project's root directory with the command: **`git clone git@github.com:cassidydc/ddev-wp-local-setup.git`**
2. Customize the script's configuration settings at: _ddev-wp-local-setup/config.sh_
3. Run the installation script in your project's root directory with the command: **`ddev-wp-local-setup/install.sh`**
4. Delete the _ddev-wp-local-setup_ directory after successfully running the installation script

## Features

> [!NOTE]
> The optional features can be turned on/off in the `config.sh` file.

This script automatically sets up the following:

-   Configures and starts the [DDEV](https://ddev.com/) Docker containers with a WordPress development server.
-   Installs a clean WordPress site with the default pages, posts, comments, plugins, themes, welcome panel and dashboard widgets removed (with the exception of the latest official default theme as a fallback).
-   (Optional) Downloads and installs the [CassidyDC Development Toolset](https://github.com/CassidyDC/development-toolset).
-   (Optional) Downloads, installs, and activates the [CassidyDC WP Starter Block Theme](https://github.com/CassidyDC/cassidydc-wp-starter-block-theme).
-   (Optional) Installs the [All-in-One WP Migration plugin](https://wordpress.org/plugins/all-in-one-wp-migration/).
-   (Optional) Installs the [All-in-One WP Migration Unlimited Extension plugin](https://servmask.com/products/unlimited-extension).
    -   _The setup for this plugin is set to `false` by default since it's a paid plugin and is installed from your local machine. If you have this plugin, you can turn the installation on in the `config.sh` file by changing `INSTALL_WP_PLUGIN_AIOMUE_LOCAL` to `true` and updating the path to your zip file._
-   (Optional) Installs the [Query Monitor plugin](https://wordpress.org/plugins/query-monitor/).
-   (Optional) Installs the files needed to connect the DDEV Docker containers with the [Spatie Ray](https://myray.app/) desktop app (used for simple debugging when Xdebug is overkill).
-   (Optional) Initializes a local project Git repo in the `wp-content` directory

## Found an Issue?

If you come across any issues, please report them in the [GitHub Repo](https://github.com/cassidydc/ddev-wp-local-setup/issues).
