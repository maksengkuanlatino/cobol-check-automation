#!/usr/bin/env bash
set -euo pipefail

log() { printf "[%(%Y-%m-%d %H:%M:%S)T] %s\n" -1 "$*" >&2; }

log "➡️ Setting up Java environment"
java -version

log "➡️ Running COBOL Check from repo root"

# JAR lives under ./cobol-check; tests live under ./src/test/cobol
JAR="cobol-check/cobol-check-0.2.19.jar"
TEST_ROOT="src/test/cobol"

if [[ ! -f "$JAR" ]]; then
  log "❌ COBOL Check JAR not found at: $JAR"
  ls -la .
  ls -la cobol-check || true
  exit 1
fi

if [[ ! -d "$TEST_ROOT" ]]; then
  log "❌ Test directory not found: $TEST_ROOT"
  ls -la .
  ls -la src || true
  ls -la src/test || true
  exit 1
fi

log "➡️ Executing: java -jar $JAR $TEST_ROOT"
java -jar "$JAR" "$TEST_ROOT"