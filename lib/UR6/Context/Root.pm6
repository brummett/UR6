use UR6::Context;
use UR6::Entity;

unit class UR6::Context::Root is UR6::Context;

multi method fetch(Any:U $type, *@) { return () }
multi method fetch(Any:U $type where { $type ~~ UR6::Entity })         { callwith({}) }
multi method fetch(Any:U $type where { $type ~~ UR6::Entity }, $id)    { callwith({ __id => $id }) }
multi method fetch(Any:U $type where { $type ~~ UR6::Entity }, %filters) { ... }

method store(Array) { return fail }
method create-entity(Any:U, Hash) { return fail }
method delete-entity(Any) { return fail }
