function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! s:strip_end(input_string)
    return substitute(a:input_string, '\V\^\(\.\{-}\)\s\*\$', '\1', '')
endfunction

" Save and restore:
" - view
" - fold
" - marks: a, <, >
" - registers: /, :, a, "
function! todo#safe_exec(cmd)
  let l:winview = winsaveview()
  let l:save_lz = &lazyredraw
  let l:save_fe = &foldenable
  set lazyredraw
  set nofoldenable
  let l:save_reg_def = @"
  let l:save_reg_a = @a
  let l:save_reg_cmd = @:
  let l:save_reg_search = @/

  let l:save_mark_a = getpos("'a")
  let l:save_mark_lt = getpos("'<")
  let l:save_mark_gt = getpos("'>")


  let l:result = eval(a:cmd)
  let l:new_pos = getpos(".")


  let @a = l:save_reg_a
  "let @: = l:save_reg_cmd
  let @/ = l:save_reg_search
  let @" = l:save_reg_def
  
  call winrestview(l:winview)
  if (l:result['keep_cursor'] == 1)
    call setpos('.', l:new_pos)
    execute "silent! normal! v\<esc>"
  endif

  call setpos("'a", l:save_mark_a)
  call setpos("'<", l:save_mark_lt)
  call setpos("'>", l:save_mark_gt)

  let &lazyredraw = l:save_lz
  let &foldenable = l:save_fe
endfunction

function! s:get_bounding_lines()
  execute "silent! normal! 0/+---------\<cr>"
  let l:end_line = getpos('.')[1]
  execute "silent! normal! 0?+---------\<cr>"
  let l:begin_line = getpos('.')[1]
  return [l:begin_line, l:end_line]
endfunction

function! todo#Normal_C()
  normal! dt|
  return {'keep_cursor': 1}
endfunction

function! todo#Normal_dd()
  call todo#align()
  let l:start_pos = getpos('.')
  execute "silent! normal! 0/+---------\<cr>"
  let l:end_line = getpos('.')[1]
  call setpos('.', l:start_pos)

  if l:end_line <= l:start_pos[1]
    return
  endif

  "execute "normal! i" . (l:end_line - l:start_pos[1]) . "\<esc>"
  if l:end_line > l:start_pos[1] + 1
    execute "silent! normal! T|j\<c-v>t|"
    if (l:end_line - l:start_pos[1] - 2) > 0
      execute "silent! normal! " . (l:end_line - l:start_pos[1] - 2) . "j"
    endif
    execute "silent! normal! ygvkokpgv\<esc>j"
  endif
  execute "silent! normal! T|vt|r "
endfunction

function! todo#Normal_o()
  call todo#align()
  let l:start_pos = getpos('.')
  let l:bounding_lines = s:get_bounding_lines()
  if l:start_pos[1] >= l:bounding_lines[1]
    return
  endif
  call setpos('.', [l:start_pos[0], l:bounding_lines[1] - 1, l:start_pos[2], 0])
  execute "silent! normal! T|vt|y"
  if strlen(Strip(@")) > 0 || l:start_pos[1] == l:bounding_lines[1] - 1
    execute "silent! normal! o|||\<esc>"
    call todo#align()
    let l:bounding_lines = s:get_bounding_lines()
  endif
  if l:start_pos[1] < l:bounding_lines[1] - 1
    call setpos('.', l:start_pos)
    execute "silent! normal! T|<c-v>t|"
    execute "silent! normal! " . (l:bounding_lines[1] - l:start_pos[1] - 2) . "j"
  endif
  return {'keep_cursor': 1}
endfunction
function! todo#Normal_G()
  let l:start_pos = getpos('.')
  let l:bounding_lines = s:get_bounding_lines()

  let l:line = l:bounding_lines[1] - 1
  while l:line > l:bounding_lines[0]
    call setpos('.', [l:start_pos[0], l:line, l:start_pos[2], 0])
    execute "silent! normal! T|vt|y"
    if strlen(Strip(@")) > 0
      execute "silent! normal! T|l"
      return {'keep_cursor': 1}
    endif
    let l:line = l:line - 1
  endwhile
  call setpos('.', [l:start_pos[0], l:bounding_lines[0] + 1, l:start_pos[2], 0])
  execute "silent! normal! T|l"
  return {'keep_cursor': 1}
endfunction

function! todo#Normal_gk()
  let l:start_pos = getpos('.')
  call setpos('.', [l:start_pos[0], 2, l:start_pos[2], 0])
  call todo#Normal_G()
  return {'keep_cursor': 1}
endfunction
function! todo#Normal_gj()
  let l:start_pos = getpos('.')
  execute "silent! normal! gg0/+---------\<cr>nn"
  call setpos('.', [l:start_pos[0], getpos('.')[1] + 1, l:start_pos[2], 0])
  call todo#Normal_G()
  return {'keep_cursor': 1}
endfunction
function! todo#Normal_S()
  execute "silent! normal! T|vt|r T|l"
  return {'keep_cursor': 1}
endfunction
function! todo#Normal_C()
  execute "silent! normal! vt|r "
  return {'keep_cursor': 1}
endfunction

"nnoremap <Plug>TODO_Normal_C :call todo#safe_exec("call todo#Normal_C()")<cr>:call repeat#set("\<Plug>TODO_Normal_C", v:count)<CR>
"nnoremap <leader>C  <Plug>TODO_Normal_C 
"nmap <leader>x :call todo#safe_exec("call todo#Normal_C()")<cr>


function! todo#align()
  let l:winview = winsaveview()

  silent! %s/\V\[^-]---------\zs-\+/\=substitute(submatch(0), "-", " ", "ge")/ge
  Tabular /+-\|+\|| \?/l0l0l1
  silent! %s/\V\----------\{-}\zs \+\ze-\*+/\=substitute(submatch(0), " ", "-", "ge")/ge

  call winrestview(l:winview)
endfunction

"nnoremap <buffer> <silent> <space> :call todo#align()<cr>
"nnoremap <buffer> C ct\|

"nnoremap <buffer><silent> <Plug>TODO_Normal_dd :call todo#safe_exec("todo#Normal_dd()")<cr>:silent! call repeat#set("\<Plug>TODO_Normal_dd", v:count)<CR>
"nmap <buffer> dd <Plug>TODO_Normal_dd

"nnoremap <buffer><silent> <Plug>TODO_Normal_o :call todo#Normal_o()<cr>:silent! call repeat#set("\<Plug>TODO_Normal_o", v:count)<CR>
"nmap <buffer> o <Plug>TODO_Normal_o

"nnoremap <buffer><silent> <Plug>TODO_Normal_S :call todo#safe_exec("todo#Normal_S()")<cr>R
"nmap <buffer> S <Plug>TODO_Normal_S

"nnoremap <buffer><silent> <Plug>TODO_Normal_C :call todo#safe_exec("todo#Normal_C()")<cr>R
"nmap <buffer> C <Plug>TODO_Normal_C

"nnoremap <buffer><silent> <Plug>TODO_Normal_G :call todo#safe_exec("todo#Normal_G()")<cr>
"nmap <buffer> G <Plug>TODO_Normal_G

"nnoremap <buffer> gl $h:silent! call todo#safe_exec("todo#Normal_G()")<cr>
"nnoremap <buffer> gh 0l:silent! call todo#safe_exec("todo#Normal_G()")<cr>
"nnoremap <buffer> gj :silent! call todo#safe_exec("todo#Normal_gj()")<cr>
"nnoremap <buffer> gk :silent! call todo#safe_exec("todo#Normal_gk()")<cr>

"nnoremap <buffer> _ T\|l
"vnoremap <buffer> _ T\|l
"nnoremap <buffer> $ t\|ge
"vnoremap <buffer> $ t\|ge




"nnoremap <buffer> $ f\|ge
"onoremap <buffer> $ :<C-u>normal! vf\|ge<CR>

fun! todo#getColumnPositions(line)
  let l:line = getline(a:line)
  if stridx(l:line, '|') != 0 || match(l:line, '\V|\s\*\$') == -1
    return []
  endif
  let l:last_pipe = strridx(l:line, '|')
  if l:last_pipe == 0
    return []
  endif
  let l:two_column_content = strpart(l:line, 1, l:last_pipe - 1)
  " TODO Improve middle pipe detection here
  let l:middle_pipe = stridx(l:two_column_content, '|') + 1
  return [0, l:middle_pipe, l:last_pipe]
endfun
fun! todo#inTODO()
  let l:line = getline(".")
  return stridx(l:line, "+--") == 0 || stridx(l:line, "|") == 0
endfun

fun! todo#normal_dollar()
  let l:column_positions = todo#getColumnPositions('.')
  let l:pos = getpos(".")
  if len(l:column_positions) != 3
    return
  endif
  if l:pos[2] > l:column_positions[1]
    let l:column_positions = l:column_positions[1:]
  endif
  let l:content = strpart(getline("."), l:column_positions[0] + 1, l:column_positions[1] - l:column_positions[0] - 1)
  let l:content = s:strip_end(l:content)
  echom (l:column_positions[0] + 3) . "|"
  if l:content == ""
    execute "normal! " . (l:column_positions[0] + 3) . "|"
  else
    execute "normal! " . (l:column_positions[0] + strlen(l:content) + 1) . "|"
  endif
endfun

"nnoremap <expr><buffer> $ todo#inTODO() ? todo#Normal_Dollar() : '$'
"vnoremap <expr><buffer> $ todo#inTODO() ? todo#Normal_Dollar() : '$'
"onoremap <expr><buffer> $ todo#inTODO() ? ":<C-u>normal! v" . todo#Normal_Dollar() . "\<cr>" : '$'

"nnoremap <silent> <Plug>TODO_Normal_C
"\   :<C-U>execute 'silent! call repeat#setreg("\<lt>Plug>TODO_Normal_C", v:register)'<Bar>
"\   call <SID>MyFunction(v:register, ...)<Bar>
"\   silent! call repeat#set("\<lt>Plug>TODO_Normal_C")<CR>

function! todo#repeat_set(mapping)
    call repeat#set(v:operator . "\<Plug>" . a:mapping . (v:operator == 'c' ? "\<c-r>." : ''))

    augroup todo_repeat_tick
        autocmd!
        autocmd CursorMoved <buffer>
            \ let g:repeat_tick = b:changedtick |
            \ autocmd! todo_repeat_tick
    augroup END
endfunction

"fun! Move_cursor()

  ""let @a= "normal v" . todo#Normal_Dollar() . "\<cr>"
  "execute "normal v" . todo#Normal_Dollar()
"endfun

nnoremap <buffer> <Plug>TODO_normal_dollar  :call todo#normal_dollar()<cr>
vnoremap <buffer> <Plug>TODO_normal_dollar  :<C-U>call todo#normal_dollar()<CR>
onoremap <buffer> <Plug>TODO_normal_dollar v:<C-U>call todo#normal_dollar() \| call todo#repeat_set('TODO_normal_dollar')<cr>

nmap <buffer> $ <Plug>TODO_normal_dollar
vmap <buffer> $ <Plug>TODO_normal_dollar
omap <buffer> $ <Plug>TODO_normal_dollar

"nmap <buffer><silent> C <Plug>TODO_Normal_C


"nmap <expr><buffer> C todo#inTODO() ? 'c$' : 'C'



"Box Drawing[1]
"Official Unicode Consortium code chart (PDF)
"        0 1 2 3 4 5 6 7 8 9 A B C D E F
"U+250x  ─ ━ │ ┃ ┄ ┅ ┆ ┇ ┈ ┉ ┊ ┋ ┌ ┍ ┎ ┏
"U+251x  ┐ ┑ ┒ ┓ └ ┕ ┖ ┗ ┘ ┙ ┚ ┛ ├ ┝ ┞ ┟
"U+252x  ┠ ┡ ┢ ┣ ┤ ┥ ┦ ┧ ┨ ┩ ┪ ┫ ┬ ┭ ┮ ┯
"U+253x  ┰ ┱ ┲ ┳ ┴ ┵ ┶ ┷ ┸ ┹ ┺ ┻ ┼ ┽ ┾ ┿
"U+254x  ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋ ╌ ╍ ╎ ╏
"U+255x  ═ ║ ╒ ╓ ╔ ╕ ╖ ╗ ╘ ╙ ╚ ╛ ╜ ╝ ╞ ╟
"U+256x  ╠ ╡ ╢ ╣ ╤ ╥ ╦ ╧ ╨ ╩ ╪ ╫ ╬ ╭ ╮ ╯
"U+257x  ╰ ╱ ╲ ╳ ╴ ╵ ╶ ╷ ╸ ╹ ╺ ╻ ╼ ╽ ╾ ╿
"Notes
"1.^ As of Unicode version 9.0



" vim: set ts=2 sts=2 sw=2 expandtab:
