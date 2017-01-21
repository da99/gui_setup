
# === {{CMD}}  URL
icy-title () {
  local +x URL="$1"; shift
  local +x TITLE="$((curl --connect-timeout 2 -H 'icy-metadata: 1' "$URL"  -s || echo "[down]") | head -c 34000 | grep --text -Pzo "(?s)(StreamTitle='\K(.*)(?=';Stream))|down|(4|5)\d\d Service \w" )"

  case "$TITLE" in
    down|*" Service "*)
      echo "[down]"
      ;;
    "")
      echo "[Untitled]"
      ;;
    *)
      echo "$TITLE"
      ;;
  esac
} # === end function
