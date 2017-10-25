% Andmed
hulk(a, 1).
hulk(a, 5).
hulk(a, 7).
hulk(a, 9).
hulk(a, 3).
hulk(a, 2).
hulk(a, -66).
hulk(a, 0).

% Ülesanne
lendab(X) :- pingviin(X), !, fail.
lendab(X) :- emu(X), !, fail.
lendab(X) :- lind(X).

:- dynamic suurim/1.

suurim(X, Y) :- suurim(Y), !, Y < X, retract(suurim(Y)), assertz(suurim(X)).
suurim(X, _) :- assertz(suurim(X)).

max(Hulga_nimi, Max_element) :-
    hulk(Hulga_nimi, Max_element),
    suurim(Max_element, Y),
    fail.
max(Hulga_nimi, Max_element) :- suurim(Max_element), retract(suurim(Max_element)).

:- dynamic dynamic_hulk/2.
set_viimane(Hulga_nimi) :- hulk(Hulga_nimi, X), retractall(viimane(Y)), assertz(viimane(X)), fail.
loo_dynamic_hulk(Hulga_nimi) :- hulk(Hulga_nimi, X), assertz(dynamic_hulk(Hulga_nimi, X)), fail.

jarjestus(Hulga_nimi, List) :-
    fail,
    not(set_viimane(a)),
    not(loo_dynamic_hulk(Hulga_nimi)),
    repeat,    
    dynamic_hulk(Hulga_nimi, Element),
    write(Element),write(' '),nl,
    viimane(Viimane),
    Viimane = Element.
