use UR6::Context;
use UR6::Context::Root;
use UR6::DataSource;

# Kinds of trait mods: is, hides, does, will, of returns, handles

my role IsIdAttribute is export(:attribute-traits) { }
multi sub trait_mod:<is>(Attribute $attr, :$id!) is export {
    $attr does IsIdAttribute;
}

my role HasColumn[Str $column!] is export(:attribute-traits) {
    method column-name { $column }
}
multi sub trait_mod:<is>(Attribute $attr, :$column!) is export {
    $attr does HasColumn[$column];
}

my role HasDataSource[ UR6::DataSource $data-source ] is export(:class-traits) {
    multi method data-source() { $data-source }
    multi method data-source(Mu $class) { $data-source }
}
multi sub trait_mod:<is>(Mu:U $class, UR6::DataSource :$data-source!) is export {
    $class.HOW does HasDataSource[$data-source];
}

my role HasTable[Str $table-name!] is export(:class-traits) {
    multi method table-name() { $table-name }
    multi method table-name(Mu $class) { $table-name }
}
multi sub trait_mod:<is>(Mu:U $class, Str :$table-name!) is export {
    $class.HOW does HasTable[$table-name];
}

my role IsMemoized[Method $meth] is export(:method-traits) {
    my $is-set-attr = Attribute.new(:name('_' ~ $meth.name ~ '-is-set'), :type(Bool), :package($meth.package));
    my $value-attr  = Attribute.new(:name('_' ~ $meth.name ~ '-memoized-value'), :type(Any), :package($meth.package));
    $meth.package.^add_attribute($is-set-attr);
    $meth.package.^add_attribute($value-attr);

    method is-set(Any:D $invocant --> Bool) { $is-set-attr.get_value($invocant) }
    multi method value(Any:D $invocant) { $value-attr.get_value($invocant) }
    multi method value(Any:D $invocant, \new_value) { $value-attr.set_value($invocant, new_value); $is-set-attr.set_value($invocant, True); }
}
multi sub trait_mod:<is>(Method $meth, Bool :$memoized!) is export {
    unless $meth.arity == 1 {
        die "Can't memoize a sub that requires arguments other than 'self'";
    }
    $meth does IsMemoized[$meth];
    $meth.wrap( method () {
        unless $meth.is-set(self) {
            my $value := callsame;
            $meth.value(self, $value);
        }
        $meth.value(self);
    });
}

initialize();

sub initialize() {
    my $root-context = UR6::Context::Root.new();
    UR6::Context.initialize($root-context);
}

class UR6 { }
