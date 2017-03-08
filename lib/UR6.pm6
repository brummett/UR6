unit class UR6;

use UR6::Context;
use UR6::Context::Root;

initialize();

sub initialize() {
    my $root-context = UR6::Context::Root.new();
    UR6::Context.initialize($root-context);
}

