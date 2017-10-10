%===================== NÄIDE 1 =====================
%================= Klass-alamklass seos ============
%----------------- Vahetu seos ---------------------
is_a(nelinurk, hulknurk).
is_a(romb, nelinurk).
is_a(ruut, romb).
%---------------- Pärimisseos ----------------------
alamklass(Kes, Kelle):-
	is_a(Kes,Kelle),!.
alamklass(Kes, Kelle):-
	is_a(Kes,Vahepealne),
	alamklass(Vahepealne,Kelle).
%=============== Klasside omadused =================
   hulknurk(koosneb, [nurkadest, külgedest]).

% Rombile iseloomulikud omadused
   romb(kyljed, vordsed).
   romb(nurgad, ebavordsed).

% Ruudule iseloomulikud omadused
   ruut(symmeetriline, 4).
   nelinurk(kylgi,4).

% TESTPÄRING1:	ruut(kyljed, Missugused).
% VASTUS:	Missugused = vordsed

% ============= Pärimisreegel objekti omaduste väärtustamiseks ===================
   ruut(Atribuut, Vaartus):-
	alamklass(ruut,Freim),				% Leiab esivanemklassi nime
	Subgoal =.. [Freim, Atribuut,Vaartus],		% Saab atribuudi päritud väärtuse
	Subgoal.

% TESTPÄRING2:	ruut(koosneb,X).

%=================== END NÄIDE 1 ===================

%====================== NÄIDE 2 ====================
% Omaduste pärimine klasside vahel
%==================================================

 % ------ Klass-alamklass seos ------
  is_a(elusolend, eluvorm).
  is_a(taim, eluvorm).
  is_a(selgroogne, elusolend).
  is_a(lehm,selgroogne).
  is_a(selgrootu, elusolend).
  is_a(oistaim, taim).
  is_a(mitteoistaim, taim).
  is_a(kapsas,oistaim).
  is_a(valgelillkapsas,lillkapsas).
  is_a(lillkapsas,kapsas).
  is_a(maasi,lehm).
  is_a(puuk,selgrootu).
  is_a(kapsauss,selgrootu). 

	is_a(soob,toitub).
	is_a(imeb,soob).
	is_a(narib,soob).
	is_a(nakitseb,narib).
	is_a(malub,soob).

% ----------------- Klasside omadused ---------
   toitub(eluvorm).
   hingab(eluvorm).
   paljuneb(eluvorm).
   kasvab(eluvorm).
   liigub(elusolend).
   soob(selgrootu,taim).
   malub(lehm,taim).
   eats(lehm, taim).
   eats(selgrootu, taim).
   nakitseb(kapsauss,kapsas).

%-----------------------------------------------------------------------------
%		Konkreetsete omaduste pärimise reeglid
%-----------------------------------------------------------------------------
   hingab(M):- alamhulk(M,N), hingab(N).
   liigub(P):- alamhulk(P,Q), liigub(Q).
   toitub(R):- alamhulk(R,S), toitub(S).
   kasvab(V):- alamhulk(V,W), kasvab(W).
   paljuneb(X):- alamhulk(X,Y), paljuneb(Y). 

%------------------ Omaduse tuvastamise üldine reegel --------------------
omadus(Om_nimi, Om_subjekt):-
	alamklass(Om_subjekt,Esivanem),
	Term =.. [Om_nimi,Esivanem],
	Term.