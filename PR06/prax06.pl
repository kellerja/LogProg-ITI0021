% Klassid
is_a(loom, elusolend).
    is_a(omnivoor, loom).
    is_a(karnivoor, loom).
    is_a(herbivoor, loom).
    is_a(oistaime_sooja, loom).
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
is_a(muruniiduk, oistaime_sooja).

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
soob(oistaime_sooja, oistaim).

loomne_toit(loom).
taimne_toit(taim).

%---------------- Pärimisseos ----------------------
alamklass(Kes, Kelle):-
	is_a(Kes,Kelle), !.
alamklass(Kes, Kelle):-
	is_a(Kes,Vahepealne),
	alamklass(Vahepealne,Kelle).

alamhulk(X,Y):-  is_a(X,Y).
alamhulk(X,Y):-  is_a(W,Y), alamhulk(X,W).
% Omaduste pärimine
toitub(X) :- alamklass(X, Y), toitub(Y).
hingab(X) :- alamklass(X, Y), hingab(Y).
paljuneb(X) :- alamklass(X, Y), paljuneb(Y).
kasvab(X) :- alamklass(X, Y), kasvab(Y).

liigub(X) :- alamklass(X, Y), liigub(Y).

loomne_toit(X) :- alamhulk(X, Y), is_a(X, Y), loomne_toit(Y), !.
taimne_toit(X) :- alamhulk(X, Y), is_a(X, Y), taimne_toit(Y), !.

% söömina vastavalt ajale.
oo(Aeg) :- Aeg >= 0 , Aeg =< 6, !.
oo(Aeg) :- Aeg >= 22, Aeg =< 24, !.

soob(Kes, Keda, Millal) :- 
    oo(Millal),
    loomne_toit(Keda),
    loomne_toit(Toit),
    soob(Sooja, Toit),
    alamklass(Kes, Sooja),
    %alamklass(Keda, Toit),
    Kes \= Keda, !.
soob(Kes, Keda, Millal) :-
    \+ oo(Millal),
    taimne_toit(Keda),
    taimne_toit(Toit),
    soob(Sooja, Toit),
    alamklass(Kes, Sooja),
    %alamklass(Keda, Toit),
    Kes \= Keda.
