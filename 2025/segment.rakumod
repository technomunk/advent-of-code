unit module segment;

class Segment is export {
    has Int $.min is built is rw;
    has Int $.max is built is rw;

    method new($a, $b) {
        my $av = $a.Int;
        my $bv = $b.Int;
        self.bless(min => min($av, $bv), max => max($av, $bv));
    }

    method includes(Int $v --> Bool) {
        $v >= $.min && $v <= $.max;
    }

    #| Check that the provided $v is within the inner section of the segment
    method contains(Int $v --> Bool) {
        $v > $.min && $v < $.max;
    }

    method overlaps(Segment $o) {
        self.includes($o.min)
            || self.includes($o.max)
            || $o.includes($.min)
            || $o.includes($.max);
    }

    method merge(Segment $o) {
        $.min = min($o.min, $.min);
        $.max = max($o.max, $.max);
    }

    method length {
        $.max - $.min + 1;
    }

    method elems {
        self.length
    }

    multi method gist(Segment:D: --> Str) {
        "$.min-$.max"
    }
}
