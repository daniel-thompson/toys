"
" Daniel's .vimrc file
"
" All macros etc. published here can be considered to be in the public domain
"
" Please feel free to share any really cool modifications with me
" (daniel@redfelineninja.org.uk)
"

"
" Setup some really basic confort features
"

if has("syntax")
  syntax on
endif
set autoindent
set autowrite
set background=light
set backspace=1
set mousemodel=popup
set title

if has("gui_running")
set guifont=Monospace\ 9
endif

" Work around a bug in F19 (lilypond expects wrong vim version)
filetype off
set runtimepath+=/usr/share/vim/vim73/
filetype on

" treat C preprocessed assembler files as C
if has("autocmd")
  augroup filetype
    autocmd filetype BufRead,BufNewFile *.S set filetype=c
  augroup END
endif

" this does not actually use any auto commands but this function and its 
" friends are not compiled into all vim editors (think /bin/vi on some
" GNU/Linux systems) and I cannot find the correct string from the
" docs
if has("autocmd")

  function TabSize (size)
    exe 'set noexpandtab'
    exe 'set shiftwidth=' . a:size
    exe 'set softtabstop=' . a:size
    return "Tab size = " . a:size
  endfunction

  map ,t2   :echo TabSize(2)<CR>
  map ,t3   :echo TabSize(3)<CR>
  map ,t4   :echo TabSize(4)<CR>
  map ,t8   :echo TabSize(8)<CR>
  map ,tx   :%!expand -8<CR>

  " set up the default tab size of 8
  call TabSize(8)
endif

if has("folding")
  " by default we will use fold markers to perform folding...
  set foldmethod=marker

  " ... except for XML which has an intrinsic heirarchy
  let g:xml_syntax_folding=1
  au FileType xml setlocal foldmethod=syntax
endif

" Sort out faust syntax highlighting
"faust filetype file
augroup filetypedetect
  au! BufRead,BufNewFile *.dsp      set filetype=faust
  au! BufRead,BufNewFile *.lib      set filetype=faust
augroup END

" Cut text down to size (C-J does not pre-join the lines)
map <C-S-J> J74\|bi<CR><ESC>
map <C-J> 74\|bi<CR><ESC>

" get lookup the API top for the current function or open its man page
map <F1> :!grep -h <cword>\( /u/thompsond/public/share/*.api<CR>
map <S-F1> :!man <cword><CR>

" open the file under the cursor with path search (ie header file)
map <F2> gf
map <S-F2> :sp<CR>gf

" use F6 to jump into and out of hex editing
map <F6> :set binary<CR>:%!xxd -c 12 <CR>
map <S-F6> :%!xxd -c 12 -r<CR>

" control keys for use on make files
map <F5>   :cn<CR>
map <S-F5>   :cp<CR>
map <F7>   :!cleartool checkout %<CR>
map <S-F7> :!cleartool checkin %<CR>
map <F8>   :make %<CR>
map <F9>   :make<CR>
map <F10>  :make run<CR>
map <S-F10>  :make debug<CR>

" alter the behavior of F8 for java files (compile directly - don't use make)
if has("autocmd")
	augroup filetype
		au BufRead,BufNewFile *.java map <F8> :set mp=javac<CR>:make %<CR>:set mp=make<CR>
	augroup END
endif

" repeat the last command on the next line (F12 is Again on Sun keyboards)
map <F12> j.

" edit the .vimrc file
map ,v  :sp $HOME/.vimrc<CR>

" underscore based versions of vi's cw & dw
map cu c/_<CR>
map du d/_<CR>


"
" IDE workalike features
"

" Make sure https://github.com/Rip-Rip/clang_complete is installed...

set spell spelllang=en_gb "Enable inline spell checking"

" <Tab> and <S-Tab> indent and unindent code
map <Tab> :><CR>
map <S-Tab> :<<CR> 
imap <C-Space> <C-N>

" Mash a button to fix the indentation (this will override the normal
" indent behavior)
autocmd FileType c,cpp map <Tab> :pyf ~/.vim/bin/clang-format.py<CR>
autocmd FileType c,cpp map <S-Tab> :pyf ~/.vim/bin/clang-format.py<CR>
autocmd FileType c,cpp imap <S-Tab> <ESC>:pyf ~/.vim/bin/clang-format.py<CR>i
autocmd FileType c,cpp imap <C-Space> <C-X><C-U>

" comment/uncomment the current statement
autocmd FileType c,cpp,faust map // ^i/* <ESC>/;<CR>a */<ESC>
autocmd FileType c,cpp,faust map \\ bhh/ *[*][/]<CR>d/[/]<CR>x?[/][*]<CR>dw

