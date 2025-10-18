#!/bin/bash

# SETTINGS

## Set WP Admin login details for user 1
WP_USER_NAME='admin'
WP_USER_PASS='password'
WP_USER_EMAIL='admin@example.com'

## Boolean Settings
INSTALL_CASSIDYDC_DEV_TOOLSET=true # Installs https://github.com/CassidyDC/development-toolset `root` files
INSTALL_CASSIDYDC_STARTER_THEME=false # Install CassidyDC's WP Starter Block Theme
INSTALL_GIT=true # Install local Git repo and .gitignore file for the project
INSTALL_RAY_CONNECTIONS=true # Install Spatie Ray app connection files to work with Docker containers
INSTALL_WP_CLEAN=true # Install clean version of WP (individual settings can be set below)
INSTALL_WP_CONFIG_HOOKS=true # Install ddev post-start hooks for wp-config (individual settings can be set below)
INSTALL_WP_DEFAULT_THEME=true # Install official default WordPress theme
INSTALL_WP_PLUGIN_AIOM=false # All-in-One WP Migration plugin
INSTALL_WP_PLUGIN_AIOMUE_LOCAL=false # All-in-One WP Migration Unlimited Extension plugin from local machine
INSTALL_WP_PLUGIN_QUERY_MONITOR=false # Query Monitor plugin for developers

## Uncomment and update the following line to set a custom site title (defaults to the project name taken from the project directory):
# WP_SITE_TITLE='Example Title'

## Uncomment and update the following line to set a DB search and replace post-import-db hook:
# DB_URL_REPLACE_VALUE="https://example.com https://example.ddev.site"

## Uncomment and update the following line if you set `INSTALL_WP_PLUGIN_AIOMUE_LOCAL` to true:
# LOCAL_AIOMUE_PATH='/Users/Jacob/Projects/Assets/Packages/WordPress/Plugins/All In One Migration Unlimited Extension/all-in-one-wp-migration-unlimited-extension_2.65.zip'

## WP Clean Settings
if $INSTALL_WP_CLEAN; then
  ### Hide default WP Admin dashboard widgets for default user 1
  HIDE_DASHBOARD_WIDGETS=true

  ### Remove default Hello World post
  REMOVE_WP_HELLO_POST=true

  ### Remove default Sample Page
  REMOVE_WP_SAMPLE_PAGE=true

  ### Remove default Privacy Policy draft page
  REMOVE_WP_PRIVACY_DRAFT=true

  ### Update the WP permalinks to use the post name
  SET_POSTNAME_PERMALINKS=true

  ### Create a new page titled 'Homepage' and set it to be the site's front page
  CREATE_HOMEPAGE=true
fi

## WP-Config Settings
if $INSTALL_WP_CONFIG_HOOKS; then
  ### Set the 'wp-content' paths
  WP_CONTENT_DIR_VALUE="__DIR__ . '/wp-content'"
  WP_CONTENT_URL_VALUE="'${PROJECT_URL}/wp-content'"

  ### Set WP debug settings
  WP_DEBUG_VALUE=true
  WP_DEBUG_DISPLAY_VALUE=false
  WP_DEBUG_LOG_VALUE="'logs/wp-errors.log'"
  SCRIPT_DEBUG_VALUE=true

  ### Set WP environment settings
  WP_DEVELOPMENT_MODE_VALUE="'theme'"
  WP_ENVIRONMENT_TYPE_VALUE="'local'"

  ### Uncomment the following line to set a custom table prefix for the WordPress database:
  # CUSTOM_TABLE_PREFIX_VALUE="'wp_example_'"
fi
