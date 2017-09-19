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
