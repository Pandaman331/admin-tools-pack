#!/bin/bash 

# set a dir statical for development and testing
MAIN_DIR="/home/administrator/admin-tools-pack"

# set path to other directories inside the main directory
MODULES_DIR="$MAIN_DIR/modules/"
ADDONS_DIR="$MAIN_DIR/addons/"
UTILS_DIR="$MAIN_DIR/utils/"
WINDOWS_DIR="$MAIN_DIR/windows/"

# set path to config file
CONFIG_FILE="$MAIN_DIR/config.conf"

# create a array for as a list of required directories
REQUIRED_DIRS=(
  "$MODULES_DIR"
  "$ADDONS_DIR"
  "$UTILS_DIR"
  "$WINDOWS_DIR"
)
# check if any folder in REQUIRED_DIRS is missing
MISSING=0

for dir in "${REQUIRED_DIRS[@]}"; do
  if [[ ! -d "$dir" ]]; then
    echo "Missing directory: $dir"
    MISSING=1
  fi
done

# check for missing config file
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing config file in dir: $CONFIG_FILE"
  MISSING=1
fi

# show error message when something is missing
if [[ "$MISSING" -eq 1 ]]; then
  echo -e "\nSome required components are missing!"
  echo "Run install.sh or refer to README for setup instructions."
fi
# create a utils list for next actions
UTILS_LIST=(
  "addon-loader.sh"
  "colors.sh"
  "event-loop.sh"
  "input-handler.sh"
  "module-loader.sh"
  "window-manager.sh"
  "window-size.sh"
)

# source utils files and check for missing ones
for util in "${UTILS_LIST[@]}"; do
  util_path="$UTILS_DIR/$util"

  if [[ -f "$util_path" ]]; then
    source "$util_path"
  else
    echo "Missing utility file: $util_path"
    exit 1
  fi
done
