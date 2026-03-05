#!/usr/bin/env bash
set -euo pipefail

: "${ZOWE_USERNAME:?Missing ZOWE_USERNAME secret}"
: "${ZOWE_PASSWORD:?Missing ZOWE_PASSWORD secret}"

echo "➡️ Setting up Java environment"
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH="$JAVA_HOME/bin:$PATH"

java -version || true

COBOLCHECK_DIR="cobol-check"

echo "➡️ Entering COBOL Check directory: ${COBOLCHECK_DIR}"
cd "${COBOLCHECK_DIR}"

# Ensure executable permissions
if [[ -f cobolcheck ]]; then
  chmod +x cobolcheck
fi

if [[ -d scripts ]]; then
  chmod +x scripts/* || true
fi

# Function to run tests
run_cobolcheck() {
  local program="$1"

  echo "──────────────────────────────────────────"
  echo "Running COBOL Check for program: ${program}"
  echo "──────────────────────────────────────────"

  ./cobolcheck -p "${program}" || echo "⚠️ cobolcheck returned non-zero exit code."

  # Upload CC##99.CBL if exists
  if [[ -f "CC##99.CBL" ]]; then
    echo "Uploading CC##99.CBL to ${ZOWE_USERNAME}.CBL(${program})"
    zowe zos-files upload file-to-data-set "CC##99.CBL" "${ZOWE_USERNAME}.CBL(${program})" --encoding ISO8859-1
  else
    echo "⚠️ No CC##99.CBL file found"
  fi

  # Upload JCL member
  if [[ -f "../${program}.JCL" ]]; then
    echo "Uploading ${program}.JCL"
    zowe zos-files upload file-to-data-set "../${program}.JCL" "${ZOWE_USERNAME}.JCL(${program})" --encoding ISO8859-1
    
    echo "Submitting job: ${ZOWE_USERNAME}.JCL(${program})"
    zowe zos-jobs submit data-set "${ZOWE_USERNAME}.JCL(${program})" --wfo
  else
    echo "ℹ️ No JCL file found for ${program}"
  fi
}

# Run for the 3 programs used in the lab
for program in NUMBERS EMPPAY DEPTPAY; do
  run_cobolcheck "${program}"
done

echo "✅ mainframe_operations.sh completed."
