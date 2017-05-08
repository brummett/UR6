use UR6;
use UR6::Entity;
use UR6::DataSource::Default;
use UR6::DataSource::ResultSet;
use Test;

plan 1;

my %load-args;
class NamedThing
    does UR6::Entity
    is data-source(UR6::DataSource::Default)
{
    has Int $.id is id is column<id>;
    has Str $.name is column<name>;

    method __load__(*%args) {
        %load-args = %args;
        UR6::DataSource::ResultSet.new(
            headers => ('id', 'name'),
            content => ( (1, 'one'), (2, 'two'), (3, 'three') )
        );
    }
    method __save__ { ... }
}

class NamedThingResultSetBackwards
    does UR6::Entity
    is NamedThing
    is data-source(UR6::DataSource::Default)
{
    method __load__(*%args) {
        %load-args = %args;
        UR6::DataSource::ResultSet.new(
            headers => ('name', 'id'),
            content => ( ('one', 1), ('two', 2), ('three', 3) )
        );
    }
}

subtest 'get' => {
    plan 2;

    for ( NamedThing, NamedThingResultSetBackwards ) -> $class {
        subtest "for class { $class.^name }" => {
            plan 5;

            my @objs = $class.get();
            is @objs.elems, 3, 'get() returned all NamedThing objects';
            for @objs -> $obj {
                #ok $obj ~~ $class, 'Object is NamedThing';
                isa-ok $obj, $class;
            }
            is %load-args, { filter => {}, headers => <id name> }, 'args to __load__';
        }
    }
}

# vim: set syntax=perl6
