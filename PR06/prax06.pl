% Klassid
is_a(loom, elusolend).
    is_a(omnivoor, loom).
    is_a(karnivoor, loom).
    is_a(herbivoor, loom).
is_a(taim, elusolend).
    is_a(oistaim, taim).
    is_a(mitteoistaim, taim).

% teadmisbaas
is_a(rebane, karnivoor).
is_a(siga, omnivoor).
is_a(lehm, herbivoor).
    is_a(maasi, lehm).
is_a(inimene, omnivoor).
    is_a(mari, inimene).
is_a(kass, karnivoor).
is_a(kaelkirjak, herbivoor).
is_a(rabbit, herbivoor).

is_a(porgand, mitteoistaim).
is_a(kapsas, oistaim).
is_a(kartul, mitteoistaim).
is_a(korvits, oistaim).

% Omadused
toitub(elusolend).
hingab(elusolend).
paljuneb(elusolend).
kasvab(elusolend).

liigub(loom).

soob(herbivoor, taim).
soob(karnivoor, loom).
soob(omnivoor, taim).
soob(omnivoor, loom).

loomne_toit(loom).
taimne_toit(taim).

%---------------- Pärimisseos ----------------------
alamklass(Kes, Kelle):-
	is_a(Kes,Kelle), !.
alamklass(Kes, Kelle):-
	is_a(Kes,Vahepealne),
	alamklass(Vahepealne,Kelle).

% Omaduste pärimine
toitub(X) :- alamklass(X, Y), toitub(Y), !.
hingab(X) :- alamklass(X, Y), hingab(Y), !.
paljuneb(X) :- alamklass(X, Y), paljuneb(Y), !.
kasvab(X) :- alamklass(X, Y), kasvab(Y), !.

liigub(X) :- alamklass(X, Y), liigub(Y), !.

loomne_toit(X) :- alamklass(X, Y), loomne_toit(Y), !.
taimne_toit(X) :- alamklass(X, Y), taimne_toit(Y), !.

soob(X, Y) :- 
    X \= Y, loomne_toit(Y), 
    (alamklass(X, omnivoor); alamklass(X, karnivoor)), !.
soob(X, Y) :- 
    X \= Y, taimne_toit(Y),
    alamklass(X, omnivoor).
% söömina vastavalt ajale.
oo(Aeg) :- Aeg >= 0 , Aeg =< 6, !.
oo(Aeg) :- Aeg >= 22, Aeg =< 24, !.

soob(Kes, Keda, Millal) :- 
    soob(Kes, Keda), 
    oo(Millal), !.
soob(Kes, Keda, Millal) :-
    soob(Kes, Keda), 
    \+ oo(Millal).
