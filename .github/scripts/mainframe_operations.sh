#!/usr/bin/env bash
set -euo pipefail

log() { printf "[%(%Y-%m-%d %H:%M:%S)T] %s\n" -1 "$*" >&2; }

# 1) Ensure Java
log "➡️ Setting up Java environment"
java -version

# 2) Enter the COBOL Check directory (adjust if your structure differs)
log "➡️ Entering COBOL Check directory: cobol-check"
cd cobol-check

# 3) Resolve artifact / launcher
LAUNCHER="./cobolcheck"                                # expected shell launcher (if present)
JAR="./cobol-check-0.2.19.jar"                         # the JAR you already have
CFG_DIR="./lib"                                        # typical place for config; change if needed
TEST_ROOT="./src"                                      # where your COBOL tests live; change if needed
REPORTS_DIR="./reports"                                # output folder

mkdir -p "$REPORTS_DIR"

# 4) Choose how to run cobol-check
if [[ -x "$LAUNCHER" ]]; then
  log "✅ Found cobolcheck launcher: $LAUNCHER"
  RUN_CMD=( "$LAUNCHER" "--root" "$TEST_ROOT" "--config" "$CFG_DIR" "--reports" "$REPORTS_DIR" )
elif [[ -f "$JAR" ]]; then
  log "⚠️ cobolcheck launcher not found. Falling back to JAR: $JAR"
  # Pass arguments equivalent to the launcher (tweak flags to your project)
  RUN_CMD=( java -jar "$JAR" "--root" "$TEST_ROOT" "--config" "$CFG_DIR" "--reports" "$REPORTS_DIR" )
else
  log "❌ Neither launcher ($LAUNCHER) nor JAR ($JAR) found. Aborting."
  exit 1
fi

# 5) Run cobol-check
log "➡️ Running COBOL Check: ${RUN_CMD[*]}"
"${RUN_CMD[@]}"

log "✅ COBOL Check completed. Reports in: $REPORTS_DIR"
``