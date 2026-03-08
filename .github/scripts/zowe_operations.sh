#!/bin/bash
# zowe_operations.sh

# 1. INITIALIZE CONFIG
zowe config init

# 2. SET CONNECTION PROPERTIES
# We explicitly point to the config file just in case
CONFIG_PATH="./zowe.config.json"

zowe config set "profiles.base.properties.host" "204.90.115.200" --config-file "$CONFIG_PATH"
zowe config set "profiles.base.properties.user" "$ZOWE_USERNAME" --config-file "$CONFIG_PATH"
zowe config set "profiles.base.properties.password" "$ZOWE_PASSWORD" --config-file "$CONFIG_PATH"
zowe config set "profiles.base.properties.rejectUnauthorized" false --config-file "$CONFIG_PATH"
zowe config set "profiles.zosmf.properties.port" 10443 --config-file "$CONFIG_PATH"

# 3. Setup Variables
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
TARGET_DIR="//z/$LOWERCASE_USERNAME/cobolcheck"

# 4. Check/Create Directory
# We now use '--config-file' to force Zowe to use the values we just set
if ! zowe zos-files list uss-files "$TARGET_DIR" --config-file "$CONFIG_PATH" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "$TARGET_DIR" --config-file "$CONFIG_PATH"
else
    echo "Directory already exists. Skipping mkdir."
fi

# 5. Upload files
zowe zos-files upload dir-to-uss "." "$TARGET_DIR" \
  --recursive \
  --binary-files "cobol-check-0.2.19.jar" \
  --config-file "$CONFIG_PATH"