#!/bin/bash

# --- DIRECTORIES --- #
export ROOT_DIR='ddev-wp-local-setup'
export FILES_DIR="${ROOT_DIR}/files"
export SCRIPTS_DIR="${ROOT_DIR}/scripts"

# --- PROJECT VARIABLES --- #
## Get the host machine project path.
PROJECT_DIR=$(pwd)
export PROJECT_DIR
## Get the project name from the project directory, minus any leading non-alphanumeric characters and trailing `.ddev.site`.
PROJECT_NAME=$(basename "$PROJECT_DIR" | sed 's:^[^a-zA-Z0-9]*::;s:\.ddev\.site$::')
export PROJECT_NAME
## Replace any hyphens in $PROJECT_NAME with spaces and capitalize the first letter of each word.
PROJECT_TITLE=$(echo "$PROJECT_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1')
export PROJECT_TITLE
## Replace any spaces in $PROJECT_NAME with hyphens and convert all letters to lowercase.
PROJECT_NAME_SLUG=$(echo "$PROJECT_NAME" | sed 's/[[:space:]]/-/g' | tr '[:upper:]' '[:lower:]')
export PROJECT_NAME_SLUG
## Set the project root URL
export PROJECT_URL="https://${PROJECT_NAME}.ddev.site"

# --- TERMINAL STYLES --- #
# Set terminal base colors for script output
export BLACK='\033[0;30m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[0;37m'
# Set terminal bright colors for script output
export BRIGHT_BLACK='\033[1;30m'
export BRIGHT_RED='\033[1;31m'
export BRIGHT_GREEN='\033[1;32m'
export BRIGHT_YELLOW='\033[1;33m'
export BRIGHT_BLUE='\033[1;34m'
export BRIGHT_MAGENTA='\033[1;35m'
export BRIGHT_CYAN='\033[1;36m'
export BRIGHT_WHITE='\033[1;37m'
# Set terminal formatting for script output
export ITALIC='\033[3m'
export BOLD='\033[1m'
export RESET='\033[0m'

# --- THEME SLUGS --- #
## Set the default official WordPress theme slug
export DEFAULT_WP_THEME_SLUG='twentytwentyfive'
## Set the CassidyDC WP Starter Block Theme slug
export CASSIDYDC_STARTER_THEME_SLUG='cassidydc-block-theme'

