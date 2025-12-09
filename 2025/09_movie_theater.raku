use lib '.';
use dim2d;

my @points = $*IN.lines.map({ Point2.parse($_) });

say @points.combinations(2)
    .map({ rect-area(|$_) })
    .max;
