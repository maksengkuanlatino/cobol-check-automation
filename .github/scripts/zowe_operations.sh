#!/bin/bash
# zowe_operations.sh

# 1. UPDATE CONFIGURATION
# Removed --global and corrected 'pass' to 'password' to match your config list
zowe config set "profiles.global_base.properties.host" "204.90.115.200"
zowe config set "profiles.zosmf.properties.port" 10443
zowe config set "profiles.global_base.properties.user" "$ZOWE_USERNAME"
zowe config set "profiles.global_base.properties.password" "$ZOWE_PASSWORD"
zowe config set "profiles.global_base.properties.rejectUnauthorized" false

# 2. Setup Variables
# Mainframes are usually uppercase, so we ensure the username matches the path
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# 3. Check/Create Directory
# This prevents the 'mkdir() error' by checking if it exists first
if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck"
else
    echo "Directory already exists. Skipping mkdir."
fi

# 4. Upload files
# We use the --zosmf-profile to ensure it uses the correct port (10443)
zowe zos-files upload dir-to-uss "./" "/z/$LOWERCASE_USERNAME/cobolcheck" \
  --recursive \
  --binary-files "cobol-check-0.2.19.jar" \
  --zosmf-profile zosmf