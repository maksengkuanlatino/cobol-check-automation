--- a/.github/scripts/mainframe_operations.sh
+++ b/.github/scripts/mainframe_operations.sh
@@ -1,28 +1,36 @@
 #!/usr/bin/env bash
 set -euo pipefail
 
 log() { printf "[%(%Y-%m-%d %H:%M:%S)T] %s\n" -1 "$*" >&2; }
 
-log "➡️ Setting up Java environment"
+log "➡️ Setting up Java environment"
 java -version
 
-log "➡️ Entering COBOL Check directory: cobol-check"
-cd cobol-check
-
-# OLD (wrong): looks for ./src under cobol-check/
-# JAR="./cobol-check-0.2.19.jar"
-# TEST_ROOT="./src"
+log "➡️ Running COBOL Check from repo root"
+# JAR lives under ./cobol-check; tests live under ./src/test/cobol
+JAR="cobol-check/cobol-check-0.2.19.jar"
+TEST_ROOT="src/test/cobol"
 
-if [[ ! -f "$JAR" ]]; then
-  log "❌ JAR not found at $JAR"
-  exit 1
-fi
-if [[ ! -d "$TEST_ROOT" ]]; then
-  log "❌ Test root not found at $TEST_ROOT"
-  exit 1
-fi
+if [[ ! -f "$JAR" ]]; then
+  log "❌ COBOL Check JAR not found at: $JAR"
+  # Show tree to aid debugging in CI
+  ls -la .
+  ls -la cobol-check || true
+  exit 1
+fi
+if [[ ! -d "$TEST_ROOT" ]]; then
+  log "❌ Test directory not found: $TEST_ROOT"
+  # Show tree to aid debugging in CI
+  ls -la .
+  ls -la src || true
+  ls -la src/test || true
+  exit 1
+fi
 
-log "➡️ Running COBOL Check: java -jar $JAR $TEST_ROOT"
-java -jar "$JAR" "$TEST_ROOT"
+log "➡️ Executing: java -jar $JAR $TEST_ROOT"
+set +e
+java -jar "$JAR" "$TEST_ROOT"
+rc=$?
+set -e
+exit $rc