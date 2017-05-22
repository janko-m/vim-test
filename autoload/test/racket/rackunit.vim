if !exists('g:test#racket#rackunit#file_pattern')
  let g:test#racket#rackunit#file_pattern = '\v(t|T)est\.rkt$'
endif

function! test#racket#rackunit#test_file(file) abort
  return a:file =~# g:test#racket#rackunit#file_pattern
endfunction

function! test#racket#rackunit#build_position(type, position) abort
  return [a:position['file']]
endfunction

function! test#racket#rackunit#build_args(args) abort
  return a:args
endfunction

function! test#racket#rackunit#executable() abort
  return 'racket'
endfunction

function! s:nearest_test(position)
  return 'This functionality is not available in rackunit'
endfunction
