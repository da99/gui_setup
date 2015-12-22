#!/bin/bash
orig="$@"
first="$1"
last=""
shift
if [[ -n "$@" ]]; then
  last="$@"
fi

set -u -e -o pipefail

desktops="/usr/share/applications/ $HOME/.local/share/applications"
apps="/apps/*/bin/ /progs/bin/ /progs/*/bin"
files=""
pattern=$(echo "$orig" | sed 's/[[:blank:]]//g; s/\(.\)/\1{1}[^\/]*/g')

counter=1
while read -r FILE
do
  [ "$counter" -ge 10 ] && break
  files="$files\n$FILE"
done < <(find $desktops $apps -ignore_readdir_race -type f -iname "${first}*" 2>/dev/null)

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
      # echo "command=$TERM --command \"$FILE $@\""
      term=$(which urxvt gnome-terminal $TERM 2>/dev/null | tail -n 1)
      echo "command=$term -x sh -c \"$FILE $last; bash\""
      echo "icon="
      echo "subtext=$term -x sh -c \"$FILE $last; bash\""
      ;;
  esac
done < <(echo -e "$files" | grep -v --extended-regexp "^[[:blank:]]*$" | uniq | head -n 10)


