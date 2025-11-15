gcd(X, X, X).
gcd(X,Y, D) :- 
   X < Y,
   Y1 is Y - X,
   gcd(X, Y1, D).
gcd(X,Y,D) :- 
    X > Y,
    gcd(Y, X, D).
size([], 0).
size([_|T], N) :- size(T, N1), N is N1 + 1.
issin(X, [X|_]).
issin(X, [_,T]) :- issin(X,T).
sumlis([],0).
sumlis([H|T],N) :- sumlis(T, N1), N is N1 + H.
