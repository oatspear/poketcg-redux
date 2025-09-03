AltCardPointers:
	table_width 2, CardPointers
	dw NULL
	dw GrassyTerrainCard
	dw MysteriousFossilPokemonCard
	dw NULL
	assert_table_length NUM_CARDS_ALT + 2

; ------------------------------------------------------------------------------

GrassyTerrainCard:
	db TYPE_TRAINER_STADIUM ; type
	gfx GrassEnergyCardGfx ; gfx
	tx GrassyTerrainName ; name
	db CIRCLE ; rarity
	db NONE | NONE ; sets
	db GRASS_ENERGY
	dw StadiumCardEffectCommands ; effect commands
	tx GrassyTerrainStadiumDescription ; description
	dw NONE ; description (cont)


MysteriousFossilPokemonCard:
	db TYPE_PKMN_COLORLESS ; type
	gfx MysteriousFossilCardGfx ; gfx
	tx MysteriousFossilName ; name
	db CIRCLE ; rarity
	db MYSTERY | FOSSIL ; sets
	db MYSTERIOUS_FOSSIL
	db 20 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy 0 ; energies
	tx DiscardName ; name
	tx DiscardDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db POKE_POWER ; category
	dw TrainerCardAsPokemonEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db NONE ; animation

	; attack 2
	energy 0 ; energies
	dw NONE ; name
	dw NONE ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db DAMAGE_NORMAL ; category
	dw NONE ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db NONE ; animation

	db UNABLE_RETREAT ; retreat cost
	db NONE ; weakness
	db NONE ; resistance
	tx FossilName ; category
	db 0 ; Pokedex number
	db 0
	db 0 ; level
	db 1, 6 ; length
	dw 23 * 10 ; weight
	tx MysteriousFossilPokemonDescription ; description
	db 0
