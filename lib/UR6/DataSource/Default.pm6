use UR6::DataSource;
use UR6::DataSource::QueryPlan;
use UR6::DataSource::ResultSet;

my class MappingIterator does Iterator {
    has Iterator $!iterator;
    has Int @!mapping;
    submethod BUILD(:$source, :@from, :@to) {
        $!iterator = $source;

        my %from = @from.antipairs;
        @!mapping = @to.map: { %from{$_} // die "Can't resolve position of column '$_' from the headers returned by its __load__: { @from.gist }" };
    }

    method pull-one {
        my \row = $!iterator.pull-one;
        return row if row =:= IterationEnd;
        return row[@!mapping];
    }
}

class UR6::DataSource::Default does UR6::DataSource {
    method query(UR6::DataSource::QueryPlan $query-plan --> Iterator) {
        if ! $query-plan.type.can('__load__') {
            return ();
        }

        my $rs := $query-plan.type.__load__(:headers($query-plan.columns), :filter($query-plan.filters));
        unless $rs ~~ UR6::DataSource::ResultSet {
            die "Expected UR6::DataSource::ResultSet from __load__() but got $rs";
        }

        # Comparing a List/Array to a Seq (returned by $qp.columns) with eqv doesn't work
        if same($rs.headers, $query-plan.columns) {
            return $rs;
        } else {
            return MappingIterator.new(source => $rs, from => $rs.headers, to => $query-plan.columns);
        }
    }

    sub same(@a, @b) {
        return (@a.elems == @b.elems and all(@a >>eq<< @b));
    }
}
