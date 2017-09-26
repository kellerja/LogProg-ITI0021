alamklass(Kes, Kelle):-
	is_a(Kes,Kelle), !.
alamklass(Kes, Kelle):-
	is_a(Kes,Vahepealne),
	alamklass(Vahepealne,Kelle).

alamhulk(X,Y):-  is_a(X,Y).
alamhulk(X,Y):-  is_a(W,Y), alamhulk(X,W).

occupation(Who, Relative, O) :- 
  call(Relative, Who, R),
  alamklass(R, O).

who_is(O, Who) :-
  alamhulk(O, Who).
