use UR6::Context;
use UR6::ObjectCache;
#use UR6::Change;

unit class UR6::Context::Transaction is UR6::Context;

#has UR6::Change @change_list;

method fetch(Any:U $type, %filters --> Iterable) {
    return self.object-cache.fetch($type, %filters);
}

method create-entity(Any:U $type, *%params --> UR6::Object) {
    unless %params<__id>:exists {
        %params<__id> = self.generate-object-id;
    }
    my $obj = $type.new(|%params);
    self.object-cache.store($obj);
}

method delete-entity(Any:U $type, $id) {
    return self.object-cache.remove($type, $id);
}
        
