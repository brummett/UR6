#use UR6;
#need UR6::Object;
#my class UR6::Object { ... }
use UR6::BoolExpr::Template::And;

unit class UR6::BoolExpr;

has UR6::BoolExpr::Template $.template handles <subject-class is-normalized is-id-only is-partial-id is-unique is-matches-all>;
has @.values;
has @.hard_refs;

method new(Mu:U $subject-class,
           *%filters,
) {
    my @attributes;
    my @operators;
    my @values;
    my @hard_refs;
    my @constant_values;
    my @extra_keys;

    for %filters.kv -> ($key, $value) {
        my Str ($attribute, $operator);

        if my $pos = $key.index(' ') {
            $attribute = $key.substr(0, $pos);
            $operator = $key.substr($pos+1);
        } else {
            $attribute = $key;
            $operator = '=';
        }

        if $subject-class.has-attribute($attribute) {
            @extra_keys.push($key);

        } else {
            @attributes.push($attribute);
            @operators.push($operator);
            @values.push($value);
        }
    }

    if @extra_keys.elems {
        die "Unknown attributes for class { $subject-class.name }: { @extra_keys.join(', ') }";
    }

    my $template = UR6::BoolExpr::Template::And.new(
                    subject-class => $subject-class,
                    attributes => @attributes,
                    operators  => @operators,
                );
    return self.bless(:$template, :@values);
}

method values() { ... }

method value-for-id() { ... }

method specifies-value-for() { ... }

method value-for() { ... }

method operator-for() { ... }

# De-compose the BoolExpr back to a hash of key/value pairs
method construction-params() { ... } 

method add-filter() { ... }

method remove-filter() { ... }

method sub-classify() { ... }

