use UR6::Context;

role UR6::Object {
    has $.__id;

    method create(*%args) {
        UR6::Context.current.create-entity(self.WHAT, %args);
    }

    multi method get() {
        UR6::Context.current.fetch(self.WHAT);
    }
    multi method get($id) {
        UR6::Context.current.fetch(self.WHAT, $id);
    }
    multi method get(%args) {
        UR6::Context.current.fetch(self.WHAT, %args);
    }
}
        
