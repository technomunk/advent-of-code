unit module dim2d;

class Point2 is export {
    has Int $.x is built;

    has Int $.y is built;

    method parse(::?CLASS:U: Str $line, Str $sep = ',') {
        my ($x, $y) = $line.split($sep).map({ .Int });
        self.bless(x => $x, y => $y);
    }

    method gist {
        "(x=$.x,y=$.y)";
    }
}

sub rect-area(Point2 $a, Point2 $b) is export {
    my $dx = abs($a.x() - $b.x()) + 1;
    my $dy = abs($a.y() - $b.y()) + 1;
    $dx * $dy;
}
