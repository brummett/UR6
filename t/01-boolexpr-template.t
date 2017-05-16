use UR6;
use UR6::Object;
use UR6::BoolExpr;
use UR6::BoolExpr::Template::And;
use Test;

plan 2;

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

subtest 'filters' => {
    plan 26;

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


# vim: set syntax=perl6
