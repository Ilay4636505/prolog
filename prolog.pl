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
issin(X, [_|T]) :- issin(X,T).
sumlis([],0).
sumlis([H|T],N) :- sumlis(T, N1), N is N1 + H.
holiday(sunday, passover).
weather(sunday, good).
weather(friday, good).
weather(saturday, good).

weekend(friday).
weekend(saturday).
picnic(Day) :- weather(Day, good), !, weekend(Day).
picnic(Day) :- holiday(Day, passover).
animal(snake).
animal(dog).
likes(moshe, Animal) :- animal(Animal), not(snake(Animal)).