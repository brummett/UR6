use UR6::BoolExpr::Template;
use UR6::BoolExpr::Template::PropertyComparison;

unit class UR6::BoolExpr::Template::And does UR6::BoolExpr::Template;

method logic-type { 'And' }

method evaluate(:$subject, :@values --> Bool) {
    for self.underlying-templates Z @values -> ($tmpl, $value) {
        unless $tmpl.evaluate(:$subject, value => $value) {
            return False;
        }
    }
    return True;
}

method underlying-templates {
    unless @!underlying-templates {  # FIXME - need something that'll return true if it's set to an empty list, but false if not set yet
        @!underlying-templates = do for @!operators Z @!attributes -> ($operator, $attribute-name)
                                    { UR6::BoolExpr::Template::PropertyComparison.new($operator, :$attribute-name) };
    }
    @!underlying-templates;
}
