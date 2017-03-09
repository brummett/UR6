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

UR6::Context.branch(UR6::Context::Transaction);

subtest 'create/get/delete' => {
    plan 9;

    my $obj = Foo.create(param1 => 1, param2 => 'two');
    ok $obj, 'Created object';
    my $obj-id = $obj.__id;
    ok $obj-id, 'object has __id';

    my @objects = Foo.get();
    is @objects.elems, 1, 'get() with no params returns the one created object';
    ok @objects[0] === $obj, 'It is the same object we just created';

    my $o2 = Foo.get($obj-id);
    ok $o2, 'get() an object by __id';
    ok $obj === $o2, 'was the same object';

    ok $obj.delete(), 'delete object';
    @objects = Foo.get();
    is @objects.elems, 0, 'get() returned 0 objects';
    ok ! Foo.get($obj-id), 'get by-id returns nothing';
}

# vim: set syntax=perl6
