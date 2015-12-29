#!/usr/bin/env bash


export PATH="/apps/gui_setup/bin:$PATH"
escape () {
  val="$@"
  val="${val//\{/}"
  echo "${val//\}/}"
}

to_cmd () {
  name="$(escape $(echo "$@" | cut -d'|' -f1))"
  icon="$(escape $(echo "$@" | cut -d'|' -f2))"
  comment="$(escape $(echo "$@" | cut -d'|' -f4-))"
  exec="$(escape $(echo "$@" | cut -d'|' -f3))"
  echo -n "{OPEN $name | $exec | "$comment" }"
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
  while read -r LINE
  do
    result="${result}$(to_cmd $LINE)"
  done < <(gui_setup select "$val")
  echo "$result"

done
