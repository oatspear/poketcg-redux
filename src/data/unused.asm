

SteamrollerDescription:
	text "This attack does 10 more damage for"
	line "each <WATER> or <FIGHTING> energy attached"
	line "to this Pokémon. If this attack"
	line "Knocks Out the Defending Pokémon,"
	line "do the excess damage to 1 of the"
	line "opponent's Benched Pokémon."
	done

; SteamrollerDescription:
; 	text "This attack does <FIGHTING> damage to the"
; 	line "Defending Pokémon. In addition,"
; 	line "this attack does 20 damage to 1 of"
; 	line "your opponent's Benched Pokémon."
; 	done

; New attack: **Steamroller** (CCC): 40 damage; +10 damage for each attached Water or Fighting Energy; excess damage goes to 1 Benched Pokémon.

; attack 2
energy COLORLESS, 3 ; energies
tx SteamrollerName ; name
tx SteamrollerDescription ; description
tx NoWeaknessResistanceForBenchDescriptionCont ; description (cont)
db 40 ; damage
db DAMAGE_PLUS ; category
dw SteamrollerEffectCommands ; effect commands
db DAMAGE_TO_OPPONENT_BENCH ; flags 1
db ATTACHED_ENERGY_BOOST ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_HIT ; animation



ReduceDamageTakenBy20Description:
	text "Reduce all damage done by attacks"
	line "to this Pokémon during your"
	line "opponent's next turn by 20 (after"
	line "applying Weakness and Resistance)."
	done

; attack 1
energy COLORLESS, 1 ; energies
tx WithdrawName ; name
tx ReduceDamageTakenBy20Description ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw ReduceDamageTakenBy20EffectCommands ; effect commands
db NONE ; flags 1
db NULLIFY_OR_WEAKEN_ATTACK ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_PROTECT ; animation




FindIceName:
	text "Find Ice"
	done

; attack 1
energy COLORLESS, 1 ; energies
tx FindIceName ; name
tx WaterReserveDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw WaterReserveEffectCommands ; effect commands
db DRAW_CARD ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_GLOW_EFFECT ; animation



IceBeamName:
	text "Ice Beam"
	done

IceBeamDescriptionCont:
	text "If there are none, the Defending"
	line "Pokémon is now Paralyzed."
	done


; attack 1
energy WATER, 1, COLORLESS, 1 ; energies
tx IceBeamName ; name
tx Discard1EnergyFromTargetDescription ; description
tx IceBeamDescriptionCont ; description (cont)
db 20 ; damage
db DAMAGE_NORMAL ; category
dw IceBeamEffectCommands ; effect commands
db INFLICT_PARALYSIS ; flags 1
db NONE ; flags 2
db SPECIAL_AI_HANDLING ; flags 3
db 3
db ATK_ANIM_BEAM ; animation

; attack 2
energy WATER, 2, COLORLESS, 1 ; energies
tx BlizzardName ; name
tx DamageOpponentBench10Description ; description
tx NoWeaknessResistanceForBenchDescriptionCont ; description (cont)
db 30 ; damage
db DAMAGE_NORMAL ; category
dw DamageAllOpponentBenched10EffectCommands ; effect commands
db DAMAGE_TO_OPPONENT_BENCH ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 10
db ATK_ANIM_BLIZZARD ; animation



; attack 2
energy PSYCHIC, 1, COLORLESS, 1 ; energies
tx HypnoblastName ; name
tx InflictSleepDescription ; description
dw NONE ; description (cont)
db 20 ; damage
db DAMAGE_NORMAL ; category
dw InflictSleepEffectCommands ; effect commands
db INFLICT_SLEEP ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_HYPNOSIS ; animation



; attack 2
energy PSYCHIC, 1 ; energies
tx ConfuseRayName ; name
tx InflictConfusionDescription ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_NORMAL ; category
dw InflictConfusionEffectCommands ; effect commands
db INFLICT_CONFUSION ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_CONFUSE_RAY ; animation


; attack 2
energy PSYCHIC, 1, COLORLESS, 1 ; energies
tx InvadeMindName ; name
tx InvadeMindDescription ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_PLUS ; category
dw InvadeMindEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_PSYCHIC_HIT ; animation



; attack 1
energy 0 ; energies
tx ProphecyName ; name
tx ProphecyDescription ; description
tx PokemonPowerDescriptionCont ; description (cont)
db 0 ; damage
db POKEMON_POWER ; category
dw ProphecyEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_PKMN_POWER_1 ; animation


; attack 1
energy COLORLESS, 1 ; energies
tx LunarPowerName ; name
tx PokemonBreederDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw LunarPowerEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db SPECIAL_AI_HANDLING ; flags 3
db 0
db ATK_ANIM_GLOW_EFFECT ; animation


; attack 2
energy WATER, 1, COLORLESS, 2 ; energies
tx PrimalSwirlName ; name
tx PrimalSwirlDescription ; description
dw NONE ; description (cont)
db 50 ; damage
db DAMAGE_NORMAL ; category
dw PrimalSwirlEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_WHIRLPOOL ; animation


; attack 1
energy COLORLESS, 1 ; energies
tx ThiefName ; name
tx ThiefDescription ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_NORMAL ; category
dw ThiefEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_HIT ; animation



; attack 1
energy WATER, 1, COLORLESS, 1 ; energies
tx SpiralDrainName ; name
tx Heal20DamageDescription ; description
dw NONE ; description (cont)
db 40 ; damage
db DAMAGE_NORMAL ; category
dw Leech20DamageEffectCommands ; effect commands
db NONE ; flags 1
db HEAL_USER ; flags 2
db NONE ; flags 3
db 2
db ATK_ANIM_DRAIN ; animation



; attack 1
energy FIGHTING, 1 ; energies
tx PrimalScytheName ; name
tx PrimalScytheDescription ; description
dw NONE ; description (cont)
db 30 ; damage
db DAMAGE_PLUS ; category
dw PrimalScytheEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_TEAR ; animation

; attack 2
energy FIGHTING, 1, COLORLESS, 2 ; energies
tx SharpSickleName ; name
tx SharpSickleDescription ; description
dw NONE ; description (cont)
db 60 ; damage
db DAMAGE_PLUS ; category
dw SharpSickleEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 2
db ATK_ANIM_MULTIPLE_SLASH ; animation





DeepDiveName:
	text "Deep Dive"
	done

DeepDiveDescription:
	text "Heal 30 damage from this Pokémon"
	line "and Switch it with 1 of your"
	line "Benched Pokémon."
	done

; attack 1
energy WATER, 1 ; energies
tx DeepDiveName ; name
tx DeepDiveDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw DeepDiveEffectCommands ; effect commands
db NONE ; flags 1
db HEAL_USER ; flags 2
db SPECIAL_AI_HANDLING ; flags 3
db 3
db ATK_ANIM_GLOW_EFFECT ; animation



; attack 2
energy WATER, 1, COLORLESS, 1 ; energies
tx SharpshooterName ; name
tx Deal30ToAnyPokemonDescription ; description
tx NoWeaknessResistanceForBenchDescriptionCont ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw Deal30ToAnyPokemonEffectCommands ; effect commands
db DAMAGE_TO_OPPONENT_BENCH ; flags 1
db FLAG_2_BIT_6 ; flags 2
db NONE ; flags 3
db 2
db ATK_ANIM_GLOW_EFFECT ; animation


; attack 2
energy FIRE, 1, COLORLESS, 1 ; energies
tx BurnOutName ; name
tx BurnOutDescription ; description
dw NONE ; description (cont)
db 50 ; damage
db DAMAGE_NORMAL ; category
dw BurnOutEffectCommands ; effect commands
db LOW_RECOIL ; flags 1
db FLAG_2_BIT_7 ; flags 2
db NONE ; flags 3
db 10
db ATK_ANIM_BIG_FLAME ; animation


; attack 2
energy LIGHTNING, 1, COLORLESS, 1 ; energies
tx ThunderSpearName ; name
tx Deal30ToAnyPokemonDescription ; description
tx NoWeaknessResistanceForBenchDescriptionCont ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw Deal30ToAnyPokemonEffectCommands ; effect commands
db DAMAGE_TO_OPPONENT_BENCH ; flags 1
db FLAG_2_BIT_6 ; flags 2
db NONE ; flags 3
db 2
db ATK_ANIM_MAGNETIC_STORM ; animation


; attack 2
energy WATER, 1, COLORLESS, 1 ; energies
tx EnergySwirlName ; name
tx EnergySwirlDescription ; description
dw NONE ; description (cont)
db 20 ; damage
db DAMAGE_NORMAL ; category
dw Bounce1EnergyFromOpponentEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3  | SPECIAL_AI_HANDLING
db 0
db ATK_ANIM_WHIRLPOOL ; animation


; attack 1
energy PSYCHIC, 1 ; energies
tx EnergyAbsorptionName ; name
tx EnergyAbsorptionDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw EnergyAbsorptionEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db SPECIAL_AI_HANDLING ; flags 3
db 0
db ATK_ANIM_GLOW_EFFECT ; animation


; New attack: **Clamp** (CC): 10 damage; increase opponent's retreat cost by 1 and deal +10 damage for each (C) in retreat cost.
; attack 2
energy COLORLESS, 2 ; energies
tx ClampName ; name
tx ConstrictDescription ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_PLUS ; category
dw ConstrictEffectCommands ; effect commands
db NONE ; flags 1
db FLAG_2_BIT_6 ; flags 2
db NONE ; flags 3
db 1
db ATK_ANIM_HIT ; animation


; attack 2
energy WATER, 1, COLORLESS, 1 ; energies
tx ClampName ; name
tx ClampDescription ; description
dw NONE ; description (cont)
db 20 ; damage
db DAMAGE_NORMAL ; category
dw ClampEffectCommands ; effect commands
db INFLICT_PARALYSIS ; flags 1
db DISCARD_ENERGY ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_HIT ; animation


; attack 2
energy WATER, 1, COLORLESS, 1 ; energies
tx ColdCrushName ; name
tx Discard1EnergyFromBothActiveDescription ; description
dw NONE ; description (cont)
db 40 ; damage
db DAMAGE_NORMAL ; category
dw Discard1EnergyFromBothActiveEffectCommands ; effect commands
db NONE ; flags 1
db DISCARD_ENERGY ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_BLIZZARD ; animation



JigglypuffLv12Card:
	db TYPE_PKMN_PSYCHIC ; type
	gfx JigglypuffLv12CardGfx ; gfx
	tx JigglypuffName ; name
	db PROMOSTAR ; rarity
	db PROMOTIONAL | PRO ; sets
	db JIGGLYPUFF_LV12
	db 40 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy COLORLESS, 1 ; energies
	tx CallForFamilyName ; name
	tx CallForFamilyDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw CallForFamilyEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db SPECIAL_AI_HANDLING ; flags 3
	db 0
	db ATK_ANIM_GLOW_EFFECT ; animation

	; attack 2
	energy PSYCHIC, 1 ; energies
	tx LightStepsName ; name
	tx EnergySlideDescription ; description
	dw NONE ; description (cont)
	db 10 ; damage
	db DAMAGE_NORMAL ; category
	dw EnergySlideEffectCommands ; effect commands
	db NONE ; flags 1
	db DISCARD_ENERGY ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_BOYFRIENDS ; animation

	db 0 ; retreat cost
	db WR_DARKNESS ; weakness
	db NONE ; resistance
	tx BalloonName ; category
	db 39 ; Pokedex number
	db 0
	db 12 ; level
	db 1, 8 ; length
	dw 12 * 10 ; weight
	tx JigglypuffDescription ; description
	db 16

; attack 2
energy COLORLESS, 1 ; energies
tx ExpandName ; name
tx ReduceDamageTakenBy10Description ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_NORMAL ; category
dw ReduceDamageTakenBy10EffectCommands ; effect commands
db NONE ; flags 1
db NULLIFY_OR_WEAKEN_ATTACK ; flags 2
db NONE ; flags 3
db 10
db ATK_ANIM_EXPAND ; animation


; attack 2
energy DARKNESS, 1, COLORLESS, 2 ; energies
tx LeechLifeName ; name
tx LeechLifeDescription ; description
dw NONE ; description (cont)
db 30 ; damage
db DAMAGE_NORMAL ; category
dw LeechLifeEffectCommands ; effect commands
db NONE ; flags 1
db HEAL_USER ; flags 2
db NONE ; flags 3
db 3
db ATK_ANIM_DRAIN ; animation


; attack 2
energy WATER, 1, COLORLESS, 1 ; energies
tx AquaBurstName ; name
tx OptionalDiscard1Energy10BonusDamageDescription ; description
dw NONE ; description (cont)
db 20 ; damage
db DAMAGE_PLUS ; category
dw IfDiscardedEnergy10BonusDamageEffectCommands ; effect commands
db NONE ; flags 1
db DISCARD_ENERGY ; flags 2
db NONE ; flags 3
db 3
db ATK_ANIM_WATER_GUN ; animatio


; attack 2
energy WATER, 2, COLORLESS, 2 ; energies
tx RagingStormName ; name
tx DoubleDamageIfMorePrizesDescription ; description
dw NONE ; description (cont)
db 50 ; damage
db DAMAGE_PLUS ; category
dw DoubleDamageIfMorePrizesEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_THUNDERSTORM ; animation
; db ATK_ANIM_WHIRLPOOL ; alt animation


energy COLORLESS, 1 ; energies
	tx HardenName ; name
	tx HardenDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw HardenEffectCommands ; effect commands
	db NONE ; flags 1
	db NULLIFY_OR_WEAKEN_ATTACK ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_PROTECT ; animation


; attack 1
energy COLORLESS, 1 ; energies
tx DefensiveStanceName ; name
tx DefensiveStanceDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw DefensiveStanceEffectCommands ; effect commands
db NONE ; flags 1
db HEAL_USER ; flags 2
db SPECIAL_AI_HANDLING ; flags 3
db 2
db ATK_ANIM_PROTECT ; animation


; attack 2
energy FIGHTING, 1, COLORLESS, 1 ; energies
tx LowKickName ; name
tx ConstrictDescription ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_PLUS ; category
dw ConstrictEffectCommands ; effect commands
db NONE ; flags 1
db FLAG_2_BIT_6 ; flags 2
db NONE ; flags 3
db 1
db ATK_ANIM_HIT ; animation




PoliwhirlCard:
	db TYPE_PKMN_WATER ; type
	gfx PoliwhirlCardGfx ; gfx
	tx PoliwhirlName ; name
	db DIAMOND ; rarity
	db LABORATORY | NONE ; sets
	db POLIWHIRL
	db 70 ; hp
	db STAGE1 ; stage
	tx PoliwagName ; pre-evo name

	; attack 1
	energy 0 ; energies
	tx MudSportName ; name
	tx Retrieve1WaterOrFightingEnergyFromDiscardDescription ; description
	tx PokemonPowerDescriptionCont ; description (cont)
	db 0 ; damage
	db POKEMON_POWER ; category
	dw MudSportEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_PKMN_POWER_1 ; animation

	; attack 2
	energy COLORLESS, 2 ; energies
	tx RainSplashName ; name
	tx DoubleDamageIfAttachedEnergyDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_PLUS ; category
	dw DoubleDamageIfAttachedEnergyEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_WATER_GUN ; animation

	db 1 ; retreat cost
	db WR_LIGHTNING ; weakness
	db NONE ; resistance
	tx TadpoleName ; category
	db 61 ; Pokedex number
	db 0
	db 28 ; level
	db 3, 4 ; length
	dw 44 * 10 ; weight
	tx PoliwhirlDescription ; description
	db 16




KinglerCard:
	db TYPE_PKMN_WATER ; type
	gfx KinglerCardGfx ; gfx
	tx KinglerName ; name
	db DIAMOND ; rarity
	db EVOLUTION | FOSSIL ; sets
	db KINGLER
	db 80 ; hp
	db STAGE1 ; stage
	tx KrabbyName ; pre-evo name

	; attack 1
	energy COLORLESS, 2 ; energies
	tx RendName ; name
	tx Bonus20IfOpponentIsDamagedDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_PLUS ; category
	dw RendEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_HIT ; animation

	; attack 2
	energy WATER, 1, COLORLESS, 2 ; energies
	tx CrabhammerName ; name
	tx CrabhammerDescription ; description
	dw NONE ; description (cont)
	db 40 ; damage
	db DAMAGE_PLUS ; category
	dw CrabhammerEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_HIT ; animation

	db 1 ; retreat cost
	db WR_LIGHTNING ; weakness
	db NONE ; resistance
	tx PincerName ; category
	db 99 ; Pokedex number
	db 0
	db 27 ; level
	db 4, 3 ; length
	dw 132 * 10 ; weight
	tx KinglerDescription ; description
	db 0



SlowpokeLv9Card:
	db TYPE_PKMN_PSYCHIC ; type
	gfx SlowpokeLv9CardGfx ; gfx
	tx SlowpokeName ; name
	db PROMOSTAR ; rarity
	db PROMOTIONAL | PRO ; sets
	db SLOWPOKE_LV9
	db 50 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy PSYCHIC, 1 ; energies
	tx AmnesiaName ; name
	tx AmnesiaDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db DAMAGE_NORMAL ; category
	dw AmnesiaEffectCommands ; effect commands
	db NONE ; flags 1
	db FLAG_2_BIT_6 ; flags 2
	db NONE ; flags 3
	db 2
	db ATK_ANIM_AMNESIA ; animation

	; attack 2
	energy COLORLESS, 2 ; energies
	tx ConfusionWaveName ; name
	tx ConfusionWaveDescription ; description
	dw NONE ; description (cont)
	db 10 ; damage
	db DAMAGE_NORMAL ; category
	dw ConfusionWaveEffectCommands ; effect commands
	db INFLICT_CONFUSION ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_PSYCHIC_HIT ; animation

	db 0 ; retreat cost
	db WR_DARKNESS ; weakness
	db NONE ; resistance
	tx DopeyName ; category
	db 79 ; Pokedex number
	db 0
	db 9 ; level
	db 3, 11 ; length
	dw 79 * 10 ; weight
	tx SlowpokeDescription ; description
	db 19




MeowthLv14Card:
	db TYPE_PKMN_COLORLESS ; type
	gfx MeowthLv14CardGfx ; gfx
	tx MeowthName ; name
	db CIRCLE ; rarity
	db COLOSSEUM | GB ; sets
	db MEOWTH_LV14
	db 50 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy 0 ; energies
	tx LuckyTailsName ; name
	tx LuckyTailsDescription ; description
	tx PokemonPowerDescriptionCont ; description (cont)
	db 0 ; damage
	db POKEMON_POWER ; category
	dw PassivePowerEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_NONE ; animation

	; attack 2
	energy COLORLESS, 1 ; energies
	tx FurySwipesName ; name
	tx FlipUntilTails10xDescription ; description
	dw NONE ; description (cont)
	db 10 ; damage
	db DAMAGE_X ; category
	dw FurySwipesEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_MULTIPLE_SLASH ; animation

	db 0 ; retreat cost
	db WR_FIGHTING ; weakness
	db NONE ; resistance
	tx ScratchCatName ; category
	db 52 ; Pokedex number
	db 0
	db 14 ; level
	db 1, 4 ; length
	dw 9 * 10 ; weight
	tx MeowthDescription ; description
	db 16




MagnemiteLv13Card:
	db TYPE_PKMN_LIGHTNING ; type
	gfx MagnemiteLv13CardGfx ; gfx
	tx MagnemiteName ; name
	db CIRCLE ; rarity
	db COLOSSEUM | NONE ; sets
	db MAGNEMITE_LV13
	db 50 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy COLORLESS, 1 ; energies
	tx MagneticChargeName ; name
	tx MagneticChargeDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw MagneticChargeEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db SPECIAL_AI_HANDLING ; flags 3
	db 0
	db ATK_ANIM_GLOW_EFFECT ; animation

	; attack 2
	energy LIGHTNING, 1, COLORLESS, 1 ; energies
	tx ThundershockName ; name
	tx MayInflictParalysisDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_NORMAL ; category
	dw Paralysis50PercentEffectCommands ; effect commands
	db INFLICT_PARALYSIS ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_THUNDERSHOCK ; animation

	; energy COLORLESS, 1 ; energies
	; tx SonicboomName ; name
	; tx SonicboomDescription ; description
	; dw NONE ; description (cont)
	; db 10 ; damage
	; db DAMAGE_NORMAL ; category
	; dw SonicboomEffectCommands ; effect commands
	; db NONE ; flags 1
	; db NONE ; flags 2
	; db NONE ; flags 3
	; db 0
	; db ATK_ANIM_TEAR ; animation

	db 0 ; retreat cost
	db WR_FIGHTING ; weakness
	db WR_GRASS ; resistance
	tx MagnetName ; category
	db 81 ; Pokedex number
	db 0
	db 13 ; level
	db 1, 0 ; length
	dw 13 * 10 ; weight
	tx MagnemiteDescription ; description
	db 19



PikachuAltLv16Card:
	db TYPE_PKMN_LIGHTNING ; type
	gfx PikachuAltLv16CardGfx ; gfx
	tx PikachuName ; name
	db PROMOSTAR ; rarity
	db PROMOTIONAL | PRO ; sets
	db PIKACHU_ALT_LV16
	db 50 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy COLORLESS, 1 ; energies
	tx CollectName ; name
	tx Draw2CardsDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw Draw2CardsEffectCommands ; effect commands
	db DRAW_CARD ; flags 1
	db NONE ; flags 2
	db SPECIAL_AI_HANDLING ; flags 3
	db 0
	db ATK_ANIM_GLOW_EFFECT ; animation

	; attack 2
	energy COLORLESS, 2 ; energies
	tx SwiftName ; name
	tx SonicboomDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_NORMAL ; category
	dw SonicboomEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_HIT ; animation

	db 0 ; retreat cost
	db WR_FIGHTING ; weakness
	db NONE ; resistance
	tx MouseName ; category
	db 25 ; Pokedex number
	db 0
	db 16 ; level
	db 1, 4 ; length
	dw 13 * 10 ; weight
	tx PikachuDescription ; description
	db 16
