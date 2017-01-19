

source "$THIS_DIR/bin/public/vlc-title/_.sh"

# === {{CMD}}
gui-console () {

  sleep 2
  PATH="$PATH:$THIS_DIR/../sh_string/bin"
  PATH="$PATH:$THIS_DIR/../dawm/bin"

  if [[ "$@" == "quit" ]]; then

    local +x ME=$$
    local +x PID=$(pgrep -f "/paradise gui-console" | grep -v "$ME" | head -n 1)

    local +x IFS=$'\n'

    for GROUP in $(pgrep -f "/paradise gui-console" | xargs -I ID pstree -a -A  -p -g ID | grep -P '^[^[:space:]].+paradise[[:space:]]+gui-console$' | cut -d',' -f3 | cut -d' ' -f1 | uniq ) ; do
      kill -SIGINT -- -"$GROUP" || echo '!!! Group not killed: '$GROUP
    done

    return 0

  fi

  close-all () {
    echo "=== Closing gui-console: $$, Previous exit code: $?" >&2
    exit 0
  }
  trap 'close-all' SIGINT SIGTERM ERR


  echo $$
  PATH="$PATH:/progs/wmutils/bin"
  local +x COUNTER=0

  if ! type lemonbar &>/dev/null ; then
    echo "!!! Install lemonbar."
  fi

  if ! type dawm &>/dev/null ; then
    echo "!!! Install dawm."
  fi

  if ! type curl &>/dev/null; then
    echo "!!! Install curl."
  fi

  if ! type lynx &>/dev/null; then
    echo "!!! Install lynx."
  fi

  # === Top bar:
  while true ; do
    local +x CURR_WIN_ID="$(pfw 2>/dev/null || :)"
    echo -n "  "$(date "+%a %b %d, %r")
    if [[ -z "$CURR_WIN_ID" ]]; then
      echo -n "[no window]"
    else
      echo -n "   %{c}$( dawm titles | grep "$CURR_WIN_ID" | head -n 1 | cut -d' ' -f2-)"
    fi

    echo -n '%{r}'

    {
      paradise internet-activity | awk '{if (NR == 1) printf "%s",$0; else printf "  %s  ",$0;}';
    } || echo -n '[unknown internet activity]'

    # echo -n "CPU: $(process cpu-usage | tr '\n' ' ')  "
    echo "$(paradise volume graph)   "
    # No sleep necessary because 'paradise internet-activity' sleeps for 1 second.
  done | lemonbar -d -p -n daBottomStatus &

  # done | lemonbar -d -p -n daConsole -g "$((  $(wattr w $(lsw -r))  - 160 ))x18+160+0"

  # === Media:
  while true; do
    local +x MIN="$(date '+%M')"

    echo  -n "  NHK: $(get nhk-title)"
    echo  -n "  *C99: $(get channel99-title)"
    echo  -n "  *C101: $(get channel101-title)"
    echo  -n "  *LOTDG: $(get lotdg-title)"
    echo  -n "  *ASI: $(get asi-title)"

    # This are not working for now:
    # echo  -n "  *Q77: $(get q77-title)"
    # echo -n "%{r}$(get vlc-title)"
    echo ""
    sleep 5
  done | lemonbar -b -d -p -n daConsole # -g "$((  $(wattr w $(lsw -r))  - 160 ))x18+160+0"

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

  local +x TITLE="$(curl -H 'icy-metadata: 1' "$URL"  -s | head -c 34000 | grep --text -Pzo "(?s)StreamTitle='\K(.*)(?=';Stream)" || : )"

  if [[ -z "$TITLE" ]]; then
    echo "[unknown]"
  else
    echo "$TITLE"
  fi
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

