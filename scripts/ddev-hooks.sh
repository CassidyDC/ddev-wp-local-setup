#!/bin/bash

# shellcheck disable=SC2059

CONFIG_FILE=".ddev/config.yaml"

# Set WP development configurations
printf "${BLUE}Adding DDEV configuration hooks to ${CONFIG_FILE}...${RESET}\n"

EXEC_HOOK="- exec:"
SLEEP_HOOK="$EXEC_HOOK sleep 2"

# Define an array of WP config command variable names
WP_CONFIGS=(
  SCRIPT_DEBUG
  WP_CONTENT_DIR
  WP_CONTENT_URL
  WP_DEBUG
  WP_DEBUG_DISPLAY
  WP_DEBUG_LOG
  WP_DEVELOPMENT_MODE
  WP_ENVIRONMENT_TYPE
)

# Create {WP_CONFIG}_HOOK variables assigned to {WP_CONFIG}_VALUE
for CONFIG in "${WP_CONFIGS[@]}"; do
  HOOK_VAR_NAME="${CONFIG}_HOOK"
  VALUE_VAR_NAME="${CONFIG}_VALUE"
  CONFIG_VALUE="\"${!VALUE_VAR_NAME}\""

  if [ -n "$CONFIG_VALUE" ]; then
    eval "$HOOK_VAR_NAME='${EXEC_HOOK} wp config set $CONFIG \"'${CONFIG_VALUE}'\" --raw'"
  else
    eval "$HOOK_VAR_NAME="
  fi
done

# Add a post-start hook with the table_prefix variable
if [ -n "$CUSTOM_TABLE_PREFIX_VALUE" ]; then
  CUSTOM_TABLE_PREFIX_HOOK="$EXEC_HOOK wp config set table_prefix \"$CUSTOM_TABLE_PREFIX_VALUE\" --raw --type=variable"
fi

# Add a post-import-db hook with the search-replace command
if [ -n "$DB_URL_REPLACE_VALUE" ]; then
  DB_URL_REPLACE_HOOK="$EXEC_HOOK wp search-replace $DB_URL_REPLACE_VALUE"
fi

# Add the hook and commands if hooks doesn't exist
if ! grep -q "^hooks:" "$CONFIG_FILE"; then
  {
    echo "hooks:"
    echo "    post-start:"
    echo "        $SLEEP_HOOK"
    for CONFIG in "${WP_CONFIGS[@]}"; do
      HOOK_VAR_NAME="${CONFIG}_HOOK"
      if [ -n "${!HOOK_VAR_NAME}" ]; then
        echo "        ${!HOOK_VAR_NAME}"
      fi
    done
    if [ -n "$CUSTOM_TABLE_PREFIX_HOOK" ]; then
      echo "        $CUSTOM_TABLE_PREFIX_HOOK"
    fi
    if [ -n "$DB_URL_REPLACE_HOOK" ]; then
      echo "    post-import-db:"
      echo "        $SLEEP_HOOK"
      echo "        $DB_URL_REPLACE_HOOK"
    fi
  } >> "$CONFIG_FILE"
  printf "${GREEN}Added hooks section with subsections in: ${BOLD}${CONFIG_FILE}${RESET}\n\n"
else
  # Check if post-start hooks section exists
  grep -q "^[[:space:]]*post-start:" "$CONFIG_FILE"
  POST_START_EXISTS=$?

  # Check if post-import-db hooks section exists
  grep -q "^[[:space:]]*post-import-db:" "$CONFIG_FILE"
  POST_IMPORT_DB_EXISTS=$?

  # If the post-start hooks section doesn't exist, add it
  if [ "$POST_START_EXISTS" -ne 0 ]; then
    sed -i '' "/^hooks:/a\\
    post-start:\\
$(for CONFIG in "${WP_CONFIGS[@]}"; do
  HOOK_VAR_NAME="${CONFIG}_HOOK"
  if [ -n "${!HOOK_VAR_NAME}" ]; then
    printf "        %s\\\\\n" "${!HOOK_VAR_NAME}"
  fi
done)
" "$CONFIG_FILE"
    printf "${GREEN}Added post-start hooks for WP Config in: ${BOLD}${CONFIG_FILE}${RESET}\n\n"
  else
    printf "${BLACK}The post-start hooks section already exist in $CONFIG_FILE. Skipping creation.${RESET}\n\n"
  fi

  # If the post-import-db hooks section doesn't exist, add it
  if [ "$POST_IMPORT_DB_EXISTS" -ne 0 ]; then
    if [ -n "$DB_URL_REPLACE_HOOK" ]; then
    sed -i '' "/^hooks:/a\\
    post-import-db:\\
$(printf "        %s\\\\\n" "$DB_URL_REPLACE_HOOK")
" "$CONFIG_FILE"
      printf "${GREEN}Added post-import-db hooks for WP Config in: ${BOLD}${CONFIG_FILE}${RESET}\n\n"
    fi
  else
    printf "${BLACK}The post-import-db hooks section already exist in $CONFIG_FILE. Skipping creation.${RESET}\n\n"
  fi
fi
