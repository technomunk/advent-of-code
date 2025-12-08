unit module dim3d;

class Point3 is export {
    has Int $.x is built is rw;
    has Int $.y is built is rw;
    has Int $.z is built is rw;

    method parse(::?CLASS:U: Str $line) {
        my ($x, $y, $z) = $line.split(',').map({.Int});
        self.bless(x => $x, y => $y, z => $z);
    }

    multi method gist {
        "(x=$.x y=$.y z=$.z)";
    }

    method WHICH {
        ValueObjAt.new("Point3|$.x|$.y|$.z");
    }
}

sub dist2(Point3:D $a, Point3:D $b --> Int) is export {
    my $dx = $a.x() - $b.x();
    my $dy = $a.y() - $b.y();
    my $dz = $a.z() - $b.z();
    $dx*$dx + $dy*$dy + $dz*$dz;
}
