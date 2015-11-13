/* 
	Products 
product(id, name, suppliers [], quantity). 
*/

:- dynamic(product/4).
:- dynamic(supplier/3).
:- dynamic(event/4).

product(1, alternateurT1, [1,2,3,4,50], 100).
product(2, alternateurT2, [1,2,3,4], 100).
product(3, alternateurT3, [1,2,3,4], 100).
product(4, alternateurT4, [1,2,3,4,50], 100).
product(5, alternateurT5, [1,2,3,4], 100).

product(6, demarreurT1, [6,7,8,9], 100).
product(7, demarreurT2, [6,7,8,9,50], 100).
product(8, demarreurT3, [6,7,8,9], 100).
product(9, demarreurT4, [6,7,8,9], 100).
product(10, demarreurT5, [6,7,8,9,50], 100).

product(11, amortisseurT1, [10,11,12,13,50], 100).
product(12, amortisseurT2, [10,11,12,13], 100).
product(13, amortisseurT3, [10,11,12,13,50], 100).
product(14, amortisseurT4, [10,11,12,13], 100).
product(15, amortisseurT5, [10,11,12,13,50], 100).

product(16, suspensionT1, [14,15,16,17], 100).
product(17, suspensionT2, [14,15,16,17,50], 100).
product(18, suspensionT3, [14,15,16,17], 100).
product(19, suspensionT4, [14,15,16,17,50], 100).
product(20, suspensionT5, [14,15,16,17], 100).

product(21, batterieT1, [18,19,20,21], 100).
product(22, batterieT2, [18,19,20,21,50], 100).
product(23, batterieT3, [18,19,20,21], 100).
product(24, batterieT4, [18,19,20,21,50], 100).
product(25, batterieT5, [18,19,20,21,50], 100).

product(26, bougieT1, [22,23,24,25,50], 100).
product(27, bougieT2, [22,23,24,25,50], 100).
product(28, bougieT3, [22,23,24,25,50], 100).
product(29, bougieT4, [22,23,24,25,50], 100).
product(30, bougieT5, [22,23,24,25,50], 100).

product(31, pneuT1, [26,27,28,29], 100).
product(32, pneuT2, [26,27,28,29,50], 100).
product(33, pneuT3, [26,27,28,29], 100).
product(34, pneuT4, [26,27,28,29,50], 100).
product(35, pneuT5, [26,27,28,29], 100).

product(36, retroviseurT1, [30,31,32,33], 100).
product(37, retroviseurT2, [30,31,32,33,50], 100).
product(38, retroviseurT3, [30,31,32,33], 100).
product(39, retroviseurT4, [30,31,32,33,50], 100).
product(40, retroviseurT5, [30,31,32,33], 100).

product(41, parebriseT1, [34,35,36,37,50], 100).
product(42, parebriseT2, [34,35,36,37], 100).
product(43, parebriseT3, [34,35,36,37,50], 100).
product(44, parebriseT4, [34,35,36,37], 100).
product(45, parebriseT5, [34,35,36,37,50], 100).

product(46, radiateurT1, [38,39,40,41], 100).
product(47, radiateurT2, [38,39,40,41,50], 100).
product(48, radiateurT3, [38,39,40,41,50], 100).
product(49, radiateurT4, [38,39,40,41], 100).
product(50, radiateurT5, [38,39,40,41,50], 100).

product(51, duriteT1, [42,43,44,45,50], 100).
product(52, duriteT2, [42,43,44,45,50], 100).
product(53, duriteT3, [42,43,44,45,50], 100).
product(54, duriteT4, [42,43,44,45], 100).
product(55, duriteT5, [42,43,44,45,50], 100).

product(56, moteurT1, [46,47,48,49,50], 100).
product(57, moteurT2, [46,47,48,49], 100).
product(58, moteurT3, [46,47,48,49], 100).
product(59, moteurT4, [46,47,48,49,50], 100).
product(60, moteurT5, [46,47,48,49,50], 100).

/*
	Suppliers
supplier(id, name, location []).
*/

supplier(1, abax, [0,0]).
supplier(2, aspock, [0,0]).
supplier(3, acimex, [0,0]).
supplier(4, bardhal, [0,0]).
supplier(5, bendix, [0,0]).
supplier(6, brink, [0,0]).
supplier(7, champion, [0,0]).
supplier(8, cipa, [0,0]).
supplier(9, colaert, [0,0]).
supplier(10, denso, [0,0]).
supplier(11, diframa, [0,0]).
supplier(12, doga, [0,0]).
supplier(13, electrifil, [0,0]).
supplier(14, eram, [0,0]).
supplier(15, faab, [0,0]).
supplier(16, ferodo, [0,0]).
supplier(17, fichet, [0,0]).
supplier(18, francefix, [0,0]).
supplier(19, gabriel, [0,0]).
supplier(20, gys, [0,0]).
supplier(21, haacon, [0,0]).
supplier(22, haldex, [0,0]).
supplier(23, hitachi, [0,0]).
supplier(24, iskra, [0,0]).
supplier(25, jonesco, [0,0]).
supplier(26, jost, [0,0]).
supplier(27, klaxcar, [0,0]).
supplier(28, knorr, [0,0]).
supplier(29, loni, [0,0]).
supplier(30, lumho, [0,0]).
supplier(31, lecoy, [0,0]).
supplier(32, lugdunum, [0,0]).
supplier(33, luk, [0,0]).
supplier(34, meiwa, [0,0]).
supplier(35, mekra, [0,0]).
supplier(36, mga, [0,0]).
supplier(37, muller, [0,0]).
supplier(38, netman, [0,0]).
supplier(39, ngk, [0,0]).
supplier(40, norton, [0,0]).
supplier(41, osram, [0,0]).
supplier(42, promauto, [0,0]).
supplier(43, raufoss, [0,0]).
supplier(44, ringfeder, [0,0]).
supplier(45, rockinger, [0,0]).
supplier(46, rubbolite, [0,0]).
supplier(47, sachs, [0,0]).
supplier(48, sicli, [0,0]).
supplier(49, siepa, [0,0]).
supplier(50, sifam, [0,0]).


/*
	Events
event(id, name, impact, radius).
*/

event(1, tornade, 0, 0).
event(2, tsunami, 0, 0).
event(3, innondations, 0, 0).
event(4, eruption_volcanique, 0, 0).
event(5, tempete, 0, 0).
event(6, tremblement_de_terre, 0, 0).
event(7, guerre_civile, 0, 0).
event(8, conflit_majeur, 0, 0).
event(9, conflit_mineur, 0, 0).
event(10, panne_courant, 0, 0).
event(11, incendie, 0, 0).
event(12, meteorite, 0, 0).
event(13, chute_boursiere, 0, 0).
event(14, attaque_terroriste, 0, 0).
event(15, accident_voitures, 0, 0).
event(16, accident_avion, 0, 0).
event(17, augmentation_taxes, 0, 0).
event(18, braquage, 0, 0).
event(19, scandale_pollution, 0, 0).
event(20, bouchons, 0, 0).
