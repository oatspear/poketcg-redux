CharizardCard:
	db TYPE_PKMN_FIRE ; type
	gfx CharizardCardGfx ; gfx
	tx CharizardName ; name
	db STAR ; rarity
	db EVOLUTION | NONE ; sets
	db CHARIZARD
	db 110 ; hp
	db STAGE2 ; stage
	tx CharmeleonName ; pre-evo name

	; attack 1
	energy FIRE, 1 ; energies
	tx FlameCloakName ; name
	tx Attach1FireEnergyFromDiscardDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_NORMAL ; category
	dw Attach1FireEnergyFromDiscardEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db SPECIAL_AI_HANDLING ; flags 3
	db 1
	db ATK_ANIM_BIG_FLAME ; animation

	; attack 2
	energy FIRE, 2, COLORLESS, 1 ; energies
	tx FireBlastName ; name
	tx Discard2EnergiesDescription ; description
	dw NONE ; description (cont)
	db 110 ; damage
	db DAMAGE_NORMAL ; category
	dw Discard2EnergiesEffectCommands ; effect commands
	db NONE ; flags 1
	db DISCARD_ENERGY ; flags 2
	db NONE ; flags 3
	db 6
	db ATK_ANIM_FIRE_SPIN ; animation

	db 2 ; retreat cost
	db WR_WATER ; weakness
	db WR_FIGHTING ; resistance
	tx FlameName ; category
	db 6 ; Pokedex number
	db 0
	db 76 ; level
	db 5, 7 ; length
	dw 200 * 10 ; weight
	tx CharizardDescription ; description
	db 0
