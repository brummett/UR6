use UR6;
use Test;

plan 3;

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

subtest 'object-sorter' => {
    plan 9;
    use UR6::Object;

    my class Strs does UR6::Object {
        has Str $.a is id;
    }
    my $o1 = Strs.new(a => 'a');
    my $o2 = Strs.new(a => 'b');
    my $o3 = Strs.new(a => 'a');

    my $sorter = Strs.HOW.object-sorter();
    is $sorter($o1, $o2), Order::Less, 'a sorts less than b';
    is $sorter($o2, $o1), Order::More, 'b sorts more than a';
    is $sorter($o1, $o1), Order::Same, 'a sorts same as a';
    is $sorter($o1, $o3), Order::Same, 'a sorts same as a, different objects';


    my class Ints does UR6::Object {
        has Int $.a is id;
    }
    $o1 = Ints.new(a => 1);
    $o2 = Ints.new(a => 2);
    $o3 = Ints.new(a => 01);

    $sorter = Ints.HOW.object-sorter();
    is $sorter($o1, $o2), Order::Less, '1 sorts less than 2';
    is $sorter($o2, $o1), Order::More, '2 sorts more than 1';
    is $sorter($o1, $o1), Order::Same, '1 sorts same as 1';
    is $sorter($o1, $o3), Order::Same, '1 sorts same as 01, different objects';


    my class MultiId does UR6::Object {
        has Str $.str is id;
        has Int $.int is id;
    }
    # Created in reverse-sorted order
    $o3 = MultiId.new(str => 'b', int => 2);
    $o2 = MultiId.new(str => 'a', int => 2);
    $o1 = MultiId.new(str => 'a', int => 1);

    $sorter = MultiId.HOW.object-sorter;
    is ($o3,$o2,$o1).sort($sorter), ($o1, $o2, $o3), 'sorted multi-id objects';
}

# vim: set syntax=perl6
