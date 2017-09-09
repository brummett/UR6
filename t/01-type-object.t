use UR6;
use Test;

plan 5;

subtest 'implied ID attribute' => {
    plan 7;
    use UR6::Object;

    my class ImpliedId is UR6::Object {
        has $.a;
    }

    my $class-obj = ImpliedId.HOW;
    ok $class-obj ~~ UR6::Object::ClassHOW, 'class obj is-a UR6::Object::ClassHOW';

    my @attribs = $class-obj.get-attributes();
    is @attribs.elems, 2, 'has 2 attributes';
    is-deeply @attribs>>.name, ['$!a', '$!__id'], 'attribute names';

    my @id-attribs = $class-obj.get-attributes(:id, :!explicit);
    is @id-attribs.elems, 1, 'has 1 ID attribute';
    is @id-attribs[0].name, '$!__id', 'is the implied $!__id attribute';

    is $class-obj.get-attributes(:id).elems, 0, 'Class has no explicit ID attributes';
    is $class-obj.get-attribute-names(:id).elems, 0, 'Class has no explicit ID attribute names';
}

subtest 'explicit ID attributes' => {
    plan 6;
    use UR6::Object;

    my class HasId is UR6::Object {
        has $.a is id;
        has $.not-id;
    }

    my @id-attribs = HasId.HOW.get-attributes(:id);
    is @id-attribs.elems, 1, 'HasId explicit ID attribute';
    is @id-attribs[0].name, '$!a', 'ID attrib name';

    my class HasIdChild is HasId {
        has $.b is id;
    }
    @id-attribs = HasIdChild.HOW.get-attributes(:id);
    is @id-attribs.elems, 2, 'HasIdChild ID attributes';
    is-deeply @id-attribs>>.name, ['$!b', '$!a'], 'ID attrib names';

    my class HasManyId is UR6::Object {
        has $.a is id;
        has $.b is id;
        has $.c is id;
    }
    @id-attribs = HasManyId.HOW.get-attributes(:id);
    is @id-attribs.elems, 3, 'HasIdChild ID attributes';
    is-deeply @id-attribs>>.name, ['$!a', '$!b', '$!c'], 'ID attrib names';
}

subtest 'object-sorter' => {
    plan 9;
    use UR6::Object;

    my class Strs is UR6::Object {
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


    my class Ints is UR6::Object {
        has Int $.a is id;
    }
    $o1 = Ints.new(a => 1);
    $o2 = Ints.new(a => 2);
    $o3 = Ints.new(a => 1);

    $sorter = Ints.HOW.object-sorter();
    is $sorter($o1, $o2), Order::Less, '1 sorts less than 2';
    is $sorter($o2, $o1), Order::More, '2 sorts more than 1';
    is $sorter($o1, $o1), Order::Same, '1 sorts same as 1';
    is $sorter($o1, $o3), Order::Same, '1 sorts same as 01, different objects';


    my class MultiId is UR6::Object {
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

subtest 'caret methods' => {
    plan 12;
    use UR6::Object;

    my class Thingy is UR6::Object {
        has Int $.a is id;
    }

    my @props = Thingy.^get-attributes();
    is @props.elems, 2, '2 attribute';
    is-deeply @props>>.name, ['$!a', '$!__id'], 'name';

    my @id-props = Thingy.^get-attributes(:id);
    is @id-props.elems, 1, '1 ID attribute';
    is @id-props[0].name, '$!a', 'name';

    @id-props = Thingy.^get-attribute-names(:id);
    is @id-props.elems, 1, '1 ID attribute name';
    is @id-props[0], 'a', 'name';

    ok Thingy.^object-sorter ~~ Callable, 'object-sorter';
    ok Thingy.^composite-id-resolver ~~ Callable, 'composite-id-resolver';

    ok Thingy.^composite-id-decomposer(123), 'composite-id-decomposer';
    ok Thingy.^generate-new-object-id, 'generate-new-object-id';

    ok Thingy.^has-attribute('a'), 'class has-attribute a';
    ok ! Thingy.^has-attribute('nope'), 'class does not has-attribute nope';
}

subtest 'id resolution' => {
    plan 6;

    use UR6::Object;
    my class Thingy is UR6::Object {
        has Int $.a is id;
        has Int $.b is id;
    }
    my $obj = Thingy.new( a => 1, b => 2 );

    my $resolver = Thingy.^composite-id-resolver();
    ok $resolver ~~ Callable, 'composite-id-resolver with no args';
    is $resolver($obj), "1\02", 'called with object';
    is $resolver((1, 2)), "1\02", 'called with list of values';

    is Thingy.HOW.composite-id-resolver($obj), "1\02", 'composite-id-resolver called with object';
    is Thingy.HOW.composite-id-resolver((1, 2)), "1\02", 'composite-id-resolver called with list of values';
    is Thingy.HOW.composite-id-resolver({a => 1, b => 2}), "1\02", 'composite-id-resolver called with hash of values';
};

# vim: set syntax=perl6
