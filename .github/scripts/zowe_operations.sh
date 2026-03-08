#!/bin/bash
# zowe_operations.sh

# 1. INITIALIZE CONFIGURATION
# Simply run 'init' without the force flag
zowe config init

# 2. SET CONNECTION PROPERTIES
# Targeting standard 'base' and 'zosmf' profiles
zowe config set "profiles.base.properties.host" "204.90.115.200"
zowe config set "profiles.base.properties.user" "$ZOWE_USERNAME"
zowe config set "profiles.base.properties.password" "$ZOWE_PASSWORD"
zowe config set "profiles.base.properties.rejectUnauthorized" false
zowe config set "profiles.zosmf.properties.port" 10443

# 3. Setup Variables
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
TARGET_DIR="//z/$LOWERCASE_USERNAME/cobolcheck"

# 4. Check/Create Directory
# Using '//' to bypass Windows/Git Bash path translation
if ! zowe zos-files list uss-files "$TARGET_DIR" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "$TARGET_DIR"
else
    echo "Directory already exists. Skipping mkdir."
fi

# 5. Upload files
# Using the standard dir-to-uss command
zowe zos-files upload dir-to-uss "." "$TARGET_DIR" \
  --recursive \
  --binary-files "cobol-check-0.2.19.jar"