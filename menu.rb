#encoding: utf-8
# Set encoding or else problems sometimes
# occur with splitting window titles.


@app = Shoes.app do

  folders = "/home/da/.local/share/applications /apps/*/bin/  /usr/share/applications/ /progs/bin/ /progs/*/bin"
  @windows = `/apps/gui_setup/bin/gui_setup window_list`.split("\n")
  @files = @windows.dup
  @files.concat  `find #{folders} -ignore_readdir_race -maxdepth 1 -type f `.split("\n")
  str = ""

  @selects  = []
  @selected = -1
  @options  = nil
  @info     = nil
  @colors   = []


  def insert line
    @options.append {
      stack margin: [10, 4, 0, 0]  do
        is_window = @windows.include?(line)
        background(is_window ? slategray : gray)
        para(is_window ? "window: #{line}" : line)
      end # === stack
    }

    stack
  end

  def select move = :up
    old = @selected
    new = move == :up ? @selected - 1 : @selected + 1
    return if new < 0 || new > (@options.children.size - 1)

    @info.replace @colors.inspect
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

    background  white
    @info = para("Nothing yet")

    @options = stack do
    end # === stack of options

    # @windows.each { |line| insert line }

    keypress do |k|
      @app.exit if k == :escape

      if k == :up
        @info.replace("UP arrow")
        select(:up)
        return
      end

      if k == :down
        @info.replace("DOWN arrow")
        select(:down)
        return
      end

      @selected = -1
      (str = str[0, str.length-1]) if k == :backspace
      str << k if k.instance_of?(String)

      str.strip!
      results = str.empty? ? @windows : @files.grep(/#{Regexp.escape str}/i)

      new_stacks = []
      old_stacks = @options.children.dup
      results[0,20].each { |line|
        insert line
      }

      old_stacks.map(&:remove)

      @info.replace "#{str.inspect} (#{k.inspect}) (\#files: #{@files.size})was entered."
    end # === keypress

  end # == flow
end # === app
