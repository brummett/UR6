#use UR6;
#need UR6::Object;

role UR6::BoolExpr::Template {
    #has UR6::Object:U $.subject-class;
    has Mu:U $.subject-class;
    has Str @.attributes;
    has Str @.operators;

    has Str $.normalized-id;
    has Int $.num-values;

    has Bool $.is-normalized = False;
    has Bool $.is-id-only = False;
    has Bool $.is-partial-id = False;
    has Bool $.is-unique = False;
    has Bool $.is-matches-all = False;

    has Str @hints;

    method logic-type { ... }

    submethod BUILD(Mu:U :$!subject-class, :@attributes) {
        if @attributes.elems == 0 {
            $!is-id-only = False;
            $!is-matches-all = True;
        }
    }
}
        

