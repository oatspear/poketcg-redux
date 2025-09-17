IF POLITOED_VARIANT == 1

ELSE

PolitoedCard:
	db TYPE_PKMN_WATER ; type
	gfx PolitoedCardGfx ; gfx
	tx PolitoedName ; name
	db STAR ; rarity
	db LABORATORY | NONE ; sets
	db POLITOED
	db 130 ; hp
	db STAGE2 ; stage
	tx PoliwhirlName ; pre-evo name

	; attack 1
	energy 0 ; energies
	tx RainDanceName ; name
	tx RainDanceDescription ; description
	tx PokemonPowerDescriptionCont ; description (cont)
	db 0 ; damage
	db POKE_POWER ; category
	dw PassiveAbilityEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_PKMN_POWER_1 ; animation

	; attack 2
	energy WATER, 1, COLORLESS, 2 ; energies
	tx PowerfulSplashName ; name
	tx PowerfulSplashDescription ; description
	dw NONE ; description (cont)
	db 10 ; damage
	db DAMAGE_PLUS ; category
	dw PowerfulSplashEffectCommands ; effect commands
	db NONE ; flags 1
	db ATTACHED_ENERGY_BOOST ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_HYDRO_PUMP ; animation

	db 2 ; retreat cost
	db WR_LIGHTNING ; weakness
	db NONE ; resistance
	tx FrogName ; category
	db 186 ; Pokedex number
	db 0
	db 52 ; level
	db 3, 7 ; length
	dw 74 * 10 ; weight
	tx PolitoedDescription ; description
	db 0

ENDC
