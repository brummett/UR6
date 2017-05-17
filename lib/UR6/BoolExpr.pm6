#use UR6;
#need UR6::Object;
#my class UR6::Object { ... }
use UR6::BoolExpr::Template::And;

unit class UR6::BoolExpr;

has UR6::BoolExpr::Template $.template handles <subject-class is-normalized is-id-only is-partial-id is-unique is-matches-all position-for operator-for attributes operators>;
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

    for %filters.kv -> $attribute, $val {
        my ($operator, $value);

        if $val ~~ Pair {
            ($operator, $value) = $val.kv
        } else {
            $operator = '=';
            $value = $val;
        }

        if ! $subject-class.^has-attribute($attribute) {
            @extra_keys.push($attribute);

        } else {
            @attributes.push($attribute);
            @operators.push($operator);
            @values.push($value);
        }
    }

    if @extra_keys.elems {
        fail "Unknown attributes for class { $subject-class.name }: { @extra_keys.join(', ') }";
    }

    my $template = UR6::BoolExpr::Template::And.new(
                    subject-class => $subject-class,
                    attributes => @attributes,
                    operators  => @operators,
                );
    return self.bless(:$template, :@values);
}

method value-for-id() { ... }

method value-for($name, Bool :$exists) {
    my $pos = self.position-for($name);
    if $exists {
        return defined($pos);
    } elsif defined($pos) {
        return @!values[$pos];
    } else {
        return fail "'$name' is not an attribute";
    }
}

# De-compose the BoolExpr back to a hash of key/value pairs
method construction-params() { ... } 

method add-filter() { ... }

method remove-filter() { ... }

method sub-classify() { ... }

