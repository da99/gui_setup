
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

  cache_setup ensure

  local +x DCOLOR="#8f8f8f"
  local +x ALERT_COLOR="#f1f442"

  # === Media:
  get_media_line () {
    local +x MIN="$(date '+%M')"

    local +x IFS=$'\n'
    for LINE in $(cat ../cache_setup/progs/media-titles.txt || :); do
      local +x NAME="$(echo "$LINE" | cut -d'|' -f1)"
      local +x TITLE="$(echo "$LINE" | cut -d'|' -f3 | sh_string summarize 35)"
      echo -n "  "%{F$DCOLOR}${NAME/channel-/c-}:%{F-}$TITLE
    done

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
          FINAL_LIST="$ID $TITLE\n${FINAL_LIST}"
          continue
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




