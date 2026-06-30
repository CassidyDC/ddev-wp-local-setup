#!/bin/bash

# CONFIGURATION SETTINGS

## Set WP Admin login details for user 1
export WP_USER_NAME='admin'
export WP_USER_PASS='password'
export WP_USER_EMAIL='admin@example.com'

## Boolean Settings
export INSTALL_WP_DEV_TOOLSET=true # Installs the https://github.com/CassidyDC/wp-dev-toolset `wp-content` files
export INSTALL_CASSIDYDC_BLOCK_THEME=true # Installs https://github.com/CassidyDC/cassidydc-block-theme

export INSTALL_GIT=true # Install local Git repo and .gitignore file for the project in the `wp-content` directory
export INSTALL_RAY_CONNECTIONS=true # Install Spatie Ray app connection files to work with Docker containers

export INSTALL_WP_CLEAN=true # Install clean version of WP (individual settings can be set below)
export INSTALL_WP_CONFIG_HOOKS=true # Install ddev post-start hooks for wp-config (individual settings can be set below)
export INSTALL_WP_DEFAULT_THEME=true # Install official default WordPress theme

export INSTALL_WP_PLUGIN_AIOM=false # All-in-One WP Migration plugin
export INSTALL_WP_PLUGIN_QUERY_MONITOR=false # Query Monitor plugin for developers

## Uncomment and update the line below if you set `INSTALL_WP_PLUGIN_AIOMUE_LOCAL` to true:
export INSTALL_WP_PLUGIN_AIOMUE_LOCAL=false # All-in-One WP Migration Unlimited Extension plugin from local machine
# export LOCAL_AIOMUE_PATH='/Users/Jacob/Projects/Assets/Packages/WordPress/Plugins/All In One Migration Unlimited Extension/all-in-one-wp-migration-unlimited-extension_2.65.zip'

## Uncomment and update the following line to set a custom site title (defaults to the project name taken from the project directory):
# export WP_SITE_TITLE='Example Title'

## Uncomment and update the following line to set a DB search and replace post-import-db hook:
# export DB_URL_REPLACE_VALUE="https://example.com https://example.ddev.site"

## WP Clean Settings
if $INSTALL_WP_CLEAN; then
  ### Hide default WP Admin dashboard widgets for default user 1
  export HIDE_DASHBOARD_WIDGETS=true

  ### Remove default Hello World post
  export REMOVE_WP_HELLO_POST=true

  ### Remove default Sample Page
  export REMOVE_WP_SAMPLE_PAGE=true

  ### Remove default Privacy Policy draft page
  export REMOVE_WP_PRIVACY_DRAFT=true

  ### Update the WP permalinks to use the post name
  export SET_POSTNAME_PERMALINKS=true

  ### Create a new page titled 'Homepage' and set it to be the site's front page
  export CREATE_HOMEPAGE=true
fi

## WP-Config Settings
if $INSTALL_WP_CONFIG_HOOKS; then
  ### Set the 'wp-content' paths
  export WP_CONTENT_DIR_VALUE="__DIR__ . '/wp-content'"
  export WP_CONTENT_URL_VALUE="'${PROJECT_URL}/wp-content'"

  ### Set WP debug settings
  export WP_DEBUG_VALUE=true
  export WP_DEBUG_DISPLAY_VALUE=false
  export WP_DEBUG_LOG_VALUE="__DIR__ . '/wp-content/logs/wp-errors.log'"
  export SCRIPT_DEBUG_VALUE=true

  ### Set WP environment settings
  export WP_DEVELOPMENT_MODE_VALUE="'theme'"
  export WP_ENVIRONMENT_TYPE_VALUE="'local'"

  ### Uncomment the following line to set a custom table prefix for the WordPress database:
  # export CUSTOM_TABLE_PREFIX_VALUE="'wp_example_'"
fi
