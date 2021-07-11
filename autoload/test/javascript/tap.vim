if !exists('g:test#javascript#tap#file_pattern')
  let g:test#javascript#tap#file_pattern = '\v(tests?/.*|\.(spec|test))\.js$'
endif

if !exists('g:test#javascript#tap#runners')
  let g:test#javascript#tap#runners = ['tape', 'tap']
endif

if !exists('g:test#javascript#tap#reporters')
  let g:test#javascript#tap#reporters = []
endif

function! test#javascript#tap#test_file(file) abort
  if a:file =~# g:test#javascript#tap#file_pattern
      if exists('g:test#javascript#runner')
          return g:test#javascript#runner ==# 'tap'
      else
        return test#javascript#has_package('tap')
      endif
  endif
endfunction

function! test#javascript#tap#build_position(type, position) abort
  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      let name = '--grep='.shellescape(name, 1)
    endif
    return [a:position['file'], name]
  elseif a:type ==# 'file'
    return [a:position['file']]
  else
    return []
  endif
endfunction

function! test#javascript#tap#build_args(args) abort
  let args = a:args
  for executable in g:test#javascript#tap#reporters
    if filereadable('node_modules/.bin/' . executable)
      let args = args + ['|', 'node_modules/.bin/' . executable]
    endif
  endfor

  return args
endfunction

function! test#javascript#tap#executable() abort
  for executable in g:test#javascript#tap#runners
    if filereadable('node_modules/.bin/' . executable)
      return 'node_modules/.bin/' . executable
    endif
  endfor

  return ''
endfunction

function! s:nearest_test(position) abort
  let patterns = {
        \ 'test': ['\v^\s*%(%(%(tap|t)\.)?test)[(]\_s*%("|''|`)(.*)%("|''|`)'],
        \ 'namespace': [],
        \}
  let name = test#base#nearest_test(a:position, patterns)
  return join(name['test'])
endfunction
