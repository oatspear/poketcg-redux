

LethargySporesName:
	text "Lethargy Spores"
	done

LethargySporesDescription:
	text "At the end of your turns, if this is"
	line "your Active Pokémon and it has any"
	line "Energies attached to it, leave the"
	line "opponent's Active Pokémon Drowsy."
	done


; attack 1
energy 0 ; energies
tx LethargySporesName ; name
tx LethargySporesDescription ; description
tx PokemonPowerDescriptionCont ; description (cont)
db 0 ; damage
db POKEMON_POWER ; category
dw PassivePowerEffectCommands ; effect commands
db INFLICT_SLEEP ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 1
db ATK_ANIM_POWDER_EFFECT_CHANCE ; animation





; attack 1
energy GRASS, 1 ; energies
tx SporeName ; name
tx InflictSleepDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db DAMAGE_NORMAL ; category
dw InflictSleepEffectCommands ; effect commands
db INFLICT_SLEEP ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_SPORE ; animation

; attack 2
energy GRASS, 1, COLORLESS, 2 ; energies
tx FungalGrowthName ; name
tx LeechLifeDescription ; description
tx InflictSleepDescription ; description (cont)
db 20 ; damage
db DAMAGE_NORMAL ; category
dw FungalGrowthEffectCommands ; effect commands
db INFLICT_SLEEP | HEAL_USER ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_SPORE ; animation




VenomPowderName:
	text "Venom Powder"
	done

; attack 2
energy GRASS, 1 ; energies
tx VenomPowderName ; name
tx InflictConfusionAndPoisonDescription ; description
dw NONE ; description (cont)
db 20 ; damage
db DAMAGE_NORMAL ; category
dw InflictConfusionAndPoisonEffectCommands ; effect commands
db INFLICT_POISON | INFLICT_CONFUSION ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_POWDER_EFFECT_CHANCE ; animation




HealingWindName: ; 631e4 (18:71e4)
	text "Healing Wind"
	done

; attack 1
energy COLORLESS, 1 ; energies
tx HealingWindName ; name
tx Heal20DamageFromAllDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw Heal20DamageFromAllEffectCommands ; effect commands
db NONE ; flags 1
db HEAL_USER ; flags 2
db NONE ; flags 3
db 1
db ATK_ANIM_RECOVER ; animation
; db ATK_ANIM_NONE ; animation




LureDescription:
	text "Switch 1 of your opponent's Benched"
	line "Pokémon with their Active Pokémon."
	line "The new Active Pokémon can't retreat"
	line "during your opponent's next turn."
	done

; attack 1
energy FIRE, 1 ; energies
tx LureName ; name
tx LureDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw LureEffectCommands ; effect commands
db NONE ; flags 1
db SWITCH_OPPONENT_POKEMON ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_LURE ; animation




; attack 2
energy FIRE, 2, COLORLESS, 1 ; energies
tx FireFangName ; name
tx Discard1EnergyFromTargetDescription ; description
dw NONE ; description (cont)
db 30 ; damage
db DAMAGE_NORMAL ; category
dw Discard1EnergyFromOpponentEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db SPECIAL_AI_HANDLING ; flags 3
db 0
db ATK_ANIM_BIG_FLAME ; animation


; attack 1
energy FIRE, 1, COLORLESS, 1 ; energies
tx CombustionName ; name
tx Discard2CardsFromOpponentsDeckDescription ; description
dw NONE ; description (cont)
db 20 ; damage
db DAMAGE_NORMAL ; category
dw Discard2CardsFromOpponentsDeckEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_BIG_FLAME ; animation



ClairvoyanceName:
	text "Clairvoyance"
	done

ClairvoyanceDescription:
	text "Your opponent plays with his or her"
	line "hand face up."
	done

; attack 1
energy 0 ; energies
tx ClairvoyanceName ; name
tx ClairvoyanceDescription ; description
tx PokemonPowerDescriptionCont ; description (cont)
db 0 ; damage
db POKEMON_POWER ; category
dw PassivePowerEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_PKMN_POWER_1 ; animation


NoDamageOrEffectDueToBarrierText: ; 383d3 (e:43d3)
	text "No damage or effect on next Attack"
	line "due to the effects of Barrier."
	done

BarrierDescription:
	text "Discard all Energy cards attached to"
	line "this Pokémon (at least 1). During"
	line "your opponent's next turn, prevent"
	line "all effects of attacks, including"
	line "damage, done to this Pokémon."
	done

; attack 1
energy PSYCHIC, 1, COLORLESS, 1 ; energies
tx BarrierName ; name
tx BarrierDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw BarrierEffectCommands ; effect commands
db NONE ; flags 1
db NULLIFY_OR_WEAKEN_ATTACK | DISCARD_ENERGY ; flags 2
db NONE ; flags 3
db 2
db ATK_ANIM_BARRIER ; animation



RecoverName:
	text "Recover"
	done

RecoverDescription:
	text "Discard an Energy from this Pokémon."
	line "Then, heal all damage from it."
	done

; attack 1
energy PSYCHIC, 1 ; energies
tx RecoverName ; name
tx RecoverDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw RecoverEffectCommands ; effect commands
db NONE ; flags 1
db HEAL_USER | DISCARD_ENERGY | FLAG_2_BIT_6 ; flags 2
db NONE ; flags 3
db 6
db ATK_ANIM_RECOVER ; animation



PsyshockName:
	text "Psyshock"
	done

PsyshockDescription:
	text "If your opponent has 5 or more"
	line "cards in their hand, this attack"
	line "does 20 more damage."
	done

; attack 2
energy PSYCHIC, 1, COLORLESS, 1 ; energies
tx PsyshockName ; name
tx PsyshockDescription ; description
dw NONE ; description (cont)
db 20 ; damage
db DAMAGE_PLUS ; category
dw PsyshockEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_PSYCHIC_HIT ; animation



MimicName:
	text "Mimic"
	done

MimicDescription:
	text "Shuffle your hand into your deck."
	line "Then, draw a number of cards"
	line "equal to the number of cards"
	line "in your opponent's hand."
	done


energy COLORLESS, 1 ; energies
	tx MimicName ; name
	tx MimicDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw MimicEffectCommands ; effect commands
	db DRAW_CARD ; flags 1
	db NONE ; flags 2
	db SPECIAL_AI_HANDLING ; flags 3
	db 0
	db ATK_ANIM_GLOW_EFFECT ; animation



NaturalRemedyName:
	text "Natural Remedy"
	done

NaturalRemedyDescription:
	text "Heal 20 damage and remove all"
	line "Special Conditions from 1 of"
	line "your Pokémon."
	done

; attack 2
energy COLORLESS, 2 ; energies
tx NaturalRemedyName ; name
tx NaturalRemedyDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw NaturalRemedyEffectCommands ; effect commands
db NONE ; flags 1
db HEAL_USER ; flags 2
db NONE ; flags 3
db 30
db ATK_ANIM_GLOW_EFFECT ; animation


GetMadDescription:
	text "Move any number of damage counters"
	line "from your Pokémon to this Pokémon."
	line "If you moved at least 4, prevent all"
	line "damage done to this Pokémon during"
	line "your opponent's next turn."
	done

; attack 1
energy FIGHTING, 1 ; energies
tx GetMadName ; name
tx GetMadDescription ; description
tx OtherEffectsStillHappenDescriptionCont ; description (cont)
db 0 ; damage
db DAMAGE_NORMAL ; category
dw GetMadEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db SPECIAL_AI_HANDLING ; flags 3
db 0
db ATK_ANIM_GLOW_EFFECT ; animation



TailSwingName:
	text "Tail Swing"
	done

TailSwingDescription:
	text "This attack does 20 damage to"
	line "each of your opponent's Benched"
	line "Basic Pokémon."
	done

; attack 1
energy DARKNESS, 1, COLORLESS, 1 ; energies
tx RoutName ; name
tx RoutDescription ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_PLUS ; category
dw RoutEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_HIT ; animation

; attack 2
energy DARKNESS, 1, COLORLESS, 2 ; energies
tx TailSwingName ; name
tx TailSwingDescription ; description
tx NoWeaknessResistanceForBenchDescriptionCont ; description (cont)
db 50 ; damage
db DAMAGE_NORMAL ; category
dw TailSwingEffectCommands ; effect commands
db DAMAGE_TO_OPPONENT_BENCH ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 2
db ATK_ANIM_BIG_HIT ; animation




; - New attack: **Primal Tentacle** (CC): switch in 1 of the opponent's Benched Pokémon; devolve the new Active Pokémon; the new Active Pokémon is unable to evolve or retreat.

PrimalTentacleName:
	text "Primal Tentacle"
	done

PrimalTentacleDescription:
	text "Switch 1 of your opponent's Benched"
	line "Pokémon with their Active Pokémon."
	line "If the new Defending Pokémon is an"
	line "Evolution Pokémon, return the"
	line "highest stage evolution card on that"
	line "Pokémon to your opponent's hand."
	done

PrimalTentacleDescriptionCont:
	text "The new Active Pokémon can't"
	line "retreat or evolve during your"
	line "opponent's next turn."
	done


; attack 1
energy COLORLESS, 2 ; energies
tx PrimalTentacleName ; name
tx PrimalTentacleDescription ; description
tx PrimalTentacleDescriptionCont ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw PrimalTentacleEffectCommands ; effect commands
db NONE ; flags 1
db SWITCH_OPPONENT_POKEMON ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_WHIP_NO_HIT ; animation





PrehistoricPowerDescription:
	text "While this is your Active Pokémon,"
	line "no more Evolution cards can be"
	line "played from either player's hand."
	done

; attack 1
energy 0 ; energies
tx PrehistoricPowerName ; name
tx PrehistoricPowerDescription ; description
tx PokemonPowerDescriptionCont ; description (cont)
db 0 ; damage
db POKEMON_POWER ; category
dw PassivePowerEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_PKMN_POWER_1 ; animation




; - New attack: **Revival Wave** (CC): 20 damage; put a Pokémon card from the discard pile onto the bench; +20 damage if the bench was already full.

RevivalWaveName:
	text "Revival Wave"
	done

RevivalWaveDescription:
	text "Put a Pokémon from your discard"
	line "pile onto your Bench."
	line "If your Bench was already full,"
	line "this attack does 20 more damage."
	done


; attack 2
energy COLORLESS, 2 ; energies
tx RevivalWaveName ; name
tx RevivalWaveDescription ; description
dw NONE ; description (cont)
db 20 ; damage
db DAMAGE_PLUS ; category
dw RevivalWaveEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_WHIRLPOOL ; animation



PrimordialDreamName:
	text "Primordial Dream"
	done

PrimordialDreamDescription:
	text "Once during your turn, you may"
	line "choose a non-Supporter Trainer card"
	line "from your Discard Pile. Transform"
	line "that card into a Mysterious Fossil"
	line "and add it to your hand."
	done


; attack 1
energy 0 ; energies
tx PrimordialDreamName ; name
tx PrimordialDreamDescription ; description
tx PokemonPowerDescriptionCont ; description (cont)
db 0 ; damage
db POKEMON_POWER ; category
dw PrimordialDreamEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_PKMN_POWER_1 ; animation





; attack 1
energy COLORLESS, 1 ; energies
tx CoreRegenerationName ; name
tx CoreRegenerationDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw CoreRegenerationEffectCommands ; effect commands
db DRAW_CARD ; flags 1
db HEAL_USER ; flags 2
db NONE ; flags 3
db 1
db ATK_ANIM_GLOW_EFFECT ; animation



RiptideName:
	text "Riptide"
	done

RiptideDescription:
	text "Shuffle up to 4 Energy cards from"
	line "your discard pile into your deck."
	line "This attack does 10 more damage for"
	line "each Energy card returned this way."
	done


; attack 1
energy WATER, 1, COLORLESS, 1 ; energies
tx RiptideName ; name
tx RiptideDescription ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_PLUS ; category
dw RiptideEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_WHIRLPOOL ; animation



; attack 1
energy 0 ; energies
tx SwimFreelyName ; name
tx SwimFreelyDescription ; description
tx PokemonPowerDescriptionCont ; description (cont)
db 0 ; damage
db POKEMON_POWER ; category
dw SwimFreelyEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_PKMN_POWER_1 ; animation



; attack 1
energy COLORLESS, 1 ; energies
tx RecoverName ; name
tx RecoverDescription ; description
dw NONE ; description (cont)
db 0 ; damage
db RESIDUAL ; category
dw RecoverEffectCommands ; effect commands
db NONE ; flags 1
db DISCARD_ENERGY | HEAL_USER ; flags 2
db NONE ; flags 3
db 7
db ATK_ANIM_RECOVER ; animation


; attack 2
energy WATER, 1, COLORLESS, 1 ; energies
tx HeadacheName ; name
tx UnableToUseItemsDescription ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_NORMAL ; category
dw HeadacheEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_AMNESIA ; animation



SplashingAttacksName:
	text "Splashing Attacks"
	done

SplashingAttacksDescription:
	text "If your Active Pokémon has any"
	line "attached <WATER> Energy, its attacks"
	line "that do damage to the Defending"
	line "Pokémon also do 10 damage to 1 of"
	line "the opponent's Benched Pokémon."
	done


; attack 1
energy 0 ; energies
tx SplashingAttacksName ; name
tx SplashingAttacksDescription ; description
tx PokemonPowerDescriptionCont ; description (cont)
db 0 ; damage
db POKEMON_POWER ; category
dw PassivePowerEffectCommands ; effect commands
db NONE ; flags 1
db NONE ; flags 2
db NONE ; flags 3
db 0
db ATK_ANIM_PKMN_POWER_1 ; animation




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



RagingStormDescription:
	text "This attack does 20 damage to each"
	line "of your opponent's Benched Pokémon"
	line "if you have more Prize cards"
	line "remaining than your opponent."
	done

; attack 2
energy WATER, 2, COLORLESS, 2 ; energies
tx RagingStormName ; name
tx RagingStormDescription ; description
dw NONE ; description (cont)
db 50 ; damage
db DAMAGE_NORMAL ; category
dw RagingStormEffectCommands ; effect commands
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
	tx IfAttachedEnergy10BonusDamageDescription ; description
	dw NONE ; description (cont)
	db 20 ; damage
	db DAMAGE_PLUS ; category
	dw IfAttachedEnergy10BonusDamageEffectCommands ; effect commands
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


; attack 2
energy WATER, 1, COLORLESS, 1 ; energies
tx AmnesiaName ; name
tx AmnesiaDescription ; description
dw NONE ; description (cont)
db 10 ; damage
db DAMAGE_NORMAL ; category
dw AmnesiaEffectCommands ; effect commands
db NONE ; flags 1
db FLAG_2_BIT_6 ; flags 2
db NONE ; flags 3
db 2
db ATK_ANIM_AMNESIA ; animation


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
	tx EnergyAssistDescription ; description
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





ClefableLv28Card:
	db TYPE_PKMN_PSYCHIC ; type
	gfx ClefableCardGfx ; gfx
	tx ClefableName ; name
	db STAR ; rarity
	db LABORATORY | GB ; sets
	db CLEFABLE  ; CLEFABLE_LV28
	db 70 ; hp
	db STAGE1 ; stage
	tx ClefairyName ; pre-evo name

	; Moon Guidance
	; Once during your turn (before your attack), you may flip a coin.
	; If heads, search your deck for a card that evolves from 1 of your Pokémon
	; and put it on that Pokémon. This counts as evolving your Pokémon.
	; Shuffle your deck afterward.

	; Moonlight
	; Once during your turn (before your attack), you may put a card from your
	; hand back on your deck. If you do, search your deck for a basic Energy card,
	; show it to your opponent, and put it into your hand. This power can't be
	; used if Clefable is affected by a Special Condition.

	; Lunar Blessing
	; Once during your turn, if your Active Pokémon has any Psychic Energy
	; attached, you may heal 20 damage from it, and it recovers from a
	; Special Condition.

	; Lunar Sanctuary
	; Prevents all effects of your opponent's attacks, except damage,
	; done to each of your Pokémon that has any Energy attached to it.

	; attack 1
	energy COLORLESS, 2 ; energies
	tx MetronomeName ; name
	tx MetronomeDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw MetronomeEffectCommands ; effect commands
	db NONE ; flags 1
	db FLAG_2_BIT_6 ; flags 2
	db NONE ; flags 3
	db 3
	db ATK_ANIM_NONE ; animation

	; attack 2
	energy PSYCHIC, 1, COLORLESS, 1 ; energies
	tx MoonblastName ; name
	tx ReduceAttackBy10Description ; description
	dw NONE ; description (cont)
	db 30 ; damage
	db DAMAGE_NORMAL ; category
	dw ReduceAttackBy10EffectCommands ; effect commands
	db NONE ; flags 1
	db NULLIFY_OR_WEAKEN_ATTACK ; flags 2
	db NONE ; flags 3
	db 10
	db ATK_ANIM_CONFUSE_RAY ; animation

	db 1 ; retreat cost
	db WR_DARKNESS ; weakness
	db NONE ; resistance
	tx FairyName ; category
	db 36 ; Pokedex number
	db 0
	db 34 ; level
	db 4, 3 ; length
	dw 88 * 10 ; weight
	tx ClefableDescription ; description
	db 0



;

MewLv23Card:
	db TYPE_PKMN_PSYCHIC ; type
	gfx MewLv23CardGfx ; gfx
	tx MewName ; name
	db STAR ; rarity
	db MYSTERY | FOSSIL ; sets
	db MEW_LV23
	db 50 ; hp
	db BASIC ; stage
	dw NONE ; pre-evo name

	; attack 1
	energy PSYCHIC, 1 ; energies
	tx PsywaveName ; name
	tx PsywaveDescription ; description
	dw NONE ; description (cont)
	db 10 ; damage
	db DAMAGE_X ; category
	dw MewPsywaveEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db NONE ; flags 3
	db 0
	db ATK_ANIM_PSYCHIC_HIT ; animation

	; attack 2
	energy PSYCHIC, 1, COLORLESS, 1 ; energies
	tx DevolutionBeamName ; name
	tx DevolutionBeamDescription ; description
	dw NONE ; description (cont)
	db 0 ; damage
	db RESIDUAL ; category
	dw MewDevolutionBeamEffectCommands ; effect commands
	db NONE ; flags 1
	db NONE ; flags 2
	db SPECIAL_AI_HANDLING ; flags 3
	db 0
	db ATK_ANIM_NONE ; animation

	db 0 ; retreat cost
	db WR_DARKNESS ; weakness
	db NONE ; resistance
	tx NewSpeciesName ; category
	db 151 ; Pokedex number
	db 0
	db 23 ; level
	db 1, 4 ; length
	dw 9 * 10 ; weight
	tx MewDescription ; description
	db 8




