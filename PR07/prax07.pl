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
