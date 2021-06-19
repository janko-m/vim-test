if exists('g:loaded_test')
  finish
endif
let g:loaded_test = 1

let g:test#plugin_path = expand('<sfile>:p:h:h')

let g:test#default_runners = {
  \ 'CSharp':     ['Xunit', 'DotnetTest'],
  \ 'Clojure':    ['FireplaceTest'],
  \ 'Crystal':    ['CrystalSpec'],
  \ 'Dart':       ['DartTest', 'FlutterTest'],
  \ 'Elixir':     ['ExUnit', 'ESpec'],
  \ 'Elm':        ['ElmTest'],
  \ 'Erlang':     ['CommonTest', 'EUnit'],
  \ 'Go':         ['GoTest', 'Ginkgo', 'RichGo', 'Delve'],
  \ 'Haskell':    ['StackTest'],
  \ 'Java':       ['MavenTest', 'GradleTest'],
  \ 'JavaScript': ['Ava', 'CucumberJS', 'DenoTest', 'Intern', 'TAP', 'Karma', 'Lab', 'Mocha',  'NgTest', 'Jasmine', 'Jest', 'ReactScripts', 'WebdriverIO', 'Cypress'],
  \ 'Kotlin':     ['GradleTest'],
  \ 'Lua':        ['Busted'],
  \ 'PHP':        ['Codeception', 'Dusk', 'Pest', 'PHPUnit', 'Behat', 'PHPSpec', 'Kahlan', 'Peridot'],
  \ 'Perl':       ['Prove'],
  \ 'Python':     ['Behave', 'DjangoTest', 'PyTest', 'PyUnit', 'Nose', 'Nose2', 'Mamba'],
  \ 'R':          ['TestThat'],
  \ 'Racket':     ['RackUnit'],
  \ 'Ruby':       ['Rails', 'M', 'Minitest', 'RSpec', 'Cucumber', 'TestBench'],
  \ 'Rust':       ['CargoTest'],
  \ 'Scala':      ['SbtTest', 'BloopTest'],
  \ 'Shell':      ['Bats'],
  \ 'Swift':      ['SwiftPM'],
  \ 'VimL':       ['Themis', 'VSpec', 'Vader', 'Testify', 'Vroom'],
\}

let g:test#custom_strategies = get(g:, 'test#custom_strategies', {})
let g:test#custom_transformations = get(g:, 'test#custom_transformations', {})
let g:test#runner_commands = get(g:, 'test#runner_commands', [])

command! -nargs=* -bar TestNearest call test#run('nearest', split(<q-args>))
command! -nargs=* -bar -complete=file
      \                TestFile    call test#run('file', split(<q-args>))
command! -nargs=* -bar TestSuite   call test#run('suite', split(<q-args>))
command! -nargs=* -bar TestLast    call test#run_last(split(<q-args>))
command!          -bar TestVisit   call test#visit()

for [s:language, s:runners] in items(test#get_runners())
  for s:runner in s:runners
    if index(g:test#runner_commands, s:runner) != -1
      if exists(':'.s:runner) | continue | endif
      let s:runner_id = tolower(s:language).'#'.tolower(s:runner)
      execute 'command! -bar -nargs=* -complete=file'
            \ s:runner
            \ 'call test#execute("'.s:runner_id.'", split(<q-args>))'
    endif
  endfor
endfor

if &autochdir
  let g:test#project_root = getcwd()
endif
