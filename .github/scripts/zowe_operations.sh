#!/bin/bash
# zowe_operations.sh

# 1. CREATE CONFIGURATION (Modern Zowe Syntax)
# This replaces the 'profiles' command that was failing
zowe config set "profiles.zosmf.properties.host" "204.90.115.200" --global
zowe config set "profiles.zosmf.properties.port" "10443" --global
zowe config set "profiles.zosmf.properties.user" "$ZOWE_USERNAME" --global
zowe config set "profiles.zosmf.properties.pass" "$ZOWE_PASSWORD" --global
zowe config set "profiles.zosmf.properties.rejectUnauthorized" "false" --global

# 2. Setup Variables
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# 3. Check/Create Directory
if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck"
else
    echo "Directory already exists."
fi

# 4. Upload files
zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive --binary-files "cobol-check-0.2.9.jar"

# 5. Verify upload
echo "Verifying upload:"
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck"