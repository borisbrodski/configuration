fun! SmartSpaceN()
  let l:cmd = '0'
  let l:winview = winsaveview()
  let l:old_pos = getpos(".")
  let l:b = @"
  normal yiw
  if @" == 'true'
    call Switch_to_false()
  elseif @" == 'false'
    call Switch_to_true()
  elseif getline('.') =~ '^:'
    execute strpart(getline('.'), 1)
  endif
  let @"=l:b
  call winrestview(l:winview)
  call setpos('.', l:old_pos)
  call eval(l:cmd)
endfun

fun! Switch_to_true()
  execute "normal! ciwtrue\<esc>"
endfun

fun! Switch_to_false()
  execute "silent! normal! ciwfalse\<esc>"
endfun

"augroup PROPERTY
  "autocmd!
  "autocmd filetype jproperties nnoremap <buffer> <silent> <SPACE> :call Space()<cr>
"augroup END

nnoremap <silent> <SPACE> :call SmartSpaceN()<cr>

" vim: set ts=2 sts=2 sw=2 expandtab:
