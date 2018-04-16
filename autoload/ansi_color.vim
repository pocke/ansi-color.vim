let s:self_path=expand("<sfile>")
execute 'ruby require "' . s:self_path . '.rb"'

function! ansi_color#colorize() abort
  ruby AnsiColor.highlight!
endfunction
