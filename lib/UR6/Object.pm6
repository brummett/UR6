use UR6 :attribute-traits;
use UR6::Context;

role UR6::Object {
    has $.__id;

    method create(Any:U: *%args --> UR6::Object) {
        my %normalized-args = self.normalize-id-attributes-for-create(%args);
        UR6::Context.current.create-entity(self.WHAT, |%normalized-args);
    }

    method normalize-id-attributes-for-create(%args --> Hash) {
        my $type-obj = self.HOW;

        my @id-attrib-names = $type-obj.get-attribute-names(:id, :explicit);
        if %args<__id> and any(%args{@id-attrib-names}:exists) {
            die "Cannot provide both __id and explicit ID attributes to create()";

        } elsif %args<__id>:!exists and @id-attrib-names.elems > 1 and none(%args{@id-attrib-names}:exists) {
            die "Cannot autogenerate __id for a class with multiple ID attributes";

        } elsif %args<__id>:!exists and @id-attrib-names.elems and any(%args{@id-attrib-names}:exists) {
            %args<__id> = $type-obj.composite-id-resolver(%args);

        } elsif %args<__id>:!exists {
            %args<__id> = $type-obj.generate-new-object-id;
        }

        if none(%args{@id-attrib-names}:exists) {
            %args{@id-attrib-names} = $type-obj.composite-id-decomposer(%args<__id>);
        }

        return %args;
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
    has $.id-value-separator = "\0";
    has %.__cache;

    # allows calling via TypeName.^attributes()
    # I'd rather this were an override of Metamodel::ClassHOW's attributes(), but creating a class
    # fails with something about iterating a P6Opaque
    multi method get-attributes(Mu $class, Bool :$explicit=False, Bool :$id=False, *%params --> Iterable) {
        if $id {
            my @id-attribs = self.attributes(self).grep({ $_ ~~ IsIdAttribute});
            unless $explicit or @id-attribs.elems {
                @id-attribs = self.attributes(self).grep({ .name eq '$!__id'});
            }
            return @id-attribs;
        }
        return self.attributes(self, |%params);
    }
    multi method get-attributes(*%params --> Iterable) {
       samewith(self, |%params);
    }

    multi method has-attribute(Mu $class, Str $name --> Bool) {
        unless self.__cache<has-attribute>:exists {
            self.__cache<has-attribute> = self.get-attribute-names.Set;
        }
        return self.__cache<has-attribute> (cont) $name;
    }
    multi method has-attribute(Str $name --> Bool) {
        samewith(self, $name);
    }

    # allows calling via TypeName.^id-attribute-names()
    multi method get-attribute-names(Mu $class, *%params --> Iterable) {
        self.get-attributes(self, |%params)>>.name.map({ ($_ ~~ /<[@$%]>'!'(\w+)/)[0].Str });
    }
    multi method get-attribute-names(*%params) {
        samewith(self, |%params);
    }

    multi method object-sorter(--> Callable) {
        my @id-attribute-names = self.get-attribute-names(:id);
        return -> UR6::Object $a, UR6::Object $b {
            my $comparison = Order::Same;
            for @id-attribute-names -> $name {
                $comparison = $a."$name"() cmp $b."$name"();
                last if $comparison != Order::Same
            }
            $comparison;
        };
    }
    # allows calling via TypeName.^object-sorter
    multi method object-sorter(UR6::Object:U $class) {
        samewith();
    }

    # Returns a closure that can be called for any object
    multi method composite-id-resolver(--> Callable) {
        my @id-attrib-names = self.get-attribute-names(:id);
        my multi sub resolver (UR6::Object $obj --> Str) {
            @id-attrib-names.map({ $obj."$_"() }).join($!id-value-separator);
        }
        my multi sub resolver (@id-values --> Str) {
            @id-values.map({ $_ // ''}).join($!id-value-separator);
        }
        return &resolver;
    }
    # allows calling via TypeName.^composite-id-resolver
    multi method composite-id-resolver(UR6::Object:U $class) {
        samewith();
    }
    # Get the composite ID for a particular instance
    multi method composite-id-resolver(UR6::Object:D $obj --> Str) {
        my @id-attrib-names = self.get-attribute-names(:id);
        @id-attrib-names.map({ $obj."$_"() }).join($!id-value-separator);
    }
    # used by a Context to generate __id for new objects
    multi method composite-id-resolver(%params --> Str) {
        my @id-attrib-names = self.get-attribute-names(:id);
        @id-attrib-names.map({ %params{$_} // '' }).join($!id-value-separator);
    }
    # used by the Loader to turn a row of data into an object ID
    multi method composite-id-resolver(@id-cols --> Str) {
        @id-cols.map({ $_ // ''}).join($!id-value-separator);
    }

    multi method composite-id-decomposer(Cool $id --> Iterable) {
        $id.split( $!id-value-separator, self.get-attributes(:id, :explicit).elems);
    }
    multi method composite-id-decomposer(UR6::Object:U $class, Cool $id) {
        samewith($id);
    }

    my Int $id = 0;
    multi method generate-new-object-id() {
        return ++$id;
    }
    multi method generate-new-object-id(UR6::Object:U $class) {
        samewith();
    }
}

my module EXPORTHOW { }
EXPORTHOW.WHO.<class> = UR6::Object::ClassHOW;
