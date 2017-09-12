female(anne).
female(evelin).
female(mari).
male(priit).
male(vello).
male(tiit).
male(kalle).
married(anne,vello).
mother(evelin,anne).
mother(mari, anne).
married(mari, kalle).
married(evelin, tiit).
mother(priit, evelin).

father(Child, Father) :- 
    mother(Child, Mother) , married(Mother, Father).
brother(Person, Brother) :- 
    mother(Person, Mother) , mother(Brother, Mother) , Person \= Brother , male(Brother).
sister(Person, Sister) :- 
    mother(Person, Mother) , mother(Sister, Mother) , Person \= Sister , female(Sister).
aunt(Person, Aunt) :- 
    mother(Person, Mother) , sister(Mother, Aunt).
uncle(Person, Uncle) :- 
    aunt(Person, Aunt) , married(Aunt, Uncle).
grandfather(Person, Grandfather) :- 
    grandmother(Person, Grandmother) , married(Grandmother, Grandfather).
grandmother(Person, Grandmother) :- 
    mother(Person, Mother) , mother(Mother, Grandmother).
