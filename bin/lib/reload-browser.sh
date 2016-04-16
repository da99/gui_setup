
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
      mksh_setup BOLD "=== Reloading: {{$(echo "$WINDOWS" | grep $(printf 0x0%x $WIN_ID) || echo "[unknown window]")}}"
      xdotool windowfocus --sync $WIN_ID  key --clearmodifiers --delay 0 'F5'
    done

    xdotool windowfocus --sync $this_window

} # === end function


