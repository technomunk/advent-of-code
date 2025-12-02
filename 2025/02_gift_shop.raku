sub parse-range(Str $range) {
    my ($l, $r) = $range.split('-');
    $l.Int .. $r.Int;
}

sub is-odd(Int $n) {
    return $n & 1 == 1;
}

sub is-invalid(Int $id) {
    my $digit-count = ceiling(log10($id));
    return False if $digit-count ==> is-odd;
    my $base = 10 ** ($digit-count div 2);
    return ($id div $base) == ($id mod $base);
}

sub solve-p1(Seq $ranges) {
    $ranges>>.grep(&is-invalid)
        .flat
        .sum;
}

my $ranges = $*IN.slurp.split(',').map(&parse-range);
say solve-p1($ranges);
