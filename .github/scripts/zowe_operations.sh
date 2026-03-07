#!/bin/bash
# zowe_operations.sh

# 1. CREATE TEMPORARY ZOWE PROFILE (Fixes "Timed out waiting for hostname")
# Replace '192.86.32.250' with the IP provided in your COBOL course if different
zowe profiles create zosmf-profile default-profile \
  --host 192.86.32.250 \
  --port 10443 \
  --user "$ZOWE_USERNAME" \
  --pass "$ZOWE_PASSWORD" \
  --reject-unauthorized false --overwrite

zowe profiles set zosmf default-profile

# 2. Setup Variables
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# 3. Check/Create Directory
if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck"
else
    echo "Directory already exists."
fi

# 4. Upload files (Fixes line 14 error by removing the accidental line break)
zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive --binary-files "cobol-check-0.2.9.jar"

# 5. Verify upload
echo "Verifying upload:"
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck"