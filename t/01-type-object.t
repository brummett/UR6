use UR6;
use Test;

plan 2;

subtest 'implied ID attribute' => {
    plan 3;
    use UR6::Object;

    my class ImpliedId does UR6::Object {
        has $.a;
    }

    my $class-obj = ImpliedId.HOW;
    ok $class-obj ~~ UR6::Object::ClassHOW, 'class obj is-a UR6::Object::ClassHOW';

    my @id-attribs = $class-obj.id-attributes;
    is @id-attribs.elems, 1, 'has 1 ID attribute';
    is @id-attribs[0].name, '$!__id', 'is the implied $!__id attribute';
}

subtest 'explicit ID attributes' => {
    plan 6;
    use UR6::Object;

    my class HasId does UR6::Object {
        has $.a is id;
        has $.not-id;
    }

    my @id-attribs = HasId.HOW.id-attributes;
    is @id-attribs.elems, 1, 'HasId ID attribute';
    is @id-attribs[0].name, '$!a', 'ID attrib name';

    my class HasIdChild is HasId {
        has $.b is id;
    }
    @id-attribs = HasIdChild.HOW.id-attributes;
    is @id-attribs.elems, 2, 'HasIdChild ID attributes';
    is-deeply @id-attribs>>.name, ['$!b', '$!a'], 'ID attrib names';

    my class HasManyId does UR6::Object {
        has $.a is id;
        has $.b is id;
        has $.c is id;
    }
    @id-attribs = HasManyId.HOW.id-attributes;
    is @id-attribs.elems, 3, 'HasIdChild ID attributes';
    is-deeply @id-attribs>>.name, ['$!a', '$!b', '$!c'], 'ID attrib names';
}

# vim: set syntax=perl6
