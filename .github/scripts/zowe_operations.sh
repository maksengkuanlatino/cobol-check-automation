#!/usr/bin/env bash
set -euo pipefail

# Make sure secrets exist
: "${ZOWE_USERNAME:?Missing ZOWE_USERNAME secret}"
: "${ZOWE_PASSWORD:?Missing ZOWE_PASSWORD secret}"

# Convert username to lowercase for USS paths
LOWERCASE_USERNAME="$(printf "%s" "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')"
USS_DIR="/z/${LOWERCASE_USERNAME}/cobolcheck"

echo "➡️ Zowe CLI version:"
zowe --version || true

echo "➡️ Checking USS directory: ${USS_DIR}"
if ! zowe zos-files list uss-files "${USS_DIR}" >/dev/null 2>&1; then
  echo "Creating directory ${USS_DIR}"
  zowe zos-files create uss-directory "${USS_DIR}"
else
  echo "Directory already exists."
fi

echo "➡️ Uploading COBOL Check directory"
zowe zos-files upload dir-to-uss "./cobol-check" "${USS_DIR}" --recursive

echo "➡️ Listing uploaded files:"
zowe zos-files list uss-files "${USS_DIR}"

echo "✅ zowe_operations.sh completed."