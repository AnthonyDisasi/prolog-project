:- use_module(library(pce)).


/*
    Start GUI
*/

start :-
		new(D, dialog('Prolog Project')),
    	send(D, append, new(Resultat, text('Bienvenue !'))),
        send(Resultat, colour, black),
    	send(Resultat, font, font(times, bold, 18)),
    	send(D, append, button(products, message(@prolog, open_products_list))),
    	send(D, append, button(suppliers, message(@prolog, open_suppliers_list))),
    	send(D, append, button(events, message(@prolog, open_events_list))),
    	send(D, append, button(close_window, message(D, destroy))),
    	send(D, open).

/*
    Open Products List Window
*/

open_products_list :-
        consult(datas),
        consult(rules),
    	new(B, browser('List')),
    	get_products_for_view(List),
        send_list(B, append, List),
        send(B, size, size(50,100)),
    	send(B, open).


/*
    Open Suppliers List Window
*/

open_suppliers_list :-
        consult(datas),
        consult(rules),
    	new(B, browser('List')),
    	get_suppliers_for_view(List),
        send_list(B, append, List),
        send(B, size, size(50,100)),
    	send(B, open).

/*
    Open Events List Window
*/

open_events_list :-
        consult(datas),
        consult(rules),
    	new(B, browser('List')),
    	get_events_for_view(List),
        send_list(B, append, List),
        send(B, size, size(50,100)),
    	send(B, open).