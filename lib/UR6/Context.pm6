unit class UR6::Context;

has UR6::Context $.parent;

my UR6::Context $current-context;
method initialize(UR6::Context $initial-context) {
    die "Already initialized" if $current-context;
    $current-context = $initial-context;
}
method current() returns UR6::Context { $current-context }

method fetch(Any:U, Hash) { ... }
method store(Array) { ... }
method create-entity(Any:U, Hash) { ... }
method delete-entity(Any) { ... }

method branch(UR6::Context:U: UR6::Context:U $kind) {
    my $new = $kind.new(parent => $current-context);
    $current-context = $new;
}

method push(UR6::Context $c) {
    $c.parent = $current-context;
    $current-context = $c;
}

method pop() returns UR6::Context {
    my UR6::Context $old = $current-context;
    $current-context = $current-context.parent;
    return $old;
}

my Int $id = 0;
method generate-object-id() {
    return ++$id;
}
