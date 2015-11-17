/*
    Prédicats de base
*/

/********** PRODUCTS *************/

/* 
	Prédicat : affichage informations produit
*/

info_product(ID_Product):- 
	product(ID_Product, Name_product, List_suppliers, Quantity),
	write('ID_Product : '), write(ID_Product), nl,
	write('Name_product : '), write(Name_product), nl,
	write('List_suppliers : '), write(List_suppliers), nl,
	write('Quantity : '), write(Quantity), nl, nl.

/*
	Affichage de tout les produits
*/

info_all_products :-
	forall(product(ID,_,_,_), info_product(ID)).

/*
	Getter Quantity
*/

get_quantity(ID_Product, Quantity):-
	product(ID_Product,_,_,Quantity).

/*
	Getter List_suppliers
*/
	
get_suppliers(ID_Product, List_suppliers):-
	product(ID_Product,_,List_suppliers,_).

/********** SUPPLIERS *************/

/*
	Getter Distance with supplier
*/
	distance(ID_Supplier, Distance):-
		supplier(ID_Supplier, _, [Latitude_supplier|Longitude_supplier]),
		Latitude is abs(Latitude_supplier-50),
		Longitude is abs(Longitude_supplier-50),
		Distance is Latitude + Longitude.

/*
	Creation suppliers tab
*/
	suppliers_tab_init(List_suppliers):-
		ID_Supplier is 1,
		add_suppliers_rec(ID_Supplier,[],List_suppliers).

	add_suppliers_rec(ID_Supplier,[],Supplier):-
		supplier(ID_Supplier,_,_),
		distance(ID_Supplier,Dist),
		append(ID_Supplier,10,Tmp),
		append(Tmp,Dist,Supplier),
		ID_Supplier is ID_Supplier + 1,
		add_suppliers_rec(ID_Supplier, List_suppliers,Supplier).

	add_suppliers_rec(ID_Supplier,[List_suppliers_head|List_suppliers_tail],[List_suppliers_head|Supplier]):-
		supplier(ID_Supplier,_,_),
		distance(ID_Supplier,Dist),
		append(ID_Supplier,10,Tmp),
		append(Tmp,Dist,Supplier),
		ID_Supplier is ID_Supplier + 1,
		add_suppliers_rec(ID_Supplier, List_suppliers_tail,Supplier).

add_tail([],X,[X]).
add_tail([H|T],X,[H|L]):-add_tail(T,X,L).
		
/*
    SETTERS
*/

set_product_quantity(IdProduct, NewQuantity):-
    retract(product(IdProduct, Name, Suppliers, _)),
    asserta(product(IdProduct, Name, Suppliers, NewQuantity)).

/*
    GUI Predicates
*/

add_into_list([], L, [L]).
add_into_list(X, L, [X|L]).

:- dynamic(listTmp/2).

get_products_for_view(ListString) :-
    get_products_for_view_rec([],ListString).

get_products_for_view_rec(EmptyList,ListString) :-
    asserta(listTmp(1,EmptyList)),
    forall(
	    product(IdProduct ,Name, _, Quantity),
	    (
	        atomic_concat('[',IdProduct, A),
	        atomic_concat(A,'] ', B),
	        atomic_concat(B, Name, C),
	        atomic_concat(C,' - (Quantity = ', D),
	        atomic_concat(D, Quantity, E),
	        atomic_concat(E,')', String),
            retract(listTmp(1, List)),
            add_into_list(List, String, Return),
            asserta(listTmp(1, Return))
	    )
	),
	retract(listTmp(1,ListString)).

get_suppliers_for_view(ListString) :-
    get_suppliers_for_view_rec([],ListString).

get_suppliers_for_view_rec(EmptyList,ListString) :-
    asserta(listTmp(2,EmptyList)),
    forall(
	    supplier(IdSupplier ,Name, Products, _),
	    (
	        atomic_concat('[',IdSupplier, A),
	        atomic_concat(A,'] ', B),
	        atomic_concat(B, Name, C),
	        atomic_concat(C,' - (Coordinates = [', D),
	        atomic_list_concat(Products,', ', Atom),
	        atomic_concat(D, Atom, E),
	        atomic_concat(E,'])', String),
            retract(listTmp(2, List)),
            add_into_list(List, String, Return),
            asserta(listTmp(2, Return))
	    )
	),
	retract(listTmp(2,ListString)).

get_events_for_view(ListString) :-
    get_events_for_view_rec([],ListString).

get_events_for_view_rec(EmptyList,ListString) :-
    asserta(listTmp(2,EmptyList)),
    forall(
	    event(IdEvent ,Name, Impact, Radius),
	    (
	        atomic_concat('[',IdEvent, A),
	        atomic_concat(A,'] ', B),
	        atomic_concat(B, Name, C),
	        atomic_concat(C,' - Impact = [', D),
	        atomic_concat(D, Impact, E),
	        atomic_concat(E,'] - Radius = [', F),
	        atomic_concat(F, Radius, G),
	        atomic_concat(G,']', String),
            retract(listTmp(2, List)),
            add_into_list(List, String, Return),
            asserta(listTmp(2, Return))
	    )
	),
	retract(listTmp(2,ListString)).

/*
    Day Plus One Function
*/

day_plus_one(Integer) :-

    retract(context(OldNumDay)),
    NewNumDay is OldNumDay + 1,
    asserta(context(NewNumDay)),
    write('Changement de jour: '),write(NewNumDay),
    nl.
    /*
    send(Resultat,selection, NewNumDay).
    atomic_concat('Jour ',Integer,StringDay).
    */
