use UR6::BoolExpr::Evaluator;

class UR6::BoolExpr::Template::PropertyComparison::Not { ... }
class UR6::BoolExpr::Template::PropertyComparison::Equal { ... }
class UR6::BoolExpr::Template::PropertyComparison::Eq { ... }
class UR6::BoolExpr::Template::PropertyComparison::LessThan { ... }
class UR6::BoolExpr::Template::PropertyComparison::Lt { ... }
class UR6::BoolExpr::Template::PropertyComparison::GreaterThan { ... }
class UR6::BoolExpr::Template::PropertyComparison::Gt { ... }
class UR6::BoolExpr::Template::PropertyComparison::LessOrEqual { ... }
class UR6::BoolExpr::Template::PropertyComparison::Le { ... }
class UR6::BoolExpr::Template::PropertyComparison::GreaterOrEqual { ... }
class UR6::BoolExpr::Template::PropertyComparison::Ge { ... }
class UR6::BoolExpr::Template::PropertyComparison::Between { ... }

class UR6::BoolExpr::Template::PropertyComparison does UR6::BoolExpr::Evaluator {
    has $.attribute-name;
    multi method new(Str $s where { ~$_ ~~ m/^['!' | 'not '](.*)/ }, :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Not.new(~$/[0], :$attribute-name) }
    multi method new('=', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Equal.new(:$attribute-name) }
    multi method new('eq', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Eq.new(:$attribute-name) }
    multi method new('<', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::LessThan.new(:$attribute-name) }
    multi method new('lt', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Lt.new(:$attribute-name) }
    multi method new('>', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::GreaterThan.new(:$attribute-name) }
    multi method new('gt', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Gt.new(:$attribute-name) }
    multi method new('<=', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::LessOrEqual.new(:$attribute-name) }
    multi method new('le', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Le.new(:$attribute-name) }
    multi method new('>=', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::GreaterOrEqual.new(:$attribute-name) }
    multi method new('ge', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Ge.new(:$attribute-name) }
    multi method new('in', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::In.new(:$attribute-name) }
    multi method new('between', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Between.new(:$attribute-name) }
    multi method new('like', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Like.new(:$attribute-name) }

    method evaluate { ... }
}

class UR6::BoolExpr::Template::PropertyComparison::Not is UR6::BoolExpr::Template::PropertyComparison {
    has UR6::BoolExpr::Template::PropertyComparison $!underlying-comparison;
    submethod BUILD(:$!underlying-comparison) { 1 }
    method new(Str $op, :$attribute-name) {
        nextwith(:underlying-comparison(UR6::BoolExpr::Template::PropertyComparison.new($op, :$attribute-name)));
    }
    method evaluate(Any:D :$subject, :$value) { ! $!underlying-comparison.evaluate(:$subject, :$value) }
}

class UR6::BoolExpr::Template::PropertyComparison::Equal is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, :$value) { $subject."{ self.attribute-name }"() == $value }
}

class UR6::BoolExpr::Template::PropertyComparison::Eq is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, :$value) { $subject."{ self.attribute-name }"() eq $value }
}
        
class UR6::BoolExpr::Template::PropertyComparison::LessThan is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, Numeric :$value) { $subject."{ self.attribute-name }"() < $value }
}

class UR6::BoolExpr::Template::PropertyComparison::Lt is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, Stringy :$value) { $subject."{ self.attribute-name }"() lt $value }
}

class UR6::BoolExpr::Template::PropertyComparison::GreaterThan is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, Numeric :$value) { $subject."{ self.attribute-name }"() > $value }
}

class UR6::BoolExpr::Template::PropertyComparison::Gt is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, Stringy :$value) { $subject."{ self.attribute-name }"() gt $value }
}

class UR6::BoolExpr::Template::PropertyComparison::LessOrEqual is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, Numeric :$value) { $subject."{ self.attribute-name }"() <= $value }
}

class UR6::BoolExpr::Template::PropertyComparison::Le is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, Stringy :$value) { $subject."{ self.attribute-name }"() le $value }
}

class UR6::BoolExpr::Template::PropertyComparison::GreaterOrEqual is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, Numeric :$value) { $subject."{ self.attribute-name }"() >= $value }
}

class UR6::BoolExpr::Template::PropertyComparison::Ge is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, Stringy :$value) { $subject."{ self.attribute-name }"() ge $value }
}

class UR6::BoolExpr::Template::PropertyComparison::Between is UR6::BoolExpr::Template::PropertyComparison {
    method evaluate(Any:D :$subject, Range :$value) { $subject."{ self.attribute-name }"() ~~ $value }
}
