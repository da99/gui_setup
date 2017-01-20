



# === {{CMD}}
console () {

  # sleep 2
  PATH="$PATH:$THIS_DIR/../sh_string/bin"
  PATH="$PATH:$THIS_DIR/../dawin/bin"
  PATH="$PATH:$THIS_DIR/../cache_setup/bin"
  # PATH="$PATH:$THIS_DIR/../paradise/bin"

  echo "PID: $$"

  # PATH="$PATH:/progs/wmutils/bin"
  local +x COUNTER=0

  if ! type lemonbar &>/dev/null ; then
    echo "!!! Install lemonbar." >&2
    exit 1
  fi

  if ! type dawin &>/dev/null ; then
    echo "!!! Install dawin." >&2
    exit 1
  fi

  if ! type curl &>/dev/null; then
    echo "!!! Install curl." >&2
    exit 1
  fi

  if ! type lynx &>/dev/null; then
    echo "!!! Install lynx."
    exit 1
  fi

  cache_setup ensure-setup

  local +x DCOLOR="#8f8f8f"

  # === Media:
  get_media_line () {
    local +x MIN="$(date '+%M')"

    echo  -n "  "%{F$DCOLOR}C99:%{F-}    $(get channel99-title)
    echo  -n "  "%{F$DCOLOR}C101:%{F-}   $(get channel101-title)
    echo  -n "  "%{F$DCOLOR}LOTDG:%{F-}  $(get lotdg-title)
    echo  -n "  "%{F$DCOLOR}Q77:%{F-}    $(get q77-title)
    echo  -n "  "%{F$DCOLOR}ASI:%{F-}    $(get asi-title)
    echo  -n "  "%{F$DCOLOR}NHK:%{F-}    $(get nhk-title)
    echo ""
    #   # This are not working for now:
    #   # echo -n "%{r}$(get vlc-title)"
  }

  (
    while true; do
      get_media_line
      sleep 3
    done | lemonbar -b -p -n daMediaStatus
  ) &

  desktop-to-title () {
    local +x FILE="$1"; shift

    if [[ -z "$FILE" ]]; then
      echo "[unknown]"
      return 0
    fi

    local +x KEY="$(basename "$FILE" .desktop)"
    local +x TITLE="$(cache_setup read-or-empty "$KEY")"
    if [[ -z "$TITLE" ]]; then
      local +x TITLE="$(grep "Name=" "$FILE" | head -n 1 | cut -d'=' -f2-)"
      cache_setup write "$KEY" "$TITLE"
    fi
    echo "$TITLE"
  }

  # === Top bar:
  get_window_titles () {
    local +x IFS=$'\n'
    for WIN in $(dawin list-desktop-entrys); do
      local +x ID="$(echo $WIN | cut -d' ' -f1)"
      local +x DESKTOP="$(echo $WIN | cut -d' ' -f2)"

      local +x TITLE="$(desktop-to-title "$DESKTOP")"
      local +x STATE="$(xprop -id "$ID" _NET_WM_STATE || :)"

      if [[ "$STATE" == *"_NET_WM_STATE_ABOVE"* ]] ; then
        TITLE="*$TITLE"
      fi

      if [[ "$STATE" == *"_NET_WM_STATE_HIDDEN"* ]] ; then
        TITLE="%{F$DCOLOR}$TITLE%{F-}"
        TITLE="%{A:unhide $ID:}$TITLE%{A}"
      else
        TITLE="%{A:hide $ID:}$TITLE%{A}"
      fi

      echo -n " $TITLE "
    done
    echo ""
  }

  get_line () {
    echo "  "$(date "+%a %b %d, %r")"   $(get_window_titles)"
    # echo -n '%{r}'
    # {
    #   paradise internet-activity | awk '{if (NR == 1) printf "%s",$0; else printf "  %s  ",$0;}';
    # } || echo -n '[unknown internet activity]'

    # # echo -n "CPU: $(process cpu-usage | tr '\n' ' ')  "
    # echo "$(paradise volume graph)   "
    # # No sleep necessary because 'paradise internet-activity' sleeps.
  }

  run_command () {
    local +x IFS=$'\n'
    read -r LINE
    case "$LINE" in
      "unhide 0x"*)
        wmctrl -i -a $(echo $LINE | cut -d' ' -f2)
        ;;
      "hide 0x"*)
        wmctrl -i -r $(echo $LINE | cut -d' ' -f2) -b add,hidden
        ;;
      *)
        echo "!!! Unknown command: $LINE" >&2
        ;;
    esac
  }


  # === Top bar:
  while true ; do
    get_line
  done | lemonbar -p -n daTopStatus | while true; do
    run_command
  done
  return 0

  # while read -r CMD ; do
  #   case "$CMD" in
  #     "0x"*)
  #       local +x ID="$CMD"
  #       echo "=== focusing: $ID" >&2
  #       wmctrl -i -a "$ID" || echo "=== error: $ID" >&2
  #       ;;
  #     *)
  #       echo "=== Ignoring: $CMD" >&2
  #       ;;
  #   esac
  # done


} # === end function

get () {
  local +x FUNC="$1"; shift
  case "$FUNC" in

    vlc-*)
      echo -n $($FUNC)
      ;;

    *)
      local +x TITLE="$($FUNC | sh_string summarize 30 || :)"
      if [[ -z "$TITLE" ]]; then
        echo -n "[error]"
      else
        echo -n $TITLE
      fi
      ;;
  esac
}

if-stale () {
  local +x SECOND="$(date '+%S' | grep -Pzo '\A0?\K.+' )"

  case "$SECOND" in
    0|3|5|10|15|20|50)
      return 0
		;;
    *)
      return 1
			;;
	esac
}

icy-title () {
  local +x URL="$1"; shift


  local +x TITLE="$((curl -H 'icy-metadata: 1' "$URL"  -s || echo "[down]") | head -c 34000 | grep --text -Pzo "(?s)(StreamTitle='\K(.*)(?=';Stream))|down|(4|5)\d\d Service \w" )"

  case "$TITLE" in
    *" Service "*)
      echo "[down]"
      ;;
    "")
      echo "[empty]"
      ;;
    *)
      echo "$TITLE"
      ;;
  esac
}

asi-title () {
  icy-title "http://38.96.148.18:6490/;stream.nsv"
}

q77-title () {
  icy-title "http://98.168.140.157:8777/;stream.nsv"
}

channel101-title () {
  icy-title "http://46.166.162.26:8017/;stream.nsv"
}

channel99-title () {
  icy-title "http://174.142.103.65:8060/;stream.nsv"
}

lotdg-title () {
  icy-title "http://65.60.19.42:8380"
}

nhk-title () {
  local +x URL="https://api.nhk.or.jp/nhkworld/epg/v6/world/now.json?apikey=EJfK8jdS57GqlupFgAfAAwr573q01y6k"

  local +x JSON="$( { curl --ssl -s "$URL" | gzip -d -c 2>/dev/null; } || curl --ssl -s "$URL" )"

  if [[ -z "$JSON" ]]; then
    return 1
  fi

  local +x NHK_TITLE="$( echo "$JSON" |  python -c "import sys, json; sys.stdout.write( json.load(sys.stdin)['channel']['item'][0]['title'] )"  || :)"

  if [[ -z "$NHK_TITLE" ]]; then
    return 1
  fi

  if [[ "$NHK_TITLE" != "NHK NEWSLINE" ]]; then
    echo $NHK_TITLE
    return 0
  fi

  echo "[NEXT] $( echo "$JSON" |  python -c "import sys, json; sys.stdout.write( json.load(sys.stdin)['channel']['item'][1]['title'] )" )"
}

