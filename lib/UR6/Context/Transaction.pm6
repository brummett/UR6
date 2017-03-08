use UR6::Context;
use UR6::ObjectCache;
#use UR6::Change;

unit class UR6::Context::Transaction is UR6::Context;

#has UR6::Change @change_list;
has UR6::ObjectCache $!object-cache = UR6::ObjectCache.new();

multi method fetch(Any:U $type) {
    return $!object-cache.fetch($type);
}
multi method fetch(Any:U $type, $id) {
    return $!object-cache.fetch($type, $id);
}
multi method fetch(Any:U $type, %filters) {
    return $!object-cache.fetch($type, %filters);
}

method create-entity(Any:U $type, %params) {
    unless %params<__id>:exists {
        %params<__id> = self.generate-object-id;
    }
    my $obj = $type.new(|%params);
    $!object-cache.store($obj);
}
        
