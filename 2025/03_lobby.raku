sub max-joltage(Seq $bank) {
    my $left = 0;
    my $left-index = -1;
    for ^($bank.elems - 1) -> $index {
        if $bank[$index] > $left {
            $left = $bank[$index];
            $left-index = $index;
        }
    }
    my $right = max($bank[($left-index+1)..*]);
    $left * 10 + $right;
}

my $battery-banks := $*IN.lines>>.comb>>.map({.Int});

say $battery-banks.map(&max-joltage).sum;
