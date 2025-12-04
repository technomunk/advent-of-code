role Grid {
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

sub parse-grid(Seq $lines) is rw {
    my $width = $lines[0].chars;
    my $height = $lines.elems;
    my @grid[$height;$width] of Str;

    for ^$height -> $y {
        my $chars = $lines[$y].comb;
        @grid[$y;$_] = $chars[$_] for ^$width;
    }
    @grid does Grid;

    @grid
}

sub is-movable(Grid $grid, UInt $x, UInt $y --> Bool) {
    $grid[$y;$x] ~~ '@' && ($grid.neighbors($x, $y).grep('@') < 4);
}

sub count-movable(Grid $grid --> UInt) {
    my $count = 0;
    for ^$grid.height -> $y {
        for ^$grid.width -> $x {
            next if $grid[$y;$x] ~~ '.';
            $count += $grid.&is-movable($x, $y);
        }
    }
    $count;
}

sub count-movable-with-removal(Grid $grid) {
    my $check-more = True;
    my $count = 0;
    while $check-more {
        $check-more = False;
        for ^$grid.height -> $y {
            for ^$grid.width -> $x {
                next if $grid[$y;$x] ~~ '.';
                if $grid.&is-movable($x, $y) {
                    $grid[$y;$x] = '.';
                    $count += 1;
                    $check-more = True;
                }
            }
        }
    }
    $count;
}

my @grid := $*IN.lines.&parse-grid;

say @grid.&count-movable;
say @grid.&count-movable-with-removal;
