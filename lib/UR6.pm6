use UR6::Context;
use UR6::Context::Root;
use UR6::DataSource;

# Kinds of trait mods: is, hides, does, will, of returns, handles

my role IsIdAttribute is export(:attribute-traits) { }
multi sub trait_mod:<is>(Attribute $attr, :$id!) is export {
    $attr does IsIdAttribute;
}

my role HasColumn[Str $column-name!] is export(:attribute-traits) {
    method column-name { $column-name }
}
multi sub trait_mod:<is>(Attribute $attr, :$column-name!) is export {
    $attr does HasColumn[$column-name];
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


initialize();

sub initialize() {
    my $root-context = UR6::Context::Root.new();
    UR6::Context.initialize($root-context);
}

class UR6 { }
