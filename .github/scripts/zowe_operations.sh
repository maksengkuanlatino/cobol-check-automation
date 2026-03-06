#!/usr/bin/env bash
set -euo pipefail

# Validate required environment variables
: "${ZOWE_USERNAME:?Missing ZOWE_USERNAME}"
: "${ZOWE_PASSWORD:?Missing ZOWE_PASSWORD}"
: "${ZOWE_HOST:?Missing ZOWE_HOST}"
: "${ZOWE_PORT:?Missing ZOWE_PORT}"

echo "➡️ Zowe CLI version:"
zowe --version

# Build common flags used on every Zowe command
ZOPTS=(
  --host "$ZOWE_HOST"
  --port "$ZOWE_PORT"
  --user "$ZOWE_USERNAME"
  --password "$ZOWE_PASSWORD"
  --reject-unauthorized false
)

# Lowercase username
LOWERCASE_USERNAME="$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')"
USS_DIR="/z/${LOWERCASE_USERNAME}/cobolcheck"

echo "➡️ Checking USS directory: ${USS_DIR}"
if ! zowe zos-files list uss-files "${USS_DIR}" "${ZOPTS[@]}" >/dev/null 2>&1; then
  echo "Creating directory ${USS_DIR}"
  zowe zos-files create uss-directory "${USS_DIR}" "${ZOPTS[@]}"
else
  echo "Directory already exists."
fi

echo "➡️ Uploading COBOL Check directory"
zowe zos-files upload dir-to-uss "./cobol-check" "${USS_DIR}" --recursive "${ZOPTS[@]}" --binary


echo "➡️ Listing uploaded files:"
zowe zos-files list uss-files "${USS_DIR}" "${ZOPTS[@]}"

echo "✅ zowe_operations.sh completed."