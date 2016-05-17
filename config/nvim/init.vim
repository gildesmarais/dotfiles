" Activate Syntax Highlight
syntax enable
" set default encoding to UTF-8
set encoding=utf-8

" Highlight search results
set hlsearch
" Incremental search, search as you type
set incsearch
" Ignore case when searching
set ignorecase smartcase
" Ignore case when searching lowercase
set smartcase

" Deactivate Wrapping
set nowrap
" Treat all numbers as decimal
set nrformats=
" I don't like Swapfiles
set noswapfile
" Don't make a backup before overwriting a file.
set nobackup
" And again.
set nowritebackup

" I prefer , to be the leader key
" let mapleader = ","

" show line numbers
set number
" MOAR colors
set t_Co=256
" Unselect the search result
map <Leader><Space> :noh<CR>
" nnoremap <esc> :noh<return><esc>
" Better buffer handling
set hidden
" highlight cursor position
set cursorline

" Use the clipboard of Mac OS
set clipboard=unnamed

" Enable mouse
set mouse=a
" Set the title of the iterm tab
set title

" no timeout, make switching modes easier
set timeoutlen=1000 ttimeoutlen=0

call plug#begin('~/.config/nvim/plugged')

" CtrlP: Full path fuzzy finder
Plug 'ctrlpvim/ctrlp.vim'

" Borrowed from @skwp
if executable('ag')
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command =
    \ 'ag %s --files-with-matches -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
else
  " Fall back to using git ls-files if Ag is not available
  let g:ctrlp_custom_ignore = '\.git$\|\.hg$\|\.svn$'
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others']
endif

" Nerdtree
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
let NERDTreeIgnore=['\.pyc$', '\.pyo$', '\.rbc$', '\.rbo$', '\.class$', '\.o$', '\~$']
noremap <C-n> :NERDTreeToggle<CR>
noremap <leader>n :NERDTreeToggle<CR>
" Git marker for nerdtree
Plug 'Xuyuanp/nerdtree-git-plugin'

" vim-rails <3
Plug 'tpope/vim-rails'

" Syntastic: Really great Syntax checker
Plug 'scrooloose/syntastic'
let g:syntastic_enable_signs=1
let g:syntastic_quiet_messages = {'level': 'warnings'}
let g:syntastic_auto_loc_list=2
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_check_on_open=1
let g:syntastic_error_symbol='🙀'
let g:syntastic_warning_symbol='😿'



" Color Theme
Plug 'chriskempson/vim-tomorrow-theme'
" --- End ---
call plug#end()

colorscheme Tomorrow-Night-Bright
set background=dark
