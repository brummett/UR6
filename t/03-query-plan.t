use Test;
use UR6::DataSource::QueryPlan;
use UR6::DataSource;

class DummyDataSource does UR6::DataSource { method query { ... } };

plan 1;

subtest 'basic' => {
    plan 18;

    use UR6;
    use UR6::Entity;
    my class Foo does UR6::Entity is data-source(DummyDataSource) is table-name<foo> {
        has $.id is id is column<id_col>;
        has $.name is column<name>;
        has $.val is column<val>;
    }

    my $qp = UR6::DataSource::QueryPlan.new(:type(Foo), :filters({ name => 'Bob', val => 2 }));
    ok $qp, 'new';

    is-deeply $qp.filters, { name => 'Bob', val => 2}, 'filters';
    is $qp.type, Foo, 'type';
    is-deeply $qp.columns, ('id_col', 'name', 'val'), 'columns';

    my @loading-templates = $qp.loading-templates;
    is @loading-templates.elems, 1, '1 loading template';

    my %loading-templates-expected = object-num => 0,
                                     table-alias => '',
                                     data-type => Foo,
                                     final-type => Foo,
                                     attribute-names => ('id', 'name', 'val'),
                                     column-names => ('id_col', 'name', 'val'),
                                     attribute-positions => (0, 1, 2),
                                     id-attribute-positions => (0),
                                   ;
    for %loading-templates-expected.kv -> $method, $val {
        is @loading-templates[0]."$method"(), $val, "loading template $method";
    }

    is $qp.object-fabricators.elems, 1, '1 object-fabricator';
    my $obj = $qp.object-fabricators[0].fabricate( (1, 'Bob', 2) );
    ok $obj ~~ Foo, 'fabricate';
    is $obj.id, 1, 'object id';
    is $obj.name, 'Bob', 'object name';
    is $obj.val, 2, 'object val';
}
