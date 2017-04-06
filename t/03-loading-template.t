use Test;
use UR6::DataSource::LoadingTemplate;
use UR6::DataSource;

plan 14;

my class DummyDataSource does UR6::DataSource { method query { ... } };

use UR6;
use UR6::Entity;
my class Foo does UR6::Entity is data-source(DummyDataSource) is table-name<foo> {
    has $.id is id is column<id_col>;
    has $.name is column<name>;
    has $.val is column<val>;
}

my %construction-params = type => Foo, object-num => 0, table-alias => 'foo', start-col => 0;
for %construction-params.keys -> $omit-key {
    my %params = %construction-params;
    %params{$omit-key}:delete;
    throws-like { UR6::DataSource::LoadingTemplate.new(|%params) },
        Exception, message => /"Required named parameter '$omit-key' not passed"/,
        "new omitting $omit-key throws exception";
}


my %expected =  data-type => Foo,
                final-type => Foo,
                object-num => 0,
                table-alias => 'foo',
                attribute-names => ['id', 'name', 'val'],
                column-names => ['id_col', 'name', 'val'],
                attribute-positions => [ 3, 4, 5 ],
                id-attribute-positions => [ 3 ],
              ;  
                
my $tmpl = UR6::DataSource::LoadingTemplate.new(
                type => Foo,
                object-num => %expected<object-num>,
                table-alias => %expected<table-alias>,
                start-col => 3,
            );
ok $tmpl, 'create LoadingTemplate';

for %expected.kv -> $key, $expected {
    is $tmpl."$key"(), $expected, $key;
}

my @row = 0, 1, 2, 'id', 'bob', 'cool';
is $tmpl.id-resolver.( @row ) , 'id', 'id-resolver';
