use lib '.';
use grid;

sub parse-grid(Seq $lines) is rw {
    my $width = $lines[0].chars;
    my $height = $lines.elems;
    my @grid[$height;$width];

    for ^$height -> $y {
        my $chars = $lines[$y].comb;
        @grid[$y;$_] = $chars[$_] ~~ '@' for ^$width;
    }
    @grid does Grid;

    @grid
}

sub is-movable(Grid $grid, UInt $x, UInt $y --> Bool) {
    $grid[$y;$x] && ($grid.neighbors($x, $y).sum < 4);
}

sub count-movable(Grid $grid --> UInt) {
    my $count = 0;
    for ^$grid.height -> $y {
        for ^$grid.width -> $x {
            next if !$grid[$y;$x];
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
                next if !$grid[$y;$x];
                if $grid.&is-movable($x, $y) {
                    $grid[$y;$x] = False;
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
