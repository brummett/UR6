unit class UR6::DataSource::LoadingTemplate;

has Int $.object-num;
has Str $.table-alias;
has Mu:U $.data-type;
has Mu:U $.final-type;
has Str @.attribute-names;
has Str @.column-names;
has Int @.attribute-positions;
#has Str @.id-attribute-names;
has Int @.id-attribute-positions;
has &.id-resolver;

submethod BUILD(Mu:U :$type!, Int :$!object-num!, Str :$!table-alias!, Int :$start-col!) {
    $!data-type = $!final-type = $type;

    @!attribute-names = $type.^get-attribute-names(:column);
    @!column-names = $type.^get-attributes(:column)>>.column-name;
    @!attribute-positions = $start-col .. ($start-col + @!attribute-names.end);

    my %attribute-positions = do for @!attribute-names Z @!attribute-positions -> ( $name, $pos ) { $name => $pos };
    my @id-attribute-names = $type.^get-attribute-names(:id, :column);
    @!id-attribute-positions = @id-attribute-names.map({ %attribute-positions{$_} });

    my $typeobj = $type.HOW;
    &!id-resolver = sub (@row) {
        $typeobj.composite-id-resolver(@row[@!id-attribute-positions]);
    };
}

method column-list {
    @.column-names.map({ $!table-alias ?? $!table-alias ~ $_ !! $_ });
}
