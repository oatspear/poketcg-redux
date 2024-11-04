; ------------------------------------------------------------------------------
; Pokémon Evolution
; ------------------------------------------------------------------------------

AdaptiveEvolution_AllowEvolutionEffect:
	ldh a, [hTempPlayAreaLocation_ff9d]  ; triggering Pokémon
	add DUELVARS_ARENA_CARD_FLAGS
	call GetTurnDuelistVariable
	set CAN_EVOLVE_THIS_TURN_F, [hl]
	ret


; deck search is not cancellable
PokemonBreeder_PlayerSelectEffect:
	call CreateDeckCardList
	ld e, CARDTEST_EVOLUTION_POKEMON
	call PlayerSelectEvolutionFromDeck_Preamble
	ret c  ; none in deck, Player refused to look

; select an Evolution card from the deck
.loop_deck
	call HandlePlayerSelectionEvolutionPokemonFromDeckList
	ret c  ; no Pokémon | Player cancelled
	; [hTempCardIndex_ff98]: deck index of the Evolution card
	ld a, CARDTEST_EVOLVES_INTO
	call CheckSomeMatchingPokemonInPlayArea
	jr nc, .got_valid_card
	call PlaySFX_InvalidChoice
	jr .loop_deck

; store the selected Evolution card
.got_valid_card
	ldh a, [hTempCardIndex_ff98]
	ldh [hTemp_ffa0], a

; choose a Pokémon in the play area to evolve
.loop_play_area
	; ldh a, [hTemp_ffa0]
	; ldh [hTempCardIndex_ff98], a
	ld a, CARDTEST_EVOLVES_INTO
	call HandlePlayerSelectionMatchingPokemonInPlayArea_AllowCancel
	jr nc, .can_evolve
	call PlaySFX_InvalidChoice
	ldtx hl, ChoosePokemonToEvolveText
	call DrawWideTextBox_WaitForInput
	jr .loop_play_area  ; not a valid Pokémon

.can_evolve
	ldh [hTempPlayAreaLocation_ffa1], a
	or a
	ret



EvolvePlayAreaPokemonFromDeck_PlayerSelectEffect:
	ldtx hl, ChoosePokemonToEvolveText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionPokemonInPlayArea  ; forced
	; [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the selected Pokémon
	jr EvolutionFromDeck_PlayerSelectEffect


EvolveArenaPokemonFromDeck_PlayerSelectEffect:
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ff9d], a
	; jr EvolutionFromDeck_PlayerSelectEffect
	; fallthrough

; input:
;   [hTempPlayAreaLocation_ff9d]: PLAY_AREA_* of the evolving Pokémon
; output:
;   a: deck index of the selected Evolution card (if valid)
;   [hTemp_ffa0]: deck index of the selected Evolution card | $ff
;   [hTempPlayAreaLocation_ffa1]: PLAY_AREA_* of the evolving Pokémon
;   carry: set if the Player did not choose a valid Evolution card
EvolutionFromDeck_PlayerSelectEffect:
	call CreateDeckCardList
	ld e, CARDTEST_EVOLUTION_OF_PLAY_AREA
	call PlayerSelectEvolutionFromDeck_Preamble
	ret c  ; none in deck, Player refused to look

; select an Evolution card from the deck
.loop_deck
	call HandlePlayerSelectionEvolutionPokemonFromDeckList
	ret c  ; no Pokémon | Player cancelled
	; [hTempCardIndex_ff98]: deck index of the Evolution card
	ld [wDynamicFunctionArgument], a
	call CardTypeTest_IsEvolutionOfPlayArea
	jr c, .got_valid_card
	call PlaySFX_InvalidChoice
	jr .loop_deck

; store the selected Evolution card
.got_valid_card
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	ldh a, [hTempCardIndex_ff98]
	ldh [hTemp_ffa0], a
	or a
	ret


; input:
;   e: CARDTEST_* pattern of the intended card
; output:
;   carry: set if none in deck and Player refused to look
PlayerSelectEvolutionFromDeck_Preamble:
	ld a, $ff
	ldh [hTemp_ffa0], a
	ldh [hTempPlayAreaLocation_ffa1], a
; search for an Evolution card in the deck
	ldtx hl, ChooseEvolvedPokemonFromDeckText
	ldtx bc, EvolvedPokemonText
	ld a, e
	call LookForCardsInDeckList
	ret  ; carry: none in deck, Player refused to look


EvolveArenaPokemonFromDeck_AISelectEffect:
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	; jr EvolutionFromDeck_AISelectEffect
	; fallthrough

; selects the first suitable card in the Deck
; input:
;   [hTempPlayAreaLocation_ffa1]: PLAY_AREA_* of the card to evolve
EvolutionFromDeck_AISelectEffect:
	; call IsPrehistoricPowerActive
	; jr nc, .search
	ld a, $ff
	ldh [hTemp_ffa0], a
	; ret
.search
	call CreateDeckCardList
	ldh a, [hTempPlayAreaLocation_ffa1]
	ldh [hTempPlayAreaLocation_ff9d], a
	ld a, CARDTEST_EVOLUTION_OF_PLAY_AREA
	call SearchDuelTempListForMatchingCard
	ldh [hTemp_ffa0], a
	or a
	ret


; Evolves and heals the user.
Hatch_EvolveEffect:
	ld e, 20
	call HealUserHP_NoAnimation
	call ClearStatusFromTarget_NoAnim
	; fallthrough

; Adds the selected card to the turn holder's Hand (temporarily)
; and then evolves the selected Pokémon using the selected card.
EvolutionFromDeck_EvolveEffect:
; check if a card was chosen from the deck
	ldh a, [hTemp_ffa0]
	cp $ff
	jp z, SyncShuffleDeck ; skip if no evolution card was chosen

; add evolution card to the hand and skip showing it on screen
	call SearchCardInDeckAndSetToJustDrawn
	call AddCardToHand

; proceed into Breeder-like evolution code
	ldh a, [hTempCardIndex_ff9f]
	push af
; store deck index of evolution card in [hTempCardIndex_ff98]
	ldh a, [hTemp_ffa0]
	ldh [hTempCardIndex_ff98], a
; store play area slot of the evolving card in [hTempPlayAreaLocation_ff9d]
	ldh a, [hTempPlayAreaLocation_ffa1]
	ldh [hTempPlayAreaLocation_ff9d], a

; load the evolving Pokémon card name to RAM
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex
	call LoadCard1NameToRamText

	call EvolvePokemonCard

; load evolved Pokémon card name to RAM
; TODO FIXME optimize: maybe unnecessary to load card again from EvolvePokemonCard
	ldh a, [hTempCardIndex_ff98]
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, 18
	call CopyCardNameAndLevel
	xor a
	ld [hl], a ; $0 character
	ld hl, wTxRam2_b
	ld [hli], a
	ld [hl], a

; display Pokemon picture and play sfx,
; print the corresponding card names.
	bank1call DrawLargePictureOfCard
	ld a, $5e
	call PlaySFX
	ldtx hl, PokemonEvolvedIntoPokemonText
	call DrawWideTextBox_WaitForInput
; FIXME this is harmless, but probably turn off Pokémon Powers in general code
; this is the one that changes hTempCardIndex_ff9f
	call OnPokemonPlayedInitVariablesAndPowers
	bank1call HandleOnEvolvePokemonEffects
	pop af
	ldh [hTempCardIndex_ff9f], a
	jp SyncShuffleDeck


; ------------------------------------------------------------------------------
; Pokémon Devolution
; ------------------------------------------------------------------------------


DevolveDefendingPokemonEffect:
; did this attack KO the Defending Pokémon?
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	or a
	ret z  ; nothing to do

; is the Defending Pokémon a Basic Pokémon?
	ld a, DUELVARS_ARENA_CARD_STAGE
	call GetNonTurnDuelistVariable
	or a  ; BASIC
	ret z  ; nothing to do

; devolve the Defending Pokémon
	ld a, 1  ; opponent's Play Area
	ldh [hTemp_ffa0], a
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a

	call SwapTurn
	call HandleNoDamageOrEffect
	jp c, SwapTurn  ; exit

	; ld b, PLAY_AREA_ARENA
	; ld c, $00
	call TryDevolveSelectedPokemonEffect
	call SwapTurn
	; refresh screen to show devolved Pokémon
	xor a  ; REFRESH_DUEL_SCREEN
	ld [wDuelDisplayedScreen], a
	bank1call DrawDuelMainScene
	ret


TryDevolveSelectedPokemonEffect:
	; load selected card's data
	ldh a, [hTempPlayAreaLocation_ffa1]
	ldh [hTempPlayAreaLocation_ff9d], a
	ld [wTempPlayAreaLocation_cceb], a
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex

; check if card is affected
	ld a, [wLoadedCard1ID]
	ld [wTempNonTurnDuelistCardID], a
	ld de, $0
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	jr nz, .skip_substatus_check
	call HandleNoDamageOrEffectSubstatus
	jr c, .check_no_damage_effect
.skip_substatus_check
	call HandleDamageReductionOrNoDamageFromPkmnPowerEffects
.check_no_damage_effect
	call CheckNoDamageOrEffect
	jp c, DrawWideTextBox_WaitForInput
	; fallthrough

DevolveSelectedPokemonEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	call DevolvePokemon
	ld a, e
	call PrintDevolvedCardNameAndLevelText
; refresh screen to show devolved Pokémon
	xor a  ; REFRESH_DUEL_SCREEN
	ld [wDuelDisplayedScreen], a
	bank1call DrawDuelMainScene
; check if this devolution is a Knock Out
	ldh a, [hTempPlayAreaLocation_ffa1]
	call PrintPlayAreaCardKnockedOutIfNoHP
	ret nc  ; not Knocked Out
	bank1call ClearKnockedOutPokemon_TakePrizes_CheckGameOutcome
	ret


DevolveTurnHolderArenaPokemonEffect:
; is the Active Pokémon a Basic Pokémon?
	ld a, DUELVARS_ARENA_CARD_STAGE
	call GetTurnDuelistVariable
	or a  ; BASIC
	ret z  ; nothing to do
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	jr DevolveSelectedPokemonEffect


;
DevolutionSpray_DevolutionEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	; cp $ff
	; ret z
	ld b, a
	ld a, ATK_ANIM_GLOW_PLAY_AREA
	bank1call PlayAdhocAnimationOnPlayAreaLocation_NoEffectiveness
	jr DevolveSelectedPokemonEffect
	; bank1call DrawDuelHUDs


; Devolves a Pokémon in the turn holder's Play Area and returns the
; highest Stage card to the turn holder's hand.
; input:
;   a: PLAY_AREA_* of the target Pokémon
; output:
;   d: deck index of the lower stage Pokémon (after devolving)
;   e: deck index of the higher stage Pokémon (before devolving)
DevolvePokemon:
	ldh [hTempPlayAreaLocation_ff9d], a
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	bank1call GetCardOneStageBelow
	; d: deck index of the lower stage card
	; e: deck index of the higher stage card
; add the evolved card to the hand
	ld a, e
	call AddCardToHand  ; preserves af, hl, de
; update the devolved card's stats and status
	ld a, d
	call UpdateDevolvedCardHPAndStage  ; preserves bc, de
	; jr ResetDevolvedCardStatus       ; preserves bc, de
	; fallthrough

; Reset status and effects after devolving card.
; preserves: bc, de
ResetDevolvedCardStatus:
	push de
	ld de, CELADON_GYM
	call CheckStadiumIDInPlayArea  ; preserves: bc, de
	pop de
	jr nc, .clear_effects  ; found stadium
; clear status conditions
	ldh a, [hTempPlayAreaLocation_ff9d]
	call ClearStatusFromTarget  ; preserves bc, de
.clear_effects
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a  ; cp PLAY_AREA_ARENA
	call z, ClearAllArenaEffectsAndSubstatus  ; preserves hl, bc, de
; reset changed color status
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD_CHANGED_TYPE
	call GetTurnDuelistVariable
	ld [hl], $00
; reset C2 flags
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD_FLAGS
	ld l, a
	ld [hl], $00
	ret


; Overwrites HP and Stage data of the card that was devolved
; in the Play Area to the values of new card.
; If the damage exceeds HP of pre-evolution, then HP is set to zero.
; input:
;	  a: deck index of pre-evolved card
;   wAllStagesIndices: populated from GetCardOneStageBelow
; preserves: bc, de
UpdateDevolvedCardHPAndStage:
	push bc
	push de
	push af
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld e, a
	call GetCardDamageAndMaxHP
	ld b, a ; store damage
	ld a, e
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	pop af

	ld [hl], a
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, e
	add DUELVARS_ARENA_CARD_HP
	ld l, a
	ld a, [wLoadedCard2HP]
	sub b ; subtract damage from new HP
	jr nc, .got_hp
	; damage exceeds HP
	xor a ; 0 HP
.got_hp
	ld [hl], a
	ld a, e
; overwrite card stage
	add DUELVARS_ARENA_CARD_STAGE
	ld l, a
; check for Stage 2 regression to revived Stage 1 (no Basic)
	ld a, [wLoadedCard2Stage]
	cp STAGE1
	jr nz, .got_stage
; does this Stage 1 Pokémon have a Basic Pokémon underneath it?
	ld a, [wAllStagesIndices]
	cp $ff
	ld a, [wLoadedCard2Stage]
	jr nz, .got_stage
; force a Basic stage for a Stage 1 without a Basic underneath
	xor a  ; BASIC
.got_stage
	ld [hl], a
	pop de
	pop bc
	ret


; prints the text "<X> devolved to <Y>!" with
; the proper card names and levels.
; input:
;	  d: deck index of the lower stage card
;	  e: deck index of card that was devolved
PrintDevolvedCardNameAndLevelText:
	; push de
	ld a, e
	call LoadCardDataToBuffer1_FromDeckIndex
	ld bc, wTxRam2
	ld hl, wLoadedCard1Name
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hl]
	ld [bc], a

	inc bc ; wTxRam2_b
	xor a
	ld [bc], a
	inc bc
	ld [bc], a

	ld a, d
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, 18
	call CopyCardNameAndLevel
	ld [hl], $00
	ldtx hl, PokemonDevolvedToText
	call DrawWideTextBox_WaitForInput
	; pop de
	ret
