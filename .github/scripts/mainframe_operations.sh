#!/usr/bin/env bash
set -euo pipefail

log() { printf "[%(%Y-%m-%d %H:%M:%S)T] %s\n" -1 "$*" >&2; }

log "➡️ Setting up Java environment"
java -version

log "➡️ Running COBOL Check from repo root (no launcher)"

JAR="cobol-check/cobol-check-0.2.19.jar"   # adjust if you bump the version file name
SRC_MAIN="src/main/cobol"
SRC_TEST="src/test/cobol"

# Sanity checks
[[ -f "$JAR" ]] || { log "❌ JAR not found: $JAR"; ls -la cobol-check || true; exit 1; }
[[ -d "$SRC_MAIN" ]] || { log "❌ Source folder not found: $SRC_MAIN"; ls -la src || true; exit 1; }
[[ -d "$SRC_TEST" ]] || { log "❌ Test folder not found: $SRC_TEST"; ls -la src/test || true; exit 1; }

# Show usage so we can see which flags this JAR supports in logs
log "ℹ️ Dumping --help for this JAR (non-zero exit here is OK on some builds)"
set +e
java -jar "$JAR" --help || java -jar "$JAR" -h
set -e

try_run() {
  log "➡️ Executing: $*"
  set +e
  "$@"
  rc=$?
  set -e
  return $rc
}

# Try common 0.2.x flag sets in order; stop on first success
if try_run java -jar "$JAR" --tests "$SRC_TEST" --sources "$SRC_MAIN"; then
  log "✅ Done with --tests/--sources"
  exit 0
fi

if try_run java -jar "$JAR" -t "$SRC_TEST" -s "$SRC_MAIN"; then
  log "✅ Done with -t/-s"
  exit 0
fi

if try_run java -jar "$JAR" --test-root "$SRC_TEST" --source-root "$SRC_MAIN"; then
  log "✅ Done with --test-root/--source-root"
  exit 0
fi

# Rare older builds: positional argument for test root
if try_run java -jar "$JAR" "$SRC_TEST"; then
  log "✅ Done with positional test-root"
  exit 0
fi

log "❌ All invocation patterns failed. See the --help usage above to lock exact flags."
exit 1
``