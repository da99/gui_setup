
source "$THIS_DIR/bin/public/icy-title/_.sh"
source "$THIS_DIR/../dawin/bin/public/window-entry-to-title/_.sh"

# === {{CMD}}
console () {
  local +x KEEP_RUNNING="/tmp/gui-console-keep-running"

  if [[ "$@" == "exit" ]]; then
    rm -f "$KEEP_RUNNING"
    killall lemonbar || :
    return $?
  fi

  # sleep 2
  PATH="$PATH:$THIS_DIR/../sh_string/bin"
  PATH="$PATH:$THIS_DIR/../dawin/bin"
  PATH="$PATH:$THIS_DIR/../cache_setup/bin"
  PATH="$PATH:$THIS_DIR/../process/bin"
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

  cache_setup ensure

  local +x DCOLOR="#8f8f8f"
  local +x ALERT_COLOR="#f1f442"

  # === Media:
  get_media_line () {
    local +x MIN="$(date '+%M')"

    echo  -n "  "%{F$DCOLOR}C99:%{F-}    $(get icy-title "http://174.142.103.65:8060/;stream.nsv")
    echo  -n "  "%{F$DCOLOR}C101:%{F-}   $(get icy-title "http://46.166.162.26:8017/;stream.nsv")
    echo  -n "  "%{F$DCOLOR}LOTDG:%{F-}  $(get icy-title "http://65.60.19.42:8380")
    echo  -n "  "%{F$DCOLOR}Q77:%{F-}    $(get icy-title "http://98.168.140.157:8777/;stream.nsv")
    echo  -n "  "%{F$DCOLOR}ASI:%{F-}    $(get icy-title "http://38.96.148.18:6490/;stream.nsv")
    echo  -n "  "%{F$DCOLOR}NHK:%{F-}    $(get nhk-title)
    echo ""
    #   # This are not working for now:
    #   # echo -n "%{r}$(get vlc-title)"
  }

  touch "$KEEP_RUNNING"

  (
    while [[ -f "$KEEP_RUNNING" ]]; do
      get_media_line
      sleep 3
    done | lemonbar -b -p -n daBar_Media
  ) &

  # === Top bar:
  get-window-titles () {
    local +x IFS=$'\n'
    local +x META=""
    local +x WINDOWS="$(dawin list-windows)"

    local +x FINAL_LIST=""

    for WIN in $WINDOWS; do
      IFS=$' \t\n'
      set $WIN
      IFS=$'\n'

      local +x FULL="$8"
      local +x ID="${WIN%% *}"
      local +x TITLE="$(window-entry-to-title "$WIN")"
      local +x STATE="$(xprop -id "$ID" WM_CLASS _NET_WM_STATE _NET_WM_WINDOW_TYPE 2>/dev/null || :)"

      if [[ -z "$STATE" ]]; then # window has been closed.
        continue
      fi

      if [[ "$STATE" == *"_NET_WM_STATE_ABOVE"* ]] ; then
        META="$META| $TITLE = ABOVE |"
      fi

      case "$FULL $STATE" in
        *'"file_progress", "Caja"'*|*"_NET_WM_STATE_DEMANDS_ATTENTION"*|*"_NET_WM_STATE_MODAL"*|*"_NET_WM_WINDOW_TYPE_DIALOG"*)
          META="$META| $TITLE = ALERT |"
          if [[ "$FINAL_LIST" == *"$ID $TITLE"* ]]; then
            continue
          fi
          ;;
        *"_NET_WM_STATE_HIDDEN"*)
          META="$META| $TITLE = HIDDEN |"
          ;;
      esac

      FINAL_LIST="$FINAL_LIST\n$ID $TITLE"
    done # === for WIN

    local +x DONE=""

    for WIN in $(echo -e "$FINAL_LIST"); do
      IFS=$' \t\n'
      set $WIN
      IFS=$'\n'
      local +x ID="$1"
      local +x TITLE="$2"
      local +x FINAL="$TITLE"

      if [[ "$DONE" == *" $TITLE = DONE "* ]]; then
        continue
      fi

      if [[ "$META" == *" $TITLE = ABOVE "* ]]; then
        FINAL="*$FINAL"
      fi

      case "$META" in
        *" $TITLE = ALERT "*)
          FINAL="%{F${ALERT_COLOR}}$FINAL%{F-}"
          FINAL="%{A:unhide $ID:}$FINAL%{A}"
          ;;
        *" $TITLE = HIDDEN "*)
          FINAL="%{F$DCOLOR}$FINAL%{F-}"
          FINAL="%{A:unhide $ID:}$FINAL%{A}"
          ;;
        *)
          FINAL="%{A:hide $ID:}$FINAL%{A}"
          ;;
      esac

      echo -n " $FINAL "
      DONE="$DONE| $TITLE = DONE |"
    done # === for WIN

    echo ""
  }

  get-line () {
    echo "  $(date "+%a %b %d, %r")   $(get-window-titles) %{r}$(process volume graph)   "
    # echo -n '%{r}'
    # {
    #   paradise internet-activity | awk '{if (NR == 1) printf "%s",$0; else printf "  %s  ",$0;}';
    # } || echo -n '[unknown internet activity]'

    # # echo -n "CPU: $(process cpu-usage | tr '\n' ' ')  "
    # echo ""
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
  while [[ -f "$KEEP_RUNNING" ]]; do
    get-line
  done | lemonbar -p -n daBar_Top | while true; do
    run_command
  done
  return 0


} # === end function

get () {
  local +x FUNC="$@"
  case "$FUNC" in

    vlc-*)
      echo -n $($FUNC)
      ;;

    *)
      local +x TITLE="$($FUNC | sh_string summarize 40 || :)"
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

