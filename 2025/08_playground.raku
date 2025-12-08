use lib '.';
use dim3d;

class CircuitGraph {
    has @!circuits is built = [];
    has %!map is built = {};

    method connect(Point3 $a, Point3 $b) {
        my $ac = %!map{$a};
        my $bc = %!map{$b};
        if $ac.defined && $bc.defined {
            self.merge($ac, $bc);
        } elsif $ac.defined {
            @!circuits[$ac].push($b);
            %!map.push($b => $ac);
        } elsif $bc.defined {
            @!circuits[$bc].push($a);
            %!map.push($a => $bc);
        } else {
            my $key = @!circuits.elems;
            @!circuits.push([$a, $b]);
            %!map.push($a => $key, $b => $key);
        }
    }

    method are-connected(Point3 $a, Point3 $b --> Bool) {
        my $ac = %!map{$a};
        my $bc = %!map{$b};
        return $ac.defined && $bc.defined && $ac == $bc;
    }

    method merge(Int $ac, Int $bc) {
        my $smaller-index = min($ac, $bc);
        my $larger-index = max($ac, $bc);
        @!circuits[$smaller-index].push(@!circuits[$larger-index]);
        @!circuits.splice($larger-index, 1);
        for %!map.kv -> $k, $v {
            if $v == $larger-index {
                %!map{$k} = $smaller-index;
            } elsif $v > $larger-index {
                %!map{$k} = $v - 1;
            }
        }
    }

    method largest(::?CLASS:D: Int $n = 1 --> Int) {
        [*] @!circuits.map({.elems}).sort.tail($n);
    }
}

my @points = $*IN.lines.map({ Point3.parse($_) });
my $dists := @points
    .keys
    .combinations(2)
    .map(-> ($a, $b) { [$a, $b, dist2(@points[$a], @points[$b])] })
    .sort(-> $a, $b { $a[2] <=> $b[2] });

my $graph = CircuitGraph.new();
my $connection-count = @*ARGS[0];

for $dists -> [$ai, $bi, $d] {
    last unless $connection-count;
    my $a = @points[$ai];
    my $b = @points[$bi];
    unless $graph.are-connected($a, $b) {
        $graph.connect($a, $b);
        $connection-count -= 1;
    }
}

say $graph.largest(3);
