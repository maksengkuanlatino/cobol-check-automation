#!/bin/bash
# zowe_operations.sh

# 1. INITIALIZE & UPDATE CONFIGURATION
# Using 'base' and 'zosmf' profiles which are standard in V2
zowe config init --force
zowe config set "profiles.base.properties.host" "204.90.115.200"
zowe config set "profiles.base.properties.user" "$ZOWE_USERNAME"
zowe config set "profiles.base.properties.password" "$ZOWE_PASSWORD"
zowe config set "profiles.base.properties.rejectUnauthorized" false
zowe config set "profiles.zosmf.properties.port" 10443

# 2. Setup Variables
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
TARGET_DIR="//z/$LOWERCASE_USERNAME/cobolcheck"

# 3. Check/Create Directory
# We use '//' to prevent Git Bash path conversion
if ! zowe zos-files list uss-files "$TARGET_DIR" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "$TARGET_DIR"
else
    echo "Directory already exists. Skipping mkdir."
fi

# 4. Upload files
# We use '--recursive' and binary flag as requested
zowe zos-files upload dir-to-uss "." "$TARGET_DIR" \
  --recursive \
  --binary-files "cobol-check-0.2.19.jar"