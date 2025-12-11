unit module graph;

class DirectedGraph is export {
    has %!fwd is built;
    has %!bwd is built;
    has @!order;

    method new {
        self.bless(fwd => {}, bwd => {});
    }

    method link(Str $name, *@nodes) {
        for @nodes -> $node {
            %!fwd.push($name => $node);
            %!bwd.push($node => $name);
        }
    }

    multi method say(::?CLASS:D:) {
        for %!fwd.kv -> $from, $to {
            say "$from => $to";
        }
    }

    method order {
        unless @!order {
            @!order = [];
            # unprocessed incoming edges
            my %uie is default(0);
            for %!bwd.kv -> $t, $f {
                %uie{$t} = $f.elems;
            }
            my @queue = %!fwd.keys.grep(-> $n { %uie{$n} == 0 });

            while my $from = @queue.shift {
                @!order.push($from);
                for %!fwd{$from}.values -> $to {
                    %uie{$to} -= 1;
                    @queue.push($to) if %uie{$to} == 0;
                }
            }
        }

        @!order;
    }

    method count-paths(Str $from, Str $to) {
        # Use Kahn's algorithm
        my %paths is default(0) = $from => 1;
        for self.order -> $f {
            my $p = %paths{$f};
            next if $p == 0;
            for %!fwd{$f}.values -> $t {
                %paths{$t} += $p;
            }
        }

        %paths{$to};
    }
}
