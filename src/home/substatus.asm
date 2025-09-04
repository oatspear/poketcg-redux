; doubles the damage at de if swords dance or focus energy was used
; in the last turn by the turn holder's arena Pokemon
; also applies other damage bonus effects based on the Defender's substatus 1
; or the attacker's substatus 2.
; preserves: bc
HandleDamageBonusSubstatus:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS3
	call GetTurnDuelistVariable
	bit SUBSTATUS3_THIS_TURN_DOUBLE_DAMAGE, a
	call nz, DoubleDE

	ld a, DUELVARS_ARENA_CARD_SUBSTATUS1
	call GetNonTurnDuelistVariable
	cp SUBSTATUS1_VULNERABLE_40
	ret nz
	ld hl, 40
	jp AddToDamage_DE

; check if the attacking card (non-turn holder's arena card) has any substatus that
; reduces the damage dealt this turn (SUBSTATUS2).
; damage is given in de as input and the possibly updated damage is also returned in de.
; preserves: bc
HandleAttackerDamageReductionEffects:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS2
	call GetNonTurnDuelistVariable
	or a
	ret z
	cp SUBSTATUS2_REDUCE_BY_20
	jp z, ReduceDamageBy20_DE
	cp SUBSTATUS2_REDUCE_BY_10
	jp z, ReduceDamageBy10_DE
	ret

; check if the defending card (turn holder's arena card) has any substatus that
; reduces the damage dealt to it this turn. (SUBSTATUS1 or abilities)
; damage is given in de as input and the possibly updated damage is also returned in de.
HandleDefenderDamageReductionEffects:
	ld a, [wNoDamageOrEffect]
	or a
	jr z, .substatus1
; no damage
	ld de, 0
	ret
.substatus1
	call HandleDefenderDamageReduction_Substatus
.abilities
	call CheckCannotUsePokeBody
	ret c
	; jr HandleDefenderDamageReduction_Abilities
	; fallthrough

HandleDefenderDamageReduction_Abilities:
	ld a, [wLoadedAttackCategory]
	and ABILITY
	ret nz
	ld a, [wTempNonTurnDuelistCardID]
	cp MAROWAK_LV26
	jp z, ReduceDamageBy20_DE ; Battle Armor
	cp METAPOD
	jp z, ReduceDamageBy20_DE ; Exoskeleton
	cp KAKUNA
	jp z, ReduceDamageBy20_DE ; Exoskeleton
IF BLASTOISE_VARIANT == 1
	cp BLASTOISE
	jp z, ReduceDamageBy20_DE ; Solid Shell
ENDC
	cp CLOYSTER
	jp z, ReduceDamageBy20_DE ; Exoskeleton
	cp SHELLDER
	jp z, ReduceDamageBy10_DE ; Exoskeleton
	ret


HandleDefenderDamageReduction_Substatus:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS1
	call GetTurnDuelistVariable
	or a
	ret z
	cp SUBSTATUS1_NO_DAMAGE_FROM_BASIC
	jr z, .no_damage_from_basic
	cp SUBSTATUS1_NO_DAMAGE
	jr z, .no_damage
	cp SUBSTATUS1_REDUCE_BY_10
	jp z, ReduceDamageBy10_DE
	cp SUBSTATUS1_REDUCE_BY_20
	jp z, ReduceDamageBy20_DE
	cp SUBSTATUS1_HARDEN
	jr z, .prevent_less_than_40_damage
	cp SUBSTATUS1_HALVE_DAMAGE
	jp z, HalveDamage_DE
	ret

.no_damage_from_basic
	ld a, DUELVARS_ARENA_CARD_STAGE
	call GetNonTurnDuelistVariable
	or a
	ret nz  ; not a Basic Pokémon
.no_damage
	ld de, 0
	ret

.prevent_less_than_40_damage
	ld bc, 40
	call CompareDEtoBC
	ret nc  ; de >= 40
	ld de, 0
	ret


; check for Invisible Wall, Kabuto Armor, NShield, or Transparency, in order to
; possibly reduce or make zero the damage at de.
; TODO FIXME this function can be refactored and eliminated
HandleDamageReductionOrNoDamageFromPokeBodyEffects:
	ld a, [wLoadedAttackCategory]
	and ABILITY
	ret nz
.attack
	call ArePokeBodiesDisabled
	ret c
	ld a, [wTempPlayAreaLocation_cceb]
	or a
	jr z, .not_bench
	call IsBodyguardActive
	jr c, .no_damage
	call HandleDefenderDamageReduction_Abilities
.not_bench
	push de ; push damage from call above, which handles Invisible Wall and Kabuto Armor
	call HandleNoDamageOrEffectSubstatus.abilities
	; call nc, HandleTransparency
	pop de ; restore damage
	ret nc
; if carry was set due to NShield or Transparency, damage is 0
.no_damage
	ld de, 0
	ret


; return carry if NShield or Transparency activate (if MEW_LV8 or HAUNTER_LV17 is
; the turn holder's arena Pokemon), and print their corresponding text if so
HandleNShieldAndTransparency:
	push de
	ld a, DUELVARS_ARENA_CARD
	add e
	call GetTurnDuelistVariable
	call GetCardIDFromDeckIndex
	ld a, e
	cp MEW_LV8
	jr z, .nshield
	; cp HAUNTER_LV17
	; jr z, .transparency
.done
	pop de
	or a
	ret
.nshield
	ld a, DUELVARS_ARENA_CARD_STAGE
	call GetNonTurnDuelistVariable
	or a
	jr z, .done
	ld a, NO_DAMAGE_OR_EFFECT_NSHIELD
	ld [wNoDamageOrEffect], a
	ldtx hl, NoDamageOrEffectDueToNShieldText
.print_text
	call DrawWideTextBox_WaitForInput
	pop de
	scf
	ret
; .transparency
; 	xor a
; 	ld [wDuelDisplayedScreen], a
; 	ldtx de, TransparencyCheckText
; 	bank1call TossCoin
; 	jr nc, .done
; 	ld a, NO_DAMAGE_OR_EFFECT_TRANSPARENCY
; 	ld [wNoDamageOrEffect], a
; 	ldtx hl, NoDamageOrEffectDueToTransparencyText
; 	jr .print_text

; return carry if the turn holder's arena Pokemon is under a condition that makes
; it unable to attack. also return in hl the text id to be displayed
HandleCantAttackSubstatus:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS3
	call GetTurnDuelistVariable
	bit SUBSTATUS3_THIS_TURN_CANNOT_ATTACK, a
	ret z
	ldtx hl, UnableToAttackDueToEffectText
	scf
	ret

; return carry if the turn holder's arena Pokemon cannot use
; selected attack at wSelectedAttack due to amnesia
HandleAmnesiaSubstatus:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS2
	call GetTurnDuelistVariable
	or a
	jr nz, .check_amnesia
	ret
.check_amnesia
	cp SUBSTATUS2_AMNESIA
	jr z, .affected_by_amnesia
.not_the_disabled_atk
	or a
	ret
.affected_by_amnesia
	ld a, DUELVARS_ARENA_CARD_DISABLED_ATTACK_INDEX
	call GetTurnDuelistVariable
	ld a, [wSelectedAttack]
	cp [hl]
	jr nz, .not_the_disabled_atk
	ldtx hl, UnableToUseAttackDueToAmnesiaText
	scf
	ret


; return carry if the defending card (turn holder's arena card) is under a substatus
; that prevents any damage or effect dealt to it for a turn.
; also return the cause of the substatus in wNoDamageOrEffect
HandleNoDamageOrEffectSubstatus:
	xor a
	ld [wNoDamageOrEffect], a
	ld a, [wLoadedAttackCategory]
	and ABILITY
	ret nz
.attack
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS1
	call GetTurnDuelistVariable
	ld e, NO_DAMAGE_OR_EFFECT_AGILITY
	ldtx hl, NoDamageOrEffectDueToAgilityText
	cp SUBSTATUS1_AGILITY
	jr z, .no_damage_or_effect
; check whether abilities can be used
	call CheckCannotUsePokeBody
	ccf
	ret nc

.abilities
	ld a, [wTempNonTurnDuelistCardID]
	cp MEW_LV8
	jr z, .neutralizing_shield
	; cp VENOMOTH
	; jr z, .shield_dust
	or a
	ret

.no_damage_or_effect
	ld a, e
	ld [wNoDamageOrEffect], a
	scf
	ret

.neutralizing_shield
	ld a, [wIsDamageToSelf]
	or a
	ret nz

; prevent damage if attacked by a non-basic Pokemon
	; ld a, [wTempTurnDuelistCardID]
	; ld e, a
	; ld d, $0
	; call LoadCardDataToBuffer2_FromCardID
	; ld a, [wLoadedCard2Stage]
	ld a, DUELVARS_ARENA_CARD_STAGE
	call GetNonTurnDuelistVariable
	or a  ; cp BASIC
	ret z

	ld e, NO_DAMAGE_OR_EFFECT_NSHIELD
	ldtx hl, NoDamageOrEffectDueToNShieldText
	jr .no_damage_or_effect

; .shield_dust
; 	ld a, [wIsDamageToSelf]
; 	or a
; 	ret nz
;
; ; prevent damage if attacked by a Pokémon with 2 or more status
; 	ld a, DUELVARS_ARENA_CARD_STATUS
; 	call GetNonTurnDuelistVariable
; 	and PSN_BRN
; 	ret z
; 	and POISONED | BURNED
; 	cp POISONED | BURNED
; 	jr z, .shield_dust_active
; 	ld a, [hl]
; 	and CNF_SLP_PRZ
; 	ret z
;
; .shield_dust_active
; 	ld e, NO_DAMAGE_OR_EFFECT_SHIELD_DUST
; 	ldtx hl, NoDamageOrEffectDueToNShieldText
; 	jr .no_damage_or_effect


; return carry if the turn holder's arena card is under the effects of reduced accuracy
CheckReducedAccuracySubstatus:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS2
	call GetTurnDuelistVariable
	or a
	ret z
	ldtx de, AccuracyCheckText
	cp SUBSTATUS2_ACCURACY
	jr z, .card_is_affected
	or a
	ret
.card_is_affected
	ld a, [wGotHeadsFromAccuracyCheck]
	or a
	ret nz
	scf
	ret


; return carry and return the appropriate text id in hl if the target has an
; special status or power that prevents any damage or effect done to it this turn
; input: wNoDamageOrEffect = NO_DAMAGE_OR_EFFECT_*
CheckNoDamageOrEffect:
	ld a, [wNoDamageOrEffect]
	or a
	ret z
	bit 7, a
	jr nz, .dont_print_text ; already been here so don't repeat the text
	ld hl, wNoDamageOrEffect
	set 7, [hl]
	dec a
	add a
	ld e, a
	ld d, $0
	ld hl, NoDamageOrEffectTextIDTable
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	scf
	ret

.dont_print_text
	ld hl, $0000
	scf
	ret

NoDamageOrEffectTextIDTable:
	tx NoDamageText                          ; NO_DAMAGE_OR_EFFECT_UNUSED
	tx NoDamageOrEffectDueToAgilityText      ; NO_DAMAGE_OR_EFFECT_AGILITY
	tx NoDamageOrEffectDueToShieldDustText   ; NO_DAMAGE_OR_EFFECT_SHIELD_DUST
	tx NoDamageOrEffectDueToNShieldText      ; NO_DAMAGE_OR_EFFECT_NSHIELD


; returns carry if turn holder's arena card is paralyzed, asleep, confused,
; and/or neutralizing gas in play, meaning that attack and/or pkmn power cannot be used
; preserves: bc, de
CheckCannotUseDueToStatus:
	xor a  ; PLAY_AREA_ARENA
	; fallthrough

; returns carry if turn holder's card in location a is paralyzed, asleep, confused,
; and/or neutralizing gas in play, meaning that attack and/or pkmn power cannot be used
; preserves: bc, de
CheckCannotUseDueToStatus_PlayArea:
	push bc
	ld b, a
	call CheckPokemonPowerReadyState
	pop bc
	ret c
.toxic_gas
	call ArePokemonPowersDisabled
	ret nc
	ldtx hl, UnableToUsePkmnPowerText
	ret


CheckCannotUsePokeBody:
	xor a  ; PLAY_AREA_ARENA
	; fallthrough

CheckCannotUsePokeBody_PlayArea:
	call ArePokeBodiesDisabled
	; ret nc
	; ldtx hl, UnableToUsePokeBodyText
	ret


; input:
;   b: PLAY_AREA_* of the target Pokémon
; output:
;      hl: text pointer to failure reason
;   carry: set if the Power cannot be used due to status,
;          or if it was already used this turn
; preserves: bc, de
CheckPokemonPowerReadyState:
	ld a, DUELVARS_ARENA_CARD_STATUS
	add b
	call GetTurnDuelistVariable
	and CNF_SLP_PRZ
	jr z, .check_already_used
	ldtx hl, CannotUseDueToStatusText
	jr .unavailable
.check_already_used
	ld a, DUELVARS_ARENA_CARD_FLAGS
	add b
	ld l, a
	ld a, [hl]
	and USED_PKMN_POWER_THIS_TURN
	ret z
	ldtx hl, OnlyOncePerTurnText
.unavailable
	scf
	ret


; Check whether Neutralizing Gas is found on the turn holder's Active Spot,
; and whether it is Ability capable.
; Returns carry if the Pokémon card is found
; output:
;   a: 0 if not found; 1 if found
;   carry: set iff found and capable of using the Ability
; preserves: hl, bc, de
IsNeutralizingGasActive:
	ld a, WEEZING
	jr IsActiveSpotAbilityActive  ; preserves: hl, bc, de

; preserves: hl, bc, de
ArePokeBodiesDisabled:
IsOpponentNeutralizingGasActive:
	call SwapTurn
	call IsNeutralizingGasActive
	jp SwapTurn

; Check whether Pokémon Powers are currently disabled.
; Returns carry if Pokémon Powers cannot be used.
; output:
;   a: 0 if not found; 1 if found
;   carry: set iff found and capable of using the Power
; preserves: hl, bc, de
ArePokemonPowersDisabled:
	xor a
	ret


; Check whether a given Pokémon is found in the turn holder's
; Active Spot, and whether it is Ability capable.
; Returns carry if the Pokémon card is found.
; input:
;   a: ID of the Pokémon to check
; output:
;   a: 0 if not found; 1 if found
;   carry: set iff found and the Ability is enabled
; preserves: hl, bc, de
IsActiveSpotAbilityActive:
	push hl
	push bc
	ld c, a
; check whether it is the correct Pokémon
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	push de
	call GetCardIDFromDeckIndex  ; preserves bc
	ld a, e
	pop de
	cp c
	jr nz, .nope
; check whether Poké-Bodies are enabled at this location
	; ld b, PLAY_AREA_ARENA
	; call CheckPokemonPowerReadyState
	; jr c, .nope
.yup
	ld a, 1
	scf
	jr .done
.nope
	xor a  ; reset carry
.done
	pop bc
	pop hl
	ret


; return carry if turn holder has Sandslash and its Spikes ability is active
; preserves: hl, bc, de
IsSpikesActive:
	call ArePokeBodiesDisabled  ; preserves: hl, bc, de
	ccf
	ret nc
	ld a, SANDSLASH
	jp GetFirstPokemonMatchingID  ; preserves: hl, bc, de


; return carry if turn holder has Tentacruel and its Dark Prison ability is active
; preserves: hl, bc, de
IsDarkPrisonActive:
	call ArePokeBodiesDisabled  ; preserves: hl, bc, de
	ccf
	ret nc
	ld a, TENTACRUEL
	jp GetFirstPokemonMatchingID  ; preserves: hl, bc, de


; return carry if turn holder has Mew and its Clairvoyance ability is active
; preserves: hl, bc, de
IsClairvoyanceActive:
	or a
	ret
;	call ArePokeBodiesDisabled
;	ccf
;	ret nc
;	ld a, MEW_LV15
;	jp GetFirstPokemonMatchingID


; return carry if turn holder has Mr. Mime and its Bench Barrier ability is active
; preserves: hl, bc, de
IsBodyguardActive:
	call ArePokeBodiesDisabled  ; preserves: hl, bc, de
	ccf
	ret nc
	ld a, [wIsDamageToSelf]
	or a
	ret nz  ; only prevents damage from the opponent
	ld a, MR_MIME
	jp GetFirstPokemonMatchingID  ; preserves: hl, bc, de


; return carry if a Poké-Body capable Vileplume
; is found in the non-turn holder's Active Spot.
; preserves: hl, bc, de
IsHayFeverActive:
	ld a, VILEPLUME
	jr IsOpponentActiveSpotAuraActive


; return carry if a Pokémon Power capable Omastar
; is found in the non-turn holder's Active Spot.
; preserves: hl, bc, de
IsPrehistoricPowerActive:
	ld a, OMASTAR
	jr IsOpponentActiveSpotAuraActive


; return carry if an ability-capable Pokémon
; is found in the non-turn holder's Active Spot,
; and the turn holder does not have Neutralizing Gas
; input:
;   a: Pokémon ID of the aura to check
; preserves: hl, bc, de
IsOpponentActiveSpotAuraActive:
	call SwapTurn  ; preserves af
	call IsActiveSpotAbilityActive  ; preserves: hl, bc, de
	call SwapTurn
	ret nc  ; the opponent does not have the Ability
; check for Neutralizing Gas on the turn holder's side
	call IsNeutralizingGasActive  ; preserves: hl, bc, de
	ccf
	ret


; returns carry if the turn holder's Pokémon in the given location
; benefits from Safeguard
; input:
;   a: PLAY_AREA_* of the Pokémon benefiting from the Power
; output:
;   carry: set if Safeguard is active
IsSafeguardActive:
	ld b, a
	ld c, WATER
	ld e, DEWGONG
	jr IsSpecialEnergyPowerActive


; returns carry if the turn holder's Active Pokémon benefits
; from Grass Knot
; output:
;   carry: set if Grass Knot is active
IsGrassKnotActive:
	ld b, PLAY_AREA_ARENA
	ld c, GRASS
	ld e, WEEPINBELL
	jr IsSpecialEnergyPowerActive


; returns carry if the turn holder's Active Pokémon benefits
; from Cursed Flames
; output:
;   carry: set if Cursed Flames is active
IsCursedFlamesActive:
	ld b, PLAY_AREA_ARENA
	ld c, FIRE
	ld e, NINETALES_LV35
	jr IsSpecialEnergyPowerActive


; returns carry if the turn holder's Active Pokémon benefits
; from Vampiric Aura
; output:
;   carry: set if Vampiric Aura is active
IsVampiricAuraActive:
	ld b, PLAY_AREA_ARENA
	ld c, DARKNESS
	ld e, GOLBAT
	jr IsSpecialEnergyPowerActive


; returns carry if the turn holder's Pokémon in the given location
; benefits from Dark Retribution
; input:
;   a: PLAY_AREA_* of the Pokémon benefiting from the Power
; output:
;   carry: set if Dark Retribution is active
; IsDarkRetributionActive:
; 	ld b, a
; 	ld c, DARKNESS
; 	ld e, NIDORINO
; 	jr IsSpecialEnergyPowerActive


; returns carry if the turn holder's Pokémon in the given location
; benefits from Stone Skin
; input:
;   a: PLAY_AREA_* of the Pokémon benefiting from the Power
; output:
;   carry: set if Stone Skin is active
IsStoneSkinActive:
	ld b, a
	ld c, FIGHTING
	ld e, GRAVELER
	jr IsSpecialEnergyPowerActive


; returns carry if the turn holder's Active Pokémon benefits
; from Fighting Fury
; output:
;   carry: set if Fighting Fury is active
IsFightingFuryActive:
	ld b, PLAY_AREA_ARENA
	ld c, FIGHTING
	ld e, MACHOKE
	; jr IsSpecialEnergyPowerActive
	; fallthrough


; returns carry if the turn holder's Pokémon Power
; that enhances Energies is active
; input:
;   b: PLAY_AREA_* of the Pokémon benefiting from the Power
;   c: color of the energy to look for
;   e: ID of the Pokémon granting the Power
; output:
;   carry: set if the Power is active
IsSpecialEnergyPowerActive:
	call ArePokeBodiesDisabled  ; preserves bc, de
	ccf
	ret nc
	ld a, e
	call GetFirstPokemonMatchingID  ; preserves hl, bc, de
	ret nc  ; not found
; Feedback is returned in wAttachedEnergies and wTotalAttachedEnergies.
	ld e, b
	call GetPlayAreaCardAttachedEnergies  ; preserves hl, bc, de
	push bc
	call HandleEnergyColorOverride  ; preserves de
	pop bc
	ld hl, wAttachedEnergies
	ld b, 0  ; bc is color offset
	add hl, bc
	ld a, [hl]
	cp 1
	ccf
	ret


; returns carry if the turn holder's Pokémon Power
; that enhances Energies is active
; output:
;   carry: set if the Power is active
; preserves: bc, de
IsElementalMasteryActive:
	call ArePokeBodiesDisabled  ; preserves bc, de
	ccf
	ret nc
	ld a, DRAGONAIR
	call GetFirstPokemonMatchingID  ; preserves hl, bc, de
	ret nc  ; not found
; Feedback is returned in wAttachedEnergies and wTotalAttachedEnergies.
	push de
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies  ; preserves hl, bc, de
	push bc
	call HandleEnergyColorOverride  ; preserves de
	pop bc
	ld d, 0  ; counter
	ld e, NUM_COLORED_TYPES
	ld hl, wAttachedEnergies
.loop
	ld a, [hli]
	or a
	jr z, .next
	inc d
.next
	dec e
	jr nz, .loop
	ld a, d
	pop de
	cp 2
	ccf
	ret  ; carry set if two or more colors


; return carry if the Active Pokémon is unable to evolve due to substatus
; preserves: bc, de
IsUnableToEvolve:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS2
	call GetTurnDuelistVariable
	cp SUBSTATUS2_PRIMAL_TENTACLE
	scf
	ret z
	or a  ; reset carry
	ret


; Return, in a, the amount of times that the Pokémon card with a given ID is found in the
; turn holder's play area. Also return carry if the Pokémon card is at least found once.
; If the Pokémon is asleep, confused, or paralyzed (Pkmn Power-incapable), it doesn't count.
; input:
;   a: Pokémon card ID to search
; preserves: hl, bc, de
CountPokemonIDWithAvailablePower:
	push hl
	ld hl, CheckPokemonPowerReadyState
	ld a, l
	ld [wPlayAreaFilterFunctionPointer], a
	ld a, h
	ld [wPlayAreaFilterFunctionPointer + 1], a
	pop hl
	jr CountPokemonIDInPlayAreaMatchingFilter


; Return, in a, the amount of times that the Pokémon card
; with a given ID and matching the filter function
; is found in the turn holder's play area.
; Also return carry if the Pokémon card is at least found once.
; input:
;   a: Pokémon card ID to search
; preserves: hl, bc, de
CountPokemonIDInPlayArea:
	xor a  ; null filter
	ld [wPlayAreaFilterFunctionPointer], a
	ld [wPlayAreaFilterFunctionPointer + 1], a
	; jr CountPokemonIDInPlayAreaMatchingFilter
	; fallthrough

; Return, in a, the amount of times that the Pokémon card
; with a given ID and matching the filter function
; is found in the turn holder's play area.
; Also return carry if the Pokémon card is at least found once.
; input:
;   a: Pokémon card ID to search
;   [wPlayAreaFilterFunctionPointer]: pointer to a filter function
; preserves: hl, bc, de
CountPokemonIDInPlayAreaMatchingFilter:
	push hl
	push de
	push bc
	ld [wTempPokemonID_ce7c], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld b, a
	ld c, 0
	or a
	jr z, .found
.loop_play_area
	ld a, DUELVARS_ARENA_CARD
	add b
	dec a  ; zero-based index
	call GetTurnDuelistVariable
	cp $ff
	jr z, .done
; check if it is the right Pokémon
	call GetCardIDFromDeckIndex
	ld a, [wTempPokemonID_ce7c]
	cp e
	jr nz, .skip
; check if the Pokémon matches the filter
	dec b  ; zero-based index
	or a  ; reset carry
	ld hl, wPlayAreaFilterFunctionPointer
	call CallIndirect  ; call [hl] if non-NULL
	inc b  ; restore index
	jr c, .skip
	inc c
.skip
	dec b
	jr nz, .loop_play_area
.done
	ld a, c
	or a
	scf
	jr nz, .found
	or a
.found
	pop bc
	pop de
	pop hl
	ret


; Returns the PLAY_AREA_* location of the first Pokémon Power
; capable Pokémon with the given ID in play.
; If a Pokémon is Asleep, Confused, or Paralyzed (Power-incapable), it does not count.
; If a Pokémon's Power has been used this turn, it does not count.
; Returns $ff if no Pokémon is found.
; input:
;   a: Pokémon card ID to search
; output:
;   a: PLAY_AREA_* of the first Pokémon with given ID | $ff
;   carry: set if a Pokémon is found
; preserves: hl, bc, de
GetFirstPokemonWithAvailablePower:
	push hl
	ld hl, CheckPokemonPowerReadyState
	ld a, l
	ld [wPlayAreaFilterFunctionPointer], a
	ld a, h
	ld [wPlayAreaFilterFunctionPointer + 1], a
	pop hl
	jr GetFirstPokemonMatchingFilter


; Returns the PLAY_AREA_* location of the first
; Pokémon with the given ID in play.
; Returns $ff if no Pokémon is found.
; input:
;   a: Pokémon card ID to search
; output:
;   a: PLAY_AREA_* of the first Pokémon with given ID | $ff
;   carry: set if a Pokémon is found
; preserves: hl, bc, de
GetFirstPokemonMatchingID:
	xor a  ; null filter
	ld [wPlayAreaFilterFunctionPointer], a
	ld [wPlayAreaFilterFunctionPointer + 1], a
	; jr GetFirstPokemonMatchingFilter
	; fallthrough


; Returns the PLAY_AREA_* location of the first Pokémon with the
; given ID in play that passes the filter function.
; Returns $ff if no Pokémon is found.
; input:
;   a: Pokémon card ID to search
;   [wPlayAreaFilterFunctionPointer]: pointer to a filter function
; output:
;   a: PLAY_AREA_* of the first Pokémon with given ID | $ff
;   carry: set if a Pokémon is found
; preserves: hl, bc, de
GetFirstPokemonMatchingFilter:
	push hl
	push de
	push bc
	ld [wTempPokemonID_ce7c], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a  ; loop counter
	ld b, 0  ; use b as a 0-based index
; optimize: assume that hl is already in DUELVARS
.loop_play_area
	ld a, DUELVARS_ARENA_CARD
	add b
	ld l, a
	ld a, [hl]
	cp $ff
	jr z, .done
; check if it is the right Pokémon
	call GetCardIDFromDeckIndex
	ld a, [wTempPokemonID_ce7c]
	cp e
	jr nz, .skip
; check if this Pokémon matches the filter
	or a  ; reset carry
	push hl
	ld hl, wPlayAreaFilterFunctionPointer
	call CallIndirect  ; call [hl] if non-NULL
	pop hl
	jr c, .skip  ; this carry flag only matters if the call happens
; found a valid Pokémon
	ld a, b  ; get the PLAY_AREA_* offset
	scf
	jr .found
.skip
	inc b
	dec c
	jr nz, .loop_play_area
	ld a, $ff
.done
	or a
.found
	pop bc
	pop de
	pop hl
	ret


; input:
;   e: PLAY_AREA_* of the target Pokémon
; output:
;   a: number of Colorless energy to add to the attack's cost
;   c: number of Colorless energy to add to the attack's cost
; preserves: hl, b, de
GetAttackCostPenalty:
	push hl
	ld c, 0
IF CC_IS_COIN_FLIP == 0
; check for status
	ld a, e
	add DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	and CNF_SLP_PRZ
	cp ASLEEP
	jr nz, .substatus
	inc c
.substatus
ENDC
	ld a, e
	or a
	jr nz, .tally
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS2
	call GetTurnDuelistVariable
	cp SUBSTATUS2_ATTACK_COST_PLUS_1
	jr nz, .tally
	inc c
.tally
	ld a, c
	pop hl
	ret


; input:
;   e: PLAY_AREA_* of the target Pokémon
; output:
;   a: number of Colorless energy to discount from the attack's cost
;   c: number of Colorless energy to discount from the attack's cost
; preserves: hl, b, de
GetAttackCostDiscount:
	push hl
	ld c, 0
; check for substatus
	ld a, e
	or a
	jr nz, .bench
; check for Swift Swim
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call _GetCardIDFromDeckIndex  ; preserves bc, de
	cp GOLDUCK
	jr z, .swift_swim
	cp RAPIDASH
	jr nz, .bench
.swift_swim
	call CheckCannotUsePokeBody  ; unable to use ability
	jr c, .bench
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS3
	call GetTurnDuelistVariable
	bit SUBSTATUS3_THIS_TURN_ACTIVE, a
	jr z, .bench
	inc c
	; ld a, e
.bench
;	add DUELVARS_ARENA_CARD
;	call GetTurnDuelistVariable
;	call _GetCardIDFromDeckIndex  ; preserves bc, de
;	cp SEAKING
;	jr nz, .tally
	; TODO
.tally
	ld a, c
	pop hl
	ret


; input:
;   hl: pointer to loaded attack struct energy cost
;   e: PLAY_AREA_* of the target
; output:
;   updated attack cost in the struct pointed by hl
; preserves: de
OverwriteLoadedAttackCost:
	push hl
	push de
	ld de, VIRIDIAN_GYM
	call CheckStadiumIDInPlayArea  ; preserves: bc, de
	pop de
	pop hl
	jr c, .colorless_modifiers  ; not in play

; Viridian Gym
	push hl
	ld b, 0  ; total basic energy cost
	ld c, NUM_TYPES / 2  ; loop counter
.loop
; first color
	ld a, [hl]
	swap a
	and $0f
	add b
	ld b, a
; second color
	ld a, [hl]
	and $0f
	add b
	ld b, a
; erase colored cost
	xor a
	ld [hli], a
	dec c
	jr nz, .loop
; write converted colorless cost
IF (NUM_TYPES % 2) == 1
	ld a, [hl]
	swap a
	add b
	and $0f
	swap a
ELSE
	dec hl
	ld a, b
ENDC
	ld [hl], a
	pop hl

.colorless_modifiers
; skip to colorless energy
	ld bc, (NUM_TYPES - 1) / 2
	add hl, bc
; check whether there are any cost modifiers
	call GetAttackCostDiscount
	ld b, a
	call GetAttackCostPenalty
	add b
	ret z  ; no modifiers
; apply attack cost modifiers
	ld a, [hl]
IF (NUM_TYPES % 2) == 1
	swap a
ENDC
	and $0f
	add c  ; penalty
	ret z  ; no Colorless required
	sub b  ; discount
	jr nc, .overwrite
	xor a  ; no Colorless required
	; jr .capped
.overwrite
	cp $10
	jr c, .capped
	ld a, $0f
.capped
IF (NUM_TYPES % 2) == 1
	swap a
ELSE
; retain colored cost
	ld c, a
	ld a, [hl]
	and $f0
	or c
ENDC
	ld [hl], a
	ret


; return any applicable retreat cost penalties
; input:
;   a: PLAY_AREA_* of the Pokémon to check
; output:
;   a: number of Colorless energy to add to the Retreat Cost
;   c: number of Colorless energy to add to the Retreat Cost
; preserves: b, de
GetRetreatCostPenalty:
	ld c, 0
	or a
	jr nz, .bench
; increased Retreat Cost substatus (Arena)
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS2
	call GetTurnDuelistVariable
	cp SUBSTATUS2_RETREAT_PLUS_1
	jr nz, .rooted
	inc c
.rooted
	ld l, DUELVARS_ARENA_CARD_SUBSTATUS3
	bit SUBSTATUS3_THIS_TURN_ROOTED, [hl]
	jr z, .no_substatus
	inc c
.no_substatus
	xor a  ; PLAY_AREA_ARENA
.bench
	add DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
IF CC_IS_COIN_FLIP
; Crowd Control status
; 	and CNF_SLP_PRZ
; 	jr z, .no_crowd_control
; 	inc c
; .no_crowd_control
; 	ld a, [hl]
ELSE
; Drowsiness status
	and CNF_SLP_PRZ
	cp ASLEEP
	jr nz, .not_drowsy
	inc c
.not_drowsy
	ld a, [hl]
ENDC
	or a
	jr z, .tally  ; no status
; Dark Prison ability
	call SwapTurn
	call IsDarkPrisonActive  ; preserves bc, de
	call SwapTurn
	jr nc, .tally
	inc c
.tally
	ld a, c
	ret


; return any applicable retreat cost discounts
; input:
;   a: PLAY_AREA_* of the Pokémon to check
; output:
;   a: number of Colorless energy to discount from Retreat Cost
; preserves: bc, de
GetRetreatCostDiscount:
	or a
	jr nz, .no_discount
	call ArePokeBodiesDisabled  ; preserves bc, de
	jr c, .no_discount
	ld a, DODRIO  ; Retreat Aid
	jp CountPokemonIDInPlayArea  ; preserves hl, bc, de
.no_discount
	xor a
	ret


; return carry if the turn holder's arena Pokemon can't retreat
CheckCantRetreatDueToStatusOrEffect:
IF CC_IS_COIN_FLIP
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	and CNF_SLP_PRZ
	cp FLINCHED
	ldtx hl, UnableDueToParalysisText
	jr z, .cant_retreat
ENDC
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS2
	call GetTurnDuelistVariable
	or a
	ret z
	ldtx hl, UnableToRetreatDueToTrapText
	cp SUBSTATUS2_UNABLE_RETREAT
	jr z, .cant_retreat
	cp SUBSTATUS2_PRIMAL_TENTACLE
	jr z, .cant_retreat
	or a
	ret
.cant_retreat
	scf
	ret


; assumes:
;   - call SwapTurn if needed
; input:
;   e: PLAY_AREA_* of the target Pokémon
; outputs:
;   carry: set if able to apply status
; preserves: bc, de
CanBeAffectedByStatus:
	ld a, DUELVARS_ARENA_CARD
	add e
	call GetTurnDuelistVariable
	cp $ff
	ret z  ; empty slot

	push de
	call GetCardIDFromDeckIndex
	ld a, e
	pop de
	cp MYSTERIOUS_FOSSIL
	ret z  ; cannot induce status
; Snorlax's Thick Skinned prevents it from being statused...
	cp SNORLAX
	jr nz, .safeguard
; ...unless already so, or if affected by Neutralizing Gas
	ld a, e
	call CheckCannotUsePokeBody_PlayArea  ; preserves bc, de
	ret nc  ; Poké-Body is active

.safeguard
	ld a, e
	push bc
	push de
	call IsSafeguardActive
	pop de
	pop bc
	ccf
	ret  ; nc if safeguarded


; return carry if the turn holder is affected by Headache and trainer cards can't be used
CheckCantUseItemsThisTurn:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS3
	call GetTurnDuelistVariable
	or a
	bit SUBSTATUS3_HEADACHE, [hl]
	ret z
	; jr nz, .unable
	; call IsHayFeverActive
	; ret nc
.unable
	ldtx hl, UnableToUseItemCardThisTurnText
	scf
	ret


; clears some SUBSTATUS2 conditions from the turn holder's active Pokemon.
; more specifically, those conditions that reduce the damage from an attack
; or prevent the opposing Pokemon from attacking the substatus condition inducer.
ClearDamageReductionSubstatus2:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS2
	call GetTurnDuelistVariable
	or a
	ret z
	cp SUBSTATUS2_REDUCE_BY_20
	jr z, .zero
	cp SUBSTATUS2_REDUCE_BY_10
	jr z, .zero
	cp SUBSTATUS2_UNABLE_ATTACK
	jr z, .zero
	ret
.zero
	ld [hl], 0
	ret

; clears the SUBSTATUS1 and updates the double damage condition of the player about to start his turn
UpdateSubstatusConditions_StartOfTurn:
	ld a, $ff
	ld [wEnergyColorOverride], a
; clear active this turn flag to handle opponent gusting/repulsion
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS3
	call GetTurnDuelistVariable
	res SUBSTATUS3_THIS_TURN_ACTIVE, [hl]
	ld l, DUELVARS_ARENA_CARD_SUBSTATUS1
	ld a, [hl]
	ld [hl], $0
	or a
	ret z
	cp SUBSTATUS1_NEXT_TURN_DOUBLE_DAMAGE
	jr z, .double_damage
	cp SUBSTATUS1_NEXT_TURN_UNABLE_ATTACK
	ret nz

; .unable_to_attack
	ld l, DUELVARS_ARENA_CARD_SUBSTATUS3
	set SUBSTATUS3_THIS_TURN_CANNOT_ATTACK, [hl]
	ret

.double_damage
	ld l, DUELVARS_ARENA_CARD_SUBSTATUS3
	set SUBSTATUS3_THIS_TURN_DOUBLE_DAMAGE, [hl]
	ret

; clears the SUBSTATUS2, Headache, and updates the double damage condition
; and the "became active" condition of the player ending his turn
UpdateSubstatusConditions_EndOfTurn:
	ld a, DUELVARS_MISC_TURN_FLAGS
	call GetTurnDuelistVariable
	; res TURN_FLAG_TOSSED_TAILS_F, [hl]
	; res TURN_FLAG_KO_OPPONENT_POKEMON_F, [hl]
	ld [hl], $0
	ld l, DUELVARS_ARENA_CARD_SUBSTATUS3
	ld [hl], $0
	; res SUBSTATUS3_HEADACHE, [hl]
	; res SUBSTATUS3_THIS_TURN_ACTIVE, [hl]
	; res SUBSTATUS3_THIS_TURN_DOUBLE_DAMAGE, [hl]
	; res SUBSTATUS3_THIS_TURN_CANNOT_ATTACK, [hl]
	; res SUBSTATUS3_THIS_TURN_ROOTED, [hl]
	ld l, DUELVARS_ARENA_CARD_SUBSTATUS2
	ld [hl], $0
	; ld l, DUELVARS_ABILITY_FLAGS
	; res ABILITY_FLAG_SWIFT_SWIM_F, [hl]
	ret

; return carry if turn holder has an active Rain Dance Pkmn Power
IsRainDanceActive:
	call ArePokemonPowersDisabled
	ccf
	ret nc ; Powers are disabled
IF POLITOED_VARIANT == 0
	ld a, POLITOED
	call GetFirstPokemonWithAvailablePower
	ret c
ENDC
IF BLASTOISE_VARIANT == 2
	ld a, BLASTOISE
ELSE
	ld a, WARTORTLE
ENDC
	jp GetFirstPokemonWithAvailablePower


; if the defending (non-turn) card's HP is 0 and the attacking (turn) card's HP
;  is not, the attacking card faints if it was affected by destiny bond
HandleDestinyBondSubstatus:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS1
	call GetNonTurnDuelistVariable
	cp SUBSTATUS1_DESTINY_BOND
	ret nz

	ld a, DUELVARS_ARENA_CARD
	call GetNonTurnDuelistVariable
	cp $ff
	ret z

	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	or a
	ret nz

	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	or a
	ret z

	ld [hl], 0
	push hl
	call DrawDuelMainScene
	call DrawDuelHUDs
	pop hl
	ld l, DUELVARS_ARENA_CARD
	ld a, [hl]
	call LoadCardDataToBuffer2_FromDeckIndex
	call LoadCard2NameToRamText
	ldtx hl, KnockedOutDueToDestinyBondText
	jp DrawWideTextBox_WaitForInput


; If a Strikes Back ability is active, the attacking Pokémon
; (turn holder's arena Pokémon) takes damage back.
; Used to bounce back an attack of the RESIDUAL category.
; Used to handle direct damage in the Active spot after an attack.
HandleStrikeBack_AfterDirectAttack:
	ld a, [wLoadedAttackCategory]
	and RESIDUAL
	ret nz

; not a RESIDUAL attack
	ld a, [wDealtDamage]
	or a
	ret z

; damaging attack
	call SwapTurn
	call IsCounterattackActive
	call SwapTurn
	ret nc  ; not active or no capable Pokémon

	; de: amount of counter damage to deal
	call ApplyCounterattackDamage
	jp c, DrawDuelHUDs
	ret


; If a Strikes Back ability is active, the attacking Pokémon
; (non-turn holder's arena Pokémon) takes damage back.
; Ignore if damage taken at de is 0.
; Used to bounce back a damaging attack.
; This is called with turns swapped (turn holder is the defender).
HandleStrikeBack_AgainstDamagingAttack:
	ld a, e
	or d
	ret z

; do not counter recoil or confusion damage
	ld a, [wIsDamageToSelf]
	or a
	ret nz

; do not counter damage from Pokémon Powers
	ld a, [wLoadedAttackCategory]
	and ABILITY
	ret nz

; do not counter damage while on the bench
	ld a, [wTempPlayAreaLocation_cceb]  ; defending Pokemon's PLAY_AREA_*
	or a
	ret nz  ; bench

; do not counter if the Pokémon Power is disabled or not available
	call IsCounterattackActive
	ret nc  ; not active or no capable Pokémon
	ccf

; assume: no carry is set at this point
; back up wTempTurnDuelistCardID (not sure if needed)
	ld a, [wTempTurnDuelistCardID]
	push af  ; ld [wMultiPurposeByte], a

; subtract HP from attacking Pokémon (non-turn holder's arena Pokémon)
	call SwapTurn
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	push de  ; amount of counter damage to deal
	call GetCardIDFromDeckIndex
	ld a, e
	ld [wTempTurnDuelistCardID], a
	pop de  ; amount of counter damage to deal

	call ApplyCounterattackDamage
	; not sure if these assignments are needed
	ld a, [wLoadedCard2ID]
	ld [wTempNonTurnDuelistCardID], a

; restore backed up variables
	pop af  ; ld a, [wMultiPurposeByte]
	ld [wTempTurnDuelistCardID], a
	jp SwapTurn


; subtract HP from the attacking Pokémon due to a counter attack
; input:
;   e: damage to be dealt
; output:
;   z: set if no Knock Out due to damage
;   carry: set if Knock Out occurred
ApplyCounterattackDamage:
	push de
	ld l, e
	ld h, 0
	call LoadTxRam3
	ld a, [wTempTurnDuelistCardID]
	ld e, a
	ld d, 0
	call LoadCardDataToBuffer2_FromCardID
	call LoadCard2NameToRamText
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	pop de
	push af
	; push hl
	call SubtractHP
	ldtx hl, ReceivesDamageDueToStrikeBackText
	call DrawWideTextBox_WaitForInput
	; pop hl
	pop af
	or a
	ret z
	xor a  ; PLAY_AREA_ARENA
	call PrintPlayAreaCardKnockedOutIfNoHP
	scf
	ret


; Checks whether the target Pokémon in the turn holder's play area
; is capable of dealing counterattack damage.
; input:
;   wTempNonTurnDuelistCardID: ID of the target Pokémon receiving damage
; output:
;   carry: set if counterattack damage is active
;   de: amount of counter damage to deal
IsCounterattackActive:
	ld de, 0

; do not counter if the defender's ability is disabled
; ArePokeBodiesDisabled is called here
	; ld a, [wTempPlayAreaLocation_cceb]  ; defending Pokemon's PLAY_AREA_*
	; call CheckCannotUsePokeBody_PlayArea  ; preserves de
	call CheckCannotUsePokeBody  ; preserves de
	jr c, .dark_retribution

; Strike Back Pokémon
	ld a, [wTempNonTurnDuelistCardID]
	; cp MACHAMP
	; ; ld hl, 20  ; damage to return
	; ; call z, AddToDamage_DE
	; ld de, 20  ; damage to return
	; jr z, .dark_retribution

	cp MEWTWO_LV60
	; ld hl, 10  ; damage to return
	; call z, AddToDamage_DE
	ld de, 10  ; damage to return
	jr z, .dark_retribution

.desperate_blast
	ld de, 0   ; damage to return
	cp ELECTRODE_LV35
	jr nz, .dark_retribution
; only triggers if the Pokémon has been Knocked Out
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	or a
	jr nz, .dark_retribution  ; not Knocked Out
	ld de, 40  ; damage to return

	; ld de, 30  ; damage to return
	; push de
	; ld e, PLAY_AREA_ARENA
	; call GetPlayAreaCardAttachedEnergies  ; preserves: hl, bc, de
	; call HandleEnergyColorOverride  ; preserves: de
	; pop de
	; ld a, [wTotalAttachedEnergies]
	; or a
	; jr z, .dark_retribution
	; ld h, 0
	; ld l, a
	; call AddToDamage_DE

.dark_retribution
	; push de
	; xor a  ; PLAY_AREA_ARENA
	; call IsDarkRetributionActive
	; pop de
	; jr nc, .rocky_helmet  ; not active
	; ld hl, 10
	; call AddToDamage_DE

.rocky_helmet
	ld a, DUELVARS_ARENA_CARD_ATTACHED_TOOL
	call GetTurnDuelistVariable
	push de
	call GetCardIDFromDeckIndex  ; preserves af, hl, bc
	ld a, e
	pop de
	cp ROCKY_HELMET
	jr nz, .counter_substatus
	ld hl, 10
	call AddToDamage_DE

.counter_substatus
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS1
	call GetTurnDuelistVariable
	cp SUBSTATUS1_COUNTER_20
	jr nz, .done
	ld hl, 20
	call AddToDamage_DE

.done
; carry set if non-zero damage
	call CapMaximumDamage_DE
	ld a, e
	cp 1
	ccf
	ret


; if the id of the arena card is WEEZING,
; clear the changed type of all arena and bench Pokémon
ClearChangedTypesIfWeezing:
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call GetCardIDFromDeckIndex
	ld a, e
	cp WEEZING
	ret nz

	call SwapTurn
	call .zero_changed_types
	call SwapTurn
.zero_changed_types
	ld a, DUELVARS_ARENA_CARD_CHANGED_TYPE
	call GetTurnDuelistVariable
	ld c, MAX_PLAY_AREA_POKEMON
.zero_changed_types_loop
	xor a
	ld [hli], a
	dec c
	jr nz, .zero_changed_types_loop
	ret
