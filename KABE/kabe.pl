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

:- dynamic on_votnud/2.
votmine_tammiga(X, Y, Suund, X3, Y3):-
    kas_saab_votta_tammiga(X, Y, Suund, X1, Y1, X2, Y2, Kaimise_suund),
    parim_maandumiskoht(X2, Y2, Kaimise_suund, X3, Y3),
    vota(X, Y, Suund, X1, Y1, X3, Y3),
    retractall(on_votnud(_, _)),
    assert(on_votnud(X3, Y3)),
    votmine_tammiga(X3, Y3, Suund, X4, Y4).
votmine_tammiga(_, _, _, X2, Y2):-
    on_votnud(X2, Y2),
    retract(on_votnud(_, _)).

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

tee_kaik(X,Y,X1,Y1) :-
    retract(ruut(X, Y, Status)),
    assert(ruut(X, Y, 0)),
    retract(ruut(X1, Y1, _)),
    assert(ruut(X1, Y1, Status)).

kaigu_variandid(Color, Depth, State, kai(X, Y, X1,Y1)) :-
    leia_suund(Color, Suund),
    ruut(X, Y, Color, Depth, State, _, _),
    kas_naaber_vaba(ruut(X, Y, Color, Depth, State, _, _), Suund, X1, Y1).

kopeeri_valja(Depth) :-
    ruut(X, Y, C),
    assert(ruut(X, Y, C, Depth, 0, 0, 0)), 
    fail.
kopeeri_valja(_).

main(Color) :-
    retractall(ruut(_, _, _, _, _, _, _)),
    Depth = 2,
    kopeeri_valja(Depth),
    minimax(Color),

minimax(Color, State) :-

minimax(Pos, 0, _, Val) :-
    utility(Pos, Val).
minimax(AlgPos, Depth, ParimKaik, Val) :-
    bagof(Kaik, kaigu_variandid(AlgPos, Kaik), Kaigud),
    best(Kaigud, Depth, ParimKaik, Val), !.

best([Kaik], Depth, Kaik, Val) :-
    minimax(Kaik, Depth, _, Val), !.
best([Kaik| Kaigud], Depth, ParimKaik, ParimVal) :-
    NewDepth is Depth - 1,
    minimax(Kaik, NewDepth, _, Val),
    best(Kaigud, Depth, AlternatiivneKaik, AlternatiivneVal),
    betterOf(Kaik, Val, AlternatiivneKaik, AlternatiivneVal, ParimKaik, ParimVal).

betterOf(Pos0, Val0, _, Val1, Pos0, Val0) :-
    min_to_move(Pos0),
    Val0 > Val1, !.
betterOf(Pos0, Val0, _, Val1, Pos0, Val0) :-
    max_to_move(Pos0),
    Val0 > Val1, !.
betterOf(_, _, Pos1, Val1, Pos1, Val1).

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
