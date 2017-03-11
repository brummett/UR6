use UR6;
use UR6::Object;
use UR6::Context;
use UR6::Context::Transaction;
use Test;

plan 2;

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

    @objects = Foo.get(__id => $obj-id);
    is @objects.elems, 1, 'Get 1 object by __id';
    ok @objects[0] === $obj, 'was the same object';

    ok $obj.delete(), 'delete object';
    @objects = Foo.get();
    is @objects.elems, 0, 'get() returned 0 objects';
    ok ! Foo.get(__id => $obj-id), 'get by-id returns nothing';
}

subtest 'get with simple filters' => {
    plan 15;

    ok my $o1 = Foo.create(param1 => 1, param2 => 'two'),  'create';
    ok my $o2 = Foo.create(param1 => 1, param2 => 'foo'),  'create';
    ok my $o3 = Foo.create(param1 => 10, param2 => 'bar'), 'create';
    ok my $o4 = Foo.create(param1 => 20, param2 => 'bar'), 'create';

    my @results = Foo.get(param1 => 10);
    is @results.elems, 1, 'get() with a filter matches 1 object';
    ok @results[0] === $o3, 'got the right object';

    @results = Foo.get(param2 => 'foo');
    is @results.elems, 1, 'get() with 1 other filter matches 1 object';
    ok @results[0] === $o2, 'got the right other object';

    @results = Foo.get(param1 => 1);
    is @results.elems, 2, 'filter matches 2 objects';
    ok @results>>.__id.contains(all($o1.__id, $o2.__id)), 'Got both objects back';

    @results = Foo.get(param2 => 'bar');
    is @results.elems, 2, 'filter on other property matches 2 objects';
    ok @results>>.__id.contains(all($o3.__id, $o4.__id)), 'Got both objects back';

    @results = Foo.get(param1 => 99);
    is @results.elems, 0, 'filter matching nothing returns 0 objects';

    @results = Foo.get(param1 => 1, param2 => 'foo');
    is @results.elems, 1, 'get() with two filters matched 1 object';
    ok @results[0] === $o2, 'got the right object back';
}

# vim: set syntax=perl6
