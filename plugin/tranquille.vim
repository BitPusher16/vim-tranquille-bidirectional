" Vim plugin for searching without moving the cursor
" Last Change:	2018 Nov 2
" Maintainer:	Adam P. Regasz-Rethy  <rethy.spud@gmail.com>
" License:	This file is placed in the public domain.

if exists('g:loaded_tranquille') || !has('autocmd')
    finish
endif
let g:loaded_tranquille = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

"if mapcheck('g/') ==# '' && !hasmapto('<Plug>(tranquille_search)')
"    nmap <unique> g/ <Plug>(tranquille_search)
"endif

nnoremap <silent> <Plug>(tranquille_search_down) :TranquilleSearchDown<CR>
nnoremap <silent> <Plug>(tranquille_search_up) :TranquilleSearchUp<CR>

command! -nargs=0 TranquilleSearchDown
            \ let result = <SID>tranquille_search_down()
            \ | if result
                \ | set hls
                \ | endif

command! -nargs=0 TranquilleSearchUp
            \ let result = <SID>tranquille_search_up()
            \ | if result
                \ | set hls
                \ | endif

augroup tranquille_autocmds
    autocmd!
    autocmd CmdlineLeave * call s:delete_match()
augroup END

let s:tranquille_id = 67

fun! s:delete_match() abort
    try
        call matchdelete(s:tranquille_id)
    catch /\v(E802|E803)/
    endtry
endfun

fun! s:tranquille_search_down()
    nohls
    augroup tranquille_textwatcher
        autocmd!
        autocmd CmdlineChanged * call s:update_hl()
    augroup END
    let search = input('/')
    augroup tranquille_textwatcher
        autocmd!
    augroup END
    if search !=# ''
        let @/ = search
        redraw
        try
            " maybe a good idea to set timeout on this search.
            " https://vimdoc.sourceforge.net/htmldoc/eval.html#functions
            if search(search, 'n') == 0
                echohl ErrorMsg | echo 'E486: Pattern not found: '.search | echohl None
            endif
        catch /.*/
            echohl ErrorMsg | echom 'Error with search term: '.search | echohl None
        endtry
        return 1
    else
        return 0
    endif
endf

fun! s:tranquille_search_up()
    nohls
    augroup tranquille_textwatcher
        autocmd!
        autocmd CmdlineChanged * call s:update_hl()
    augroup END
    let search = input('?')
    augroup tranquille_textwatcher
        autocmd!
    augroup END
    if search !=# ''
        let @/ = search
        redraw
        try
            if search(search, 'n') == 0
                echohl ErrorMsg | echo 'E486: Pattern not found: '.search | echohl None
            endif
        catch /.*/
            echohl ErrorMsg | echom 'Error with search term: '.search | echohl None
        endtry
        return 1
    else
        return 0
    endif
endf

fun! s:update_hl() abort
    call s:delete_match()

    let l:pattern = ''
    if !&magic
        let l:pattern .= '\M'
    endif
    if &ignorecase
        let l:pattern .= '\c'
    endif
    let l:cmdline = getcmdline()
    if l:cmdline !=# ''
        let l:pattern .= l:cmdline
        try
            call matchadd('Search', l:pattern, 0, s:tranquille_id)
        catch /.*/
        endtry
    endif
    redraw
endf

let &cpoptions = s:save_cpo
unlet s:save_cpo
