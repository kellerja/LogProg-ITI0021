viimane_element(A, [A]) :- !.
viimane_element(X,[_|L]) :-
    viimane_element(X, L).

suurim([], []).
suurim([A], [A]).
suurim([A, B|List], [A|X]) :-
    A > B, suurim([B|List], X), !.
suurim([A, B|List], [B|X]) :-
    B > A, suurim([B|List], X).

paki([], []).
paki([B], [B]).
paki([A, B|List], X) :-
    A = B, paki([B|List], X), !.
paki([A, B|List], [A|X]) :-
    not(A = B), paki([B|List], X).

duplikeeri([], []).
duplikeeri([H|T],[H, H|X]) :-
    duplikeeri(T, X).
