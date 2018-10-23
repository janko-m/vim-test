if !exists('g:test#ruby#cucumber#file_pattern')
  let g:test#ruby#cucumber#file_pattern = '\v\.feature$'
endif

function! test#ruby#cucumber#test_file(file) abort
  if a:file =~# g:test#ruby#cucumber#file_pattern
    if <SID>has_ruby_children(expand('%:h'))
      return 1
    else
      let l:featuresDir = finddir('features', getcwd() . '/**')
      return <SID>has_ruby_children(l:featuresDir)
  endif
  return 0
endfunction

function! s:has_ruby_children(dir) abort
  return !empty(glob(a:dir . '/**/*.rb'))
endfunction

function! test#ruby#cucumber#build_position(type, position) abort
  if a:type ==# 'nearest'
    return [a:position['file'].':'.a:position['line']]
  elseif a:type ==# 'file'
    return [a:position['file']]
  else
    return []
  endif
endfunction

function! test#ruby#cucumber#build_args(args) abort
  let args = a:args

  if test#base#no_colors()
    let args = ['--no-color'] + args
  endif

  return args
endfunction

function! test#ruby#cucumber#executable() abort
  if !empty(glob('.zeus.sock'))
    return 'zeus cucumber'
  elseif filereadable('./bin/cucumber') && get(g:, 'test#ruby#use_binstubs', 1)
    return './bin/cucumber'
  elseif filereadable('Gemfile') && get(g:, 'test#ruby#bundle_exec', 1)
    return 'bundle exec cucumber'
  else
    return 'cucumber'
  endif
endfunction
