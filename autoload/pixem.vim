function! s:run_conversion(match) abort
  " strip 'px' or 'em'
  let stripped = matchstr(a:match, '.*\(em\|px\)\@=')
  if match(a:match, 'px$') != -1
    let converted = string(s:pixel2em(stripped)) . 'em'
  elseif match(a:match, 'em$') != -1
    let converted = string(s:em2pixel(stripped)) .'px'
  endif

  return converted
endfunction

function! s:pixel2em(px_value) abort
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

function! s:em2pixel(em_value) abort
  let value = str2float(a:em_value)
  return float2nr(round(value * g:pixem_base_font_size))
endfunction

" TODO: add range (visual mode) support
function! pixem#pixem() abort
  let line_text = getline('.')
  let line_num = getcurpos()[1]
  let pattern = '[0-9]*\.\?[0-9]\+\(em\|px\)'

  let converted = substitute(line_text, pattern, '\=s:run_conversion(submatch(0))', 'g')
  call setline(line_num, converted)
endfunction
