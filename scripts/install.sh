#!/bin/bash

# shellcheck disable=SC2059

# Get the constants
# shellcheck source=/constants.sh
source "$(dirname "${BASH_SOURCE[0]}")/constants.sh"

# Get the install settings
source "${SCRIPTS_DIR}/settings.sh"

echo '' # new line

# Confirm WP_USER_EMAIL is a valid email address before proceeding
if ! [[ "$WP_USER_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  printf "${BRIGHT_RED}ERROR: ${WP_USER_EMAIL}${RESET}${RED} is not a valid email address. Please update the ${BRIGHT_RED}WP_USER_EMAIL${RESET}${RED} setting in ${BRIGHT_RED}scripts/settings.sh${RESET}${RED} with a valid email and rerun the install script.${RESET}\n\n"
  exit 1
fi

# Install CassidyDC Development Toolset 'root' config files
if $INSTALL_CASSIDYDC_DEV_TOOLSET; then
  printf "${BLUE}Installing CassidyDC Development Toolset config files...${RESET}\n"

  # Clone with error handling
  if git clone --depth 1 --filter=blob:none --sparse git@github.com:CassidyDC/development-toolset.git cassidydc-temp-toolset; then
    if (
      cd cassidydc-temp-toolset || exit 1
      git sparse-checkout set root

      # Copy with error handling
      if cp -r root/. ../; then
        printf "${GREEN}Successfully copied toolset files.${RESET}\n\n"
      else
        printf "${RED}ERROR: Failed to copy toolset files.${RESET}\n\n"
        exit 1
      fi
    ); then
      rm -rf cassidydc-temp-toolset

      # Install npm packages for toolset
      printf "${BLUE}Installing CassidyDC Development Toolset NPM packages...${RESET}\n"
      npm install
    else
      rm -rf cassidydc-temp-toolset
      exit 1
    fi
  else
    printf "${BRIGHT_RED}ERROR: Failed to clone development toolset repository.${RESET}\n\n"
    exit 1
  fi
fi

# Install WP Core Files in 'wordpress' directory with roots/wordpress composer package
printf "${BLUE}Adding WordPress core files with roots/wordpress composer package...${RESET}\n"
if [ -f composer.json ]; then
  composer config --no-interaction allow-plugins.roots/wordpress-core-installer true
  composer require --dev roots/wordpress
else
  composer init --author CassidyDC --require-dev roots/wordpress:'*' --no-interaction
  composer config --no-interaction allow-plugins.roots/wordpress-core-installer true
  composer require --dev roots/wordpress
fi
echo '' # new line

# Create index.php file to point WP Core install to wordpress directory
printf "${BLUE}Creating index.php file...${RESET}\n"
if [ -f index.php ]; then
  printf "${BLACK}The index.php file already exists. Skipping creation.${RESET}\n\n"
else
  # Copy/Paste file
  cp ${FILES_DIR}/roots/index.php index.php
  # Print success message
  printf "${GREEN}File created at: ${BOLD}index.php${RESET}\n\n"
fi

# Create wp-cli.yml file to point wp-cli to wordpress core directory
printf "${BLUE}Creating wp-cli.yml file...${RESET}\n"
if [ -f wp-cli.yml ]; then
  printf "${BLACK}The wp-cli.yml file already exists. Skipping creation.${RESET}\n\n"
else
  # Copy/Paste file
  cp "${FILES_DIR}/roots/wp-cli.yml" wp-cli.yml
  # Print success message
  printf "${GREEN}File created at: ${BOLD}wp-cli.yml${RESET}\n\n"
fi

# Set DDEV containers configuration
printf "${BLUE}Setting DDEV configurations...${RESET}\n"
if ! ddev config --project-type=wordpress --project-name="$PROJECT_NAME_SLUG"; then
  echo '' # new line
  printf "${RED}${BOLD}The ddev config setup failed. Check if your project name already exists with ${GREEN}ddev list${RESET}\n\n" >&2
  exit 1
fi

echo '' # new line

# Add WP Config constants and set DDEV post-start hooks for restarts
if $INSTALL_WP_CONFIG_HOOKS; then
  source "${MODULES_DIR}/ddev-hooks-module.sh"

  # Create the log directory if it's set in the settings and doesn't yet exist
  if [ -n "$WP_DEBUG_LOG_VALUE" ] && [ "$WP_DEBUG_LOG_VALUE" != "false" ]; then
    LOG_DIR="$(dirname "$WP_DEBUG_LOG_VALUE" | tr -d "'")"

    if [ -n "$LOG_DIR" ]; then
      printf "${BLUE}Creating $LOG_DIR directory...${RESET}\n"
      if [ -d "$LOG_DIR" ]; then
        printf "${BLACK}The '$LOG_DIR' directory already exists. Skipping creation.${RESET}\n\n"
      else
        mkdir -p "$LOG_DIR"
        # Print success message
        printf "${GREEN}New directory created at: ${BOLD}${LOG_DIR}${RESET}\n\n"
      fi
    else
      printf "${RED}WP_DEBUG_LOG_VALUE is not set. Skipping directory creation.${RESET}\n\n"
    fi
  fi
fi

# Create themes directory
printf "${BLUE}Creating wp-content/themes directory...${RESET}\n"
if [ ! -d wp-content/themes ]; then
  mkdir -p wp-content/themes
  printf "${GREEN}Directory created at: ${BOLD}wp-content/themes${RESET}\n\n"
else
  printf "${BLACK}The wp-content/themes directory already exists. Skipping creation.${RESET}\n\n"
fi

# Create plugins directory
printf "${BLUE}Creating wp-content/plugins directory...${RESET}\n"
if [ ! -d wp-content/plugins ]; then
  mkdir -p wp-content/plugins
  printf "${GREEN}Directory created at: ${BOLD}wp-content/plugins${RESET}\n\n"
else
  printf "${BLACK}The wp-content/plugins directory already exists. Skipping creation.${RESET}\n\n"
fi

# Add Spatie Ray app files for development env.
if $INSTALL_RAY_CONNECTIONS; then
  source "${MODULES_DIR}/ray-app-connections-module.sh"
fi

# Install Git
if $INSTALL_GIT; then
  # Initialize Git
  printf "${BLUE}Initializing Git...${RESET}\n"
  if [ -d '.git' ]; then
    printf "${BLACK}Git is already initialized for this project. Skipping initialization.${RESET}\n\n"
  else
    git init
    # Print success message
    printf "${GREEN}Local Git repository created at: ${BOLD}.git${RESET}\n\n"
  fi
fi

# Build and start the project's Docker containers.
printf "${BLUE}Starting DDEV containers...${RESET}\n"
ddev start "$PROJECT_NAME_SLUG"
echo '' # new line

# Install WP with selected plugins and themes
source "${MODULES_DIR}/wp-install-module.sh"

printf "${MAGENTA}${BOLD}The ddev-local-wordpress-script installation process is all finished! If no errors were present, you may delete the /ddev-local-wordpress-scripts directory.${RESET}\n\n"
