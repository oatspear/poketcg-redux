IF BLASTOISE_VARIANT == 2

BlastoiseCard:
	db TYPE_PKMN_WATER ; type
	gfx BlastoiseCardGfx ; gfx
	tx BlastoiseName ; name
	db STAR ; rarity
	db EVOLUTION | NONE ; sets
	db BLASTOISE
	db 130 ; hp
	db STAGE2 ; stage
	tx WartortleName ; pre-evo name

	; attack 1
	energy 0 ; energies
	tx RainDanceName ; name
	tx RainDanceDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db POKE_POWER ; category
	dw PassivePowerEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_PKMN_POWER_1 ; animation

	; attack 2
	energy COLORLESS, 3 ; energies
	tx HydroCannonName ; name
	tx HydroPumpDescription ; description
	tx ReduceDamageBy20Description ; description (cont)
	db 30 ; damage
	db DAMAGE_PLUS ; category
	dw HydroCannonEffectCommands ; effect commands
	db NONE ; flags 1
	db ATTACHED_ENERGY_BOOST ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_HYDRO_PUMP ; animation

	db 2 ; retreat cost
	db WR_LIGHTNING ; weakness
	db NONE ; resistance
	tx ShellfishName ; category
	db 9 ; Pokedex number
	db 0
	db 52 ; level
	db 5, 3 ; length
	dw 189 * 10 ; weight
	tx BlastoiseDescription ; description
	db 0

ELIF BLASTOISE_VARIANT == 1

BlastoiseCard:
	db TYPE_PKMN_WATER ; type
	gfx BlastoiseCardGfx ; gfx
	tx BlastoiseName ; name
	db STAR ; rarity
	db EVOLUTION | NONE ; sets
	db BLASTOISE
	db 120 ; hp
	db STAGE2 ; stage
	tx WartortleName ; pre-evo name

	; attack 1
	; depends: HandleDefenderDamageReductionEffects
	energy 0 ; energies
	tx SolidShellName ; name
	tx Exoskeleton20Description ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db POKE_BODY ; category
	dw PassivePowerEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_PKMN_POWER_1 ; animation

	; attack 2
	energy COLORLESS, 2 ; energies
	tx HydroCannonName ; name
	tx HydroCannonDescription ; description
	dw NONE ; description (cont)
	db 10 ; damage
	db DAMAGE_PLUS ; category
	dw HydroCannonEffectCommands ; effect commands
	db NONE ; flags 1
	db ATTACHED_ENERGY_BOOST ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_HYDRO_PUMP ; animation

	db 2 ; retreat cost
	db WR_LIGHTNING ; weakness
	db NONE ; resistance
	tx ShellfishName ; category
	db 9 ; Pokedex number
	db 0
	db 52 ; level
	db 5, 3 ; length
	dw 189 * 10 ; weight
	tx BlastoiseDescription ; description
	db 0

ELSE

BlastoiseCard:
	db TYPE_PKMN_WATER ; type
	gfx BlastoiseCardGfx ; gfx
	tx BlastoiseName ; name
	db STAR ; rarity
	db EVOLUTION | NONE ; sets
	db BLASTOISE
	db 110 ; hp
	db STAGE2 ; stage
	tx WartortleName ; pre-evo name

	; attack 1
	energy WATER, 2 ; energies
	tx HydroPumpName ; name
	tx HydroPumpDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_X ; category
	dw HydroPumpEffectCommands ; effect commands
	db NONE ; flags 1
	db ATTACHED_ENERGY_BOOST ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_HYDRO_PUMP ; animation

	; attack 2
	energy WATER, 2, COLORLESS, 1 ; energies
	tx AquaLauncherName ; name
	tx AquaLauncherDescription ; description
	tx NoWeaknessResistanceForBenchDescriptionCont ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw AquaLauncherEffectCommands ; effect commands
	db DAMAGE_TO_OPPONENT_BENCH ; flags 1
	db NULLIFY_OR_WEAKEN_ATTACK ; flags 2
	db NONE ; flags 3
	db 3
	db ATK_ANIM_PROTECT ; animation

	db 2 ; retreat cost
	db WR_LIGHTNING ; weakness
	db NONE ; resistance
	tx ShellfishName ; category
	db 9 ; Pokedex number
	db 0
	db 52 ; level
	db 5, 3 ; length
	dw 189 * 10 ; weight
	tx BlastoiseDescription ; description
	db 0

ENDC
