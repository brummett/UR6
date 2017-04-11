use UR6::DataSource::LoadingTemplate;
use UR6::Context::ObjectFabricator;

unit class UR6::DataSource::QueryPlan;

has Mu:U $.type;
has %.filters;
has UR6::DataSource::LoadingTemplate @.loading-templates;

submethod BUILD(Mu:U :$!type, :%!filters) {
    @!loading-templates = ( UR6::DataSource::LoadingTemplate.new(:$!type, :object-num(0), :table-alias(''), :start-col(0)) );
}

method object-fabricators {
    @!loading-templates.map({ UR6::Context::ObjectFabricator.new(:loading-template($_))});
}

method columns {
    @!loading-templates>>.column-list.map(*.Slip);
}
