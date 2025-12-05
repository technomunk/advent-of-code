sub index-of(Seq $bale, $elem --> UInt) {
    for ^$bale.elems -> $idx {
        if $bale[$idx] == $elem {
            return $idx;
        }
    }
    return Nil;
}

sub parse-range(Str $line --> Range) {
    my ($start, $end) = $line.split('-');
    $start.Int .. $end.Int;
}

sub parse-inputs(Seq $lines) is rw {
    my $separator = $lines.&index-of('');
    my @db = $lines[0..^$separator].map(&parse-range);
    my @ingredients = $lines[$separator^..*].map({.Int});
    @db, @ingredients;
}

sub is-spoiled(@db, Int $ingredient --> Bool) {
    for @db -> $r {
        if $ingredient ~~ $r {
            return True;
        }
    }
    False;
}

sub count-spoiled(@db, @ingredients --> UInt) {
    my UInt $count = 0;
    for @ingredients -> $ingredient {
        $count += @db.&is-spoiled($ingredient);
    }
    $count;
}

my (@db, @ingredients) := parse-inputs($*IN.lines);

say count-spoiled(@db, @ingredients);
