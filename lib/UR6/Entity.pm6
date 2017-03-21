use UR6::Context;
need UR6::Object;
use UR6::DataSource;

role UR6::Entity does UR6::Object { }

my role HasColumn[Str $column-name!] {
    method column-name { $column-name }
}
multi sub trait_mod:<is>(Attribute $attr, :$column-name!) is export {
    $attr does HasColumn[$column-name];
}

my role HasDataSource[ UR6::DataSource $data-source ] {
    method data-source { $data-source }
}
multi sub trait_mod:<is>(Mu:U $class, UR6::DataSource :$data-source!) is export {
    $class.HOW does HasDataSource[$data-source];
}

my role HasTable[Str $table-name!] {
    method table-name { $table-name }
}
multi sub trait_mod:<is>(Mu:U $class, Str :$table-name!) is export {
    $class.HOW does HasTable[$table-name];
}

class UR6::Entity::ClassHOW
    is UR6::Object::ClassHOW
{
    method compose(Mu $class) {
        unless $class.HOW ~~ HasDataSource {
            my $class-name = $class.^name;
            die "Class $class-name has no data-source";
        }
        callsame;
    }
}

my module EXPORTHOW { }
EXPORTHOW.WHO.<class> = UR6::Entity::ClassHOW;
