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
	distance(ID_Supplier, Distance):-
		supplier(ID_Supplier, _, [Latitude_supplier|Longitude_supplier]),
		Latitude is abs(Latitude_supplier-50),
		Longitude is abs(Longitude_supplier-50),
*/
		