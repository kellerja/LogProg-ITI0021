% Andmed
hulk(a, 1).
hulk(a, 5).
hulk(a, 7).
hulk(a, 9).
hulk(a, a).
hulk(a, z).
hulk(a, 34).
hulk(a, 2).
hulk(a, -66).
hulk(a, x).
hulk(b, 5).
hulk(b, 7).
hulk(b, 0).
hulk(b, 33).
hulk(b, 22).

lind(kajakas).
lind(kotkas).
lind(emu).
lind(part).
lind(pingviin).
lind(tihane).
lind(vares).

% Ülesanne
lendab(X) :- (X = pingviin; X = emu), !, fail.
lendab(_).

:- dynamic suurim/1.

suurim(X, Y) :- suurim(Y), !, Y @< X, retract(suurim(Y)), assertz(suurim(X)).
suurim(X, _) :- assertz(suurim(X)).

max(Hulga_nimi, Max_element) :-
    hulk(Hulga_nimi, Max_element),
    suurim(Max_element, _),
    fail.
max(_, Max_element) :- suurim(Max_element), retract(suurim(Max_element)).

lisa_listi(Element, [], [Element]).
lisa_listi(Element, [H|T], [Element, H|T]) :-
    Element @< H.
lisa_listi(Element, [H|T], [H|Temp]) :- lisa_listi(Element, T, Temp).

lisa_listi(Element) :-
    ajutine_list(Y),
    lisa_listi(Element, Y, Temp),
    retractall(ajutine_list(Y)),
    assertz(ajutine_list(Temp)), !.
lisa_listi(Element) :-
    assertz(ajutine_list([Element])).

viimane_element(Hulga_nimi) :- 
    hulk(Hulga_nimi, Hulga_element), 
    retractall(viimane(Hulga_nimi, Z)), 
    assertz(viimane(Hulga_nimi, Hulga_element)), 
    fail.

jarjestus(Hulga_nimi, List) :-
    retractall(ajutine_list(Z)),
    var(List),
    (nonvar(Hulga_nimi), hulk(Hulga_nimi, _); var(Hulga_nimi)),
    repeat,
    not(viimane_element(Hulga_nimi)),
    viimane(Hulga_nimi, Viimane),
    hulk(Hulga_nimi, Element),
    lisa_listi(Element),
    Element = Viimane,
    ajutine_list(List),
    retractall(ajutine_list(List)),
    retractall(viimane(Hulga_nimi, T)).

% ristkorrutis
ristkorrutis(_, [], []).
ristkorrutis([], _, []).
ristkorrutis([X|A], B, Result) :-
    ristkorrutis(X, B, Result1),
    ristkorrutis(A, B, Result2), !,
    append(Result1, Result2, Result).
ristkorrutis(X, [Y|B], [[X, Y]|Result]) :-
    ristkorrutis(X, B, Result).
