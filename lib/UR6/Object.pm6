use UR6::Context;

unit role UR6::Object;
has $.__id;

method create(Any:U: *%args --> UR6::Object) {
    UR6::Context.current.create-entity(self.WHAT, |%args);
}

method get(Any:U: *%args --> Iterable) {
    UR6::Context.current.fetch(self.WHAT, %args);
}

method delete(Any:D:) {
    UR6::Context.current.delete-entity(self.WHAT, self.__id);
}
