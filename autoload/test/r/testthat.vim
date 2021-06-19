if !exists('g:test#r#testthat#file_pattern')
  let g:test#r#testthat#file_pattern = '\v(test-[^/]+|[^/]+)\.R$'
endif

function! test#r#testthat#test_file(file)
  if fnamemodify(a:file, ':t') =~# g:test#r#testthat#file_pattern
    return executable("Rscript")
  endif
endfunction

function! test#r#testthat#build_position(type, position)
  if a:type ==# 'nearest'
    call s:echo_failure('TestNearest not implemented for testthat') | return []
    " let name = s:nearest_test(a:position)
    if !empty(name)
      return [s:assemble_file_filter(a:position['file'])]
    else
      return [s:assemble_file_filter(a:position['file'])]
    endif
  elseif a:type ==# 'file'
    return [s:assemble_file_filter(a:position['file'])]
  else
    return []
  endif
endfunction

function! test#r#testthat#build_args(args)
  let args = a:args
  return args
endfunction

function! test#r#testthat#executable()
  return "Rscript"
endfunction

function! s:assemble_file_filter(path)
  let path = a:path
  let file = split(path, '-')[1]
  let fileName = split(file, '\.')[0]
  let f = "-e \"library(testthat); test_local(filter='".fileName."')\""
  return f
endfunction

function! s:echo_failure(message) abort
  echohl WarningMsg
  echo a:message
  echohl None
endfunction

