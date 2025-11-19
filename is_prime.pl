is_prime(1).
is_prime(X) :- helper(X, X).

divide(X, Y):-  0 is X mod Y, X =\= Y.
helper(_, 1).
helper(X, Y):- 
    Y > 1,
    not(divide(X, Y)),
    !,
    Y1 is Y - 1,
    helper(X, Y1).
# is_prime(N) :-
#     N > 1,
#     N =:= 2, !.
# is_prime(N) :-
#     N > 1,
#     N mod 2 =:= 0, !,
#     fail.
# is_prime(N) :-
#     N > 1,
#     check_divisor(N, 3).

# check_divisor(N, D) :-
#     D * D > N.

# check_divisor(N, D) :-
#     D * D =< N,
#     N mod D =\= 0,
#     D2 is D + 2,
#     check_divisor(N, D2).