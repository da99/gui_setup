#!/usr/bin/env bash


export PATH="/apps/gui_setup/bin:$PATH"
escape () {
  val="$@"
  val="${val//\{/}"
  echo "${val//\}/}"
}

to_cmd () {
  name="$(escape $(echo "$@" | cut -f1))"
  icon="$(escape $(echo "$@" | cut -f2))"
  comment="$(escape $(echo "$@" | cut -f4- | tr  '|' ':' | tr '{' '[' | tr '}' ']'))"
  # exec="$(escape $(echo "$@" | cut -f3))"
  exec="/apps/gui_setup/bin/gui_setup activate_or_launch $name"
  title="OPEN $name"
  if [[ -n "$icon" ]]; then
    title="%I$icon% $title"
  fi
  echo "$@" 1>&2
  echo -n "{ $title | $exec | $comment }"
}

log="/tmp/lighthouse.cmd.log"
echo "" > "$log"


val=""
while true; do

  last="$val"
  while read -t 0.2 -s VAL; do
    val="$VAL"
  done

  if [[ -z "$val" ]]; then
    echo "{empty! empty | echo nothing }"
    continue
  fi

  if [[ "$last" == "$val" ]]; then
    continue
  fi

  echo "$val" >> "$log"


  result=""
  while read LINE
  do
    result="${result}$(to_cmd "$LINE")"
  done < <(gui_setup select "$val")
  echo "$result"

done
