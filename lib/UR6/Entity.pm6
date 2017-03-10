use UR6::Context;
use UR6::Object;

unit role UR6::Entity[:$data-source is required, :$table-name] does UR6::Object;

method __load__ { ... }
