iapb155243(Color, X, Y):-
    enemy(Color, Enemy),
    retractall(min_player(_)),
    retractall(max_player(_)),
    assert(min_player(Enemy)),
    assert(max_player(Color)),
    Depth = 5,
    minimax(Color, Depth, Best_move, Value),
    write([Best_move, Value]), nl,
    make_move(Best_move, _), !.
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

possible_moves(Color, capture(X, Y, X_enemy, Y_enemy, X_new, Y_new)) :-
    ruut(X, Y, Color),
    direction(Color, Direction),
    can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new), !.
possible_moves(Color, move(X, Y, X_new, Y_new)) :-
    ruut(X, Y, Color),
    direction(Color, Direction),
    can_move(X, Y, Direction, X_new, Y_new).

minimax(Color, 0, Alpha, Beta, _, Value) :-
    heuristics(Color, Value), !.
minimax(Color, Depth, Alpha, Beta, Best_move, Best_value) :-
    findall(Move, possible_moves(Color, Move), Moves),
    best(Moves, Depth, Color, Best_move, Best_value), !.
minimax(Color, _, _, Value) :-
    heuristics(Color, Value).

best([Move], Depth, Color, Move, Best_value) :-
    make_move(Move, Memory),
    New_depth is Depth - 1,
    enemy(Color, Enemy),
    minimax(Enemy, New_depth, _, Best_value),
    backtrack(Move, Memory).
best([Move|Moves], Depth, Color, Best_move, Best_value) :-
    best(Moves, Depth, Color, MoveA, ValueA),
    make_move(Move, Memory),
    New_depth is Depth - 1,
    enemy(Color, Enemy),
    minimax(Enemy, New_depth, Move, ValueB),
    backtrack(Move, Memory),
    better_of(Color, MoveA, ValueA, Move, ValueB, Best_move, Best_value).

better_of(Color, X_move, X_value, _, Y_value, X_move, X_value) :-
    min_player(Color),
    X_value > Y_value, !.
better_of(Color, X_move, X_value, _, Y_value, X_move, X_value) :-
    max_player(Color),
    X_value < Y_value, !.
better_of(_, _, _, Y_move, Y_value, Y_move, Y_value).

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
