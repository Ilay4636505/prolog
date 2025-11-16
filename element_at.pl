element_at(X, [X|_], 1).
element_at(X, [_|Y], K) :- 
    K1 is K - 1,
    element_at(X, Y, K1).