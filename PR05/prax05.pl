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
    paki([B|List], X).

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

paaris_arv(N) :- 
    Z is N mod 2, Z = 0.

paaritu_arv(N) :- 
    not(paaris_arv(N)).

suurem_kui(N, X) :-
    N > X.

vordle_predikaadiga([], _, []).
vordle_predikaadiga([H|T], [Predikaat|Argumendid], [H|X]) :-
    vordle_predikaadiga(T, [Predikaat|Argumendid], X),
    Term =.. [Predikaat, H|Argumendid], call(Term), !.
 vordle_predikaadiga([H|T], [Predikaat|Argumendid], X) :-
    vordle_predikaadiga(T, [Predikaat|Argumendid], X).
