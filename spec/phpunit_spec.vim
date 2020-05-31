source spec/support/helpers.vim

describe "PHPUnit"

  before
    cd spec/fixtures/phpunit
    !mkdir vendor
    !mkdir vendor/bin
  end

  after
    !rm -f artisan
    !rm -f vendor/bin/*
    call Teardown()
    cd -
  end

  it "runs file tests"
    view NormalTest.php
    TestFile

    Expect g:test#last_command == 'phpunit --colors NormalTest.php'
  end

  it "runs nearest tests"
    view +1 NormalTest.php
    TestNearest

    Expect g:test#last_command == "phpunit --colors NormalTest.php"

    view +9 NormalTest.php
    TestNearest

    Expect g:test#last_command == "phpunit --colors --filter '::testShouldAddTwoNumbers' NormalTest.php"

    view +14 NormalTest.php
    TestNearest

    Expect g:test#last_command == "phpunit --colors --filter '::testShouldSubtractTwoNumbers' NormalTest.php"

    view +30 NormalTest.php
    TestNearest

    Expect g:test#last_command == "phpunit --colors --filter '::testShouldAddToExpectedValue' NormalTest.php"
  end

  it  "runs nearest test marked with @test annotation"
    view +40 NormalTest.php
    TestNearest

    Expect g:test#last_command == "phpunit --colors --filter '::aTestMarkedWithTestAnnotation' NormalTest.php"

    view +50 NormalTest.php
    TestNearest

    Expect g:test#last_command == "phpunit --colors --filter '::aTestMarkedWithTestAnnotationAndCrazyDocblock' NormalTest.php"
  end

  it  "runs nearest test containing an anonymous class"
    view +61 NormalTest.php
    TestNearest

    Expect g:test#last_command == "phpunit --colors --filter '::testWithAnAnonymousClass' NormalTest.php"

    view +76 NormalTest.php
    TestNearest

    Expect g:test#last_command == "phpunit --colors --filter '::aTestMakedWithTestAnnotationAndWithAnAnonymousClass' NormalTest.php"
  end

  " Fix for: https://github.com/janko/vim-test/issues/361
  it "runs nearest test with a one line @test annotation"
    view +83 NormalTest.php
    TestNearest

    Expect g:test#last_command == "phpunit --colors --filter '::aTestMarkedWithTestAnnotationOnOneLine' NormalTest.php"
  end

  it "runs test suites"
    view NormalTest.php
    TestSuite

    Expect g:test#last_command == 'phpunit --colors'
  end

  it "doesn't recognize files that don't end with 'Test'"
    view normal.php
    TestFile

    Expect exists('g:test#last_command') == 0
  end

  it "uses Laravel's artisan command if present"
    !touch artisan
    view NormalTest.php
    TestFile

    Expect g:test#last_command == 'php artisan test --colors NormalTest.php'
  end

  describe "when paratest is installed in vendor/bin"

    before
      !touch vendor/bin/paratest
    end

    it "executes paratest for TestFile"
      !touch vendor/bin/paratest
      view NormalTest.php
      TestFile

      Expect g:test#last_command == './vendor/bin/paratest --colors NormalTest.php'
    end

    it "executes paratest for TestSuite"
      view NormalTest.php
      TestSuite

      Expect g:test#last_command == './vendor/bin/paratest --colors'
    end

    it "executes paratest in functional mode for TestNearest with --filter"
      view +1 NormalTest.php
      TestNearest

      Expect g:test#last_command == "./vendor/bin/paratest --colors NormalTest.php"

      view +9 NormalTest.php
      TestNearest

      Expect g:test#last_command == "./vendor/bin/paratest --colors --functional --filter '::testShouldAddTwoNumbers' NormalTest.php"
    end

  end

end
