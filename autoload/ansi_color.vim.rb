class AnsiColor
  COLORS_FG = {
    30=>:Black,
    31=>:Red,
    32=>:Green,
    33=>:Yellow,
    34=>:Blue,
    35=>:Magenta,
    36=>:Cyan,
    37=>:White,
    90=>:LightBlack,
    91=>:LightRed,
    92=>:LightGreen,
    93=>:LightYellow,
    94=>:LightBlue,
    95=>:LightMagenta,
    96=>:LightCyan,
    97=>:LightWhite,
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
    100=>:LightBlack,
    101=>:LightRed,
    102=>:LightGreen,
    103=>:LightYellow,
    104=>:LightBlue,
    105=>:LightMagenta,
    106=>:LightCyan,
    107=>:LightWhite,
  }

  def self.highlight!
    self.new.highlight!
  end

  def initialize
    @lineno = 1
    @colno = 1
    @index = 0
    @attr = []
    @chars = Vim.evaluate('getbufline("%", 1, "$")').join("\n").chars
    @last_char = nil
  end

  STATE_NONE = :STATE_NONE
  STATE_AFTER_ESCAPE = :STATE_AFTER_ESCAPE
  STATE_NUM = :STATE_BRACE

  def highlight!
    state = nil
    n = +''

    while shift
      case ch
      when "\e"
        unless state == STATE_NONE
          state = STATE_NONE
          next
        end
        state = STATE_AFTER_ESCAPE
      when "["
        unless state == STATE_AFTER_ESCAPE
          state = STATE_NONE
          next
        end
        state = STATE_BRACE
        n = +''
      when /\d/
        unless state == STATE_NUM
          state = STATE_NONE
          next
        end
        n << ch
      when ';'
        unless state == STATE_NUM
          state = STATE_NONE
          next
        end
        attr << n.to_i
      when 'm'
        unless state == STATE_NUM
          state = STATE_NONE
          next
        end
        attr << n.to_i
      else
        state = nil
      end
    end
  end

  def ch
    @chars[@index]
  end

  def shift
    @index += 1
    return nil if @index == @chars.size
    @chars[@index].tap do |ch|
      @last_char = ch
      if ch == "\n"
        @lineno += 1
        @colno = 1
      else
        @colno += 1
      end
    end
  end
end
