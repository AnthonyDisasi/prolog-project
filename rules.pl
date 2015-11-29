:- dynamic(waiting_order/3).
:- dynamic(is_empty_waiting_list/2).
:- dynamic(listTmp/2).
:- dynamic(supplierTmp/3).
:- dynamic(bool_suppliers_impacted/0).
:- dynamic(bool_deliveries_impacted/0).
:- dynamic(bool_deliveries_made/0).
:- dynamic(delivery/8).


/*
 |============================|
 |   DAY PLUS ONE PREDICATE   |
 |============================|
*/

day_plus_one(Dialog) :-
    write('======================================='),nl,
    set_new_day(Dialog),
    upgrade_suppliers_marks,
    write('---------------------------------------'),nl,
    advancement_deliveries,
    write('---------------------------------------'),nl,
    daily_event,
    write('---------------------------------------'),nl,
    daily_order,
    write('---------------------------------------'),nl,
    check_waiting_list,
    write('======================================='),
    nl,nl.


/*
 |====================|
 |   DAY MANAGEMENT   |
 |====================|
*/

set_new_day(Dialog) :-
    retract(context(OldNumDay)),
    NewNumDay is OldNumDay + 1,
    asserta(context(NewNumDay)),

    get(Dialog, member('stringday'), Output),
    atomic_concat('','Jour ',StringTmp),
    atomic_concat(StringTmp, NewNumDay, StringDay),
    send(Output, selection, StringDay),
    write('Changement de jour : '),write(NewNumDay),
    nl.


/*
 |=========================|
 |   SUPPLIERS MANAGEMENT  |
 |=========================|
*/

distance(Latitude1, Longitude1, Latitude2, Longitude2, Distance):-
	Latitude is abs(Latitude1-Latitude2),
	Longitude is abs(Longitude1-Longitude2),
	Distance is Latitude + Longitude.

upgrade_suppliers_marks:-
    forall(
        supplier(IdSupplier,_,_,Mark),
        (
            retract(supplier(IdSupplier, Name, Location, Mark)),
            (
                Mark < 10
                ->
                NewMark is Mark + 1,
                asserta(supplier(IdSupplier, Name, Location, NewMark));
                asserta(supplier(IdSupplier, Name, Location, Mark))
            )
        )
    ).


/*
 |=========================|
 |   DELIVERY MANAGEMENT   |
 |=========================|
*/

advancement_deliveries:-
	write('ARRIVAGE DE LIVRAISONS : '),nl,
	forall(delivery(IdDelivery,_,_,_,_,_,_,_),
		(move_delivery(IdDelivery),
		delivery(IdDelivery,_,IdProduct,_,_,_,0,_),!,
			delivery_made(IdDelivery),
			(not(bool_deliveries_made) -> asserta(bool_deliveries_made);!),
			write('La livraison N° '),write(IdDelivery),write(' est arrivé.'),nl,
			product(IdProduct,NameProduct,_,Quantity),
			write('Le stock de produit  '),write(NameProduct),write(' est maintenant de '), write(Quantity),nl;!)),
		(not(bool_deliveries_made) -> write('Aucun arrivage de livraisons aujourd hui.'); retract(bool_deliveries_made)),nl.


move_delivery(IdDelivery):-
	delivery(IdDelivery,_,_,_,Latitude,_,Time,Downtime),
	(Downtime > 0
		-> NewDowntime is Downtime - 1, 
			set_delivery_downtime(IdDelivery,NewDowntime);
	(Time > 5,!,
		NewTime is Time - 5;
		NewTime is 0),
	set_delivery_time(IdDelivery,NewTime),
	(Latitude = 50
		-> change_longitude(IdDelivery, 5);
	change_latitude(IdDelivery,5))).

change_latitude(IdDelivery, Movement):-
	delivery(IdDelivery,_,_,_,Latitude,_,_,_),
	(Latitude > 45, Latitude < 55
		->
		MovementOnLongitude is Movement - abs(Latitude - 50),
		NewLatitude is 50,
		set_delivery_latitude(IdDelivery,NewLatitude),
		change_longitude(IdDelivery,MovementOnLongitude);
	Latitude < 50
		->
		NewLatitude is Latitude + Movement,
		set_delivery_latitude(IdDelivery,NewLatitude);
	Latitude > 50
		->
		NewLatitude is Latitude - Movement,
		set_delivery_latitude(IdDelivery,NewLatitude);!).

change_longitude(IdDelivery, Movement):-
	delivery(IdDelivery,_,_,_,_,Longitude,_,_),
	(Longitude > 45, Longitude < 55
		->
		NewLongitude is 50,
		set_delivery_longitude(IdDelivery,NewLongitude);
	Longitude < 50
		->
		NewLongitude is Longitude + Movement,
		set_delivery_longitude(IdDelivery,NewLongitude);
	Longitude > 50
		->
		NewLongitude is Longitude - Movement,
		set_delivery_longitude(IdDelivery,NewLongitude);!).


delivery_made(IdDelivery):-
	delivery(IdDelivery,_,Idproduct,QuantityDelivered,_,_,_,_),
	get_quantity(Idproduct,ProductQuantity),
	NewQuantity is QuantityDelivered + ProductQuantity,
	set_product_quantity(Idproduct,NewQuantity),
	retract(delivery(IdDelivery,_,_,_,_,_,_,_)).

create_delivery(IdProduct,Quantity,IdSupplier):-
	supplier(IdSupplier,NameSupplier,[LatitudeSupplier|LongitudeSupp],_),
	LongitudeSupplier is LongitudeSupp,
	product(IdProduct,NameProduct,_,_),
	distance(50,50,LatitudeSupplier,LongitudeSupplier,Dist),
	retract(nbr_deliveries_sent(Nbr)),
	NewNbr is Nbr + 1,
	asserta(nbr_deliveries_sent(NewNbr)),
	asserta(delivery(NewNbr,IdSupplier,IdProduct,Quantity,LatitudeSupplier,LongitudeSupplier,Dist,0)),
	write('Création d une nouvelle commande fournisseur : '),
	write(Quantity),write(' unités de '),write(NameProduct),
	write(' auprès de '),write(NameSupplier),
	Time is Dist//5,
	write('. Délai de livraison ≈ '),write(Time),write(' jours.'),nl.


/*
 |======================|
 |   EVENT MANAGEMENT   |
 |======================|
*/

daily_event:-
	random_event(IdEvent, Latitude, Longitude),
	impact_event(IdEvent, Latitude, Longitude).

impact_event(IdEvent,Latitude,Longitude):-
	event(IdEvent,NameEvent,Impact,Radius),
	write('EVENEMENT : '),nl,
	write('Nature : '),
	write(NameEvent),
	write(', Coordonnées : ['),
	write(Latitude),
	write(','),
	write(Longitude),
	write('], Impact : '),
	write(Impact),
	write(', Rayon : '),write(Radius),nl,
	write('Liste des fournisseurs impactés : '),
	forall(supplier(IdSupplier,_,_,_),
	 		(supplier_impacted_by_event(Latitude,Longitude,IdEvent,IdSupplier),!,
	 			impact_supplier(IdSupplier,Impact);!)),
	(not(bool_suppliers_impacted) -> write('Aucun fournisseur impacté par cet évènement.'); retract(bool_suppliers_impacted)),nl,
	write('Liste des livraisons impactées : '),
	forall(delivery(IdDelivery,_,_,_,_,_,_,_),
			(delivery_impacted_by_event(Latitude,Longitude,IdEvent,IdDelivery),!,
	 			impact_delivery(IdDelivery,Impact);!)),
	(not(bool_deliveries_impacted) -> write('Aucune livraison impactée par cet évènement.'); retract(bool_deliveries_impacted)),nl.

supplier_impacted_by_event(LatitudeEvent,LongitudeEvent,IdEvent,IdSupplier):-
	supplier(IdSupplier,_,[LatitudeSupplier|LongitudeSupp],_),
	LongitudeSupplier is LongitudeSupp,
	event(IdEvent,_,_,Radius),
	distance(LatitudeEvent,LongitudeEvent,LatitudeSupplier,LongitudeSupplier,Dist),
	Dist =< Radius.

delivery_impacted_by_event(LatitudeEvent,LongitudeEvent,IdEvent,IdDelivery):-
	delivery(IdDelivery,_,_,_,LatitudeDelivery,LongitudeDelivery,_,_),
	event(IdEvent,_,_,Radius),
	distance(LatitudeEvent,LongitudeEvent,LatitudeDelivery,LongitudeDelivery,Dist),
	Dist =< Radius.
	 			
impact_supplier(IdSupplier,Impact):-
	(bool_suppliers_impacted -> write(', '); asserta(bool_suppliers_impacted)),
	supplier(IdSupplier,Name,_,Mark),
	write(Name),
	(Mark > Impact,!,
		NewMark is Mark - Impact;
		NewMark is 0),
	set_supplier_mark(IdSupplier,NewMark).

impact_delivery(IdDelivery,Impact):-
	(bool_deliveries_impacted -> write(', '); asserta(bool_deliveries_impacted)),
	delivery(IdDelivery,_,_,_,_,_,_,Downtime),
	write(IdDelivery),
	NewDowntime is Downtime + Impact,
	set_delivery_downtime(IdDelivery,NewDowntime).


/*
 |=============================|
 |   CLIENT ORDER MANAGEMENT   |
 |=============================|
*/

daily_order :-
	write('RECEPTION COMMANDE CLIENT : '),nl,
    random_order(IdProduct,Quantity),
    product(IdProduct, _, _, ActualQuantity),
    (
        product_availability(IdProduct, Quantity)
        ->
        NewQuantity is ActualQuantity - Quantity,
        set_product_quantity(IdProduct,NewQuantity),
        write('Stock suffisant, décrémentation du stock.'),nl
        ;
        add_into_waiting_list(IdProduct,Quantity)
    ),
    find_best_supplier(IdProduct,IdSupplier),
    create_delivery(IdProduct,Quantity,IdSupplier).


find_best_supplier(IdProduct,IdSupplier):-
    product(IdProduct, _, SupplierList, _),
    get_best_supplier(SupplierList, IdSupplier),
    supplier(IdSupplier, Name, _, _),
    write('Le fournisseur "['),write(IdSupplier),write('] '),write(Name),write('" a été choisi pour cette commande client.'),nl.

get_best_supplier([X|L],IdSupplier):-
    supplier_mark_calcul(X,Mark),
    asserta(supplierTmp(1,X,Mark)),
    get_best_supplier_rec(L,IdSupplier),
    retract(supplierTmp(1,_,_)).

get_best_supplier_rec([],IdSupplier):-
    supplierTmp(1,IdSupplier,_).

get_best_supplier_rec([X|L],IdSupplier):-
    supplier_mark_calcul(X,Mark),
    supplierTmp(1, _, MarkTmp),
    (
        Mark > MarkTmp
        ->
        retract(supplierTmp(1,_,_)),
        asserta(supplierTmp(1, X, Mark));
        !
    ),
    get_best_supplier_rec(L,IdSupplier).


supplier_mark_calcul(IdSupplier, Mark):-
    supplier(IdSupplier, _, _, FiabilityMark),
    supplier(IdSupplier,_,[X|Else],_),
    Y is Else,
    distance(50,50,X,Y,Distance),
    DeliveryMark is 100 - Distance,
    Mark is FiabilityMark*10 + DeliveryMark.


add_into_waiting_list(IdProduct,Quantity):-
    asserta(waiting_order(IdProduct,Quantity,0)),
    write('Stock insuffisant, mise en attente de la commande client'),nl.


/*
 |=============================|
 |   WAITING LIST MANAGEMENT   |
 |=============================|
*/

check_waiting_list:-
	write('GESTION DES COMMANDES EN ATTENTE : '),nl,
    (
    waiting_order(_,_,_)
    ->
    write('Vérification des commandes clients en attentes.'),nl,check_waiting_list_rec
    ;
    write('Aucune commande client en attente.'),nl
    ).

check_waiting_list_rec:-
    forall(
        waiting_order(IdProduct,Quantity,NbrDays),
        (
            (
            product_availability(IdProduct, Quantity)
            ->
            product(IdProduct, Name, _, ActualQuantity),
            NewQuantity is ActualQuantity - Quantity,
            set_product_quantity(IdProduct,NewQuantity),
            write('\t'),
            write('Commande client en attente effectuée concernant le produit "['),
            write(IdProduct),
            write('] '),
            write(Name),
            write('" pour une quantité de '),
            write(Quantity),
            write(' au bout de '),
            write(NbrDays),
            write(' jours.'),nl,
            retract(waiting_order(IdProduct,_,_))
            ;
            retract(waiting_order(IdProduct,Quantity,NbrDays)),
            NewNbrDays is NbrDays+1,
            asserta(waiting_order(IdProduct,Quantity,NewNbrDays)),
            write('\t'),write('Commande client en attente non réalisable.'),nl
            )
        )
    ).


/*
 |=============|
 |   GETTERS   |
 |=============|
*/

get_quantity(ID_Product, Quantity):-
	product(ID_Product,_,_,Quantity).

get_suppliers(ID_Product, List_suppliers):-
	product(ID_Product,_,List_suppliers,_).


/*
 |=============|
 |   SETTERS   |
 |=============|
*/

set_product_quantity(IdProduct, NewQuantity):-
    retract(product(IdProduct, Name, Suppliers, _)),
    asserta(product(IdProduct, Name, Suppliers, NewQuantity)).

set_supplier_mark(IdSupplier, Mark):-
	retract(supplier(IdSupplier, Name, Coordinates, _)),
	asserta(supplier(IdSupplier, Name, Coordinates, Mark)).

set_delivery_latitude(IdDelivery,Latitude):-
	retract(delivery(IdDelivery,IdSupplier,IdProduct,Quantity,_,Longitude,Time,Downtime)),
	asserta(delivery(IdDelivery,IdSupplier,IdProduct,Quantity,Latitude,Longitude,Time,Downtime)).

set_delivery_longitude(IdDelivery,Longitude):-
	retract(delivery(IdDelivery,IdSupplier,IdProduct,Quantity,Latitude,_,Time,Downtime)),
	asserta(delivery(IdDelivery,IdSupplier,IdProduct,Quantity,Latitude,Longitude,Time,Downtime)).	

set_delivery_time(IdDelivery,Time):-
	retract(delivery(IdDelivery,IdSupplier,IdProduct,Quantity,Latitude,Longitude,_,Downtime)),
	asserta(delivery(IdDelivery,IdSupplier,IdProduct,Quantity,Latitude,Longitude,Time,Downtime)).

set_delivery_downtime(IdDelivery,Downtime):-
	retract(delivery(IdDelivery,IdSupplier,IdProduct,Quantity,Latitude,Longitude,Time,_)),
	asserta(delivery(IdDelivery,IdSupplier,IdProduct,Quantity,Latitude,Longitude,Time,Downtime)).


/*
 |=======================|
 |   RANDOM PREDICATES   |
 |=======================|
*/

random_order(IdProduct, Quantity) :-
    random(1,61,IdProduct),
    random(20,81,Quantity),
    product(IdProduct,Name,_,_),
    write('Commande client du produit "['),write(IdProduct),write('] '),write(Name),write('" pour une quantité de '), write(Quantity),write('.'),nl.

random_event(IdEvent, Latitude, Longitude):-
    random(1,21,IdEvent),
    random(0,101,Latitude),
    random(0,101,Longitude).

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
	QuantityAsked =< Quantity.


/*
 |====================|
 |   GUI PREDICATES   |
 |====================|
*/

add_into_list([], L, [L]).
add_into_list(X, L, [X|L]).


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
	    supplier(IdSupplier ,Name, Products, Mark),
	    (
	        atomic_concat('[',IdSupplier, A),
	        atomic_concat(A,'] ', B),
	        atomic_concat(B, Name, C),
	        atomic_concat(C,' - (Coordinates = [', D),
	        atomic_list_concat(Products,', ', Atom),
	        atomic_concat(D, Atom, E),
	        atomic_concat(E,']) - Note: [', F),
	        atomic_concat(F,Mark, G),
	        atomic_concat(G,'/10]', String),
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


get_waiting_orders_for_view(ListString):-
    get_waiting_orders_for_view_rec([],ListString).

get_waiting_orders_for_view_rec(EmptyList,ListString):-
    asserta(listTmp(2,EmptyList)),
    (
        waiting_order(_,_,_)
    ->
        forall(
        	    waiting_order(IdProduct ,Quantity, NbrDays),
        	    (
        	        product(IdProduct,Name,_,QuantityRemaining),
        	        atomic_concat('Produit "[',IdProduct, A),
        	        atomic_concat(A,'] ', B),
        	        atomic_concat(B, Name, C),
        	        atomic_concat(C,'" - Qté Commandé = [', D),
        	        atomic_concat(D, Quantity, E),
        	        atomic_concat(E,'] - Qté en stock = [', F),
        	        atomic_concat(F, QuantityRemaining, G),
        	        atomic_concat(G,']', H),
        	        atomic_concat(H,' - Nbr jours en attente = [', I),
        	        atomic_concat(I, NbrDays, J),
        	        atomic_concat(J,']', String),
        	        retract(listTmp(2, List)),
                    add_into_list(List, String, Return),
                    asserta(listTmp(2, Return))
        	    )
        	)
        ;
        retract(listTmp(2, List)),
        add_into_list(List, 'Aucune commande client en attente', Return),
        asserta(listTmp(2, Return))
    ),
    retract(listTmp(2,ListString)).


get_deliveries_for_view(ListString):-
    get_deliveries_for_view_rec([],ListString).

get_deliveries_for_view_rec(EmptyList,ListString):-
    asserta(listTmp(2,EmptyList)),
    (
        delivery(_, _, _, _, _, _,_, _)
    ->
        forall(
        	    delivery(_, _, IdProduct, Quantity, _, _, Time, Downtime),
        	    (
        	        product(IdProduct,Name, _, _),
        	        atomic_concat('Livraison fournisseur du produit "[',IdProduct, A),
        	        atomic_concat(A,'] ', B),
        	        atomic_concat(B, Name, C),
        	        atomic_concat(C,'" - Qté Commandé = [', D),
        	        atomic_concat(D, Quantity, E),
        	        atomic_concat(E,'] - Distance = [', F),
        	        atomic_concat(F, Time, G),
        	        atomic_concat(G,']', H),
        	        atomic_concat(H,' - Nbr jours bloqués restants = [', I),
        	        atomic_concat(I, Downtime, J),
        	        atomic_concat(J,']', String),
        	        retract(listTmp(2, List)),
                    add_into_list(List, String, Return),
                    asserta(listTmp(2, Return))
        	    )
        	)
        ;
        retract(listTmp(2, List)),
        add_into_list(List, 'Aucune livraison fournisseur en attente', Return),
        asserta(listTmp(2, Return))
    ),
    retract(listTmp(2,ListString)).