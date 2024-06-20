; ------------------------------------------------------------------------------
; Card Lists and Filters
; ------------------------------------------------------------------------------


; FIXME: could use RemoveCardFromDuelTempList instead of this
; removes the card pointed at in hl from wDuelTempList
; input:
;   wDuelTempList: must be built
;   hl: pointer to a position in wDuelTempList
; preserves: bc
CardList_RemoveCurrentPosition:
  ld e, l
	ld d, h
	inc hl
.loop
  ld a, [hli]
  ld [de], a
  cp $ff  ; terminating byte
  ret z
  inc de
  jr .loop


CardList_GetFirstTrainer:
	ld b, TYPE_TRAINER
	ld c, $ff
	jr CardList_GetFirstOfCardType

CardList_GetFirstPokemon:
	ld b, TYPE_PKMN_FIRE
	ld c, TYPE_ENERGY
	jr CardList_GetFirstOfCardType

CardList_GetFirstEnergy:
	ld b, TYPE_ENERGY
	ld c, TYPE_TRAINER
	; jr CardList_GetFirstOfCardType
	; fallthrough

; return in a deck index of card or $ff
; input:
;   b: min. TYPE_* constant to search for (e.g. TYPE_ENERGY)
;   c: max. TYPE_* constant to search for (e.g. TYPE_TRAINER)
; output:
;   a: deck index of the first matching card | $ff
;   hl: position in the list where the card was found | end of list
;   carry: set if none found
; preserves: de
CardList_GetFirstOfCardType:
	ld hl, wDuelTempList
.loop_cards
	ld a, [hl]
	cp $ff
	jr z, .none_found
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp b
	jr c, .next
	cp c
	jr nc, .next
; found
	ld a, [hl]
	or a
	ret
.next
	inc hl
	jr .loop_cards
.none_found
	scf
	ret


CardList_TakeFirstTrainer:
	call CardList_GetFirstTrainer
	ret c  ; none found
	ld c, a
	call CardList_RemoveCurrentPosition  ; preserves bc
	ld a, c
	ret

CardList_TakeFirstPokemon:
	call CardList_GetFirstPokemon
	ret c  ; none found
	ld c, a
	call CardList_RemoveCurrentPosition  ; preserves bc
	ld a, c
	ret

CardList_TakeFirstEnergy:
	call CardList_GetFirstEnergy
	ret c  ; none found
	ld c, a
	call CardList_RemoveCurrentPosition  ; preserves bc
	ld a, c
	ret

CardList_TakeFirstCard:
	ld hl, wDuelTempList
	ld a, [hl]
	cp $ff
	jr z, .none_found
	ld c, a
	call CardList_RemoveCurrentPosition  ; preserves bc
	ld a, c
	ret
.none_found
	scf
	ret


; ------------------------------------------------------------------------------
; AI Card Selection Effects
; ------------------------------------------------------------------------------


; assume:
;   - the opponent has basic energy cards in discard pile (from Special Attack AI)
AISelect_Prank:
	ld a, $ff
	ldh [hTempList], a
	ldh [hTempList + 1], a
	call SwapTurn
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	jr c, .done
; get the first energy
	ld a, [wDuelTempList]
	ldh [hTempList], a
.done
	or a
	jp SwapTurn


AISelect_Rototiller:
	ld a, $ff
	ldh [hTempList], a
	ldh [hTempList + 1], a
	ldh [hTempList + 2], a
	ldh [hTempList + 3], a
	ldh [hTempList + 4], a
	call CreateDiscardPileCardList
	jr c, .done
; start loop
	ld c, 4
	ld hl, hTempList
.loop
; try to get an energy first
	push hl
	call CardList_TakeFirstEnergy
	pop hl
	jr nc, .store_card
; try to get a Pokémon
	push hl
	call CardList_TakeFirstPokemon
	pop hl
	jr nc, .store_card
; try to get something else
	push hl
	call CardList_TakeFirstCard
	pop hl
	jr c, .done  ; no more cards
.store_card
	ld [hl], a
	inc hl
	dec c
	jr nz, .loop
.done
	or a
	ret


; assume card list is already initialized from precondition check
; FIXME improve
AISelect_AquaticRescue:
	ld a, $ff
	ldh [hTempList], a
	ldh [hTempList + 1], a
	ldh [hTempList + 2], a
	ldh [hTempList + 3], a
	ld c, 3
	ld de, wDuelTempList
	ld hl, hTempList
.loop
	ld a, [de]
	cp $ff
	ret z
	inc de
	ld [hl], a
	inc hl
	dec c
	ret z
	jr .loop
