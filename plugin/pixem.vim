" Pix'em
"
" This plugin helps you convert between em and px in CSS stylesheets
" font-size: 14px;
" padding: 2em 1.4em; 14

" if exists('g:loaded_vim_pixem')
"   finish
" endif
" let g:loaded_vim_pixem = 1

let g:pixem_base_font_size = get(g:, 'pixem_base_font_size', 16)
let g:pixem_round_digits = get(g:, 'pixem_round_digits', 4)

command! Pixem call pixem#pixem()
