IF MUK_VARIANT == 1

MukCard:
	db TYPE_PKMN_DARKNESS ; type
	gfx MukCardGfx ; gfx
	tx MukName ; name
	db STAR ; rarity
	db LABORATORY | FOSSIL ; sets
	db MUK
	db 90 ; hp
	db STAGE1 ; stage
	tx GrimerName ; pre-evo name

	; attack 1
	energy 0 ; energies
	tx SeepingToxinsName ; name
	tx SeepingToxinsDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db POKE_BODY ; category
	dw PassivePowerEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 1
	db ATK_ANIM_PKMN_POWER_1 ; animation

	; attack 2
	energy DARKNESS, 2, COLORLESS, 1 ; energies
	tx ToxicWasteName ; name
	tx InflictPoisonDescription ; description
	tx ToxicWasteDescriptionCont ; description (cont)
	db 10 ; damage
	db DAMAGE_PLUS ; category
	dw ToxicWasteEffectCommands ; effect commands
	db INFLICT_POISON ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 2
	db ATK_ANIM_GOO ; animation

	db 2 ; retreat cost
	db WR_FIGHTING ; weakness
	db NONE ; resistance
	tx SludgeName ; category
	db 89 ; Pokedex number
	db 0
	db 34 ; level
	db 3, 11 ; length
	dw 66 * 10 ; weight
	tx MukDescription ; description
	db 0

ELSE

MukCard:
	db TYPE_PKMN_DARKNESS ; type
	gfx MukCardGfx ; gfx
	tx MukName ; name
	db STAR ; rarity
	db LABORATORY | FOSSIL ; sets
	db MUK
	db 90 ; hp
	db STAGE1 ; stage
	tx GrimerName ; pre-evo name

	; attack 1
	energy 0 ; energies
	tx SeepingToxinsName ; name
	tx SeepingToxinsDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db POKE_BODY ; category
	dw PassivePowerEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 1
	db ATK_ANIM_PKMN_POWER_1 ; animation

	; attack 2
	energy DARKNESS, 2, COLORLESS, 1 ; energies
	tx ToxicWasteName ; name
	tx InflictPoisonDescription ; description
	tx ToxicWasteDescriptionCont ; description (cont)
	db 10 ; damage
	db DAMAGE_PLUS ; category
	dw ToxicWasteEffectCommands ; effect commands
	db INFLICT_POISON ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 2
	db ATK_ANIM_GOO ; animation

	db 2 ; retreat cost
	db WR_FIGHTING ; weakness
	db NONE ; resistance
	tx SludgeName ; category
	db 89 ; Pokedex number
	db 0
	db 34 ; level
	db 3, 11 ; length
	dw 66 * 10 ; weight
	tx MukDescription ; description
	db 0

ENDC
