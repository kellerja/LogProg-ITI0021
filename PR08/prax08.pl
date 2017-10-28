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

% Ülesanne
lendab(X) :- pingviin(X), !, fail.
lendab(X) :- emu(X), !, fail.
lendab(X) :- lind(X).

:- dynamic suurim/1.

suurim(X, Y) :- suurim(Y), !, Y @< X, retract(suurim(Y)), assertz(suurim(X)).
suurim(X, _) :- assertz(suurim(X)).

max(Hulga_nimi, Max_element) :-
    hulk(Hulga_nimi, Max_element),
    suurim(Max_element, Y),
    fail.
max(Hulga_nimi, Max_element) :- suurim(Max_element), retract(suurim(Max_element)).

:- dynamic vaikseim/1.
vaikseim(X, Y) :- vaikseim(Y), !, Y @> X, retract(vaikseim(Y)), assertz(vaikseim(X)).
vaikseim(X, _) :- assertz(vaikseim(X)).

min(Hulk, Hulga_nimi, Min_Element) :- 
    Term =.. [Hulk, Hulga_nimi, Min_Element],
    Term,
    vaikseim(Min_Element, Y),
    fail.
min(Hulk, Hulga_nimi, Min_Element) :- vaikseim(Min_Element), retract(vaikseim(Min_Element)).

:- dynamic dynamic_hulk/2.
set_viimane(Hulga_nimi) :- hulk(Hulga_nimi, X), retractall(viimane(Y)), assertz(viimane(X)), fail.
loo_dynamic_hulk(Hulga_nimi) :- hulk(Hulga_nimi, X), assertz(dynamic_hulk(Hulga_nimi, X)), fail.
eemalda_dynamic_hulk(Hulga_nimi) :- retractall(dynamic_hulk(Hulga_nimi, Z)).

add_to_list(Element) :- 
    temp_hulk(Y), 
    append(Y, [Element], Temp),
    retract(temp_hulk(Y)), 
    assertz(temp_hulk(Temp)), !.

jarjestus(Hulga_nimi, List) :-
    not(loo_dynamic_hulk(Hulga_nimi)),
    max(Hulga_nimi, Maksimum),
    assertz(temp_hulk([])),    
    repeat,
    min(dynamic_hulk, Hulga_nimi, Miinimum),
    add_to_list(Miinimum),    
    retract(dynamic_hulk(Hulga_nimi, Miinimum)),
    Maksimum = Miinimum,
    temp_hulk(List),
    eemalda_dynamic_hulk(Hulga_nimi),
    retract(temp_hulk(List)), !.
