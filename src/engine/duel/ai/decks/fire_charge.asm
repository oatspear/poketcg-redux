AIActionTable_FireCharge:
	dw .do_turn ; unused
	dw .do_turn
	dw .start_duel
	dw .forced_switch
	dw .ko_switch
	dw .take_prize

.do_turn
	call AIMainTurnLogic
	ret

.start_duel
	call InitAIDuelVars
	call .store_list_pointers
	call SetUpBossStartingHandAndDeck
	call TrySetUpBossStartingPlayArea
	ret nc
	call AIPlayInitialBasicCards
	ret

.forced_switch
	call AIDecideBenchPokemonToSwitchTo
	ret

.ko_switch
	call AIDecideBenchPokemonToSwitchTo
	ret

.take_prize
	call AIPickPrizeCards
	ret

.list_arena
	db JIGGLYPUFF
	db CHANSEY
	db TAUROS
	db MAGMAR_LV24
	db GROWLITHE
	db $00

.list_bench
	db JIGGLYPUFF
	db CHANSEY
	db GROWLITHE
	db MAGMAR_LV24
	db TAUROS
	db $00

.list_retreat
	ai_retreat JIGGLYPUFF,      -1
	ai_retreat CHANSEY,         -1
	ai_retreat GROWLITHE,       -1
	db $00

.list_energy
	ai_energy GROWLITHE,       3, +0
	ai_energy ARCANINE_LV45,   4, +0
	ai_energy MAGMAR_LV24,     3, +0
	ai_energy JIGGLYPUFF,      2, +0
	ai_energy WIGGLYTUFF_LV36, 3, +0
	ai_energy CHANSEY,         4, +0
	ai_energy TAUROS,          3, +0
	db $00

.list_prize
	db ROCKET_HEADQUARTERS
	db $00

.store_list_pointers
	store_list_pointer wAICardListAvoidPrize, .list_prize
	store_list_pointer wAICardListArenaPriority, .list_arena
	store_list_pointer wAICardListBenchPriority, .list_bench
	store_list_pointer wAICardListPlayFromHandPriority, .list_bench
	store_list_pointer wAICardListRetreatBonus, .list_retreat
	store_list_pointer wAICardListEnergyBonus, .list_energy
	ret
