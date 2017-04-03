use Test;
use UR6::DataSource::ResultSet;

plan 4;

subtest 'construction' => {
    plan 7;

    throws-like { UR6::DataSource::ResultSet.new(headers => ['a']) },
                Exception, message => /'Must supply either :content or :iterator, not both'/,
                'new() with neither :content nor :iterator';
    throws-like { UR6::DataSource::ResultSet.new(content => [], iterator => 1, headers => ['a']) },
                Exception, message => /'Must supply either :content or :iterator, not both'/,
                'new() with both :content and :iterator';

    my $rs = UR6::DataSource::ResultSet.new(content => [], headers => ['a']);
    ok $rs, 'created';
    is $rs.is-sorted, False, 'Default is-sorted is False';
    is $rs.is-exact, False, 'Default is-exact is False';

    $rs = UR6::DataSource::ResultSet.new(content => [], headers => ['a'], :is-sorted, :is-exact);
    ok $rs.is-sorted, 'created with :is-sorted';
    ok $rs.is-exact, 'created with :is-exact';
};

subtest 'empty array content' => {
    plan 2;

    my $rs = UR6::DataSource::ResultSet.new(content => [], headers => ['a']);
    ok $rs, 'created resultset with empty array content';
    my $val := $rs.pull-one;
    ok $val =:= IterationEnd, 'pull-one returned IterationEnd';
}

subtest 'with content' => {
    plan 4;

    my @expected = 1, 2, 3;
    my $rs = UR6::DataSource::ResultSet.new(content => @expected, headers => ['a']);
    ok $rs, 'created resultset with array content';

    for @expected -> $expected {
        my $val := $rs.pull-one;
        is $val, $expected, 'got expected value';
    }
}

subtest 'with iterator' => {
    plan 4;

    my @expected = 1, 2, 3;

    my $i = 0;
    my $iterator = (True but role { method pull-one { @expected[$i++] // IterationEnd } }) does Iterator;

    my $rs = UR6::DataSource::ResultSet.new(iterator => $iterator, headers => ['a']);
    ok $rs, 'created resultset with iterator';

    for @expected -> $expected {
        my $val = $rs.pull-one;
        last if $val =:= IterationEnd;
        is $val, $expected, 'got expected value';
    }
}
