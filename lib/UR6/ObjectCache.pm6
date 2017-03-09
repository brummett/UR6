unit class UR6::ObjectCache;

has Hash %cache;

method store($obj) {
    my $type = $obj.^name;
    %cache{$type}{$obj.__id} = $obj;
}

multi method fetch(Any:U $type) {
    return %cache{$type.^name}.values;
}
multi method fetch(Any:U $type, $id) {
    return %cache{$type.^name}{$id};
}
multi method fetch(Any:U $type, %filter) {
    return %cache{$type.^name}.values.grep({ object_matches_filter($_, %filter) });
}

method remove(Any:U $type, $id) {
    return %cache{$type.^name}{$id}:delete;
}


sub object_matches_filter($obj, %filter) returns Bool {
    for %filter.keys -> $key {
        return False unless $obj.$key eq %filter{$key};
    }
    return True;
}
