function! pixem#pixem() abort
  let line_text = getline('.')
  let line_num = getcurpos()[1]

  " value includes 'px' or 'em'
  let value = pixem#find_value(line_text)
  if value ==# ""
    return
  endif

  " num_value strips 'px' or 'em'
  let num_value = matchstr(value, '.*\(em\|px\)\@=')

  if match(value, 'px$') != -1
    let converted = pixem#pixel2em(value)
    let converted_str = string(converted) . 'em'
  elseif match(value, 'em$') != -1
    let converted = pixem#em2pixel(value)
    let converted_str = string(converted) . 'px'
  endif

  let new_line_text = substitute(line_text, value, converted_str , '')
  call setline(line_num, new_line_text)

endfunction

" Search for a valid value in the current line
" TODO: if we have more than one value in the line...
function! pixem#find_value(line_text) abort
  return matchstr(a:line_text, '[0-9]*\.\?[0-9]\+\(em\|px\)')
endfunction

function! pixem#pixel2em(px_value) abort
  let value = str2float(a:px_value)
  let digits = g:pixem_round_digits
  let base_size = g:pixem_base_font_size
  let converted = value / base_size
  let rounded = round(converted * pow(10, digits)) / pow(10, digits)
  " Avoid getting a result like 2.0
  if rounded == float2nr(rounded)
    return float2nr(rounded)
  endif
    return rounded
endfunction

function! pixem#em2pixel(em_value) abort
  let value = str2float(a:em_value)
  return float2nr(round(value * g:pixem_base_font_size))
endfunction
