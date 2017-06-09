use Test;
use UR6::Context::ObjectFabricator;
use UR6::DataSource::LoadingTemplate;
use UR6::DataSource;

class DummyDataSource does UR6::DataSource { method query { ... } };

plan 1;

subtest 'basic' => {
    plan 7;

    use UR6;
    use UR6::Entity;
    my class Foo is UR6::Object does UR6::Entity is data-source(DummyDataSource) is table-name<foo> {
        has $.id is id is column<id_col>;
        has $.name is column<name>;
        has $.val is column<val>;
    }

    my $tmpl = UR6::DataSource::LoadingTemplate.new(:type(Foo), :object-num(2), :table-alias(''), :start-col(3));
    ok $tmpl, 'create LoadingTemplate';
    my $fab = UR6::Context::ObjectFabricator.new(:loading-template($tmpl));
    ok $fab, 'create ObjectFabricator';

    my $obj = $fab.fabricate( ( 1, 2, 3, 'the_id', 'Bob', 123, 7, 8, 9 ) );
    ok $obj ~~ Foo, 'fabricate Foo';
    is $obj.id , 'the_id', 'object id';
    is $obj.__id, 'the_id', 'object __id';
    is $obj.name, 'Bob', 'object name';
    is $obj.val, 123, 'object val';
}
