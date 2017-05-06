use UR6::DataSource;
use UR6::DataSource::QueryPlan;
use UR6::Context::ObjectFabricator;
use UR6::DataSource::ResultSet;

# Like UR::Context::ImportIterator
unit class UR6::Context::ObjectImporter does Iterator;

#role UR6::Entity { ... }

has UR6::Context::ObjectFabricator @!object-fabricators;
has UR6::DataSource::QueryPlan     $!query-plan;
has Iterator                       $!resultset;
has Int $rows = 0;
has Bool $!active = True;

submethod BUILD(UR6::DataSource :$data-source, Mu:U :$type, :%filters) {
    $!query-plan = UR6::DataSource::QueryPlan.new(:$type, :%filters);
    $!resultset = $data-source.query($!query-plan);
    @!object-fabricators = $!query-plan.object-fabricators;
}

method pull-one() {
    LOAD_AN_OBJECT:
    while ($!active) {
        my \next-db-row = $!resultset.pull-one;

        if next-db-row =:= IterationEnd {
            # TODO: Fill in query cache like in UR/Context/ImportIterator.pm
            # around line 590

            @!object-fabricators>>.finalize;
            $!active = False;
            last LOAD_AN_OBJECT;
        }

        $!rows++;

        my @imported = @!object-fabricators>>.fabricate(next-db-row);

        return @imported[0];
    }
    return IterationEnd;
}
