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
    plan 6;

    UR6::Context.branch(UR6::Context::Transaction);

    my $obj = Foo.create(param1 => 1, params2 => 'two');
    ok $obj, 'Created object';
    ok $obj.__id, 'object has __id';

    my @objects = Foo.get();
    is @objects.elems, 1, 'get() with no params returns the one created object';
    ok @objects[0] === $obj, 'It is the same object we just created';

    my $o2 = Foo.get($obj.__id);
    ok $o2, 'get() an object by __id';
    ok $obj === $o2, 'was the same object';
}

# vim: set syntax=perl6
