unit module dim2d;
use segment;

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

class Rect2 is export {
    has Segment $.x is built;
    has Segment $.y is built;

    method new(Point2 $a, Point2 $b) {
        self.bless(x => Segment.new($a.x, $b.x), y => Segment.new($a.y, $b.y))
    }

    method area {
        $.x.length * $.y.length
    }

    method gist {
        "R\{x={$.x.gist} y={$.y.gist}\}"
    }

    method contains(Point2 $p --> Bool) {
        $.x.contains($p.x) && $.y.contains($p.y);
    }

    method includes(Point2 $p --> Bool) {
        $.x.includes($p.x) && $.y.includes($p.y);
    }
}
