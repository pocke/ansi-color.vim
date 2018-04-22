COLORS_FG = {
  Black: 30,
  Red: 31,
  Green: 32,
  Yellow: 33,
  Blue: 34,
  Magenta: 35,
  Cyan: 36,
  White: 37,

  #LightBlack: 90,
  LightRed: 91,
  LightGreen: 92,
  LightYellow: 93,
  LightBlue: 94,
  LightMagenta: 95,
  LightCyan: 96,
  #LightWhite: 97,
}

COLORS_BG = {
  Black: 40,
  Red: 41,
  Green: 42,
  Yellow: 43,
  Blue: 44,
  Magenta: 45,
  Cyan: 46,
  White: 47,

  #LightBlack: 100,
  LightRed: 101,
  LightGreen: 102,
  LightYellow: 103,
  LightBlue: 104,
  LightMagenta: 105,
  LightCyan: 106,
  #LightWhite: 107,
}

def hi(fg: nil, bg: nil, bold: false, underline: false)
  return "hi link ansiColor____ Default" if !fg && !bg && !bold && !underline
  cterm = []
  cterm << 'underline' if underline
  cterm << 'bold' if bold
  "hi ansiColor_#{fg}_#{bg}_#{'bold' if bold}_#{'underline' if underline} #{"ctermfg=#{fg}" if fg} #{"ctermbg=#{bg}" if bg} #{"cterm=#{cterm.join(",")}" unless cterm.empty?}"
end

puts hi(bold: true)
[*COLORS_FG.keys, nil].product([*COLORS_BG.keys, nil], [true, false], [true, false]).each do |fg, bg, bold, underline|
  puts hi(fg: fg, bg: bg, bold: bold, underline: underline).strip
end
