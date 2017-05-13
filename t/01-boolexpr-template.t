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
    plan 4;

    my $bx = Foo.define-boolexpr;
    isa-ok $bx, UR6::BoolExpr;
    ok $bx.subject-class ~~ Foo, 'bx subject-class';

    isa-ok $bx.template, UR6::BoolExpr::Template::And;
    ok $bx.template.subject-class ~~ Foo, 'template subject-class';
};

# vim: set syntax=perl6
