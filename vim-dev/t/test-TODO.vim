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
    let l:content = [
      \ '┌───────── 1/1 ──────┬───────── 1/2 ────────────┐',
      \ '│ 123456             │ abcdef                   │',
      \ '│ 0987654321         │                          │',
      \ '│                    │                          │',
      \ '├───────── 2/1 ──────┼───────── 2/2 ────────────┤',
      \ '│                    │ abcdefgh                 │',
      \ '│                    │ ABCDEFGHI                │',
      \ '│                    │ QWERTZUIOPASDFGHJKLYXCVBN│',
      \ '└────────────────────┴──────────────────────────┘']
    put! = l:content
    source ../vim/TODO.vim
  end
  after
    close!
  end
  it 'can read the contents of the buffer'
    Expect stridx(getline(1), '1/1') > 0
    Expect "" to_have_content[
      \ '┌───────── 1/1 ──────┬───────── 1/2 ────────────┐',
      \ '│ 123456             │ abcdef                   │',
      \ '│ 0987654321         │                          │',
      \ '│                    │                          │',
      \ '├───────── 2/1 ──────┼───────── 2/2 ────────────┤',
      \ '│                    │ abcdefgh                 │',
      \ '│                    │ ABCDEFGHI                │',
      \ '│                    │ QWERTZUIOPASDFGHJKLYXCVBN│',
      \ '└────────────────────┴──────────────────────────┘']
  end
  it 'simple align works'
    2
    normal! f6axxx
    call todo#align()
    Expect "" to_have_content[
      \ '┌───────── 1/1 ──────┬───────── 1/2 ────────────┐',
      \ '│ 123456             │ abcdef                   │',
      \ '│ 0987654321xxx      │                          │',
      \ '│                    │                          │',
      \ '├───────── 2/1 ──────┼───────── 2/2 ────────────┤',
      \ '│                    │ abcdefgh                 │',
      \ '│                    │ ABCDEFGHI                │',
      \ '│                    │ QWERTZUIOPASDFGHJKLYXCVBN│',
      \ '└────────────────────┴──────────────────────────┘']
  end
  it 'can align text with + sign'
    TODO
  end
end

" vim: set ts=2 sts=2 sw=2 expandtab:
