
source "$THIS_DIR/bin/private/setup-cache/_.sh"
source "$THIS_DIR/bin/private/to-key/_.sh"
source "$THIS_DIR/bin/private/to-sql-string/_.sh"

# === echo "sql string;" | {{CMD}}
# === {{CMD}}  id  "KEY=VALUE" "KEY2=VAL2" ...
# === Write to the cache.
write () {
  if [[ -z "$@" ]]; then
    setup-cache
    sqlite3 "$THE_DB_FILE"
    return 0
  fi

  ensure-valid-key "$1"
  local +x NAMES="id"
  local +x VALUES="$(to-sql-string "$1")"; shift

  while [[ ! -z "$@" ]]; do
    local +x RAW_KEY="$(echo "$1" | cut -d'=' -f1)"
    local +x RAW_VAL="$(echo "$1" | cut -d'=' -f2-)"
    ensure-valid-key "$RAW_KEY"
    NAMES="$NAMES, $RAW_KEY"
    VALUES="$VALUES, $(to-sql-string "$RAW_VAL")"
    shift
  done

  "INSERT OR REPLACE INTO $WINDOWS_TABLE ($NAMES) VALUES ( $VALUES );"
} # === end function
