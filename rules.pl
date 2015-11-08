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

info_all_products():-
	forall(product(ID,_,_,_),info_product(ID)).

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
		
