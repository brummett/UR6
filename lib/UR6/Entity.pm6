use UR6 :class-traits;
use UR6::Context;
need UR6::Object;
use UR6::DataSource;

role UR6::Entity does UR6::Object { }

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
