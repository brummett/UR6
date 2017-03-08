use UR6;
use UR6::Object;
use UR6::Context;
use UR6::Context::Transaction;
use Test;

plan 1;

class Foo does UR6::Object {
    has Int $.param1;
    has Str $.param2;
}

subtest 'create' => {
    plan 2;

    UR6::Context.branch(UR6::Context::Transaction);

    my $obj = Foo.create(param1 => 1, params2 => 'two');
    ok($obj, 'Created object');
    ok($obj.__id, 'object has __id');
}

# vim: set syntax=perl6
