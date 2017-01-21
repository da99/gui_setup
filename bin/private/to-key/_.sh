
# === {{CMD}}  STRING
to-key () {
  local +x RAW_NAME="$1"; shift
  if ! echo "$RAW_NAME" | grep -P "^[a-zA-Z0-9\_\-\.]+$" &>/dev/null;then
    echo "!!! Invalid key: $RAW_NAME" >&2
    exit 1
  fi
  echo "$RAW_NAME"
} # === end function
