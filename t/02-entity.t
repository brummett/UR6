use UR6;
use UR6::DataSource::Default;
use Test;

plan 1;

subtest 'construction' => {
    plan 6;

    throws-like q[use UR6::Entity; class A does UR6::Entity { }],
        Exception,
        message => /'Class A has no data-source'/,
        "Cannot make an Entity without data-source";

    eval-lives-ok q :to<CREATE>,
        use UR6::Entity;
        my class A does UR6::Entity is data-source(UR6::DataSource::Default) { };
        is A.HOW.data-source, UR6::DataSource::Default, "A's data-source";
    CREATE
    'Created Entity with data-source';

    eval-lives-ok q :to<CREATE>,
        use UR6::Entity;
        my class A1 does UR6::Entity is data-source(UR6::DataSource::Default) is table-name('foo') { };
        is A1.HOW.data-source, UR6::DataSource::Default, "A1's data-source";
        is A1.HOW.table-name, 'foo', "A1's table-name";
    CREATE
    'Created Entity with data-source and table-name';
}

# vim: set syntax=perl6
