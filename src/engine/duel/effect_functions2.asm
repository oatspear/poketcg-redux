EF2_AIPickEnergyCardToDiscardFromDefendingPokemon:
	call SwapTurn
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies

	xor a
	call CreateArenaOrBenchEnergyCardList
	jr nc, .has_energy
	; no energy, return
	ld a, $ff
	jp SwapTurn

.has_energy
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex
	ld e, COLORLESS
	ld a, [wAttachedEnergies + COLORLESS]
	or a
	jr nz, .pick_color ; has colorless attached?

	; no colorless energy attached.
	; if it's colorless Pokemon, just
	; pick any energy card at random...
	ld a, [wLoadedCard1Type]
	cp COLORLESS
	jr nc, .choose_random

	; ...if not, check if it has its
	; own color energy attached.
	; if it doesn't, pick at random.
	ld e, a
	ld d, $00
	ld hl, wAttachedEnergies
	add hl, de
	ld a, [hl]
	or a
	jr z, .choose_random

; pick attached card with same color as e
.pick_color
	ld hl, wDuelTempList
.loop_energy
	ld a, [hli]
	cp $ff
	jr z, .choose_random
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	and TYPE_PKMN
	cp e
	jr nz, .loop_energy
	dec hl

.done_chosen
	ld a, [hl]
	jp SwapTurn

.choose_random
	call CountCardsInDuelTempList
	ld hl, wDuelTempList
	call ShuffleCards
	jr .done_chosen


EF2_AIPickAttackForAmnesia:
; load Defending Pokemon attacks
	call SwapTurn
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ld d, a
	call LoadCardDataToBuffer2_FromDeckIndex
; if has no attack 1 name, return
	ld hl, wLoadedCard2Atk1Name
	ld a, [hli]
	or [hl]
	jr z, .chosen

; if Defending Pokemon has enough energy for second attack, choose it
	ld e, SECOND_ATTACK
	bank1call _CheckIfEnoughEnergiesToAttack
	jr nc, .chosen
; otherwise if first attack isn't a Pkmn Power, choose it instead.
	ld e, FIRST_ATTACK_OR_PKMN_POWER
	ld a, [wLoadedCard2Atk1Category]
	and ABILITY
	jr z, .chosen
; if it is an ability, choose second attack.
	ld e, SECOND_ATTACK
.chosen
	ld a, e
	jp SwapTurn


EF2_GetBenchPokemonWithLowestHP:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	lb de, PLAY_AREA_ARENA, $ff
	ld b, d
	ld a, DUELVARS_BENCH1_CARD_HP
	call GetTurnDuelistVariable
	jr .start
; find Play Area location with least amount of HP
.loop_bench
	ld a, e
	cp [hl]
	jr c, .next ; skip if HP is higher
	ld e, [hl]
	ld d, b

.next
	inc hl
.start
	inc b
	dec c
	jr nz, .loop_bench

	ld a, d
	ret
