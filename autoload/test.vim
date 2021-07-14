function! test#run(type, arguments) abort
  call s:before_run()

  let alternate_file = s:alternate_file()

  let position_result = s:determine_position_and_file(alternate_file)
  
  if empty(position_result)
    return
  endif

  let [runner_file, position] = position_result

  call s:set_test_runners(runner_file)

  let runner = test#determine_runner(position['file'])

  let args = test#base#build_position(runner, a:type, position)
  let args = a:arguments + args
  let args = test#base#options(runner, args, a:type)

  if type(get(g:, 'test#strategy')) == type({})
    let strategy = get(g:test#strategy, a:type)
    call test#execute(runner, args, strategy)
  else
    call test#execute(runner, args)
  endif

  call s:after_run()
endfunction

function! s:determine_position_and_file(alternate_file) abort
  call s:set_test_runners(expand('%:p'))

  if test#test_file(expand('%'))
    let position = s:get_position(expand('%'))
    let g:test#last_position = position
    return [expand('%:p'), position]
  endif

  if !empty(a:alternate_file)
    call s:set_test_runners(a:alternate_file)

    if test#test_file(a:alternate_file) && (!exists('g:test#last_position') || a:alternate_file !=# g:test#last_position['file'])
      let position = s:get_position(a:alternate_file)

      return [a:alternate_file, position]
    endif
  endif

  if exists('g:test#last_position')
    call s:set_test_runners(expand('%:p'))
    let position = g:test#last_position
    return [expand('%:p'), position]
  endif

  call s:echo_failure('Not a test file') 
endfunction

function! test#run_last(arguments) abort
  if exists('g:test#last_command')
    call s:before_run()

    let strategy = s:extract_strategy_from_command(a:arguments)

    if empty(strategy)
      let strategy = g:test#last_strategy
    endif

    let cmd = [g:test#last_command]
    let cmd = cmd + a:arguments

    call test#shell(join(cmd), strategy)

    call s:after_run()
  else
    call s:echo_failure('No tests were run so far')
  endif
endfunction

function! test#exists() abort
  return test#test_file(expand('%')) || test#test_file(s:alternate_file())
endfunction

function! test#visit() abort
  if exists('g:test#last_position')
    execute 'edit' '+'.g:test#last_position['line'] g:test#last_position['file']
  else
    call s:echo_failure('No tests were run so far')
  endif
endfunction

function! test#execute(runner, args, ...) abort
  let strategy = s:extract_strategy_from_command(a:args)
  if empty(strategy)
    if !empty(a:000)
      let strategy = a:1
    else
      let strategy = get(g:, 'test#strategy')
    endif
  endif
  if empty(strategy)
    let strategy = 'basic'
  endif

  let args = a:args
  let args = test#base#options(a:runner, args)
  call filter(args, '!empty(v:val)')

  let executable = test#base#executable(a:runner)
  let args = test#base#build_args(a:runner, args, strategy)
  let cmd = [executable] + args
  call filter(cmd, '!empty(v:val)')

  call test#shell(join(cmd), strategy)
endfunction

function! test#shell(cmd, strategy) abort
  let g:test#last_command = a:cmd
  let g:test#last_strategy = a:strategy

  let cmd = a:cmd

  if has_key(g:, 'test#transformation')
    let cmd = g:test#custom_transformations[g:test#transformation](cmd)
  endif

  if cmd =~# '^:'
    let strategy = 'vimscript'
  else
    let strategy = a:strategy
  endif

  if has_key(g:test#custom_strategies, strategy)
    call g:test#custom_strategies[strategy](cmd)
  else
    call test#strategy#{strategy}(cmd)
  endif
endfunction

function! test#determine_runner(file) abort
  for [language, runners] in items(test#get_runners())
    for runner in runners
      let runner = tolower(language).'#'.tolower(runner)
      if exists("g:test#enabled_runners")
        if index(g:test#enabled_runners, runner) < 0
          continue
        endif
      endif
      if test#base#test_file(runner, fnamemodify(a:file, ':.'))
        return runner
      endif
    endfor
  endfor
endfunction

function! test#get_runners() abort
  if exists('g:test#runners')
    let custom_runners = g:test#runners
  elseif exists('g:test#custom_runners')
    let custom_runners = g:test#custom_runners
  else
    let custom_runners = {}
  endif

  return s:extend(custom_runners, g:test#default_runners)
endfunction

function! test#test_file(file) abort
  return !empty(test#determine_runner(a:file))
endfunction

function! s:set_test_runners(file) abort 
  if !exists('g:loaded_projectionist')
    return
  endif 

  let result = projectionist#query('test-runner', {'file': a:file})

  if empty(result)
    return
  endif

  let runner_map = get(get(result, 0, []), 1, {})

  if type(runner_map) !=# type({})
    call s:echo_failure('Value of `test-runner` key must be a map!')
    return
  endif

  for [language, value] in items(runner_map)
    if type(value) == type('')
      let g:['test#' . language . '#runner'] = value

      let target_key = 'test#' . language . '#' . value . '#options'

      if exists(target_key)
        unlet g:[target_key]
      endif
    endif

    if type(value) == type({})
      let runner = value['runner']

      if empty(runner)
        continue
      endif

      let g:['test#' . language . '#runner'] = runner

      if has_key(value, 'options')
        let options = value['options']
        let g:['test#' . language . '#' . runner . '#options'] = options
      else
        unlet b:['test#' . language . '#' . runner . '#options']
      endif
    endif
  endfor

endfunction

function! s:alternate_file() abort
  if get(g:, 'test#no_alternate') | return '' | endif
  let alternate_file = ''

  if empty(alternate_file) && exists('g:loaded_projectionist')
    let alternate_file = get(filter(projectionist#query_file('alternate'), 'filereadable(v:val)'), 0, '')
  endif

  if empty(alternate_file) && exists('g:loaded_rails') && !empty(rails#app())
    let alternate_file = rails#buffer().alternate()
  endif

  return alternate_file
endfunction

function! s:before_run() abort
  if &autowrite || &autowriteall
    silent! wall
  endif

  if exists('g:test#project_root')
    execute 'cd' g:test#project_root
  endif
endfunction

function! s:after_run() abort
  if exists('g:test#project_root')
    execute 'cd -'
  endif
endfunction

function! s:get_position(path) abort
  let filename_modifier = get(g:, 'test#filename_modifier', ':.')

  let position = {}
  let position['file'] = fnamemodify(a:path, filename_modifier)
  let position['line'] = a:path == expand('%') ? line('.') : 1
  let position['col']  = a:path == expand('%') ? col('.') : 1

  return position
endfunction

function! s:extract_strategy_from_command(arguments) abort
  for idx in range(0, len(a:arguments) - 1)
    if a:arguments[idx] =~# '^-strategy='
      return substitute(remove(a:arguments, idx), '-strategy=', '', '')
    endif
  endfor
endfunction

function! s:echo_failure(message) abort
  echohl WarningMsg
  echo a:message
  echohl None
endfunction

function! s:extend(source, dict) abort
  let result = {}
  for [key, value] in items(a:source)
    let result[key] = value
  endfor
  for [key, value] in items(a:dict)
    let result[key] = get(result, key, []) + value
  endfor
  return result
endfunction
