#encoding: utf-8
# Set encoding or else problems sometimes
# occur with splitting window titles.


TYPE      = 0
TITLE     = 1
CMD       = 2
COLOR     = 3
ICON      = 4
SEARCH_STR= 5
ELEMENT   = 6

@app = Shoes.app do
  begin
    dir=File.read("/apps/gui_setup/tmp/temp_dir").strip
    @windows = `/apps/gui_setup/bin/gui_setup window_list`.strip!.each_line.map { |line|
      line.strip!
      line[/([^\s]+)\s+([^\s]+)\s+(.+)/]
      icon=$1
      id=$2
      title=($3 || '[No title]').strip[0,30]
      [:window, "window: #{title}", "wmctrl -i -a #{id}", slategray, icon, $3]
    }

    @desktops = File.read("#{dir}/desktops").each_line.map { |line|
      line.strip!
      cmd = "gtk-launch \"#{line}\""
      basename = File.basename(line, '.desktop')
      [:desktop, "desktop: #{line}", cmd, gray, "#{dir}/#{basename}.png", basename]
    }

    @files = File.read("#{dir}/files").each_line.map { |line|
      line.strip!
      cmd = line
      [:run, "run: #{line}", cmd, gray, nil, File.basename(line)]
    }

    str = ""

    @selects  = []
    @selected = -1
    @options  = nil
    @info     = nil
    @colors   = []

    def get_icon line
      case line[TYPE]
      when :window
      else
        nil
      end
    end

    def insert line
      return line[ELEMENT].show if line[ELEMENT]

      @options.append {
        line[ELEMENT]= flow margin: [10, 4, 0, 0]  do
          background(line[COLOR])
          icon = line[ICON]
          if icon
            image(icon).style(height: 24, width: 24)
          end
          para(line[TITLE])
          para(line[CMD])
        end # === stack
      }

      stack
    end

    def select move = :up
      old = @selected
      new = move == :up ? @selected - 1 : @selected + 1
      return if new < 0 || new > (@options.children.size - 1)

      if @selected > -1 # === deselect
        e = @options.children[old]
        bg = e.children.first
        bg.remove
        e.prepend {
          background(@colors.pop || black)
        }
      end

      e = @options.children[new]
      bg = e.children.first
      @colors << bg.fill
      bg.remove

      e.prepend do
        background orange
      end
      @selected = new
    end

    flow do

      background  lightyellow
      @info = para("[waiting]")

      @options = stack do
      end # === stack of options

      @windows[0,20].each { |line| insert(line) }
      select :down

      keypress do |k|
        @app.exit if k == :escape

        if k == :up || k == :shift_tab
          @info.replace("UP arrow")
          select(:up)
          return
        end

        if k == :down || k == :tab
          @info.replace("DOWN arrow")
          select(:down)
          return
        end

        if k == :backspace
          str = str[0, str.length-1]
        else
          if !k.instance_of?(String)
            @info.replace k.inspect
            return
          end
          if k == "\n" && @selected > -1
            system @options.children[@selected].children.last.contents.first
            @app.exit
            return
          end
          str << k
        end

        @selected = -1

        str.strip!
        @info.replace "#{str} (#{k.inspect})"

        pattern = /#{Regexp.escape str}/i
        results = case
                  when str.empty?
                    @windows.dup
                  else
                    []
                    .concat(@windows.select { |line| line[SEARCH_STR].match pattern })
                    .concat(@desktops.select { |line| line[SEARCH_STR].match pattern })
                    .concat(@files.select { |line| line[SEARCH_STR].match pattern })
                  end

        @options.children.map(&:hide)
        results[0,20].each { |line|
          insert line
        }

        select :down

      end # === keypress

    end # == flow
  rescue Object => e
    stack do
      para e.message.inspect
      e.backtrace[0,10].each { |line|
        para line
      }
    end
  end
end # === app
