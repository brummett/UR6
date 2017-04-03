use Test;
use UR6::DataSource::ResultSet;

plan 1;

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
