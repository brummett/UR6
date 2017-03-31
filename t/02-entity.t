use UR6;
use UR6::DataSource;
use Test;

plan 2;

class SomeDataSource does UR6::DataSource { }

subtest 'construction' => {
    plan 6;

    throws-like q[use UR6::Entity; class A does UR6::Entity { }],
        Exception,
        message => /'Class A has no data-source'/,
        "Cannot make an Entity without data-source";

    eval-lives-ok q :to<CREATE>,
        use UR6;
        use UR6::Entity;
        my class A does UR6::Entity is data-source(SomeDataSource) { };
        is A.HOW.data-source, SomeDataSource, "A's data-source";
    CREATE
    'Created Entity with data-source';

    eval-lives-ok q :to<CREATE>,
        use UR6;
        use UR6::Entity;
        my class A1 does UR6::Entity is data-source(SomeDataSource) is table-name('foo') { };
        is A1.HOW.data-source, SomeDataSource, "A1's data-source";
        is A1.HOW.table-name, 'foo', "A1's table-name";
    CREATE
    'Created Entity with data-source and table-name';
}

subtest 'column info' => {
    plan 2;

    use UR6::Entity;
    my class E does UR6::Entity is data-source(SomeDataSource) is table-name<foo> {
        has $.a is id is column<id>;
        has $.b is column<col_b>;
        has $.c;
    }

    is E.^table-name, 'foo', 'table name';
    is E.^data-source, SomeDataSource, 'data-source';

}

# vim: set syntax=perl6
