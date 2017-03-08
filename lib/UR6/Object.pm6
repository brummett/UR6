use UR6::Context;

role UR6::Object {
    has $.__id;

    method create(*%args) {
        UR6::Context.current.create-entity(self.WHAT, %args);
    }

    method get(*%args) {
        UR6::Context.current.fetch(self.WHAT, %args);
    }
}
        
