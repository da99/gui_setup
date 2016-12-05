
# === {{CMD}}
close-windows () {
for WIN_ID in $(wmctrl -l | cut -d' ' -f1) ; do
    wmctrl -i -c "$WIN_ID" || echo "$APP not killed"
  done
} # === end function
