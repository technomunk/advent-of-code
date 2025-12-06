use lib '.';
use grid;

multi apply(Str $op, Seq $values --> Int) {
    given $op {
        when '*' { [*] $values }
        when '+' { [+] $values }
        default { die "Unknown op: $op" }
    }
}

multi apply(Seq:D $ops, Array:D $values --> Int) {
    my $total = 0;
    for ^$ops.elems -> $idx {
        $total += $ops[$idx].&apply($values[$idx]);
    }
    $total;
}

my $lines = $*IN.lines>>.split(' ', :skip-empty);

my @numbers := ($lines.head(*-1)>>.map({.Int}) ==> transpose);
my $ops = $lines.tail;

say $ops.&apply(@numbers);
