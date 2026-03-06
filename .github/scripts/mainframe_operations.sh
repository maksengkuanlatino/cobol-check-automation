#!/usr/bin/env bash
set -euo pipefail

log() { printf "[%(%Y-%m-%d %H:%M:%S)T] %s\n" -1 "$*" >&2; }

log "➡️ Setting up Java environment"
java -version

log "➡️ Running COBOL Check from repo root"

JAR="cobol-check/cobol-check-0.2.19.jar"   # change if you rename the jar
SRC_MAIN=""
SRC_TEST=""

# Sanity checks
[[ -f "$JAR" ]] || { log "❌ JAR not found: $JAR"; ls -la cobol-check || true; exit 1; }
[[ -d "$SRC_MAIN" ]] || { log "❌ Source folder not found: $SRC_MAIN"; ls -la src || true; exit 1; }
[[ -d "$SRC_TEST" ]] || { log "❌ Test folder not found: $SRC_TEST"; ls -la src/test || true; exit 1; }

# Discover program names from subfolders under src/test/cobol (DEPTPAY, EMPPAY, ...)
mapfile -t PROGRAMS < <(find "$SRC_TEST" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

# Fallback: if there are .cut files directly under src/test/cobol, use their basenames
if [[ ${#PROGRAMS[@]} -eq 0 ]]; then
  mapfile -t PROGRAMS < <(find "$SRC_TEST" -maxdepth 1 -type f -name "*.cut" -printf "%f\n" \
                          | sed 's/\.cut$//' | sort | uniq)
fi

if [[ ${#PROGRAMS[@]} -eq 0 ]]; then
  log "❌ Could not discover any program names in $SRC_TEST (expect subfolders or .cut files)."
  ls -la "$SRC_TEST" || true
  exit 1
fi

log "ℹ️ Programs discovered for -p: ${PROGRAMS[*]}"

# Build the command: -t tests -s sources -p <one or more program names>
CMD=( java -jar "$JAR" -t "$SRC_TEST" -s "$SRC_MAIN" -p )
CMD+=( "${PROGRAMS[@]}" )

log "➡️ Executing: ${CMD[*]}"
"${CMD[@]}"