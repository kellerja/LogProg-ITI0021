:- module(iapb155243, [iapb155243/3]).
% Alfa-beta algoritmi loomisel on aluseks: http://colin.barker.pagesperso-orange.fr/lpa/tictac.htm

iapb155243(Color, 0, 0) :-
    enemy(Color, Enemy),
    retractall(min_player(_)),
    retractall(max_player(_)),
    assert(min_player(Enemy)),
    assert(max_player(Color)),
    Depth = 6,
    alfabeta(Color, Depth, -999999, 999999, Best_move, _),
    (Best_move = capture([H|_]), make_move(H, _, _); make_move(Best_move, _, _)),
    !.
iapb155243(Color, X, Y) :-
    ruut(X, Y, Piece),
    tamm(Piece),
    direction(Color, Direction),
    can_capture_with_king(X, Y, Direction, X_enemy, Y_enemy, X_newA, Y_newA, Diagonal, Color),
    best_landing(X_newA, Y_newA, Diagonal, X_new, Y_new),
    make_move(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), _, _), 
    !.
iapb155243(Color, X, Y) :-
    direction(Color, Direction),
    can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, Color),
    make_move(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), _, _).
iapb155243(_, _, _).

enemy(1, 2) :- !.
enemy(2, 1).

direction(1, 1) :- !.
direction(2, -1).

color(1, 1) :- !.
color(10, 1) :- !.
color(2, 2) :- !.
color(20, 2) :- !.
color(0, 0).

tamm(10) :- !.
tamm(20).

tamm(1, 10) :- !.
tamm(10, 10) :- !.
tamm(2, 20) :- !.
tamm(20, 20).

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
            \+ tamm(PieceColor), New_value is Value + 1
        );
        enemy(Color, PieceColor),
        (
            tamm(PieceColor), New_value is Value - 10;
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
    \+ can_capture(X, Y, Direction, _, _, _, _, Color).
possible_moves_capture(Color, origin(X, Y), [capture(X, Y, X_enemy, Y_enemy, X_new, Y_new)|Captures]) :-
    direction(Color, Direction),
    can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, Color),
    make_move(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), Enemy_piece, Piece),
    (
        ruut(X_new, Y_new, C), tamm(C), possible_moves_capture_with_king(Color, origin(X_new, Y_new), Captures);
        possible_moves_capture(Color, origin(X_new, Y_new), Captures)
    ),
    backtrack(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), Enemy_piece, Piece), !.

possible_moves_capture_with_king(Color, origin(X, Y), []) :-
    direction(Color, Direction),
    \+ can_capture_with_king(X, Y, Direction, _, _, _, _, _, Color).
possible_moves_capture_with_king(Color, origin(X, Y), [capture(X, Y, X_enemy, Y_enemy, X_new, Y_new)|Captures]) :-
    direction(Color, Direction),
    can_capture_with_king(X, Y, Direction, X_enemy, Y_enemy, X_newA, Y_newA, Diagonal, Color),
    best_landing(X_newA, Y_newA, Diagonal, X_new, Y_new),
    make_move(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), Enemy_memory, Memory),
    possible_moves_capture_with_king(Color, origin(X_new, Y_new), Captures),
    backtrack(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), Enemy_memory, Memory), !.

possible_moves(Color, capture(CaptureMove)) :-
    retractall(has_captured(_)),
    ruut(X, Y, Color),
    possible_moves_capture(Color, origin(X, Y), CaptureMove),
    CaptureMove \= [],
    assert(has_captured(true)).
possible_moves(Color, capture(CaptureMove)) :-
    tamm(Color, King),
    ruut(X, Y, King),
    possible_moves_capture_with_king(Color, origin(X, Y), CaptureMove),
    CaptureMove \= [],
    retractall(has_captured(_)),
    assert(has_captured(true)).
possible_moves(Color, move(X, Y, X_new, Y_new)) :-
    \+ has_captured(true),
    ruut(X, Y, Color),
    direction(Color, Direction),
    can_move(X, Y, Direction, X_new, Y_new).
possible_moves(Color, move(X, Y, X_new, Y_new)) :-
    \+ retract(has_captured(true)),
    tamm(Color, King),
    ruut(X, Y, King),
    best_move_with_king(X, Y, X_new, Y_new, Color).

alfabeta(Color, 0, _, _, _, Value) :-
    heuristics(Color, Value), !.
alfabeta(Color, Depth, Alpha, Beta, Best_move, Best_value) :-
    findall(Move, possible_moves(Color, Move), Moves),
    (
        Moves = [], Best_value = -9999;
        New_depth is Depth - 1,
        Alpha1 is -Beta,
        Beta1 is -Alpha,
        best(Moves, New_depth, Color, Alpha1, Beta1, 0, Best_move, Best_value)
    ), !.
alfabeta(Color, _, _, _, _, Value) :-
    heuristics(Color, Value).

best([Move|Moves], Depth, Color, Alpha, Beta, Move0, Best_move, Best_value) :-
    make_move(Move, Enemy_memory, Memory),
    enemy(Color, Enemy),
    alfabeta(Enemy, Depth, Alpha, Beta, _, Enemy_value),
    Value is -Enemy_value,
    backtrack(Move, Enemy_memory, Memory),
    cutoff(Move, Moves, Depth, Color, Value, Alpha, Beta, Move0, Best_move, Best_value).
best([], _, _, Alpha, _, Move, Move, Alpha).

cutoff(_, Moves, Depth, Color, Value, Alpha, Beta, Move0, MoveA, ValueA) :-
    Value =< Alpha, !,
    best(Moves, Depth, Color, Alpha, Beta, Move0, MoveA, ValueA).
cutoff(Move, Moves, Depth, Color, Value, _, Beta, _, MoveA, ValueA) :-
    Value < Beta, !,
    best(Moves, Depth, Color, Value, Beta, Move, MoveA, ValueA).
cutoff(Move, _, _, _, Value, _, _, _, Move, Value).

make_move(capture([]), [], []) :- !.
make_move(capture([H|T]), [Enemy_piece|Enemies], [Piece|Pieces]) :-
    make_move(H, Enemy_piece, Piece),
    make_move(capture(T), Enemies, Pieces), !.
make_move(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), Enemy_piece, Piece) :-
    retract(ruut(X_enemy, Y_enemy, Enemy_piece)),
    assert(ruut(X_enemy, Y_enemy, 0)),
    retract(ruut(X, Y, Piece)),
    assert(ruut(X, Y, 0)),
    retract(ruut(X_new, Y_new, _)),
    assert(ruut(X_new, Y_new, Piece)),
    make_king(X_new, Y_new), !.
make_move(move(X, Y, X_new, Y_new), _, Piece) :-
    retract(ruut(X, Y, Piece)),
    assert(ruut(X, Y, 0)),
    retract(ruut(X_new, Y_new, _)),
    assert(ruut(X_new, Y_new, Piece)),
    make_king(X_new, Y_new).

make_king(X, Y) :-
    ruut(X, Y, Piece), 
    can_make_king(X, Y, Piece),
    King is Piece * 10,
    retract(ruut(X, Y, Piece)),
    assert(ruut(X, Y, King)).
make_king(_, _).

can_make_king(8, _, 1) :- !.
can_make_king(1, _, 2).

backtrack_capture([], [], []) :- !.
backtrack_capture([Move|Moves], [Enemy_piece|Enemies], [Piece|Pieces]) :-
    backtrack(Move, Enemy_piece, Piece),
    backtrack_capture(Moves, Enemies, Pieces), !.
backtrack(capture(Moves), Memory, Pieces) :-
    reverse(Moves, RevMoves),
    reverse(Memory, RevMemory),
    reverse(Pieces, RevPieces),
    backtrack_capture(RevMoves, RevMemory, RevPieces), !.
backtrack(capture(X, Y, X_enemy, Y_enemy, X_new, Y_new), Enemy_piece, Piece) :-
    retract(ruut(X_enemy, Y_enemy, _)),
    assert(ruut(X_enemy, Y_enemy, Enemy_piece)),
    retract(ruut(X_new, Y_new, _)),
    assert(ruut(X_new, Y_new, 0)),
    retract(ruut(X, Y, _)),
    assert(ruut(X, Y, Piece)), !.
backtrack(move(X, Y, X_new, Y_new), _, Piece) :-
    retract(ruut(X_new, Y_new, _)),
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

best_move_with_king(X, Y, X_new, Y_new, _) :-
    X_new is X + 1,
    Y_new is Y + 1,
    ruut(X_new, Y_new, 0).
best_move_with_king(X, Y, X_new, Y_new, _) :-
    X_new is X + 1,
    Y_new is Y - 1,
    ruut(X_new, Y_new, 0).
best_move_with_king(X, Y, X_new, Y_new, _) :-
    X_new is X - 1,
    Y_new is Y + 1,
    ruut(X_new, Y_new, 0).
best_move_with_king(X, Y, X_new, Y_new, _) :-
    X_new is X - 1,
    Y_new is Y - 1,
    ruut(X_new, Y_new, 0).

can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, Color) :-
    Delta_x is Direction,
    Delta_y is 1,
    can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new, Color).
can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, Color) :-
    Delta_x is Direction,
    Delta_y is -1,
    can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new, Color).
can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, Color) :-
    Delta_x is Direction * -1,
    Delta_y is 1,
    can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new, Color).
can_capture(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, Color) :-
    Delta_x is Direction * -1,
    Delta_y is -1,
    can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new, Color).

can_capture_with_king(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Direction, 1), Color) :-
    Delta_x is Direction,
    Delta_y is 1,
    (
        can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new, Color);
        X_move is X + Delta_x,
        Y_move is Y + Delta_y,
        in_gameboard_bounds(X_move, Y_move),
        ruut(X_move, Y_move, 0),
        can_capture_with_king(X_move, Y_move, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Delta_x, Delta_y), Color)
    ).
can_capture_with_king(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Direction, -1), Color) :-
    Delta_x is Direction,
    Delta_y is -1,
    (
        can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new, Color);
        X_move is X + Delta_x,
        Y_move is Y + Delta_y,
        in_gameboard_bounds(X_move, Y_move),
        ruut(X_move, Y_move, 0),
        can_capture_with_king(X_move, Y_move, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Delta_x, Delta_y), Color)
    ).
can_capture_with_king(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Delta_x, 1), Color) :-
    Delta_x is Direction * -1,
    Delta_y is 1,
    (
        can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new, Color);
        X_move is X + Delta_x,
        Y_move is Y + Delta_y,
        in_gameboard_bounds(X_move, Y_move),
        ruut(X_move, Y_move, 0),
        can_capture_with_king(X_move, Y_move, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Delta_x, Delta_y), Color)
    ).
can_capture_with_king(X, Y, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Delta_x, -1), Color) :-
    Delta_x is Direction * -1,
    Delta_y is -1,
    (
        can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new, Color);
        X_move is X + Delta_x,
        Y_move is Y + Delta_y,
        in_gameboard_bounds(X_move, Y_move),
        ruut(X_move, Y_move, 0),
        can_capture_with_king(X_move, Y_move, Direction, X_enemy, Y_enemy, X_new, Y_new, direction(Delta_x, Delta_y), Color)
    ).
    
can_capture_general(X, Y, Delta_x, Delta_y, X_enemy, Y_enemy, X_new, Y_new, Color) :-
    X_enemy is X + Delta_x,
    Y_enemy is Y + Delta_y,
    ruut(X_enemy, Y_enemy, Enemy_piece),
    color(Enemy_piece, Enemy_color),
    Color \= Enemy_color, Enemy_color \= 0,
    X_new is X_enemy + Delta_x,
    Y_new is Y_enemy + Delta_y,
    ruut(X_new, Y_new, 0).

best_landing(X_newA, Y_newA, _, X_newA, Y_newA).
