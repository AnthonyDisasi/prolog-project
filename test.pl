




day_plus_one:-
    %set_new_day(Dialog),
    advancement_deliveries,
    daily_event,
    daily_order,
    check_waiting_list,
    write('--------------------------------------'),
    nl.



test:-
	test_rec(0),
	forall(
		product(ID, Name,_,QT),
		(write('produit '),
		write(ID),
		write(' - '),
		write(Name),
		write(' - '),
		write(QT),
		nl)).


test_rec(10000):-!.
test_rec(X):-
	day_plus_one,
	write(X),
	nl,
	Y is X+1,
	test_rec(Y).