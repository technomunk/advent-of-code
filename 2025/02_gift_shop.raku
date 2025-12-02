sub parse-range(Str $range) {
    my ($l, $r) = $range.split('-');
    $l.Int .. $r.Int;
}

sub is-odd(Int $n) {
    return $n & 1 == 1;
}

sub is-symmetrically-invalid(Int $id) {
    my $digit-count = ceiling(log10($id));
    return False if $digit-count ==> is-odd;
    my $base = 10 ** ($digit-count div 2);
    return ($id div $base) == ($id mod $base);
}

sub is-seq-invalid(Int $id) {
    my $half-digit-count = ceiling(log10($id)) div 2;
    for 1..$half-digit-count -> $dc {
        my $base = 10 ** $dc;
        my $pattern = $id % $base;
        if $pattern < (10 ** ($dc - 1)) { next; }
        my $rest = $id div $base;

        while $rest % $base == $pattern {
            $rest = $rest div $base;
        }
        if $rest == 0 {
            return True;
        }
    }
    return False;
}

sub solve($ranges, &validity) {
    $ranges>>.grep(&validity)
        .flat
        .sum;
}

my $ranges := $*IN.slurp.split(',').map(&parse-range).cache;
say solve($ranges, &is-symmetrically-invalid);
say solve($ranges, &is-seq-invalid);
