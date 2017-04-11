unit class UR6::Context::ObjectFabricator;

use UR6::ObjectCache;
use UR6::Context;
use UR6::DataSource::LoadingTemplate;

has UR6::DataSource::LoadingTemplate $!loading-template;
has UR6::ObjectCache $!object-cache;   # TODO ask the current Context to fetch() without loading when we're off the object cache

submethod BUILD (:$!loading-template!) {
    $!object-cache = UR6::Context.current.object-cache;
}

method fabricate(@row) {
    my $pending-db-object-id = $!loading-template.id-resolver.( @row );
    if my $obj = $!object-cache.fetch($!loading-template.data-type, { __id => $pending-db-object-id }) {
        # TODO merge diff between object and DB row
        return $obj;
    }

    my %new-params;
    %new-params{$!loading-template.attribute-names} = @row[$!loading-template.attribute-positions];
    $obj = $!loading-template.final-type.new(__id => $pending-db-object-id, |%new-params);
    $!object-cache.store($obj);
    return $obj;
}

method finalize { }
