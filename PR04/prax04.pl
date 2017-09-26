female(anne).
female(kai).
female(mari).
female(liis).
female(tiina).
male(priit).
male(vello).
male(tiit).
male(kalle).
male(siim).
male(toots).
married(tiina, toots).
mother(siim, tiina).
married(liis, siim).
mother(anne, liis).
married(anne,vello).
mother(kai,anne).
mother(mari, anne).
married(mari, kalle).
married(kai, tiit).
mother(priit, kai).

father(Child, Father) :- 
    mother(Child, Mother) , married(Mother, Father).
brother(Person, Brother) :- 
    mother(Person, Mother) , mother(Brother, Mother) , Person \= Brother , male(Brother).
sister(Person, Sister) :- 
    mother(Person, Mother) , mother(Sister, Mother) , Person \= Sister , female(Sister).
aunt(Person, Aunt) :- % mother's side
    mother(Person, Mother) , sister(Mother, Aunt).
aunt(Person, Aunt) :- % father's sides
    mother(Person, Mother), married(Mother, Father), sister(Father, Aunt).
uncle(Person, Uncle) :- % mother's side
    mother(Person, Mother) , brother(Mother, Uncle).
uncle(Person, Uncle) :- % father's side
    mother(Person, Mother) , married(Mother, Father) , brother(Father, Uncle).
grandfather(Person, Grandfather) :- 
    grandmother(Person, Grandmother) , married(Grandmother, Grandfather).
grandmother(Person, Grandmother) :- % mother's side
    mother(Person, Mother) , mother(Mother, Grandmother).
grandmother(Person, Grandmother) :- % father's side
    mother(Person, Mother) , married(Mother, Father) , mother(Father, Grandmother).

male_ancestor(Child, Parent) :- 
    father(Child, Parent).
male_ancestor(Child, Parent) :- 
    father(Child, Father), 
    male_ancestor(Father, Parent).
male_ancestor(Child, Parent) :-
    mother(Child, Mother),
    male_ancestor(Mother, Parent).

female_ancestor(Child, Parent) :- 
    mother(Child, Parent).
female_ancestor(Child, Parent) :- 
    mother(Child, Mother),
    female_ancestor(Mother, Parent).
female_ancestor(Child, Parent) :-
    father(Child, Father),
    female_ancestor(Father, Parent).

ancestor(Child, Parent, 1) :- 
    mother(Child, Parent) ; father(Child, Parent).
ancestor(Child, Parent, N) :- 
    mother(Child, Mother) ,
    Z is N - 1,
    ancestor(Mother, Parent, Z).
ancestor(Child, Parent, N) :-
    father(Child, Father),
    Z is N - 1,
    ancestor(Father, Parent, Z).

ancestor2(Child, Parent, X) :- 
    female_ancestor(Child, Parent),
    findall(C, mother(C, Parent), List),
    length(List, N),
    N > X.
ancestor2(Child, Parent, X) :- 
    male_ancestor(Child, Parent),
    married(Wife, Parent),
    findall(C, mother(C, Wife), List),
    length(List, N),
    N > X.

 % ------ Klass-alamklass seos ------
is_a('Juhid', 'Ametid').
  is_a('Seadusandjad, kõrgemad ametnikud ja juhid', 'Juhid').
    is_a('Seadusandjad', 'Seadusandjad, kõrgemad ametnikud ja juhid').
    is_a('Suurettevõtete tegevdirektorid ja -juhatajad', 'Seadusandjad, kõrgemad ametnikud ja juhid').
  is_a('Juhid äri- ja haldusalal', 'Juhid').
    is_a('Juhid finantsalal', 'Juhid äri- ja haldusalal').
    is_a('Juhid strateegilise planeerimise alal', 'Juhid äri- ja haldusalal').
    is_a('Juhid reklaami ja suhtekorralduse alal', 'Juhid äri- ja haldusalal').


is_a('Ametnikud', 'Ametid').
  is_a('Lihtametnikud ja arvutiametnikud', 'Ametnikud').
    is_a('Kontoriametnikud', 'Lihtametnikud ja arvutiametnikud').
    is_a('Andmesisestajad', 'Lihtametnikud ja arvutiametnikud').
  is_a('Arve- ja laoametnikud', 'Ametnikud').
    is_a('Arve- ja raamatupidamisametnikud', 'Arve- ja laoametnikud').
    is_a('Laoametnikud', 'Arve- ja laoametnikud').
    is_a('Transpordiametnikud', 'Arve- ja laoametnikud').


is_a(anne, 'Seadusandjad').
is_a(kai, 'Suurettevõtete tegevdirektorid ja -juhatajad').
is_a(mari, 'Juhid finantsalal').
is_a(liis, 'Juhid strateegilise planeerimise alal').
is_a(tiina, 'Juhid reklaami ja suhtekorralduse alal').
is_a(priit, 'Kontoriametnikud').
is_a(vello, 'Andmesisestajad').
is_a(tiit, 'Arve- ja raamatupidamisametnikud').
is_a(kalle, 'Laoametnikud').
is_a(siim, 'Transpordiametnikud').
is_a(toots, 'Juhid finantsalal').

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
  alamhulk(Who, O).
