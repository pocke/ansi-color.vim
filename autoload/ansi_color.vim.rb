require 'strscan'
require 'json'

class AnsiColor
  # color number -> Vim color name
  COLORS_FG = {
    30=>:Black,
    31=>:Red,
    32=>:Green,
    33=>:Yellow,
    34=>:Blue,
    35=>:Magenta,
    36=>:Cyan,
    37=>:White,
    90=>:Black,
    91=>:LightRed,
    92=>:LightGreen,
    93=>:LightYellow,
    94=>:LightBlue,
    95=>:LightMagenta,
    96=>:LightCyan,
    97=>:White,
  }
  COLORS_BG = {
    40=>:Black,
    41=>:Red,
    42=>:Green,
    43=>:Yellow,
    44=>:Blue,
    45=>:Magenta,
    46=>:Cyan,
    47=>:White,
    100=>:Black,
    101=>:LightRed,
    102=>:LightGreen,
    103=>:LightYellow,
    104=>:LightBlue,
    105=>:LightMagenta,
    106=>:LightCyan,
    107=>:White,
  }
  DECORATION = {
    1 => :bold,
    4 => :underline,
  }

  def self.highlight!
    # TODO: encoding
    text = Vim.evaluate('getbufline("%", 1, "$")').join("\n").force_encoding(Encoding::UTF_8)
    text, pos = self.new(text).highlight!
    Vim.command 'enew'
    Vim.command 'set buftype=nofile'
    Vim.command 'set filetype=ansi_color'
    lines = JSON.generate(text.split("\n"))
    Vim.evaluate "append(0, #{lines})"
    pos.each do |group, positions|
      positions.each_slice(8) do |p8|
        Vim.evaluate "matchaddpos(#{JSON.generate(group)}, #{JSON.generate(p8)})"
      end
    end
  end

  def initialize(text)
    @scanner = StringScanner.new(text)
    @lineno = 1
    @colno = 1
    @result_text = +""
    @attr = {}
    @matchpos = {}
    @start_col = nil
  end

  def highlight!
    loop do
      case
      when @scanner.scan(/\e\[0m/)
        clear
      when @scanner.scan(/\e\[(\d+(?:;\d+)*)m/)
        nums = @scanner[1].split(';').map(&:to_i)
        update_attr nums
      when @scanner.scan(/\n/)
        update_matchpos
        @start_col = 0
        @lineno += 1
        @colno = 1
        @result_text << "\n"
      when ch = @scanner.scan(/[^\e\n]+/)
        @colno += ch.size
        @result_text << ch
      when @scanner.eos?
        update_matchpos
        break
      end
    end

    return @result_text, @matchpos
  end

  def update_matchpos
    return if @attr.empty?
    (@matchpos[group_name] ||= []) << [@lineno, @start_col, @colno - @start_col]
  end

  def clear
    update_matchpos
    @attr = {}
  end

  def group_name
    "ansiColor_#{@attr[:fg]}_#{@attr[:bg]}_#{'bold' if @attr[:bold]}_#{'underline' if @attr[:underline]}"
  end

  def update_attr(nums)
    update_matchpos
    nums.each do |num|
      case
      when c = COLORS_FG[num]
        @attr[:fg] = c
      when c = COLORS_BG[num]
        @attr[:bg] = c
      when c = DECORATION[num]
        @attr[c] = true
      when num == 39
        @attr[:fg] = nil
      when num == 49
        @attr[:bg] = nil
      end
    end
    @start_col = @colno
  end
end
