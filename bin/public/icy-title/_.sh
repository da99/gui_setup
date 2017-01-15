
# === {{CMD}}  URL
icy-title () {
  local +x URL="$1"; shift

  local +x TITLE="$(curl -H 'icy-metadata: 1' "$URL"  -s | head -c 34000 | grep --text -Pzo "(?s)StreamTitle='\K(.*)(?=';Stream)" || : )"

  if [[ -z "$TITLE" ]]; then
    echo "[unknown]"
  else
    echo "$TITLE"
  fi
} # === end function
