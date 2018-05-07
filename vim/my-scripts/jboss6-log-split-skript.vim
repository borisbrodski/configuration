" JBoss 6 LOG analysis help scripts

" Example LOG lines
" 12:10:37,228 INFO  [org.jboss.ws.common.management] (MSC service thread 1-6) JBWS022052: Starting JBoss Web Services - Stack CXF Server 4.3.4.Final-redhat-1
" 12:10:37,281 INFO  [org.jboss.as.remoting] (MSC service thread 1-8) JBAS017100: Listening on 0.0.0.0:4447
" 12:10:37,530 INFO  [org.jboss.as.remoting] (MSC service thread 1-8) JBAS017100: Listening on 0.0.0.0:9999

let g:SLF_LINE_START_REGEX='\V\^\d\d:\d\d:\d\d,\d\+ '
let g:SLF_THREAD_ID='\V\^\d\d:\d\d:\d\d,\d\+ \[^[(]\+[\[^\]]\+]\s\+(\[^0-9]\+\(\[0-9]\+\))'

fun! SplitLogFile()
  let start_line = 1
  let log_bufnr = bufnr("%")
  while 1==1
    let g:SLF_thread_map = {}
    let curr_thread = "SPLT-LOG-0"
    for l in range(start_line, line("$"))
      let start_line = l + 1
    "for l in range(1, 30000)
      let line = getline(l)
      if match(line, g:SLF_LINE_START_REGEX) >= 0
        let groups = matchlist(line, g:SLF_THREAD_ID)
        if len(groups) > 0
          let curr_thread = "SPLT-LOG-" . groups[1]
        else
          let curr_thread = "SPLT-LOG-0"
        endif
      endif

      let g:SLF_thread_map[curr_thread] = get(g:SLF_thread_map, curr_thread, []) + [l]
      
      if l % 10000 == 0
        echo "" . l . " / " . line("$")
        break
      endif
    endfor
    for key in keys(g:SLF_thread_map)
      if bufnr(key) == -1
        execute "enew | file " . key
      else
        execute "b " . bufnr(key)
      endif
      "echom "Append to buffer : " . bufnr("%") . " - " . bufname("%")
      let last_line = line("$")
      for l in g:SLF_thread_map[key]
        call append(last_line, getbufline(log_bufnr, l))
        let last_line = last_line + 1
      endfor
    endfor
    execute "b " . log_bufnr
    if start_line > line("$")
      break
    endif
  endwhile
endfun

fun! RemoveLines(regex, ...)
  let save_to_reg = (a:0 >= 1) ? a:1 : '_'
  silent execute "let @" . save_to_reg . " = ''"
  let START_REGEX = '\V\^\d\d:\d\d:\d\d,\d\+ '
  normal mrgg
  let flags = 'c'
  let line_count = line("$")
  let removed_blocks = 0
  let removed_lines = 0
  while search(START_REGEX, flags . "W") > 0
    let start = line(".")
    let i = start
    let delete = 0
    while (i < line_count)
      if ((i > start) && (match(getline(i), START_REGEX) >= 0))
        break
      endif
      if match(getline(i), a:regex) >= 0
        let delete = 1
      endif
      let i = i + 1
    endwhile
    "echo delete . " from " . start . " to " . (i-1)
    if delete == 1
      silent execute start . "," . (i-1) . "d " . save_to_reg
      execute start
      silent! execute "normal k"
      let flags = 'c'
      let removed_blocks = removed_blocks + 1
      let removed_lines = removed_lines + (i - start)
    else
      let flags = ''
    endif
  endwhile
  let @a=removed_blocks
  let @b=removed_lines
  let msg=substitute(a:regex, '\\V', '', 'g')
  let msg=substitute(msg, '\\_s\\+', ' ', 'g')
  let msg=substitute(msg, '\\d\\+', '00000000000', 'g')
  let @m="(".removed_blocks.")  ".msg
  silent! execute "normal `r"
  echom "Removed blocks (@a): " . removed_blocks . ", lines (@b): " . removed_lines . " saved to reg: " . save_to_reg
endfun

" vim: set ts=2 sts=2 sw=2 expandtab:
