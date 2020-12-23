# Pix'em
This is my first vim plugin. Not terribly useful but a good way to learn some basic Vimscript.
## What it does
Convers between px and em values, for example in css stylesheets.
## How to install it
If you use vim-plug simply drop this line into your vimrc, or do the equivalent thing for your plugin manager of choice:
```
Plug 'gadkadosh/vim-pixem'
```
## How to use it
Running the Ex command 
```
:Pixem
```
will search for the first valid value on the line where the cursor is currently at, convert it from px to em or vice versa and suggests the value.
## How to configure it
Set `g:pixem_base_font_size` to the base px value for the conversion. (Default: 16)  
Set `g:pixem_round_digits` to the number of digits values should be rounded to (em values). (Default: 4)
### Mapping
The plugin does not set a mapping for you. You can add a mapping to your vimrc to your liking, for example:
```
nnoremap <Leader>p :Pixem<CR>
```
## TODO
1. Automatically convert the value for you instead of suggesting only.
2. Work out the edge case of having more than one valid value on the current line.
## Inspiration
I got the idea from https://youtu.be/jKBOhH6EZRg and his plugin https://github.com/joedbenjamin/pixelemconverter
