use lib '.';
use segment;

class Db {
    has Int $!max is built;
    has Int $!min is built;
    has @!segments of Segment is built;

    method new(Segment $segment) {
        self.bless(min => $segment.min(), max => $segment.max(), segments => [$segment]);
    }

    method build(Db:U: List $lines) {
        my $seg = Segment.new(|$lines.head.split('-'));
        my $result = self.new($seg);

        for $lines.skip -> $line {
            $seg = Segment.new(|$line.split('-'));
            $result.push($seg);
        }
        $result
    }

    method push(Segment $segment) {
        $!min = min($!min, $segment.min());
        $!max = max($!max, $segment.max());
        if $segment.max() < $!min || $segment.min() > $!max {
            @!segments.push($segment);
            return;
        }
        my $seg = $segment;

        my $changed = True;
        while $changed {
            $changed = False;
            for ^@!segments.elems -> $idx {
                my $s = @!segments[$idx];
                if $s.overlaps($seg) {
                    $seg.merge($s);
                    @!segments.splice($idx, 1);
                    $changed = True;
                    last;
                }
            }
        }
        @!segments.push($seg);
    }

    method includes(Int $v --> Bool) {
        if ($v < $!min) || ($v > $!max) {
            return False;
        }
        for @!segments -> $seg {
            if $seg.includes($v) {
                return True;
            }
        }
        return False;
    }

    method elems(--> UInt) {
        @!segments.map({.elems}).sum;
    }

    multi method gist(Db:D: --> Str) {
        @!segments.gist
    }
}

sub index-of(Seq $bale, $elem --> UInt) {
    for ^$bale.elems -> $idx {
        if $bale[$idx] == $elem {
            return $idx;
        }
    }
    return Nil;
}

sub parse-inputs(Seq $lines) is rw {
    my $separator = $lines.&index-of('');
    my $db = Db.build($lines[0..^$separator]);
    my @ingredients = $lines[$separator^..*].map({.Int});
    $db, @ingredients;
}

sub is-fresh(Int $ingredient, Db $db --> Bool) {
    $db.includes($ingredient);
}

multi count-fresh(@db, @ingredients --> UInt) {
    my UInt $count = 0;
    for @ingredients -> $ingredient {
        $count += @db.&is-fresh($ingredient);
    }
    $count;
}

my ($db, @ingredients) := parse-inputs($*IN.lines);

say @ingredients.grep({ $db.includes($_) }).elems;
say $db.elems;
