grammar InitInstrGm {
    rule TOP { <lights> <button>+ <joltage> }
    rule lights { '[' (<[.#]>+ % '') ']' }
    rule button { '(' (\d+)+ % ',' ')' }
    rule joltage { '{' (\d+)+ % ',' '}' }
}

sub make-button(Match $btn) {
    $btn[0].map({ .Int }).list;
}

class InitInstr {
    has Bool @.lights is built;
    has @.buttons is built;
    has Int @.joltage is built;

    submethod parse(Str $line) {
        my $m = InitInstrGm.parse($line) or die "Couldn't parse $line";
        self.new($m<lights>, $m<button>, $m<joltage>);
    }

    method new($lights, $buttons, $joltage) {
        self.bless(
            lights => $lights[0].comb.map({ $_ ~~ '#' }).list,
            buttons => $buttons.map(&make-button),
            joltage => $joltage[0].map({.Int}).list,
        )
    }
}

my @instructions = $*IN.lines.map({ InitInstr.parse($_) });
say @instructions;
