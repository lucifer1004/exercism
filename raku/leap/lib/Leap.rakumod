unit module Leap;

sub is-leap-year ($year) is export {
    if $year %% 400 {
        return True;
    } elsif $year %% 100 {
        return False;
    } elsif $year %% 4 {
        return True;
    } else {
        return False;
    }
}
