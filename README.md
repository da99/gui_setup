
Colors
======
* http://projects.susielu.com/viz-palette


FFMpeg
=======

* https://github.com/leandromoreira/ffmpeg-libav-tutorial#intro

Emacs
==============
[http://www.zohaib.me/spacemacs-and-alchemist-to-make-elixir-of-immortality/](http://www.zohaib.me/spacemacs-and-alchemist-to-make-elixir-of-immortality/)

WMCTRL, XPYINFO
===============

    WIDTH=`xdpyinfo | grep 'dimensions:' | cut -f 2 -d ':' | cut -f 1 -d 'x'` && HALF=$(($WIDTH/2)) && wmctrl -r :ACTIVE: -b add,maximized_vert && wmctrl -r :ACTIVE: -e 0,0,0,$HALF,-1

    1) https://www.reddit.com/r/unixporn/comments/4nfb8f/how_do_i_get_rofi_window_switcher_to_only_show/
    2) http://askubuntu.com/questions/269574/wmctrl-focus-most-recent-window-of-an-app

Fonts
=====
* [https://www.reddit.com/r/archlinux/comments/3yqu5p/my_arch_linux_fonts_rendering_config_without/](https://www.reddit.com/r/archlinux/comments/3yqu5p/my_arch_linux_fonts_rendering_config_without/)


Logout of Session
======
* [https://bbs.archlinux.org/viewtopic.php?id=54069](https://bbs.archlinux.org/viewtopic.php?id=54069)
* [https://bbs.archlinux.org/viewtopic.php?id=73944](https://bbs.archlinux.org/viewtopic.php?id=73944)
* [Compiz Session](https://help.ubuntu.com/community/CompizStandalone)
* [Shutdown/Reboot](https://wiki.archlinux.org/index.php/Allow_users_to_shutdown)

Conky
=====

* [https://wiki.manjaro.org/index.php?title=Basic_Tips_for_conky](https://wiki.manjaro.org/index.php?title=Basic_Tips_for_conky)

Window Switching
================
* [https://github.com/richardgv/skippy-xd](https://github.com/richardgv/skippy-xd)
* [https://github.com/jotrk/x-choyce](https://github.com/jotrk/x-choyce)
* [https://code.google.com/p/superswitcher/](https://code.google.com/p/superswitcher/)

Window Propertoes and icons:
===========

* [http://crunchbang.org/forums/viewtopic.php?id=33673](http://crunchbang.org/forums/viewtopic.php?id=33673)

WMCTRL
======

* [Examples](http://www.techsupportalert.com/content/tips-and-tricks-linux-mint-after-installation.htm#Enable-Windows-7-Aero-Snap)
* [http://movingtofreedom.org/2010/08/10/arranging-windows-from-the-gnulinux-command-line-with-wmctrl/](http://movingtofreedom.org/2010/08/10/arranging-windows-from-the-gnulinux-command-line-with-wmctrl/)

wmutils
======

* [List of tutorial and movies](https://www.reddit.com/r/unixporn/comments/3b42zj/people_using_wmutils_how_do_you_use_it/)

Exiting Windows gracefully:
===========================
  * (Log out of xorg)[https://www.reddit.com/r/archlinux/comments/2b0sbs/whats_the_best_way_to_log_out_of_an_xorg_session/cj0pajj/]
  ```
    wmctrl -l | awk '{print $1}' | while read APP; do
      wmctrl -i -c $APP || echo "$APP not killed"
    done
  ```

