fun! ToHaveContent(actual_value, expectedContentList)
  let l:expectedFixedContentList = a:expectedContentList + ['']
  let l:result = getline(1, '$') == l:expectedFixedContentList
  if l:result
    return 1
  endif

  echo "Actual:"
  for l:line in getline(1, '$')
    echo l:line
  endfor
  echo "Expected:"
  for l:line in l:expectedFixedContentList
    echo l:line
  endfor

  return 0
endfun
call vspec#customize_matcher(
\   'to_have_content',
\   function('ToHaveContent')
\ )

describe 'TODO-lib'
  before
    set encoding=UTF-8
    source ~/vimfiles/bundle/tabular/autoload/tabular.vim
    source ~/vimfiles/bundle/tabular/plugin/Tabular.vim
    new
    source ../vim/TODO.vim
  end
  after
    close!
  end
  describe 'TODO-aligner'
    it 'align empty file'
      let l:content = [
        \ '┌───────── a ─┬───────── c ─┐',
        \ '├───────── b ─┼───────── d ─┤',
        \ '└─────────────┴─────────────┘']
      silent! put! = l:content
      call TODO#align()
      Expect "" to_have_content[
        \ '┌───────── a ─────────┬───────── c ─────────┐',
        \ '│                     │                     │',
        \ '├───────── b ─────────┼───────── d ─────────┤',
        \ '│                     │                     │',
        \ '└─────────────────────┴─────────────────────┘']
    end
    it 'one space around cell caption'
      let l:content = [
        \ '┌─────────x────┬─────────    aaa    ────────────┐',
        \ '├─────────aa    a──────┼─────────  ───────────┤',
        \ '└────────────────────┴──────────────────────────┘']
      silent! put! = l:content
      call TODO#align()
      Expect "" to_have_content[
        \ '┌───────── x ───────────────┬───────── aaa ─────────┐',
        \ '│                           │                       │',
        \ '├───────── aa    a ─────────┼───────── ─────────────┤',
        \ '│                           │                       │',
        \ '└───────────────────────────┴───────────────────────┘']
    end
    it 'remove leave only one empty line at the end'
      let l:content = [
        \ '┌───────── 1/1 ────┬─────────    1/2    ────────────┐',
        \ '│               │                      │',
        \ '│               │                      │',
        \ '│               │                      │',
        \ '│               │                      │',
        \ '├─────────2/1──────┼─────────2/2───────────┤',
        \ '│               │                      │',
        \ '│           │                      │',
        \ '└────────────────────┴──────────────────────────┘']
      silent! put! = l:content
      call TODO#align()
      Expect "" to_have_content[
        \ '┌───────── 1/1 ─────────┬───────── 1/2 ─────────┐',
        \ '│                       │                       │',
        \ '├───────── 2/1 ─────────┼───────── 2/2 ─────────┤',
        \ '│                       │                       │',
        \ '└───────────────────────┴───────────────────────┘']
    end
    it 'complex table'
      let l:content = [
        \ '┌─────────  1/1  ────┬───────── 1/2 ────────────┐',
        \ '│ 123456             │ abcdef                   │',
        \ '│ 0987654321         │                          │',
        \ '│                    │                          │',
        \ '│                    │last line                 │',
        \ '├───────── 2/1 ──────┼───────── 2  2 ───────────┤',
        \ '│                    │ abcdefgh                 │',
        \ '│                    │ ABCDEFGHI                │',
        \ '│                    │ QWERTZUIOPASDFGHJKLYXCVBN│',
        \ '└────────────────────┴──────────────────────────┘']
      silent! put! = l:content
      call TODO#align()
      Expect "" to_have_content[
        \ '┌───────── 1/1 ─────────┬───────── 1/2 ─────────────┐',
        \ '│ 123456                │ abcdef                    │',
        \ '│ 0987654321            │                           │',
        \ '│                       │                           │',
        \ '│                       │ last line                 │',
        \ '│                       │                           │',
        \ '├───────── 2/1 ─────────┼───────── 2  2 ────────────┤',
        \ '│                       │ abcdefgh                  │',
        \ '│                       │ ABCDEFGHI                 │',
        \ '│                       │ QWERTZUIOPASDFGHJKLYXCVBN │',
        \ '│                       │                           │',
        \ '└───────────────────────┴───────────────────────────┘']
    end
    it 'cursor stays at the position'
      let l:content = [
        \ '┌─────────  1/1  ────┬───────── 1/2 ────────────┐',
        \ '│ 123456             │ abcdef                   │',
        \ '│ 0987654321         │                          │',
        \ '│                    │                          │',
        \ '│                    │last line                 │',
        \ '├───────── 2/1 ──────┼───────── 2  2 ───────────┤',
        \ '│                    │ abcdefgh                 │',
        \ '│                    │ ABCDEFGHI                │',
        \ '│                    │ QWERTZUIOPASDFGHJKLYXCVBN│',
        \ '└────────────────────┴──────────────────────────┘']
      silent! put! = l:content
      5
      execute "normal! 9|"
      let l:pos = getpos('.')
      call TODO#align()
      Expect "" to_have_content[
        \ '┌───────── 1/1 ─────────┬───────── 1/2 ─────────────┐',
        \ '│ 123456                │ abcdef                    │',
        \ '│ 0987654321            │                           │',
        \ '│                       │                           │',
        \ '│                       │ last line                 │',
        \ '│                       │                           │',
        \ '├───────── 2/1 ─────────┼───────── 2  2 ────────────┤',
        \ '│                       │ abcdefgh                  │',
        \ '│                       │ ABCDEFGHI                 │',
        \ '│                       │ QWERTZUIOPASDFGHJKLYXCVBN │',
        \ '│                       │                           │',
        \ '└───────────────────────┴───────────────────────────┘']
      Expect getpos('.') == l:pos
    end
  end
  describe 'n_C'
    it 'TODO#getColumnPosition 1'
      Expect TODO#getColumnPosition('│123456│', 3) == [0, 7]
    end
    "it 'C in the middle of the line'
      "let l:content = [
        "\ '┌─────────  1/1  ────┬───────── 1/2 ────────────┐',
        "\ '│ 123_56             │ abcdef                   │',
        "\ '├───────── 2/1 ──────┼───────── 2  2 ───────────┤',
        "\ '│                    │ abcdefgh                 │',
        "\ '└────────────────────┴──────────────────────────┘']
      "silent! put! = l:content
      "execute "normal! /_\<cr>"
      "execute "normal! Cxxx\<cr>"
      "Expect "" to_have_content[
        "\ '┌─────────  1/1  ────┬───────── 1/2 ────────────┐',
        "\ '│ 123xxx             │ abcdef                   │',
        "\ '├───────── 2/1 ──────┼───────── 2  2 ───────────┤',
        "\ '│                    │ abcdefgh                 │',
        "\ '└────────────────────┴──────────────────────────┘']
      "Expect getpos('.') == l:pos
    "end
  end
end

" vim: set ts=2 sts=2 sw=2 expandtab:
