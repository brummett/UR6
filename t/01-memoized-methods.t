use Test;
use UR6;

plan 2;

class Foo {
    has Int $.scalar;
    has Int $.scalar-called = 0;
    has Int @.array;
    has Int $.array-called = 0;
    has Int %.hash;
    has Int $.hash-called = 0;

    method scalar-double is memoized {
        $!scalar-called++;
        $!scalar * 2;
    }

    method array-double is memoized {
        $!array-called++;
        @!array >>*>> 2;
    }

    method hash-double is memoized {
        $!hash-called++;
        %!hash >>*>> 2;
    }
}
        
subtest 'basic' => {
    plan 15;

    my $f = Foo.new(scalar => 1, array => (1,2,3), hash => %(one => 1, two => 2, three => 3));
    my sub check-values {
        is $f.scalar-double, 2, 'scalar-double';
        is $f.array-double, (2, 4, 6), 'array-double';
        is $f.hash-double, %(one => 2, two => 4, three => 6), 'hash-double';
    }
    my sub check-call-counts($expected) {
        for <scalar-called array-called hash-called> -> $check {
            is $f."$check"(), $expected, "$check is $expected"
        }
    }

    check-call-counts(0);
    check-values;
    check-call-counts(1);
    check-values;
    check-call-counts(1);
}

subtest 'multiple instances' => {
    plan 4;

    my $a = Foo.new(scalar => 1);
    my $b = Foo.new(scalar => 5);

    is $a.scalar-double, 2, 'doubled $a';
    is $b.scalar-double, 10, 'doubled $a';
    is $a.scalar-called, 1, '$a called once';
    is $b.scalar-called, 1, '$b called once';
}
