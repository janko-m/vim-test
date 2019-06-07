if !exists('g:test#python#pytest#file_pattern')
  let g:test#python#pytest#file_pattern = '\v(test_[^/]+|[^/]+_test)\.py$'
endif

function! test#python#pytest#test_file(file) abort
  if fnamemodify(a:file, ':t') =~# g:test#python#pytest#file_pattern
    if exists('g:test#python#runner')
      return g:test#python#runner ==# 'pytest'
    else
      return executable("pytest") || executable("py.test")
    endif
  endif
endfunction

function! test#python#pytest#build_position(type, position) abort
  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      return [a:position['file'].'::'.name]
    else
      return [a:position['file']]
    endif
  elseif a:type ==# 'file'
    return [a:position['file']]
  else
    return []
  endif
endfunction

function! test#python#pytest#build_args(args) abort
  let args = a:args

  if test#base#no_colors()
    let args = ['--color=no'] + args
  endif

  return args
endfunction

function! test#python#pytest#executable() abort
  let pipenv_prefix = ""

  if filereadable("Pipfile")
    let pipenv_prefix = "pipenv run "
  endif

  if executable("py.test") && !executable("pytest")
    return pipenv_prefix . "py.test"
  else
    return pipenv_prefix . "pytest"
  endif
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#python#patterns)
  "let path = [get(name['namespace'], 0, ''), get(name['test'], 0, '')]
  "call filter(path, '!empty(v:val)')
  "return join(path, '::')
  let dtest_str = join(name['namespace'], '::') .'::'. join(name['test'], '::')
  return dtest_str
endfunction
