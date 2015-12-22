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
files=""
pattern=$(echo "$orig" | sed 's/[[:blank:]]//g; s/\(.\)/\1{1}[^\/]*/g')
files="$(find $desktops -type f -iname "${orig}*.desktop" | head -n 10)"

if [[ -n "$first" ]]; then # === find in path
  set +e +o pipefail +x
  files="$files\n$(find /apps/*/bin/ /progs/bin/ /progs/*/bin -ignore_readdir_race -type f -iname "*${first}*" 2>/dev/null | head -n 20 )"
  set -e -o pipefail +x
fi


files="$files\n$(find $desktops -type f -regextype posix-extended -regex "^.*/[^/]*$pattern\.desktop$" | head -n 10 | sort)"

while read -r FILE; do
  case $FILE in
    *.desktop)
      echo [$FILE]
      name=$(basename "$FILE" .desktop)
      icon=$(grep --extended-regexp "^Icon=" "$FILE" || echo "" | head -n 1 | sed "s/^Icon=//")
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


