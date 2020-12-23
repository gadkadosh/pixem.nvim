function! pixem#pixem() abort
  let l:cursor_word = pixem#get_cursor_word()
  if l:cursor_word ==# ""
    return
  endif

  let l:value = matchstr(l:cursor_word, '\([0-9]*[.]\)\?[0-9]\+\(em\|px\)\@=')

  if match(l:cursor_word, 'px$') != -1
    let l:converted = pixem#pixel2em(l:value)
    echo l:value . 'px' . ' converts to: ' . string(l:converted) . 'px'
  elseif match(l:cursor_word, 'em$') != -1
    let l:converted = pixem#em2pixel(l:value)
    echo l:value . 'em' . ' converts to: ' . l:converted . 'px'
  endif

endfunction

" Search for a valid value in the line we stand on
" TODO: if we have more than one value in the line...
function! pixem#get_cursor_word() abort
  let line_text = getline('.')
  return matchstr(line_text, '\([0-9]*[.]\)\?[0-9]\+\(em\|px\)')
endfunction

function! pixem#pixel2em(px_value) abort
  let value = str2float(a:px_value)
  let digits = g:pixem_round_digits
  let base_size = g:pixem_base_font_size
  return round(value * (pow(10, digits)) / base_size) / pow(10, digits)
endfunction

function! pixem#em2pixel(em_value) abort
  let value = str2float(a:em_value)
  return float2nr(round(value * g:pixem_base_font_size))
endfunction
