use UR6;
use UR6::Object;
use UR6::BoolExpr;
use UR6::BoolExpr::Template::And;
use UR6::Context::Transaction;
use Test;

plan 4;

class Foo does UR6::Object {
    has Int $.param1 is id;
    has Str $.param2;
}

subtest 'basic' => {
    plan 8;

    my $bx = Foo.define-boolexpr();
    isa-ok $bx, UR6::BoolExpr;
    ok $bx.subject-class ~~ Foo, 'bx subject-class';
    ok $bx.is-matches-all, 'bx no filters matches all';
    ok ! $bx.is-id-only, 'bx no filters is not id-only';

    isa-ok $bx.template, UR6::BoolExpr::Template::And;
    ok $bx.template.subject-class ~~ Foo, 'template subject-class';
    ok $bx.template.is-matches-all, 'template no filters matches all';
    ok ! $bx.template.is-id-only, 'template no filters is not id-only';
};

subtest 'gist' => {
    plan 6;

    my $bx = Foo.define-boolexpr(param1 => '<' => 123, param2 => 'Bob');
    my $str = $bx.gist;
    like $str, /'Foo:'/, 'saw class name';
    like $str, /'param1 => < => 123'/, 'saw filter on param1';
    like $str, /'param2 => = => Bob'/, 'saw filter on param2';

    my $bxt = $bx.template;
    $str = $bxt.gist;
    like $str, /'Foo:'/, 'saw class name on template';
    like $str, /'param1 => <'/, 'saw filter on param1';
    like $str, /'param2 => ='/, 'saw filter on param2';
}

subtest 'filters' => {
    plan 32;

    my $bx = Foo.define-boolexpr(param1 => 123, param2 => '<' => 456);
    isa-ok $bx, UR6::BoolExpr;
    ok ! $bx.is-matches-all, 'bx with filters is not matches-all';
    ok ! $bx.is-id-only, 'bx with non-id filters is not is-only';

    is $bx.operator-for('param1'), '=', 'operator-for param1';
    is $bx.value-for('param1'), 123, 'value-for param1';
    is $bx.value-for('param1', :exists), True, 'value-for param1 exists';
    ok $bx.position-for('param1').defined, 'position-for param1';

    is $bx.operator-for('param2'), '<', 'operator-for param2';
    is $bx.value-for('param2'), 456, 'value-for param2';
    is $bx.value-for('param2', :exists), True, 'value-for param2 exists';
    ok $bx.position-for('param2').defined, 'position-for param2';

    isa-ok $bx.operator-for('nope'), Failure, 'operator for non-existant param is-a Failure';
    isa-ok $bx.value-for('nope'), Failure, 'value for non-existant param is-a Failure';
    is $bx.value-for('nope', :exists), False, 'value for non-existant does not exist';
    ok ! $bx.position-for('nope').defined, 'position-for non-existant param';

    my @attributes = $bx.attributes;
    my @operators = $bx.operators;
    my @values = $bx.values;
    is @attributes[ $bx.position-for('param1') ], 'param1', 'param1 @attributes';
    is @values[ $bx.position-for('param1') ], 123, 'param1 @values';
    is @operators[ $bx.position-for('param1')], '=', 'param1 @operators';
    is @attributes[ $bx.position-for('param2') ], 'param2', 'param1 @attributes';
    is @values[ $bx.position-for('param2') ], 456, 'param2 @values';
    is @operators[ $bx.position-for('param2')], '<', 'param2 @operators';

    my $tmpl = $bx.template;
    ok ! $tmpl.is-matches-all, 'bx with filters is not matches-all';
    ok ! $tmpl.is-id-only, 'bx with non-id filters is not is-only';

    is $tmpl.operator-for('param1'), '=', 'operator-for param1';
    is $tmpl.operator-for('param1', :exists), True, 'operator-for param1 exists';
    ok $tmpl.position-for('param1').defined, 'position-for param1';

    is $tmpl.operator-for('param2'), '<', 'operator-for param2';
    is $tmpl.operator-for('param2', :exists), True, 'operator-for param2 exists';
    ok $tmpl.position-for('param2').defined, 'position-for param2';

    isa-ok $tmpl.operator-for('nope'), Failure, 'operator for non-existant param is-a Failure';
    is $tmpl.operator-for('nope', :exists), False, 'operator for non-existant param does not exist';
    ok $tmpl.position-for('param2').defined, 'position-for param2';
}

subtest 'evaluate' => sub {

    UR6::Context.branch(UR6::Context::Transaction);

    my $obj = Foo.create(param1 => 123, param2 => '456');
    my @tests = ( Foo.define-boolexpr(param1 => 123, param2 => '456')   => True,
                  Foo.define-boolexpr(param1 => 123)                    => True,
                  Foo.define-boolexpr(param2 => 456)                    => True,
                  Foo.define-boolexpr(param1 => 999)                    => False,
                  Foo.define-boolexpr(param1 => 123, param2 => 999)     => False,
                  Foo.define-boolexpr()                                 => True,
                  Foo.define-boolexpr(param1 => '<' => 200)             => True,
                  Foo.define-boolexpr(param1 => '>' => 200)             => False,
                  Foo.define-boolexpr(param1 => '=' => 123, param2 => '>' => 123) => True,
                  Foo.define-boolexpr(param1 => '=' => 999)             => False,
                  Foo.define-boolexpr(param1 => '<=' => 999)            => True,
                  Foo.define-boolexpr(param1 => '<=' => 100)            => False,
                  Foo.define-boolexpr(param1 => '>=' => 999)            => False,
                  Foo.define-boolexpr(param1 => '>=' => 100)            => True,
                  Foo.define-boolexpr(param1 => 'eq' => '123')          => True,
                  Foo.define-boolexpr(param1 => 'eq' => '999')          => False,
                  Foo.define-boolexpr(param1 => 'lt' => '200')          => True,
                  Foo.define-boolexpr(param1 => 'lt' => '100')          => False,
                  Foo.define-boolexpr(param1 => 'gt' => '100')          => True,
                  Foo.define-boolexpr(param1 => 'gt' => '200')          => False,
                  Foo.define-boolexpr(param1 => 'le' => '200')          => True,
                  Foo.define-boolexpr(param1 => 'le' => '100')          => False,
                  Foo.define-boolexpr(param1 => 'ge' => '100')          => True,
                  Foo.define-boolexpr(param1 => 'ge' => '200')          => False,
                  Foo.define-boolexpr(param1 => '!=' => 200)            => True,
                  Foo.define-boolexpr(param1 => '!=' => 123)            => False,
                  Foo.define-boolexpr(param1 => 'not >' => 200)         => True,
                  Foo.define-boolexpr(param1 => 'not >' => 100)         => False,
                  Foo.define-boolexpr(param1 => 100..200)               => True,
                  Foo.define-boolexpr(param1 => 'between' => 0..100)    => False,
                );

    plan @tests.elems;
    for @tests -> $test {
        my ($bx, $expected) = $test.kv;

        is $bx.evaluate($obj), $expected, "evaluate { $bx.gist }";
    }
}

# vim: set syntax=perl6
