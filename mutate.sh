#!/bin/bash


orig="$@"
first="$1"
last=""

shift
if [[ -n "$@" ]]; then
  last="$@"
fi

# if [[ -z "$TERM" ]]; then
  TERM="urxvt"
# fi

set -u -e -o pipefail

folders="$HOME/.local/share/applications /apps/*/bin/  /usr/share/applications/ /progs/bin/ /progs/*/bin"
term=$({ which urxvt gnome-terminal $TERM 2>/dev/null || echo "urxvt"; } | tail -n 1)
# pattern=$(echo "$orig" | sed 's/[[:blank:]]//g; s/\(.\)/\1{1}[^\/]*/g')


while read -r FILE; do
  case $FILE in
    *.desktop)
      echo [$FILE]
      name=$(basename "$FILE" .desktop)
      icon=$(grep --extended-regexp "^Icon=" "$FILE" | head -n 1 | sed "s/^Icon=//")
      echo [$name]
      echo "command=gtk-launch \"$name\""
      echo "icon=$icon"
      echo "subtext=gtk-launch: $name"
      ;;

    *)
      name="$(basename "$FILE")"
      echo [$name]
      echo "command=$term -x sh -c \"$FILE $last; bash\""
      echo "icon="
      echo "subtext=$term -x sh -c \"$FILE $last; bash\""
      ;;
  esac
done < <(find $folders -ignore_readdir_race -maxdepth 1 -type f -iname "${first}*")


