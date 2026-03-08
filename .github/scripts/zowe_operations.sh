#!/bin/bash
# zowe_operations.sh

# Connection flags reused on every command
ZOWE_CONN=(
  --host "204.90.115.200"
  --port 10443
  --user "$ZOWE_USERNAME"
  --password "$ZOWE_PASSWORD"
  --reject-unauthorized false
)

# Setup Variables
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
TARGET_DIR="/z/$LOWERCASE_USERNAME/cobolcheck"

# Check/Create Directory
if ! zowe zos-files list uss-files "$TARGET_DIR" "${ZOWE_CONN[@]}" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "$TARGET_DIR" "${ZOWE_CONN[@]}"
else
    echo "Directory already exists. Skipping mkdir."
fi

# Upload files (exclude .git folder to avoid binary encoding errors)
zowe zos-files upload dir-to-uss "." "$TARGET_DIR" \
  --recursive \
  --binary \
  --exclude-pattern ".git" \
  "${ZOWE_CONN[@]}"
