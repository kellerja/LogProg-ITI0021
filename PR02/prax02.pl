married(anne,vello).
mother(evelin,anne).
female(anne).
female(evelin).
male(vello).

father(Child, Father) :- mother(Child, Mother) , married(Mother, Father).
brother(Person, Brother) :- male(Person) , mother(Person, Mother) , mother(Brother, Mother).
sister(Person, Sister) :- female(Person) , mother(Person, Mother) , mother(Sister, Mother).
aunt(Person, Aunt) :- female(Aunt) , grandmother(Aunt, Grandmother) , mother(Person, Mother) , grandmother(Mother, Grandmother).
uncle(Person, Uncle) :- male(Uncle) , grandmother(Uncle, Grandmother) , mother(Person, Mother) , grandmother(Mother, Grandmother).
grandfather(Person, Grandfather) :- mother(Person, Mother) , mother(Mother, Grandmother) , married(Grandmother, Grandfather).
grandmother(Person, Grandmother) :- mother(Person, Mother) , mother(Mother, Grandmother).
