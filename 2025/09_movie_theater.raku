use lib '.';
use dim2d;
use segment;

class Loop {
    has Point2 @.points is built;

    sub invalidated-by(Rect2 $rect, Point2 $a, Point2 $b --> Bool) {
        if ($a.x == $b.x) {
            $rect.x.contains($a.x) && $rect.y.overlaps($a.y, $b.y);
        } else {
            die "{$a.gist} - {$b.gist} is not horizontal" if $a.y != $b.y;
            $rect.y.contains($a.y) && $rect.x.overlaps($a.x, $b.x);
        }
    }

    method new($points) {
        self.bless(points => $points.list)
    }

    method rects {
        @.points.combinations(2).map({ Rect2.new(|$_) })
    }

    method invalidates(Rect2 $rect) {
        my $last-index = @.points.elems - 1;
        for 0..$last-index -> $i {
            my $a = @.points[$i];
            my $b = @.points[$i == $last-index ?? 0 !! ($i + 1)];
            if $rect.&invalidated-by($a, $b) {
                return True;
            }
        }
        False;
    }
}

my $loop := Loop($*IN.lines.map({ Point2.parse($_) }));
my @rects = $loop.rects.sort({ $^b.area <=> $^a.area });

say @rects[0].area;
say @rects.first({ ! $loop.invalidates($_) }).area;
