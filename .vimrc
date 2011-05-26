set autoindent autowrite showmatch wrapmargin=0 report=1 ruler
"syntax highlighting
syn on
""backspace?
"set bs=2
set sm
"set softtabstop=4
"set tabstop=4
set shiftwidth=4
set expandtab
let maplocalleader = ","
set wmh=0
set showmatch
set showcmd
"set cindent
"highlight searched pattern
set hls
"incremental search
set incsearch
set smartcase
"Shift-Insert works like in terminal
"map <S-Insert> <MiddleMouse>
"map! <S-Insert> <MiddleMouse>
"
map <F9> :w!<CR>:!aspell -e -c %<CR>:e %<CR>

"try this, should be quicker to move between splits
map <C-J> <C-W>j<C-W>_ 
map <C-K> <C-W>k<C-W>_

" if I press gf on filename, new file is open in split...
map gf :new <cfile><CR>

" to be able to browse man pages in vim
runtime ftplugin/man.vim

"colorscheme elflord
set background=dark
"let g:solarized_termcolors=256
colorscheme solarized

" spell checking setup
" let spell_auto_type = "mail,otl"

augroup csyntax
    autocmd!
    autocmd BufNewFile,BufNew,BufRead *.cpp,*.c syn region myFold start="{" end="}" transparent fold
    autocmd BufNewFile,BufNew,BufRead *.cpp,*.c syn sync fromstart
    autocmd BufNewFile,BufNew,BufRead *.cpp,*.c set foldmethod=syntax
augroup END

" allow me quit man pages with 'q' as in standard man browser
autocmd FileType man map q :q<CR> 

" plugin loading
filetype plugin on
filetype indent on

" this tip is from here: http://dev.gentoo.org/~ciaranm/docs/vim-guide/
"set list
"set listchars=tab:>-,trail:.,extends:>

set laststatus=2
set statusline=
set statusline+=%-3.3n\                      " buffer number
set statusline+=%f\                          " filename
set statusline+=%h%m%r%w                     " status flags
set statusline+=\[%{strlen(&ft)?&ft:'none'}] " file type
set statusline+=%=                           " right align remainder
set statusline+=0x%-8B                       " character value
set statusline+=%-14(%l,%c%V%)               " line, character
set statusline+=%<%P                         " file position

set wildmenu
set wildignore=*.o,*.obj,*.class,*~

:runtime! macros/matchit.vim
 
" end of tip

hi mailHeaderKey  ctermfg=darkyellow
hi mailSubject    ctermfg=darkyellow
hi mailHeader     ctermfg=darkyellow
hi mailEmail      ctermfg=yellow
hi mailSignature  ctermfg=darkmagenta
hi mailQuoted1    ctermfg=darkcyan
hi mailQuoted2    ctermfg=darkgreen
hi mailQuoted3    ctermfg=darkmagenta
hi mailQuoted4    ctermfg=darkred
hi mailQuoted5    ctermfg=darkyellow
hi mailQuoted6    ctermfg=white

" vim sets encoding to utf8 no matter what
" this overrides the default
"set fileencodings=iso-8859-2
"set fenc=iso-8859-2
"set enc=iso-8859-2
"set tenc=iso-8859-2

"http://www.vim.org/tips/tip.php?tip_id=1126
"let &titlestring = hostname() . "[vim(" . expand("%:t") . ")]" 
"set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

"if &term == "screen" 
"  set t_ts=k 
"  set t_fs=\ 
"endif 

"if &term == "screen" || &term == "xterm" 
"  set title 
"endif
