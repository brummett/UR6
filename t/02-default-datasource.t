use UR6;
use UR6::Object;
use UR6::Context;
use UR6::DataSource::Default;
use Test;

plan 1;

class Test::DataSource is UR6::DataSource::Default {

}

class IsEntity does UR6::Entity[data-source => Test::DataSource] {
    has Int $.param1;
    has Str $.param2;

    method __load__ { ... }
}

class NotEntity does UR6::Object {
    has Int $.param1;
    has Str $.param2;
}

subtest 'get() on non-entity' => {
    plan 1;

    my @results = NotEntity.get(param1 => 1);
@results.elems.say;
    is @results.elems, 0, 'get() on NotEntity returns 0 objects';
}

# vim: set syntax=perl6
