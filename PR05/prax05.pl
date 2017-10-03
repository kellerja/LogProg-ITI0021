viimane_element(A, [A]) :- !.
viimane_element(X,[_|L]) :-
    viimane_element(X, L).


paki([], []).
paki([B], [B]).
paki([A, B|List], X) :-
    A = B, paki([B|List], X), !.
paki([A, B|List], [A|X]) :-
    not(A = B), paki([B|List], X).

duplikeeri([], []).
duplikeeri([H|T],[H, H|X]) :-
    duplikeeri(T, X).

kordista_element(A, 1, []).
kordista_element(A, N, [A|Result]) :-
    Z is N - 1,
    kordista_element(A, Z, Result), !.

kordista([], _, []).
kordista([H|T], N, [H|X]) :-
    kordista_element(H, N, Result),
    kordista(T, N, Y),
    append(Result, Y, X), !.
