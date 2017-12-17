% Alfa-beta algoritmi loomisel on aluseks: http://colin.barker.pagesperso-orange.fr/lpa/tictac.htm

iapb155243(Color, 0, 0) :-
    enemy(Color, Enemy),
    retractall(min_player(_)),
    retractall(max_player(_)),
    assert(min_player(Enemy)),
    assert(max_player(Color)),
    Depth = 6,
    alfabeta(Color, Depth, -999999, 999999, Best_move, _),
    (Best_move = capture([H|T]), make_move(H, _); make_move(Best_move, _)),
    !.
iapb155243(Color, X, Y) :-
    direction(Color, Direction),
    can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new),
    make_move(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), _).
iapb155243(_, _, _).

enemy(1, 2) :- !.
enemy(2, 1).

direction(1, 1) :- !.
direction(2, -1).

color(1, 1) :- !.
color(10, 1) :- !.
color(2, 2) :- !.
color(20, 2).

tamm(10) :- !.
tamm(20).

in_gameboard_bounds(X, Y) :-
    X >= 1, Y >= 1, X =< 8, Y =< 8.

heuristics(Color, _) :-
    retractall(heuristics(_)),
    assert(heuristics(0)),
    ruut(_, _, Piece),
    color(Piece, PieceColor),
    retract(heuristics(Value)),
    (
        Color = PieceColor, 
        (
            tamm(PieceColor), New_value is Value + 10;
            \+ tamm(PieceColor), New_value is Value + 2
        );
        enemy(Color, PieceColor),
        (
            tamm(PieceColor), New_value is Value - 5;
            \+ tamm(PieceColor), New_value is Value - 1
        );
        PieceColor = 0, New_value is Value
    ),
    assert(heuristics(New_value)), 
    fail.
heuristics(_, Value) :-
    retract(heuristics(Value)).

possible_moves_capture(Color, origin(X, Y), []) :-
    direction(Color, Direction),
    \+ can_capture(X, Y, Direction, _, _, _, _).
possible_moves_capture(Color, origin(X, Y), [capture(X, Y, X_enemy, Y_enemy, X_new, Y_new)|Captures]) :-
    direction(Color, Direction),
    can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new),
    make_move(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), Enemy_piece),
    possible_moves_capture(Color, origin(X_new, Y_new), Captures),
    backtrack(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), Enemy_piece), !.

possible_moves(Color, capture(CaptureMove)) :-
    retractall(has_captured(_)),
    ruut(X, Y, Color),
    possible_moves_capture(Color, origin(X, Y), CaptureMove),
    CaptureMove \= [],
    assert(has_captured(true)).
possible_moves(Color, move(X, Y, X_new, Y_new)) :-
    \+ retract(has_captured(true)),
    ruut(X, Y, Color),
    direction(Color, Direction),
    can_move(X, Y, Direction, X_new, Y_new).

alfabeta(Color, 0, _, _, _, Value) :-
    heuristics(Color, Value), !.
alfabeta(Color, Depth, Alpha, Beta, Best_move, Best_value) :-
    findall(Move, possible_moves(Color, Move), Moves),
    New_depth is Depth - 1,
    Alpha1 is -Beta,
    Beta1 is -Alpha,
    best(Moves, New_depth, Color, Alpha1, Beta1, 0, Best_move, Best_value), !.
alfabeta(Color, _, _, _, _, Value) :-
    heuristics(Color, Value).

best([Move|Moves], Depth, Color, Alpha, Beta, Move0, Best_move, Best_value) :-
    make_move(Move, Memory),
    enemy(Color, Enemy),
    alfabeta(Enemy, Depth, Alpha, Beta, _, Enemy_value),
    Value is -Enemy_value,
    backtrack(Move, Memory),
    cutoff(Move, Moves, Depth, Color, Value, Alpha, Beta, Move0, Best_move, Best_value).
best([], _, _, Alpha, _, Move, Move, Alpha).

cutoff(_, Moves, Depth, Color, Value, Alpha, Beta, Move0, MoveA, ValueA) :-
    Value =< Alpha, !,
    best(Moves, Depth, Color, Alpha, Beta, Move0, MoveA, ValueA).
cutoff(Move, Moves, Depth, Color, Value, _, Beta, _, MoveA, ValueA) :-
    Value < Beta, !,
    best(Moves, Depth, Color, Value, Beta, Move, MoveA, ValueA).
cutoff(Move, _, _, _, Value, _, _, _, Move, Value).

make_move(capture([]), []) :- !.
make_move(capture([H|T]), [Enemy_piece|Enemies]) :-
    make_move(H, Enemy_piece),
    make_move(capture(T), Enemies), !.
make_move(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), Enemy_piece) :-
    retract(ruut(X_enemy, Y_enemy, Enemy_piece)),
    assert(ruut(X_enemy, Y_enemy, 0)),
    retract(ruut(X, Y, Piece)),
    assert(ruut(X, Y, 0)),
    retract(ruut(X_new, Y_new, _)),
    assert(ruut(X_new, Y_new, Piece)), !.
make_move(move(X, Y, X_new, Y_new), _) :-
    retract(ruut(X, Y, Piece)),
    assert(ruut(X, Y, 0)),
    retract(ruut(X_new, Y_new, _)),
    assert(ruut(X_new, Y_new, Piece)).

backtrack_capture([], []).
backtrack_capture([Move|Moves], [Enemy_piece|Enemies]) :-
    backtrack(Move, Enemy_piece),
    backtrack_capture(Moves, Enemies), !.
backtrack(capture(Moves), Memory) :-
    reverse(Moves, RevMoves),
    reverse(Memory, RevMemory),
    backtrack_capture(RevMoves, RevMemory), !.
backtrack(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), Enemy_piece) :-
    retract(ruut(X_enemy, Y_enemy, _)),
    assert(ruut(X_enemy, Y_enemy, Enemy_piece)),
    retract(ruut(X_new, Y_new, Piece)),
    assert(ruut(X_new, Y_new, 0)),
    retract(ruut(X, Y, _)),
    assert(ruut(X, Y, Piece)), !.
backtrack(move(X, Y, X_new, Y_new), _) :-
    retract(ruut(X_new, Y_new, Piece)),
    assert(ruut(X_new, Y_new, 0)),
    retract(ruut(X, Y, _)),
    assert(ruut(X, Y, Piece)).

can_move(X, Y, Direction, X_new, Y_new) :-
    X_new is X + Direction,
    Y_new is Y + 1,
    ruut(X_new, Y_new, 0).
can_move(X, Y, Direction, X_new, Y_new) :-
    X_new is X + Direction,
    Y_new is Y - 1,
    ruut(X_new, Y_new, 0).

can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new) :-
    Delta_x is Direction,
    Delta_y is 1,
    can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new).
can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new) :-
    Delta_x is Direction,
    Delta_y is -1,
    can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new).
can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new) :-
    Delta_x is Direction * -1,
    Delta_y is 1,
    can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new).
can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new) :-
    Delta_x is Direction * -1,
    Delta_y is -1,
    can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new).

can_capture_with_king(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, diretion(Direction, 1)) :-
    Delta_x is Direction,
    Delta_y is 1,
    (
        can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new);
        X_move is X + Delta_x,
        Y_move is Y + Delta_y,
        in_gameboard_bounds(X_move, Y_move),
        ruut(X_move, Y_move, 0),
        can_capture_with_king(X_move, Y_move, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Delta_x, Delta_y))
    ).
can_capture_with_king(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, diretion(Direction, -1)) :-
    Delta_x is Direction,
    Delta_y is -1,
    (
        can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new);
        X_move is X + Delta_x,
        Y_move is Y + Delta_y,
        in_gameboard_bounds(X_move, Y_move),
        ruut(X_move, Y_move, 0),
        can_capture_with_king(X_move, Y_move, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Delta_x, Delta_y))
    ).
can_capture_with_king(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, diretion(Delta_x, 1)) :-
    Delta_x is Direction * -1,
    Delta_y is 1,
    (
        can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new);
        X_move is X + Delta_x,
        Y_move is Y + Delta_y,
        in_gameboard_bounds(X_move, Y_move),
        ruut(X_move, Y_move, 0),
        can_capture_with_king(X_move, Y_move, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Delta_x, Delta_y))
    ).
can_capture_with_king(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, diretion(Delta_x, -1)) :-
    Delta_x is Direction * -1,
    Delta_y is -1,
    (
        can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new);
        X_move is X + Delta_x,
        Y_move is Y + Delta_y,
        in_gameboard_bounds(X_move, Y_move),
        ruut(X_move, Y_move, 0),
        can_capture_with_king(X_move, Y_move, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Delta_x, Delta_y))
    ).
    
can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new) :-
    ruut(X, Y, Piece),
    color(Piece, Color),
    X_enemy is X + Delta_x,
    Y_enemy is Y + Delta_y,
    ruut(X_enemy, Y_enemy, Enemy_piece),
    color(Enemy_piece, Enemy_color),
    Color \= Enemy_color, Enemy_color \= 0,
    X_new is X_enemy + Delta_x,
    Y_new is Y_enemy + Delta_y,
    ruut(X_new, Y_new, 0).

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

:- dynamic ruut/3.
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
