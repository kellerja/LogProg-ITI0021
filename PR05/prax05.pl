viimane_element(A, [A]) :- !.
viimane_element(X,[_|L]) :-
    viimane_element(X, L).

suurim([], []).
suurim([A], [A]).
suurim([A, B|List], [A|X]) :-
    A > B, suurim([B|List], X), !.
suurim([A, B|List], [B|X]) :-
    B > A, suurim([B|List], X).
