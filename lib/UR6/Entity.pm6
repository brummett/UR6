use UR6 :class-traits, :attribute-traits;
need UR6::Object;

role UR6::Entity does UR6::Object { }

class UR6::Entity::ClassHOW
    is UR6::Object::ClassHOW
{
    method compose(Mu $class) {
        unless $class.HOW ~~ HasDataSource {
            my $class-name = $class.^name;
            die "Class $class-name has no data-source";
        }
        nextsame;
    }

    method get-attributes(Mu $class, Bool :$column=False, *%params) {
        if $column {
            return self.get-attributes(self, |%params).grep(* ~~ HasColumn);
        }
        nextwith($class, |%params);
    }
}

my module EXPORTHOW { }
EXPORTHOW.WHO.<class> = UR6::Entity::ClassHOW;
