use UR6::Context;

my role IsIdAttribute { }
multi sub trait_mod:<is>(Attribute $attr, :$id!) is export {
    $attr does IsIdAttribute;
}

role UR6::Object {
    has $.__id;

    method create(Any:U: *%args --> UR6::Object) {
        UR6::Context.current.create-entity(self.WHAT, |%args);
    }

    method get(Any:U: *%args --> Iterable) {
        UR6::Context.current.fetch(self.WHAT, %args);
    }

    method delete(Any:D:) {
        UR6::Context.current.delete-entity(self.WHAT, self.__id);
    }
}

class UR6::Object::ClassHOW
    is Metamodel::ClassHOW
{
    # I'd like to say "--> Array[Attribute]", but it complains :(
    method id-attributes(--> Iterable) {
        my @id-attribs = self.attributes(self).grep({ $_ ~~ IsIdAttribute});
        unless @id-attribs.elems {
            @id-attribs = self.attributes(self).grep({ .name eq '$!__id'});
        }
        @id-attribs;
    }

    method id-attribute-names(--> Iterable) {
        self.id-attributes>>.name.map({ ($_ ~~ /<[@$%]>'!'(\w+)/)[0] });
    }

    method object-sorter(--> Callable) {
        my @id-attribute-names = self.id-attribute-names;
        return -> UR6::Object $a, UR6::Object $b {
            my $comparison = Order::Same;
            for @id-attribute-names -> $name {
                $comparison = $a."$name"() cmp $b."$name"();
                last if $comparison != Order::Same
            }
            $comparison;
        };
    }
}

my module EXPORTHOW { }
EXPORTHOW.WHO.<class> = UR6::Object::ClassHOW;
