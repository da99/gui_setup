
# === {{CMD}}  a string with text and comma's
# === Returns 'a string with text and comma''s'
to-sql-string () {
  echo "'${@//"'"/"''"}'"
} # === end function
