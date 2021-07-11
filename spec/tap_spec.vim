source spec/support/helpers.vim

describe "TAP"

  before
    cd spec/fixtures/tap
  end

  after
    call Teardown()
    cd -
  end

  it "runs nearest test"
    view +6 tests/normal.js
    TestNearest

    Expect g:test#last_command == "node_modules/.bin/tape tests/normal.js --grep='math test'"

    view +3 tests/subtest.js
    TestNearest

    Expect g:test#last_command == "node_modules/.bin/tape tests/subtest.js --grep='parent'"

    view +4 tests/subtest.js
    TestNearest

    Expect g:test#last_command == "node_modules/.bin/tape tests/subtest.js --grep='subtest'"

    view +12 tests/subtest.js
    TestNearest

    Expect g:test#last_command == "node_modules/.bin/tape tests/subtest.js --grep='An example of a multi-line test'"
  end

  it "runs file tests"
    view tests/normal.js
    TestFile

    Expect g:test#last_command == 'node_modules/.bin/tape tests/normal.js'
  end

  it "runs test suites"
    view tests/normal.js
    TestSuite

    Expect g:test#last_command == 'node_modules/.bin/tape'
  end

  it "also recognizes test/ directory"
    view test/normal.js
    TestFile

    Expect g:test#last_command == 'node_modules/.bin/tape test/normal.js'
  end


  it "runs file tests ending in .test.js"
    view src/normal.test.js
    TestFile

    Expect g:test#last_command == 'node_modules/.bin/tape src/normal.test.js'
  end

  it "runs file tests ending in .spec.js"
    !cp src/normal.test.js src/normal.spec.js
    view src/normal.spec.js
    TestFile
    !rm src/normal.spec.js

    Expect g:test#last_command == 'node_modules/.bin/tape src/normal.spec.js'
  end

  it "it uses the specified reporter if it exists"
    view tests/normal.js
    let g:test#javascript#tap#reporters = ['tap-spec']
    TestFile

      Expect g:test#last_command == 'node_modules/.bin/tape tests/normal.js | node_modules/.bin/tap-spec'
  end

  it "it doesn't use the specified reporter if it doesn't exist"
    view tests/normal.js
    let g:test#javascript#tap#reporters = ['tap-min']
    TestFile

      Expect g:test#last_command == 'node_modules/.bin/tape tests/normal.js'
  end

  it "it uses multiple specified reporters if they exists"
    view tests/normal.js
    let g:test#javascript#tap#reporters = ['tap-notify', 'tap-spec']
    TestFile

      Expect g:test#last_command == 'node_modules/.bin/tape tests/normal.js | node_modules/.bin/tap-notify | node_modules/.bin/tap-spec'
  end

end
