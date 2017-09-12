female(anne).
female(evelin).
female(mari).
male(priit).
male(vello).
male(tiit).
married(anne,vello).
mother(evelin,anne).
mother(mari, anne).
merried(evelin, tiit).
mother(priit, evelin).

father(Child, Father) :- 
    mother(Child, Mother) , married(Mother, Father).
brother(Person, Brother) :- 
    Person \= Brother , male(Person) , mother(Person, Mother) , mother(Brother, Mother).
sister(Person, Sister) :- 
    Person \= Sister , female(Person) , mother(Person, Mother) , mother(Sister, Mother).
aunt(Person, Aunt) :- 
    female(Aunt) , mother(Aunt, Grandmother) , grandmother(Person, Grandmother).
uncle(Person, Uncle) :- 
    male(Uncle) , married(Uncle, Aunt) , aunt(Person, Aunt).
grandfather(Person, Grandfather) :- 
    grandmother(Person, Grandmother) , married(Grandmother, Grandfather).
grandmother(Person, Grandmother) :- 
    mother(Person, Mother) , mother(Mother, Grandmother).
