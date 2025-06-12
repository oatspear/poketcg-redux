; ------------------------------------------------------------------------------
; Healing
; ------------------------------------------------------------------------------

; leech 20 against poisoned targets
; leech 10 damage otherwise
VampiricAura_LeechEffect:
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetNonTurnDuelistVariable
IF DOUBLE_POISON_EXISTS
	and MAX_POISON
ELSE
	and POISONED
ENDC
	jr z, Leech10DamageEffect
	jr Leech20DamageEffect


LeechLifeEffect:
	ld hl, wDealtDamage
	ld e, [hl]
	inc hl ; wDamageEffectiveness
	ld d, [hl]
	jr ApplyAndAnimateHPRecovery


Leech10DamageEffect:
	ld hl, wDealtDamage
	ld a, [hli]
	or a
	ret z ; return if no damage dealt
	; fallthrough

Heal10DamageEffect:
	ld de, 10
	jr ApplyAndAnimateHPRecovery


Leech20DamageEffect:
	ld hl, wDealtDamage
	ld a, [hli]
	or a
	ret z ; return if no damage dealt
	; fallthrough

Heal20DamageEffect:
	ld de, 20
	jr ApplyAndAnimateHPRecovery


; to be used in effects that happen BEFORE_DAMAGE
; Heal20DamageEffect_PreserveAttackAnimation:
; 	ld a, [wLoadedAttackAnimation]
; 	push af
; 	call Heal20DamageEffect
; 	pop af
; 	ld [wLoadedAttackAnimation], a
; 	ret


Leech30DamageEffect:
	ld hl, wDealtDamage
	ld a, [hli]
	or a
	ret z ; return if no damage dealt
	; fallthrough

Heal30DamageEffect:
	ld de, 30
	jr ApplyAndAnimateHPRecovery


SwallowUp_HealEffect:
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	or a
	ret nz  ; not Knocked Out
	; jr Heal40DamageEffect
	; fallthrough

Heal40DamageEffect:
	ld de, 40
	jr ApplyAndAnimateHPRecovery


; to be used in effects that happen BEFORE_DAMAGE
; Heal30DamageEffect_PreserveAttackAnimation:
; 	ld a, [wLoadedAttackAnimation]
; 	push af
; 	call Heal30DamageEffect
; 	pop af
; 	ld [wLoadedAttackAnimation], a
; 	ret


HealADamageEffect:
	ld d, 0
	ld e, a
	; jr ApplyAndAnimateHPRecovery
	; fallthrough

; applies HP recovery on Pokemon after an attack
; with HP recovery effect, and handles its animation.
; input:
;	d = damage effectiveness
;	e = HP amount to recover
ApplyAndAnimateHPRecovery:
	push de
	ld hl, wHPRecoveryInputBackup
	ld [hl], e
	inc hl
	ld [hl], d

; get Arena card's damage
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	pop de
	or a
	ret z ; return if no damage

; load correct animation
	push de
	ld a, ATK_ANIM_HEAL
	ld [wLoadedAttackAnimation], a
	ld bc, $01 ; arrow
	bank1call PlayAttackAnimation

; compare HP to be restored with max HP
; if HP to be restored would cause HP to
; be larger than max HP, cap it accordingly
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	ld b, $00
	pop de
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	add e
	ld e, a
	xor a
	adc d
	ld d, a
	; de = damage dealt + current HP
	; bc = max HP of card
	call CompareDEtoBC
	jr c, .skip_cap
	; cap de to value in bc
	ld e, c
	ld d, b

.skip_cap
	ld [hl], e ; apply new HP to arena card
	bank1call WaitAttackAnimation
	ret

; input:
;   e: amount to heal
HealUserHP_NoAnimation:
	push de
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	or a
	pop de
	ret z ; no damage counters

	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	add e
	cp c  ; c contains max HP from GetCardDamageAndMaxHP
	jr c, .store
	ld a, c  ; cap HP
.store
	ld [hl], a
	ret

; heals up to the amount of damage in register d for card in
; Play Area location in e.
; plays healing animation and prints text with card's name.
; uses: a, de, hl
; preserves: bc
; (no longer) uses: [hTempPlayAreaLocation_ff9d]
; input:
;	   d: amount of HP to heal
;	   e: PLAY_AREA_* of card to heal
; output:
;    carry: set if not damaged
HealPlayAreaCardHP:
; check its damage
	; ld d, a
	; ldh a, [hTempPlayAreaLocation_ff9d]
	; ld e, a
	push bc
	call GetCardDamageAndMaxHP
	pop bc
	or a
	jr nz, .damaged
	scf
	ret

.damaged
	cp d
	jr nc, .got_amount_to_heal  ; is damage higher than amount to heal?
	ld d, a                     ; else, heal at most a damage
.got_amount_to_heal
; play heal animation
	bank1call PlayHealingAnimation_PlayAreaPokemon

; heal the target Pokemon
	ld a, DUELVARS_ARENA_CARD_HP
	add e
	call GetTurnDuelistVariable
	add d
	ld [hl], a
	ret

	; call GetCardDamageAndMaxHP
	; ld b, $00
	; ld a, DUELVARS_ARENA_CARD_HP
	; call GetTurnDuelistVariable
	; add e
	; ld e, a
	; xor a
	; adc d
	; ld d, a
; de = damage dealt + current HP
; bc = max HP of card
	; call CompareDEtoBC
	; jr c, .skip_cap
; cap de to value in bc
	; ld e, c
	; ld d, b
; .skip_cap
	; ld [hl], e ; apply new HP to arena card
	; ret


; Heal10DamagePerAttachedEnergyEffect:
; 	ld e, PLAY_AREA_ARENA
; 	call GetEnergyAttachedMultiplierDamage
; 	jp HealADamageEffect


; no animation
; does not count as healing
; input:
;   d: damage to remove (tens, not units)
;   e: PLAY_AREA_* of the target
; output:
;   d: amount of healed damage (<= input d)
;   carry: set if no damage counters to remove
; preserves: bc, e
RemoveDamageCounters:
; check its damage
	push bc
	call GetCardDamageAndMaxHP
	pop bc
	or a
	jr nz, .damaged
	ld d, 0
	scf
	ret

.damaged
	cp d
	jr nc, .got_amount_to_heal  ; is damage higher than amount to heal?
	ld d, a                     ; else, heal at most a damage
.got_amount_to_heal
	ld a, DUELVARS_ARENA_CARD_HP
	add e
	call GetTurnDuelistVariable
	add d
	ld [hl], a
	ret


Aromatherapy_HealEffect:
	call SetUsedPokemonPowerThisTurn
; play the global healing wind animation
	ld a, ATK_ANIM_HEALING_WIND
	bank1call PlayAdhocAnimationOnPlayAreaArena_NoEffectiveness
	; jr Heal10DamageFromAll_HealEffect
	; fallthrough

Heal10DamageFromAll_HealEffect:
	ld a, $ff
	ld d, 10
	jr HealNDamageFromAllMatchingPokemon

Heal20DamageFromAll_HealEffect:
	ld a, $ff
	ld d, 20
	jr HealNDamageFromAllMatchingPokemon

Heal30DamageFromAll_HealEffect:
	ld a, $ff
	ld d, 30
	; jr HealNDamageFromAllMatchingPokemon
	; fallthrough

; Heals some damage from all friendly Pokémon in Play Area (Active and Benched).
; input:
;   a - CARDTEST_* constant for pattern matching | $ff to match all
;   d - amount to heal
; uses: a, de, hl
; preserves: bc
; output:
;   carry: set if no Pokémon had damage to heal
HealNDamageFromAllMatchingPokemon:
	ld [wDataTableIndex], a
	push bc
; play the global healing wind animation (uses bc)
	; ld a, ATK_ANIM_HEALING_WIND
	; bank1call PlayAdhocAnimationOnPlayAreaArena_NoEffectiveness

	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld b, 0  ; how many were healed
	ld c, a  ; loop counter
	ld e, PLAY_AREA_ARENA

; go through every Pokemon in the Play Area and heal c damage.
.loop_play_area
	ld a, e
	ldh [hTempPlayAreaLocation_ff9d], a
	; e: PLAY_AREA_* of the tested Pokémon
	push de
	push bc
	call CheckPlayAreaPokemonMatchesStoredPattern
	pop bc
	pop de
	jr c, .no_damage
; there is a match
	push de
	call HealPlayAreaCardHP
	pop de
	jr c, .no_damage
	inc b
.no_damage
	inc e
	dec c
	jr nz, .loop_play_area
	ld a, b
	pop bc
	or a
	ret nz  ; some were healed
	scf
	ret  ; none healed


Heal20DamageFromAllEnergizedPokemon_HealEffect:
	ld a, CARDTEST_ENERGIZED_POKEMON
	ld d, 20
	jr HealNDamageFromAllMatchingPokemon


HealAllDamageEffect:
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	ld e, a ; all damage for recovery
	ld d, 0
	jp ApplyAndAnimateHPRecovery


; ------------------------------------------------------------------------------
; Status and Effects
; ------------------------------------------------------------------------------

; plays a healing animation for the arena Pokémon
; preserves: de
PlayStatusClearAnimation_ArenaPokemon:
	ld bc, $00
	ld a, ATK_ANIM_FULL_HEAL
	jr _PlayStatusClearAnimation

; plays a healing animation for a play area Pokémon
; input:
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* offset of card to heal
; preserves: de
PlayStatusClearAnimation_PlayAreaPokemon:
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld b, a
	ld c, WEAKNESS
	ld a, ATK_ANIM_GLOW_PLAY_AREA
	; jr _PlayStatusClearAnimation
	; fallthrough

_PlayStatusClearAnimation:
	push de
	bank1call PlayAdhocAnimationOnPlayAreaLocation
; print Pokemon card name
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD
	call LoadCardNameAndLevelFromVarToRam2
	ldtx hl, IsCuredOfStatusAndEffectsText
	call DrawWideTextBox_WaitForInput
	pop de
	ret


; Removes status conditions from turn holder's target.
; Input:
;    a: [0, 5] (PLAY_AREA_* offsets)
; Affects hl.
ClearStatusAndEffectsFromTargetEffect:
	ldh [hTempPlayAreaLocation_ff9d], a
	call ClearStatusFromTarget
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	jr nz, PlayStatusClearAnimation_PlayAreaPokemon
; arena Pokémon additionally clears all substatus effects from attacks
	; call ClearAllArenaEffectsAndSubstatus
	call ClearSubstatus2FromArenaPokemon
	jr PlayStatusClearAnimation_ArenaPokemon

; Removes status conditions from turn holder's target.
; Input:
;    a: [0, 5] (PLAY_AREA_* offsets)
; Affects hl.
ClearStatusFromTarget_NoAnim:
	push af
	call ClearStatusFromTarget
	pop af
	or a
	ret nz
	; arena Pokémon additionally clears all substatus effects from attacks
	; call ClearAllArenaEffectsAndSubstatus
	jr ClearSubstatus2FromArenaPokemon


; clears SUBSTATUS2 effects (harmful) from arena Pokémon
ClearSubstatus2FromArenaPokemon:
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS2
	call GetTurnDuelistVariable
	xor a
	ld [hl], a
	; ld l, DUELVARS_ARENA_CARD_CHANGED_WEAKNESS
	; ld [hl], a
	; ld l, DUELVARS_ARENA_CARD_CHANGED_RESISTANCE
	; ld [hl], a
	; ld l, DUELVARS_ARENA_CARD_CHANGED_TYPE
	; ld [hl], a
	ret


; input:
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the target Pokémon
Safeguard_StatusHealingEffect:
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	or a
	jr nz, .something_to_handle
; check effects
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	ret nz  ; no status or effects
	ld l, DUELVARS_ARENA_CARD_SUBSTATUS2
	ld a, [hl]
	or a
	ret z  ; no status or effects
.something_to_handle
	ldh a, [hTempPlayAreaLocation_ff9d]
	jp ClearStatusAndEffectsFromTargetEffect
