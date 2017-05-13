use UR6;
use UR6::Object;
use UR6::BoolExpr;
use UR6::BoolExpr::Template::And;
use Test;

plan 1;

class Foo does UR6::Object {
    has Int $.param1;
    has Str $.param2;
}

subtest 'basic' => {
    plan 8;

    my $bx = Foo.define-boolexpr;
    isa-ok $bx, UR6::BoolExpr;
    ok $bx.subject-class ~~ Foo, 'bx subject-class';
    ok $bx.is-matches-all, 'bx no filters matches all';
    ok ! $bx.is-id-only, 'bx no filters is not id-only';

    isa-ok $bx.template, UR6::BoolExpr::Template::And;
    ok $bx.template.subject-class ~~ Foo, 'template subject-class';
    ok $bx.template.is-matches-all, 'template no filters matches all';
    ok ! $bx.template.is-id-only, 'template no filters is not id-only';
};

# vim: set syntax=perl6
