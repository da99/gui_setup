#!/usr/bin/env bash


files="$(find ~/.local/share/applications/ /usr/share/applications/ -type f -iname '*.desktop')"
# names=$(echo -e "$files" | xargs -I f basename f .desktop)
# pair="$(paste <() <() --delimiter)"
LAST=""

to_cmd () {
  local full=$1
  local base=$(basename $full .desktop)
  echo -n "{OPEN $base | launch $full | OPEN the file using the desktop. }"
}

echo "" > /tmp/lighthouse.cmd.log
result="$files"
last=""
while true; do
  read -t 0.3 -s VAL && val="$VAL"
  read -t 0.1 -s VAL && val="$VAL"
  read -t 0.1 -s VAL && val="$VAL"

  if [[ -z "$val" ]]; then
    echo "{empty! empty | echo nothing }"
    continue
  fi

  if [[ "$last" == "$val" ]]; then
    continue
  fi

  last="$val"
  echo "$val" >> /tmp/lighthouse.cmd.log
  result=""
  while read LINE
  do
    result="${result}{echo! $(basename $LINE) | echo $val | you put: $val}"
  done < <(echo "$files" | sed -nr "/$val/p" | head -n 10)
  echo "$result"

done
