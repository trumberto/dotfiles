let mapleader=","
set autoindent 
set autowrite 
set showmatch 
set wrapmargin=0 
set report=1 
set ruler
"syntax highlighting
syn on
""backspace?
"set bs=2
set sm
set softtabstop=4
"set tabstop=4
set shiftwidth=4
set expandtab
set wmh=0
set showcmd
"set cindent
"highlight searched pattern
set hls
"incremental search
set incsearch
set smartcase
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

set matchpairs=(:),[:],{:},<:>

set completeopt=menuone,longest,preview

map <F9> :w!<CR>:!aspell -e -c %<CR>:e %<CR>
"try this, should be quicker to move between splits
map <C-J> <C-W>j 
map <C-K> <C-W>k
map <C-H> <C-W>h
map <C-L> <C-W>l

" if I press gf on filename, new file is open in split...
map gf :new <cfile><CR>

" to be able to browse man pages in vim
runtime ftplugin/man.vim
runtime! macros/matchit.vim

augroup csyntax
    autocmd!
    autocmd BufNewFile,BufNew,BufRead *.cpp,*.c syn region myFold start="{" end="}" transparent fold
    autocmd BufNewFile,BufNew,BufRead *.cpp,*.c syn sync fromstart
    autocmd BufNewFile,BufNew,BufRead *.cpp,*.c set foldmethod=syntax
augroup END

augroup python
    autocmd!
    autocmd FileType python set omnifunc=pythoncomplete#Complete
    autocmd Filetype python set foldmethod=indent    
    autocmd Filetype python set foldlevel=0    
    " START pydoc plugin setup
    "au FileType python,man map <buffer> <leader>pw :call ShowPyDoc('<C-R><C-W>', 1)<CR>
    au FileType python,man map <buffer> <leader>pw :let save_isk = &iskeyword \|
        \ set iskeyword+=. \|
        \ call ShowPyDoc('<C-R><C-W>', 1)<CR> \|
        \ let &iskeyword = save_isk<CR>
    au FileType python,man map <buffer> <leader>pW :call ShowPyDoc('<C-R><C-A>', 1)<CR>
    au FileType python,man map <buffer> <leader>pk :call ShowPyDoc('<C-R><C-W>', 0)<CR>
    au FileType python,man map <buffer> <leader>pK :call ShowPyDoc('<C-R><C-A>', 0)<CR>
    " END pydoc plugin setup
augroup END

let g:SuperTabDefaultCompletionType = "context"

" allow me quit man pages with 'q' as in standard man browser
autocmd FileType man map q :q<CR>
autocmd FileType man set foldlevel=99

" close all folds on start
autocmd FileType vo_base set foldlevel=0

" plugin loading
filetype off
call pathogen#infect()
call pathogen#runtime_append_all_bundles()
filetype plugin indent on

set background=dark
colorscheme solarized
"colorscheme elflord
