use UR6::BoolExpr::Evaluator;

class UR6::BoolExpr::Template::PropertyComparison::Equal { ... }
class UR6::BoolExpr::Template::PropertyComparison::LessThan { ... }
class UR6::BoolExpr::Template::PropertyComparison::GreaterThan { ... }
class UR6::BoolExpr::Template::PropertyComparison::LessOrEqual { ... }
class UR6::BoolExpr::Template::PropertyComparison::GreaterOrEqual { ... }

class UR6::BoolExpr::Template::PropertyComparison {
    has $.attribute-name;
    multi method new('=', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Equal.new(:$attribute-name) }
    multi method new('<', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::LessThan.new(:$attribute-name) }
    multi method new('>', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::GreaterThan.new(:$attribute-name) }
    multi method new('<=', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::LessOrEqual.new(:$attribute-name) }
    multi method new('>=', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::GreaterOrEqual.new(:$attribute-name) }
}

class UR6::BoolExpr::Template::PropertyComparison::Equal
    is UR6::BoolExpr::Template::PropertyComparison
    does UR6::BoolExpr::Evaluator
{
    method evaluate(Any:D :$subject, :$value) { $subject."{ self.attribute-name }"() == $value }
}
        
class UR6::BoolExpr::Template::PropertyComparison::LessThan
    is UR6::BoolExpr::Template::PropertyComparison
    does UR6::BoolExpr::Evaluator
{
    method evaluate(Any:D :$subject, Numeric :$value) { $subject."{ self.attribute-name }"() < $value }
}

class UR6::BoolExpr::Template::PropertyComparison::GreaterThan
    is UR6::BoolExpr::Template::PropertyComparison
    does UR6::BoolExpr::Evaluator
{
    method evaluate(Any:D :$subject, Numeric :$value) { $subject."{ self.attribute-name }"() > $value }
}

class UR6::BoolExpr::Template::PropertyComparison::LessOrEqual
    is UR6::BoolExpr::Template::PropertyComparison
    does UR6::BoolExpr::Evaluator
{
    method evaluate(Any:D :$subject, Numeric :$value) { $subject."{ self.attribute-name }"() <= $value }
}

class UR6::BoolExpr::Template::PropertyComparison::GreaterOrEqual
    is UR6::BoolExpr::Template::PropertyComparison
    does UR6::BoolExpr::Evaluator
{
    method evaluate(Any:D :$subject, Numeric :$value) { $subject."{ self.attribute-name }"() >= $value }
}
