#!/usr/bin/env bash
set -euo pipefail

# Validate required environment variables
: "${ZOWE_USERNAME:?Missing ZOWE_USERNAME (set as a GitHub secret)}"
: "${ZOWE_PASSWORD:?Missing ZOWE_PASSWORD (set as a GitHub secret)}"
: "${ZOWE_HOST:?Missing ZOWE_HOST (set as a GitHub secret)}"
: "${ZOWE_PORT:?Missing ZOWE_PORT (set as a GitHub secret)}"

echo "➡️ Zowe CLI version:"
zowe --version

echo "➡️ Creating Zowe CLI profile"
# Create (or overwrite) a default z/OSMF profile for this runner
zowe profiles create zosmf default \
  --host "$ZOWE_HOST" \
  --port "$ZOWE_PORT" \
  --user "$ZOWE_USERNAME" \
  --password "$ZOWE_PASSWORD" \
  --reject-unauthorized false \
  --ru false

# Convert username to lowercase for USS paths
LOWERCASE_USERNAME="$(printf "%s" "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')"
USS_DIR="/z/${LOWERCASE_USERNAME}/cobolcheck"

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