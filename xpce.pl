:- use_module(library(pce)).


/*
    Start GUI
*/

start :-
        set_context,
		new(D, dialog('Prolog Project')),
    	send(D, append, new(StringDay, label(stringday, 'Jour 0'))),
    	send(StringDay, colour, black),
        send(StringDay, font, font(times, bold, 18)),
    	send(D, append, button(produits, message(@prolog, open_products_list))),
    	send(D, append, button(fournisseurs, message(@prolog, open_suppliers_list))),
    	send(D, append, button(évènements, message(@prolog, open_events_list))),
    	send(D, append, button(commandes_en_attente, message(@prolog, open_waiting_list))),
    	send(D, append, button(simulation_journée, message(@prolog, day_plus_one, D))),
    	send(D, append, button(quitter, message(D, destroy))),
    	send(D, open).


/*
    Set Initial Context
        Arguments:
            (1) Day Numero
*/

:- dynamic(context/1).

set_context:-
    consult(datas),
    consult(rules),
    asserta(context(0)).

/*
    Open Products List Window
*/

open_products_list :-
    	new(B, browser('List')),
    	get_products_for_view(List),
        send_list(B, append, List),
        send(B, size, size(50,100)),
    	send(B, open).


/*
    Open Suppliers List Window
*/

open_suppliers_list :-
    	new(B, browser('List')),
    	get_suppliers_for_view(List),
        send_list(B, append, List),
        send(B, size, size(50,100)),
    	send(B, open).

/*
    Open Events List Window
*/

open_events_list :-
    	new(B, browser('List')),
    	get_events_for_view(List),
        send_list(B, append, List),
        send(B, size, size(50,100)),
    	send(B, open).

/*
    Open Waiting List Window
*/

open_waiting_list :-
    	new(B, browser('List')),
    	get_waiting_orders_for_view(List),
        send_list(B, append, List),
        send(B, size, size(90,100)),
    	send(B, open).

