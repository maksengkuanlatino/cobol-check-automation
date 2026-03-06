#!/usr/bin/env bash
set -euo pipefail

: "${ZOWE_USERNAME:?Missing ZOWE_USERNAME}"
: "${ZOWE_PASSWORD:?Missing ZOWE_PASSWORD}"
: "${ZOWE_HOST:?Missing ZOWE_HOST}"
: "${ZOWE_PORT:?Missing ZOWE_PORT}"

echo "➡️ Setting up Java environment"
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH="$JAVA_HOME/bin:$PATH"
java -version || true

COBOLCHECK_DIR="cobol-check"

# Common Zowe flags (no profile)
ZOPTS=( --host "$ZOWE_HOST"
        --port "$ZOWE_PORT"
        --user "$ZOWE_USERNAME"
        --password "$ZOWE_PASSWORD"
        --reject-unauthorized false )
# If your site uses APIML base path, uncomment:
# ZOPTS+=( --base-path "/api/v1" )

echo "➡️ Entering COBOL Check directory: ${COBOLCHECK_DIR}"
cd "${COBOLCHECK_DIR}"

# Ensure launcher is executable
if [[ -f cobolcheck ]]; then
  chmod +x cobolcheck
else
  echo "❌ cobolcheck launcher not found in ${PWD}"
  exit 1
fi

# Helper: run cobolcheck, upload CC##99.CBL, upload+submit JCL
run_cobolcheck() {
  local program="$1"
  echo "──────────────────────────────────────────"
  echo "Running COBOL Check for program: ${program}"
  echo "──────────────────────────────────────────"

  ./cobolcheck -p "${program}" || echo "⚠️ cobolcheck returned non-zero; continuing if artifacts exist"

  # Upload generated CC##99.CBL into <HLQ>.CBL(member)
  if [[ -f "CC##99.CBL" ]]; then
    echo "➡️ Uploading CC##99.CBL to ${ZOWE_USERNAME}.CBL(${program})"
    zowe zos-files upload file-to-data-set "CC##99.CBL" "${ZOWE_USERNAME}.CBL(${program})" --encoding ISO8859-1 "${ZOPTS[@]}"
  else
    echo "⚠️ CC##99.CBL not found for ${program} — was the test generated?"
  fi

  # Upload JCL and submit (expects JCL at repo root)
  local JCL_FILE="../${program}.JCL"
  if [[ -f "${JCL_FILE}" ]]; then
    echo "➡️ Uploading ${program}.JCL to ${ZOWE_USERNAME}.JCL(${program})"
    zowe zos-files upload file-to-data-set "${JCL_FILE}" "${ZOWE_USERNAME}.JCL(${program})" --encoding ISO8859-1 "${ZOPTS[@]}"

    echo "➡️ Submitting job ${ZOWE_USERNAME}.JCL(${program})"
    zowe zos-jobs submit data-set "${ZOWE_USERNAME}.JCL(${program})" --wfo "${ZOPTS[@]}"
  else
    echo "ℹ️ No JCL found at ${JCL_FILE} — skipping submit."
  fi
}

for program in NUMBERS EMPPAY DEPTPAY; do
  run_cobolcheck "${program}"
done

echo "✅ mainframe_operations.sh completed."