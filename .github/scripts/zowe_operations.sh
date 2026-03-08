#!/bin/bash
# zowe_operations.sh

# 1. INITIALIZE CONFIG
# This creates zowe.config.json in the current folder
zowe config init

# 2. SET CONNECTION PROPERTIES
# We use the '--config' flag (instead of --config-file) if needed, 
# but Zowe usually finds zowe.config.json automatically.
zowe config set "profiles.base.properties.host" "204.90.115.200"
zowe config set "profiles.base.properties.user" "$ZOWE_USERNAME"
zowe config set "profiles.base.properties.password" "$ZOWE_PASSWORD"
zowe config set "profiles.base.properties.rejectUnauthorized" false
zowe config set "profiles.zosmf.properties.port" 10443

# 3. Setup Variables
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
TARGET_DIR="//z/$LOWERCASE_USERNAME/cobolcheck"

# 4. Check/Create Directory
# Removed the explicit flag to see if Zowe finds the local config automatically
if ! zowe zos-files list uss-files "$TARGET_DIR" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "$TARGET_DIR"
else
    echo "Directory already exists. Skipping mkdir."
fi

# 5. Upload files
zowe zos-files upload dir-to-uss "." "$TARGET_DIR" \
  --recursive \
  --binary-files "cobol-check-0.2.19.jar"