fun! SmartSpaceN()
  let l:replace_text = { 'true': 'false', 'True': 'False', 'TRUE': 'FALSE' }
  for v in keys(l:replace_text)
    let l:replace_text[l:replace_text[v]] = v
  endfor
  let l:cmd = '0'
  let l:winview = winsaveview()
  let l:old_pos = getpos(".")
  let l:b = @"
  normal yiw
  if has_key(l:replace_text, @")
    call Switch_to_text(l:replace_text[@"])
  endif
  let @"=l:b
  call winrestview(l:winview)
  call setpos('.', l:old_pos)
  call eval(l:cmd)
endfun

fun! Switch_to_text(text)
  execute "normal! ciw" . a:text . "\<esc>"
endfun

"augroup PROPERTY
  "autocmd!
  "autocmd filetype jproperties nnoremap <buffer> <silent> <SPACE> :call Space()<cr>
"augroup END

nnoremap <silent> <SPACE> :call SmartSpaceN()<cr>

" vim: set ts=2 sts=2 sw=2 expandtab:
