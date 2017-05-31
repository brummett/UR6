#use UR6;
#need UR6::Object;

use UR6::BoolExpr::Evaluator;

role UR6::BoolExpr::Template does UR6::BoolExpr::Evaluator {
    #has UR6::Object:U $.subject-class;
    has Mu:U $.subject-class;
    has Str @.attributes;
    has Str @.operators;
    has Int %.attribute-positions;
    has UR6::BoolExpr::Evaluator @!underlying-templates;

    has Str $.normalized-id;

    has Bool $.is-normalized = False;
    has Bool $.is-id-only = False;
    has Bool $.is-partial-id = False;
    has Bool $.is-unique = False;
    has Bool $.is-matches-all = False;

    has Str @hints;

    method logic-type { ... }
    method underlying-templates() { ... }

    submethod BUILD(Mu:U :$!subject-class, :@attributes, :@operators) {
        %!attribute-positions = @attributes.antipairs;
        if @attributes.elems == 0 {
            $!is-id-only = False;
            $!is-matches-all = True;
        }

        @!attributes = @attributes;
        @!operators  = @operators;
    }

    method position-for($name) { %!attribute-positions{$name} }

    method operator-for($name, Bool :$exists) {
        my $pos = self.position-for($name);
        if $exists {
            return defined($pos);
        } elsif defined($pos) {
            return @!operators[$pos];
        } else {
            fail "'$name' is not an attribute";
        }
    }

    method gist() {
        my @filters = do for self.attributes -> $attribute
            { ($attribute, self.operator-for($attribute)).join(' => ') }
        return 'BoolExpr::Template=(' ~ self.subject-class.^name ~ ': ' ~ @filters.join(', ') ~ ')';
    }
}
