" Pix'em
"
" This plugin helps you convert between em and px, for example in CSS stylesheets

if exists('g:loaded_vim_pixem')
  finish
endif
let g:loaded_vim_pixem = 1

let g:pixem_base_font_size = get(g:, 'pixem_base_font_size', 16)
let g:pixem_round_digits = get(g:, 'pixem_round_digits', 4)
let g:pixem_use_rem = get(g:, 'pixem_use_rem', 0)

command! Pixem call pixem#pixem()
