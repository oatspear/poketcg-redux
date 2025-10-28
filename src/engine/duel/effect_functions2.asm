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



EF2_PutDamageCountersInAnyWayYouLike_PlayerSelectEffect:
	; ldtx hl, ProcedureForPuttingDamageCountersText
	; bank1call DrawWholeScreenTextBox

; initialize damage counter list
	xor a
	ld hl, hTempList
	ld b, MAX_PLAY_AREA_POKEMON
.loop_init
	ld [hli], a
	dec b
	jr nz, .loop_init

	call EF2_CheckAnyPokemonAliveInPlayArea
	ret c  ; done if everything is KO

; store the current HP of all Pokémon for backup
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	ld de, wDuelTempList
	ld b, MAX_PLAY_AREA_POKEMON
	call CopyNBytesFromHLToDE

; handle player input to put damage counters
	xor a
	ldh [hCurSelectionItem], a
	bank1call SetupPlayAreaScreen
	call HandlePutDamageCountersInAnyWayYouLikeMenu

; restore the current HP of all Pokémon
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	ld e, l
	ld d, h
	ld hl, wDuelTempList
	ld b, MAX_PLAY_AREA_POKEMON
	call CopyNBytesFromHLToDE
	ret


HandlePutDamageCountersInAnyWayYouLikeMenu:
	bank1call PrintPlayAreaCardList_EnableLCD
	push af
	ldh a, [hCurSelectionItem]
	ld hl, .PlayAreaSelectionMenuParameters
	call InitializeMenuParameters
	pop af

	ld [wNumMenuItems], a
.loop_input
	call DoFrame
	call HandleMenuInput
	jr nc, .loop_input
	cp $ff
	jr nz, .a_button

; B button
; check if there is a damage counter to remove from this location
	ld a, [wCurMenuItem]
	ld e, a
	ld d, 0
	ld hl, hTempList
	add hl, de
	ld a, [hl]
	or a
	jr z, .loop_input  ; no damage counters
; remove 1 damage counter
	dec [hl]
	ld a, DUELVARS_ARENA_CARD_HP
	add e
	call GetTurnDuelistVariable
	add 10
	ld [hl], a
; increase the number of counters we have left
	; ld a, [wMaxMultiPlayAreaSelectionItems]
	; ld b, a
	ld a, [wCurMultiPlayAreaSelectionItem]
	inc a
	; cp b
	; jr c, .capped_items  ; still below max
	; ld a, b
; .capped_items
	ld [wCurMultiPlayAreaSelectionItem], a
	jr .loop_input

.a_button
	ldh [hCurSelectionItem], a
	add DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
; can't select Pokémon that are Knocked Out
	or a
	jr nz, .valid_choice

.play_sfx
	call PlaySFX_InvalidChoice
	jr .loop_input

.valid_choice
; put damage counter on the selected Pokémon for preview
	sub 10
	ld [hl], a
	ldh a, [hCurSelectionItem]  ; PLAY_AREA_*
	ld e, a
	ld d, 0
	ld hl, hTempList
	add hl, de
	inc [hl]
; decrease the number of counters we have left
	ld a, [wCurMultiPlayAreaSelectionItem]
	dec a
	ret z  ; done selecting
	ld [wCurMultiPlayAreaSelectionItem], a
	call EF2_CheckAnyPokemonAliveInPlayArea
	jr nc, .loop_input
	; xor a
	ret  ; no more Pokémon left to choose

.PlayAreaSelectionMenuParameters
	db 0, 0 ; cursor x, cursor y
	db 3 ; y displacement between items
	db MAX_PLAY_AREA_POKEMON ; number of items
	db SYM_CURSOR_R ; cursor tile number
	db SYM_SPACE ; tile behind cursor
	dw NULL ; function pointer if non-0


EF2_CheckAnyPokemonAliveInPlayArea:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	ld l, DUELVARS_ARENA_CARD_HP
	inc c
	jr .next_pkmn
.loop
	ld a, [hli]
	or a
	ret nz  ; found a Pokémon that is alive
.next_pkmn
	dec c
	jr nz, .loop
	scf
	ret





EF2_SelectUpTo2Benched_AISelectEffect:
; if Bench has 2 Pokemon or less, no need for selection,
; since AI will choose them all.
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	cp 3 + 1  ; 3 benched + arena
	jr nc, .start_selection

; select them all
	ld hl, hTempList
	ld b, PLAY_AREA_ARENA
	jr .next_bench
.select_bench
	ld [hl], b
	inc hl
.next_bench
	inc b
	dec a
	jr nz, .select_bench
	ld [hl], $ff ; terminating byte
	ret

.start_selection
; has more than 2 Bench cards, proceed to sort them
; by lowest remaining HP to highest, and pick first 2.
	call SwapTurn
	dec a
	ld c, a
	ld b, PLAY_AREA_BENCH_1

; first select all of the Bench Pokemon and write to list
	ld hl, hTempList
.loop_all
	ld [hl], b
	inc hl
	inc b
	dec c
	jr nz, .loop_all
	ld [hl], $00 ; end list with $00

; then check each of the Bench Pokemon HP
; sort them from lowest remaining HP to highest.
	ld de, hTempList
.loop_outer
	ld a, [de]
	add DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	ld c, a
	ld l, e
	ld h, d
	inc hl

.loop_inner
	ld a, [hli]
	or a
	jr z, .next ; reaching $00 means it's end of list

	push hl
	add DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	pop hl
	cp c
	jr c, .loop_inner
	; a Bench Pokemon was found with less HP
	ld c, a ; store its HP

; switch the two
	dec hl
	ld b, [hl]
	ld a, [de]
	ld [hli], a
	ld a, b
	ld [de], a
	jr .loop_inner

.next
	inc de
	ld a, [de]
	or a
	jr nz, .loop_outer

; done
	ld a, $ff ; terminating byte
	ldh [hTempList + 3], a
	jp SwapTurn


EF2_SelectUpTo2Benched_PlayerSelectEffect:
	call SwapTurn
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	cp 2
	jr nc, .has_bench
	call SwapTurn
	ld a, $ff
	ldh [hTempList], a
	ret

.has_bench
	ldtx hl, ChooseUpTo2PokemonOnBenchToGiveDamageText
	call DrawWideTextBox_WaitForInput

; init number of items in list and cursor position
	xor a
	ldh [hCurSelectionItem], a
	ld [wCurMultiPlayAreaSelectionItem], a
	bank1call SetDefaultConsolePalettes
	bank1call SetupPlayAreaScreen
.start
	bank1call PrintPlayAreaCardList_EnableLCD
	push af
	ld a, [wCurMultiPlayAreaSelectionItem]
	ld hl, BenchSelectionMenuParameters
	call InitializeMenuParameters
	pop af

; exclude Arena Pokemon from number of items
	dec a
	ld [wNumMenuItems], a

.loop_input
	call DoFrame
	call HandleMenuInput
	jr nc, .loop_input
	cp -1
	jr z, .try_cancel

	ld [wCurMultiPlayAreaSelectionItem], a
	call .CheckIfChosenAlready
	jr nc, .not_chosen
	; play SFX
	call PlaySFX_InvalidChoice
	jr .loop_input

.not_chosen
; mark this Play Area location
	ldh a, [hCurMenuItem]
	inc a
	ld b, SYM_HP_NOK
	call EF2_DrawSymbolOnPlayAreaCursor
; store it in the list of chosen Bench Pokemon
	call EF2_GetNextPositionInTempList
	ldh a, [hCurMenuItem]
	inc a
	ld [hl], a

; check if 2 were chosen already
	ldh a, [hCurSelectionItem]
	ld c, a
	cp 2
	jr nc, .chosen ; check if already chose 2

	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	dec a
	cp c
	jr nz, .start ; if sill more options available, loop back
	; fallthrough if no other options available to choose

.chosen
	ldh a, [hCurMenuItem]
	inc a
	ldh [hTempPlayAreaLocation_ff9d], a
	bank1call Func_2c10b
	ldh a, [hKeysPressed]
	and B_BUTTON
	jr nz, .try_cancel
	call SwapTurn
	call EF2_GetNextPositionInTempList
	ld [hl], $ff ; terminating byte
	ret

.try_cancel
	ldh a, [hCurSelectionItem]
	or a
	jr z, .start ; none selected, can safely loop back to start

; undo last selection made
	dec a
	ldh [hCurSelectionItem], a
	ld e, a
	ld d, $00
	ld hl, hTempList
	add hl, de
	ld a, [hl]

	push af
	ld b, SYM_SPACE
	call EF2_DrawSymbolOnPlayAreaCursor
	call EraseCursor
	pop af

	dec a
	ld [wCurMultiPlayAreaSelectionItem], a
	jp .start

; returns carry if Bench Pokemon
; in register a was already chosen.
.CheckIfChosenAlready: ; 2e6af (b:66af)
	inc a
	ld c, a
	ldh a, [hCurSelectionItem]
	ld b, a
	ld hl, hTempList
	inc b
	jr .next_check
.check_chosen
	ld a, [hli]
	cp c
	scf
	ret z ; return if chosen already
.next_check
	dec b
	jr nz, .check_chosen
	or a
	ret


BenchSelectionMenuParameters: ; 2c6e8 (b:46e8)
	db 0, 3 ; cursor x, cursor y
	db 3 ; y displacement between items
	db MAX_PLAY_AREA_POKEMON ; number of items
	db SYM_CURSOR_R ; cursor tile number
	db SYM_SPACE ; tile behind cursor
	dw NULL ; function pointer if non-0


EF2_DrawSymbolOnPlayAreaCursor:
	ld c, a
	add a
	add c
	add 2
	; a = 3*a + 2
	ld c, a
	ld a, b
	ld b, 0
	jp WriteByteToBGMap0


; outputs in hl the next position
; in hTempList to place a new card,
; and increments hCurSelectionItem.
EF2_GetNextPositionInTempList:
	push de
	ld hl, hCurSelectionItem
	ld a, [hl]
	inc [hl]
	ld e, a
	ld d, $00
	ld hl, hTempList
	add hl, de
	pop de
	ret
