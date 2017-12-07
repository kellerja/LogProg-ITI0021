:- dynamic ruut/3.

:- dynamic turn/1.
get_turn(Turn) :- retract(turn(X)), (X = 1, Turn = 2, assert(turn(Turn)) ; X = 2, Turn = 1, assert(turn(Turn))), !.
get_turn(1) :- assert(turn(1)).

game_loop() :-
    repeat,
    get_turn(Turn),
    main(Turn),
    status.

main(MyColor):-
    Tamm is MyColor * 10,
    ruut(X,Y, Tamm),
    leia_suund(MyColor,Suund),
    votmine_tammega(X, Y, Suund, X1, Y1, MyColor),
    nl, write([MyColor, 'Nupp ', ruudul, X,Y, ' vottis ja on nyyd ', X1, Y1]), 
    !.
main(MyColor):-
    ruut(X,Y, MyColor),
    leia_suund(MyColor,Suund),
    votmine(X, Y, Suund, X1, Y1, MyColor),
    nl, write([MyColor, 'Nupp ', ruudul, X,Y, ' vottis ja on nyyd ', X1, Y1]), !,
    (muuda_tammiks(X1, Y1, MyColor), nl, write(['Nyyd tamm']); true),   
    !.
main(MyColor) :-
    (ruut(X, Y, MyColor); Tamm is MyColor * 10, ruut(X, Y, Tamm)),
    leia_suund(MyColor, Suund),
    kaimine(X, Y, Suund, X1, Y1),
    nl, write([MyColor, 'Nupp', ruudul, X, Y, ' kais ruudule ', X1, Y1]), !,
    (muuda_tammiks(X1, Y1, MyColor), nl, write(['Nyyd tamm']); true),
    !.
main(_).

leia_suund(1,1):- !.
leia_suund(2,-1).

muuda_tammiks(X, Y, MyColor) :-
    kas_muutub_tammiks(X, Y, MyColor),
    retract(ruut(X, Y, _)),
    Tamm is MyColor * 10,
    assert(ruut(X, Y, Tamm)).

kas_muutub_tammiks(8, _, 1).
kas_muutub_tammiks(1, _, 2).

%--------------------------------
kaigu_variandid(X, Y, Suund, X1, Y1, MyColor) :-
    ruut(X, Y, Color),
    Color mod 10 = 0,
    votmine_tammega(X, Y, Suund, X1, Y1, MyColor), !.
kaigu_variandid(X,Y,Suund,X1,Y1, MyColor):-
    votmine(X,Y,Suund,X1,Y1, MyColor),!.
kaigu_variandid(X,Y,Suund,X1,Y1, _):-
    kaimine(X,Y,Suund,X1,Y1),!.
%--------------------------------
:- dynamic on_votnud/2.
votmine(X,Y,Suund,X3,Y3, MyColor):-
    kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2, MyColor),
    vota(X,Y,Suund,X1,Y1,X2,Y2), 
    retractall(on_votnud(_, _)),
    assert(on_votnud(X2, Y2)), 
    votmine(X2, Y2, Suund, X3, Y3, MyColor).
votmine(X, Y, Suund, X2, Y2, MyColor) :-
    on_votnud(X2, Y2),
    retract(on_votnud(_, _)).

votmine_tammega(X, Y, Suund, X4, Y4, MyColor):-
    kas_saab_votta_tammega(X, Y, Suund, X1, Y1, X2, Y2, Kaimise_suund, MyColor),
    parim_maandumiskoht(X2, Y2, Kaimise_suund, X3, Y3, MyColor),
    vota(X, Y, Suund, X1, Y1, X3, Y3),
    retractall(on_votnud(_, _)),
    assert(on_votnud(X3, Y3)),
    votmine_tammega(X3, Y3, Suund, X4, Y4, MyColor).
votmine_tammega(_, _, _, X2, Y2, _):-
    on_votnud(X2, Y2),
    retract(on_votnud(_, _)).
%--------
kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2, MyColor):-  % Votmine edasi paremale
    DeltaX is Suund,
    DeltaY is 1,
    kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2, MyColor).
kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2, MyColor):-  % Votmine edasi vasakule
    DeltaX is Suund,
    DeltaY is - 1,
    kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2, MyColor).
kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2, MyColor):-  % Votmine tagasi paremale
    DeltaX is Suund * -1,
    DeltaY is 1,
    kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2, MyColor).
kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2, MyColor):-  % Votmine tagasi vasakule
    DeltaX is Suund * -1,
    DeltaY is -1,
    kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2, MyColor).

kas_saab_votta_tammega(X,Y,Suund,X1,Y1,X2,Y2, suund(Suund, 1), MyColor):-  % Votmine edasi paremale
    DeltaX is Suund,
    DeltaY is 1,
    (
        kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2, MyColor);
        Xtemp is X + DeltaX, Ytemp is Y + DeltaY,
        on_valja_piirides(Xtemp, Ytemp),
        ruut(Xtemp, Ytemp, 0),
        kas_saab_votta_tammega(Xtemp, Ytemp, Suund, X1, Y1, X2, Y2, suund(DeltaX, DeltaY), MyColor)
    ).
kas_saab_votta_tammega(X,Y,Suund,X1,Y1,X2,Y2, suund(Suund, -1), MyColor):-  % Votmine edasi vasakule
    DeltaX is Suund,
    DeltaY is - 1,
    (
        kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2, MyColor);
        Xtemp is X + DeltaX, Ytemp is Y + DeltaY,
        on_valja_piirides(Xtemp, Ytemp),
        ruut(Xtemp, Ytemp, 0),
        kas_saab_votta_tammega(Xtemp, Ytemp, Suund, X1, Y1, X2, Y2, suund(DeltaX, DeltaY), MyColor)
    ).
kas_saab_votta_tammega(X,Y,Suund,X1,Y1,X2,Y2, suund(DeltaX, 1), MyColor):-  % Votmine tagasi paremale
    DeltaX is Suund * -1,
    DeltaY is 1,
    (
        kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2, MyColor);
        Xtemp is X + DeltaX, Ytemp is Y + DeltaY,
        on_valja_piirides(Xtemp, Ytemp),
        ruut(Xtemp, Ytemp, 0),
        kas_saab_votta_tammega(Xtemp, Ytemp, Suund, X1, Y1, X2, Y2, suund(DeltaX, DeltaY), MyColor)
    ).
kas_saab_votta_tammega(X,Y,Suund,X1,Y1,X2,Y2, suund(DeltaX, -1), MyColor):-  % Votmine tagasi vasakule
    DeltaX is Suund * -1,
    DeltaY is -1,
    (
        kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2, MyColor);
        Xtemp is X + DeltaX, Ytemp is Y + DeltaY,
        on_valja_piirides(Xtemp, Ytemp),
        ruut(Xtemp, Ytemp, 0),
        kas_saab_votta_tammega(Xtemp, Ytemp, Suund, X1, Y1, X2, Y2, suund(DeltaX, DeltaY), MyColor)
    ).

on_valja_piirides(X, Y) :-
    X >= 1, Y >= 1, X =< 8, Y =< 8.

kas_saab_votta_yldistus(X,Y, DeltaX, DeltaY,X1,Y1,X2,Y2, MyColor) :-
    X1 is X + DeltaX,
    Y1 is Y + DeltaY,
    ruut(X1,Y1, Color),
    Tamm is 10 * MyColor,
    Color =\= MyColor, Color =\= Tamm, Color =\= 0,
    X2 is X1 + DeltaX,
    Y2 is Y1 + DeltaY,
    ruut(X2,Y2, 0).
%--------------------------------
parim_maandumiskoht(X2, Y2, Kaimise_suund, X2, Y2, MyColor).
%--------------------------------
kaimine(X,Y,Suund,X1,Y1):-
    (
        kas_naaber_vaba(X,Y,Suund,X1,Y1);
        ruut(X, Y, Varv), V is Varv mod 10, V = 0,
        Uus_suund = Suund * -1,
        kas_naaber_vaba(X, Y, Uus_suund, X1, Y1)
    ),
    tee_kaik(X,Y,X1,Y1),
    write([' kaib ', X1,Y1]).

kas_naaber_vaba(X,Y,Suund,X1,Y1):-
    X1 is X +Suund,
    Y1 is Y + 1,
    ruut(X1,Y1, 0).
kas_naaber_vaba(X,Y,Suund,X1,Y1):-
    X1 is X +Suund,
    Y1 is Y -1,
    ruut(X1,Y1, 0).

%---------MÄNGU ALGSEIS-------------
% Valged
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

/*
ruut(X,Y, Status).  %   kus X, Y [1,8]      
Status = 0      % tühi
Status = 1      % valge
Status = 2      %  must
*/

%--------------------------
vota(X, Y, _, X1, Y1, X2, Y2) :-
    retract(ruut(X1, Y1, _)),
    assert(ruut(X1, Y1, 0)),
    retract(ruut(X, Y, Status)),
    assert(ruut(X, Y, 0)),
    retract(ruut(X2, Y2, _)),
    assert(ruut(X2, Y2, Status)).

%--------------------------
tee_kaik(X,Y,X1,Y1) :-
    retract(ruut(X, Y, Status)),
    assert(ruut(X, Y, 0)),
    retract(ruut(X1, Y1, _)),
    assert(ruut(X1, Y1, Status)).

%=================== Print checkers board - Start ==================
print_board :-
	print_squares(8).

print_squares(Row) :-
	between(1, 8, Row),
	write('|'), print_row_squares(Row, 1), write('|'), nl,
	NewRow is Row - 1,
	print_squares(NewRow), !.
print_squares(_) :- !.


print_row_squares(Row, Col) :-
	between(1, 8, Col),
	ruut(Col, Row, Status), write(' '), write(Status), write(' '),
	NewCol is Col + 1,
	print_row_squares(Row, NewCol), !.
print_row_squares(_, _) :- !.

%=================== Print checkers board - End ====================

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

