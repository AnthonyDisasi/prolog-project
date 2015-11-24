/*
    Day plus one import from rules.pl with XPCE managing removed
*/
day_plus_one:-
    upgrade_suppliers_marks,
    advancement_deliveries,
    daily_event,
    daily_order,
    check_waiting_list,
    write('--------------------------------------'),
    nl.

/*
    Predicate making necessary consults
*/
consults:-
    consult(datas),
    consult(rules).

/*
    Statistics predicate 'stats'
    Return = printing some statistics in console log
*/
stats:-
    consults,
    set_context_statistics,
    make_simulation,
    print_statistics.

/*
    Initialization of the context
    Dynamic entities:
        `test_nbr_loops` --> (Id, NbrLoops)
        `days_with_waiting_orders_tmp` --> (Id, NbrDays)
        `average_waiting_order_tmp` --> (Id, Addition)
*/

:-dynamic(days_with_waiting_orders_tmp/2).
:-dynamic(test_nbr_loops/2).
:-dynamic(average_waiting_order_tmp/2).
:-dynamic(supplier_average/2).

set_context_statistics:-
    asserta(test_nbr_loops(1,100)),
    asserta(days_with_waiting_orders_tmp(1,0)),
    asserta(average_waiting_order_tmp(1,0)),
    init_suppliers.

init_suppliers:-
    forall(
        supplier(IdSupplier,_,_,Mark),
        (
            asserta(supplier_average(IdSupplier,Mark))
        )
    ).

/*
    Making simulation on test_nbr_loops` days using rules predicates (rules.pl), still diplaying console logs but not XPCE GUI.
*/
make_simulation:-
	stats_rec(0).

stats_rec(100):-!.
stats_rec(X):-
	day_plus_one,
    waiting_list_stats,
    suppliers_stats,
	Y is X+1,
	stats_rec(Y).

/*
    Managing waiting orders statistics. Those predicates are called every day of the simulation to actualize dynamics variables.
*/
waiting_list_stats:-
    days_with_waiting_orders,
    average_waiting_order.

days_with_waiting_orders:-
    (
    waiting_order(_,_,_)
    ->
    retract(days_with_waiting_orders_tmp(1,NbrDays)),
    NewNbrDays is NbrDays + 1,
    asserta(days_with_waiting_orders_tmp(1,NewNbrDays))
    ;
    retract(days_with_waiting_orders_tmp(1,NbrDays)),
    asserta(days_with_waiting_orders_tmp(1,NbrDays))
    ).

:-dynamic(addition_tmp/2).
average_waiting_order:-
    (
    waiting_order(_,_,_)
    ->
    retract(average_waiting_order_tmp(1,Addition)),
    asserta(addition_tmp(1,0)),
    forall(
        waiting_order(_,_,_)
        ,
        (
        retract(addition_tmp(1,Value)),
        NewValue is Value + 1,
        asserta(addition_tmp(1,NewValue))
        )
    ),
    retract(addition_tmp(1,FinalValue)),
    NewAddition is Addition + FinalValue,
    asserta(average_waiting_order_tmp(1,NewAddition))
    ;
    retract(average_waiting_order_tmp(1,Addition)),
    asserta(average_waiting_order_tmp(1,Addition))
    ).

/*
    Managing suppliers statistics. Those predicates are called every day of the simulation to actualize dynamics variables.
*/
suppliers_stats:-
    forall(
        supplier(IdSupplier,_,_,Mark)
        ,
        (
            retract(supplier_average(IdSupplier,Addition)),
            NewAddition is Addition + Mark,
            asserta(supplier_average(IdSupplier,NewAddition))
        )
    ).

/*
    Print all availables statistics
*/
print_statistics:-
    nl,write('------------------------------------'),nl,
    write('Statistiques concernant les commandes client en attente:'),nl,
    days_with_waiting_orders_tmp(1,NbrDays),
    test_nbr_loops(1,NbrLoops),
    Pourcentage is NbrDays / NbrLoops * 100,
    write('\t'),write('--> Nombre de jours avec au moins une commande client en attente: ['),write(NbrDays),write('/'),write(NbrLoops),write('] - Pourcentage: ['),write(Pourcentage),write('%]'),nl,
    average_waiting_order_tmp(1,Addition),
    Average is Addition / NbrLoops,
    write('\t'),write('--> Nombre moyen de commandes en attente est de: ['),write(Addition),write('/'),write(NbrLoops),write('] - Par jour: ['),write(Average),write('/j]'),nl,
    write('**'),nl,



    write('Statistiques concernant les fournisseurs:'),nl,

    get_best_low_average_supplier_statistics(IdBestSupplier,BestMark,IdLowestSupplier,LowestMark,AverageSupplierMark),
    write('\t'),write('--> Note de fiabilité fournisseur la plus haute: [Id Fourn][Moy/10] = ['),write(IdBestSupplier),write('] ['),write(BestMark),write('/10]'),nl,
    write('\t'),write('--> Note de fiabilité fournisseur la plus basse: [Id Fourn][Moy/10] = ['),write(IdLowestSupplier),write('] ['),write(LowestMark),write('/10]'),nl,
    write('\t'),write('--> Moyenne des notes de fiabilité fournisseur: [Note/10] = ['),write(AverageSupplierMark),write('/10]'),nl,
    write('**'),nl,




    write('Statistiques concernant les livraisons des fournisseurs:'),nl,
    write('**'),nl,
    write('Statistiques concernant les produits:'),nl.

:-dynamic(best_supplier/3).
:-dynamic(lowest_supplier/3).
:-dynamic(final_average_suppliers/2).
get_best_low_average_supplier_statistics(IdBestSupplier,BestMark,IdLowestSupplier,LowestMark,Average):-
    supplier_average(1,InitAddition),
    asserta(best_supplier(1,1,InitAddition)),
    asserta(lowest_supplier(1,1,InitAddition)),
    asserta(final_average_suppliers(1,0)),
    forall(
        supplier_average(IdSupplier,AdditionFinal)
        ,
        (
            write(AdditionFinal),nl,
            best_supplier(1,_, BestMarkTmp),
            (
                AdditionFinal > BestMarkTmp
                ->
                retract(best_supplier(1,_, _)),
                asserta(best_supplier(1,IdSupplier, AdditionFinal));
                !
            ),
            lowest_supplier(1,_, LowerMarkTmp),
            (
                AdditionFinal < LowerMarkTmp
                ->
                retract(lowest_supplier(1,_, _)),
                asserta(lowest_supplier(1,IdSupplier, AdditionFinal));
                !
            ),
            retract(final_average_suppliers(1,ValueTmp)),
            NewValue is ValueTmp + AdditionFinal,
            asserta(final_average_suppliers(1,NewValue))
        )
    ),
    retract(best_supplier(1,IdBestSupplier, BestAddition)),
    retract(lowest_supplier(1,IdLowestSupplier, LowestAddition)),
    retract(final_average_suppliers(1,AverageTmp)),
    test_nbr_loops(1,NbrLoops),
    BestMark is BestAddition / NbrLoops,
    LowestMark is LowestAddition / NbrLoops,
    write(AverageTmp),nl,
    Average is AverageTmp / (49 * NbrLoops).