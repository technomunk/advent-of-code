use lib '.';
use graph;

my DirectedGraph $graph .= new;

for $*IN.lines -> $line {
    my ($from, $to) = $line.split(': ');
    $graph.link($from, |$to.split(' '));
}

say $graph.count-paths('you', 'out');

my @paths;
# since the graph is a acyclic - there's only one direction in which correct paths can take us
if $graph.count-paths('dac', 'fft') != 0 {
    @paths = [$graph.count-paths('svr', 'dac'), $graph.count-paths('dac', 'fft'), $graph.count-paths('fft', 'out')];
} else {
    @paths = [$graph.count-paths('svr', 'fft'), $graph.count-paths('fft', 'dac'), $graph.count-paths('dac', 'out')];
}
say [*] @paths;
