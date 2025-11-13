% A leap year is divisible by 400, or divisible by 4 but not by 100
leap(Year) :-
    0 is Year mod 400, !.
leap(Year) :-
    0 is Year mod 4,
    \+ (0 is Year mod 100).
