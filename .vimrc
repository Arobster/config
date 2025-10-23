" Remapping
:let mapleader = ","
inoremap kj <Esc>
noremap <SPACE> <C-F>
nnoremap <Leader>b :buffers<CR>:buffer<Space>

filetype plugin indent on

syntax on
"syntax enable

set number
set ruler
set nowrap
set noswapfile
set expandtab
set autoindent
set smartindent
set shiftwidth=2
set tabstop=2
set softtabstop=2
set smarttab
set ignorecase
set clipboard=unnamedplus
set hlsearch

" Color Scheme (options: blue,darkblue,default,delek,desert,elflord,evening,industry,koehler,morning,murphy,pablo,peachpuff,ron,shine,slate,torte,zellner)
colorscheme elflord

" Show diffs vertically
set diffopt+=vertical

autocmd FileType python,yml,yaml setlocal et si sw=2 ts=2 sts=2
autocmd BufEnter *.yaml,*.yml :set indentkeys=0#
