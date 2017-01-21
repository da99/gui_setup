
source "$THIS_DIR/bin/private/setup-cache/_.sh"
source "$THIS_DIR/bin/private/write/_.sh"

# === {{CMD}}
# === Sets alls windows to active=0
reset-cache () {
  setup-cache
  echo "UPDATE $WINDOWS_TABLE SET active = 0 ;" | write
} # === end function
