sub split($items, $sep) {
    my @run;
    gather {
        for $items.Seq.kv -> $i, $v {
            if $v ~~ $sep {
                take @run.clone;
                @run = ();
            } else {
                @run.push($v);
            }
        }

        take @run if @run.elems > 0;
    }
}

class Present {
    has Int $.width is built;
    has Bool @.shape is built;

    submethod parse(::?CLASS:U: @lines) {
        self.bless(
            width => @lines[1].chars,
            shape => @lines.tail(*-1).flatmap({ .comb.map(* ~~ '#') })
        );
    }

    method area {
        @.shape.sum
    }
}

class Region {
    has Int $.width is built;
    has Int $.height is built;
    has Int @.presents is built;

    submethod parse(::?CLASS:U: Str $line) {
        my ($shape, $presents) = $line.split(': ');
        my ($width, $height) = $shape.split('x');
        self.bless(
            width => $width.Int,
            height => $height.Int,
            presents => $presents.split(' ')>>.Int
        );
    }

    method area {
        $.width * $.height;
    }

    method fits(Present @shapes) {
        self.area >= @.presents.kv.map(-> $i, $v { @shapes[$i].area * $v }).sum;
    }
}

my $inputs = split($*IN.lines, '').list;
my Present @presents = $inputs.head(*-1).map({ Present.parse($_) });
my Region @regions = $inputs.tail.map({ Region.parse($_) });

say @regions.grep({ .fits(@presents) }).elems;
