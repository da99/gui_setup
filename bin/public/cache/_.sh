
source "$THIS_DIR/bin/private/to-key/_.sh"
source "$THIS_DIR/bin/private/to-sql-string/_.sh"

THE_DB_FILE="$THE_DIR"/tmp/windows.db
WINDOWS_TABLE="windows"

cache () {
  local +x ACTION="$1"; shift

  case "$ACTION" in

# === {{CMD}} reset
# === Sets alls windows to active=0
    reset)
      cache ensure
      echo "UPDATE $WINDOWS_TABLE SET active = 0 ;" | cache write
      ;;

# === {{CMD}}  read id
# === {{CMD}}  read id  field1  field2  field3
    read)
      ;;

# === echo "sql string;" | {{CMD}}
# === Execute a SQL statement.
# === {{CMD}}  id  "KEY=VALUE" "KEY2=VAL2" ...
# === Write or update a key based on the id.
    write)
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

      echo "INSERT OR REPLACE INTO $WINDOWS_TABLE ($NAMES) VALUES ( $VALUES );" | cache write
      ;;

# === {{CMD}} ensure
    ensure)
      local +x THE_DB_FILE="$THIS_DIR"/tmp/windows.db
      if [[ ! -f "$THE_DB_FILE" ]]; then
        mkdir -p "$(dirname "$THE_DB_FILE")"
        sqlite3 $THE_DB_FILE "create table ${WINDOWS_TABLE} ( \
          id TEXT    PRIMARY KEY,                 \
          title      TEXT,                        \
          path       TEXT,                        \
          icon_name  TEXT,                        \
          icon_path  TEXT,                        \
          try_exec   TEXT,                        \
          exec       TEXT,                        \
          terminal   INT DEFAULT 0,               \
          active     INT DEFAULT 0,               \
          display_as TEXT,                        \
          comment    TEXT                         \
        );"
      fi
      ;;
    *)
      echo "!!! Unknown action: $ACTION $@" >&2
      exit 1
      ;;
  esac
} # === end function
