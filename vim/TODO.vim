let s:char_pipe='│'
let s:char_dash='─'
let s:char_1='└'
let s:char_2='┴'
let s:char_3='┘'
let s:char_4='├'
let s:char_5='┼'
let s:char_6='┤'
let s:char_7='┌'
let s:char_8='┬'
let s:char_9='┐'
let s:chars_non_straight=s:char_1 . s:char_2 . s:char_3 . s:char_4 . s:char_5 . s:char_6 . s:char_7 . s:char_8 . s:char_9
let s:header_minimum_dash = repeat(s:char_dash, 8)

fun! TODO#align()
  let l:winview = winsaveview()

  let l:i = 1
  let l:line_count = line('$')
  let l:top_line = ""
  let l:top_line_pos = 0
  let l:middle_line = ""
  let l:middle_line_pos = 0
  let l:bottom_line = ""
  let l:bottom_line_pos = 0
  while l:i <= l:line_count
    let l:line = getline(l:i)
    if stridx(l:line, s:char_7) == 0
      if l:top_line_pos != 0
        echoerr 'Invalid TODO format (1)'
        return
      endif
      let l:top_line_pos = l:i
      let l:top_line = l:line
    elseif stridx(l:line, s:char_4) == 0
      if l:middle_line_pos != 0
        echoerr 'Invalid TODO format (2)'
        return
      endif
      let l:middle_line_pos = l:i
      let l:middle_line = l:line
    elseif stridx(l:line, s:char_1) == 0
      if l:bottom_line_pos != 0
        echoerr 'Invalid TODO format (3)'
        return
      endif
      let l:bottom_line_pos = l:i
      let l:bottom_line = l:line
      break
    endif
    let l:i = l:i + 1
  endwhile
  if l:top_line_pos == 0 || l:middle_line_pos == 0 || l:bottom_line_pos == 0
    echoerr 'Invalid TODO format (4)'
  endif

  if match(getline(l:middle_line_pos - 1), '\V\^\[[:space:]' . s:char_pipe . ']\+\$') == -1
    execute l:middle_line_pos . 'put! = ' . "'" . repeat(s:char_pipe, 3) . "'"
    let l:middle_line_pos = l:middle_line_pos + 1
    let l:bottom_line_pos = l:bottom_line_pos + 1
  endif
  if match(getline(l:bottom_line_pos - 1), '\V\^\[[:space:]' . s:char_pipe . ']\+\$') == -1
    execute l:bottom_line_pos . 'put! = ' . "'" . repeat(s:char_pipe, 3) . "'"
    let l:bottom_line_pos = l:bottom_line_pos + 1
  endif
  for l:l in [l:top_line_pos, l:middle_line_pos, l:bottom_line_pos]
    execute "silent! " . l:l . "s/\\V\\[" . s:chars_non_straight . "]/" . s:char_pipe . "/g"
    execute "silent! " . l:l . "s/\\V" . s:char_dash . "\\+/ " . s:header_minimum_dash . " /g" 
    execute "silent! " . l:l . "s/\\V\\(" . s:char_dash . "\\s\\)\\s\\*/\\1/g"
    execute "silent! " . l:l . "s/\\V\\s\\*\\(\\s" . s:char_dash . "\\)/\\1/g"
    execute "silent! " . l:l . "s/\\V\\s\\+\\$//g"
  endfor

  execute l:top_line_pos . "," . l:bottom_line_pos . "Tabularize /" . s:char_pipe

  let l:header_char_dict = {
        \  l:top_line_pos    : [s:char_7, s:char_8, s:char_9],
        \  l:middle_line_pos : [s:char_4, s:char_5, s:char_6],
        \  l:bottom_line_pos : [s:char_1, s:char_2, s:char_3]
        \ }
  for l:l in keys(l:header_char_dict)
    let l:cs = l:header_char_dict[l:l]
    execute "silent! " . l:l . 's/\V\s\+\ze' . s:char_pipe . '/\=repeat("' . s:char_dash . '", strlen(submatch(0)))/g'
    execute "silent! " . l:l . 's/\V' . s:char_pipe . '\zs\s\+/\=repeat("' . s:char_dash . '", strlen(submatch(0)))/g'
    for l:i in [0, 1, 2]
      execute "silent! " . l:l . 's/\V' . s:char_pipe . '/' . l:cs[l:i] . '/'
    endfor
  endfor
  execute "silent! " . l:top_line_pos . "," . l:bottom_line_pos .
    \ 's/\V\^\(' . s:char_pipe . '\s\*' . s:char_pipe . '\s\*' . s:char_pipe . '\n\)' .
    \ '\(\^' . s:char_pipe . '\s\*' . s:char_pipe . '\s\*' . s:char_pipe . '\n\)\+' .
    \ '/\1/g'
  "execute "silent! " . l:top_line_pos . "s/\\V\\s/" . s:char_dash . "/g"
  "execute "silent! " . l:top_line_pos . "s/\\V" . s:char_pipe . "\\ze" . s:char_dash . "\\+/" . s:char_7 . "/"
  "execute "silent! " . l:top_line_pos . "s/\\V" . s:char_dash . "\\zs" . s:char_pipe . "\\ze" . s:char_dash . "/" . s:char_8 . "/"
  "execute "silent! " . l:top_line_pos . "s/\\V" . s:char_dash . "\\zs" . s:char_pipe . "/" . s:char_9 . "/"
  "execute l:middle_line_pos . "d"
  "execute l:bottom_line_pos . "d"
  call winrestview(l:winview)
endfun

fun! TODO#getColumnPosition(line, position)
  let l:right_pos = match(a:line, '\V' . s:char_pipe, a:position)
  if l:right_pos == -1
    return []
  endif
  let l:left_pos = strridx(a:line, s:char_pipe, a:position)
  if l:left_pos == -1
    return []
  endif

  if l:left_pos != l:right_pos
    return [l:left_pos, l:right_pos]
  endif

  if l:right_pos < strlen(a:line) + 1
    let l:alt_right_pos = stridx(a:line, s:char_pipe, a:position + 1)
    if l:alt_right_pos != -1
      return [l:left_pos, l:alt_right_pos]
    endif
  endif

  if l:left_pos > 0
    let l:alt_left_pos = strridx(a:line, s:char_pipe, a:position - 1)
    if l:alt_left_pos != -1
      return [l:alt_left_pos, l:right_pos]
    endif
  endif

  return []
endfun

augroup AU_TODO
  " this one is which you're most likely to use?
  autocmd InsertLeave <buffer> silent! :call TODO#align()
augroup end

nnoremap <buffer><silent> <SPACE> :silent :call TODO#align()<cr>










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

" strchars(<str>) - count of unicode chars
" strlen/len      - count of bytes
" strcharpart     - unicode equivalent of [a:b]


" vim: set ts=2 sts=2 sw=2 expandtab:
