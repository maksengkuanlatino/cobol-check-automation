#!/usr/bin/env bash
set -euo pipefail

log() { printf "[%(%Y-%m-%d %H:%M:%S)T] %s\n" -1 "$*" >&2; }

log "➡️ Setting up Java environment"
java -version

log "➡️ Entering COBOL Check directory: cobol-check"
cd cobol-check

JAR="./cobol-check-0.2.19.jar"
TEST_ROOT="./src"       # adjust if your tests live elsewhere

if [[ ! -f "$JAR" ]]; then
  log "❌ JAR not found at $JAR"
  exit 1
fi
if [[ ! -d "$TEST_ROOT" ]]; then
  log "❌ Test root not found at $TEST_ROOT"
  exit 1
fi

log "➡️ Running COBOL Check: java -jar $JAR $TEST_ROOT"
set +e
java -jar "$JAR" "$TEST_ROOT"
rc=$?
set -e

if [[ $rc -ne 0 ]]; then
  log "❌ COBOL Check failed with exit code $rc"
  exit $rc
fi

log "✅ COBOL Check completed successfully."
