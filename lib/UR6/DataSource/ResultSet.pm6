unit class UR6::DataSource::ResultSet does Iterator;

use UR6::DataSource;
use UR6::DataSource::LoadingTemplate;

# Like UR's data source iterator
my $id = 0;

has Int $.id = $id++;
has Bool $.is-sorted = False; # True if results are sorted by ID attribs and filter -order-by
has Bool $.is-exact = False; # True if the results exactly match the filters
has Str @.headers is required;
has Iterator $!iterator;

submethod BUILD (:$content, :$iterator, :@!headers, Bool :$!is-sorted = False, Bool :$!is-exact = False) {
    unless $content.defined xor $iterator.defined {
        die "Must supply either :content or :iterator, not both";
    }

    if $content.defined {
        unless $content ~~ Positional {
            die ":content must be a Positional";
        }
        $!iterator = $content.iterator;

    } else {
        unless $iterator ~~ Iterator {
            die ":iterator must be an Iterator";
        }
        $!iterator = $iterator;
    }
}

method pull-one {
    $!iterator.pull-one;
}
