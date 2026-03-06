#!/usr/bin/env bash
set -euo pipefail

# Log helper
log() { printf "[%(%Y-%m-%d %H:%M:%S)T] %s\n" -1 "$*" >&2; }

# Upload a *binary* file to USS via Zowe CLI safely (no iconv)
# Usage: upload_binary_with_zowe local_file /path/on/uss/file.jar
upload_binary_with_zowe() {
  local src="${1:?local binary file required}"
  local dst="${2:?USS target absolute path required}"

  if [[ ! -f "$src" ]]; then
    log "ERROR: Source file not found: $src"
    return 2
  fi

  # Ensure parent directory exists on USS
  local parent_dir
  parent_dir="$(dirname "$dst")"
  log "Ensuring USS directory exists: $parent_dir"
  zowe zos-files create uss-dir "$parent_dir" --mode 755 --replace 2>/dev/null || true

  log "Uploading (binary) $src -> $dst"
  # --binary is the critical flag to prevent iconv/text conversion
  # --binary also sets appropriate transfer handling for non-text content
  zowe zos-files upload file-to-uss "$src" "$dst" --binary --rfj | tee /tmp/zowe_upload.json

  # Optional: verify size
  local local_size remote_size
  local_size=$(stat -c%s "$src")
  remote_size=$(zowe zos-files list uss-file "$dst" --rfj | jq -r '.data."size" // .data.size // empty' || echo "")
  if [[ -n "$remote_size" && "$local_size" -ne "$remote_size" ]]; then
    log "WARNING: Size mismatch local=$local_size remote=$remote_size"
  else
    log "Upload verified. Size local=$local_size remote=$remote_size"
  fi
}

# Example invocation (adjust paths as needed):
# upload_binary_with_zowe "cobolcheck-0.2.19.jar" "/z/yourapp/bin/cobolcheck-0.2.19.jar"