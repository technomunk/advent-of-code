#!raku

sub parse-instr(Str $line) {
    given $line {
        when .starts-with('R') { $line.substr(1).Int }
        when .starts-with('L') { -$line.substr(1).Int }
        default { die "Invalid instruction: $line" }
    }
}

sub solve-p1(@input) {
    my $count = 0;
    my $pos = 50;
    for @input -> $step {
        $pos = ($pos + $step) % 100;
        $count += $pos == 0;
    }
    $count;
}

sub solve-p2(@input) {
    my $count = 0;
    my $pos = 50;
    for @input -> $step {
        my $last = $pos;
        $pos += $step;
        if $pos <= 0 {
            $count += (-$pos div 100) + ($last != 0);
        } else {
            $count += $pos div 100;
        }
        $pos %= 100;
    }
    $count;
}

my $input := map(&parse-instr, $*IN.lines);
say("Part 1: ", solve-p1($input));
say("Part 2: ", solve-p2($input));
