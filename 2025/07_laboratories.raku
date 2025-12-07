sub count-timelines(List $grid) {
    my @rays = $grid[0].map(-> $v { $v ~~ 'S' ?? 1 !! 0 });
    my $splits = 0;
    for $grid.tail(*-1) -> $row {
        for $row.grep('^', :k) -> $s {
            $splits += @rays[$s] > 0;
            @rays[$s - 1] += @rays[$s];
            @rays[$s + 1] += @rays[$s];
            @rays[$s] = 0;
        }
    }
    $splits, @rays.sum;
}

my $grid := $*IN.lines>>.comb;
my ($splits, $timelines) = count-timelines($grid);
say $splits;
say $timelines;
