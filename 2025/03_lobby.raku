sub max-index(List $seq) {
    my $index = 0;
    my $value = $seq[0];
    for 1..^$seq.elems -> $idx {
        if $seq[$idx] > $value {
            $value = $seq[$idx];
            $index = $idx;
        }
    }
    ($index, $value)
}

sub max-joltage(Seq $bank, UInt $len) {
    # use a greedy algorithm to grab the largest number
    # that laves sufficient tail-length
    my $joltage = 0;
    my $start = 0;
    my Int $battery = 0;
    my Int $battery-index = 0;
    for reverse(0..^$len) -> $tail-len {
        my $end = $bank.elems - $tail-len;
        my $partial-bank = $bank[$start..^$end];
        ($battery-index, $battery) = max-index($partial-bank);
        $start += 1 + $battery-index;
        $joltage = $joltage * 10 + $battery;
    }
    $joltage;
}

my $battery-banks := $*IN.lines>>.comb>>.map({.Int});

say $battery-banks.map({max-joltage($_, 2)}).sum;
say $battery-banks.map({max-joltage($_, 12)}).sum;
