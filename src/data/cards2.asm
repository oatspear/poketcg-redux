AltCardPointers:
	table_width 2, CardPointers
	dw NULL
	dw GrassyTerrainCard
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

