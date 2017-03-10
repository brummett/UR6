use UR6::Context;

role UR6::Object {
    has $.__id;

    method create(Any:U: *%args) {
        UR6::Context.current.create-entity(self.WHAT, |%args);
    }

    multi method get(Any:U:) {
        UR6::Context.current.fetch(self.WHAT);
    }
    multi method get(Any:U: $id) {
        UR6::Context.current.fetch(self.WHAT, $id);
    }
    multi method get(Any:U: *%args where { %args.keys }) {
        UR6::Context.current.fetch(self.WHAT, %args);
    }

    method delete(Any:D:) {
        UR6::Context.current.delete-entity(self.WHAT, self.__id);
    }
}
        
