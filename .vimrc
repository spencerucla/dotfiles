" VUNDLE SETUP
" Required for Vundle, also see http://stackoverflow.com/a/22543937
set nocompatible
filetype off
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Other plugins
Plugin 'vimwiki/vimwiki'
" vim-signify requires file save to show diff, so prefer vim-gitgutter
" Plugin 'mhinz/vim-signify'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'phleet/vim-mercenary'
" Plugin 'scrooloose/nerdtree'
" Plugin 'kien/ctrlp.vim'
" Plugin 'scroolose/nerdcommenter'
" Plugin 'scroolose/syntastic'
" Plugin 'vim-airline/vim-airline'
" Plugin 'rustushki/JavaImp.vim'
Plugin 'akhaku/vim-java-unused-imports'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'udalov/kotlin-vim'
call vundle#end()
filetype plugin on " TODO: maybe add indent between plugin and on

" VIM SETUP

syntax on

" Show line numbers
set nu
" Toggle line numbers
map tln :set nu!<CR>

" Spaces and tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
" Convert tabs to spaces
set expandtab

" Torture self
" noremap <Up> <NOP>
" noremap <Down> <NOP>
" noremap <Right> <NOP>
" noremap <Left> <NOP>

" Tab completion for vim commands
" First tab completes to longest match and shows wildmenu (other options)
" Second tab cycles thru matches
set wildmenu
set wildmode=longest:full,full

" Change spacing to perfection
nnoremap <F7> mzgg=G`z

" Toggle paste mode for auto-spacing/comments
nnoremap <F2> :set invpaste paste?<CR>

" Format JSON " TODO: switch to syntax highlighting to handle formatting also
" Performs the following:%!python -m json.tool
com! FormatJSON %!python -m json.tool

" Highlight search results
set hlsearch

" Vertical red line after 80 chars
set colorcolumn=81

" Always show filename
set laststatus=2

" use default folding settings
" use default color settings

" ==============
" ==== XIAO ====
" ==============
" Don't expand tabs for makefiles
autocmd FileType make       setlocal noexpandtab

" allows toggling between tabs and spaces
function! TabToggle()
  if &expandtab
    set noexpandtab
  else
    set expandtab
  endif
endfunction
nnoremap <F9> mz:execute TabToggle()<CR>'z

"
" Highlight Commands
"
" Show trailing whitespaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+\%#\@<!$/
" highlight ExtraWhitespace ctermbg=red guibg=red
" au ColorScheme * highlight ExtraWhitespace guibg=red
" au BufEnter * match ExtraWhitespace /\s\+$/
" au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
" au InsertLeave * match ExtraWhiteSpace /\s\+$/
" autocmd InsertLeave * redraw!

nmap <F5> :noh<CR>

" File type detection
" There are multiple ways to do this:
" call SetFileTypeSH(""), setfiletype, set ft=, set filetype=
augroup filetypedetect
  autocmd BufRead,BufNewFile .bash_aliases set filetype=bash
  autocmd BufRead,BufNewFile *.cc set filetype=cpp
  autocmd BufRead,BufNewFile *.cu,*.cu_inl set filetype=cpp
  autocmd BufRead,BufNewFile *.dts,*.dtsi set filetype=dts
  autocmd BufRead,BufNewFile *.json set filetype=json
  autocmd BufRead,BufNewFile *.klogcat,*.logcat set filetype=logcat
  autocmd BufRead,BufNewFile *.md setlocal filetype=markdown
  autocmd BufRead,BufNewFile *.mk,[mM]ake*file*,*.make set filetype=make
augroup END

" DOES NOT WORK :(
" autocmd FileType python     nnoremap <buffer> <localleader>c I#<esc>

" If file is in kernel directory, use 8 character wide tabs for indentation
" https://www.kernel.org/doc/Documentation/CodingStyle
autocmd BufRead,BufNewFile */kernel/* setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab

command F tabe <bar> FZF

" TODO: go thru these
" "
" " Misc
" "
" set pastetoggle=<F2>
set ruler
" au WinLeave * set nocursorline nocursorcolumn
" au WinEnter * set cursorline cursorcolumn
" set cursorline cursorcolumn
" set nowrap
"
" "
" " Macro to remove spaces
" "
" function ShowSpaces(...)
"   let @/='\v(\s+$)|( +\ze\t)'
"   let oldhlsearch=&hlsearch
"   if !a:0
"     let &hlsearch=!&hlsearch
"   else
"     let &hlsearch=a:1
"   end
"   return oldhlsearch
" endfunction
"
" function TrimSpaces() range
"   let oldhlsearch=ShowSpaces(1)
"   execute a:firstline.",".a:lastline."substitute ///gec"
"   let &hlsearch=oldhlsearch
" endfunction

" Strip trailing whitespace (,ss)
"function! StripWhitespace()
"    let save_cursor = getpos(".")
"    let old_query = getreg('/')
"    :%s/\s\+$//e
"    call setpos('.', save_cursor)
"    call setreg('/', old_query)
"endfunction
"noremap <leader>ss :call StripWhitespace()<CR>
"
" command -bar -nargs=? ShowSpaces call ShowSpaces(<args>)
" command -bar -nargs=0 -range=% TrimSpaces <line1>,<line2>call TrimSpaces()
" nnoremap <F6>   m`:TrimSpaces<CR>``
" vnoremap <F6>   :TrimSpaces<CR>

" Save a file as root (,W)
"noremap <leader>W :w !sudo tee % > /dev/null<CR>

" FOLDS
"set foldcolumn=0 " Column to show folds
"set foldenable " Enable folding
"set foldlevel=0 " Close all folds by default
"set foldmethod=syntax " Syntax are used to specify folds
"set foldminlines=0 " Allow folding single lines
"set foldnestmax=5 " Set max fold nesting level
" Toggle folds (<Space>)
"nnoremap <silent> <space> :exe 'silent! normal! '.((foldclosed('.')>0)? 'zMzx' : 'zc')<CR>

" PLUGINS CONFIG

" Vimwiki.vim {{{
augroup vimwiki_config
  let g:vimwiki_list = [{'path': '~/.vimwiki', 'syntax': 'markdown', 'ext': '.md'}]
augroup END
" }}}

" " Signify.vim {{{
" augroup signify_config
"   autocmd!
"   let g:signify_vcs_list = [ 'git' ]
" augroup END
" " }}}

" Gitgutter.vim {{{
augroup gitgutter_config
  set updatetime=2000
  let g:gitgutter_max_signs = 500  " default value
  " let g:gitgutter_sign_column_always = 1
augroup END
" }}}

" " Airline.vim {{{
" augroup airline_config
"   autocmd!
"   let g:airline_powerline_fonts = 1
"   let g:airline_enable_syntastic = 1
"   let g:airline#extensions#tabline#buffer_nr_format = '%s '
"   let g:airline#extensions#tabline#buffer_nr_show = 1
"   let g:airline#extensions#tabline#enabled = 1
"   let g:airline#extensions#tabline#fnamecollapse = 0
"   let g:airline#extensions#tabline#fnamemod = ':t'
" augroup END
" " }}}

" " CtrlP.vim {{{
" augroup ctrlp_config
"   autocmd!
"   let g:ctrlp_clear_cache_on_exit = 0 " Do not clear filenames cache, to improve CtrlP startup
"   let g:ctrlp_lazy_update = 350 " Set delay to prevent extra search
"   let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' } " Use python fuzzy matcher for better performance
"   let g:ctrlp_match_window_bottom = 0 " Show at top of window
"   let g:ctrlp_max_files = 0 " Set no file limit, we are building a big project
"   let g:ctrlp_switch_buffer = 'Et' " Jump to tab AND buffer if already open
"   let g:ctrlp_open_new_file = 'r' " Open newly created files in the current window
"   let g:ctrlp_open_multiple_files = 'ij' " Open multiple files in hidden buffers, and jump to the first one
" augroup END
" " }}}

" " JavaImp.vim {{{
" augroup javaimp_config
"   let g:JavaImpPaths =
"     \ $HOME."/code/aosp/frameworks/base/core/java," .
"   let g:JavaImpDataDir = $HOME."/.javaimp"
" augroup END
" " }}}
