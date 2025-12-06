unit module Dim2D;

role Grid is export {
    method width(::?CLASS:D: --> UInt) {
        self.shape[1]
    }

    method height(::?CLASS:D: --> UInt) {
        self.shape[0]
    }

    method neighbors(::?CLASS:D: UInt $x, UInt $y) {
        my ($min-y, $max-y) = max(0, $y - 1), min(self.height - 1, $y + 1);
        my ($min-x, $max-x) = max(0, $x - 1), min(self.width - 1, $x + 1);
        my @result;
        for $min-y..$max-y -> $ny {
            for $min-x..$max-x -> $nx {
                next if ($ny == $y && $nx == $x);
                @result.push(self[$ny;$nx]);
            }
        }
        @result
    }
}

sub transpose(@grid) is export is rw {
    my $height = @grid[0].elems;
    my @result = [];
    for ^$height -> $y {
        @result.push(@grid.map(-> $r { $r[$y] }));
    }

    @result;
}
