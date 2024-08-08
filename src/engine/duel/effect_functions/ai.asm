; ------------------------------------------------------------------------------
; AI Selection
; ------------------------------------------------------------------------------


; store deck index of selected card or $ff in [hTemp_ffa0]
ChoosePokemonFromDeck_AISelectEffect:
; TODO FIXME
	ld a, $ff
	ldh [hTemp_ffa0], a
	ret


OptionalDoubleDamage_AISelectEffect:
	call ApplyDamageModifiers_DamageToTarget  ; damage in e
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	cp e
	jr c, .no  ; current HP is less than minimum damage
	ld a, e
	add a
	cp [hl]
	ld a, 1
	jr nc, .store  ; double damage is enough
.no
	xor a
.store
	ldh [hTemp_ffa0], a
	ret


Prank_AISelectEffect:
	farcall AISelect_Prank
	ret


; ------------------------------------------------------------------------------
; AI Scoring
; ------------------------------------------------------------------------------


DoubleHit_AIEffect:
	call CheckArenaPokemonHas2OrMoreEnergiesAttached
	ret c
	ld a, [wDamage]
	add a
	call AddToDamage
	jp SetDefiniteAIDamage


TripleHit_AIEffect:
	call CheckArenaPokemonHas3OrMoreEnergiesAttached
	cp 2
	ret c  ; once
; twice
	dec a
	ld c, a
	ld a, [wDamage]
	ld d, a
	add d
	dec c
	jr z, .update
; thrice
	add d
.update
	call AddToDamage
	jp SetDefiniteAIDamage


Put1DamageCounterOnTarget_AIEffect:
	ld a, 10
	lb de, 10, 10
	jp UpdateExpectedAIDamage


IgnitedVoltage_AIEffect:
	ld a, CARDTEST_ENERGIZED_MAGMAR
	call CheckSomeMatchingPokemonInBench
	ret c
; energized Magmar is available
	ld a, 10
	lb de, 10, 40
	jp UpdateExpectedAIDamage


SearingSpark_AIEffect:
	ld a, CARDTEST_ENERGIZED_ELECTABUZZ
	call CheckSomeMatchingPokemonInBench
	ret c
; energized Electabuzz is available
	ld a, 20
	lb de, 20, 50
	jp UpdateExpectedAIDamage


; ------------------------------------------------------------------------------
; Trainer Cards
; ------------------------------------------------------------------------------
