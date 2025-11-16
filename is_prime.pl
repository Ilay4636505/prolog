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