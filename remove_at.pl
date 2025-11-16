remove_at(X, [X|R], 1, R).
remove_at(X, [H|Y], K, [H|R]) :- 
    K1 is K - 1,
    remove_at(X, Y, K1, R).