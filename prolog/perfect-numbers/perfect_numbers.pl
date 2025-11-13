% Reject non-positive integers
classify(Number, _) :-
    Number =< 0,
    !,
    fail.

% Find all proper divisors (factors excluding the number itself)
% For 1, there are no proper divisors
proper_divisors(1, []) :- !.
proper_divisors(N, Divisors) :-
    N > 1,
    proper_divisors(N, 1, [], Divisors).

% Helper predicate to find divisors up to sqrt(N)
proper_divisors(N, Current, Acc, Divisors) :-
    Current * Current > N,
    !,
    Divisors = Acc.
proper_divisors(N, Current, Acc, Divisors) :-
    Current * Current =:= N,
    !,
    Divisors = [Current | Acc].
proper_divisors(N, Current, Acc, Divisors) :-
    0 is N mod Current,
    !,
    Other is N // Current,
    Next is Current + 1,
    (   Other =:= N
    ->  % Current is 1, Other is N itself, only add 1
        proper_divisors(N, Next, [Current | Acc], Divisors)
    ;   % Both Current and Other are proper divisors
        proper_divisors(N, Next, [Current, Other | Acc], Divisors)
    ).
proper_divisors(N, Current, Acc, Divisors) :-
    Next is Current + 1,
    proper_divisors(N, Next, Acc, Divisors).

% Calculate aliquot sum (sum of proper divisors)
aliquot_sum(N, Sum) :-
    proper_divisors(N, Divisors),
    sum_list(Divisors, Sum).

% Classify based on aliquot sum
classify(Number, perfect) :-
    Number > 0,
    aliquot_sum(Number, Sum),
    Sum =:= Number,
    !.
classify(Number, abundant) :-
    Number > 0,
    aliquot_sum(Number, Sum),
    Sum > Number,
    !.
classify(Number, deficient) :-
    Number > 0,
    aliquot_sum(Number, Sum),
    Sum < Number.
