laevaga(tallinn, stockholm, 120, time(6, 15, 0.0), time(16, 0, 30.0)).
laevaga(tallinn, helsinki, 50, time(15, 45, 0.0), time(17, 0, 0.0)).
laevaga(stockholm, tallinn, 130, time(17, 30, 0.0), time(22, 59, 59.10)).
laevaga(helsinki, tallinn, 54, time(17, 15, 0.0), time(19, 0, 0.0)).
rongiga(tallinn, riia, 25, time(9, 0, 0.0), time(16, 13, 55.0)).
rongiga(paris, berlin, 75, time(4, 10, 0.0), time(8, 25, 0.0)).
rongiga(riia, berlin, 222, time(12, 0, 0.0), time(21, 0, 0.0)).
lennukiga(stockholm, tallinn, 350, time(17, 30, 0.0), time(19, 0, 0.0)).
lennukiga(helsinki, paris, 500, time(12, 0, 0.0), time(18, 30, 0.0)).
lennukiga(berlin, helsinki, 419, time(10, 0, 0.0), time(11, 59, 0.0)).
lennukiga(tallinn, helsinki, 200, time(9, 0, 0.0), time(9, 45, 0.0)).
bussiga(riia, tallinn, 40, time(13, 0, 0.0), time(0, 0, 0.0)).
bussiga(paris, berlin, 100, time(23, 0, 0.0), time(15, 0, 0.0)).

soidukiga([laevaga, rongiga, lennukiga, bussiga]).

on_tee(_, _, _, []) :- !, fail.
on_tee(Kust, Kuhu, Soiduk, [Soiduk|_]) :-
    Tee =.. [Soiduk, Kust, Kuhu, _, _, _],
    Tee.
on_tee(Kust, Kuhu, Soiduk, [_|Soidukid]) :-
    on_tee(Kust, Kuhu, Soiduk, Soidukid).
on_tee(Kust, Kuhu, Soiduk) :-
    soidukiga(Soidukid),
    on_tee(Kust, Kuhu, Soiduk, Soidukid).

reisi(Kust, Kuhu, Tee, Hind, _) :-
    on_tee(Kust, Kuhu, Soidukiga),
    Term =.. [Soidukiga, Kust, Kuhu, Hind, _, _],
    Term,
    Tee = mine(Kust, Kuhu, Soidukiga).
reisi(Kust, Kuhu, Tee, Hind, Labitud) :-
    \+ on_tee(Kust, Kuhu, _),
    on_tee(Kust, Vahepealne, Soiduk),
    \+ member(Vahepealne, Labitud),   
    reisi(Vahepealne, Kuhu, Edasine_teekond, Edasine_hind, [Kust|Labitud]),
    Term =.. [Soiduk, Kust, Vahepealne, Praegune_hind, _, _],
    Term,
    Hind is Praegune_hind + Edasine_hind,
    Tee = mine(Kust, Vahepealne, Soiduk, Edasine_teekond).
reisi(Kust, Kuhu, Tee, Hind) :-
    reisi(Kust, Kuhu, Tee, Hind, [Kust]).

on_parim_odavaim_reis(Kust, Kuhu, _, Hind) :-
    parim_odavaim_reis(Kust, Kuhu, _, Parim_hind),
    Hind < Parim_hind.
on_parim_odavaim_reis(Kust, Kuhu, Tee, Hind) :-
    \+ parim_odavaim_reis(Kust, Kuhu, _, _),
    assert(parim_odavaim_reis(Kust, Kuhu, Tee, Hind)).

odavaim_reis(_, _,_ ,_) :- 
    retractall(parim_odavaim_reis(_, _, _, _)),
    fail.
odavaim_reis(Kust, Kuhu, _, _) :-
    reisi(Kust, Kuhu, Hetke_tee, Hetke_hind),
    on_parim_odavaim_reis(Kust, Kuhu, Hetke_tee, Hetke_hind),
    retractall(parim_odavaim_reis(Kust, Kuhu, _, _)),
    asserta(parim_odavaim_reis(Kust, Kuhu, Hetke_tee, Hetke_hind)),
    fail.
odavaim_reis(Kust, Kuhu, Tee, Hind) :-
    retract(parim_odavaim_reis(Kust, Kuhu, Tee, Hind)).

aegade_vahe(time(H1, M1, S1), time(H2, M2, S2), time(Tunnid, Minutid, Sekundid)) :-
    Vahe_temp is (H1*60*60 + M1*60 + S1) - (H2*60*60 + M2*60 + S2),
    (Vahe_temp < 0, Vahe is 24*60*60 + Vahe_temp; Vahe is Vahe_temp), !, 
    Tunnid is floor(Vahe / (60*60)),
    Minutid is floor(Vahe / 60) mod 60,
    Sekundid is Vahe - Tunnid * 3600 - Minutid * 60.

aegade_summa(time(H1, M1, S1), time(H2, M2, S2), time(Tunnid, Minutid, Sekundid)) :-
    Summa is (H1*60*60 + M1*60 + S1) + (H2*60*60 + M2*60 + S2),
    Tunnid is floor(Summa / (60*60)),
    Minutid is floor(Summa / 60) mod 60,
    Sekundid is Summa - Tunnid * 3600 - Minutid * 60.

aegade_vordlus(time(H1, M1, S1), time(H2, M2, S2), Tulemus) :-
    Tulemus is sign((H1*60*60 + M1*60 + S1) - (H2*60*60 + M2*60 + S2)).

oote_aeg(time(H1, M, S), time(H2, M, S)) :-
    H1 < 1, H2 is 24 + H1.
oote_aeg(time(H, M, S), time(H, M, S)).

tee_aeg(mine(Kust, Kuhu, Soiduk), Aeg, Eelmise_saabumise_aeg) :- 
    Term =.. [Soiduk, Kust, Kuhu, _, Valjumise_aeg, Saabumise_aeg], Term,
    aegade_vahe(Valjumise_aeg, Eelmise_saabumise_aeg, Oote_aeg_temp),
    oote_aeg(Oote_aeg_temp, Oote_aeg),
    aegade_vahe(Saabumise_aeg, Valjumise_aeg, Soidu_aeg),
    aegade_summa(Oote_aeg, Soidu_aeg, Aeg).
tee_aeg(mine(Kust, Kuhu, Soiduk, Jargine_tee), Aeg, Eelmise_saabumise_aeg) :- 
    Term =.. [Soiduk, Kust, Kuhu, _, Valjumise_aeg, Saabumise_aeg], Term,
    tee_aeg(Jargine_tee, Jargmise_tee_aeg, Saabumise_aeg),
    aegade_vahe(Saabumise_aeg, Valjumise_aeg, Soidu_aeg),
    aegade_vahe(Valjumise_aeg, Eelmise_saabumise_aeg, Oote_aeg_temp),
    oote_aeg(Oote_aeg_temp, Oote_aeg),
    aegade_summa(Oote_aeg, Soidu_aeg, Solme_aeg),
    aegade_summa(Jargmise_tee_aeg, Solme_aeg, Aeg).

on_lyhim_reis(Tee) :-
    parim_lyhim_reis_aeg(Parim_aeg),
    tee_aeg(Tee, Aeg, time(0, 0, 0)),
    aegade_vordlus(Parim_aeg, Aeg, Tulemus),
    Tulemus < 0,
    retract(parim_lyhim_reis_aeg(Parim_aeg)),
    asserta(parim_lyhim_reis_aeg(Aeg)).
on_lyhim_reis(Tee) :-
    \+ parim_lyhim_reis_aeg(_),
    tee_aeg(Tee, Aeg, time(0, 0, 0)),
    assert(parim_lyhim_reis_aeg(Aeg)).

lyhim_reis(_, _, _, _) :-
    retractall(parim_lyhim_reis_aeg(_)),
    retractall(parim_lyhim_reis(_, _, _, _)), fail.
lyhim_reis(Kust, Kuhu, _, _) :-
    reisi(Kust, Kuhu, Tee, Hind),
    on_lyhim_reis(Tee),
    retractall(parim_lyhim_reis(_, _, _, _)),
    asserta(parim_lyhim_reis(Kust, Kuhu, Tee, Hind)),
    fail.
lyhim_reis(Kust, Kuhu, Tee, Hind) :-
    retract(parim_lyhim_reis(Kust, Kuhu, Tee, Hind)),
    retract(parim_lyhim_reis_aeg(_)).
