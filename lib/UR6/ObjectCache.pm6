unit class UR6::ObjectCache;

has Hash %cache;

method store($obj) {
    my $type = $obj.^name;
    %cache{$type}{$obj.__id} = $obj;
}

method fetch(Any:U $type, %filter --> Iterable) {
    return %cache{$type.^name}.values.grep({ object_matches_filter($_, %filter) }).sort({ $^a.__id cmp $^b.__id});
}

method remove(Any:U $type, $id) {
    return %cache{$type.^name}{$id}:delete;
}


sub object_matches_filter($obj, %filter) returns Bool {
    for %filter.keys -> $key {
        return False unless $obj."$key"() eq %filter{$key};
    }
    return True;
}
