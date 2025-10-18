#!/bin/bash

# Initialize Git
printf "${BLUE}Initializing Git...${RESET}\n"
if [ -d '.git' ]; then
  printf "${BLACK}Git is already initialized for this project. Skipping initialization.${RESET}\n\n"
else
  git init
  # Print success message
  printf "${GREEN}Local Git repository created at: ${BOLD}.git${RESET}\n\n"
fi
