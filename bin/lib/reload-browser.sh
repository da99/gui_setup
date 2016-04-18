
# === {{CMD}}
# === {{CMD}}  google-chrome|firefox|Title of window|...
reload-browser () {
    local +x this_window="$( xdotool getactivewindow )"

    if [[ -z "$@" ]]; then
      target="google-chrome|firefox"
    else
      target="$1"; shift
    fi

    win_id="$(sort <(xdotool search --all --onlyvisible --class "$target") <(xdotool search --all --onlyvisible --name "$target") | uniq | tail -n 1)"

    if [[ -z "$win_id" ]]; then
      echo "!!! Window not found" 1>&2
      return 1
    fi

    local +x WINDOWS="$($0 normal_window_info)"

    for WIN_ID in $win_id ; do
      local +x RELOAD="xdotool windowfocus --sync $WIN_ID  key --clearmodifiers F5"
      mksh_setup BOLD "=== Reloaded: $WIN_ID -> {{$(echo "$WINDOWS" | grep $(printf 0x0%x $WIN_ID) || echo "[unknown window]")}}"
      $RELOAD
      sleep 0.2 # If there is delay, the window will lose focus and the 'key press' (F5) may not be
                # passed on the window (ie racing issue between focusing and key press.)
    done

    xdotool windowfocus --sync $this_window

} # === end function


