#!/bin/bash

# --- DIRECTORIES --- #
ROOT_DIR='ddev-local-wordpress-script'
FILES_DIR="${ROOT_DIR}/files"
MODULES_DIR="${ROOT_DIR}/modules"
SCRIPTS_DIR="${ROOT_DIR}/scripts"

# --- PROJECT VARIABLES --- #
## Get the host machine project path.
PROJECT_DIR=$(pwd)
## Get the project name from the project directory, minus any leading non-alphanumeric characters and trailing `.ddev.site`.
PROJECT_NAME=$(basename "$PROJECT_DIR" | sed 's:^[^a-zA-Z0-9]*::;s:\.ddev\.site$::')
## Replace any hyphens in $PROJECT_NAME with spaces and capitalize the first letter of each word.
PROJECT_TITLE=$(echo "$PROJECT_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1')
## Replace any spaces in $PROJECT_NAME with hyphens and convert all letters to lowercase.
PROJECT_NAME_SLUG=$(echo "$PROJECT_NAME" | sed 's/[[:space:]]/-/g' | tr '[:upper:]' '[:lower:]')
## Set the project root URL
PROJECT_URL="https://${PROJECT_NAME}.ddev.site"

# --- TERMINAL STYLES --- #
# Set terminal base colors for script output
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
# Set terminal bright colors for script output
BRIGHT_BLACK='\033[1;30m'
BRIGHT_RED='\033[1;31m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
BRIGHT_BLUE='\033[1;34m'
BRIGHT_MAGENTA='\033[1;35m'
BRIGHT_CYAN='\033[1;36m'
BRIGHT_WHITE='\033[1;37m'
# Set terminal formatting for script output
ITALIC='\033[3m'
BOLD='\033[1m'
RESET='\033[0m'

# --- THEME SLUGS --- #
## Set the default official WordPress theme slug
DEFAULT_WP_THEME_SLUG='twentytwentyfive'
## Set the CassidyDC WP Starter Block Theme slug
CASSIDYDC_STARTER_THEME_SLUG='cassidydc-wp-starter-block-theme'

