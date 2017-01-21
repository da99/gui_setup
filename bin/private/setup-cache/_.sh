
THE_DB_FILE="$THE_DIR"/tmp/windows.db
WINDOWS_TABLE="windows"

# === {{CMD}}
setup-cache () {
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

} # === end function
