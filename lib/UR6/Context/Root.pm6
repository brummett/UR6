use UR6::Context;

unit class UR6::Context::Root is UR6::Context;

method fetch(Any:U, Hash) { return fail }
method store(Array) { return fail }
method create-entity(Any:U, Hash) { return fail }
method delete-entity(Any) { return fail }
