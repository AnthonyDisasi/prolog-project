/*
    Prédicats de base
*/

/********** PRODUCTS *************/

/* 
	Prédicat : affichage informations produit
*/

info_product(IdProduct):- 
	product(IdProduct, NameProduct, ListSuppliers, Quantity),
	write('ID : '), write(IdProduct), nl,
	write('Nom : '), write(NameProduct), nl,
	write('Liste des fournisseurs : '), write(ListSuppliers), nl,
	write('Quantité : '), write(Quantity), nl, nl.

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
	distance(Latitude1, Longitude1, Latitude2, Longitude2, Distance):-
		Latitude is abs(Latitude1-Latitude2),
		Longitude is abs(Longitude1-Longitude2),
		Distance is Latitude + Longitude.

		
/*
    SETTERS
*/

set_product_quantity(IdProduct, NewQuantity):-
    retract(product(IdProduct, Name, Suppliers, _)),
    asserta(product(IdProduct, Name, Suppliers, NewQuantity)).

set_supplier_mark(IdSupplier, Mark):-
	retract(supplier(IdSupplier, Name, Coordinates, _)),
	asserta(supplier(IdSupplier, Name, Coordinates, Mark)).

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

day_plus_one :-
    set_new_day,
    random_order(IdProduct,Quantity),
    random_event(IdEvent, AxisX, AxisY),
    write('--------------------------------------'),
    nl.

/*
    Days Management
*/

set_new_day :-
    retract(context(OldNumDay)),
    NewNumDay is OldNumDay + 1,
    asserta(context(NewNumDay)),
    write('Changement de jour: '),write(NewNumDay),
    nl.

/*
    Random predicates
        (1) random_order --> Idproduct [1-60], Quantity [20-80]
        (2) random_event --> IdEvent [1-20], AxisX [0-100], AxisY [0-100]
*/

random_order(IdProduct, Quantity):-
    random(1,61,IdProduct),
    random(20,81,Quantity),
    write('Commande du produit '),write(IdProduct), write(' [Qté: '), write(Quantity),write(']'),nl.

random_event(IdEvent, AxisX, AxisY):-
    random(1,21,IdEvent),
    random(0,101,AxisX),
    random(0,101,AxisY).

random_coordinates(Latitude,Longitude):-
	D = 1, F = 51, 
	random(D,F,Latitude), 
	random(D,F,Longitude).

random_product(ID_Product, Quantity):-
	D = 1, F = 61,
	random(D,F,ID_Product),
	L = 1, M = 101,
	random(L,M, Quantity).

product_availability(IdProduct,QuantityAsked):-
	product(IdProduct,_,_,Quantity),
	Quantity > QuantityAsked.

%replenishment(ID_Product):-!.

impact_event(Latitude,Longitude,IdEvent):-
	event(IdEvent,NameEvent,Impact,Radius),
	write('Evenement : '),write(NameEvent),nl,
	write('\t'),write('Latitude : '),write(Latitude),nl,
	write('\t'),write('Longitude : '),write(Longitude),nl,
	write('\t'),write('Impact : '),write(Impact),nl,
	write('\t'),write('Rayon : '),write(Radius),nl,
	forall(supplier(IdSupplier,_,_,_),
	 		(supplier_impacted_by_event(Latitude,Longitude,IdEvent,IdSupplier),!,
	 			impact_supplier(IdSupplier,Impact);!)),
	forall(delivery(IdDelivery,_,_,_,_,_,_),
			(delivery_impacted_by_event(Latitude,Longitude,IdEvent,IdDelivery),!,
	 			impact_delivery(IdDelivery);!)).

supplier_impacted_by_event(LatitudeEvent,LongitudeEvent,IdEvent,IdSupplier):-
	supplier(IdSupplier,_,[LatitudeSupplier|LongitudeSupp],_),
	LongitudeSupplier is LongitudeSupp,
	event(IdEvent,_,_,Radius),
	distance(LatitudeEvent,LongitudeEvent,LatitudeSupplier,LongitudeSupplier,Dist),
	Dist =< Radius.

delivery_impacted_by_event(LatitudeEvent,LongitudeEvent,IdEvent,IdDelivery):-
	delivery(IdDelivery,_,_,_,LatitudeDelivery,LongitudeDelivery,_),
	event(IdEvent,_,_,Radius),
	distance(LatitudeEvent,LongitudeEvent,LatitudeDelivery,LongitudeDelivery,Dist),
	Dist =< Radius.
	 			
impact_supplier(IdSupplier,Impact):-
	supplier(IdSupplier,Name,_,Mark),
	write('Le fournisseur '),write(Name),write(' a ete impacte par l évènement.'),nl,
	(Mark > Impact,!,
		NewMark is Mark - Impact;
		NewMark is 0),
	set_supplier_mark(IdSupplier,NewMark).

impact_delivery(IdDelivery):-
	retract(delivery(IdDelivery,_,IdProduct,Quantity,_,_,_)),
	write('La commande N° '),write(IdDelivery),write(' a été impacté par l évènement.'),nl,
	%Choix supplier
	write('Relance de la commande aupres du fournisseur').
	%Création commande
	%affichage commande

display_delivery(IdDelivery):-
	delivery(IdDelivery,IdSupplier,IdProduct,Quantity,_,_,Time),
	product(IdProduct,NameProduct,_,_),
	supplier(IdSupplier,NameSupplier,_,_),
	write('Livraison N° '),write(IdDelivery),nl,
	write('\t'),write('Libelle Produit : '),write(NameProduct),nl,
	write('\t'),write('Quantite : '),write(Quantity),nl,
	write('\t'),write('Fournisseur : '),write(NameSupplier),nl,
	write('\t'),write('Temps d acheminement restant : '),write(Time),nl.

