% :- module(arbiter, [peapredikaat/3]).
% :- export(iapb155243/3).

iapb155243(Color, 0, 0) :- 
    ruut(X, Y, Color),
    tamm(Color),
    leia_suund(Color, Suund),
    votmine_tammiga(X, Y, Suund, _, _),
    !.
iapb155243(Color, 0, 0) :- 
    ruut(X, Y, Color),
    leia_suund(Color, Suund),
    votmine(X, Y, Suund, _, _),
    !.
iapb155243(Color, 0, 0) :- 
    ruut(X, Y, Color),
    leia_suund(Color, Suund),
    kaimine(X, Y, Suund, _, _),
    !.
iapb155243(Color, X, Y) :- 
    leia_suund(Color, Suund),
    votmine(X, Y, Suund, _, _),
    !.
iapb155243(_, _, _).

leia_suund(1,1):- !.
leia_suund(2,-1).

color(BoardPiece, Color) :-
    Z is BoardPiece mod 10,
    Z = 0,
    X is BoardPiece / 10,
    Color = X, !.
color(BoardPiece, BoardPiece).

tamm(BoardPiece) :-
    V is BoardPiece mod 10, V = 0.

votmine(X,Y,Suund,X2,Y2):-
    kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2),
    vota(X,Y,Suund,X1,Y1,X2,Y2).

votmine_tammiga(X, Y, Suund, X1, Y1, X3, Y3):-
    kas_saab_votta_tammiga(X, Y, Suund, X1, Y1, X2, Y2, Kaimise_suund),
    parim_maandumiskoht(X2, Y2, Kaimise_suund, X3, Y3).

parim_maandumiskoht(X2, Y2, Kaimise_suund, X2, Y2).

kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2):-  % Votmine edasi paremale
    DeltaX is Suund,
    DeltaY is 1,
    kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2).
kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2):-  % Votmine edasi vasakule
    DeltaX is Suund,
    DeltaY is - 1,
    kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2).
kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2):-  % Votmine tagasi paremale
    DeltaX is Suund * -1,
    DeltaY is 1,
    kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2).
kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2):-  % Votmine tagasi vasakule
    DeltaX is Suund * -1,
    DeltaY is -1,
    kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2).

kas_saab_votta_tammiga(X,Y,Suund,X1,Y1,X2,Y2, suund(Suund, 1)):-  % Votmine edasi paremale
    DeltaX is Suund,
    DeltaY is 1,
    (
        kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2);
        Xtemp is X + DeltaX, Ytemp is Y + DeltaY,
        on_valja_piirides(Xtemp, Ytemp),
        ruut(Xtemp, Ytemp, 0),
        kas_saab_votta_tammiga(Xtemp, Ytemp, Suund, X1, Y1, X2, Y2, suund(DeltaX, DeltaY))
    ).
kas_saab_votta_tammiga(X,Y,Suund,X1,Y1,X2,Y2, suund(Suund, -1)):-  % Votmine edasi vasakule
    DeltaX is Suund,
    DeltaY is - 1,
    (
        kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2);
        Xtemp is X + DeltaX, Ytemp is Y + DeltaY,
        on_valja_piirides(Xtemp, Ytemp),
        ruut(Xtemp, Ytemp, 0),
        kas_saab_votta_tammiga(Xtemp, Ytemp, Suund, X1, Y1, X2, Y2, suund(DeltaX, DeltaY))
    ).
kas_saab_votta_tammiga(X,Y,Suund,X1,Y1,X2,Y2, suund(DeltaX, 1)):-  % Votmine tagasi paremale
    DeltaX is Suund * -1,
    DeltaY is 1,
    (
        kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2);
        Xtemp is X + DeltaX, Ytemp is Y + DeltaY,
        on_valja_piirides(Xtemp, Ytemp),
        ruut(Xtemp, Ytemp, 0),
        kas_saab_votta_tammiga(Xtemp, Ytemp, Suund, X1, Y1, X2, Y2, suund(DeltaX, DeltaY))
    ).
kas_saab_votta_tammiga(X,Y,Suund,X1,Y1,X2,Y2, suund(DeltaX, -1)):-  % Votmine tagasi vasakule
    DeltaX is Suund * -1,
    DeltaY is -1,
    (
        kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2);
        Xtemp is X + DeltaX, Ytemp is Y + DeltaY,
        on_valja_piirides(Xtemp, Ytemp),
        ruut(Xtemp, Ytemp, 0),
        kas_saab_votta_tammiga(Xtemp, Ytemp, Suund, X1, Y1, X2, Y2, suund(DeltaX, DeltaY))
    ).

on_valja_piirides(X, Y) :-
    X >= 1, Y >= 1, X =< 8, Y =< 8.

kas_saab_votta_yldistus(X, Y, DeltaX, DeltaY, X1, Y1, X2, Y2) :-
    ruut(X, Y, BoardPiece),
    color(BoardPiece, MyColor),
    X1 is X + DeltaX,
    Y1 is Y + DeltaY,
    ruut(X1,Y1, Color),
    Tamm is 10 * MyColor,
    Color =\= MyColor, Color =\= Tamm, Color =\= 0,
    X2 is X1 + DeltaX,
    Y2 is Y1 + DeltaY,
    ruut(X2,Y2, 0).

kaimine(X,Y,Suund,X1,Y1):-
    (
        kas_naaber_vaba(X,Y,Suund,X1,Y1);
        ruut(X, Y, Varv), tamm(Varv),
        Uus_suund = Suund * -1,
        kas_naaber_vaba(X, Y, Uus_suund, X1, Y1)
    ),
    tee_kaik(X,Y,X1,Y1).

kas_naaber_vaba(X,Y,Suund,X1,Y1):-
    X1 is X +Suund,
    Y1 is Y + 1,
    ruut(X1,Y1, 0).
kas_naaber_vaba(X,Y,Suund,X1,Y1):-
    X1 is X +Suund,
    Y1 is Y -1,
    ruut(X1,Y1, 0).

vota(X, Y, _, X1, Y1, X2, Y2) :-
    retract(ruut(X1, Y1, _)),
    assert(ruut(X1, Y1, 0)),
    retract(ruut(X, Y, Status)),
    assert(ruut(X, Y, 0)),
    retract(ruut(X2, Y2, _)),
    assert(ruut(X2, Y2, Status)).

vota(X, Y, X1, Y1, X2, Y2) :-
    retract(ruut(X1, Y1, _)),
    assert(ruut(X1, Y1, 0)),
    retract(ruut(X, Y, Status)),
    assert(ruut(X, Y, 0)),
    retract(ruut(X2, Y2, _)),
    assert(ruut(X2, Y2, Status)).

tee_kaik(X,Y,X1,Y1) :-
    retract(ruut(X, Y, Status)),
    assert(ruut(X, Y, 0)),
    retract(ruut(X1, Y1, _)),
    assert(ruut(X1, Y1, Status)).

kaigu_variandid(Varv, vota_tammiga(X, Y, X1, Y1, X2, Y2)) :-
    retractall(on_voetud(_)),
    leia_suund(Varv, Suund),
    Tamm is Varv * 10, ruut(X, Y, Tamm),
    votmine_tammiga(X, Y, Suund, X1, Y1, X2, Y2),
    assert(on_voetud(true)).
kaigu_variandid(Varv, vota(X, Y, X1, Y1, X2, Y2)) :-
    leia_suund(Varv, Suund),
    ruut(X, Y, Varv),
    kas_saab_votta(X, Y, Suund, X1, Y1, X2, Y2),
    retract(on_voetud(_)),
    assert(on_voetud(true)).
kaigu_variandid(Varv, kai(X, Y, X1,Y1)) :-
    \+ on_voetud(true),
    leia_suund(Varv, Suund),
    ruut(X, Y, Varv),
    kas_naaber_vaba(X,Y,Suund,X1,Y1).

main(Color, Parim, V) :-
    vastane(Color, Vastane),
    retractall(minPlayer(_)),
    retractall(maxPlayer(_)),
    assert(minPlayer(Vastane)),
    assert(maxPlayer(Color)),
    Depth = 4,
    minimax(Color, Depth, Parim, V),
    tee_kaik(Parim).

minimax(Color, 0, Kaik, Val) :-
    vaartus(Color, Val), !.
minimax(Color, Depth, Parim, ParimVal) :-
    findall(Kaik, kaigu_variandid(Color, Kaik), Kaigud),
    parim(Kaigud, Depth, Color, Parim, ParimVal).

parim([Kaik], Depth, Color, Kaik, ParimVal) :-
    tee_kaik(Kaik),
    UusDepth is Depth - 1,
    vastane(Color, UusColor),
    minimax(UusColor, UusDepth, _, ParimVal),
    vota_tagasi(Kaik).
parim([Kaik|Kaigud], Depth, Color, Parim, ParimVal) :-
    parim(Kaigud, Depth, Color, AltTee, AltVaartus),    
    tee_kaik(Kaik),
    UusDepth is Depth - 1,
    vastane(Color, UusColor),
    minimax(UusColor, UusDepth, Tee, Vaartus),
    vota_tagasi(Kaik),
    parem(Color, Tee, Vaartus, AltTee, AltVaartus, Parim, ParimVal).

vastane(1, 2).
vastane(2, 1).

vaartus(_, _) :-
    retractall(vaartus(_)), assert(vaartus(0)), fail.
vaartus(Color, _) :-
    ruut(_, _, C),
    C \= 0,
    retract(vaartus(V)),
    (
        C = Color, NewV is V + 1, assert(vaartus(NewV));
        Tamm is Color * 10, C = Tamm, NewV is V + 2, assert(vaartus(NewV));
        vastane(Color, Vastane), VTamm is Vastane * 10, C = VTamm, NewV is V - 2, assert(vaartus(NewV));
        vastane(Color, Vastane), C = Vastane, NewV is V - 1, assert(vaartus(NewV))
        ),
    fail.
vaartus(_, Vaartus) :-
    retract(vaartus(Vaartus)).

parem(Color, Xt, Xv, _, Yv, Xt, Xv) :-
    minPlayer(Color),
    Xv > Yv, !.
parem(Color, Xt, Xv, _, Yv, Xt, Xv) :-
    maxPlayer(Color),
    Xv < Yv, !.
parem(_, _, _, Yt, Yv, Yt, Yv).

tee_kaik(kai(X, Y, X1, Y1)) :-
    tee_kaik(X, Y, X1, Y1), !.
tee_kaik(vota(X, Y, X1, Y1, X2, Y2)) :-
    vota(X, Y, X1, Y1, X2, Y2).
tee_kaik(vota_tammiga(X, Y, X1, Y1, X2, Y2)) :-
    vota(X, Y, X1, Y1, X2, Y2).

vota_tagasi(kai(X, Y, X1, Y1)) :-
    tee_kaik(X1, Y1, X, Y), !.
vota_tagasi(vota(X, Y, X1, Y1, X2, Y2)) :-
    retract(ruut(X, Y, _)),
    retract(ruut(X2, Y2, C)),
    retract(ruut(X1, Y1, _)),
    assert(ruut(X, Y, C)),
    assert(ruut(X2, Y2, 0)),
    color(C, Cc),
    vastane(Cc, V),
    assert(ruut(X1, Y1, V)).
vota_tagasi(vota_tammiga(X, Y, X1, Y1, X2, Y2)) :-
    vota_tagasi(vota(X, Y, X1, Y1, X2, Y2)).

:- dynamic ruut/3.
ruut(1,1,1).
ruut(1,3,1).
ruut(1,5,1).
ruut(1,7,1).
ruut(2,2,1).
ruut(2,4,1).
ruut(2,6,1).
ruut(2,8,1).
ruut(3,1,1).
ruut(3,3,1).
ruut(3,5,1).
ruut(3,7,1).
% Tühjad ruudud
ruut(4,2,0).
ruut(4,4,0).
ruut(4,6,0).
ruut(4,8,0).
ruut(5,1,0).
ruut(5,3,0).
ruut(5,5,0).
ruut(5,7,0).
% Mustad
ruut(6,2,2).
ruut(6,4,2).
ruut(6,6,2).
ruut(6,8,2).
ruut(7,1,2).
ruut(7,3,2).
ruut(7,5,2).
ruut(7,7,2).
ruut(8,2,2).
ruut(8,4,2).
ruut(8,6,2).
ruut(8,8,2).

%=================== Print checkers board v2 - Start ==================
status_sq(ROW,COL):-
	(	ruut(ROW,COL,COLOR),
        write(COLOR), (Tamm is COLOR mod 10, COLOR =\= 0, Tamm = 0; write(' '))
	);(
		write('  ')
	).
status_row(ROW):-
	write('row # '),write(ROW), write('   '),
	status_sq(ROW,1),
	status_sq(ROW,2),
	status_sq(ROW,3),
	status_sq(ROW,4),
	status_sq(ROW,5),
	status_sq(ROW,6),
	status_sq(ROW,7),
	status_sq(ROW,8),
	nl.
% print the entire checkers board..
status:-
	nl,
	status_row(8),
	status_row(7),
	status_row(6),
	status_row(5),
	status_row(4),
	status_row(3),
	status_row(2),
	status_row(1), !.

%=================== Print checkers board v2 - End ====================

