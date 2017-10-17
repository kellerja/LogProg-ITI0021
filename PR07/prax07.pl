element(X, [X|A]).
element(X, [Y|A]) :- element(X, A).

yhisosa([], B, []).
yhisosa([X|A], B, [X|Result]) :-
    yhisosa(A, B, Result),
    element(X, B), !.
yhisosa([X|A], B, Result) :-
    yhisosa(A, B, Result).

yhend(A, [], A).
yhend(A, [X|B], [X|Result]) :-
    yhend(A, B, Result),
    not(element(X, Result)), !.
yhend(A, [X|B], Result) :-
    yhend(A, B, Result).

vahe([], _, []).
vahe([X|A], B, [X|Result]) :-
    vahe(A, B, Result),
    not(element(X, B)), !.
vahe([X|A], B, Result) :-
    vahe(A, B, Result).

ristkorrutis_abi(_, [], [], _).
ristkorrutis_abi([], [Y|B], Result, ACopy) :-
    ristkorrutis_abi(ACopy, B, Result, ACopy), !.
ristkorrutis_abi([X|A], [Y|B], [[X, Y]|Result], ACopy) :-
    ristkorrutis_abi(A, [Y|B], Result, ACopy).

ristkorrutis(A, B, Result) :-
    ristkorrutis_abi(A, B, Result, A).
