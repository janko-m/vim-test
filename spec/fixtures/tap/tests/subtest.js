const test = require('tap');

tap.test("parent", function(t) {
    t.test("subtest", function(t) {
        t.ok(1)
        t.end()
    })
    t.end()
})

tap.test(
    'An example of a multi-line test',
    function(t) {
        t.ok(1)
        t.end()
    }
);
