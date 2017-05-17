use UR6::Context;
use UR6::Context::ObjectImporter;

unit class UR6::Context::Root is UR6::Context;

role UR6::Entity { ... }

multi method fetch(Any:U $type, *% --> Iterable) { return () }
multi method fetch(Any:U $type where * ~~ UR6::Entity, %filters --> Iterable) {
    # like UR::Context::LoadingIterator
    my $object-picker = make-object-picker($type);
    my $data-source = $type.^data-source;
    my Iterator $importer = UR6::Context::ObjectImporter.new(:$data-source, :$type, :%filters);
    my Iterator $cached = self.object-cache.fetch($type, %filters).iterator;

    gather {
        my UR6::Entity ($next-object-cached, $next-object-loading);

        PICK_NEXT_OBJECT_FOR_LOADING:
        while ($importer or $cached) {

            if $importer and !$next-object-loading {
                $next-object-loading = pull-from-iterator($importer);
            }

            if $cached and !$next-object-cached {
                $next-object-cached = pull-from-iterator($cached);
            }

            take $object-picker($next-object-cached, $next-object-loading) if $next-object-cached or $next-object-loading;
        }
    };
}

method store(Array) { return fail }
method create-entity(Any:U, *%) { fail "Can't create objects in a read-only transaction" }
method delete-entity(Any, $id) { fail "Can't delete objects in a read-only transaction" }

my sub pull-from-iterator (Iterator $iter is rw) {
    return Nil unless $iter;

    my $pulled := $iter.pull-one;
    if $pulled =:= IterationEnd {
        $iter = Nil;
        return Nil;
    }
    return $pulled;
}

my sub make-object-picker(UR6::Entity:U $type) {
    my $sorter = $type.^object-sorter;

    my multi sub pick(UR6::Entity:D $a is rw, UR6::Entity:D $b is rw) {
        my $rv;
        given $sorter($a, $b) {
            when Order::Less { $rv = $b; $b = Nil }
            when Order::More { $rv = $a; $a = Nil }
            when Order::Same { $rv = $a; $a = Nil; $b = Nil }
        }
        return $rv;
    }
    my multi sub pick(UR6::Entity:D $a is rw, Any:U $) {
        my $rv = $a; $a = Nil; return $rv;
    }
    my multi sub pick(Any:U $, UR6::Entity:D $b is rw) {
        my $rv = $b; $b = Nil; return $rv;
    }
    return &pick;
}
