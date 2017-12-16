%:- module(arbiter,[turniir/0, ruut/3]).
%:- module(arbiter,[t/0, ruut/3]).
:- dynamic ruut/3,ruut_old/3,vottis/1,siire/3,siire_1/3,moves_abi/2,valekaik/1,move_count/1, modeCntr/1.

mustad(iapb155243).	%%%%%%%%%%%%%%%% Kasitsi tehtud ainult testimise ajaks!!!!
valged(iapb155243).	%%%%%%%%%%%%%%%% Kasitsi tehtud ainult testimise ajaks!!!!

% qcompile('C:/Users/Juri/Desktop/Mina/Minu Programmid/Kabe/arbiiter.pl').
%===================================== Turniir ====================================
%turniir:-
t(Mode):-
	prepare(Mode),
    repeat,
		modeCntr(Mode1),
		make_move(Color,ColorN),
		verify_turn(ColorN),			% kas kaib lubatud nupuga ja kas kaik korrektne?
		show_board0(ColorN,Mode1),
		end_condition,
		announce_winner(Color),
	korista,				% kommenteeritud valja testimise ajaks!!!!!!!!
	!.
%======================== KaIGU oIGUSE ANDMINE JA SOORITUS ===============================
make_move(Color,ColorNN):-
	 retract(colorCC(Color)),
	 players_turn0(Color,ColorN,_),
	assert(colorCC(ColorN)),
	record_board_status,							% kopeeri laua seis enne kaiku
	siire(_,Vottis,(X,Y)),
	retract(move_count(M)),
	(Vottis=[],X1=0,Y1=0,ColorNN=ColorN,		% Kui eelnevalt ei votnud, saab mangija X=0, Y=0
		M1 is M+1,assert(move_count(M1));		% Votmiseta kaikude loendamine
		assert(move_count(0)),					% Votmiseta kaikude loenduri reset
	millega_kaia(ColorN,(X,Y),(X1,Y1),ColorNN)),	% Kui vottis, vaatab kas sama nupuga saab veel votta
	retract(colorCC(_)),assert(colorCC(ColorNN)),
	correct_player(ColorNN,PlayerNN),
	 Turn=..[PlayerNN,ColorNN,X1,Y1],			% Kui sellega saab veel votta, annab nupu X ja Y ja Color
%	nl,write('KaIB: '),write(Turn),nl,
%	get0(_),
	 Turn,						% Kaigu sooritamine
	!.
%================= Vaatab kellele anda kaimisoigus ===================
reset_color(10,1):- retract(colorCC(_)),assert(colorCC(1)),!.
reset_color(20,2):- retract(colorCC(_)),assert(colorCC(2)),!.
reset_color(Color,Color).

reset_color1(1,10).
reset_color1(2,20).
reset_color1(20,2).
reset_color1(10,1).
reset_color1(C,C).

correct_player(1,PlayerNN):-
	valged(PlayerNN),!.
correct_player(10,PlayerNN):-
	valged(PlayerNN),!.
correct_player(2,PlayerNN):-
	mustad(PlayerNN),!.
correct_player(20,PlayerNN):-
	mustad(PlayerNN).
%-------------------
players_turn0(Color,ColorN,Player):-
	vottis([]),
	players_turn(Color,ColorN,Player),!.	% poordub algselt genereeritud fakti poole
players_turn0(Color,ColorN,Player):-		% Kui vottis ja saab veel votta sama nupuga, jatkab sama mangija
	partner_color(Color,ColorP),
	players_turn(ColorP,_,Player),		% poordub algselt genereeritud fakti poole
	siire(_,_,XY),
	kas_sai_tammiks(Color,XY,ColorN),!.
%----------------------
kas_sai_tammiks(1,(8,_),10):- !.		% valge sai tammiks
kas_sai_tammiks(2,(1,_),20):- !.		% must sai tammiks
kas_sai_tammiks(Color,_,Color).			% ei saanud tammiks
%----------------------
millega_kaia(Color,(X,Y),(0,0),ColorNN):-		% Kui ei saa edasi votta, siis saab kaiguoiguse vastane
	ruut_old(X,Y,Z),
	generate_moves((X,Y,Z),Moves),			% genereerime selle nupu legaalsed kaigud
	findall(Vottis,(member([Vottis,_],Moves),	% kui leitud kaikude hulgas votmist ei ole?
	not(Vottis=[])),[]),
	partner_color(Color,ColorNN),!.
millega_kaia(Color,(X,Y),(X,Y),ColorNN):-
	reset_color(Color,ColorNN),!.			% peab sama nupuga edasi votma, millega vottis eelmisel kaigul

%===================VERIFY: Kaigu reeglitele vastavuse kontroll=======================

verify_turn(Color):-						% Vordle ruut_old/3 ja ruut/3 fakte ja
	kaiv_nupp(Color,(X,Y),Kuhu,Vottis),		% Leia mis nupp kais
	retract(siire_1(_,_,_)),
	retract(siire((X0,Y0),Vottis0,Kuhu0)),
	assert(siire_1((X0,Y0),Vottis0,Kuhu0)),	% Salvesta eelmine kaik
	assert(siire((X,Y),Vottis,Kuhu)),		% Salvesta jooksev kaik
	ruut_old(X,Y,Z),
	generate_all_legal_moves((X,Y,Z),Vottis),	% genereeri selle nupu legaalsed kaigud
	moves_abi((X,Y,_),Moves),
	Kaik=[Vottis,KuhuList],
	member(Kaik,Moves),
	member(Kuhu,KuhuList),
	retractall(vottis(_)),
	retractall(moves_abi(_,_)),
	assert(vottis(Vottis)),!.
verify_turn(Color):-
	(Color=1,Who=' WHITEs '; Who=' BLACKs '),
	nl,write('Player with '), write(Who), write(' did not make or failed a move!'),nl,
	assert(valekaik(Color)),
	retractall(moves_abi(_,_)),!.

kaiv_nupp(Color,(X0,Y0),(X2,Y2),Vottis):-
	ruut_old(X0,Y0,Color),ruut(X0,Y0,0),		% leia kaiv nupp
	ruut_old(X2,Y2,0), ruut(X2,Y2,ColorN),		% leia sihtruut
	kas_sai_tammiks(Color,(X2,Y2),ColorN),		% votmisega voib saada tammiks
	partner_color(Color,ColorP),
	(sama_varv(ColorP,ColorPP),ruut_old(X1,Y1,ColorPP),ruut(X1,Y1,0),Vottis=(X1,Y1);Vottis=[]),!.
kaiv_nupp(Color,(X0,Y0),(X2,Y2),Vottis):-		% kui nupp on juba tamm
	Color10 is Color * 10,
	ruut_old(X0,Y0,Color10),ruut(X0,Y0,0),		% leia kaiv nupp
	ruut_old(X2,Y2,0), ruut(X2,Y2,Color10),		% leia sihtruut
	partner_color(Color,ColorP),
	(sama_varv(ColorP,ColorPP),ruut_old(X1,Y1,ColorPP),ruut(X1,Y1,0),Vottis=(X1,Y1);Vottis=[]),!.
%---------------------------
sama_varv(1,10).
sama_varv(10,1).
sama_varv(2,20).
sama_varv(20,2).
sama_varv(C,C).

%------------------------------ Genereeri antud seisust koik legaalsed kaigud -----------------------------

generate_all_legal_moves((X,Y,_),Vottis):-		% Kui eelmisel kaigul vottis, proovib kas saab samaga veel
	not(Vottis=[]),					% Vottis ei tohi olla tuhi
	ruut_old(X,Y,ColorN),
	generate_moves((X,Y,ColorN),Moves),
	findall([Vottis,Kuhu],(member([Vottis,Kuhu],Moves),not(Vottis=[])),MovesXY),	% Leia votmisega kaigud
	not(MovesXY=[]),
	assert(moves_abi((X,Y,ColorN),Moves)),!.
generate_all_legal_moves((_,_,Color),_):-		% Kui saab suva nupuga votta, siis salvesta ainult votmiskaigud
	reset_color1(Color,ColorN),			% Proovi nii nupu kui tammi koodiga
	ruut_old(X,Y,ColorN),
	generate_moves((X,Y,ColorN),Moves),		% genereeri kaigud uhele nupule
	findall([Vottis,Kuhu],(member([Vottis,Kuhu],Moves),not(Vottis=[])),MovesXY),	% Leia votmisega kaigud
	not(MovesXY=[]),
	assert(moves_abi((X,Y,ColorN),MovesXY)),
	fail.
generate_all_legal_moves((_,_,_),_):-			% Sai votta ja rohkem ei otsi kaike
	moves_abi(_,_),!.
generate_all_legal_moves((_,_,Color),_):-		% Kui ei saa uldse votta, leia koik muud kaigud
	reset_color1(Color,ColorN),			% Proovi nii nupu kui tammi koodiga
	ruut_old(X,Y,ColorN),
	generate_moves((X,Y,ColorN),Moves),
	assert(moves_abi((X,Y,ColorN),Moves)),
	fail.
generate_all_legal_moves((_,_,_),_).
%------------------------------------------------------------
%	Koigi kaikude genereerimine nupule (X0,Y0)
%-----------------------------------------------------------
generate_moves((X0,Y0,1), Moves):-		% Kui tavaline nupp ja valge
	ruut_old(X0,Y0,1),			% Kas niisugune nupp on uldse olemas?
	nupuga(X0, Y0,1,1,Moves),!.
generate_moves((X0,Y0,2), Moves):-		% Kui tavaline nupp ja must
	ruut_old(X0,Y0,2),			% Kas niisugune nupp on uldse olemas?
	nupuga(X0, Y0,2,-1,Moves),!.
generate_moves((X0,Y0,Value), Moves):-
	Value > 2,				% Kas nupp on tamm?
	ruut_old(X0,Y0,Value),			% Kas niisugune nupp on olemas?
	tammiga(X0,Y0,L0), list_to_set(L0,Moves),!.
%	write((X0,Y0,Value)),write('   '),write(Moves),nl,nl.	% TESTIMISEKS!!!!
%===================== Tavalise nupu kaigud antud positsioonilt====================================
nupuga(X0, Y0,Color,XSuund,Kaigud):-
	vota_nupuga(X0,Y0,Color,(1,1), Kaik1),					% Genereeri nupuga voimalikud votmised suunas (1,1)
	vota_nupuga(X0,Y0,Color,(1,-1), Kaik2),	append(Kaik1,Kaik2,Kaik12),	% Genereeri nupuga voimalikud votmised suunas (1,-1)
	vota_nupuga(X0,Y0,Color,(-1,1), Kaik3),	append(Kaik12,Kaik3,Kaik123),	% Genereeri nupuga voimalikud votmised suunas (-1,1)
	vota_nupuga(X0,Y0,Color,(-1,-1), Kaik4),append(Kaik123,Kaik4,Kaik1234),	% Genereeri nupuga voimalikud votmised suunas (-1,-1)
		(Kaik1234=[],						% Kui vahemalt uhe on nupuga voetud, siis lihtsaid kaike enam ei vaadata
	kai_nupuga(X0,Y0,Color,(XSuund,1),Kaik5),
	kai_nupuga(X0,Y0,Color,(XSuund,-1),Kaik6),
	append(Kaik5,Kaik6,Kaigud);
	Kaigud=Kaik1234),!.
%------------------ nupuga votmised-------------
vota_nupuga(X0,Y0,Color,(DX,DY), [[(X1,Y1),[(X2,Y2)]]]):-
	X1 is X0+DX, Y1 is Y0 + DY,      kas_laual(X1,Y1),
	X2 is X1 + DX, Y2 is Y1 + DY,    kas_laual(X2,Y2),
	partner_color(Color,Color1),
	ruut_old(X1,Y1,Color1),
	ruut_old(X2,Y2,0),!.
vota_nupuga(_,_,_,_, []).
%------------------ nupu tavalised kaigud-------------
kai_nupuga(X0,Y0,_,(DX,DY),[[[],[(X1,Y1)]]]):-
	X1 is X0+DX, Y1 is Y0 + DY,      kas_laual(X1,Y1),
	ruut_old(X1,Y1,0),!.
kai_nupuga(_,_,_,_,[]).

%====================== Tammi kaigud antud positsioonilt ==============================================
tammiga(X0, Y0,Kaigud):-
	findall((X,Y), (ruut(X,Y,_), tingimus(X0,Y0,X,Y)), L0), delete(L0,(X0,Y0), Diagonals0),		% Leida ruudu (X0,Y0) diagonaalruudud
	list_to_set(Diagonals0, Diagonals),
	vota_tammiga((X0,Y0), Diagonals, _, Post_posits),					% Kui saab votta, tagastab votmise jargsed positsioonid ja
	(Post_posits=[], findall((XX,YY), (member((XX,YY), Diagonals), ruut_old(XX,YY,0)), VabadRd),	% voetava nupu koordinaadid
	kai_tammiga([(X0,Y0)], VabadRd, Vabad0), delete(Vabad0, (X0,Y0), Vabad),
	append([[]],[Vabad],Kaigud0),Kaigud=[Kaigud0];							% kui ei, tagastab mis ruudud on nendest liikumiseks vabad
	Kaigud=Post_posits).
%------------------ Tammiga votmised-------------
vota_tammiga((X0,Y0),Diagonals,VoetavadNupud,Post_posits):-						% Voetavad=[[(X,Y), Post_positions],...]
	findall((X,Y), (member((X,Y),Diagonals), voetav((X0,Y0),(X,Y))), VoetavadNupud),
	find_post_pos((X0,Y0),VoetavadNupud,Post_posits).
%------------------------------------------------
find_post_pos(_,[],[]).								% Leia voimalikud jarelpositsioonid peale votmist
find_post_pos((X0,Y0),[(X,Y)|VoetavadNupud], [[(X,Y),PostsXY]|Post_posits]):-
	Vx is sign(X-X0), Vy is sign(Y-Y0),
	X1 is X + Vx, Y1 is Y + Vy,
	find_post_pos1((X1,Y1),(Vx,Vy),PostsXY),
	find_post_pos((X0,Y0),VoetavadNupud,Post_posits).

find_post_pos1((X,Y),(Vx,Vy),[(X,Y)|PostsXY]):-
	ruut_old(X,Y,0),
	X1 is X + Vx, Y1 is Y + Vy,
	find_post_pos1((X1,Y1),(Vx,Vy),PostsXY).
find_post_pos1(_,_,[]).

voetav((X0,Y0),(X,Y)):-
	colorCC(Color),
	partner_color(Color,Vastase_varv),
	ruut_old(X,Y,Vastase_varv),
	Vx is sign(X-X0), Vy is sign(Y-Y0),
	X1 is X0 + Vx, Y1 is Y0 + Vy,
	kas_vahel_vabad((X1,Y1),(X,Y),(Vx,Vy)),
	X2 is X + Vx, Y2 is Y + Vy,	ruut_old(X2,Y2,0).			% kas jarel vaba ruut?

kas_vahel_vabad((X,Y),(X,Y),_):- !.						% Kas voetava ja kaidava nupu vahel on vabad ruudud?
kas_vahel_vabad((Xi,Yi),(X,Y),(Vx,Vy)):-
	ruut_old(Xi,Yi,0),
	Xi1 is Xi + Vx, Yi1 is Yi + Vy,
	kas_vahel_vabad((Xi1,Yi1),(X,Y),(Vx,Vy)).

%--------------- tingimused, mida tammi liikumisteed peavad rahuldama---------------------------
tingimus(X0,Y0,X,Y):-
	kas_laual(X0,Y0),
	X =:=Y+X0-Y0.
tingimus(X0,Y0,X,Y):-
	kas_laual(X0,Y0),
	X =:= -Y+(X0+Y0).

%--------------------------------Vabade ruutude leidmine, kuhu tamm saab kaia-------------------------
% Front liigub pikki vabasid ruute nupust sammu kaupa  kaugemale ja tagastab vabade ruutude listi
%-----------------------------------------------------------------------------------------------------
kai_tammiga([],_,[]):- !.
kai_tammiga(_,[],[]):- !.
kai_tammiga(Front,Space,Eligible):-
	subtract(Space,Front,RemainingSpace),
	findall((X,Y),constraint((X,Y),RemainingSpace,Front),NewFront),
	kai_tammiga(NewFront,RemainingSpace,Eligible0),
	append(Front,Eligible0,Eligible).

constraint((X,Y),RemainingSpace,Front):-
	member((X,Y),RemainingSpace),
	neighbourIn((X,Y),Front).

neighbourIn((X,Y), [(X1,Y1)|_]):-		% kas (X,Y)-l leidub hulgas Front vahetu naaber
	abs(abs(X) - abs(X1)) =:=1,
	abs(abs(Y) - abs(Y1)) =:=1,!.
neighbourIn((X,Y), [_|Front]):-
	neighbourIn((X,Y), Front),!.
%========================== END MAKE_MOVE==========================

end_condition:-
	valekaik(_),!.
end_condition:-
	check_fp,
	reset_seis,
	fixpoint(yes).
end_condition:-
	move_count(M),
	M >= 14.

%================== Kontrolli pusipunkti===========================
check_fp:-
    abolish(fixpoint/1),
    assert(fixpoint(yes)),
    ruut(X,Y,Color),
    check_fp1(X,Y,Color),
    fail.
check_fp.

check_fp1(X,Y,Color):-
    retract(ruut_o(X,Y,Color)),!.	% Kas leidub samade parameetritega ruut
check_fp1(_,_,_):-
    retract(fixpoint(_)),
    assert(fixpoint(no)),!.

reset_seis:-
    abolish(ruut_o/3),
    ruut(X,Y,Color),
    assert(ruut_o(X,Y,Color)),
    fail.
reset_seis.

%==================================================================
%-------------------------------------------------------------------------------------------------------------------
prepare(Mode):-
	tee_ruut_faktid,
	assert(modeCntr(Mode)),
	assert(move_count(0)),
	mustad(Functor2),	assert(players_turn(1,2,Functor2)),
	valged(Functor1),	assert(players_turn(2,1,Functor1)),
	assert(siire_1((0,0),[],(0,0))),
	assert(siire((0,0),[],(0,0))),
	assert(arv(0)),
	abolish(colorCC/1),
	assert(colorCC(2)),	% Kui alustab VALGE, siis 2
	reset_seis,
	assert(vottis([])),!.
%--------------
korista:-
%	abolish(mustad/1), abolish(valged/1),
	abolish(ruut/3),
	abolish(ruut_old/3),
	abolish(ruut_o/3),
	abolish(modeCntr/1),
	abolish(move_count/1),
	abolish(siire/3),
	abolish(siire_1/3),
	abolish(arv/1),
	abolish(colorCC/1),
	retractall(players_turn(_,_,_)),
	abolish(vottis/1),
	abolish(moves_abi/2),
	abolish(valekaik/1),
  	abolish(fixpoint/1),
	!.
%--------------
kas_laual(X,Y):-
	1=< X, X=<8,
	1=< Y, Y=<8,!.
%-------------------------
partner_color(1, 2).
partner_color(1, 20).
partner_color(10, 2).
partner_color(10, 20).
partner_color(2, 1).
partner_color(2, 10).
partner_color(20, 1).
partner_color(20, 10).
%-------------------------


%============================= Announce_winner =====================================
announce_winner(_):-	% Kui viik
		move_count(M),
		M >= 14,
		nl, write('The game is a draw (no winner). '),
		arv(NNN),nl,write('Total number of moves is '), write(NNN).
announce_winner(Color):-
    players_turn(_,Color,Winner),
    nl, write('The winner is program \"'),write(Winner), write('\"'),write(' playing with color '), write(Color),
    arv(NNN),nl,write('Total number of moves is '), write(NNN).
%-------------
record_board_status:-
	abolish(ruut_old/3),
	ruut(X,Y,Z), kas_laual(X,Y),
	assert(ruut_old(X,Y,Z)),
	fail.
record_board_status.

% ======================== Mangulaua seisu kuvamine =======================
show_board0(_,_):-
	valekaik(_),!.
show_board0(Color,Mode):-
	retract(arv(NN)), NN1 is NN + 1,assert(arv(NN1)),
	nl,nl,write('Move no '),write(NN1),				%write('--  Player\'s  '),
	(Color=1, Who=':   WHITE ';Who=':   BLACK '),write(Who),	%write(' turn: '),
	siire(Kust,Vottis,Kuhu),
	translate(Kust,Kust1),
	write(Kust1),write('--'),
	translate(Vottis,Vottis1),
	write(Vottis1),
	write('-->'),
	translate(Kuhu,Kuhu1),
	write(Kuhu1),nl,
	write('  \e[1;7;49;36m                              \e[0m'),nl,
	show_board(8),
	mode(Mode),!.
show_board0(_).

translate((X,Y),(Y1,X)):-
	y_to_letter(Y,Y1),!.
translate([X,Y],[Y1,X]):-
	y_to_letter(Y,Y1),!.
translate([],[]).

y_to_letter(1,'1'). y_to_letter(2,'2'). y_to_letter(3,'3'). y_to_letter(4,'4').
y_to_letter(5,'5'). y_to_letter(6,'6'). y_to_letter(7,'7'). y_to_letter(8,'8').

mode(s):-
	write(' (Hit "c" to continue without breaks/ Hit any other key to continue in step mode)'),
	get_single_char(Char),(Char=99, retractall(modeCntr(_)),assert(modeCntr(c));true),!.
mode(_).


show_board(0):-
	write('  \e[1;7;49;36m    1  2  3  4  5  6  7  8    \e[0m'),nl,!.
show_board(X):-
		Mod is mod(X, 2),
		((Mod =:= 1, write('  \e[1;7;49;36m '), write(X), write(' \e[0m')); write('  \e[1;7;49;36m '), write(X)),
    show_board1(X,1),
		((Mod =:= 1, write('\e[1;7;49;36m   \e[0m')); write(' \e[1;7;49;36m   \e[0m')),nl,
    X1 is X - 1,!,
    show_board(X1).

show_board1(_,9):- !.
show_board1(X,Y):-
		Mod is mod(X + Y, 2),
		write(''),
		((Mod =:= 1, write(' \e[0m\e[7m'));write('\e[0m')),
    (ruut(X,Y,Color),  show_board2(Color); write('   \e[27m')),
    Y1 is Y + 1,!,
    show_board1(X,Y1).

show_board2(Color):-
	(Color =:= 10, write("\e[1;1;1;1m \u25EF"));
	(Color =:= 20, write("\e[90;90;1m \u25EF"));
	Color > 2, write(Color),!. % tammi puhul uks tuhik vahem
show_board2(Color):-
	write('\e[27m'),
	(Color =:= 1, write("\e[1;1;1;1m \u25CF"));
	(Color =:= 2, write("\e[90;90;1m \u25CF"));
	(Color =:= 0, write("  ")); (write(' '), write(Color)).
%========================================= MaNGU ALGSEIS ================================
tee_ruut_faktid:-
	abolish(ruut/3),
	% Valged
	assert(ruut(1,1,1)),
	assert(ruut(1,3,1)),
	assert(ruut(1,5,1)),
	assert(ruut(1,7,1)),
	assert(ruut(2,2,1)),
	assert(ruut(2,4,1)),
	assert(ruut(2,6,1)),
	assert(ruut(2,8,1)),
	assert(ruut(3,1,1)),
	assert(ruut(3,3,1)),
	assert(ruut(3,5,1)),
	assert(ruut(3,7,1)),
	% Tuhjad ruudud
	assert(ruut(4,2,0)),
	assert(ruut(4,4,0)),
	assert(ruut(4,6,0)),
	assert(ruut(4,8,0)),
	assert(ruut(5,1,0)),
	assert(ruut(5,3,0)),
	assert(ruut(5,5,0)),
	assert(ruut(5,7,0)),
	% Mustad
	assert(ruut(6,2,2)),
	assert(ruut(6,4,2)),
	assert(ruut(6,6,2)),
	assert(ruut(6,8,2)),
	assert(ruut(7,1,2)),
	assert(ruut(7,3,2)),
	assert(ruut(7,5,2)),
	assert(ruut(7,7,2)),
	assert(ruut(8,2,2)),
	assert(ruut(8,4,2)),
	assert(ruut(8,6,2)),
	assert(ruut(8,8,2)).
/*
 ================================ Mangija programmi vormistamise reeglid: =======================
 1. Programm peab olema vormistatud mooduli kujul
	:- module(mooduli_nimi, mooduli_peapredikaat/3).
		kus peapredikaadi parameetriks on selle programmi nuppude varv, X ja Y koordinaat
 2. Moodulis ei tohi olla defineeritud staatilisi fakte ruut/3 ja  definitsiooni :- dynamic ruut/3.
 3. Mangija programmist ei tohi valjuda fail-ga. Seetottu on soovitav kasutada mangija peapredikaadi jargmist struktuuri:

	main_pgm(Color,X,Y):-
		...., !.
	main_pgm(_,_,_).

 4. Arbiiter salvestab seisu (ruut_old), annab juhtimise mangija programmile, saab kaigu tulemuse, vaatab mis nupuga kaidi.
	kontrollib kas oige mangija nupp ja kas see nupp eksisteerib
	genereerib ise sama nupu lubatud kaikude hulga ja kontrollib kas kaik sisaldub selles hulgas.
	Kui kaik on votmisega ja sama nupuga saab veel votta, siis arbiiter annab oiguse samale mangijale koos votva nupu koordinaatidega.
	Kui sama nupuga ei saa rohkem votta, ei pea ka sama nupuga kaima.
	Kui ei olnud votmist, on parameetrid X=Y=0 ja kaia voib suvalise nupuga
5. Lopetamistingimused:
	5.1 Kui kaik rikub reegkeid, voidab vastane.
	5.2 Kui ei ole rohkem kaike, voidab see, kes teeb viimase kaigu.
	5.3 Kui molema blokeerumisel kaikude arv ja nuppude arv vordne, siis viik.
	5.4 Kui 10 kaigu jarel ei ole seis muutunud, siis viik.

===============Mangu ettevalmistamine====================
Kasurealt defineerida faktid:    assert(mustad(Predik_nimi1)), assert(valged(Prdik_nimi2)).
Testimisel: assert(mustad(main)), assert(valged(main)).
=================Mangu kaivitamine============================
 Laadida esmalt mallu arbiter.pl ja seejarel mangijate programmide failid
 Kutsuda valja predikaat "turniir/0"
==========================================================
*/

%%%%%TESTid
t1:- retract(ruut(3,3,_)),retract(ruut(4,4,_)),assert(ruut(3,3,0)),assert(ruut(4,4,1)).
t2:- retract(ruut(6,2,_)),retract(ruut(5,3,_)), assert(ruut(6,2,0)),assert(ruut(5,3,2)).
t3x:- retract(ruut(2,2,_)),retract(ruut(3,3,_)), assert(ruut(2,2,0)),assert(ruut(3,3,1)).
t3:- retract(ruut(4,4,_)),retract(ruut(5,3,_)),retract(ruut(6,2,_)), assert(ruut(4,4,0)),assert(ruut(5,3,0)),assert(ruut(6,2,1)).
t5:- retract(ruut(6,8,_)),retract(ruut(5,7,_)),retract(ruut(4,6,_)), assert(ruut(6,8,0)),assert(ruut(5,7,0)),assert(ruut(4,6,10)).
