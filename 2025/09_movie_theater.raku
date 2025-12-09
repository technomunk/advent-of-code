use lib '.';
use dim2d;

class Loop {
    has Point2 @.points is built;

    method new($points) {
        self.bless(points => $points.list)
    }

    method rects {
        @.points.combinations(2).map({ Rect2.new(|$_) })
    }

    method intersects(Rect2 $rect) {
        my $last-index = @.points.elems - 1;
        for 0..$last-index -> $i {
            my $a = @.points[$i];
            my $b = @.points[$i == $last-index ?? $i !! 0];
            if $rect.intersects($a, $b) {
                return True;
            }
        }
        False;
    }
}

my $loop := Loop($*IN.lines.map({ Point2.parse($_) }));

my $p1 = 0;
my $p2 = 0;
for $loop.rects -> $r {
    my $a = $r.area;
    if ($a > $p1) {
        $p1 = $a;
    }
    if ($a > $p2 && ! $loop.intersects($r)) {
        $p2 = $a;
    }
}
say $p1;
say $p2;
