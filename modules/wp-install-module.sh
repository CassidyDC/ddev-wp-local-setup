#!/bin/bash

# shellcheck disable=SC2059

# Install WordPress
printf "${BLUE}Installing WordPress...${RESET}\n"
ddev wp core install --url="$DDEV_PRIMARY_URL" --title="${WP_SITE_TITLE:-$PROJECT_TITLE}" --admin_user="$WP_USER_NAME" --admin_password="$WP_USER_PASS" --admin_email="$WP_USER_EMAIL"
echo '' # new line

if $INSTALL_WP_CLEAN; then
  # Hide default WordPress dashboard widgets
  if $HIDE_DASHBOARD_WIDGETS; then
    printf "${BLUE}Hiding default WordPress dashboard widgets...${RESET}\n"
    ddev wp eval 'update_user_meta(
        1,
        "metaboxhidden_dashboard",
        array(
            "dashboard_right_now",
            "dashboard_activity",
            "dashboard_site_health",
            "dashboard_quick_press",
            "dashboard_primary"
        )
    );
    '
    # Hide the welcome panel
    ddev wp user meta update 1 show_welcome_panel 0
    echo '' # new line
  fi

  # Remove default Hello World post
  if $REMOVE_WP_HELLO_POST; then
    printf "${BLUE}Deleting WordPress' default 'Hello, World' post...${RESET}\n"
    if ddev wp post exists 1 > /dev/null 2>&1; then
      ddev wp post delete 1 --force
      echo '' # new line
    else
      printf "${BLACK}Post with ID 1 does not exist. Skipping deletion.${RESET}\n\n"
    fi
  fi

  # Remove default Sample Page
  if $REMOVE_WP_SAMPLE_PAGE; then
    printf "${BLUE}Deleting WordPress' default 'Sample Page'...${RESET}\n"
    if ddev wp post exists 2 > /dev/null 2>&1; then
      ddev wp post delete 2 --force
      echo '' # new line
    else
      printf "${BLACK}Post with ID 2 does not exist. Skipping deletion.${RESET}\n\n"
    fi
  fi

  # Remove default Privacy Policy draft page
  if $REMOVE_WP_PRIVACY_DRAFT; then
    printf "${BLUE}Deleting WordPress' default 'Privacy Policy'...${RESET}\n"
    if ddev wp post exists 3 > /dev/null 2>&1; then
      ddev wp post delete 3 --force
      echo '' # new line
    else
      printf "${BLACK}Post with ID 3 does not exist. Skipping deletion.${RESET}\n\n"
    fi
  fi

  # Update the WP permalinks to use the post name
  if $SET_POSTNAME_PERMALINKS; then
    printf "${BLUE}Setting WP permalinks to use '%%postname%%'...${RESET}\n"

    if [[ $(ddev wp option get permalink_structure) == '/%postname%' ]]; then
      printf "${BLACK}The permalink structure is already using '%%postname%%'. Skipping restructure.${RESET}\n\n"
    else
      ddev wp rewrite structure '/%postname%'
      echo '' # new line
    fi
  fi

  # Create a new page titled 'Homepage' and set it to be the site's front page
  if $CREATE_HOMEPAGE; then
    printf "${BLUE}Creating a new page titled 'Homepage' and setting it to be the site's front page...${RESET}\n"

    if [[ $(ddev wp option get show_on_front) == 'page' ]]; then
      printf "${BLACK}Homepage already exists. Skipping creation.${RESET}\n\n"
    else
      HOMEPAGE_ID=$(ddev wp post create --post_type=page --post_title='Homepage' --post_author=1 --post_status=publish --post_content='<!-- wp:paragraph --><p>This is the homepage.</p><!-- /wp:paragraph -->' --porcelain)
      ddev wp option update show_on_front 'page'
      ddev wp option update page_on_front "$HOMEPAGE_ID"
      echo '' # new line
    fi
  fi
fi

# Install default theme
if $INSTALL_WP_DEFAULT_THEME; then
  printf "${BLUE}Installing default ${DEFAULT_WP_THEME_SLUG} theme...${RESET}\n"

  if ddev wp theme is-installed "${DEFAULT_WP_THEME_SLUG}" > /dev/null 2>&1; then
    DEFAULT_THEME_NAME=$(ddev wp theme get "${DEFAULT_WP_THEME_SLUG}" --field=name)
    printf "${BLACK}${DEFAULT_THEME_NAME} is already installed. Skipping installation.${RESET}\n\n"
  else
    ddev wp theme install "${DEFAULT_WP_THEME_SLUG}"
    echo '' # new line
  fi
fi

# Install and activate CassidyDC WP Starter Block Theme
if $INSTALL_CASSIDYDC_STARTER_THEME; then
  if ddev wp theme is-installed "${CASSIDYDC_STARTER_THEME_SLUG}" > /dev/null 2>&1; then
    CUSTOM_THEME_NAME=$(ddev wp theme get "${CASSIDYDC_STARTER_THEME_SLUG}" --field=name)
    printf "${BLUE}Installing ${CUSTOM_THEME_NAME}...${RESET}\n"
    printf "${BLACK}${CUSTOM_THEME_NAME} is already installed. Skipping installation.${RESET}\n\n"
  else
    printf "${BLUE}Creating ${CASSIDYDC_STARTER_THEME_SLUG} directory...${RESET}\n"
    git clone git@github.com:CassidyDC/cassidydc-wp-starter-block-theme.git wp-content/themes/"${CASSIDYDC_STARTER_THEME_SLUG}"
    CUSTOM_THEME_NAME=$(ddev wp theme get "${CASSIDYDC_STARTER_THEME_SLUG}" --field=name)
    printf "${BLUE}Installing ${CUSTOM_THEME_NAME}...${RESET}\n"
    ddev wp theme activate "${CASSIDYDC_STARTER_THEME_SLUG}"
    echo '' # new line

    # Remove remote Git connection to CassidyDC WP Starter Block Theme repo.
    printf "${BLUE}Removing cloned remote Git for ${CUSTOM_THEME_NAME}...${RESET}\n"
    git -C wp-content/themes/"${CASSIDYDC_STARTER_THEME_SLUG}" remote remove origin
    printf "${GREEN}Removed cloned remote Git connection for ${CUSTOM_THEME_NAME}.${RESET}\n\n"
  fi
fi

# Install All-In-One Migration plugin
if $INSTALL_WP_PLUGIN_AIOM; then
  printf "${BLUE}Installing All-In-One Migration plugin...${RESET}\n"
  PLUGIN_SLUG_AIOM='all-in-one-wp-migration'

  if ddev wp plugin is-installed ${PLUGIN_SLUG_AIOM} > /dev/null 2>&1; then
    PLUGIN_NAME_AIOM=$(ddev wp plugin get ${PLUGIN_SLUG_AIOM} --field=title)
    printf "${BLACK}${PLUGIN_NAME_AIOM} is already installed. Skipping installation.${RESET}\n\n"
  else
    ddev wp plugin install $PLUGIN_SLUG_AIOM --activate
    echo '' # new line
  fi
fi

# Copy and install All-In-One Migration Unlimited Extension plugin from host machine.
if $INSTALL_WP_PLUGIN_AIOMUE_LOCAL; then
  printf "${BLUE}Installing All-In-One Migration Unlimited Extension plugin from local source...${RESET}\n"
  PLUGIN_SLUG_AIOMUE='all-in-one-wp-migration-unlimited-extension'

  if ddev wp plugin is-installed ${PLUGIN_SLUG_AIOMUE} > /dev/null 2>&1; then
    PLUGIN_NAME_AIOMUE=$(ddev wp plugin get ${PLUGIN_SLUG_AIOMUE} --field=title)
    printf "${BLACK}${PLUGIN_NAME_AIOMUE} is already installed. Skipping installation.${RESET}\n\n"
  else
    unzip "$LOCAL_AIOMUE_PATH" -x "__MACOSX/*" -d ./wp-content/plugins
    printf "${BLUE}Activating All-In-One Migration Unlimited Extension plugin...${RESET}\n"
    ddev wp plugin activate $PLUGIN_SLUG_AIOMUE
    echo '' # new line
  fi
fi

# Install Query Monitor plugin
if $INSTALL_WP_PLUGIN_QUERY_MONITOR; then
  printf "${BLUE}Installing Query Monitor plugin...${RESET}\n"
  PLUGIN_SLUG_QM='query-monitor'

  if ddev wp plugin is-installed ${PLUGIN_SLUG_QM} > /dev/null 2>&1; then
    PLUGIN_NAME_QM=$(ddev wp plugin get ${PLUGIN_SLUG_QM} --field=title)
    printf "${BLACK}${PLUGIN_NAME_QM} is already installed. Skipping installation.${RESET}\n\n"
  else
    ddev wp plugin install $PLUGIN_SLUG_QM --activate
    echo '' # new line
  fi
fi

# Open project in default browser to finish WordPress installation
printf "${BLUE}Opening browser to the WP Admin dashboard...${RESET}\n"
ddev launch wp-admin/
echo '' # new line
