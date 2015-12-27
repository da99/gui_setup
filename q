#!/usr/bin/env bash
#
#
set -u -e -o pipefail

str=""
lines=0

while read -r -n 1 CHAR
do
  tput rc
  tput el
  if [[ "$CHAR" == "" || "$CHAR" == "z" ]]; then
    break
  fi

  while [ $lines -gt 0 ]
  do
    tput cuu1
    tput ed
    lines=$[$lines - 1]
  done
  str="${str}${CHAR}"
  echo $str
  lines=$[$lines + 1]
  echo /apps/${str}*
  lines=$[$lines + 1]
done
