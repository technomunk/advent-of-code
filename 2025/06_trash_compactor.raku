use lib '.';
use grid;

sub grab-column(@lines, $column) {
    my $value = 0;
    for @lines -> $r {
        my $digit = $r.substr($column..$column);
        next if $digit ~~ ' ';
        $value = $value * 10 + $digit.Int;
    }
    $value;
}

sub grab-column-numbers(@lines) {
    my @result = [];
    my @column = [];
    for ^@lines[0].chars -> $x {
        my $value = grab-column(@lines, $x);
        if $value != 0 {
            @column.push($value);
        } else {
            @result.push(@column.Seq);
            @column.splice;
        }
    }
    if @column.elems > 0 {
        @result.push(@column.Seq);
    }
    @result;
}

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

my @lines = $*IN.lines;

my @numbers = (@lines>>.split(' ', :skip-empty).head(*-1)>>.map({.Int}) ==> transpose);
my $ops = @lines.tail.split(' ', :skip-empty);

say $ops.&apply(@numbers);

@numbers = grab-column-numbers(@lines.head(*-1));
say $ops.&apply(@numbers);
