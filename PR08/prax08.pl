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

lind(kotkas).
lind(emu).
lind(pingviin).
lind(tihane).
% Ülesanne
lendab(X) :- var(X), lind(X), lendab(X).
lendab(X) :- X = pingviin, !, fail.
lendab(X) :- X = emu, !, fail.
lendab(X) :- lind(X).

:- dynamic suurim/1.

suurim(X, Y) :- suurim(Y), !, Y @< X, retract(suurim(Y)), assertz(suurim(X)).
suurim(X, _) :- assertz(suurim(X)).

max(Hulga_nimi, Max_element) :-
    hulk(Hulga_nimi, Max_element),
    suurim(Max_element, Y),
    fail.
max(Hulga_nimi, Max_element) :- suurim(Max_element), retract(suurim(Max_element)).

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
