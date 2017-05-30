use UR6::BoolExpr::Evaluator;

class UR6::BoolExpr::Template::PropertyComparison::Equal { ... }
#use UR6::BoolExpr::Template::PropertyComparison::NotEqual { ... }
#use UR6::BoolExpr::Template::PropertyComparison::LessThan { ... }
#use UR6::BoolExpr::Template::PropertyComparison::GreaterThan { ... }
#use UR6::BoolExpr::Template::PropertyComparison::LessOrEqual;
#use UR6::BoolExpr::Template::PropertyComparison::GreaterOrEqual;
#use UR6::BoolExpr::Template::PropertyComparison::In;
#use UR6::BoolExpr::Template::PropertyComparison::NotIn;
#use UR6::BoolExpr::Template::PropertyComparison::Between;
#use UR6::BoolExpr::Template::PropertyComparison::NotBetween;
#use UR6::BoolExpr::Template::PropertyComparison::Like;
#use UR6::BoolExpr::Template::PropertyComparison::NotLike;

class UR6::BoolExpr::Template::PropertyComparison {
    has $.attribute-name;
    multi method new('=', :$attribute-name) { UR6::BoolExpr::Template::PropertyComparison::Equal.new(:$attribute-name) }
}

class UR6::BoolExpr::Template::PropertyComparison::Equal
    is UR6::BoolExpr::Template::PropertyComparison
    does UR6::BoolExpr::Evaluator
{
    method evaluate(Any:D :$subject, :$value) { $subject."{ self.attribute-name }"() == $value }
}
        
