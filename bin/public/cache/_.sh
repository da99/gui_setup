
source "$THIS_DIR/bin/private/to-key/_.sh"
source "$THIS_DIR/bin/private/to-sql-string/_.sh"

THE_DB_FILE="$THE_DIR"/tmp/windows.db
WINDOWS_TABLE="windows"

cache () {
  local +x ACTION="$1"; shift

  case "$ACTION" in

# === {{CMD}}  a string with text and comma's
# === Returns 'a string with text and comma''s'
    to-sql-string)
      echo "'${@//"'"/"''"}'"
      ;;

# === {{CMD}}  ensure-valid-key STRING
# === {{CMD}}  to-key           STRING
    ensure-valid-key|to-key)
      local +x RAW_NAME="$1"; shift
      if ! echo "$RAW_NAME" | grep -P "^[a-zA-Z0-9\_\-\.]+$" &>/dev/null;then
        echo "!!! Invalid key: $RAW_NAME" >&2
        exit 1
      fi
      echo "$RAW_NAME"
      ;;

# === {{CMD}} reset
# === Sets alls windows to active=0
    reset)
      cache ensure
      echo "UPDATE $WINDOWS_TABLE SET attn = 0, active = 0 ;" | cache write
      ;;

# === {{CMD}}  read id
# === {{CMD}}  read id  field1  field2  field3
    read)
      local +x ID="$1"; shift

      if [[ -z "$@" ]]; then
        sqlite3 "$THE_DB_FILE" "SELECT * FROM $WINDOWS_TABLE WHERE id = $(cache to-sql-string "$ID");"
      else
        sqlite3 "$THE_DB_FILE" "SELECT $(cache to-field-list $@) FROM $WINDOWS_TABLE WHERE id = $(cache to-sql-string "$ID");"
      fi
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

      cache ensure-valid-key "$1"
      local +x NAMES="id"
      local +x VALUES="$(cache to-sql-string "$1")"; shift

      while [[ ! -z "$@" ]]; do
        local +x RAW_KEY="$(echo "$1" | cut -d'=' -f1)"
        local +x RAW_VAL="$(echo "$1" | cut -d'=' -f2-)"
        cache ensure-valid-key "$RAW_KEY"
        NAMES="$NAMES, $RAW_KEY"
        VALUES="$VALUES, $(cache to-sql-string "$RAW_VAL")"
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
          attn       INT DEFAULT 0,               \
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
