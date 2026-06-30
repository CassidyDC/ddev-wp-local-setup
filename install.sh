#!/bin/bash

# shellcheck disable=SC2059

# Get the constants
source "$(dirname "${BASH_SOURCE[0]}")/scripts/constants.sh"

# Get the install configuration settings
source "${ROOT_DIR}/config.sh"

echo '' # new line

# Confirm WP_USER_EMAIL is a valid email address before proceeding
if ! [[ "$WP_USER_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  printf "${BRIGHT_RED}ERROR: ${WP_USER_EMAIL}${RESET}${RED} is not a valid email address. Please update the ${BRIGHT_RED}WP_USER_EMAIL${RESET}${RED} setting in ${BRIGHT_RED}config.sh${RESET}${RED} with a valid email and rerun the install script.${RESET}\n\n"
  exit 1
fi

# Create root composer.json file if it doesn't exist, and run composer install to add roots/wordpress composer package
printf "${BLUE}Creating composer.json file and running composer install to add roots/wordpress package...${RESET}\n"
if [ ! -f composer.json ]; then
  cp "${FILES_DIR}/root/composer.json" composer.json
  composer install
else
  printf "${BLACK}The composer.json file already exists. Skipping creation and adding roots/wordpress composer package.${RESET}\n\n"
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
  cp "${FILES_DIR}/root/index.php" index.php
  # Print success message
  printf "${GREEN}File created at: ${BOLD}index.php${RESET}\n\n"
fi

# Create wp-cli.yml file to point wp-cli to wordpress core directory
printf "${BLUE}Creating wp-cli.yml file...${RESET}\n"
if [ -f wp-cli.yml ]; then
  printf "${BLACK}The wp-cli.yml file already exists. Skipping creation.${RESET}\n\n"
else
  # Copy/Paste file
  cp "${FILES_DIR}/root/wp-cli.yml" wp-cli.yml
  # Print success message
  printf "${GREEN}File created at: ${BOLD}wp-cli.yml${RESET}\n\n"
fi

# Create wp-content directory
printf "${BLUE}Creating wp-content directory...${RESET}\n"
if [ ! -d wp-content ]; then
  mkdir -p wp-content
  printf "${GREEN}Directory created at: ${BOLD}wp-content${RESET}\n\n"
else
  printf "${BLACK}The wp-content directory already exists. Skipping creation.${RESET}\n\n"
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

# Install CassidyDC Toolset's 'wp-content' config files
if $INSTALL_WP_DEV_TOOLSET; then
  printf "${BLUE}Installing CassidyDC Toolset's \"wp-content\" config files...${RESET}\n"

  # Clone with error handling
  if git clone --depth 1 --filter=blob:none --sparse git@github.com:CassidyDC/wp-dev-toolset.git wp-dev-toolset-temp; then
    if (
      cd wp-dev-toolset-temp || exit 1
      git sparse-checkout set files/wp-content

      # Copy with error handling
      if cp -r files/wp-content/. ../wp-content; then
        printf "${GREEN}Successfully copied toolset files.${RESET}\n\n"
      else
        printf "${RED}ERROR: Failed to copy toolset files.${RESET}\n\n"
        exit 1
      fi
    ); then
      rm -rf wp-dev-toolset-temp

      # Install npm packages for toolset
      printf "${BLUE}Installing CassidyDC Toolset's NPM packages in wp-content directory...${RESET}\n"
      if (
        cd wp-content || exit 1
        npm install
      ); then
        echo '' # new line
      else
        printf "${BRIGHT_RED}ERROR: Failed to install CassidyDC Toolset's NPM packages in wp-content directory.${RESET}\n\n"
        exit 1
      fi
    else
      rm -rf wp-dev-toolset-temp
      exit 1
    fi
  else
    printf "${BRIGHT_RED}ERROR: Failed to clone CassidyDC Toolset repository.${RESET}\n\n"
    exit 1
  fi
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
  # shellcheck source=scripts/ddev-hooks.sh
  source "${SCRIPTS_DIR}/ddev-hooks.sh"

  # Create the log directory if it's set in the settings and doesn't yet exist
  if [ -n "$WP_DEBUG_LOG_VALUE" ] && [ "$WP_DEBUG_LOG_VALUE" != "false" ]; then

    # Extract the single quoted directory path from the WP_DEBUG_LOG_VALUE constant
    WP_DEBUG_LOG_VALUE_CLEAN="${WP_DEBUG_LOG_VALUE#*\'}"
    WP_DEBUG_LOG_VALUE_CLEAN="${WP_DEBUG_LOG_VALUE_CLEAN%%\'*}"
    WP_DEBUG_LOG_VALUE_CLEAN="${WP_DEBUG_LOG_VALUE_CLEAN#/}"
    LOG_DIR="$(dirname "$WP_DEBUG_LOG_VALUE_CLEAN" | tr -d "'")"

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

# Add Spatie Ray app files for development env.
if $INSTALL_RAY_CONNECTIONS; then
# shellcheck source=scripts/ray-app-connections.sh
  source "${SCRIPTS_DIR}/ray-app-connections.sh"
fi

# Install Git
if $INSTALL_GIT; then
  # Initialize Git
  printf "${BLUE}Initializing Git...${RESET}\n"
  if [ -d 'wp-content/.git' ]; then
    printf "${BLACK}Git is already initialized for this project. Skipping initialization.${RESET}\n\n"
  else
    if (
      cd wp-content || exit 1
      git init
    ); then
      # Print success message
      printf "${GREEN}Local Git repository created at: ${BOLD}/wp-content/.git${RESET}\n\n"
      echo '' # new line
    else
      printf "${BRIGHT_RED}ERROR: Failed to initialize Git in wp-content directory.${RESET}\n\n"
      exit 1
    fi
  fi
fi

# Build and start the project's Docker containers.
printf "${BLUE}Starting DDEV containers...${RESET}\n"
ddev start "$PROJECT_NAME_SLUG"
echo '' # new line

# Install WP with selected plugins and themes
# shellcheck source=scripts/wp-install.sh
source "${SCRIPTS_DIR}/wp-install.sh"

printf "${MAGENTA}${BOLD}The ddev-wp-local-setup installation process is all finished! If no errors were present, you may delete the /ddev-wp-local-setup directory.${RESET}\n\n"
