:- dynamic(waiting_order/3).
:- dynamic(is_empty_waiting_list/2).
:- dynamic(listTmp/2).
:- dynamic(supplierTmp/3).

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

/*
    Day Plus One Function
*/

day_plus_one(Dialog) :-
    set_new_day(Dialog),
    upgrade_suppliers_marks,
    advancement_deliveries,
    daily_event,
    daily_order,
    check_waiting_list,
    write('--------------------------------------'),
    nl.

/*
    Setting +1 to every suppliers marks
*/
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
    Days Management
*/

set_new_day(Dialog) :-
    retract(context(OldNumDay)),
    NewNumDay is OldNumDay + 1,
    asserta(context(NewNumDay)),

    get(Dialog, member('stringday'), Output),
    atomic_concat('','Jour ',StringTmp),
    atomic_concat(StringTmp, NewNumDay, StringDay),
    send(Output, selection, StringDay),
    write('Changement de jour: '),write(NewNumDay),
    nl.

/*
    Waiting list Management
*/
check_waiting_list:-
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
    Client Orders Management
    Random order + (if stock is ok then decrease stock else addition in waiting_list) + Best supplier research + create new delivery
*/


daily_order :-
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
    Random predicates
        (1) random_order --> Idproduct [1-60], Quantity [20-80]
        (2) random_event --> IdEvent [1-20], AxisX [0-100], AxisY [0-100]
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


/**********************EVENT******************************/

daily_event:-
	random_event(IdEvent, Latitude, Longitude),
	impact_event(IdEvent, Latitude, Longitude).


/* 

Changer l'affichage des fournisseurs pour un affichage en ligne 
Rajouter un prédicat dynamique pour savoir si on a un fournisseur impacté du genre
fournisseur_impactés()
*/


impact_event(IdEvent,Latitude,Longitude):-
	event(IdEvent,NameEvent,Impact,Radius),
	write('Evenement : '),write(NameEvent),nl,
	write('\t'),write('Latitude : '),write(Latitude),nl,
	write('\t'),write('Longitude : '),write(Longitude),nl,
	write('\t'),write('Impact : '),write(Impact),nl,
	write('\t'),write('Rayon : '),write(Radius),nl,
	forall(supplier(IdSupplier,_,_,_),
	 		(supplier_impacted_by_event(Latitude,Longitude,IdEvent,IdSupplier),!,
	 			impact_supplier(IdSupplier,Impact);!)),
	forall(delivery(IdDelivery,_,_,_,_,_,_,_),
			(delivery_impacted_by_event(Latitude,Longitude,IdEvent,IdDelivery),!,
	 			impact_delivery(IdDelivery,Impact);!)).

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
	supplier(IdSupplier,Name,_,Mark),
	write('Le fournisseur '),write(Name),write(' a été impacté par l évènement.'),nl,
	(Mark > Impact,!,
		NewMark is Mark - Impact;
		NewMark is 0),
	set_supplier_mark(IdSupplier,NewMark).

impact_delivery(IdDelivery,Impact):-
	delivery(IdDelivery,_,_,_,_,_,_,Downtime),
	NewDowntime is Downtime + Impact,
	set_delivery_downtime(IdDelivery,NewDowntime),
	write('La commande fournisseur actuellement en livraison N° '),write(IdDelivery),write(' a été impacté par l évènement.'),nl,
	write('Elle sera immobilisé pendant '), write(Impact), write(' jours.'),nl.


/*********************DELIVERY**************************/


display_delivery(IdDelivery):-
	delivery(IdDelivery,IdSupplier,IdProduct,Quantity,_,_,Time,Downtime),
	product(IdProduct,NameProduct,_,_),
	supplier(IdSupplier,NameSupplier,_,_),
	write('Livraison N° '),write(IdDelivery),nl,
	write('\t'),write('Libelle Produit : '),write(NameProduct),nl,
	write('\t'),write('Quantite : '),write(Quantity),nl,
	write('\t'),write('Fournisseur : '),write(NameSupplier),nl,
	write('\t'),write('Temps d acheminement restant : '),write(Time),nl,
	(Downtime > 0
		-> 	write('\t'),write('Temps d immobilisation : '),write(Downtime),write(' jours'),nl;!).




advancement_deliveries:-
	forall(delivery(IdDelivery,_,_,_,_,_,_,_),
		(move_delivery(IdDelivery),
		delivery(IdDelivery,_,IdProduct,_,_,_,0,_),!,
			delivery_made(IdDelivery),
			write('La livraison N° '),write(IdDelivery),write(' est arrivé.'),nl,
			product(IdProduct,NameProduct,_,Quantity),
			write('Le stock de produit  '),write(NameProduct),write(' est maintenant de '), write(Quantity),nl;!)).

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

create_delivery(IdProduct,Quantity,IdSupplier):-
	supplier(IdSupplier,NameSupplier,[LatitudeSupplier|LongitudeSupp],_),
	LongitudeSupplier is LongitudeSupp,
	product(IdProduct,NameProduct,_,_),
	distance(50,50,LatitudeSupplier,LongitudeSupplier,Dist),
	retract(nbr_deliveries_sent(Nbr)),
	NewNbr is Nbr + 1,
	asserta(nbr_deliveries_sent(NewNbr)),
	asserta(delivery(NewNbr,IdSupplier,IdProduct,Quantity,LatitudeSupplier,LongitudeSupplier,Dist,0)),
	write('Création d une nouvelle commande fournisseur'),nl,
	write('\t'),write('Libelle du produit : '),write(NameProduct),nl,
	write('\t'),write('Quantite : '),write(Quantity),nl,
	write('\t'),write('Fournisseur : '),write(NameSupplier),nl,
	write('\t'),write('Temps d acheminement restant : '),write(Dist),nl.
