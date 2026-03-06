#!/usr/bin/env bash
set -euo pipefail

log() { printf "[%(%Y-%m-%d %H:%M:%S)T] %s\n" -1 "$*" >&2; }

log "➡️ Setting up Java environment"
java -version

# Paths based on your repo layout
LAUNCHER="cobol-check/cobolcheck"     # unix launcher shipped with the project
JAR="cobol-check/cobol-check-0.2.19.jar"  # keep for sanity checks
SRC_MAIN="src/main/cobol"
SRC_TEST="src/test/cobol"

log "➡️ Verifying files/folders"
[[ -x "$LAUNCHER" ]] || { log "❌ Launcher not executable: $LAUNCHER"; ls -la cobol-check || true; exit 1; }
[[ -f "$JAR" ]] || { log "❌ JAR not found: $JAR"; ls -la cobol-check || true; exit 1; }
[[ -d "$SRC_MAIN" ]] || { log "❌ Source folder not found: $SRC_MAIN"; ls -la src || true; exit 1; }
[[ -d "$SRC_TEST" ]] || { log "❌ Test folder not found: $SRC_TEST"; ls -la src/test || true; exit 1; }

log "➡️ Showing cobolcheck --help to confirm valid flags"
set +e
"$LAUNCHER" --help || "$LAUNCHER" -h
help_rc=$?
set -e
log "ℹ️ help returned code: $help_rc (non-zero here is okay on some versions)"

# Try the most common flag set first.
# Many 0.2.x builds expect explicit options for test and source roots.
try_run() {
  log "➡️ Executing: $*"
  set +e
  "$@"
  rc=$?
  set -e
  return $rc
}

# Attempt 1: common flags seen in recent 0.2.x
if try_run "$LAUNCHER" --tests "$SRC_TEST" --sources "$SRC_MAIN"; then
  log "✅ COBOL Check completed with --tests/--sources"
  exit 0
fi

# Attempt 2: alternative short flags used by some builds (-t/-s)
if try_run "$LAUNCHER" -t "$SRC_TEST" -s "$SRC_MAIN"; then
  log "✅ COBOL Check completed with -t/-s"
  exit 0
fi

# Attempt 3: some distributions use --test-root/--source-root
if try_run "$LAUNCHER" --test-root "$SRC_TEST" --source-root "$SRC_MAIN"; then
  log "✅ COBOL Check completed with --test-root/--source-root"
  exit 0
fi

# Attempt 4: legacy positional (rare on your build, but try once)
if try_run "$LAUNCHER" "$SRC_TEST"; then
  log "✅ COBOL Check completed with positional test-root"
  exit 0
fi

log "❌ All invocation patterns failed. See the --help output above for the exact options your build expects."
exit 1