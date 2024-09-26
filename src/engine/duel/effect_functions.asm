; ------------------------------------------------------------------------------
; Dummy Functions
; ------------------------------------------------------------------------------

PassivePowerEffect:
	scf
	; fallthrough

NullEffect:
	ret

; ------------------------------------------------------------------------------
; Status Effects
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/status.asm"

INCLUDE "engine/duel/effect_functions/substatus.asm"


HyperHypnosis_DiscardSleepEffect:
	call SetUsedPokemonPowerThisTurn_RestoreTrigger
	ldh a, [hEnergyTransEnergyCard]
	cp $ff
	ret z
; discard energy
	call PutCardInDiscardPile
; inflict status
	call SwapTurn
	ld e, PLAY_AREA_ARENA
	call SleepEffect_PlayArea
	call SwapTurn
; handle failure
	jr c, .animation
	ldtx hl, ThereWasNoEffectFromSleepText
	jp DrawWideTextBox_WaitForInput
.animation
	; bank1call DrawDuelMainScene
	xor a
	ld [wDuelAnimLocationParam], a
	ld a, ATK_ANIM_SLEEP
	bank1call PlayAdhocAnimationOnPlayAreaArena_NoEffectiveness
	ret


; ------------------------------------------------------------------------------
; Pokémon Evolution
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/evolution.asm"


RareCandy_HandPlayAreaCheck:
	call CreatePlayableStage2PokemonCardListFromHand
	jr c, .cannot_evolve
	jp IsPrehistoricPowerActive
.cannot_evolve
	ldtx hl, ConditionsForEvolvingToStage2NotFulfilledText
	scf
	ret

RareCandy_PlayerSelection:
; create hand list of playable Stage2 cards
	call CreatePlayableStage2PokemonCardListFromHand
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck

; handle Player selection of Stage2 card
	ldtx hl, PleaseSelectCardText
	ldtx de, DuelistHandText
	bank1call SetCardListHeaderText
	bank1call DisplayCardList
	ret c ; exit if B was pressed

	ldh a, [hTempCardIndex_ff98]
	ldh [hTemp_ffa0], a
	ldtx hl, ChoosePokemonToEvolveText
	call DrawWideTextBox_WaitForInput

; handle Player selection of Basic card to evolve
	bank1call HasAlivePokemonInPlayArea
.read_input
	bank1call OpenPlayAreaScreenForSelection
	ret c ; exit if B was pressed
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	ld e, a
	ldh a, [hTemp_ffa0]
	ld d, a
	call CheckIfCanEvolveInto_BasicToStage2
	jr c, .read_input ; loop back if cannot evolve this card
	or a
	ret

RareCandy_EvolveEffect:
	ldh a, [hTempCardIndex_ff9f]
	push af
	ld hl, hTemp_ffa0
	ld a, [hli]
	ldh [hTempCardIndex_ff98], a
	ld a, [hl] ; hTempPlayAreaLocation_ffa1
	ldh [hTempPlayAreaLocation_ff9d], a

; load the Basic Pokemon card name to RAM
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex
	call LoadCard1NameToRamText

; evolve card and overwrite its stage as STAGE2_WITHOUT_STAGE1
	ldh a, [hTempCardIndex_ff98]
	call EvolvePokemonCard
	ld [hl], STAGE2_WITHOUT_STAGE1

; load Stage2 Pokemon card name to RAM
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
	call OnPokemonPlayedInitVariablesAndPowers
	bank1call HandleOnEvolvePokemonEffects
	pop af
	ldh [hTempCardIndex_ff9f], a
	ret

; creates list in wDuelTempList of all Stage2 Pokemon cards
; in the hand that can evolve a Basic Pokemon card in Play Area
; through use of Rare Candy.
; returns carry if that list is empty.
CreatePlayableStage2PokemonCardListFromHand: ; 2f73e (b:773e)
	call CreateHandCardList
	ret c ; return if no hand cards

; check if hand Stage2 Pokemon cards can be made
; to evolve a Basic Pokemon in the Play Area and, if so,
; add it to the wDuelTempList.
	ld hl, wDuelTempList
	ld e, l
	ld d, h
.loop_hand
	ld a, [hl]
	cp $ff
	jr z, .done
	call .CheckIfCanEvolveAnyPlayAreaBasicCard
	jr c, .next_hand_card
	ld a, [hl]
	ld [de], a
	inc de
.next_hand_card
	inc hl
	jr .loop_hand

.done
	ld a, $ff ; terminating byte
	ld [de], a
	ld a, [wDuelTempList]
	cp $ff
	scf
	ret z ; return carry if empty
	; not empty
	or a
	ret

; return carry if Stage2 card in a cannot evolve any
; of the Basic Pokemon in Play Area through Rare Candy.
.CheckIfCanEvolveAnyPlayAreaBasicCard
	push de
	ld d, a
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY
	jr nc, .set_carry ; skip if not Pokemon card
	ld a, [wLoadedCard2Stage]
	cp STAGE2
	jr nz, .set_carry ; skip if not Stage2

; check if can evolve any Play Area cards
	push hl
	push bc
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	ld e, PLAY_AREA_ARENA
.loop_play_area
	push bc
	push de
	call CheckIfCanEvolveInto_BasicToStage2
	pop de
	pop bc
	jr nc, .done_play_area
	inc e
	dec c
	jr nz, .loop_play_area
; set carry
	scf
.done_play_area
	pop bc
	pop hl
	pop de
	ret
.set_carry
	pop de
	scf
	ret


; ------------------------------------------------------------------------------


SetNoEffectFromStatus: ; 2c09c (b:409c)
	ld a, EFFECT_FAILED_NO_EFFECT
	ld [wEffectFailed], a
	ret


Func_2c0a8: ; 2c0a8 (b:40a8)
	ldh a, [hTemp_ffa0]
	push af
	ldh a, [hWhoseTurn]
	ldh [hTemp_ffa0], a
	ld a, OPPACTION_6B30
	call SetOppAction_SerialSendDuelData
	bank1call AnimateShuffleDeck
	ld c, a
	pop af
	ldh [hTemp_ffa0], a
	ld a, c
	ret


SyncShuffleDeck:
	call ExchangeRNG
	bank1call AnimateShuffleDeck
	jp ShuffleDeck


; ------------------------------------------------------------------------------
; Checks and Tests
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/checks.asm"


HyperHypnosis_PreconditionCheck:
	call CheckPokemonPowerCanBeUsed_StoreTrigger
	ret c
	jp CheckPlayAreaPokemonHasAnyEnergiesAttached


Aromatherapy_PreconditionCheck:
Mischief_PreconditionCheck:
	call CheckPokemonPowerCanBeUsed_StoreTrigger
	ret c
	call CheckPlayAreaPokemonHasAnyEnergiesAttached
	ret c
	jp CheckIfPlayAreaHasAnyDamage


Maintenance_CheckHandAndDiscardPile:
	call CheckHandSizeGreaterThan1
	ret c
	jp CreateItemCardListFromDiscardPile


AssassinFlight_CheckBenchAndStatus:
	call CheckDefendingPokemonHasStatus
	ret c
	jp CheckOpponentBenchIsNotEmpty


Trade_PreconditionCheck:
	call CheckHandIsNotEmpty
	ret c
	jr DrawOrTutorAbility_PreconditionCheck

; this Power needs to back up hTempPlayAreaLocation_ff9d
EnergyGenerator_PreconditionCheck:
	ld e, 30
	call CheckSomePokemonWithEnoughHP
	ret c
	; fallthrough

; this Power needs to back up hTempPlayAreaLocation_ff9d
CrushingCharge_PreconditionCheck:
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTemp_ffa0], a
	jr DrawOrTutorAbility_PreconditionCheck

WaveRider_PreconditionCheck:
	ld c, 3
	call CheckHandSizeIsLessThanC
	ret c
	; fallthrough

DrawOrTutorAbility_PreconditionCheck:
	call CheckDeckIsNotEmpty
	ret c
	jp CheckPokemonPowerCanBeUsed


MysteriousTail_PreconditionCheck:
FleetFooted_PreconditionCheck:
	call CheckTriggeringPokemonIsActive
	ret c
	jr DrawOrTutorAbility_PreconditionCheck


StressPheromones_PreconditionCheck:
	call CheckTempLocationPokemonHasAnyDamage
	ret c
	jr DrawOrTutorAbility_PreconditionCheck


PrimalGuidance_PreconditionCheck:
	call CheckBenchIsNotFull
	ret c
	call CheckDeckIsNotEmpty
	ret c
	jp CheckPokemonPowerCanBeUsed_StoreTrigger


EnergySpike_PreconditionCheck:
	call CheckDeckIsNotEmpty
	ret c
	jp CheckBenchIsNotEmpty


; return carry if no eligible cards in the Discard Pile
AquaticRescue_DiscardPileCheck:
	call CheckDiscardPileNotEmpty  ; builds discard pile list
	ret c  ; no cards
	ld a, CARDTEST_POKEMON_OR_SUPPORTER
	call FilterCardList
	ldtx hl, ThereAreNoCardsInTheDiscardPileText
	ret


FirePunch_PreconditionCheck:
	call CheckArenaPokemonHasAnyDamage
	ret nc  ; damaged
	jp CheckArenaPokemonHasAnyEnergiesAttached


ThunderPunch_PreconditionCheck:
	call CheckEnteredActiveSpotThisTurn
	ret nc  ; active this turn
	jp CheckArenaPokemonHasAnyEnergiesAttached


; ------------------------------------------------------------------------------
; Discard Cards
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/discard.asm"


Wildfire_DiscardDeckEffect:
	ldh a, [hTemp_ffa0]
	jp DiscardFromOpponentsDeckEffect


Discard2CardsFromOpponentsDeckEffect:
	ld a, 2
	jp DiscardFromOpponentsDeckEffect


Discard1CardFromOpponentsDeckEffect:
	ld a, 1
	jp DiscardFromOpponentsDeckEffect


Landslide_DiscardDeckEffect:
	ld a, 2
	jp DiscardFromDeckEffect


Devastate_DiscardDeckEffect:
	ld a, 4
	jp DiscardFromDeckEffect


MountainSwing_DiscardDeckEffect:
	ld a, 2
	call DiscardFromDeckEffect
	ld a, 2
	jp DiscardFromOpponentsDeckEffect


PrimalCold_DrawbackEffect:
	call CheckOpponentHasMorePrizeCardsRemaining
	ret c  ; opponent Prizes < user Prizes (losing)
	ret z  ; opponent Prizes = user Prizes (tied)
; opponent Prizes > user Prizes (winning)
	jp DiscardAllAttachedEnergiesOnTurnHolderSideEffect


PrimalFire_DrawbackEffect:
	call CheckOpponentHasMorePrizeCardsRemaining
	ret c  ; opponent Prizes < user Prizes (losing)
	ret z  ; opponent Prizes = user Prizes (tied)
; opponent Prizes > user Prizes (winning)
	ld a, 10
	jp DiscardFromDeckEffect


; ------------------------------------------------------------------------------

; Stores information about the attack damage for AI purposes
; taking into account poison damage between turns.
; if target poisoned
;	[wAIMinDamage] <- [wDamage]
;	[wAIMaxDamage] <- [wDamage]
; else
;	[wAIMinDamage] <- [wDamage] + d
;	[wAIMaxDamage] <- [wDamage] + e
;	[wDamage]      <- [wDamage] + a
UpdateExpectedAIDamage_AccountForPoison: ; 2c0d4 (b:40d4)
; OATS poison ticks only for the turn holder
	; push af
	; ld a, DUELVARS_ARENA_CARD_STATUS
	; call GetNonTurnDuelistVariable
	; and POISONED | DOUBLE_POISONED
	; jr z, UpdateExpectedAIDamage.skip_push_af
	; pop af
	; ld a, [wDamage]
	; ld [wAIMinDamage], a
	; ld [wAIMaxDamage], a
	; ret

; Sets some variables for AI use
;	[wAIMinDamage] <- [wDamage] + d
;	[wAIMaxDamage] <- [wDamage] + e
;	[wDamage]      <- [wDamage] + a
UpdateExpectedAIDamage: ; 2c0e9 (b:40e9)
	push af

.skip_push_af
	ld hl, wDamage
	ld a, [hl]
	add d
	ld [wAIMinDamage], a
	ld a, [hl]
	add e
	ld [wAIMaxDamage], a
	pop af
	add [hl]
	ld [hl], a
	ret

; Stores information about the attack damage for AI purposes
; [wDamage]      <- a (average amount of damage)
; [wAIMinDamage] <- d (minimum)
; [wAIMaxDamage] <- e (maximum)
SetExpectedAIDamage: ; 2c0fb (b:40fb)
	ld [wDamage], a
	xor a
	; ld [wDamageFlags], a
	ld a, d
	ld [wAIMinDamage], a
	ld a, e
	ld [wAIMaxDamage], a
	ret


Func_2c12e: ; 2c12e (b:412e)
	ld [wLoadedAttackAnimation], a
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld b, a
	ld c, $0 ; neither WEAKNESS nor RESISTANCE
	ldh a, [hWhoseTurn]
	ld h, a
	bank1call PlayAttackAnimation
	bank1call WaitAttackAnimation
	ret


; returns carry if Defending has No Damage or Effect
; if so, print its appropriate text.
HandleNoDamageOrEffect: ; 2c216 (b:4216)
	call CheckNoDamageOrEffect
	ret nc
	ld a, l
	or h
	call nz, DrawWideTextBox_PrintText
	scf
	ret

; ------------------------------------------------------------------------------
; Healing
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/healing.asm"


; select the Pokémon with status to heal
FullHeal_PlayerSelection:
	bank1call HasAlivePokemonInPlayArea
.read_input
	bank1call OpenPlayAreaScreenForSelection
	ret c ; exit is B was pressed
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTemp_ffa0], a

	add DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	or a
	ret nz  ; Pokémon has status

	ldh a, [hTempPlayAreaLocation_ff9d]
	or a  ; arena Pokémon?
	jr nz, .read_input ; not arena, loop back to start

	ld l, DUELVARS_ARENA_CARD_SUBSTATUS2
	ld a, [hl]
	or a
	jr z, .read_input ; no status, loop back to start
	ret

FullHeal_ClearStatusEffect:
	ldh a, [hTemp_ffa0]
	call ClearStatusAndEffectsFromTargetEffect
	bank1call DrawDuelHUDs
	ret


; ------------------------------------------------------------------------------
; Damage
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/damage.asm"


TripleHit_StoreExtraDamageEffect:
	call CheckArenaPokemonHas3OrMoreEnergiesAttached
	ld de, 0
	or a
	jr z, .store  ; zero energies
	ld c, a
	dec c
	jr z, .store  ; one energy
	ld a, [wLoadedAttackDamage]
	ld d, a
	dec c
	jr z, .store  ; two energies
	ld e, a  ; three or more energies
.store
	ld a, d
	ldh [hTempList], a
	ld a, e
	ldh [hTempList + 1], a
	ret


DoubleHit_StoreExtraDamageEffect:
	call CheckArenaPokemonHas2OrMoreEnergiesAttached
	ld a, [wLoadedAttackDamage]
	jr nc, .store
	xor a  ; also reset carry
.store
	ldh [hTemp_ffa0], a
	ret

;
TripleHitEffect:
	call DoubleHitEffect
	ldh a, [hTempList + 1]
	ldh [hTemp_ffa0], a
	; jr DoubleHitEffect
	; fallthrough

DoubleHitEffect:
	ldh a, [hTemp_ffa0]
	or a
	ret z
.hit
	ld d, 0
	ld e, a
	xor a  ; REFRESH_DUEL_SCREEN
	ld [wDuelDisplayedScreen], a  ; trick to avoid graphical glitch
	ld a, ATK_ANIM_HIT_NO_GLOW
	call DealDamageToArenaPokemon_CustomAnim
	ld a, DUEL_MAIN_SCENE
	ld [wDuelDisplayedScreen], a
	ret


PrimalThunder_DrawbackEffect:
	call CheckOpponentHasMorePrizeCardsRemaining
	ret c  ; opponent Prizes < user Prizes (losing)
	ret z  ; opponent Prizes = user Prizes (tied)
; opponent Prizes > user Prizes (winning)
	call Recoil30Effect
	jp DamageAllFriendlyPokemon30Effect


DragonArrow_DamageEffect:
	ldh a, [hTemp_ffa0]
	add a  ; x2
	call ATimes10
	add 10  ; base
	ld d, 0
	ld e, a
	jp DealDamageToTarget_DE_DamageEffect


; ------------------------------------------------------------------------------
; Damage Modifiers
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/damage_modifiers.asm"


; ------------------------------------------------------------------------------
; Pokémon Powers
; ------------------------------------------------------------------------------


AbilityEnergyRetrieval_PreconditionCheck:
	call CheckPokemonPowerCanBeUsed_StoreTrigger
	ret c  ; cannot be used
	call CheckHandIsNotEmpty
	ret c  ; return if there are no cards to discard
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	ldtx hl, ThereAreNoBasicEnergyCardsInDiscardPileText
	ret


StepIn_SwitchEffect:
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ff9d], a  ; source PLAY_AREA_*
	ldh a, [hTemp_ffa0]
	ldh [hTempPlayAreaLocation_ffa1], a  ; target PLAY_AREA_*
	call MoveAllAttachedEnergiesToAnotherPokemonEffect
	ldh a, [hTemp_ffa0]
	ld e, a
	call SwapArenaWithBenchPokemon
	; xor a  ; PLAY_AREA_ARENA
	; ldh [hTempPlayAreaLocation_ff9d], a
	jp SetUsedPokemonPowerThisTurn


EvolutionaryFlame_DamageBurnEffect:
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	ld e, a
	call SwapTurn
	call BurnEffect_PlayArea
	call SwapTurn
	jp Deal20DamageToTarget_DamageEffect


; Draw 1 card per turn if in the Active Spot.
FleetFootedEffect:
	call SetUsedPokemonPowerThisTurn
	jp Draw1Card


; Discard 1 card and draw 2 cards per turn.
TradeEffect:
	call SetUsedPokemonPowerThisTurn
	ldh a, [hAIPkmnPowerEffectParam]
	ldh [hTempList], a
	call SelectedCards_Discard1FromHand
	jp Draw2Cards


; Search for any card in deck and add it to the hand.
Courier_TutorEffect:
	ld a, DUELVARS_DUELIST_TYPE
	call GetTurnDuelistVariable
	cp DUELIST_TYPE_LINK_OPP
	jr z, .link_opp
	and DUELIST_TYPE_AI_OPP
	jr nz, .ai_opp

; player
	; ldtx hl, ChooseCardToPlaceInHandText
	; call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionAnyCardFromDeckToHand
	; ldh [hAIPkmnPowerEffectParam], a
	call SerialSend8Bytes
	jr .done

.link_opp
	call SerialRecv8Bytes
	; ldh [hAIPkmnPowerEffectParam], a
	jr .done

.ai_opp
; AI just selects the first card in the deck
	ld b, 1
	call CreateDeckCardListTopNCards
	ld a, [wDuelTempList]
	; fallthrough

.done
	cp $ff
	jp z, SyncShuffleDeck
	jp AddDeckCardToHandAndShuffleEffect


; Search for a basic energy card in deck and add it to the hand.
EnergyStream_TutorEffect:
	ld a, DUELVARS_DUELIST_TYPE
	call GetTurnDuelistVariable
	cp DUELIST_TYPE_LINK_OPP
	jr z, .link_opp
	and DUELIST_TYPE_AI_OPP
	jr nz, .ai_opp

; player
	; ldtx hl, ChooseCardToPlaceInHandText
	; call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionBasicEnergyFromDeck
	; ldh [hAIPkmnPowerEffectParam], a
	call SerialSend8Bytes
	jr .done

.link_opp
	call SerialRecv8Bytes
	; ldh [hAIPkmnPowerEffectParam], a
	jr .done

.ai_opp
; AI just selects the first card in the deck
	call CreateDeckCardList
	ld a, CARDTEST_BASIC_ENERGY
	call FilterCardList
	ld a, [wDuelTempList]
	; fallthrough

.done
	cp $ff
	jp z, SyncShuffleDeck
	jp AddDeckCardToHandAndShuffleEffect


GarbageEater_HealEffect:
	ld a, [wGarbageEaterDamageToHeal]
	or a
	ret z  ; nothing to do

	ld a, GRIMER
	call ListPowerCapablePokemonIDInPlayArea
	ret nc  ; none found

	ld hl, hTempList
.loop_play_area
	ld a, [hli]
	cp $ff
	ret z  ; done
	ld e, a  ; location
	ld a, [wGarbageEaterDamageToHeal]
	ld d, a  ; damage
	push hl
	call HealPlayAreaCardHP
	pop hl
	jr .loop_play_area


StrangeBehavior_SelectAndSwapEffect:
	ld a, DUELVARS_DUELIST_TYPE
	call GetTurnDuelistVariable
	cp DUELIST_TYPE_PLAYER
	jr z, .player

; not player
	bank1call Func_61a1
	bank1call PrintPlayAreaCardList_EnableLCD
	ret

.player
	ldtx hl, ProcedureForStrangeBehaviorText
	bank1call DrawWholeScreenTextBox

	xor a
	ldh [hCurSelectionItem], a
	bank1call Func_61a1
.loop
	call Move1DamageCounterToRecipient_PlayerSelectEffect
	ret z  ; B was pressed
	ld a, OPPACTION_EXECUTE_EFFECT_STEP
	call SetOppAction_SerialSendDuelData
	jr .loop


; Single iteration of the Strange Behaviour effect
; return nz if the damage counter was moved (more iterations to come)
; return z if the player pressed B (end selection)
; the goal of refactoring this into its own function was to take
; OPPACTION_EXECUTE_EFFECT_STEP apart, so that its effect can be used for
; other things besides Strange Behaviour.
Move1DamageCounterToRecipient_PlayerSelectEffect:
	bank1call PrintPlayAreaCardList_EnableLCD
	push af
	ldh a, [hCurSelectionItem]
	ld hl, PlayAreaSelectionMenuParameters
	call InitializeMenuParameters
	pop af

	ld [wNumMenuItems], a
.loop_input
	call DoFrame
	call HandleMenuInput
	jr nc, .loop_input
	cp $ff
	ret z  ; return when B button is pressed

	ldh [hCurSelectionItem], a
	ldh [hTempPlayAreaLocation_ffa1], a
	ld hl, hTemp_ffa0
	cp [hl]
	jr z, .play_sfx ; can't select Slowbro itself

	call GetCardDamageAndMaxHP
	or a
	jr z, .play_sfx ; can't select card without damage

	call TryGiveDamageCounter_StrangeBehavior
	jr c, .play_sfx
	ld a, 1
	or a
	ret

.play_sfx
	call PlaySFX_InvalidChoice
	jr .loop_input


StrangeBehavior_SwapEffect:
	call TryGiveDamageCounter_StrangeBehavior
	ret c
	bank1call PrintPlayAreaCardList_EnableLCD
	or a
	ret

; tries to give the damage counter to the target
; chosen by the Player (hTemp_ffa0).
; if the damage counter would KO card, then do
; not give the damage counter and return carry.
TryGiveDamageCounter_StrangeBehavior:
	ldh a, [hTemp_ffa0]
	add DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	sub 10
	jr z, .set_carry  ; would bring HP to zero?
; has enough HP to receive a damage counter
	ld [hl], a
	ldh a, [hTempPlayAreaLocation_ffa1]
	add DUELVARS_ARENA_CARD_HP
	ld l, a
	ld a, 10
	add [hl]
	ld [hl], a
	or a
	ret
.set_carry
	scf
	ret


Mischief_DamageTransferEffect:
; heal the selected Pokémon
	ldh a, [hPlayAreaEffectTarget]
	ld e, a   ; location
	ld d, 10  ; damage
	call HealPlayAreaCardHP
	call Curse_DamageEffect
	jp ExchangeRNG


Curse_DamageEffect:
	call SetUsedPokemonPowerThisTurn_RestoreTrigger
	; fallthrough

Put1DamageCounterOnTarget_DamageEffect:
	; input e: PLAY_AREA_* of the target
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	call SwapTurn
	call Put1DamageCounterOnTarget
	call SwapTurn
	ret nc
; Knocked Out Defending Pokémon
	ld a, DUELVARS_MISC_TURN_FLAGS
	call GetTurnDuelistVariable
	set TURN_FLAG_KO_OPPONENT_POKEMON_F, [hl]
	bank1call ClearKnockedOutPokemon_TakePrizes_CheckGameOutcome
	ret


; input:
;   [hTempPlayAreaLocation_ffa1]: PLAY_AREA_* of the Pokémon that switched in
;                                 (now with the previous Active Pokémon)
;   [hTempRetreatCostCards]: $ff-terminated list of discarded deck indices
VoltSwitchEffect:
	ld hl, hTempRetreatCostCards
.loop
	ld a, [hli]
	cp $ff
	ret z  ; no (more) cards were discarded
	ld d, a  ; deck index
	call LoadCardDataToBuffer2_FromDeckIndex  ; preserves hl, de
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY_LIGHTNING
	jr nz, .loop
; found a Lightning Energy
	ld a, d
	ld e, CARD_LOCATION_ARENA
	call Helper_AttachCardFromDiscardPile

	call IsPlayerTurn
	ret c
	xor a  ; PLAY_AREA_ARENA
	jp Helper_GenericShowAttachedEnergyToPokemon.got_play_area_location

; check for an active Energy Jolt
	; ld a, [wEnergyColorOverride]
	; cp LIGHTNING


; ------------------------------------------------------------------------------
; Compound Attacks
; ------------------------------------------------------------------------------

; if evolution takes place, it overrides the effect queue and Poison does not
; apply to the Defending Pokémon, even though the animation plays
PoisonEvolution_EvolveEffect:
	ld a, [wEffectFunctionsFeedbackIndex]
	push af
	call EvolutionFromDeck_EvolveEffect
	pop af
	ld [wEffectFunctionsFeedbackIndex], a
	ret


PollenBurstEffect:
	call KarateChop_DamageSubtractionEffect
	jp PollenBurst_StatusEffect


GluttonFrenzy_DiscardEffect:
	call DiscardOpponentEnergy_DiscardEffect
	jp Discard1RandomCardFromOpponentsHandEffect


; Poison, Confusion, bonus damage based on Retreat Cost
JellyfishStingEffect:
	call Constrict_DamageBoostEffect
	call PoisonEffect
	jp ConfusionEffect


Ingrain_RetrieveAndHealEffect:
	call TempListLength
	or a
	ret z
	push af
	call SelectedCardList_AddToHandFromDiscardPileEffect
	pop af
	call ATimes10
	jp HealADamageEffect


ToxicNeedleEffect:
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetNonTurnDuelistVariable
	or a
	jp nz, DoublePoisonEffect  ; just poison
	call ParalysisEffect
	jp DoublePoisonEffect


GatherToxinsEffect:
	call Attach1DarknessEnergyFromDiscard_SelectEffect
	jp PoisonEffect


FireSpinEffect:
	call FireSpin_DamageMultiplierEffect
	call BurnEffect
	jp IncreaseRetreatCostEffect


; input:
;   [hTemp_ffa0]: selected number of damage counters
GetMadEffect:
	ldh a, [hTemp_ffa0]
	or a
	ret z  ; no recoil
; load recoil dialogue
	ld l, a
	ld h, 0
	call LoadTxRam3  ; preserves hl, bc, de
	ld a, DUELVARS_ARENA_CARD
	call LoadCardNameAndLevelFromVarToRam2  ; preserves bc, de
	ldtx hl, PutDamageCountersOnPokemonText
	call DrawWideTextBox_PrintText
; convert damage counters into actual damage
	ldh a, [hTemp_ffa0]
	call ATimes10
	ld d, a
; back up attack variables
	ld a, [wLoadedAttackAnimation]
	ld c, a
	ld a, [wTempNonTurnDuelistCardID]
	ld b, a
; apply damage counters on self
	ld e, PLAY_AREA_ARENA
	ld a, TRUE
	ld [wIsDamageToSelf], a
	ld a, ATK_ANIM_NONE
	ld [wLoadedAttackAnimation], a
	call ApplyDirectDamage  ; preserves hl, de, bc
; restore attack variables
	xor a  ; FALSE
	ld [wIsDamageToSelf], a
	ld a, c
	ld [wLoadedAttackAnimation], a
	ld a, b
	ld [wTempNonTurnDuelistCardID], a
	; xor a
	; ld [wDuelAnimLocationParam], a
	; ld a, DUEL_ANIM_SCREEN_MAIN_SCENE
	; ld [wDuelAnimationScreen], a
; damage boost effect
	ld a, d
	jp AddToDamage
	; bank1call DrawDuelMainScene
	; ret


PrimalSwirl_DevolveAndTrapEffect:
	call DevolveDefendingPokemonEffect
	jp IncreaseRetreatCostEffect


IF SLEEP_WITH_COIN_FLIP == 0
SheerCold_SleepDamageMultiplierEffect:
	call SheerCold_MultiplierEffect
	jp SleepEffect
ENDC


Freeze_EnergyHealingEffect:
Concentration_EnergyHealingEffect:
	call AccelerateFromDiscard_AttachEnergyToArenaEffect
	jp Heal20DamageEffect


WickedTentacle_PoisonTransferEffect:
	call MoveOpponentEnergyToBench_TransferEffect
	jp PoisonEffect


ToxicWaste_DamagePoisonEffect:
	call ToxicWaste_DamageBoostEffect
	jp DoublePoisonEffect


; DiscardEnergy_DamageTargetPokemon_AISelectEffect:
; 	call DiscardEnergy_AISelectEffect      ; uses [hTemp_ffa0]
; 	jp DamageTargetPokemon_AISelectEffect  ; uses [hTempPlayAreaLocation_ffa1]


ScorchingColumn_DamageBurnEffect:
	call ScorchingColumn_MultiplierEffect
	ldh a, [hTemp_ffa0]
	cp 2
	jp nc, BurnEffect
	ret


Discharge_DamageParalysisEffect:
	call Discharge_MultiplierEffect
	ldh a, [hTemp_ffa0]
	cp 2
	jp nc, ParalysisEffect
	ret


WaterPulse_DamageConfusionEffect:
	call Discharge_MultiplierEffect
	ldh a, [hTemp_ffa0]
	cp 2
	jp nc, ConfusionEffect
	ret


PluckEffect:
	call DiscardOpponentTool_DiscardEffect
	jp c, DoubleDamage_DamageBoostEffect
	ret


RampageEffect:
	call Rage_DamageBoostEffect
	jp SelfConfusionEffect


; Attaches the selected energy from the discard pile to the user and heals 10 damage.
MendEffect:
	call AccelerateFromDiscard_AttachEnergyToArenaEffect
	jp Heal10DamageEffect


Constrict_TrapDamageBoostEffect:
	call IncreaseRetreatCostEffect
	jp Constrict_DamageBoostEffect


; Deal damage to selected Pokémon and apply defense boost to self.
AquaLauncherEffect:
	call Deal50DamageToTarget_DamageEffect
	jp ReduceDamageTakenBy20Effect


; heal up to 30 damage from user and put it to sleep
Rest_HealEffect:
	call ClearAllArenaStatusAndEffects
	call HealAllDamageEffect
	call SwapTurn
	call SleepEffect
	jp SwapTurn


; look at opponent's hand
CheckOpponentHandEffect:
	; call IsPlayerTurn
	; ret nc
	farcall OpenYourOrOppPlayAreaScreen_NonTurnHolderHand
	xor a
	ret


PoisonPaybackEffect:
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	or a
	ret z  ; not damaged
	call DoubleDamage_DamageBoostEffect
	jp PoisonEffect


ShadowClawEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z  ; no card was chosen to discard
	jp Discard1RandomCardFromOpponentsHandEffect

; OptionalDiscardEnergy:
; 	ldh a, [hTemp_ffa0]
; 	cp $ff
; 	ret z  ; none selected, do nothing
; 	call DiscardEnergy_DiscardEffect


DeadlyPoisonEffect:
	call DeadlyPoison_DamageBoostEffect
	jp PoisonEffect


OverwhelmEffect:
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetNonTurnDuelistVariable
	cp 4
	ret c  ; less than 4 cards
	call Discard1RandomCardFromOpponentsHandEffect
	jp ParalysisEffect


; ------------------------------------------------------------------------------
; Card Search
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/card_search.asm"


; Searches the Deck for either a Grass Energy or Grass Pokémon
; and adds that card to the Hand.
Sprout_PlayerSelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a

	call CreateDeckCardList
	ldtx hl, ChooseGrassCardFromDeckText
	ldtx bc, GrassCardText
	ld a, CARDTEST_GRASS_CARD
	call LookForCardsInDeckList
	ret c

; draw Deck list interface and print text
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	ldtx hl, ChooseGrassCardFromDeckText
	ldtx de, DuelistDeckText
	bank1call SetCardListHeaderText

.loop
	bank1call DisplayCardList
	jr c, .pressed_b

	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY_GRASS
	jr z, .got_card  ; is it a Grass Energy?
	cp TYPE_PKMN_GRASS
	jr nz, .play_sfx ; is it a Grass Pokémon?
.got_card
	ldh a, [hTempCardIndex_ff98]
	ldh [hTemp_ffa0], a
	or a
	ret

.play_sfx
	; play SFX and loop back
	call PlaySFX_InvalidChoice
	jr .loop

.pressed_b
; figure if Player can exit the screen without selecting,
; that is, if the Deck has no Grass-type cards.
	ld a, DUELVARS_CARD_LOCATIONS
	call GetTurnDuelistVariable
.loop_b_press
	ld a, [hl]
	cp CARD_LOCATION_DECK
	jr nz, .next
	ld a, l
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY_GRASS
	jr z, .play_sfx ; found, go back to top loop
	cp TYPE_PKMN_GRASS
	jr z, .play_sfx ; found, go back to top loop
.next
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .loop_b_press

; no valid card in Deck, can safely exit screen
	ld a, $ff
	ldh [hTemp_ffa0], a
	or a
	ret

Sprout_AISelectEffect:
	call CreateDeckCardList
	ld b, TYPE_ENERGY_GRASS
	call ChooseCardOfGivenType_AISelectEffect
	ldh [hTemp_ffa0], a
	cp $ff
	ret nz  ; found
	ld b, TYPE_PKMN_GRASS
	call ChooseCardOfGivenType_AISelectEffect
	ldh [hTemp_ffa0], a
	ret


; Looks at the top 2 cards and allows the Player to choose a card.
QuickSearch_PlayerSelectEffect:
	ld b, 2
	call CreateDeckCardListTopNCards
	call HandlePlayerSelectionAnyCardFromDeckListToHand
	ldh [hAIPkmnPowerEffectParam], a
	ret

; Looks at the top 4 cards and allows the Player to choose a card.
Ultravision_PlayerSelectEffect:
	ld b, 4
	call CreateDeckCardListTopNCards
	; fallthrough

; input:
;   wDuelTempList: list of deck cards to choose from
ChooseAnyCardFromDeckList_PlayerSelectEffect:
	call HandlePlayerSelectionAnyCardFromDeckListToHand
	ldh [hTemp_ffa0], a
	ret


; selects the first Trainer or Energy card that shows up
; FIXME improve
Ultravision_AISelectEffect:
	ld b, 4
	call CreateDeckCardListTopNCards
	; fallthrough

; input:
;   wDuelTempList: list of deck cards to choose from
ChooseAnyCardFromDeckList_AISelectEffect:
	ld hl, wDuelTempList
.loop_deck
	ld a, [hli]
	ldh [hTemp_ffa0], a
	cp $ff
	jr z, .anything ; none found
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY
	ret nc
	jr .loop_deck
.anything
	ld a, [wDuelTempList]
	ldh [hTemp_ffa0], a
	ret


Rototiller_AISelectEffect:
	farcall AISelect_Rototiller
	ret


AquaticRescue_AISelectEffect:
	farcall AISelect_AquaticRescue
	ret


TutorFireEnergy_PlayerSelectEffect:
	call CreateDeckCardList
	ld a, TYPE_ENERGY_FIRE
	call HandlePlayerSelectionCardTypeFromDeckListToHand
	ldh [hTempList], a
	ret


TutorWaterEnergy_PlayerSelectEffect:
	; ld b, 5
	; call CreateDeckCardListTopNCards
	call CreateDeckCardList
	ld a, TYPE_ENERGY_WATER
	call HandlePlayerSelectionCardTypeFromDeckListToHand
	ldh [hTempList], a
	ret

TutorFightingEnergy_PlayerSelectEffect:
	call CreateDeckCardList
	ld a, TYPE_ENERGY_FIGHTING
	call HandlePlayerSelectionCardTypeFromDeckListToHand
	ldh [hTempList], a
	ret


TutorFireEnergy_AISelectEffect:
	call CreateDeckCardList
	ld b, TYPE_ENERGY_FIRE
	call ChooseCardOfGivenType_AISelectEffect
	ldh [hTempList], a
	ret

TutorWaterEnergy_AISelectEffect:
	; ld b, 5
	; call CreateDeckCardListTopNCards
	call CreateDeckCardList
	ld b, TYPE_ENERGY_WATER
	call ChooseCardOfGivenType_AISelectEffect
	ldh [hTempList], a
	ret

TutorFightingEnergy_AISelectEffect:
	call CreateDeckCardList
	ld b, TYPE_ENERGY_FIGHTING
	call ChooseCardOfGivenType_AISelectEffect
	ldh [hTempList], a
	ret


Transport_PlayerSelectEffect:
	ld a, TYPE_TRAINER_SUPPORTER
	jr Tutor2OfCardType_PlayerSelectEffect

RapidCharge_PlayerSelectEffect:
	ld a, TYPE_ENERGY_LIGHTNING
	jr Tutor2OfCardType_PlayerSelectEffect

WaterReserve_PlayerSelectEffect:
	ld a, TYPE_ENERGY_WATER
	; jr Tutor2OfCardType_PlayerSelectEffect
	; fallthrough

; select 2 cards from the deck of the given type
; input:
;   a: TYPE_* constant of the card to search
Tutor2OfCardType_PlayerSelectEffect:
	; temporary storage
	ldh [hTempList + 2], a
	; ld b, 5
	; call CreateDeckCardListTopNCards
	call CreateDeckCardList
; select the first card
	ldh a, [hTempList + 2]
	call HandlePlayerSelectionCardTypeFromDeckListToHand
	ldh [hTempList], a
	cp $ff
	ret z  ; no cards or cancelled selection
; remove the first card from the list
	call RemoveCardFromDuelTempList
; choose a second card
	ldh a, [hTempList + 2]
	call HandlePlayerSelectionCardTypeFromDeckListToHand
	ldh [hTempList + 1], a
	ld a, $ff
	ldh [hTempList + 2], a  ; terminator
	ret


Transport_AISelectEffect:
	ld b, TYPE_TRAINER_SUPPORTER
	jr Tutor2OfCardType_AISelectEffect

RapidCharge_AISelectEffect:
	ld b, TYPE_ENERGY_LIGHTNING
	jr Tutor2OfCardType_AISelectEffect

WaterReserve_AISelectEffect:
	ld b, TYPE_ENERGY_WATER
	; jr Tutor2OfCardType_AISelectEffect
	; fallthrough

; input:
;   b: TYPE_* constant of the card to search
Tutor2OfCardType_AISelectEffect:
	push bc
	; ld b, 5
	; call CreateDeckCardListTopNCards
	call CreateDeckCardList
	pop bc
	; ld b, TYPE_ENERGY_WATER
	call ChooseCardOfGivenType_AISelectEffect  ; preserves b
	ldh [hTempList], a
	cp $ff
	ret z
	call RemoveCardFromDuelTempList  ; preserves bc
	; ld b, TYPE_ENERGY_WATER
	call ChooseCardOfGivenType_AISelectEffect
	ldh [hTempList + 1], a
	ld a, $ff
	ldh [hTempList + 2], a  ; terminator
	ret


; input:
;   [wDuelTempList]: list of cards to choose from
;   b: TYPE_* constant of card to choose
; output:
;   a: deck index of the selected card
; preserves: b
ChooseCardOfGivenType_AISelectEffect:
	ld hl, wDuelTempList
.loop_cards
	ld a, [hli]
	cp $ff
	ret z  ; no more cards
	ld c, a
	call GetCardIDFromDeckIndex  ; preserves af, hl, bc
	call GetCardType  ; preserves hl, bc
	cp b
	ld a, c
	ret z  ; found
	jr .loop_cards


; ------------------------------------------------------------------------------
; Card Lists and Filters
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/card_lists.asm"

; ------------------------------------------------------------------------------


GetNumAttachedGrassEnergy:
	; ldh a, [hTempPlayAreaLocation_ff9d]
	; ld e, a
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ld a, [wAttachedEnergies + GRASS]
	ret


GetNumAttachedFireEnergy:
	; ldh a, [hTempPlayAreaLocation_ff9d]
	; ld e, a
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ld a, [wAttachedEnergies + FIRE]
	ret


GetNumAttachedWaterEnergy:
	; ldh a, [hTempPlayAreaLocation_ff9d]
	; ld e, a
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ld a, [wAttachedEnergies + WATER]
	ret


; handles the Player selection of attack
; to use, i.e. Amnesia or Metronome on.
; returns carry if none selected.
; outputs:
;	  d = card index of defending card
;	  e = attack index selected
HandleDefendingPokemonAttackSelection:
	bank1call DrawDuelMainScene
	call SwapTurn
	xor a
	ldh [hCurSelectionItem], a

.start
	bank1call PrintAndLoadAttacksToDuelTempList
	push af
	ldh a, [hCurSelectionItem]
	ld hl, .menu_parameters
	call InitializeMenuParameters
	pop af

	ld [wNumMenuItems], a
	call EnableLCD
.loop_input
	call DoFrame
	ldh a, [hKeysPressed]
	bit B_BUTTON_F, a
	jr nz, .set_carry
	and START
	jr nz, .open_atk_page
	call HandleMenuInput
	jr nc, .loop_input
	cp -1
	jr z, .loop_input

; an attack was selected
	ldh a, [hCurMenuItem]
	add a
	ld e, a
	ld d, $00
	ld hl, wDuelTempList
	add hl, de
	ld d, [hl]
	inc hl
	ld e, [hl]
	call SwapTurn
	or a
	ret

.set_carry
	call SwapTurn
	scf
	ret

.open_atk_page
	ldh a, [hCurMenuItem]
	ldh [hCurSelectionItem], a
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex
	bank1call OpenAttackPage
	call SwapTurn
	bank1call DrawDuelMainScene
	call SwapTurn
	jr .start

.menu_parameters
	db 1, 13 ; cursor x, cursor y
	db 2 ; y displacement between items
	db 2 ; number of items
	db SYM_CURSOR_R ; cursor tile number
	db SYM_SPACE ; tile behind cursor
	dw NULL ; function pointer if non-0

; loads in hl the pointer to attack's name.
; input:
;	d = deck index of card
; 	e = attack index (0 = first attack, 1 = second attack)
GetAttackName: ; 2c3fc (b:43fc)
	ld a, d
	call LoadCardDataToBuffer1_FromDeckIndex
	ld hl, wLoadedCard1Atk1Name
	inc e
	dec e
	jr z, .load_name
	ld hl, wLoadedCard1Atk2Name
.load_name
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

; returns carry if Defending Pokemon
; doesn't have an attack.
CheckIfDefendingPokemonHasAnyAttack: ; 2c40e (b:440e)
	call SwapTurn
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Atk1Category]
	cp POKEMON_POWER
	jr nz, .has_attack
	ld hl, wLoadedCard2Atk2Name
	ld a, [hli]
	or [hl]
	jr nz, .has_attack
	call SwapTurn
	scf
	ret
.has_attack
	call SwapTurn
	or a
	ret


; prompts the Player with a Yes/No question
; whether to quit the screen, even though
; they can select more cards from list.
; [hCurSelectionItem] holds number of cards
; that were already selected by the Player.
; input:
;	- a = total number of cards that can be selected
; output:
;	- carry set if "No" was selected
AskWhetherToQuitSelectingCards:
	ld hl, hCurSelectionItem
	sub [hl]
	ld l, a
	ld h, $00
	call LoadTxRam3
	ldtx hl, YouCanSelectMoreCardsQuitText
	jp YesOrNoMenuWithText


; handles the selection of a forced switch by link/AI opponent or by the player.
; outputs the Play Area location of the chosen bench card in hTempPlayAreaLocation_ff9d.
DuelistSelectForcedSwitch:
	ld a, DUELVARS_DUELIST_TYPE
	call GetNonTurnDuelistVariable
	cp DUELIST_TYPE_LINK_OPP
	jr z, .link_opp

	cp DUELIST_TYPE_PLAYER
	jr z, .player

; AI opponent
	call SwapTurn
	bank1call AIDoAction_ForcedSwitch
	call SwapTurn

	ld a, [wPlayerAttackingAttackIndex]
	ld e, a
	ld a, [wPlayerAttackingCardIndex]
	ld d, a
	ld a, [wPlayerAttackingCardID]
	call CopyAttackDataAndDamage_FromCardID
	jp Func_16f6

.player
	ldtx hl, SelectPkmnOnBenchToSwitchWithActiveText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	bank1call HasAlivePokemonInBench
	ld a, $01
	ld [wcbd4], a
.asm_2c4c0
	bank1call OpenPlayAreaScreenForSelection
	jr c, .asm_2c4c0
	jp SwapTurn

.link_opp
; get selection from link opponent
	ld a, OPPACTION_FORCE_SWITCH_ACTIVE
	call SetOppAction_SerialSendDuelData
.loop
	call SerialRecvByte
	jr nc, .received
	halt
	nop
	jr .loop
.received
	ldh [hTempPlayAreaLocation_ff9d], a
	ret

; returns in a the card index of energy card
; attached to Defending Pokemon
; that is to be discarded by the AI for an effect.
; outputs $ff is none was found.
; output:
;	a = deck index of attached energy card chosen
AIPickEnergyCardToDiscardFromDefendingPokemon: ; 2c4da (b:44da)
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

; handles AI logic to pick attack for Amnesia
AIPickAttackForAmnesia: ; 2c532 (b:4532)
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
	cp POKEMON_POWER
	jr nz, .chosen
; if it is a Pkmn Power, choose second attack.
	ld e, SECOND_ATTACK
.chosen
	ld a, e
	jp SwapTurn


; Return in a the PLAY_AREA_* of the non-turn holder's Pokemon card
; in bench with the lowest (remaining) HP.
; if multiple cards are tied for the lowest HP, the one with
; the highest PLAY_AREA_* is returned.
GetOpponentBenchPokemonWithLowestHP:
	call SwapTurn
	call GetBenchPokemonWithLowestHP
	jp SwapTurn

; outputs:
;   a: PLAY_AREA_* of Pokémon with lowest HP
;   d: PLAY_AREA_* of Pokémon with lowest HP
;   e: lowest HP amount found
GetBenchPokemonWithLowestHP:
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


; outputs:
;   a: PLAY_AREA_* of Pokémon with highest HP
;   d: PLAY_AREA_* of Pokémon with highest HP
;   e: highest HP amount found
GetBenchPokemonWithHighestHP:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	lb de, PLAY_AREA_ARENA, 0
	ld b, d
	ld a, DUELVARS_BENCH1_CARD_HP
	call GetTurnDuelistVariable
	jr .start
; find Play Area location with the highest HP
.loop_bench
	ld a, e
	cp [hl]
	jr nc, .next ; skip if HP is lower
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

; handles drawing and selection of screen for
; choosing a color (excluding colorless), for use
; of Shift Pkmn Power and Conversion attacks.
; outputs in a the color that was selected or,
; if B was pressed, returns carry.
; input:
;	a  = Play Area location (PLAY_AREA_*), with:
;	     bit 7 not set if it's applying to opponent's card
;	     bit 7 set if it's applying to player's card
;	hl = text to be printed in the bottom box
; output:
;	a = color that was selected
HandleColorChangeScreen: ; 2c588 (b:4588)
	or a
	call z, SwapTurn
	push af
	call .DrawScreen
	pop af
	call z, SwapTurn

	ld hl, .menu_params
	xor a
	call InitializeMenuParameters
	call EnableLCD

.loop_input
	call DoFrame
	call HandleMenuInput
	jr nc, .loop_input
	cp -1 ; b pressed?
	jr z, .set_carry
	ld e, a
	ld d, $00
	ld hl, ShiftListItemToColor
	add hl, de
	ld a, [hl]
	or a
	ret
.set_carry
	scf
	ret

.menu_params
	db 1, 1 ; cursor x, cursor y
	db 2 ; y displacement between items
	db MAX_PLAY_AREA_POKEMON ; number of items
	db SYM_CURSOR_R ; cursor tile number
	db SYM_SPACE ; tile behind cursor
	dw NULL ; function pointer if non-0

.DrawScreen: ; 2c5be (b:45be)
	push hl
	push af
	call EmptyScreen
	call ZeroObjectPositions
	call LoadDuelCardSymbolTiles

; load card data
	pop af
	and $7f
	ld [wTempPlayAreaLocation_cceb], a
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex

; draw card gfx
	ld de, v0Tiles1 + $20 tiles ; destination offset of loaded gfx
	ld hl, wLoadedCard1Gfx
	ld a, [hli]
	ld h, [hl]
	ld l, a
	lb bc, $30, TILE_SIZE
	call LoadCardGfx
	bank1call SetBGP6OrSGB3ToCardPalette
	bank1call FlushAllPalettesOrSendPal23Packet
	ld a, $a0
	lb hl, 6, 1
	lb de, 9, 2
	lb bc, 8, 6
	call FillRectangle
	bank1call ApplyBGP6OrSGB3ToCardImage

; print card name and level at the top
	ld a, 16
	call CopyCardNameAndLevel
	ld [hl], $00
	lb de, 7, 0
	call InitTextPrinting
	ld hl, wDefaultText
	call ProcessText

; list all the colors
	ld hl, ShiftMenuData
	call PlaceTextItems

; print card's color, resistance and weakness
	ld a, [wTempPlayAreaLocation_cceb]
	call GetPlayAreaCardColor
	inc a
	lb bc, 15, 9
	call WriteByteToBGMap0
	ld a, [wTempPlayAreaLocation_cceb]
	call GetPlayAreaCardWeakness
	lb bc, 15, 10
	bank1call PrintCardPageWeaknessesOrResistances
	ld a, [wTempPlayAreaLocation_cceb]
	call GetPlayAreaCardResistance
	lb bc, 15, 11
	bank1call PrintCardPageWeaknessesOrResistances

	call DrawWideTextBox

; print list of color names on all list items
	lb de, 4, 1
	ldtx hl, ColorListText
	call InitTextPrinting_ProcessTextFromID

; print input hl to text box
	lb de, 1, 14
	pop hl
	call InitTextPrinting_ProcessTextFromID

; draw and apply palette to color icons
	ld hl, ColorTileAndBGP
	lb de, 2, 0
	ld c, NUM_COLORED_TYPES
.loop_colors
	ld a, [hli]
	push de
	push bc
	push hl
	lb hl, 1, 2
	lb bc, 2, 2
	call FillRectangle

	ld a, [wConsole]
	cp CONSOLE_CGB
	jr nz, .skip_vram1
	pop hl
	push hl
	call BankswitchVRAM1
	ld a, [hl]
	lb hl, 0, 0
	lb bc, 2, 2
	call FillRectangle
	call BankswitchVRAM0

.skip_vram1
	pop hl
	pop bc
	pop de
	inc hl
	inc e
	inc e
	dec c
	jr nz, .loop_colors
	ret

; loads wTxRam2 and wTxRam2_b:
; [wTxRam2]   <- wLoadedCard1Name
; [wTxRam2_b] <- input color as text symbol
; input:
;	a = type (color) constant
LoadCardNameAndInputColor: ; 2c686 (b:4686)
	add a
	ld e, a
	ld d, $00
	ld hl, ColorToTextSymbol
	add hl, de

; load wTxRam2 with card's name
	ld de, wTxRam2
	ld a, [wLoadedCard1Name]
	ld [de], a
	inc de
	ld a, [wLoadedCard1Name + 1]
	ld [de], a

; load wTxRam2_b with ColorToTextSymbol
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ret

ShiftMenuData: ; 2c6a1 (b:46a1)
	; x, y, text id
	textitem 10,  9, TypeText
	textitem 10, 10, WeaknessText
	textitem 10, 11, ResistanceText
	db $ff

ColorTileAndBGP: ; 2c6ae (b:46ae)
	; tile, BG
	db $e4, $02
	db $e0, $01
	db $eC, $02
	db $e8, $01
	db $f0, $03
	db $f4, $03

ShiftListItemToColor: ; 2c6ba (b:46ba)
	db GRASS
	db FIRE
	db WATER
	db LIGHTNING
	db FIGHTING
	db PSYCHIC

ColorToTextSymbol:  ; 2c6c0 (b:46c0)
	tx FireSymbolText
	tx GrassSymbolText
	tx LightningSymbolText
	tx WaterSymbolText
	tx FightingSymbolText
	tx PsychicSymbolText

DrawSymbolOnPlayAreaCursor: ; 2c6cc (b:46cc)
	ld c, a
	add a
	add c
	add 2
	; a = 3*a + 2
	ld c, a
	ld a, b
	ld b, 0
	call WriteByteToBGMap0
	ret


PlayAreaSelectionMenuParameters: ; 2c6e0 (b:46e0)
	db 0, 0 ; cursor x, cursor y
	db 3 ; y displacement between items
	db MAX_PLAY_AREA_POKEMON ; number of items
	db SYM_CURSOR_R ; cursor tile number
	db SYM_SPACE ; tile behind cursor
	dw NULL ; function pointer if non-0

BenchSelectionMenuParameters: ; 2c6e8 (b:46e8)
	db 0, 3 ; cursor x, cursor y
	db 3 ; y displacement between items
	db MAX_PLAY_AREA_POKEMON ; number of items
	db SYM_CURSOR_R ; cursor tile number
	db SYM_SPACE ; tile behind cursor
	dw NULL ; function pointer if non-0


RepelAbility_PreconditionCheck:
	call CheckTriggeringPokemonIsActive
	ret c
	; jr LureAbility_PreconditionCheck
	; fallthrough

; return carry if there are no Pokemon cards in the non-turn holder's bench
LureAbility_PreconditionCheck:
	; call Lure_AssertPokemonInBench
	call CheckOpponentBenchIsNotEmpty
	ret c
	jp CheckPokemonPowerCanBeUsed_StoreTrigger


FragranceTrap_PlayerSelectEffect:
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	call CheckOpponentBenchIsNotEmpty
	ret c
	; jr Lure_SelectSwitchPokemon
	; fallthrough

; return in hTempPlayAreaLocation_ffa1 the PLAY_AREA_* location
; of the Bench Pokemon that was selected for switch
Lure_SelectSwitchPokemon:
	ldtx hl, SelectPkmnOnBenchToSwitchWithActiveText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	call HandlePlayerSelectionPokemonInBench
	ldh [hTempPlayAreaLocation_ffa1], a
	jp SwapTurn

; Return in hTemp_ffa0 the PLAY_AREA_* of the non-turn holder's Pokemon card in bench with the lowest (remaining) HP.
; if multiple cards are tied for the lowest HP, the one with the highest PLAY_AREA_* is returned.
Lure_GetOpponentBenchPokemonWithLowestHP:
	call GetOpponentBenchPokemonWithLowestHP
	ldh [hTempPlayAreaLocation_ffa1], a
	ret

; Defending Pokemon is swapped out for the one with the PLAY_AREA_* at hTemp_ffa0
; unless Mew's Neutralizing Shield or Haunter's Transparency prevents it.
Lure_SwitchDefendingPokemon:
	call SwapTurn
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	call HandleNShieldAndTransparency
	call nc, SwapArenaWithBenchPokemon
	call SwapTurn
	xor a
	ld [wDuelDisplayedScreen], a
	ret

PoisonLure_SwitchEffect:
	call Lure_SwitchDefendingPokemon
	jp PoisonEffect


Lure_SwitchAndTrapDefendingPokemon:
	call Lure_SwitchDefendingPokemon
	jp UnableToRetreatEffect


LureAbility_SwitchDefendingPokemon:
	ldh a, [hTemp_ffa0]
	ldh [hTempPlayAreaLocation_ff9d], a
	call SetUsedPokemonPowerThisTurn
	jp Lure_SwitchDefendingPokemon


FragranceTrap_SwitchEffect:
	ld a, ATK_ANIM_LURE
	ldh [hTemp_ffa0], a
	; jr DragOff_SwitchEffect
	; fallthrough

DragOff_SwitchEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	or a
	ret z  ; no switch
; back up attack variables
	ld a, [wLoadedAttackAnimation]
	ld c, a
	ld a, [wTempNonTurnDuelistCardID]
	ld b, a
	push bc
; switch the Defending Pokémon
	ldh a, [hTemp_ffa0]
	bank1call PlayAdhocAnimationOnPlayAreaArena_NoEffectiveness
	call Lure_SwitchDefendingPokemon
; restore attack variables
	pop bc
	ld a, c
	ld [wLoadedAttackAnimation], a
	ld a, b
	ld [wTempNonTurnDuelistCardID], a
; refresh screen to show new Pokémon
	xor a  ; REFRESH_DUEL_SCREEN
	ld [wDuelDisplayedScreen], a
	bank1call DrawDuelMainScene
	ret


ForceSwitchUser_PlayerSelectEffect:
	ldtx hl, SelectPkmnOnBenchToSwitchWithActiveText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionPokemonInBench_AllowExamine
	ldh [hTemp_ffa0], a
	ret


SwitchUser_PlayerSelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a
	call CheckBenchIsNotEmpty
	jr c, .done

	ldtx hl, SelectPkmnOnBenchToSwitchWithActiveText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionPokemonInBench_AllowCancel_AllowExamine
	ldh [hTemp_ffa0], a
.done
	or a
	ret

SwitchUser_AISelectEffect:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	call Random
	ldh [hTemp_ffa0], a
	ret

; z: false
; nz: true
IsBenchPokemonSelected:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z
	or a
	ret

SwitchUser_SwitchEffect:
	call IsBenchPokemonSelected
	ret z
.switch
	ld e, a
	call SwapArenaWithBenchPokemon
	xor a
	ld [wDuelDisplayedScreen], a
	ret


BatonPass_SwitchEffect:
	call IsBenchPokemonSelected
	ret z
	ldh [hTempPlayAreaLocation_ffa1], a  ; target PLAY_AREA_*
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ff9d], a  ; source PLAY_AREA_*
	call MoveAllAttachedEnergiesToAnotherPokemonEffect
	ldh a, [hTemp_ffa0]
	jr SwitchUser_SwitchEffect.switch


AquaReturn_PlayerSelectEffect:
	ld a, PLAY_AREA_BENCH_1
	ldh [hTempPlayAreaLocation_ffa1], a
	; fallthrough

Teleport_PlayerSelectEffect:
	ldtx hl, SelectPokemonToPlaceInTheArenaText
	call DrawWideTextBox_WaitForInput
	bank1call HasAlivePokemonInBench
	bank1call OpenPlayAreaScreenForSelection
	; ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


Teleport_ReturnToDeckEffect:
	xor a  ; PLAY_AREA_ARENA
	call ReturnPlayAreaPokemonToDeckEffect
	ld a, 4
	jp DrawNCards_NoCardDetails


; returns carry if no Grass Energy in Play Area
EnergyTrans_CheckPlayArea: ; 2cb44 (b:4b44)
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTemp_ffa0], a
	call CheckCannotUseDueToStatus_Anywhere
	ret c ; cannot use Pkmn Power

; search in Play Area for at least 1 Grass Energy type
	ld a, DUELVARS_CARD_LOCATIONS
	call GetTurnDuelistVariable
.loop_deck
	ld a, [hl]
	and CARD_LOCATION_PLAY_AREA
	jr z, .next
	push hl
	ld a, l
	call GetCardIDFromDeckIndex
	call GetCardType
	pop hl
	cp TYPE_ENERGY_GRASS
	ret z
.next
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .loop_deck

; none found
	ldtx hl, NoGrassEnergyText
	scf
	ret

EnergyTrans_PrintProcedure: ; 2cb6f (b:4b6f)
	ldtx hl, ProcedureForEnergyTransferText
	bank1call DrawWholeScreenTextBox
	or a
	ret

EnergyTrans_TransferEffect: ; 2cb77 (b:4b77)
	ld a, DUELVARS_DUELIST_TYPE
	call GetTurnDuelistVariable
	cp DUELIST_TYPE_PLAYER
	jr z, .player
; not player
	bank1call Func_61a1
	bank1call PrintPlayAreaCardList_EnableLCD
	ret

.player
	xor a
	ldh [hCurSelectionItem], a
	bank1call Func_61a1

.draw_play_area
	bank1call PrintPlayAreaCardList_EnableLCD
	push af
	ldh a, [hCurSelectionItem]
	ld hl, PlayAreaSelectionMenuParameters
	call InitializeMenuParameters
	pop af
	ld [wNumMenuItems], a

; handle the action of taking a Grass Energy card
.loop_input_take
	call DoFrame
	call HandleMenuInput
	jr nc, .loop_input_take
	cp -1 ; b press?
	ret z

; a press
	ldh [hAIPkmnPowerEffectParam], a
	ldh [hCurSelectionItem], a
	call CheckIfCardHasGrassEnergyAttached
	jr c, .play_sfx ; no Grass attached

	ldh [hEnergyTransEnergyCard], a
	; temporarily take card away to draw Play Area
	call AddCardToHand
	bank1call PrintPlayAreaCardList_EnableLCD
	ldh a, [hAIPkmnPowerEffectParam]
	ld e, a
	ldh a, [hEnergyTransEnergyCard]
	; give card back
	call PutHandCardInPlayArea

	; draw Grass symbol near cursor
	ldh a, [hAIPkmnPowerEffectParam]
	ld b, SYM_GRASS
	call DrawSymbolOnPlayAreaCursor

; handle the action of placing a Grass Energy card
.loop_input_put
	call DoFrame
	call HandleMenuInput
	jr nc, .loop_input_put
	cp -1 ; b press?
	jr z, .remove_symbol

; a press
	ldh [hCurSelectionItem], a
	ldh [hAIEnergyTransPlayAreaLocation], a
	ld a, OPPACTION_EXECUTE_EFFECT_STEP
	call SetOppAction_SerialSendDuelData
	ldh a, [hAIEnergyTransPlayAreaLocation]
	ld e, a
	ldh a, [hEnergyTransEnergyCard]
	; give card being held to this Pokemon
	call AddCardToHand
	call PutHandCardInPlayArea

.remove_symbol
	ldh a, [hAIPkmnPowerEffectParam]
	ld b, SYM_SPACE
	call DrawSymbolOnPlayAreaCursor
	call EraseCursor
	jr .draw_play_area

.play_sfx
	call PlaySFX_InvalidChoice
	jr .loop_input_take

EnergyTrans_AIEffect: ; 2cbfb (b:4bfb)
	ldh a, [hAIEnergyTransPlayAreaLocation]
	ld e, a
	ldh a, [hEnergyTransEnergyCard]
	call AddCardToHand
	call PutHandCardInPlayArea
	bank1call PrintPlayAreaCardList_EnableLCD
	ret


; similar to CreateArenaOrBenchEnergyCardList
; fill wDuelTempList with the turn holder's energy cards
; in the arena or in a bench slot (their 0-59 deck indexes).
; the cards are also moved to another Play Area location
; input:
;   [hTempPlayAreaLocation_ff9d]: source PLAY_AREA_*
;   [hTempPlayAreaLocation_ffa1]: target PLAY_AREA_*
; output:
;   a: total number of energy cards found
;   carry: set if no energy cards were found
;   [wDuelTempList]: $ff-terminated list of energy cards
MoveAllAttachedEnergiesToAnotherPokemonEffect:
	ldh a, [hTempPlayAreaLocation_ff9d]
	or CARD_LOCATION_PLAY_AREA
	ld c, a
	ld b, 0  ; counter
	ld de, wDuelTempList
	ld a, DUELVARS_CARD_LOCATIONS
	call GetTurnDuelistVariable
.next_card_loop
	ld a, [hl]
	cp c
	jr nz, .skip_card  ; not in source Play Area
	ld a, l
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	and 1 << TYPE_ENERGY_F
	jr z, .skip_card  ; not an Energy card
	ld a, l     ; deck index
	ld [de], a  ; add to wDuelTempList
	inc de
	inc b
; move card to target location
	ldh a, [hTempPlayAreaLocation_ffa1]
	or CARD_LOCATION_PLAY_AREA
	ld [hl], a
.skip_card
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .next_card_loop
; all cards checked
	ld a, $ff
	ld [de], a
	ld a, b  ; load total number of cards
	or a
	ret nz  ; found some
; no energies found
	scf
	ret


; ------------------------------------------------------------------------------
; Color Manipulation
; ------------------------------------------------------------------------------


EnergySoak_ChangeColorEffect:
	ld a, WATER
	ld [wEnergyColorOverride], a
	jp SetUsedPokemonPowerThisTurn

EnergyJolt_ChangeColorEffect:
	ld a, LIGHTNING
	ld [wEnergyColorOverride], a
	jp SetUsedPokemonPowerThisTurn

EnergyBurn_ChangeColorEffect:
	ld a, FIRE
	ld [wEnergyColorOverride], a
	jp SetUsedPokemonPowerThisTurn


Shift_PlayerSelectEffect: ; 2cd21 (b:4d21)
	ldtx hl, ChoosePokemonWishToColorChangeText
	ldh a, [hTemp_ffa0]
	or $80
	call HandleColorChangeScreen
	ldh [hAIPkmnPowerEffectParam], a
	ret c ; cancelled

; check whether the color selected is valid
	; look in Turn Duelist's Play Area
	call .CheckColorInPlayArea
	ret nc
	; look in NonTurn Duelist's Play Area
	call SwapTurn
	call .CheckColorInPlayArea
	call SwapTurn
	ret nc
	; not found in either Duelist's Play Area
	ldtx hl, UnableToSelectText
	call DrawWideTextBox_WaitForInput
	jr Shift_PlayerSelectEffect ; loop back to start

; checks in input color in a exists in Turn Duelist's Play Area
; returns carry if not found.
.CheckColorInPlayArea: ; 2cd44 (b:4d44)
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	ld b, PLAY_AREA_ARENA
.loop_play_area
	push bc
	ld a, b
	call GetPlayAreaCardColor
	pop bc
	ld hl, hAIPkmnPowerEffectParam
	cp [hl]
	ret z ; found
	inc b
	dec c
	jr nz, .loop_play_area
	; not found
	scf
	ret


SetUsedPokemonPowerThisTurn_RestoreTrigger:
	ldh a, [hTemp_ffa0]
	ldh [hTempPlayAreaLocation_ff9d], a
	; jr SetUsedPokemonPowerThisTurn
	; fallthrough

SetUsedPokemonPowerThisTurn:
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD_FLAGS
	call GetTurnDuelistVariable
	set USED_PKMN_POWER_THIS_TURN_F, [hl]
	ret


Shift_ChangeColorEffect:
	ldh a, [hTemp_ffa0]
	add DUELVARS_ARENA_CARD_FLAGS
	call GetTurnDuelistVariable
	set USED_PKMN_POWER_THIS_TURN_F, [hl]

	ldh a, [hTemp_ffa0]
	ld e, a
	ldh a, [hAIPkmnPowerEffectParam]
	ld d, a
	; jr ColorShift_ChangeColorEffect
	; fallthrough

; changes the effective color of a Pokémon in play
; input:
;   e: offset of play area Pokémon
;   d: selected color (type) constant
ColorShift_ChangeColorEffect:
	call _ChangeCardColor
	call LoadCardNameAndInputColor
	ldtx hl, ChangedTheColorOfText
	jp DrawWideTextBox_WaitForInput


; changes the effective color of a Pokémon in play
; input:
;   e: offset of play area Pokémon
;   d: selected color (type) constant
_ChangeCardColor:
	ld a, e
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex

	ld a, e
	add DUELVARS_ARENA_CARD_CHANGED_TYPE
	ld l, a
	ld a, d
	or HAS_CHANGED_COLOR
	ld [hl], a
	ret

_ChangeCardColorPermanent:
	call _ChangeCardColor
	or IS_PERMANENT_COLOR
	ld [hl], a
	ret


; resets the effective color of the Areana Pokémon
ResetArenaCardColorEffect:
	xor a  ; PLAY_AREA_ARENA
	ld e, a
	; fallthrough

; resets the effective color of a Pokémon in play
; input:
;   e: offset of play area Pokémon
ResetCardColorEffect:
	call _ResetCardColor
	ld a, e
	call GetPlayAreaCardColor
	ld [hl], a
	call LoadCardNameAndInputColor
	ldtx hl, ChangedTheColorOfText
	jp DrawWideTextBox_WaitForInput


; resets the effective color of a Pokémon in play
; input:
;   e: offset of play area Pokémon
_ResetCardColor:
	ld a, e
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex

	ld a, e
	add DUELVARS_ARENA_CARD_CHANGED_TYPE
	ld l, a
	res HAS_CHANGED_COLOR_F, [hl]
	res IS_PERMANENT_COLOR_F, [hl]
	ret


HelpingHand_CheckUse:
	call CheckArenaPokemonHasStatus
	ret c  ; Arena card does not have status conditions
	; jp StepIn_PreconditionCheck
	; fallthrough

StepIn_PreconditionCheck:
	call CheckTriggeringPokemonIsOnTheBench
	ret c
	jp CheckPokemonPowerCanBeUsed_StoreTrigger


HelpingHand_RemoveStatusEffect:
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld b, a
	ld a, ATK_ANIM_HEAL
	bank1call PlayAdhocAnimationOnPlayAreaLocation

	ldh a, [hTemp_ffa0]
	add DUELVARS_ARENA_CARD_FLAGS
	call GetTurnDuelistVariable
	set USED_PKMN_POWER_THIS_TURN_F, [hl]
	ld l, DUELVARS_ARENA_CARD_STATUS
	ld [hl], NO_STATUS

	bank1call DrawDuelHUDs
	ret



HeadacheEffect: ; 2d00e (b:500e)
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS3
	call GetNonTurnDuelistVariable
	set SUBSTATUS3_HEADACHE, [hl]
	ret


; returns carry if Defending Pokemon has no attacks
Amnesia_CheckAttacks: ; 2d149 (b:5149)
	call SwapTurn
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Atk1Category]
	cp POKEMON_POWER
	jr nz, .has_attack
	ld hl, wLoadedCard2Atk2Name
	ld a, [hli]
	or [hl]
	jr nz, .has_attack
; has no attack
	call SwapTurn
	ldtx hl, NoAttackMayBeChoosenText
	scf
	ret
.has_attack
	call SwapTurn
	or a
	ret

Amnesia_AISelectEffect: ; 2d173 (b:5173)
	call AIPickAttackForAmnesia
	ldh [hTemp_ffa0], a
	ret

Amnesia_PlayerSelectEffect:
PlayerPickAttackForAmnesia:
	ldtx hl, ChooseAttackOpponentWillNotBeAbleToUseText
	call DrawWideTextBox_WaitForInput
	call HandleDefendingPokemonAttackSelection
	ld a, e
	ldh [hTemp_ffa0], a
	ret

; applies the Amnesia effect on the defending Pokemon,
; for the attack index in hTemp_ffa0.
Amnesia_DisableEffect:
ApplyAmnesiaToAttack:
	ld a, SUBSTATUS2_AMNESIA
	call ApplySubstatus2ToDefendingCard
	ld a, [wNoDamageOrEffect]
	or a
	ret nz ; no effect

; set selected attack as disabled
	ld a, DUELVARS_ARENA_CARD_DISABLED_ATTACK_INDEX
	call GetNonTurnDuelistVariable
	ldh a, [hTemp_ffa0]
	ld [hl], a

	ld l, DUELVARS_ARENA_CARD_LAST_TURN_EFFECT
	ld [hl], LAST_TURN_EFFECT_AMNESIA

	call IsPlayerTurn
	ret c ; return if Player

; the rest of the routine if for Opponent
; to announce which attack was used for Amnesia.
	call SwapTurn
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ld d, a
	ldh a, [hTemp_ffa0]
	ld e, a
	call GetAttackName
	call LoadTxRam2
	ldtx hl, WasChosenForTheEffectOfAmnesiaText
	call DrawWideTextBox_WaitForInput
	jp SwapTurn


; return carry if can use Cowardice
Cowardice_Check:
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTemp_ffa0], a
	call CheckCannotUseDueToStatus_Anywhere
	ret c ; return if cannot use

	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ldtx hl, EffectNoPokemonOnTheBenchText
	cp 2
	ret c ; return if no bench

	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD_FLAGS
	call GetTurnDuelistVariable
	ldtx hl, CannotBeUsedInTurnWhichWasPlayedText
	and CAN_EVOLVE_THIS_TURN
	cp 1  ; set carry if zero (played this turn)
	ret


Cowardice_PlayerSelectEffect:
	ldh a, [hTemp_ffa0]
	or a
	ret nz ; return if not Arena card
	ldtx hl, SelectPokemonToPlaceInTheArenaText
	call DrawWideTextBox_WaitForInput
	bank1call HasAlivePokemonInBench
	bank1call OpenPlayAreaScreenForSelection
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hAIPkmnPowerEffectParam], a
	ret


Cowardice_RemoveFromPlayAreaEffect:
	ldh a, [hTemp_ffa0]
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable

; put card in Discard Pile temporarily, so that
; all cards attached are discarded as well.
	push af
	ldh a, [hTemp_ffa0]
	ld e, a
	call MovePlayAreaCardToDiscardPile

; if card was in Arena, swap selected Bench
; Pokemon with Arena, otherwise skip.
	ldh a, [hTemp_ffa0]
	or a
	jr nz, .skip_switch
	ldh a, [hAIPkmnPowerEffectParam]
	ld e, a
	call SwapArenaWithBenchPokemon

.skip_switch
; move card back to Hand from Discard Pile
; and adjust Play Area
	pop af
	call MoveDiscardPileCardToHand
	call AddCardToHand
	call ShiftAllPokemonToFirstPlayAreaSlots

	xor a
	ld [wDuelDisplayedScreen], a
	ret


; return carry if no Lightning energy cards
CheckArenaPokemonHasEnergy_Lightning:
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ldtx hl, NotEnoughLightningEnergyText
	ld a, [wAttachedEnergies + LIGHTNING]
	cp 1
	ret


; return carry if no Fire energy cards
CheckArenaPokemonHasEnergy_Fire:
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ldtx hl, NotEnoughFireEnergyText
	ld a, [wAttachedEnergies + FIRE]
	cp 1
	ret


; return carry if no Water energy cards
CheckArenaPokemonHasEnergy_Water:
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ldtx hl, NotEnoughWaterEnergyText
	ld a, [wAttachedEnergies + WATER]
	cp 1
	ret


; return carry if no Psychic energy cards
CheckArenaPokemonHasEnergy_Psychic:
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ldtx hl, NotEnoughPsychicEnergyText
	ld a, [wAttachedEnergies + PSYCHIC]
	cp 1
	ret


DragonArrow_PlayerSelectEffect:
	call CreateListOfEnergiesAttachedToArena
	jr c, .none
	call DiscardAnyNumberOfAttachedEnergy_PlayerSelectEffect
	ret nc
.none
	xor a
	ldh [hTemp_ffa0], a
	ret


Psyburn_PlayerSelectEffect:
	call CreateListOfPsychicEnergyAttachedToArena
	jr DiscardAnyNumberOfAttachedEnergy_PlayerSelectEffect


SheerCold_PlayerSelectEffect:
WaterPulse_PlayerSelectEffect:
	call CreateListOfWaterEnergyAttachedToArena
	jr DiscardAnyNumberOfAttachedEnergy_PlayerSelectEffect


Thunderstorm_PlayerSelectEffect:
Discharge_PlayerSelectEffect:
	call CreateListOfLightningEnergyAttachedToArena
	jr DiscardAnyNumberOfAttachedEnergy_PlayerSelectEffect


Wildfire_PlayerSelectEffect:
	ldtx hl, DiscardOppDeckAsManyFireEnergyCardsText
	call DrawWideTextBox_WaitForInput
	; fallthrough

ScorchingColumn_PlayerSelectEffect:
	call CreateListOfFireEnergyAttachedToArena
	; jr DiscardAnyNumberOfAttachedEnergy_PlayerSelectEffect
	; fallthrough

; input:
;   [wDuelTempList]: list of attached energy cards to choose from
; output:
;   a: number of selected cards to discard
;   [hTemp_ffa0]: number of selected cards to discard
;   [wDuelTempList + DECK_SIZE]: list of selected energy cards
DiscardAnyNumberOfAttachedEnergy_PlayerSelectEffect:
	xor a
	ldh [hCurSelectionItem], a
	bank1call DisplayEnergyDiscardScreen

; show list to Player and, for each card selected to discard,
; increase a counter and store it
	xor a
	ld [wEnergyDiscardMenuDenominator], a
.loop
	ldh a, [hCurSelectionItem]
	ld [wEnergyDiscardMenuNumerator], a
	bank1call HandleEnergyDiscardMenuInput
	jr c, .done  ; cancelled
	ld c, a  ; deck index
	ldh a, [hCurSelectionItem]
	ld d, 0
	ld e, a  ; offset
	inc a
	ldh [hCurSelectionItem], a
	ld hl, wDuelTempList + DECK_SIZE
	add hl, de
	ld a, c  ; deck index
	ld [hl], a
	call RemoveCardFromDuelTempList  ; preserves bc
	jr c, .done  ; list is now empty
	bank1call DisplayEnergyDiscardMenu
	jr .loop

.done
; return carry if no cards were discarded
; output the result in hTemp_ffa0
	ldh a, [hCurSelectionItem]
	ldh [hTemp_ffa0], a
	cp 1  ; carry if zero
	ret


DragonArrow_AISelectEffect:
	call DamageTargetPokemon_AISelectEffect
; 	add DUELVARS_ARENA_CARD_HP
; 	call GetNonTurnDuelistVariable
; 	push hl
	call CreateListOfEnergiesAttachedToArena
	ldh [hTemp_ffa0], a
; 	ld c, a
; 	pop hl
; 	ld a, [hl]
; 	srl a
; 	cp 11
; 	jr nc, .done
; 	ld c, 1
; .done
; 	ld a, c
; 	ldh [hTemp_ffa0], a
	jr DiscardAnyNumberOfAttachedEnergy_AISelectEffect


Psyburn_AISelectEffect:
; AI always chooses all cards to discard
	call CreateListOfPsychicEnergyAttachedToArena
	ldh [hTemp_ffa0], a
	jr DiscardAnyNumberOfAttachedEnergy_AISelectEffect


SheerCold_AISelectEffect:
IF SLEEP_WITH_COIN_FLIP
	call DiscardOpponentEnergy_AISelectEffect
ENDC
	; jr WaterPulse_AISelectEffect
	; fallthrough

WaterPulse_AISelectEffect:
; AI always chooses all cards to discard
	call CreateListOfWaterEnergyAttachedToArena
	ldh [hTemp_ffa0], a
	jr DiscardAnyNumberOfAttachedEnergy_AISelectEffect


Wildfire_AISelectEffect:
ScorchingColumn_AISelectEffect:
; AI always chooses all cards to discard
	call CreateListOfFireEnergyAttachedToArena
	ldh [hTemp_ffa0], a
	jr DiscardAnyNumberOfAttachedEnergy_AISelectEffect


Thunderstorm_AISelectEffect:
Discharge_AISelectEffect:
; AI always chooses all cards to discard
	call CreateListOfLightningEnergyAttachedToArena
	ldh [hTemp_ffa0], a
	; jr DiscardAnyNumberOfAttachedEnergy_AISelectEffect
	; fallthrough

; input:
;   a: number of selected cards
;   [wDuelTempList]: list of valid attached energy cards
DiscardAnyNumberOfAttachedEnergy_AISelectEffect:
	ld hl, wDuelTempList
	ld de, wDuelTempList + DECK_SIZE
	ld c, a
	ld b, 0
	jp CopyDataHLtoDE


DragonArrow_DiscardEnergyEffect:
	call CreateListOfEnergiesAttachedToArena
	jr DiscardAnyNumberOfAttachedEnergy_DiscardEnergyEffect

Psyburn_DiscardEnergyEffect:
	call CreateListOfPsychicEnergyAttachedToArena
	jr DiscardAnyNumberOfAttachedEnergy_DiscardEnergyEffect

SheerCold_DiscardEnergyEffect:
WaterPulse_DiscardEnergyEffect:
	call CreateListOfWaterEnergyAttachedToArena
	jr DiscardAnyNumberOfAttachedEnergy_DiscardEnergyEffect

Thunderstorm_DiscardEnergyEffect:
Discharge_DiscardEnergyEffect:
	call CreateListOfLightningEnergyAttachedToArena
	jr DiscardAnyNumberOfAttachedEnergy_DiscardEnergyEffect

Wildfire_DiscardEnergyEffect:
	call CreateListOfFireEnergyAttachedToArena
	; jr DiscardAnyNumberOfAttachedEnergy_DiscardEnergyEffect
	; fallthrough

; input:
;   [hTemp_ffa0]: number of cards to discard
;   [wDuelTempList + DECK_SIZE]: list of energy cards to discard
; output:
;   [hTemp_ffa0]: updated number of discarded energies (counting double energies)
DiscardAnyNumberOfAttachedEnergy_DiscardEnergyEffect:
	ldh a, [hTemp_ffa0]
	or a
	ret z ; no cards to discard

; discard cards from wDuelTempList equal to the number
; of cards that were input in hTemp_ffa0.
; these are all the matching Energy cards attached to Arena card
; so it will discard the cards in order, regardless
; of the actual order that was selected by Player.
	ld b, 0
	ld c, a
	ld hl, wDuelTempList + DECK_SIZE
.loop_discard
	ld a, [hli]
	call PutCardInDiscardPile  ; preserves af, hl, bc
	call GetHowMuchEnergyCardIsWorth  ; preserves hl, bc
	add b
	ld b, a
	dec c
	jr nz, .loop_discard
	ld a, b
	ldh [hTemp_ffa0], a
	ret


; input:
;   a: deck index
; output:
;   a: how much energy the given card is worth
; preserves: hl, bc, de
GetHowMuchEnergyCardIsWorth:
	call LoadCardDataToBuffer2_FromDeckIndex  ; preserves hl, bc, de
	ld a, [wLoadedCard2Type]
	bit TYPE_ENERGY_F, a
	jr z, .not_an_energy_card
	and TYPE_PKMN  ; zero bit 3 to extract the type
	cp COLORLESS
	ld a, 1
	ret nz
	ld a, 2
	ret

.not_an_energy_card
	xor a
	ret



Retrieve2BasicEnergy_PlayerSelectEffect:
	ldtx hl, Choose2EnergyCardsFromDiscardPileForHandText
	; jp HandleEnergyCardsInDiscardPileSelection
	; fallthrough

; draws list of Energy Cards in Discard Pile
; for Player to select from.
; the Player can select up to 2 cards from the list.
; these cards are given in $ff-terminated list
; in hTempList.
HandleEnergyCardsInDiscardPileSelection:
	push hl
	xor a
	ldh [hCurSelectionItem], a
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	; call CreateEnergyCardListFromDiscardPile_AllEnergy
	pop hl
	jr c, .finish

	call DrawWideTextBox_WaitForInput
.loop
	call Helper_ChooseAnEnergyCardFromList
	jr nc, .selected

; Player is trying to exit screen,
; but can select up to 2 cards total.
; prompt Player to confirm exiting screen.
	ld a, 2
	call AskWhetherToQuitSelectingCards
	jr c, .loop
	jr .finish

.selected
; a card was selected, so add it to list
	call GetNextPositionInTempList
	ldh a, [hTempCardIndex_ff98]
	ld [hl], a
	call RemoveCardFromDuelTempList
	or a
	jr z, .finish ; no more cards?
	ldh a, [hCurSelectionItem]
	cp 2
	jr c, .loop ; already selected 2 cards?

.finish
; place terminating byte on list
	call GetNextPositionInTempList
	ld [hl], $ff
	or a
	ret

; Draws list of Energy Cards in Discard Pile for Player to select from.
; Output deck index or $ff in hTemp_ffa0 and a.
; Return carry if there are no cards to choose.
HandleSelectBasicEnergyFromDiscardPile_NoCancel:
	push hl
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	pop hl
	jr nc, .select_card
; return terminating byte
	ld a, $ff
	ldh [hTemp_ffa0], a
	scf
	ret

.select_card
	call DrawWideTextBox_WaitForInput
.loop
	call Helper_ChooseAnEnergyCardFromList
	jr c, .loop

	ldh a, [hTempCardIndex_ff98]
	ldh [hTemp_ffa0], a
	or a
	ret

; Draws list of Energy Cards in Discard Pile for Player to select from.
; input:
;   hl: text to display before choosing a card
;   hHowManyCardsToSelectOneByOne - how many cards still left to choose
; Output deck index or $ff in a.
; Return carry if cancelled or if there are no cards to choose.
HandleSelectBasicEnergyFromDiscardPile_AllowCancel:
	push hl
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	pop hl
	jr nc, .select_card
.not_chosen
; return terminating byte
	ld a, $ff
	scf
	ret

.select_card
	call DrawWideTextBox_WaitForInput
.loop
	call Helper_ChooseAnEnergyCardFromList
	jr nc, .selected

; Player is trying to exit screen, prompt to confirm.
	ldh a, [hHowManyCardsToSelectOneByOne]
	call AskWhetherToQuitSelectingCards
	jr c, .loop
	jr .not_chosen

.selected
	ldh a, [hTempCardIndex_ff98]
	or a
	ret

; Draws Discard Pile screen and textbox, and handles Player input.
; Returns carry if B is pressed to exit the card list screen.
; Otherwise, returns the selected card (deck index) at hTempCardIndex_ff98 and at a.
Helper_ChooseAnEnergyCardFromList:
	bank1call InitAndDrawCardListScreenLayout
	ldtx hl, ChooseAnEnergyCardText
	ldtx de, PlayerDiscardPileText
	bank1call SetCardListHeaderText
	bank1call DisplayCardList
	ret


;
PainAmplifier_DamageEffect:
	call SwapTurn
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	xor a  ; PLAY_AREA_ARENA
	ld b, a

.loop
	push bc
	ld e, a
	call GetCardDamageAndMaxHP
	or a
	jr z, .next  ; no damage
	ld a, e  ; PLAY_AREA_*
	ld b, a  ; input location
	ld de, 10  ; input damage
	call DealDamageToPlayAreaPokemon_RegularAnim

.next
	pop bc
	inc b
	ld a, b
	dec c
	jr nz, .loop
	jp SwapTurn


ApplyDestinyBondEffect: ; 2d987 (b:5987)
	ld a, SUBSTATUS1_DESTINY_BOND
	jp ApplySubstatus1ToAttackingCard


JunkMagnet_AISelectEffect:
	call CreateItemCardListFromDiscardPile
	ld a, 2
	jp PickFirstNCardsFromList_SelectEffect


Recover4Energy_AISelectEffect:
	call CreateEnergyCardListFromDiscardPile_AllEnergy
	ld a, 4
	jp PickFirstNCardsFromList_SelectEffect


QueenPressEffect:
	ld a, SUBSTATUS1_NO_DAMAGE_FROM_BASIC
	jp ApplySubstatus1ToAttackingCard


AttachBasicEnergyFromDiscardPile_PlayerSelectEffect:
	ldtx hl, Choose1BasicEnergyCardFromDiscardPileText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionFromDiscardPile_BasicEnergy_Forced
	ldh [hEnergyTransEnergyCard], a
	ret


AttachBasicEnergyFromDiscardPileToBench_PlayerSelectEffect:
	call AttachBasicEnergyFromDiscardPile_PlayerSelectEffect
	call EmptyScreen
	ldtx hl, ChoosePokemonToAttachEnergyCardText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionPokemonInBench
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


EnergyAssist_PlayerSelectEffect:
	ld a, $ff
	ldh [hTempPlayAreaLocation_ffa1], a
	ldh [hEnergyTransEnergyCard], a
	call CheckBenchIsNotEmpty
	ret c  ; no bench
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	ret c  ; no energies
	jr AttachBasicEnergyFromDiscardPileToBench_PlayerSelectEffect


RetrieveBasicEnergyFromDiscardPile_PlayerSelectEffect:
	ldtx hl, Choose1BasicEnergyCardFromDiscardPileText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionFromDiscardPile_BasicEnergy
	ldh [hEnergyTransEnergyCard], a
	or a  ; ignore carry
	ret

RetrieveBasicEnergyFromDiscardPile_AISelectEffect:
; AI picks the first energy card
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	ld a, [wDuelTempList]
	ldh [hEnergyTransEnergyCard], a
	or a  ; ignore carry
	ret

AttachBasicEnergyFromDiscardPileToBench_AISelectEffect:
	ld a, $ff
	ldh [hTempPlayAreaLocation_ffa1], a
; pick first energy card
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	ld a, [wDuelTempList]
	ldh [hEnergyTransEnergyCard], a
	ret c
	; FIXME
	ld a, PLAY_AREA_BENCH_1
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


Attach1DarknessEnergyFromDiscard_SelectEffect:
; pick the first energy card
	call CreateEnergyCardListFromDiscardPile_OnlyDarkness
	jr PickFirstEnergyFromList_SelectEffect


Attach1PsychicEnergyFromDiscard_SelectEffect:
; pick the first energy card
	call CreateEnergyCardListFromDiscardPile_OnlyPsychic
	jr PickFirstEnergyFromList_SelectEffect


Attach1WaterEnergyFromDiscard_SelectEffect:
; pick the first energy card
	call CreateEnergyCardListFromDiscardPile_OnlyWater
	jr PickFirstEnergyFromList_SelectEffect


Attach1FightingEnergyFromDiscard_SelectEffect:
; pick the first energy card
	call CreateEnergyCardListFromDiscardPile_OnlyFighting
	jr PickFirstEnergyFromList_SelectEffect


Attach1LightningEnergyFromDiscard_SelectEffect:
; pick the first energy card
	call CreateEnergyCardListFromDiscardPile_OnlyLightning
	jr PickFirstEnergyFromList_SelectEffect


Attach1GrassEnergyFromDiscard_SelectEffect:
; pick the first energy card
	call CreateEnergyCardListFromDiscardPile_OnlyGrass
	jr PickFirstEnergyFromList_SelectEffect


Attach1FireEnergyFromDiscard_SelectEffect:
; pick the first energy card
	call CreateEnergyCardListFromDiscardPile_OnlyFire
	; jr PickFirstEnergyFromList_SelectEffect
	; fallthrough


PickFirstEnergyFromList_SelectEffect:
	ld a, [wDuelTempList]
	ldh [hEnergyTransEnergyCard], a
	ret


; input:
;   a: number of cards to pick from wDuelTempList
PickFirstNCardsFromList_SelectEffect:
	ld de, hTempList

; input:
;   a: number of cards to pick from wDuelTempList
;   de: pointer to destination list
PickFirstNCardsFromList_SelectEffect_DE:
	ld hl, wDuelTempList
	ld c, a
.loop
	ld a, [hli]
	ld [de], a
	cp $ff  ; terminating byte
	ret z   ; done
	inc de
	dec c
	jr nz, .loop
	ld a, $ff
	ld [de], a  ; terminating byte
	ret


; FIXME not multiplayer compatible
AttachEnergyFromDiscard_AttachToPokemonEffect:
	call IsPlayerTurn
	jr c, .player_turn

; AI energy attachment selection
; special attack handling already picks a suitable Pokémon
	ldh a, [hTempPlayAreaLocation_ff9d]
	or CARD_LOCATION_PLAY_AREA
	ld e, a
	call SetCardLocationsFromDiscardPileToPlayArea
; show detail screen and which Pokemon was chosen to attach Energy
	jp Helper_GenericShowAttachedEnergyToPokemon

.player_turn
	ld hl, hTempList
.loop
	ld a, [hl]
	cp $ff
	ret z
	push hl
	ldtx hl, ChoosePokemonToAttachEnergyCardText
	bank1call DisplayCardDetailScreen
; select target Pokémon in play area
	call Helper_ChooseAPokemonInPlayArea
	; ldh a, [hTempPlayAreaLocation_ff9d]
; attach card(s) to the selected Pokemon
	or CARD_LOCATION_PLAY_AREA
	ld e, a
	pop hl
	ld a, [hli]
	call Helper_AttachCardFromDiscardPile
	jr .loop
	or a
	ret

; input:
;   [hTempList]: $ff-terminated list of discarded card indices to attach
AccelerateFromDiscard_AttachToPokemonEffect:
	ld e, CARD_LOCATION_ARENA
	; jr SetCardLocationsFromDiscardPileToPlayArea
	; fallthrough


; input:
;   e: CARD_LOCATION_* constant
;   [hTempList]: $ff-terminated list of discarded card indices to attach
SetCardLocationsFromDiscardPileToPlayArea:
	ld hl, hTempList
.loop
	ld a, [hli]
	cp $ff
	ret z
	call Helper_AttachCardFromDiscardPile
	jr .loop


; input:
;   [hTempPlayAreaLocation_ffa1]: PLAY_AREA_* of the target to attach energy to
;   [hEnergyTransEnergyCard]: deck index of discarded card to attach
AccelerateFromDiscard_AttachEnergyToPlayAreaEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	cp $ff
	ret z
	add CARD_LOCATION_ARENA
	ld e, a
	ldh a, [hEnergyTransEnergyCard]
	jr Helper_AttachCardFromDiscardPile


; input:
;   [hEnergyTransEnergyCard]: deck index of discarded card to attach
AccelerateFromDiscard_AttachEnergyToArenaEffect:
	ld e, CARD_LOCATION_ARENA
	ldh a, [hEnergyTransEnergyCard]
	; jr Helper_AttachCardFromDiscardPile
	; fallthrough


; input:
;   a: deck index of discarded card to attach
;   e: CARD_LOCATION_* constant
Helper_AttachCardFromDiscardPile:
	push hl
	call MoveDiscardPileCardToHand
	call GetTurnDuelistVariable
	ld a, e
	ld [hl], a
	pop hl
	ret


Scavenge_PlayerSelectEffect:
	call HandlePlayerSelectionFromDiscardPile_ItemTrainer
	ldh [hTemp_ffa0], a
	ret

Scavenge_AISelectEffect:
; AI picks first Trainer card in list
	call CreateItemCardListFromDiscardPile
	ld a, [wDuelTempList]
	ldh [hTemp_ffa0], a
	ret


; ------------------------------------------------------------------------------
; Energy Discard
; ------------------------------------------------------------------------------

DiscardEnergyAbility_PlayerSelectEffect:
	ldh a, [hTemp_ffa0]
	ld e, a
	bank1call HandleDiscardPlayAreaEnergy
	ldh [hEnergyTransEnergyCard], a
	ret


;
ThunderPunch_PlayerSelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a
	call CheckEnteredActiveSpotThisTurn
	ret nc  ; active this turn
	jr DiscardEnergy_PlayerSelectEffect


FirePunch_PlayerSelectEffect:
	call _StoreFF_CheckIfUserIsDamaged
	ret nz  ; damaged
	; jr DiscardEnergy_PlayerSelectEffect
	; fallthrough

DiscardEnergy_PlayerSelectEffect:
	bank1call HandleDiscardArenaEnergy
	ldh [hTemp_ffa0], a
	ret


;
ThunderPunch_AISelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a
	call CheckEnteredActiveSpotThisTurn
	ret nc  ; active this turn
	jr DiscardEnergy_AISelectEffect

;
FirePunch_AISelectEffect:
	call _StoreFF_CheckIfUserIsDamaged
	ret nz  ; damaged
	; jr DiscardEnergy_AISelectEffect
	; fallthrough

DiscardEnergy_AISelectEffect:
	xor a ; PLAY_AREA_ARENA
	call CreateArenaOrBenchEnergyCardList
	ld a, [wDuelTempList] ; pick first card
	ldh [hTemp_ffa0], a
	ret

DiscardBasicEnergy_AISelectEffect:
	xor a ; PLAY_AREA_ARENA
	call CreateArenaOrBenchEnergyCardList
	ld c, DOUBLE_COLORLESS_ENERGY
	call RemoveCardIDFromCardList
	ld a, [wDuelTempList] ; pick first card
	ldh [hTemp_ffa0], a
	ret


OptionalDiscardEnergyForStatus_AISelectEffect:
	ld a, [wAIAttackLogicFlags]
	bit AI_LOGIC_MIN_DAMAGE_CAN_KO_F, a
; apply status if the attack's damage is not enough to score a KO
	jr z, DiscardEnergy_AISelectEffect
	ret  ; no need for bonus effects


OptionalDiscardEnergy_PlayerSelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a
.select
	xor a ; PLAY_AREA_ARENA
	call CreateArenaOrBenchEnergyCardList
	jr c, .no_energy
	xor a ; PLAY_AREA_ARENA
	bank1call HandlePlayAreaEnergyDiscardMenu
	ldh [hTemp_ffa0], a
.no_energy
	or a  ; ignore carry if set
	ret


; output:
;   z: set if the user did not take damage
_StoreFF_CheckIfUserIsDamaged:
	ld a, $ff
	ldh [hTemp_ffa0], a
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	or a
	ret


InitializeEmptyList:
	ld a, $ff
	ldh [hTempList], a
	or a
	ret


BounceEnergy_BounceEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z
.bounce
	call PutCardInDiscardPile
	call MoveDiscardPileCardToHand
	call AddCardToHand
	ld d, a
.display_card
	call IsPlayerTurn  ; preserves bc, de
	ld a, d
	ret c
	ldtx hl, WasPlacedInTheHandText
	bank1call DisplayCardDetailScreen
	ret


Bounce2Energies_BounceEffect:
	ldh a, [hTempList]
	cp $ff
	ret z
	call BounceEnergy_BounceEffect.bounce
	ldh a, [hTempList + 1]
	cp $ff
	ret z
	jr BounceEnergy_BounceEffect.bounce


BounceOpponentEnergy_BounceEffect:
	call HandleNoDamageOrEffect
	ret c ; return if attack had no effect
	ldh a, [hEnergyTransEnergyCard]
	cp $ff
	ret z
	call SwapTurn
	call PutCardInDiscardPile
	call MoveDiscardPileCardToHand
	call AddCardToHand
	ld d, a
	call SwapTurn
	jr BounceEnergy_BounceEffect.display_card


DiscardEnergy_DiscardEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z
	jp PutCardInDiscardPile


Discard2Energies_PlayerSelectEffect:
	ldtx hl, ChooseAndDiscard2EnergyCardsText
	call DrawWideTextBox_WaitForInput
	ld a, 2
	; jr HandlePlayerSelection_EnergiesToDiscard
	; fallthrough

; input:
;   a: how many energies
; output:
;   carry: set if the selection was cancelled
HandlePlayerSelection_EnergiesToDiscard:
	push af
	xor a
	ldh [hCurSelectionItem], a
	; xor a ; PLAY_AREA_ARENA
	call CreateArenaOrBenchEnergyCardList
	call SortCardsInDuelTempListByID
	xor a ; PLAY_AREA_ARENA
	bank1call DisplayEnergyDiscardScreen
	pop af
	ld [wEnergyDiscardMenuDenominator], a

.loop_input
	bank1call HandleEnergyDiscardMenuInput
	ret c
	call GetNextPositionInTempList
	ldh a, [hTempCardIndex_ff98]
	ld [hl], a
	ld hl, wEnergyDiscardMenuNumerator
	inc [hl]
	ld a, [wEnergyDiscardMenuDenominator]
	ld c, a
	ldh a, [hCurSelectionItem]
	cp c
	jr nc, .done
	ldh a, [hTempCardIndex_ff98]
	call RemoveCardFromDuelTempList
	bank1call DisplayEnergyDiscardMenu
	jr .loop_input
.done
; return when 2 have been chosen
	or a
	ret

; select the first two Energies
; TODO avoid Energies of the same type as the user
Discard2Energies_AISelectEffect:
	xor a ; PLAY_AREA_ARENA
	call CreateArenaOrBenchEnergyCardList
	ld hl, wDuelTempList
	ld a, [hli]
	ldh [hTempList], a
	ld a, [hl]
	ldh [hTempList + 1], a
	ret

Discard2Energies_DiscardEffect:
	ld hl, hTempList
	ld a, [hli]
	call PutCardInDiscardPile
	ld a, [hli]
	jp PutCardInDiscardPile


IgnitedVoltage_PlayerSelectEffect:
	ld a, CARDTEST_ENERGIZED_MAGMAR
	jr DiscardEnergyFromMatchingPokemonInBench_PlayerSelectEffect

SearingSpark_PlayerSelectEffect:
	ld a, CARDTEST_ENERGIZED_ELECTABUZZ
	; jr DiscardEnergyFromMatchingPokemonInBench_PlayerSelectEffect
	; fallthrough

; input:
;   a: how to test the selected Pokémon (CARDTEST_* constants)
; output:
;   [hTemp_ffa0]: deck index of the selected energy to discard | $ff
DiscardEnergyFromMatchingPokemonInBench_PlayerSelectEffect:
	call CheckSomeMatchingPokemonInBench
	ld a, $ff
	ldh [hTemp_ffa0], a
	jr c, .done
.loop
	call HandlePlayerSelectionPokemonInBench_AllowCancel
	ret c  ; cancelled
; selected Benched Pokémon
	; ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call DynamicCardTypeTest
	jr nc, .loop  ; invalid card
; selected a valid Pokémon
	ldh a, [hTempPlayAreaLocation_ff9d]
	call CreateArenaOrBenchEnergyCardList
	jr c, .loop  ; no energy
	ldh a, [hTempPlayAreaLocation_ff9d]
	bank1call HandlePlayAreaEnergyDiscardMenu
	ldh [hTemp_ffa0], a
; ignore carry if set, because this is used for an EFFECTCMDTYPE_INITIAL_EFFECT_2
.done
	or a
	ret


; discards energy if the bonus is enough to score a KO
IgnitedVoltage_AISelectEffect:
	ld a, CARDTEST_ENERGIZED_MAGMAR
	jr FireLightningCombo_AISelectEffect

SearingSpark_AISelectEffect:
	ld a, CARDTEST_ENERGIZED_ELECTABUZZ
	; jr FireLightningCombo_AISelectEffect
	; fallthrough

FireLightningCombo_AISelectEffect:
	call CheckSomeMatchingPokemonInBench
	ld e, a  ; play area location of the matching Pokémon
	ld a, $ff
	ldh [hTemp_ffa0], a
	ret c  ; no matches
	ld a, [wAIAttackLogicFlags]
	bit AI_LOGIC_MIN_DAMAGE_CAN_KO_F, a
	ret nz  ; no need for bonus damage
	; bit AI_LOGIC_MAX_DAMAGE_CAN_KO_F, a
	; ret z  ; bonus damage is not enough
; choose an energy attached to the matching Pokémon
	ld a, e
	call CreateArenaOrBenchEnergyCardList
	ld a, [wDuelTempList] ; pick first card
	ldh [hTemp_ffa0], a
	ret


ThunderWave_PlayerSelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a
	call CheckEnteredActiveSpotThisTurn
	ret nc  ; active this turn
	jp DiscardEnergy_PlayerSelectEffect


ThunderWave_AISelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a
	call CheckEnteredActiveSpotThisTurn
	ret nc  ; active this turn
	jp DiscardEnergy_AISelectEffect


; ------------------------------------------------------------------------------
; Energy Discard (Opponent)
; ------------------------------------------------------------------------------

; handles screen for selecting an Energy card to discard
; that is attached to Defending Pokemon,
; and store the Player selection in [hEnergyTransEnergyCard].
DiscardOpponentEnergy_PlayerSelectEffect:
	call SwapTurn
	xor a ; PLAY_AREA_ARENA
	call CreateArenaOrBenchEnergyCardList
	jr c, .no_energy
	ldtx hl, ChooseDiscardEnergyCardFromOpponentText
	call DrawWideTextBox_WaitForInput
	xor a ; PLAY_AREA_ARENA
	bank1call DisplayEnergyDiscardScreen

.loop_input
	bank1call HandleEnergyDiscardMenuInput
	jr c, .loop_input

	ldh a, [hTempCardIndex_ff98]
	ldh [hEnergyTransEnergyCard], a ; store selected card to discard
	jp SwapTurn

.no_energy
	ld a, $ff
	ldh [hEnergyTransEnergyCard], a
	jp SwapTurn

DiscardOpponentEnergy_AISelectEffect:
	call AIPickEnergyCardToDiscardFromDefendingPokemon
	ldh [hEnergyTransEnergyCard], a
	ret

DiscardOpponentEnergy_DiscardEffect:
	call HandleNoDamageOrEffect
	ret c ; return if attack had no effect
.affected
	; check if energy card was chosen to discard
	ldh a, [hEnergyTransEnergyCard]
	cp $ff
	ret z ; return if none selected

	; discard Defending card's energy
	call SwapTurn
	call PutCardInDiscardPile
	ld a, DUELVARS_ARENA_CARD_LAST_TURN_EFFECT
	call GetTurnDuelistVariable
	ld [hl], LAST_TURN_EFFECT_DISCARD_ENERGY
	jp SwapTurn


; ------------------------------------------------------------------------------


; output:
;   a: deck index of the selected card | $ff
;   [hTempCardIndex_ff98]: deck index of the selected card
;   carry: set if there are no Pokémon or the Player cancelled the selection
ChooseBasicPokemonFromDeck_PlayerSelectEffect:
	call CreateDeckCardList
	ldtx hl, ChooseBasicPokemonFromDeckText
	ldtx bc, BasicPokemonDeckText
	ld a, CARDTEST_BASIC_POKEMON
	call LookForCardsInDeckList
	ld a, $ff
	ret c  ; none in deck, refused to look
	jp HandlePlayerSelectionBasicPokemonFromDeckList


Swarm_PlayerSelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a
	call CallForFamily_CheckDeckAndPlayArea
	ret c
	call ChooseBasicPokemonFromDeck_PlayerSelectEffect
	ldh [hTemp_ffa0], a
	ret


Swarm_AISelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a
	call CallForFamily_CheckDeckAndPlayArea
	ret c
	call SearchDeck_BasicPokemon
	ldh [hTemp_ffa0], a
	ret



; returns carry if can't add Pokemon from deck
CallForFamily_CheckDeckAndPlayArea:
	call CheckDeckIsNotEmpty
	ret c ; no cards in deck
	jp CheckBenchIsNotFull


CallForFamily_PlayerSelectEffect:
	ld a, $ff
	ldh [hTempList], a
	ldh [hTempList + 1], a
	ldh [hTempList + 2], a  ; terminator

; handle selection of the first card
	call ChooseBasicPokemonFromDeck_PlayerSelectEffect
	ret c  ; none in deck or cancelled
	ldh [hTempList], a
; remove the first card from the list
	call RemoveCardFromDuelTempList
	ld a, [wDuelTempList]
	cp $ff
	ret z  ; no more cards in the deck

; check whether there is a second free slot in the bench
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	cp MAX_PLAY_AREA_POKEMON - 1
	ret nc  ; only has space for one

; handle selection of the second card
	call HandlePlayerSelectionBasicPokemonFromDeckList
	ldh [hTempList + 1], a
	ret


CallForFamily_AISelectEffect:
	ld a, $ff
	ldh [hTempList], a
	ldh [hTempList + 1], a
	ldh [hTempList + 2], a  ; terminator

; handle selection of the first card
	call CreateDeckCardList
	ld a, CARDTEST_BASIC_POKEMON
	call SearchDuelTempListForMatchingCard
	ret c  ; none in deck
	ldh [hTempList], a

; remove the first card from the list
	call RemoveCardFromDuelTempList
	ld a, [wDuelTempList]
	cp $ff
	ret z  ; no more cards in the deck

; check whether there is a second free slot in the bench
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	cp MAX_PLAY_AREA_POKEMON - 1
	ret nc  ; only has space for one

; handle selection of the second card
	ld a, CARDTEST_BASIC_POKEMON
	call SearchDuelTempListForMatchingCard
	ldh [hTempList + 1], a
	ret


CallForFamily_PutInPlayAreaEffect:
	ld hl, hTempList
.loop
	ld a, [hl]
	cp $ff
	jp z, SyncShuffleDeck
	call .PutInPlayArea
	jp c, SyncShuffleDeck
	inc hl
	jr .loop

; input:
;   hl: pointer to deck index
.PutInPlayArea:
	call SearchCardInDeckAndSetToJustDrawn  ; preserves everything
	call AddCardToHand  ; preserves everything
	push hl
	call PutHandPokemonCardInPlayArea
	pop hl
	ret c
	push hl
	call IsPlayerTurn
	pop hl
	ccf
	ret nc
	; display card on screen
	ld a, [hl]
	push hl
	ldtx hl, PlacedOnTheBenchText
	bank1call DisplayCardDetailScreen
	pop hl
	ret


Swarm_PutInPlayAreaEffect:
	ld hl, hTemp_ffa0
	ldh a, [hTemp_ffa0]
	cp $ff
	jp z, SyncShuffleDeck
	call CallForFamily_PutInPlayAreaEffect.PutInPlayArea
	jp SyncShuffleDeck


; ------------------------------------------------------------------------------

LightScreenEffect:
	ld a, SUBSTATUS1_HALVE_DAMAGE
	jp ApplySubstatus1ToAttackingCard


; deal 10 damage to all benched Pokémon
Earthquake10Effect:
	call DamageAllFriendlyPokemon10Effect
	jp DamageAllOpponentBenched10Effect


Selfdestruct80Bench20Effect:
	ld a, 80
	jr Selfdestruct100Bench20Effect.recoil

Selfdestruct100Bench20Effect:
	ld a, 100
.recoil
	call DealRecoilDamageToSelf
	; jr Earthquake20Effect
	; fallthrough

; deal 20 damage to all benched Pokémon
Earthquake20Effect:
	call DamageAllFriendlyPokemon20Effect
	jp DamageAllOpponentBenched20Effect


DiscardAllAttachedEnergiesEffect:
	xor a  ; PLAY_AREA_ARENA
	; jr DiscardAllAttachedEnergies
	; fallthrough

; input:
;   a: PLAY_AREA_* of the target Pokémon
DiscardAllAttachedEnergies:
	call CreateArenaOrBenchEnergyCardList
	ld hl, wDuelTempList
; put all energy cards in Discard Pile
.loop
	ld a, [hli]
	cp $ff
	ret z
	call PutCardInDiscardPile
	jr .loop


; similar to CreateArenaOrBenchEnergyCardList
; fill wDuelTempList with the turn holder's energy cards
; in the arena or in a bench slot (their 0-59 deck indexes).
; the cards are also moved to the discard pile
; output:
;   a: total number of energy cards found
;   carry: set if no energy cards were found
;   [wDuelTempList]: $ff-terminated list of energy cards
DiscardAllAttachedEnergiesOnTurnHolderSideEffect:
	ld c, CARD_LOCATION_PLAY_AREA
	ld b, 0  ; counter
	ld de, wDuelTempList
	ld a, DUELVARS_CARD_LOCATIONS
	call GetTurnDuelistVariable
.next_card_loop
	ld a, [hl]
	and c
	jr z, .skip_card  ; not in Play Area
	ld a, l
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	and 1 << TYPE_ENERGY_F
	jr z, .skip_card  ; not an Energy card
	ld a, l     ; deck index
	ld [de], a  ; add to wDuelTempList
	inc de
	inc b
	call PutCardInDiscardPile  ; preserves af, hl, bc, de
.skip_card
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .next_card_loop
; all cards checked
	ld a, $ff
	ld [de], a
	ld a, b  ; load total number of cards
	or a
	ret nz  ; found some
; no energies found
	scf
	ret


SelectUpTo2Benched_PlayerSelectEffect:
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
	ld [wce72], a
	bank1call Func_61a1
.start
	bank1call PrintPlayAreaCardList_EnableLCD
	push af
	ld a, [wce72]
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

	ld [wce72], a
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
	call DrawSymbolOnPlayAreaCursor
; store it in the list of chosen Bench Pokemon
	call GetNextPositionInTempList
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
	call GetNextPositionInTempList
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
	call DrawSymbolOnPlayAreaCursor
	call EraseCursor
	pop af

	dec a
	ld [wce72], a
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

SelectUpTo2Benched_AISelectEffect: ; 2e6c3 (b:66c3)
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
	call SwapTurn
	ret

SelectUpTo2Benched_BenchDamageEffect:
	call SwapTurn
	ld hl, hTempList
.loop_selection
	ld a, [hli]
	cp $ff
	jp z, SwapTurn  ; done
	push hl
	ld b, a
	ld de, 10
	call DealDamageToPlayAreaPokemon_RegularAnim
	pop hl
	jr .loop_selection

Sonicboom_UnaffectedByColorEffect:
	ld hl, wDamageFlags
	set UNAFFECTED_BY_WEAKNESS_F, [hl]
	set UNAFFECTED_BY_RESISTANCE_F, [hl]
	ret

UnaffectedByResistanceEffect:
	ld hl, wDamageFlags
	set UNAFFECTED_BY_RESISTANCE_F, [hl]
	ret

UnaffectedByWeaknessResistancePowersEffectsEffect:
	ld hl, wDamageFlags
	set UNAFFECTED_BY_WEAKNESS_F, [hl]
	set UNAFFECTED_BY_RESISTANCE_F, [hl]
	set UNAFFECTED_BY_POWERS_OR_EFFECTS_F, [hl]
	ret


QuiverDance_PlayerSelectEffect:
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, $ff
	ldh [hEnergyTransEnergyCard], a
; search cards in Deck
	call CreateDeckCardList
	ldtx hl, Choose1BasicEnergyCardFromDeckText
	ldtx bc, BasicEnergyText
	ld a, CARDTEST_BASIC_ENERGY
	call LookForCardsInDeckList
	ret c  ; no cards, the Player refuses to search the deck
; choose a card from the deck
	call HandlePlayerSelectionBasicEnergyFromDeckList
	ldh [hEnergyTransEnergyCard], a
	ret

QuiverDance_AISelectEffect:
; AI just selects the first card in the deck
	call CreateDeckCardList
	ld a, CARDTEST_BASIC_ENERGY
	call FilterCardList
	ld a, [wDuelTempList]
	ldh [hEnergyTransEnergyCard], a
	ret


EnergySpike_PlayerSelectEffect:
	xor a  ; FALSE
	ld [wMultiPurposeByte], a
	jr Accelerate1EnergyFromDeck_PlayerSelectEffect.start

NutritionSupport_PlayerSelectEffect:
Accelerate1EnergyFromDeck_PlayerSelectEffect:
	ld a, TRUE
	ld [wMultiPurposeByte], a
.start
	ld a, $ff
	ldh [hEnergyTransEnergyCard], a

; search cards in Deck
	call CreateDeckCardList
	ldtx hl, Choose1BasicEnergyCardFromDeckText
	ldtx bc, BasicEnergyText
	ld a, CARDTEST_BASIC_ENERGY
	call LookForCardsInDeckList
	ret c  ; no cards, the Player refuses to search the deck

; choose a card from the deck
	call HandlePlayerSelectionBasicEnergyFromDeckList
	ldh [hEnergyTransEnergyCard], a
	ret c  ; no cards or the Player cancelled selection

; choose a Pokemon in Play Area to attach card
	call EmptyScreen
	call AttachEnergyToPokemon_PlayerSelectEffect
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


; choose a Pokemon in Play Area to attach card
; input:
;   [wMultiPurposeByte]: TRUE if the Arena Pokémon is a valid choice
AttachEnergyToPokemon_PlayerSelectEffect:
	ldtx hl, ChoosePokemonToAttachEnergyCardText
.display
	call DrawWideTextBox_WaitForInput
	ld a, [wMultiPurposeByte]
	or a
	jp z, HandlePlayerSelectionPokemonInBench
	jp HandlePlayerSelectionPokemonInPlayArea


EnergyGenerator_PlayerSelectEffect:
	call Accelerate1EnergyFromDeck_PlayerSelectEffect
	ret c
.loop
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, 30
	call CheckPokemonHasEnoughHP
	ret nc
	call AttachEnergyToPokemon_PlayerSelectEffect.display
	ldh [hTempPlayAreaLocation_ffa1], a
	jr .loop


EnergySpike_AISelectEffect:
NutritionSupport_AISelectEffect:
Accelerate1EnergyFromDeck_AISelectEffect:
; retrieve the preserved [hTempPlayAreaLocation_ffa1] from scoring phase
; just for safety, ensure it is a valid play area index
	ld a, $ff
	ldh [hEnergyTransEnergyCard], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ldh a, [hTempPlayAreaLocation_ffa1]
	cp [hl]
	ret nc  ; error, use $ff for [hEnergyTransEnergyCard]
; find the first available energy
	call CreateDeckCardList
	ld hl, wDuelTempList
.loop_deck
	ld a, [hli]
	ldh [hEnergyTransEnergyCard], a
	cp $ff
	ret z  ; end of list
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY
	jr c, .loop_deck  ; not an energy
	cp TYPE_ENERGY + NUM_COLORED_TYPES
	jr nc, .loop_deck  ; not a basic energy
	or a  ; reset carry flag
	ret


Accelerate1EnergyFromDeck_AttachEnergyEffect:
	ldh a, [hEnergyTransEnergyCard]
	cp $ff
	jp z, SyncShuffleDeck  ; done

; add card to hand and attach it to the selected Pokemon
	call SearchCardInDeckAndSetToJustDrawn
	call AddCardToHand
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	ldh a, [hEnergyTransEnergyCard]
	call PutHandCardInPlayArea
	call IsPlayerTurn
	jp c, SyncShuffleDeck  ; done

; not Player, so show detail screen
; and which Pokemon was chosen to attach Energy.
	call Helper_ShowAttachedEnergyToPokemon
	jp SyncShuffleDeck


QuiverDance_AttachEnergyEffect:
	call Accelerate1EnergyFromDeck_AttachEnergyEffect
	call FocusEnergyEffect
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a   ; location
	ld d, 30  ; damage
	jp HealPlayAreaCardHP


EnergyGenerator_AttachEnergyEffect:
	call SetUsedPokemonPowerThisTurn_RestoreTrigger
	call Accelerate1EnergyFromDeck_AttachEnergyEffect
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a   ; location
	jp Put2DamageCountersOnTarget


EnergyLift_PreconditionCheck:
	call CheckBenchIsNotEmpty
	ret c  ; no bench
	call AttachEnergyFromHand_HandCheck
	ret c
	jp CheckPokemonPowerCanBeUsed_StoreTrigger


ClairvoyantSense_PreconditionCheck:
	call CheckBenchIsNotEmpty
	ret c  ; no bench
	call CreateHandCardList_OnlyPsychicEnergy
	ldtx hl, NoEnergyCardsText
	ret c
	call CheckDeckSizeGreaterThan1
	ret c
	jp CheckPokemonPowerCanBeUsed_StoreTrigger

;	ld a, [wAlreadyPlayedEnergyOrSupporter]
;	and USED_FIRESTARTER_THIS_TURN
;	jr nz, .already_used

;.already_used
;	ldtx hl, OnlyOncePerTurnText
;	scf
;	ret


RainbowTeam_OncePerTurnCheck:
	call CheckBenchIsNotEmpty
	ret c  ; no bench
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	ret c  ; no energy
	call CheckNoDuplicateColorsInPlayArea
	ldtx hl, MultiplePokemonOfTheSameColorText
	ret c  ; duplicate colors
	jp CheckPokemonPowerCanBeUsed_StoreTrigger

;	ld a, [wAlreadyPlayedEnergyOrSupporter]
;	and USED_FIRESTARTER_THIS_TURN
;	jr nz, .already_used

;.already_used
;	ldtx hl, OnlyOncePerTurnText
;	scf
;	ret


RainbowTeam_AttachEnergyEffect:
	; input: hHowManyCardsToSelectOneByOne - how many cards still left to choose
	; Output deck index or $ff in a.
	; Return carry if cancelled or if there are no cards to choose.
	ld a, 1
	ldh [hHowManyCardsToSelectOneByOne], a
	ldtx hl, Choose1BasicEnergyCardFromDiscardPileText
	call HandleSelectBasicEnergyFromDiscardPile_AllowCancel
	ldh [hEnergyTransEnergyCard], a
	xor a  ; cannot select active spot
	ld hl, .retrieve
	jr _AttachEnergyFromDiscardPileToBenchEffect

.retrieve
	ldh a, [hEnergyTransEnergyCard]
	ld [wDuelTempList], a
	ret


CrushingCharge_DiscardAndAttachEnergyEffect:
	ld a, 1
	call DiscardFromDeckEffect
; check whether the discarded card is a basic energy
	ld a, [wDuelTempList]
	ldh [hEnergyTransEnergyCard], a
	cp $ff
	ret z
	call GetCardIDFromDeckIndex  ; preserves af, hl, bc
	call GetCardType  ; preserves hl, bc
	cp TYPE_ENERGY
	jp c, SetUsedPokemonPowerThisTurn  ; not a basic energy
	cp TYPE_ENERGY_DOUBLE_COLORLESS
	jp nc, SetUsedPokemonPowerThisTurn  ; not a basic energy
	ld a, 1  ; can select active spot
	ld hl, RainbowTeam_AttachEnergyEffect.retrieve
	jr _AttachEnergyFromDiscardPileToBenchEffect


LightningHaste_OncePerTurnCheck:
	xor a  ; PLAY_AREA_ARENA
	ld e, 20  ; HP
	call CheckPokemonHasEnoughHP
	ret c  ; not enough HP
	call CreateEnergyCardListFromDiscardPile_OnlyLightning
	ret c  ; no energy
	jp CheckPokemonPowerCanBeUsed_StoreTrigger


LightningHaste_AttachEnergyEffect:
; attach an energy to the Active Pokémon
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	call .attach
; put 1 damage counter on the Active Pokémon
	ld e, PLAY_AREA_ARENA
	jp Put1DamageCounterOnTarget
	; jp Deal10DamageToFriendlyTarget_DamageEffect

; this is a separate sub-routine because we need to `push hl` before jumping,
; and a `call` puts pointers on the stack above the `push hl`, so it must
; be an explicit jump.
.attach
	ld hl, CreateEnergyCardListFromDiscardPile_OnlyLightning
	push hl
	jr _AttachEnergyFromDiscardPileToBenchEffect.attach


Firestarter_OncePerTurnCheck:
	call CheckBenchIsNotEmpty
	ret c  ; no bench
	call CreateEnergyCardListFromDiscardPile_OnlyFire
	ret c  ; no energy
	jp CheckPokemonPowerCanBeUsed_StoreTrigger

;	ld a, [wAlreadyPlayedEnergyOrSupporter]
;	and USED_FIRESTARTER_THIS_TURN
;	jr nz, .already_used

;.already_used
;	ldtx hl, OnlyOncePerTurnText
;	scf
;	ret

Firestarter_AttachEnergyEffect:
	xor a  ; cannot select active spot
	ld hl, CreateEnergyCardListFromDiscardPile_OnlyFire
	; jr _AttachEnergyFromDiscardPileToBenchEffect
	; fallthrough

; input:
;   a: (boolean) whether active Pokémon can be selected
;  hl: function to place an energy card in [wDuelTempList]
_AttachEnergyFromDiscardPileToBenchEffect:
	ld [wMultiPurposeByte], a
	push hl
	ld a, DUELVARS_DUELIST_TYPE
	call GetTurnDuelistVariable
	cp DUELIST_TYPE_LINK_OPP
	jr z, .link_opp
	and DUELIST_TYPE_AI_OPP
	jr z, .player

; AI Pokémon selection logic is in HandleAIFirestarterEnergy
	pop hl
	ld hl, RainbowTeam_AttachEnergyEffect.retrieve
	push hl
	jr .attach

.player
	call AttachEnergyToPokemon_PlayerSelectEffect
	ld e, a  ; set selected Pokémon
	ldh [hTempPlayAreaLocation_ffa1], a
	call SerialSend8Bytes
	jr .attach

.link_opp
	call SerialRecv8Bytes
	ld a, e  ; get selected Pokémon
	ldh [hTempPlayAreaLocation_ffa1], a
	; fallthrough

.attach
; flag Firestarter as being used (requires [hTempPlayAreaLocation_ff9d])
	call SetUsedPokemonPowerThisTurn_RestoreTrigger
	; ld a, [wAlreadyPlayedEnergyOrSupporter]
	; or USED_FIRESTARTER_THIS_TURN
	; ld [wAlreadyPlayedEnergyOrSupporter], a

; pick Energy from card list
	; call CreateEnergyCardListFromDiscardPile_OnlyFire
	pop hl
	call CallHL
; input e: CARD_LOCATION_* constant
	ldh a, [hTempPlayAreaLocation_ffa1]
	or CARD_LOCATION_PLAY_AREA
	ld e, a
; input a: deck index of discarded card to attach
	ld a, [wDuelTempList]
	call Helper_AttachCardFromDiscardPile

	call IsPlayerTurn
	jr c, .done
	call Helper_GenericShowAttachedEnergyToPokemon

.done
	bank1call Func_2c10b
	jp ExchangeRNG


WaterAbsorb_PreconditionCheck:
	call CreateEnergyCardListFromDiscardPile_OnlyWater
	ret c  ; no energy
	jp CheckPokemonPowerCanBeUsed_StoreTrigger


WaterAbsorb_AttachEnergyEffect:
; attach an energy to the triggering Pokémon
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	ld hl, CreateEnergyCardListFromDiscardPile_OnlyWater
	push hl
	jr _AttachEnergyFromDiscardPileToBenchEffect.attach


Hurricane_PlayerSelectEffect:
	ldtx hl, ChoosePokemonToReturnToTheHandText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	call HandlePlayerSelectionPokemonInPlayArea_AllowCancel
	ldh [hTempPlayAreaLocation_ffa1], a
	jp SwapTurn


Hurricane_AISelectEffect:
	call SwapTurn
	call GetBenchPokemonWithHighestHP
	ldh [hTempPlayAreaLocation_ffa1], a
	jp SwapTurn


Hurricane_ReturnToHandEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	cp $ff
	ret z  ; none selected
	or a
	jr nz, .bench
; arena
	call HandleNoDamageOrEffect
	ret c ; is unaffected
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	or a
	ret z  ; Knocked Out
	xor a  ; PLAY_AREA_ARENA
.bench
	call SwapTurn
	call ReturnPokemonAndAttachedCardsToHandEffect
	jp SwapTurn


Fly_ReturnToHandEffect:
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	or a
	ret z  ; Knocked Out
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	; jp ReturnPokemonAndAttachedCardsToHandEffect
	; fallthrough


; assume:
;   call to SwapTurn if necessary
; input:
;   [hTempPlayAreaLocation_ffa1]: PLAY_AREA_* of the cards to return to the hand
ReturnPokemonAndAttachedCardsToHandEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	push af
	ldh a, [hTempPlayAreaLocation_ffa1]
	call ReturnPokemonAndAttachedCardsToHand  ; preserves de
	call EmptyPlayAreaSlot  ; input e
	pop af

	call LoadCardDataToBuffer1_FromDeckIndex
	call LoadCard1NameToRamText
	ldtx hl, PokemonAndAllAttachedCardsReturnedToHandText
	call DrawWideTextBox_WaitForInput
	xor a
	ld [wDuelDisplayedScreen], a
	ret


; input:
;   a: PLAY_AREA_* of the cards to return to the hand
; preserves: bc, de
ReturnPokemonAndAttachedCardsToHand:
	push de
	or CARD_LOCATION_ARENA
	ld e, a
	ld a, DUELVARS_CARD_LOCATIONS
	call GetTurnDuelistVariable
.loop_locations
	ld a, [hl]
	cp e
	jr nz, .next_card
; found a card in the given location
	ld a, l
	call AddCardToHand  ; preserves: af, hl, de
.next_card
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .loop_locations
	pop de
	ret


; This lazy version of EmptyPlayAreaSlot changes fewer variables.
; Assume that it is used in conjunction with an attack.
; After attacking, the engine takes care of cleaning up empty slots.
; Sets `DUELVARS_*_CARD_HP` to zero, which effectively counts
; as a KO and triggers the Active Pokémon replacement routine.
; Also sets `DUELVARS_*_CARD` to $ff, which
;   (1) signals an empty slot;
;   (2) prevents counting a prize-awarding KO
; input:
;   a: PLAY_AREA_* of the target to remove
; preserves: bc, d
LazyEmptyPlayAreaSlot:
	ld e, a
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ld [hl], $ff
	ld a, DUELVARS_ARENA_CARD_HP
	add e
	ld l, a
	ld [hl], 0
	ret


Whirlwind_SelectEffect:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	cp 2
	jr nc, RepelDefendingPokemon_SelectEffect
; no Bench Pokemon
	ld a, $ff
	ldh [hTempPlayAreaLocation_ffa1], a
	ret

RepelDefendingPokemon_SelectEffect:
	call DuelistSelectForcedSwitch
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


Ram_RecoilSwitchEffect:
	call Recoil10Effect
	; jr Whirlwind_SwitchEffect
	; fallthrough


Whirlwind_SwitchEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	; jr HandleSwitchDefendingPokemonEffect
	; fallthrough

HandleSwitchDefendingPokemonEffect:
	ld e, a
	cp $ff
	ret z

; check Defending Pokemon's HP
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	or a
	jr nz, .switch

; if 0, handle Destiny Bond first
	push de
	call HandleDestinyBondSubstatus
	pop de

.switch
	call HandleNoDamageOrEffect
	ret c
	; fallthrough

ForceSwitchDefendingPokemon:
; attack was successful, switch Defending Pokemon
	call SwapTurn
	call SwapArenaWithBenchPokemon
	call SwapTurn

	xor a
	ld [wccc5], a
	ld [wDuelDisplayedScreen], a
	inc a
	ld [wccef], a
	ret


IntimidatingRoar_SwitchEffect:
	call SetUsedPokemonPowerThisTurn_RestoreTrigger
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	jr ForceSwitchDefendingPokemon


RapidSpin_PlayerSelectEffect:
	call SwitchUser_PlayerSelectEffect  ; ffa0
	; ldh a, [hTemp_ffa0]
	; ldh [hTempPlayAreaLocation_ffa1], a
	jp Whirlwind_SelectEffect  ; ffa1

RapidSpin_AISelectEffect:
	call SwitchUser_AISelectEffect  ; ffa0
	; ldh a, [hTemp_ffa0]
	; ldh [hTempPlayAreaLocation_ffa1], a
	jp Whirlwind_SelectEffect  ; ffa1

RapidSpin_SwitchEffect:
	call Whirlwind_SwitchEffect  ; ffa1
	; ldh a, [hTempPlayAreaLocation_ffa1]
	; ldh [hTemp_ffa0], a
	jp SwitchUser_SwitchEffect  ; ffa0


SilverWhirlwind_SwitchEffect:
	call Whirlwind_SwitchEffect
; refresh screen to show new Pokémon
	xor a  ; REFRESH_DUEL_SCREEN
	ld [wDuelDisplayedScreen], a
	bank1call DrawDuelMainScene
	jp SilverWhirlwind_StatusEffect


; return carry if Defending Pokemon has no attacks
Metronome_CheckAttacks:
	call CheckIfDefendingPokemonHasAnyAttack
	ldtx hl, NoAttackMayBeChoosenText
	ret

; does nothing for AI
Metronome_AISelectEffect:
	ret

; Metronome1_UseAttackEffect:
; 	ld a, 1 ; energy cost of this attack
; 	jr HandlePlayerMetronomeEffect

Metronome_UseAttackEffect:
	ld hl, wLoadedAttackEnergyCost
	ld b, 0
	ld c, (NUM_TYPES / 2) - 1
.loop
; check all basic energy cards except colorless
; each nybble is an energy cost for a type
	ld a, [hl]
	swap a
	and $f
	add b
	ld b, a
	ld a, [hli]
	and $f
	add b
	ld b, a
	dec c
	jr nz, .loop
; last byte, check for darkness energy
	ld a, [hl]
	swap a
	and $f
	add b
	ld b, a
; colorless energy cost
	ld a, [hl]
	and $f
; total energy cost of the attack
	add b
	;	fallthrough

; handles Metronome selection, and validates
; whether it can use the selected attack.
; if unsuccessful, returns carry.
; input:
;	a = amount of colorless energy needed for Metronome
HandlePlayerMetronomeEffect:
	ld [wMetronomeEnergyCost], a

	ld hl, wTxRam2
	ld de, wLoadedAttackName
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	ld [hl], a
	ldtx hl, ChooseOppAttackToBeUsedWithMetronomeText
	call DrawWideTextBox_WaitForInput

	call HandleDefendingPokemonAttackSelection
	ret c ; return if operation cancelled

; store this attack as selected attack to use
	ld hl, wMetronomeSelectedAttack
	ld [hl], d
	inc hl
	ld [hl], e

; compare selected attack's name with
; the attack that is loaded, which is Metronome.
; if equal, then cannot select it.
; (i.e. cannot use Metronome with Metronome.)
	ld hl, wLoadedAttackName
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	call SwapTurn
	call CopyAttackDataAndDamage_FromDeckIndex
	call SwapTurn
	pop de
	ld hl, wLoadedAttackName
	ld a, e
	cp [hl]
	jr nz, .try_use
	inc hl
	ld a, d
	cp [hl]
	jr nz, .try_use
	; cannot select Metronome
	ldtx hl, UnableToSelectText
.failed
	call DrawWideTextBox_WaitForInput
.set_carry
	scf
	ret

.try_use
; run the attack checks to determine
; whether it can be used.
	ld a, EFFECTCMDTYPE_INITIAL_EFFECT_1
	call TryExecuteEffectCommandFunction
	jr c, .failed
	ld a, EFFECTCMDTYPE_INITIAL_EFFECT_2
	call TryExecuteEffectCommandFunction
	jr c, .set_carry
	; successful

; send data to link opponent
	call SendAttackDataToLinkOpponent
	ld a, OPPACTION_USE_METRONOME_ATTACK
	call SetOppAction_SerialSendDuelData
	ld hl, wMetronomeSelectedAttack
	ld d, [hl]
	inc hl
	ld e, [hl]
	ld a, [wMetronomeEnergyCost]
	ld c, a
	call SerialSend8Bytes

	ldh a, [hTempCardIndex_ff9f]
	ld [wPlayerAttackingCardIndex], a
	ld a, [wSelectedAttack]
	ld [wPlayerAttackingAttackIndex], a
	ld a, [wTempCardID_ccc2]
	ld [wPlayerAttackingCardID], a
	or a
	ret


ConversionBeam_ChangeWeaknessEffect:
	call HandleNoDamageOrEffect
	ret c ; is unaffected

; Choose this Pokemon's color unless it is colorless.
	call GetArenaCardColor
	cp COLORLESS
	ret z

; apply changed weakness
	ld c, a
	ld a, DUELVARS_ARENA_CARD_CHANGED_WEAKNESS
	call GetNonTurnDuelistVariable
	ld a, c
	call TranslateColorToWR
	ld [hl], a
	call SwapTurn
	ldtx hl, ChangedTheWeaknessOfPokemonToColorText
	call PrintArenaCardNameAndColorText
	jp SwapTurn

; prints text that requires card name and color,
; with the card name of the Turn Duelist's Arena Pokemon
; and color in [hTemp_ffa0].
; input:
;	hl = text to print
PrintArenaCardNameAndColorText:
	push hl
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex
	ldh a, [hTemp_ffa0]
	call LoadCardNameAndInputColor
	pop hl
	jp DrawWideTextBox_PrintText


; return carry if no Pokemon in Bench
TrainerCardAsPokemon_BenchCheck: ; 2ef18 (b:6f18)
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTemp_ffa0], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ldtx hl, EffectNoPokemonOnTheBenchText
	cp 2
	ret

TrainerCardAsPokemon_PlayerSelectSwitch:
	ldh a, [hTemp_ffa0]
	or a
	ret nz ; no need to switch if it's not Arena card

	ldtx hl, SelectPokemonToPlaceInTheArenaText
	call DrawWideTextBox_WaitForInput
	bank1call HasAlivePokemonInBench
	bank1call OpenPlayAreaScreenForSelection
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	ret

TrainerCardAsPokemon_DiscardEffect:
	ldh a, [hTemp_ffa0]
	ld e, a
	call MovePlayAreaCardToDiscardPile
	ldh a, [hTemp_ffa0]
	or a
	jr nz, .shift_cards
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	call SwapArenaWithBenchPokemon
.shift_cards
	jp ShiftAllPokemonToFirstPlayAreaSlots


; return carry if no energy cards in hand,
AttachEnergyFromHand_HandCheck:
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	ldtx hl, NoCardsInHandText
	cp 1
	ret c ; return if no cards in hand
	ld c, $01
	call Helper_CreateEnergyCardListFromHand
	ldtx hl, NoEnergyCardsText
	ret
	; ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	; call GetTurnDuelistVariable
	; ldtx hl, EffectNoPokemonOnTheBenchText
	; cp 2
	; ret

Helper_SelectEnergyFromHand:
; print text box
	ldtx hl, ChooseCardFromYourHandToAttachText
	call DrawWideTextBox_WaitForInput

; create list with all Energy cards in hand
	ld c, $01
	call Helper_CreateEnergyCardListFromHand
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck

; handle Player selection (from hand)
	ldtx hl, ChooseBasicEnergyCardText
	ldtx de, DuelistHandText
	bank1call SetCardListHeaderText
.loop_hand_input
	bank1call DisplayCardList
; if B pressed, return carry and $ff in a
; otherwise, return deck index in a
	ret nc
	ld a, $ff
	ret


AttachEnergyFromHand_PlayerSelectEffect:
	call Helper_SelectEnergyFromHand
	ldh [hEnergyTransEnergyCard], a
	cp $ff
	ret z
.select_play_area
	call Helper_ChooseAPokemonInPlayArea_EmptyScreen
	ldh [hTempPlayAreaLocation_ffa1], a
	ret

AttachEnergyFromHand_OnlyActive_PlayerSelectEffect:
; always choose Active Pokémon
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	call Helper_SelectEnergyFromHand
	ldh [hEnergyTransEnergyCard], a
	or a  ; ignore carry
	ret

EnergyLift_PlayerSelectEffect:
; choose an energy card from the hand
	call Helper_SelectEnergyFromHand
	ret c  ; cancelled
	ldh [hEnergyTransEnergyCard], a
; choose a Pokémon in the Bench
	call EmptyScreen
	ldtx hl, ChoosePokemonToAttachEnergyCardText
	call DrawWideTextBox_WaitForInput
.loop
	call HandlePlayerSelectionPokemonInBench_AllowCancel
	ret c  ; cancelled
	ldh [hTempPlayAreaLocation_ffa1], a
; repeat if the Pokémon already has Energy attached
	ld e, a
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
	or a
	ret z
	ldtx hl, ThatPokemonAlreadyHasAttachedEnergiesText
	call DrawWideTextBox_WaitForInput
	jr .loop


ClairvoyantSense_PlayerSelectEffect:
	ldtx hl, ChoosePokemonToAttachEnergyCardText
	call DrawWideTextBox_WaitForInput

	call HandlePlayerSelectionPokemonInBench_AllowCancel
	ret c  ; cancelled
	ldh [hTempPlayAreaLocation_ffa1], a

; choose the first card, there's only 1 type
	call CreateHandCardList_OnlyPsychicEnergy
	ld a, [wDuelTempList]
	ldh [hEnergyTransEnergyCard], a
	ret


AttachEnergyFromHand_AISelectEffect:
; AI doesn't select any card
	ld a, $ff
	ldh [hEnergyTransEnergyCard], a
	ret

AttachEnergyFromHand_OnlyActive_AISelectEffect:
	ld c, TRUE
	call Helper_CreateEnergyCardListFromHand
; pick the first card from the list
	ld a, [wDuelTempList]
	ldh [hEnergyTransEnergyCard], a
; always choose Active Pokémon
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


EnergyLift_AttachEnergyEffect:
	call SetUsedPokemonPowerThisTurn_RestoreTrigger
	; jr AttachEnergyFromHand_AttachEnergyEffect
	; fallthrough


; input:
;   [hTempPlayAreaLocation_ffa1]: PLAY_AREA_* of the receiver
;   [hEnergyTransEnergyCard]: deck index of the energy card
AttachEnergyFromHand_AttachEnergyEffect:
	ldh a, [hEnergyTransEnergyCard]
	cp $ff
	ret z

; attach card to the selected Pokemon
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	ldh a, [hEnergyTransEnergyCard]
	call PutHandCardInPlayArea
	call IsPlayerTurn
	ret c

; not Player, so show detail screen
; and which Pokemon was chosen to attach Energy.
	jp Helper_ShowAttachedEnergyToPokemon


ClairvoyantSense_AttachEnergyEffect:
	call EnergyLift_AttachEnergyEffect
	jp Draw2CardsEffect


Transform_PlayerSelectEffect:
	call HandlePlayerSelectionFromDiscardPile_BasicPokemon
	ldh [hAIPkmnPowerEffectParam], a
	ret

TransformEffect:
	ldh a, [hAIPkmnPowerEffectParam]
	cp $ff
	ret z
	ldh [hTempCardIndex_ff98], a
	ld c, a  ; deck index of the selected card in the discard pile

; get the current Pokémon using this ability
	ldh a, [hTemp_ffa0]
	ld e, a  ; play area location of the Pokémon using the ability
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ld b, a  ; deck index of the Pokémon using the ability

; store the current damage on this card
	; e: PLAY_AREA_* of the ability user
	push bc
	call GetCardDamageAndMaxHP  ; preserves hl, de, b
	pop bc
	ld d, a  ; damage taken

; set this play area card to the index of the selected card
	ld a, c
	ld [hl], a
; change the card location of the ability user to the discard pile
	ld l, b
	ld a, CARD_LOCATION_DISCARD_PILE
	ld [hl], a
; change the card location of the selected card to the play area slot
	ld l, c
	ld a, CARD_LOCATION_ARENA
	add e
	ld [hl], a

; move this card to the discard pile and vice versa
	ld l, DUELVARS_DECK_CARDS
.discard_pile_loop
	ld a, [hli]
	cp c
	jr nz, .discard_pile_loop
	dec hl
	ld a, b  ; the ability user card
	ld [hl], a

; overwrite card stage (redundant)
	ld a, DUELVARS_ARENA_CARD_STAGE
	add e
	ld l, a
	xor a  ; BASIC
	ld [hl], a

; point hl to the user's current HP
	ld a, DUELVARS_ARENA_CARD_HP
	add e
	ld l, a
; overwrite HP (retain damage counters)
	ld a, c
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wLoadedCard1HP]
	sub d  ; current HP = max HP - damage taken
	jr nc, .got_hp
	xor a
.got_hp
	ld [hl], a
	cp 1
	push af  ; carry set if KO

; clear changed color and status
	; ld l, DUELVARS_ARENA_CARD_CHANGED_TYPE
	; ld [hl], $00
	; call ClearAllArenaStatusAndEffects

	; call IsPlayerTurn
	; ret c
	ldh a, [hTempCardIndex_ff98]
	ldtx hl, PutInPlayWithTransformText
	bank1call DisplayCardDetailScreen
	pop af
	ret nc
	ldtx hl, WasKnockedOutText
	call DrawWideTextBox_WaitForInput
	bank1call ClearKnockedOutPokemon_TakePrizes_CheckGameOutcome
	ret


; returns carry if either there are no damage counters
; or no Energy cards attached in the Play Area.
SuperPotion_DamageEnergyCheck: ; 2f159 (b:7159)
	call CheckIfPlayAreaHasAnyDamage
	ret c ; no damage counters
	call CheckIfThereAreAnyEnergyCardsAttached
	ldtx hl, ThereIsNoEnergyCardAttachedText
	ret

SuperPotion_PlayerSelectEffect: ; 2f167 (b:7167)
	ldtx hl, ChoosePokemonToRemoveDamageCounterFromText
	call DrawWideTextBox_WaitForInput
.start
	bank1call HasAlivePokemonInPlayArea
.read_input
	bank1call OpenPlayAreaScreenForSelection
	ret c ; exit if B is pressed
	ld e, a
	call GetCardDamageAndMaxHP
	or a
	jr z, .read_input ; Pokemon has no damage?
	ldh a, [hCurMenuItem]
	ld e, a
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
	or a
	jr nz, .got_pkmn
	; no energy cards attached
	ldtx hl, NoEnergyCardsText
	call DrawWideTextBox_WaitForInput
	jr .start

.got_pkmn
; Pokemon has damage and Energy cards attached,
; prompt the Player for Energy selection to discard.
	ldh a, [hCurMenuItem]
	call CreateArenaOrBenchEnergyCardList
	ldh a, [hCurMenuItem]
	bank1call DisplayEnergyDiscardScreen
	bank1call HandleEnergyDiscardMenuInput
	ret c ; exit if B was pressed

	ldh a, [hTempCardIndex_ff98]
	ldh [hTemp_ffa0], a
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	ret

SuperPotion_HealEffect:
	ldh a, [hTemp_ffa0]
	call PutCardInDiscardPile
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a   ; location
	ld d, 60  ; damage
	jp HealPlayAreaCardHP


; checks if there is at least one Energy card
; attached to some card in the Turn Duelist's Play Area.
; return no carry if one is found,
; and returns carry set if none is found.
CheckIfThereAreAnyEnergyCardsAttached: ; 2f1c4 (b:71c4)
	ld a, DUELVARS_CARD_LOCATIONS
	call GetTurnDuelistVariable
.loop_deck
	ld a, [hl]
	bit CARD_LOCATION_PLAY_AREA_F, a
	jr z, .next_card ; skip if not in Play Area
	ld a, l
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
; OATS begin support trainer subtypes
	cp TYPE_TRAINER
	; original: jr z
	jr nc, .next_card  ; skip if it's a Trainer card
; OATS end support trainer subtypes
	cp TYPE_ENERGY
	jr nc, .found
.next_card
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .loop_deck
	scf
	ret
.found
	or a
	ret


ImakuniEffect: ; 2f216 (b:7216)
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wLoadedCard1ID]

; cannot confuse Mysterious Fossil
	cp MYSTERIOUS_FOSSIL
	jr z, .failed

; cannot confuse Snorlax if its Pkmn Power is active
	cp SNORLAX
	jr nz, .success
	call CheckCannotUseDueToStatus
	jr c, .success
	; fallthrough if Thick Skinned is active

.failed
; play confusion animation and print failure text
	ld a, ATK_ANIM_IMAKUNI_CONFUSION
	bank1call PlayAdhocAnimationOnPlayAreaArena_NoEffectiveness
	ldtx hl, ThereWasNoEffectText
	jp DrawWideTextBox_WaitForInput

.success
; play confusion animation and confuse card
	ld a, ATK_ANIM_IMAKUNI_CONFUSION
	bank1call PlayAdhocAnimationOnPlayAreaArena_NoEffectiveness
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	and PSN_DBLPSN_BRN
	or CONFUSED
	ld [hl], a
	bank1call DrawDuelHUDs
	ret

; returns carry if opponent has no energy cards attached
RocketGrunts_EnergyCheck:
	call SwapTurn
	call CheckIfThereAreAnyEnergyCardsAttached
	ldtx hl, NoEnergyAttachedToOpponentsActiveText
	jp SwapTurn

RocketGrunts_PlayerSelection:
	ldtx hl, ChoosePokemonToRemoveEnergyFromText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	call HandlePokemonAndEnergySelectionScreen
	call SwapTurn
	ret  ; carry if cancelled

RocketGrunts_AISelection:
	jp AIPickEnergyCardToDiscardFromDefendingPokemon

RocketGrunts_DiscardEffect:
	call SwapTurn
	ldh a, [hTempPlayAreaLocation_ffa1]
	call PutCardInDiscardPile
	call SwapTurn
	call IsPlayerTurn
	ret c

; show Player which Pokemon was affected
	call SwapTurn
	ldh a, [hTemp_ffa0]
	ldh [hTempPlayAreaLocation_ff9d], a
	bank1call Func_2c10b
	jp SwapTurn

; ------------------------------------------------------------------------------
; UI, Menus and Prompts
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/ui_card_selection.asm"


; search Pokémon cards in Deck
; return carry if there are none and the player refused to look into the deck
_LookForPokemonInDeck:
	call CreateDeckCardList
	ldtx hl, ChooseAnyPokemonFromDeckText
	ldtx bc, AnyPokemonDeckText
	ld a, CARDTEST_POKEMON
	jp LookForCardsInDeckList


; store deck index of selected card or $ff in [hTemp_ffa0]
ChoosePokemonFromDeck_PlayerSelectEffect:
	call _LookForPokemonInDeck
	; jr c, .none_in_deck
	ld a, $ff
	call nc, HandlePlayerSelectionPokemonFromDeckList
	ldh [hTemp_ffa0], a
	or a  ; the effect has been handled, regardless of cancel
	ret



; store deck index of selected card or $ff in [hAIPkmnPowerEffectParam]
StressPheromones_PlayerSelectEffect:
	call _LookForPokemonInDeck
	; jr c, .none_in_deck
	ld a, $ff
	call nc, HandlePlayerSelectionPokemonFromDeckList
	ldh [hAIPkmnPowerEffectParam], a
	or a  ; the Power has been used, regardless of cancel
	ret


PrimalGuidance_PlayerSelectEffect:
	call CreateDeckCardList
	ldtx hl, ChooseAncientEvolutionPokemonCardFromDeckText
	ldtx bc, AncientPokemonCardText
	ld a, CARDTEST_RESTORED_POKEMON
	call LookForCardsInDeckList
	ld a, $ff
	jr c, .none_in_deck
	ld a, CARDTEST_RESTORED_POKEMON
	ldtx hl, ChoosePokemonCardText
	call HandlePlayerSelectionFromDeckList
.none_in_deck
	ldh [hAIPkmnPowerEffectParam], a
	or a  ; the Power has been used, regardless of cancel
	ret


MysteriousTail_PlayerSelectEffect:
	ld b, 6
	call CreateDeckCardListTopNCards
	ld a, TYPE_TRAINER
	call HandlePlayerSelectionCardTypeFromDeckListToHand
	ldh [hTempRetreatCostCards], a
	ld a, $ff
	ldh [hTempRetreatCostCards + 1], a
	ret


SearchingMagnet_PlayerSelectEffect:
	call HandlePlayerSelectionItemTrainerFromDeck
	ldh [hTemp_ffa0], a
	ret

; selects the first available card
SearchingMagnet_AISelectEffect:
	call CreateDeckCardList
	ld hl, wDuelTempList
.loop_deck
	ld a, [hli]
	ldh [hTemp_ffa0], a
	cp $ff
	ret z  ; none found
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_TRAINER
	ret z  ; found one
	jr .loop_deck


Lead_PlayerSelectEffect:
	call HandlePlayerSelectionSupporterFromDeck
	ldh [hTemp_ffa0], a
	ret

; selects the first available card
Lead_AISelectEffect:
	call CreateDeckCardList
	ld hl, wDuelTempList
.loop_deck
	ld a, [hli]
	ldh [hTemp_ffa0], a
	cp $ff
	ret z  ; none found
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_TRAINER_SUPPORTER
	ret z  ; found one
	jr .loop_deck


Mischief_PlayerSelectEffect:
	ldtx hl, ChoosePkmnToHealText
	call DrawWideTextBox_WaitForInput
	ld a, CARDTEST_DAMAGED_POKEMON
	call HandlePlayerSelectionMatchingPokemonInPlayArea_AllowCancel
	ret c
	ldh [hPlayAreaEffectTarget], a
	jp DamageTargetPokemon_PlayerSelectEffect


OptionalDiscard_PlayerHandCardSelection:
	call CheckHandIsNotEmpty
	ld a, $ff
	call nc, HandlePlayerSelection1HandCardToDiscard
	ldh [hTemp_ffa0], a
	or a
	ret

ShadowClaw_AISelectEffect:
; the AI never discards hand cards
	ld a, $ff
	ldh [hTemp_ffa0], a
	ret
	; ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	; call GetNonTurnDuelistVariable
	; or a
	; ret z  ; Player has no cards in hand
	; jp DiscardEnergy_AISelectEffect


Trade_PlayerHandCardSelection:
	call HandlePlayerSelection1HandCardToDiscard
	ldh [hAIPkmnPowerEffectParam], a
	ret


Discard_PlayerHandCardSelection:
	call HandlePlayerSelection1HandCardToDiscardExcludeSelf
	ldh [hTempList], a
	ret


Maintenance_PlayerDiscardPileSelection:
	call HandlePlayerSelectionFromDiscardPile_ItemTrainer
	ret c
	ldh [hTempList + 1], a
	ld a, $ff  ; terminating byte
	ldh [hTempList + 2], a
	ret


EnergySwitch_PlayerSelection:
	ldtx hl, ChoosePokemonToRemoveEnergyFromText
	call DrawWideTextBox_WaitForInput
	call HandlePokemonAndBasicEnergySelectionScreen
	ret c  ; gave up on using the card
; choose a Pokemon in Play Area to attach card
	call EmptyScreen
	ldtx hl, ChoosePokemonToAttachEnergyCardText
	call DrawWideTextBox_WaitForInput
.loop_input
	call HandlePlayerSelectionPokemonInPlayArea
; cannot choose the same Pokémon
	ld e, a
	ldh a, [hTemp_ffa0]
	cp e
	jr nz, .got_pkmn
	call PlaySFX_InvalidChoice
	jr .loop_input
.got_pkmn
; target location is already in [hTempPlayAreaLocation_ff9d]
; move energy to [hTempList]
	ldh a, [hTempPlayAreaLocation_ffa1]
	ldh [hTempList], a
	ld a, $ff
	ldh [hTempList + 1], a
	or a
	ret


; output:
;   [hTemp_ffa0]: deck index of energy card to move | $ff
;   [hTempPlayAreaLocation_ffa1]: PLAY_AREA_* of benched Pokémon
EnergySlide_PlayerSelection:
	ld a, $ff
	ldh [hTemp_ffa0], a
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	cp 2
	ccf
	ret nc  ; nothing to do if there are no Benched Pokémon

	ld e, PLAY_AREA_ARENA
	call HandleAttachedBasicEnergySelectionScreen
	ccf
	ret nc  ; gave up on choosing energy or there are no Basic energies

; selected energy index is in a and [hTempCardIndex_ff98]
	ldh [hTemp_ffa0], a
	call EmptyScreen
	ldtx hl, ChoosePokemonToAttachEnergyCardText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionPokemonInBench
	ldh [hTempPlayAreaLocation_ffa1], a
	ret

; chooses a benched Pokémon without any attached energies
EnergySlide_AISelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a
	ldh [hTempPlayAreaLocation_ffa1], a

	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	dec a
	ret z  ; nothing to do
	ld d, a
	ld e, PLAY_AREA_BENCH_1

.loop_play_area
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
	or a
	jr nz, .skip
; found Pokémon without any attached energies
	ld a, e
	ldh [hTempPlayAreaLocation_ffa1], a
; choose an energy to move
	jp DiscardBasicEnergy_AISelectEffect
.skip
	inc e
	dec d
	ret z  ; nothing to do
	jr .loop_play_area


MoveOpponentEnergyToBench_PlayerSelection:
	call SwapTurn
	call EnergySlide_PlayerSelection
	jp SwapTurn

OptionalMoveOpponentEnergyToBench_AISelectEffect:
	ld a, $ff
	ldh [hTemp_ffa0], a
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	or a
	ret z  ; no benched Pokémon
	; fallthrough

; Precondition ensures there are Bench Pokémon and energy on the Active Pokémon.
MoveOpponentEnergyToBench_AISelectEffect:
	call SwapTurn
; store energy to discard in [hTemp_ffa0]
	call DiscardBasicEnergy_AISelectEffect
; pick the first Benched Pokémon
	ld a, PLAY_AREA_BENCH_1
	ldh [hTempPlayAreaLocation_ffa1], a
	jp SwapTurn


; Asks the Player whether they want to deal double damage
; output:
;   [hTemp_ffa0]: 0 if selected No; 1 if selected Yes
OptionalDoubleDamage_PlayerSelectEffect:
	ldtx hl, DoAdditionalDamageText
	call YesOrNoMenuWithText
	ld a, 1
	jr nc, .store
	xor a  ; no, reset carry
.store
	ldh [hTemp_ffa0], a
	ret


; choose a card from the opponent's Discard Pile
; assume:
;   - card list already created in precondition check
Prank_PlayerSelectEffect:
	call SwapTurn
	; call CreateDiscardPileCardList
	ldtx de, OpponentsDiscardPileText
	bank1call HandlePlayerSelectionFromCardList_Forced
	ldh [hTemp_ffa0], a
	jp SwapTurn


JunkMagnet_PlayerSelectEffect:
	ldtx hl, Put2ItemsFromDiscardPileIntoHandDescription
	call CreateItemCardListFromDiscardPile
	jp ChooseUpTo2Cards_PlayerDiscardPileSelection


; ------------------------------------------------------------------------------
; Move Selected Cards
; ------------------------------------------------------------------------------


;
ItemFinder_DiscardAddToHandEffect:
SelectedCards_Discard1AndAdd1ToHandFromDeck:
; discard the first card in hTempList
	call SelectedCards_Discard1FromHand
; add the second card in hTempList to the hand
	ldh a, [hTempList + 1]
	ldh [hTempList], a
	; ld a, $ff
	; ldh [hTempList + 1], a
	jr SelectedCard_AddToHandFromDeckEffect


; Pokémon Powers should not use [hTemp_ffa0]
; adds cards in [hTempRetreatCostCards] from the deck to the hand
; Note: Pokémon Power no longer needs to preserve [hTemp_ffa0] at this point
Synthesis_AddToHandEffect:
	call SetUsedPokemonPowerThisTurn
	ld hl, hTempRetreatCostCards
.loop
	ld a, [hli]
	cp $ff
	jp z, SyncShuffleDeck ; quit, no more cards
	; a: deck index of card to add from deck to hand
	push hl
	call AddDeckCardToHandEffect
	pop hl
	jr .loop


; Pokémon Powers should not use [hTemp_ffa0]
; adds a card in [hEnergyTransEnergyCard] from the deck to the hand
; Note: Pokémon Power no longer needs to preserve [hTemp_ffa0] at this point
DeckSearchAbility_AddToHandEffect:
	call SetUsedPokemonPowerThisTurn
	ldh a, [hAIPkmnPowerEffectParam]
	ldh [hTemp_ffa0], a
	jr SelectedCard_AddToHandFromDeckEffect


PrimalGuidance_PutInPlayAreaEffect:
	call SetUsedPokemonPowerThisTurn_RestoreTrigger
; was any card selected?
	ldh a, [hAIPkmnPowerEffectParam]
	cp $ff
	ret z
; put the selected card in the Play Area
	ldh [hTempList], a
	ld a, $ff
	ldh [hTempList + 1], a
	call CallForFamily_PutInPlayAreaEffect
; make it count as a Basic Pokémon
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	dec a
	add DUELVARS_ARENA_CARD_STAGE
	ld l, a
	xor a  ; BASIC
	ld [hl], a
	ret


; Pokémon Powers should not use [hTemp_ffa0]
; adds a card in [hAIPkmnPowerEffectParam] from the deck to the hand
; Note: Pokémon Power no longer needs to preserve [hTemp_ffa0] at this point
StressPheromones_AddToHandEffect:
	call SetUsedPokemonPowerThisTurn
	ldh a, [hAIPkmnPowerEffectParam]
	ldh [hTemp_ffa0], a
	; jr RocketShell_AddToHandEffect
	; fallthrough


; Adds the selected card to the turn holder's Hand.
; Then, shuffles the deck, but only if a card was selected.
RocketShell_AddToHandEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z
	jr AddDeckCardToHandAndShuffleEffect


; Adds the selected card to the turn holder's Hand.
; Then, shufles the deck.
SelectedCard_AddToHandFromDeckEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	jp z, SyncShuffleDeck ; skip if no card was chosen
	; fallthrough

; add selected card to the hand and show it on screen if
; it wasn't the Player who used the attack.
; input:
;   a: deck index of card to add from deck to hand
AddDeckCardToHandAndShuffleEffect:
	call AddDeckCardToHandEffect
	jp SyncShuffleDeck

; add selected card to the hand and show it on screen if
; it wasn't the Player who used the attack.
; input:
;   a: deck index of card to add from deck to hand
AddDeckCardToHandEffect:
	call SearchCardInDeckAndSetToJustDrawn  ; preserves af, hl, bc, de
	call AddCardToHand  ; preserves af, hl bc, de
	push de
	ld d, a
	call IsPlayerTurn  ; preserves bc, de
	ld a, d
	pop de
	ret c
	ldtx hl, WasPlacedInTheHandText
	bank1call DisplayCardDetailScreen
	ret


; adds all the cards in hTempList to the turn holder's hand
SelectedCardList_AddToHandFromDeckEffect:
	ld hl, hTempList
.loop_cards
	ld a, [hli]
	cp $ff
	jp z, SyncShuffleDeck  ; done
	push hl
	call AddDeckCardToHandEffect
	pop hl
	jr .loop_cards



; Move the selected deck card to the top of the deck.
SelectedCard_DredgeEffect:
SelectedCard_MoveToTopOfDeckEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z ; skip if no card was chosen
	; fallthrough

; move selected card to the top of the deck.
; input:
;   a: deck index of card to move
DredgeEffect:
MoveDeckCardToTopOfDeckEffect:
	call SearchCardInDeckAndSetToJustDrawn  ; preserves af, hl, bc, de
	call AddCardToHand  ; preserves af, hl bc, de
	call RemoveCardFromHand  ; preserves af, hl bc, de
	jp ReturnCardToDeck  ; preserves a, hl, de, bc


SelectedCard_AddToDeckFromDiscardPileEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z ; return if no card was selected
	; fallthrough

MoveDiscardPileCardToTopOfDeckEffect:
	call MoveDiscardPileCardToHand
	jp ReturnCardToDeck


; put card on top of the deck and show it on screen if
; it wasn't the Player who played the Trainer card.
Recycle_AddToDeckEffect:
	ldh a, [hTempList]
	or a
	jp z, SelectedDiscardPileCards_ShuffleIntoDeckEffect
; cycle this card back into deck
	ldh a, [hTempCardIndex_ff9f]
	push af
	call Draw1CardEffect
	pop af
	call RemoveCardFromHand  ; preserves af, hl bc, de
	jp ReturnCardToBottomOfDeck


Prank_AddToDeckEffect:
	call SwapTurn
	call SelectedCard_AddToDeckFromDiscardPileEffect
	call SwapTurn
	ldtx hl, CardWasChosenText
	jp SelectedCard_ShowDetailsIfOpponentsTurn


SelectedEnergy_AddToHandFromDiscardPile:
; add the first card in hTempList to the hand
	ldh a, [hEnergyTransEnergyCard]
	cp $ff
	ret z
	jr AddDiscardPileCardToHandEffect


SelectedCard_AddToHandFromDiscardPile:
; add the first card in hTempList to the hand
	ldh a, [hTempList]
	cp $ff
	ret z
	; fallthrough

; move the card with deck index given in a from the discard pile to the hand
AddDiscardPileCardToHandEffect:
	ld d, a
	call MoveDiscardPileCardToHand  ; preserves de
	call AddCardToHand  ; preserves de
	call IsPlayerTurn  ; preserves de
	ret c
; display card on screen
	ld a, d
	ldtx hl, WasPlacedInTheHandText
	bank1call DisplayCardDetailScreen
	ret


; moves all the cards in hTempList from the discard pile to the turn holder's hand
SelectedCardList_AddToHandFromDiscardPileEffect:
	ld hl, hTempList
	ld de, wDuelTempList
.loop_cards
	ld a, [hli]
	ld [de], a
	inc de
	cp $ff
	jr z, .done
	call MoveDiscardPileCardToHand
	call AddCardToHand
	jr .loop_cards

.done
	call IsPlayerTurn
	ret c
	bank1call DisplayCardListDetails
	ret


Maintenance_DiscardAndAddToHandEffect:
SelectedCards_Discard1AndAdd1ToHandFromDiscardPile:
; discard the first card in hTempList
	call SelectedCards_Discard1FromHand
; add the second card in hTempList to the hand
	ldh a, [hTempList + 1]
	ldh [hTempList], a
	ld a, $ff
	ldh [hTempList + 1], a
	jr SelectedCard_AddToHandFromDiscardPile


; discard the first card in hTempList
SelectedCards_Discard1FromHand:
	ldh a, [hTempList]
	cp $ff
	scf
	ret z
	call RemoveCardFromHand
	call PutCardInDiscardPile
	or a
	ret


MoveOpponentEnergyToBench_TransferEffect:
	call SwapTurn
	call EnergySlide_TransferEffect
; restore target location to [hTempPlayAreaLocation_ffa1]
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	jp SwapTurn


; input:
;   [hTemp_ffa0]: deck index of card to move
;   [hTempPlayAreaLocation_ffa1]: target location to move card to
EnergySlide_TransferEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z  ; nothing to do

	ldh a, [hTempPlayAreaLocation_ffa1]
	ldh [hTempPlayAreaLocation_ff9d], a  ; target location
	; [hTempList]: card to move
	ld a, $ff
	ldh [hTempList + 1], a  ; list terminator
	; jr SelectedCards_MoveWithinPlayArea
	; fallthrough


; input:
;   [hTempPlayAreaLocation_ff9d]: target location to move cards to
;   [hTempList]: list of cards to move
EnergySwitch_TransferEffect:
SelectedCards_MoveWithinPlayArea:
; get target location to assign to cards in list
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld e, a
	ld d, 0
	ld hl, hTempList
; relocate all cards in [hTempList]
.loop
	ld a, [hli]
	cp $ff
	jr z, .done
	call AddCardToHand
	push hl
	call PutHandCardInPlayArea  ; location in e
	pop hl
	inc d
	jr .loop

; if not Player, show which Pokemon was chosen to attach Energy
.done
	call IsPlayerTurn
	ret c
	jp Helper_GenericShowAttachedEnergyToPokemon


; add a card to the bottom of the turn holder's deck
; input:
;   a: the deck index (0-59) of the card
; output:
;   a: the deck index (0-59) of the card
ReturnCardToBottomOfDeck:
	push hl
	push af
	ld a, DUELVARS_NUMBER_OF_CARDS_NOT_IN_DECK
	call GetTurnDuelistVariable
	dec a
	ld [hl], a  ; decrement number of cards not in deck
	ld a, DECK_SIZE
	sub [hl]
	dec a    ; how many cards there were in the deck before
	ld b, a  ; how many cards to shift position
	or a
	jr z, .done_shift
	ld a, [hl]
	add DUELVARS_DECK_CARDS
	ld l, a  ; point to the new top deck position
	ld e, l
	ld d, h
	inc hl   ; point to the actual top deck card
; shift all cards up to make space at the bottom
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
.done_shift
	pop af
	ld l, DUELVARS_DECK_CARDS + DECK_SIZE - 1  ; last card
	ld [hl], a ; set the last deck card
	ld l, a
	ld [hl], CARD_LOCATION_DECK
	ld a, l
	pop hl
	ret


; ------------------------------------------------------------------------------
; AI Logic
; ------------------------------------------------------------------------------

INCLUDE "engine/duel/effect_functions/ai.asm"


; ------------------------------------------------------------------------------

; return carry if no other card in hand to discard
; or if there are no Basic Energy cards in Discard Pile.
EnergyRetrieval_HandEnergyCheck:
	call CheckHandSizeGreaterThan1
	ret c ; return if doesn't have another card to discard
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	ldtx hl, ThereAreNoBasicEnergyCardsInDiscardPileText
	ret


AbilityEnergyRetrieval_PlayerSelectEffect:
	call HandlePlayerSelection1HandCardToDiscard
	ldh [hMultiPurposeByte4], a
	; jr EnergyRetrieval_PlayerDiscardPileSelection
	; fallthrough

EnergyRetrieval_PlayerDiscardPileSelection:
	ldtx hl, Choose2BasicEnergyCardsFromDiscardPileText
	call DrawWideTextBox_WaitForInput
	call CreateEnergyCardListFromDiscardPile_OnlyBasic
	ld a, 2 + 1  ; count the hand card as offset for [hTempList]
	ld [wCardListNumberOfCardsToChoose], a
	ld a, 1
	ldh [hCurSelectionItem], a  ; selection offset, starts at [hTempList + 1]
	jp ChooseUpToNCards_PlayerDiscardPileSelectionLoop


AbilityEnergyRetrieval_DiscardAndAddToHandEffect:
	call SetUsedPokemonPowerThisTurn_RestoreTrigger
	ldh a, [hMultiPurposeByte4]
	ldh [hTempList], a
	; jr EnergyRetrieval_DiscardAndAddToHandEffect
	; fallthrough

EnergyRetrieval_DiscardAndAddToHandEffect:
	ld hl, hTempList
	ld a, [hli]
	call RemoveCardFromHand
	call PutCardInDiscardPile
	ld de, wDuelTempList
.loop
	ld a, [hli]
	ld [de], a
	inc de
	cp $ff
	jr z, .done
	call MoveDiscardPileCardToHand
	call AddCardToHand
	jr .loop
.done
	call IsPlayerTurn
	ret c
	bank1call DisplayCardListDetails
	ret


Synthesis_PlayerSelectEffect:
	ld a, $ff
	ldh [hTempRetreatCostCards], a
	ldh [hTempRetreatCostCards + 1], a
	ldh [hTempRetreatCostCards + 2], a
; Pokémon Powers must preserve [hTemp_ffa0]
	call HandlePlayerSelectionBasicEnergyFromDeck
	ldh [hTempRetreatCostCards], a
	jr c, .done  ; no Energies or Player cancelled selection
	call RemoveCardFromDuelTempList
	jr c, .done  ; should not happen
; skip deck list creation
	call HandlePlayerSelectionBasicEnergyFromDeckList
	ldh [hTempRetreatCostCards + 1], a
.done
	or a  ; clear carry
	ret


EnergySearch_PlayerSelectEffect:
	call HandlePlayerSelectionBasicEnergyFromDeck
	ldh [hTemp_ffa0], a
	ret


; check if card index in a is a Basic Energy card.
; returns carry in case it's not.
CheckIfCardIsBasicEnergy: ; 2f38f (b:738f)
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY
	jr c, .not_basic_energy
	cp TYPE_ENERGY_DOUBLE_COLORLESS
	jr nc, .not_basic_energy
; is basic energy
	or a
	ret
.not_basic_energy
	scf
	ret


ProfessorOakEffect:
	call DiscardAllCardsFromHand
.draw_cards
	ld a, 7
	bank1call DisplayDrawNCardsScreen
	ld c, 7
.draw_loop
	call DrawCardFromDeck
	jr c, .done
	call AddCardToHand
	dec c
	jr nz, .draw_loop
.done
	ret


; shuffle hand back into deck and draw N cards
LassEffect:
	call ShuffleHandIntoDeckExcludeSelf
	ld a, 5
	jp DrawNCards_NoCardDetails


Potion_PlayerSelection:
	bank1call HasAlivePokemonInPlayArea
.read_input
	bank1call OpenPlayAreaScreenForSelection
	ret c ; exit is B was pressed
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTemp_ffa0], a
	ld e, a
	call GetCardDamageAndMaxHP
	or a
	jr z, .read_input ; no damage, loop back to start
	ret

Potion_HealEffect:
	ldh a, [hTemp_ffa0]
	ld e, a
	ld d, 30
	jp HealPlayAreaCardHP


GamblerEffect: ; 2f3f9 (b:73f9)
	ldtx de, CardCheckIfHeads8CardsIfTails1CardText
	; call TossCoin_BankB
	ld a, 1
	ldh [hTemp_ffa0], a
; discard Gambler card from hand
	ldh a, [hTempCardIndex_ff9f]
	call RemoveCardFromHand
	call PutCardInDiscardPile

; shuffle cards into deck
	call CreateHandCardList
	call SortCardsInDuelTempListByID
	ld hl, wDuelTempList
.loop_return_deck
	ld a, [hli]
	cp $ff
	jr z, .check_coin_toss
	call RemoveCardFromHand
	call ReturnCardToDeck
	jr .loop_return_deck

.check_coin_toss
	call SyncShuffleDeck
	ld c, 8
	ldh a, [hTemp_ffa0]
	or a
	jr nz, .draw_cards ; coin toss was heads?
	; if tails, number of cards to draw is 1
	ld c, 1

; correct number of cards to draw is in c
.draw_cards
	ld a, c
	jp DrawNCards_NoCardDetails


ItemFinder_PlayerSelection:
	; call HandlePlayerSelection2HandCardsToDiscardExcludeSelf
	call HandlePlayerSelection1HandCardToDiscardExcludeSelf
	ret c  ; cancelled selection
; cards were selected to discard from hand
	ldh [hTempList], a
; now to choose an Item card from Deck
	call HandlePlayerSelectionItemTrainerFromDeck
	ldh [hTempList + 1], a  ; placed after the selected cards to discard
	ret


AttachPokemonTool_PlayerSelectEffect:
	call LoadCard1NameToRamText
	ldtx hl, ChoosePokemonToAttachToolToText
	call DrawWideTextBox_WaitForInput
.loop
	call HandlePlayerSelectionPokemonInPlayArea_AllowCancel
	ret c  ; cancelled
	ldh [hTempPlayAreaLocation_ffa1], a
	call CheckPokemonHasNoToolsAttached
	ret nc
	call DrawWideTextBox_WaitForInput
	jr .loop


PokemonTool_AttachToolEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	add DUELVARS_ARENA_CARD_ATTACHED_TOOL
	call GetTurnDuelistVariable
	ldh a, [hTempCardIndex_ff9f]
; store the attached tool and put it in play
	ld [hl], a
	call PutHandCardInPlayArea
	call IsPlayerTurn
	ret c
	ldh a, [hTempPlayAreaLocation_ffa1]
	ldh [hTempPlayAreaLocation_ff9d], a
	bank1call Func_2c10b
	ret


; return carry if Bench is full.
MysteriousFossil_BenchCheck:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	cp MAX_PLAY_AREA_POKEMON
	ccf
	ldtx hl, NoSpaceOnTheBenchText
	ret

MysteriousFossil_PlaceInPlayAreaEffect:
	ldh a, [hTempCardIndex_ff9f]
	jp PutHandPokemonCardInPlayArea



ImposterProfessorOakEffect:
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	dec a  ; exclude this card
	or a
	jr nz, .has_cards  ; at least 1 player has cards in hand
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetNonTurnDuelistVariable
	or a
	ret z  ; neither player has any cards in hand

.has_cards
	call ShuffleHandAndReturnToBottomOfDeckExcludeSelf
	call CheckOpponentHasMorePrizeCardsRemaining
	ld a, 3  ; player draws 3 cards
	jr nc, .draw_cards
	ld a, 5  ; player is losing, draws 5 cards
.draw_cards
	call DrawNCards_NoCardDetails
	call SwapTurn
	call ShuffleHandAndReturnToBottomOfDeck
	ld a, 4  ; opponent draws 4 cards
	call DrawNCards_NoCardDetails
	jp SwapTurn


JudgeEffect:
	call ShuffleHandIntoDeckExcludeSelf
	ld a, 4  ; player draws 4 cards
	call DrawNCards_NoCardDetails
	; fallthrough

DevastatingWindEffect:
	call SwapTurn
	call ShuffleHandIntoDeck
	ld a, 4  ; opponent draws 4 cards
	call DrawNCards_NoCardDetails
	jp SwapTurn


; Returns all hand cards (excluding the Trainer card currently in use) to
; the turn holder's deck and then shuffles the deck.
ShuffleHandIntoDeckExcludeSelf:
	call CreateHandCardListExcludeSelf
	jr ShuffleHandIntoDeck.got_card_list

; Returns all hand cards to the turn holder's deck and then shuffles the deck.
ShuffleHandIntoDeck:
	call CreateHandCardList
.got_card_list
	; call SortCardsInDuelTempListByID
	ld hl, wDuelTempList
.loop_return_deck
	ld a, [hli]
	cp $ff
	jr z, .done_return
	call RemoveCardFromHand
	call ReturnCardToDeck
	jr .loop_return_deck
.done_return
	jp SyncShuffleDeck


; Shuffles all hand cards (excluding the Trainer card in use) and then puts
; those cards at the bottom of the turn holder's deck.
ShuffleHandAndReturnToBottomOfDeckExcludeSelf:
	call CreateHandCardListExcludeSelf
	jr ShuffleHandAndReturnToBottomOfDeck.got_card_list

; Shuffles all hand cards and then puts those cards at the bottom of
; the turn holder's deck.
ShuffleHandAndReturnToBottomOfDeck:
	call CreateHandCardList
.got_card_list
	ld hl, wDuelTempList
	call ShuffleCards
.loop_return_deck
	ld a, [hli]
	cp $ff
	ret z
	call RemoveCardFromHand
	call ReturnCardToBottomOfDeck
	jr .loop_return_deck


ComputerSearch_PlayerSelection:
; create the list of the top 7 cards in deck
	ld b, 7
	call CreateDeckCardListTopNCards
; handle input
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	ldtx hl, ChooseSupporterCardText
	ldtx de, DuelistDeckText
	bank1call SetCardListHeaderText
.read_input
	bank1call DisplayCardList
; if B was pressed, either there are no Supporters or Player does not want any
	jr c, .no_cards
	ldh a, [hTempCardIndex_ff98]
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_TRAINER_SUPPORTER
	jr nz, .play_sfx ; can't select non-Supporter card
	ldh a, [hTempCardIndex_ff98]
	ldh [hTemp_ffa0], a
	or a
	ret

.no_cards
	ld a, $ff
	ldh [hTemp_ffa0], a
	or a
	ret

.play_sfx
	call PlaySFX_InvalidChoice
	jr .read_input


MrFuji_PlayerSelection:
	ldtx hl, ChoosePokemonToReturnToTheDeckText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionPokemonInBench_AllowCancel
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


MrFuji_ReturnToDeckAndDrawEffect:
; determine how many cards to draw based on Stage
	ldh a, [hTempPlayAreaLocation_ffa1]
	add DUELVARS_ARENA_CARD_STAGE
	call GetTurnDuelistVariable
	push af
; return the selected Pokémon to the deck
	ldh a, [hTempPlayAreaLocation_ffa1]
	call ReturnPlayAreaPokemonToDeckEffect
; draw cards based on the Stage of the returned Pokémon
	pop af
	or a  ; BASIC
	jp z, Draw1CardEffect
	cp STAGE2
	jp z, Draw3CardsEffect
	; STAGE1 or STAGE2_WITHOUT_STAGE1
	jp Draw2CardsEffect


; Return the Arena Pokémon and all cards
; attached to it to the turn holder's deck.
ReturnArenaPokemonToDeckEffect:
	xor a  ; PLAY_AREA_ARENA
	; jr ReturnPlayAreaPokemonToDeckEffect
	; fallthrough


; Return the Pokémon in the location given in a
; and all cards attached to it to the turn holder's deck.
ReturnPlayAreaPokemonToDeckEffect:
	ld e, a
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ldh [hTempCardIndex_ff98], a
	ld a, e
	or a
	jr nz, _ReturnBenchedPokemonToDeckEffect

; if Pokemon was in Arena, then switch it with the selected Bench card first
; this avoids a bug that occurs when arena is empty before
; calling ShiftAllPokemonToFirstPlayAreaSlots
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
; this eventually calls ClearAllArenaEffectsAndSubstatus
	call SwapArenaWithBenchPokemon

; after switching, return the benched Pokémon as normal
	; fallthrough

_ReturnBenchedPokemonToDeckEffect:
; find all cards that are in the same location
; (previous evolutions and energy cards attached)
; and return them all to the deck.
	ldh a, [hTempPlayAreaLocation_ffa1]
	or CARD_LOCATION_PLAY_AREA
	ld e, a
	ld a, DUELVARS_CARD_LOCATIONS
	call GetTurnDuelistVariable
.loop_cards
	push de
	push hl
	ld a, [hl]
	cp e
	jr nz, .next_card
	ld a, l
	call ReturnCardToDeck
.next_card
	pop hl
	pop de
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .loop_cards

; clear Play Area location of card
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	call EmptyPlayAreaSlot
	ld l, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	dec [hl]
	call ShiftAllPokemonToFirstPlayAreaSlots

; if not the Player's turn, print text and show card on screen
	call IsPlayerTurn
	jr c, .done
	ldh a, [hTempCardIndex_ff98]
	call LoadCardDataToBuffer1_FromDeckIndex
	call LoadCard1NameToRamText
	bank1call DrawLargePictureOfCard
	ldtx hl, PokemonAndAllAttachedCardsWereReturnedToDeckText
	call DrawWideTextBox_WaitForInput
.done
	jp SyncShuffleDeck


PlusPower_PreconditionCheck:
	xor a  ; PLAY_AREA_ARENA
	jp CheckPokemonHasNoToolsAttached

PlusPowerEffect:
; store PlusPower as the attached tool
	ld a, DUELVARS_ARENA_CARD_ATTACHED_TOOL
	call GetTurnDuelistVariable
; attach Trainer card to Arena Pokemon
	ldh a, [hTempCardIndex_ff9f]
	ld [hl], a
	ld e, PLAY_AREA_ARENA
	jp PutHandCardInPlayArea


Switch_PlayerSelection:
	ldtx hl, SelectPkmnOnBenchToSwitchWithActiveText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionPokemonInBench_AllowCancel
	ldh [hTempPlayAreaLocation_ffa1], a
	ret

Switch_SwitchEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	jp SwapArenaWithBenchPokemon


; return carry if non-Turn Duelist has full Bench
; or if they have no Basic Pokemon cards in Discard Pile.
PokemonFlute_BenchCheck:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	ldtx hl, NoSpaceOnTheBenchText
	cp MAX_PLAY_AREA_POKEMON
	ccf
	ret c ; not enough space in Bench
	; check Discard Pile
	call SwapTurn
	call CreateBasicPokemonCardListFromDiscardPile
	ldtx hl, ThereAreNoPokemonInDiscardPileText
	call SwapTurn
	ret

PokemonFlute_PlayerSelection:
; create Discard Pile list
	call SwapTurn
	call CreateBasicPokemonCardListFromDiscardPile

; display selection screen and store Player's selection
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	ldtx hl, ChoosePokemonToPlaceInPlayText
	ldtx de, PlayerDiscardPileText
	bank1call SetCardListHeaderText
	bank1call DisplayCardList
	call SwapTurn
	ldh a, [hTempCardIndex_ff98]
	ldh [hTemp_ffa0], a
	ret

PokemonFlute_PlaceInPlayAreaText:
; place selected card in non-Turn Duelist's Bench
	call SwapTurn
	ldh a, [hTemp_ffa0]
	call MoveDiscardPileCardToHand
	call AddCardToHand
	call PutHandPokemonCardInPlayArea
	call SwapTurn

; unless it was the Player who played the card,
; display the Pokemon card on screen.
	call IsPlayerTurn
	ret c
	call SwapTurn
	ldh a, [hTemp_ffa0]
	ldtx hl, CardWasChosenText
	bank1call DisplayCardDetailScreen
	jp SwapTurn


ScoopUpNet_PlayerSelectEffect:
	ldtx hl, ChoosePokemonToReturnToTheHandText
	call DrawWideTextBox_WaitForInput
; handle Player selection
	ld a, CARDTEST_BASIC_POKEMON
	call HandlePlayerSelectionMatchingPokemonInBench_AllowCancel
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


PokemonNurse_PlayerSelectEffect:
	ldtx hl, ChoosePokemonToReturnToTheHandText
	call DrawWideTextBox_WaitForInput
; handle Player selection
	call HandlePlayerSelectionPokemonInPlayArea_AllowCancel
	ret c  ; exit if B was pressed

	ldh [hTempPlayAreaLocation_ffa1], a
	or a
	ret nz ; if it wasn't the Active Pokemon, we are done

; handle switching to a Pokemon in Bench and store selected location
	call EmptyScreen
	ldtx hl, SelectPokemonToPlaceInTheArenaText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionPokemonInBench_AllowCancel
	ldh [hTemp_ffa0], a
	ret


ScoopUpNet_ReturnToHandEffect:
PokemonNurse_ReturnToHandEffect:
; if card was in Bench, simply return Pokémon to hand
	ldh a, [hTempPlayAreaLocation_ffa1]
	or a
	jr nz, ScoopUpFromBench
	; fallthrough

; if Pokemon was in Arena, then switch it with the selected Bench card first
; this avoids a bug that occurs when arena is empty before
; calling ShiftAllPokemonToFirstPlayAreaSlots
ScoopUpFromArena:
	ldh a, [hTemp_ffa0]
	ld e, a
; this eventually calls ClearAllArenaEffectsAndSubstatus
	call SwapArenaWithBenchPokemon

; after switching, scoop up the benched Pokémon as normal
	ldh a, [hTemp_ffa0]
	call ReturnBenchedPokemonToHand

; if card was not played by Player, show detail screen
	call IsPlayerTurn
	ret c

	ldtx hl, PokemonWasReturnedFromArenaToHandText
	ldh a, [hTempCardIndex_ff98]
	bank1call DisplayCardDetailScreen
	ret


ScoopUpFromBench:
	ldh a, [hTempPlayAreaLocation_ffa1]
	call ReturnBenchedPokemonToHand

; if card was not played by Player, show detail screen
	call IsPlayerTurn
	ret c

	ldtx hl, PokemonWasReturnedFromBenchToHandText
	ldh a, [hTempCardIndex_ff98]
	bank1call DisplayCardDetailScreen
	ret


; input:
;   a: PLAY_AREA_* of the benched Pokémon to scoop up
ReturnBenchedPokemonToHand:
; store chosen card location to Scoop Up
	ld d, a
	or CARD_LOCATION_PLAY_AREA
	ld e, a

; find Pokémon cards that are in the selected Play Area location
; and add them to the hand, discarding all cards attached.
	ld a, DUELVARS_CARD_LOCATIONS
	call GetTurnDuelistVariable
.loop
	ld a, [hl]
	cp e
	jr nz, .next_card ; skip if not in selected location
	ld a, l
	call LoadCardDataToBuffer2_FromDeckIndex  ; preserves de
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY
	jr nc, .next_card ; skip if not Pokemon card
	; ld a, [wLoadedCard2Stage]
	; or a
	; jr nz, .next_card  ; skip if not Basic stage
; found
	ld a, l
	ldh [hTempCardIndex_ff98], a
	call AddCardToHand  ; preserves de
.next_card
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .loop

; The Pokémon has been moved to hand.
; MovePlayAreaCardToDiscardPile will discard other cards that were attached.
	ld e, d
	call MovePlayAreaCardToDiscardPile

; clear status from Pokémon location
; handled by EmptyPlayAreaSlot, called by MovePlayAreaCardToDiscardPile
;	ldh a, [hTempPlayAreaLocation_ffa1]
;	call ClearStatusFromTarget_NoAnim

; finally, shift Pokemon slots (necessary for Trainer cards)
	jp ShiftAllPokemonToFirstPlayAreaSlots


; return carry if no other cards in hand,
; or if there are no Pokemon cards in hand.
PokemonTrader_HandDeckCheck:
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	ldtx hl, ThereAreNoCardsInHandThatYouCanChangeText
	cp 2
	ret c ; return if no other cards in hand
	call CreatePokemonCardListFromHand
	ldtx hl, ThereAreNoCardsInHandThatYouCanChangeText
	ret

PokemonTrader_PlayerHandSelection:
; print text box
	ldtx hl, ChooseCardFromYourHandToSwitchText
	call DrawWideTextBox_WaitForInput

; create list with all Pokemon cards in hand
	call CreatePokemonCardListFromHand
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck

; handle Player selection
	ldtx hl, ChooseCardToSwitchText
	ldtx de, DuelistHandText
	bank1call SetCardListHeaderText
	bank1call DisplayCardList
	ldh [hTemp_ffa0], a
	ret

PokemonTrader_PlayerDeckSelection:
; temporarily place chosen hand card in deck
; so it can be potentially chosen to be traded.
	ldh a, [hTemp_ffa0]
	call RemoveCardFromHand
	call ReturnCardToDeck

; display deck card list screen
	ldtx hl, ChooseAnyPokemonFromDeckText
	call DrawWideTextBox_WaitForInput
	call CreateDeckCardList
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	ldtx hl, ChoosePokemonCardText
	ldtx de, DuelistDeckText
	bank1call SetCardListHeaderText

; handle Player selection
.read_input
	bank1call DisplayCardList
	jr c, .read_input ; pressing B loops back to selection
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY
	jr nc, .read_input ; can't select non-Pokemon cards

; a valid card was selected, store its card index and
; place the selected hand card back to the hand.
	ldh a, [hTempCardIndex_ff98]
	ldh [hTempPlayAreaLocation_ffa1], a
	ldh a, [hTemp_ffa0]
	call SearchCardInDeckAndSetToJustDrawn
	call AddCardToHand
	or a
	ret

PokemonTrader_TradeCardsEffect:
; place hand card in deck
	ldh a, [hTemp_ffa0]
	call RemoveCardFromHand
	call ReturnCardToDeck

; place deck card in hand
	ldh a, [hTempPlayAreaLocation_ffa1]
	call SearchCardInDeckAndSetToJustDrawn
	call AddCardToHand

; display cards if the Pokemon Trader wasn't played by Player
	call IsPlayerTurn
	jr c, .done
	ldh a, [hTemp_ffa0]
	ldtx hl, PokemonWasReturnedToDeckText
	bank1call DisplayCardDetailScreen
	ldh a, [hTempPlayAreaLocation_ffa1]
	ldtx hl, WasPlacedInTheHandText
	bank1call DisplayCardDetailScreen
.done
	jp SyncShuffleDeck


; makes list in wDuelTempList with all Pokemon cards
; that are in Turn Duelist's hand.
; if list turns out empty, return carry.
CreatePokemonCardListFromHand: ; 2f8b6 (b:78b6)
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	ld c, a
	ld l, DUELVARS_HAND
	ld de, wDuelTempList
.loop
	ld a, [hl]
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Type]
	cp TYPE_ENERGY
	jr nc, .next_hand_card
	ld a, [hl]
	ld [de], a
	inc de
.next_hand_card
	inc l
	dec c
	jr nz, .loop
	ld a, $ff ; terminating byte
	ld [de], a
	ld a, [wDuelTempList]
	cp $ff
	jr z, .set_carry
	or a
	ret
.set_carry
	scf
	ret


Pokedex_PlayerSelection:
; cap the number of cards to reorder up to
; number of cards left in the deck (maximum of 5)
; fill wDuelTempList with cards that are going to be sorted
	ld b, 5
	call CreateDeckCardListTopNCards
	inc a
	ld [wNumberOfCardsToOrder], a
; initialize safety variables
	ld a, $ff
	ldh [hTempList + 5], a  ; terminator for the sorting list
	ldh [hTempList + 6], a  ; placeholder for chosen Pokémon

; check if there are any Pokémon
	ld a, CARDTEST_POKEMON
	call SearchDuelTempListForMatchingCard
	jr c, .no_pokemon

; print text box
	ldtx hl, ChooseAnyPokemonFromDeckText
	call DrawWideTextBox_WaitForInput

; let the Player choose a Pokémon to add to the hand
	call HandlePlayerSelectionPokemonFromDeckList
	ldh [hTempList], a
	cp $ff
	jr z, .got_pkmn

; store chosen Pokémon
	ldh [hTempList + 6], a
; remove selected card from the ordering list
	call RemoveCardFromDuelTempList
	ld a, $ff
	ldh [hTempList], a  ; terminator for the sorting list
	ldh [hTempList + 1], a  ; terminator for the sorting list
	ld a, [wNumberOfCardsToOrder]
	dec a
	ld [wNumberOfCardsToOrder], a
; check if there was only the selected Pokémon
	dec a
	or a
	ret z
; check if there are still multiple cards to reorder
	cp 2
	jr nc, .got_pkmn
; there is only one more card, no need to reorder
	ld a, [wDuelTempList]
	ldh [hTempList], a
	; [hTempList + 1] already has terminator
	or a  ; remove carry flag
	ret

.got_pkmn
	call EmptyScreen

.no_pokemon
; print text box
	ldtx hl, RearrangeTheCardsAtTopOfDeckText
	call DrawWideTextBox_WaitForInput


.clear_list
	call InitializeListForReordering

; display card list to order
	bank1call InitAndDrawCardListScreenLayout
	ldtx hl, ChooseTheOrderOfTheCardsText
	ldtx de, DuelistDeckText
	bank1call SetCardListHeaderText
	bank1call Func_5735

.read_input
	bank1call DisplayCardList
	jr c, .undo ; if B is pressed, undo last order selection

; a card was selected, check if it's already been selected
	ldh a, [hCurMenuItem]
	ld e, a
	ld d, $00
	ld hl, wDuelTempList + 10
	add hl, de
	ld a, [hl]
	or a
	jr nz, .read_input ; already has an ordering number

; hasn't been ordered yet, apply to it current ordering number
; and increase it by 1.
	ldh a, [hCurSelectionItem]
	ld [hl], a
	inc a
	ldh [hCurSelectionItem], a

; refresh screen
	push af
	bank1call Func_5744
	pop af

; check if we're done ordering
	ldh a, [hCurSelectionItem]
	ld hl, wNumberOfCardsToOrder
	cp [hl]
	jr c, .read_input ; if still more cards to select, loop back up

; we're done selecting cards
	call EraseCursor
	ldtx hl, IsThisOKText
	call YesOrNoMenuWithText_LeftAligned
	jr c, .clear_list ; "No" was selected, start over
	; selection was confirmed

; now wDuelTempList + 10 will be overwritten with the
; card indices in order of selection.
	ld hl, wDuelTempList + 10
	ld de, wDuelTempList
	ld c, 0
.loop_write_indices
	ld a, [hli]
	cp $ff
	jr z, .done_write_indices
	push hl
	push bc
	ld c, a
	ld b, $00
	ld hl, hTempCardIndex_ff9f
	add hl, bc
	ld a, [de]
	ld [hl], a
	pop bc
	pop hl
	inc de
	inc c
	jr .loop_write_indices

.done_write_indices
	ld b, $00
	ld hl, hTempList
	add hl, bc
	ld [hl], $ff ; terminating byte
	or a
	ret

.undo
; undo last selection and get previous order number
	ld hl, hCurSelectionItem
	ld a, [hl]
	cp 1
	jr z, .read_input ; already at first input, nothing to undo
	dec a
	ld [hl], a
	ld c, a
	ld hl, wDuelTempList + 10
.asm_2f99e
	ld a, [hli]
	cp c
	jr nz, .asm_2f99e
	dec hl
	ld [hl], $00 ; overwrite order number with 0
	bank1call Func_5744
	jr .read_input


Pokedex_AddToHandAndOrderDeckCardsEffect:
	ldh a, [hTempList + 6]
	cp $ff
	jr z, Pokedex_OrderDeckCardsEffect  ; none chosen

; add Pokémon card to hand and show it on screen
	call AddCardToHand
	ldtx hl, WasPlacedInTheHandText
	bank1call DisplayCardDetailScreen
	; fallthrough

Pokedex_OrderDeckCardsEffect:
; place cards in order to the hand.
	ld hl, hTempList
	ld c, 0
.loop_place_hand
	ld a, [hli]
	cp $ff
	jr z, .place_top_deck
	call SearchCardInDeckAndSetToJustDrawn
	inc c
	jr .loop_place_hand

.place_top_deck
; go to last card in list and iterate in decreasing order
; placing each card in top of deck.
	dec hl
	dec hl
.loop_place_deck
	ld a, [hld]
	call ReturnCardToDeck
	dec c
	jr nz, .loop_place_deck
	ret


DrawUntil5CardsInHandEffect:
	ld c, 5
	jr DrawUntilNCardsInHandEffect


;
WaveRider_DrawEffect:
	ldtx hl, DrawCardsUntil3CardsInHandText
	call DrawWideTextBox_WaitForInput
	call SetUsedPokemonPowerThisTurn
	; jp DrawUntil3CardsInHandEffect
	; fallthrough

DrawUntil3CardsInHandEffect:
	ld c, 3
	; jr DrawUntilNCardsInHandEffect
	; fallthrough

; input:
;   c: maximum number of cards to have in hand
DrawUntilNCardsInHandEffect:
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	sub c
	ret nc
; two's complement on a
	cpl
	inc a
; draw (N - a)
	cp 4
	jr nc, DrawNCards_NoCardDetails
; 3 or fewer cards, show details
	dec a
	jr z, Draw1Card
	dec a
	jr z, Draw2Cards
	jr Draw3Cards


;
Draw1CardEffect:
	ldtx hl, Draw1CardFromTheDeckText
	call DrawWideTextBox_WaitForInput
	; fallthrough

Draw1Card:
	bank1call DisplayDrawOneCardScreen
	call DrawCardFromDeck
	ret c ; return if deck is empty
	call AddCardToHand
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wDuelistType]
	cp DUELIST_TYPE_PLAYER
	ret nz
; show card on screen if it was Player
	bank1call OpenCardPage_FromHand
	ret

;
Draw2CardsEffect:
	ldtx hl, Draw2CardsFromTheDeckText
	call DrawWideTextBox_WaitForInput
	; fallthrough

Draw2Cards:
	ld a, 2
	bank1call DisplayDrawNCardsScreen
	ld c, 2
	jr Draw3Cards.loop_draw

;
Draw3CardsEffect:
	ldtx hl, Draw3CardsFromTheDeckText
	call DrawWideTextBox_WaitForInput
	; fallthrough

Draw3Cards:
	ld a, 3
	bank1call DisplayDrawNCardsScreen
	ld c, 3
.loop_draw
	call DrawCardFromDeck
	jr c, .done
	ldh [hTempCardIndex_ff98], a
	call AddCardToHand
	call IsPlayerTurn
	jr nc, .skip_display_screen
	push bc
	bank1call DisplayPlayerDrawCardScreen
	pop bc
.skip_display_screen
	dec c
	jr nz, .loop_draw
.done
	ret


; input:
;   a: how many cards to draw
DrawNCards_NoCardDetails:
	ld c, a  ; store in c to use later
	bank1call DisplayDrawNCardsScreen  ; preserves bc
.loop_draw
	call DrawCardFromDeck
	ret c
	call AddCardToHand
	dec c
	jr nz, .loop_draw
	ret



PokeBall_PlayerSelectEffect:
	call ChooseBasicPokemonFromDeck_PlayerSelectEffect
	; call c, ForcePlayerSelectionFromDeckList
	ldh [hTemp_ffa0], a
	ret


UltraBall_PlayerSelectEffect:
	call HandlePlayerSelectionPokemonFromDeck
	ldh [hTempList + 2], a  ; placed after the selected cards to discard
	ret


UltraBall_DiscardAddToHandEffect:
; discard cards from hand
	ld hl, hTempList
	ld a, [hli]
	call RemoveCardFromHand
	call PutCardInDiscardPile
	ld a, [hli]
	call RemoveCardFromHand
	call PutCardInDiscardPile

; add card from deck to hand
	ld a, [hl]
	call SearchCardInDeckAndSetToJustDrawn
	call AddCardToHand
	jp SyncShuffleDeck


; return carry if no eligible cards in the Discard Pile and deck is empty
; Recycle_PreconditionCheck:
; 	call CheckDeckIsNotEmpty
; 	ret nc
; 	jp CreatePokemonAndBasicEnergyCardListFromDiscardPile


FishingTail_PlayerSelection:
; assume: wDuelTempList is initialized from Recycle_DiscardPileCheck
	; call CreateDiscardPileCardList
	; call RemoveTrainerCardsFromCardList
	bank1call InitAndDrawCardListScreenLayout_MenuTypeSelectCheck
	ldtx hl, PleaseSelectCardText
	ldtx de, PlayerDiscardPileText
	bank1call SetCardListHeaderText
.read_input
	bank1call DisplayCardList
	jr c, .read_input ; can't cancel with B button

; Discard Pile card was chosen
	ldh a, [hTempCardIndex_ff98]
	ldh [hTemp_ffa0], a
	ret

FishingTail_AISelection:
; reuse the same logic as for Recycle
	farcall AIDecide_Recycle
	jr c, .got_card
	ld a, $ff
.got_card
	ldh [hTemp_ffa0], a
	or a
	ret

;
Recycle_PlayerSelectEffect:
	; bank1call DrawDuelMainScene
	ldtx hl, ProcedureForRecycleText
	bank1call DrawWholeScreenTextBox
	ldtx hl, PleaseSelectAnOptionText
	call TwoItemHorizontalMenu
	ldh a, [hKeysHeld]
	and B_BUTTON
	jr nz, .cancel
	ldh a, [hCurMenuItem]
	ldh [hTempList], a ; store selection index (0/1)
	or a
	jr z, .discard_pile
; cycle card into deck
	call CheckDeckIsNotEmpty
	jr c, .cant_use
	ret

.discard_pile
; assume: wDuelTempList initialized from precondition
	call CreatePokemonAndBasicEnergyCardListFromDiscardPile
	jr c, .cant_use
	call ChooseUpTo2Cards_PlayerDiscardPileSelection
	ldh a, [hTempList]
	inc a  ; $ff turns into 0
	cp 1   ; set carry if cancelled selection
	ret

.cant_use
	call DrawWideTextBox_WaitForInput
.cancel
	scf
	ret


SuperRod_PlayerSelectEffect:
	call ChooseUpTo3Cards_PlayerDiscardPileSelection
	ldh a, [hTempList]
	inc a  ; $ff turns into 0
	cp 1   ; set carry if cancelled selection
	ret


; input:
;   hl: pointer to text to display
SelectedCard_ShowDetailsIfOpponentsTurn:
	push hl
	call IsPlayerTurn
	pop hl
	ret c
	ldh a, [hTemp_ffa0]
	bank1call DisplayCardDetailScreen
	ret


; return carry if Bench is full or if no Basic Pokemon cards in Discard Pile
Revive_BenchCheck:
	call CheckBenchIsNotFull
	ret c
	call CreateBasicPokemonCardListFromDiscardPile
	ldtx hl, ThereAreNoPokemonInDiscardPileText
	ret


Revive_PlayerSelection:
; create Basic Pokemon card list from Discard Pile
	ldtx hl, ChooseBasicPokemonToPlaceOnBenchText
	call DrawWideTextBox_WaitForInput
	call HandlePlayerSelectionFromDiscardPile_BasicPokemon
	ldh [hTemp_ffa0], a
	ret

Revive_PlaceInPlayAreaEffect:
; place selected Pokemon in the Bench
	ldh a, [hTemp_ffa0]
	call MoveDiscardPileCardToHand
	call AddCardToHand
	call PutHandPokemonCardInPlayArea
; display card
	ldtx hl, PlacedOnTheBenchText
	jp SelectedCard_ShowDetailsIfOpponentsTurn


; input:
;  [wDuelTempList]: list of cards to choose from
ChooseUpTo2Cards_PlayerDiscardPileSelection:
	ld a, 2
	ld [wCardListNumberOfCardsToChoose], a
	jr ChooseUpToNCards_PlayerDiscardPileSelection


; assume:
;   [wDuelTempList]: populated from AquaticRescue_DiscardPileCheck
AquaticRescue_PlayerSelectEffect:
	call ChooseUpTo3Cards_PlayerDiscardPileSelection
; set carry set if the list is empty
	ldh a, [hTempList]
	sub $ff
	cp 1
	ret


; input:
;  [wDuelTempList]: list of cards to choose from
ChooseUpTo3Cards_PlayerDiscardPileSelection:
	ld a, 3
	ld [wCardListNumberOfCardsToChoose], a
	jr ChooseUpToNCards_PlayerDiscardPileSelection


Rototiller_PlayerSelectEffect:
	call CreateDiscardPileCardList
	jr ChooseUpTo4Cards_PlayerDiscardPileSelection


Riptide_PlayerSelectEffect:
	call CreateEnergyCardListFromDiscardPile_AllEnergy
	; jr ChooseUpTo4Cards_PlayerDiscardPileSelection
	; fallthrough

; input:
;  [wDuelTempList]: list of cards to choose from
ChooseUpTo4Cards_PlayerDiscardPileSelection:
	ld a, 4
	ld [wCardListNumberOfCardsToChoose], a
	; jr ChooseUpToNCards_PlayerDiscardPileSelection
	; fallthrough

; number of cards is given in [wCardListNumberOfCardsToChoose]
; input:
;  a: number of cards to choose
;  [wDuelTempList]: list of cards to choose from
ChooseUpToNCards_PlayerDiscardPileSelection:
	ld l, a
	ld a, $ff
	ldh [hTempList], a
	xor a
	ldh [hCurSelectionItem], a
	ld h, a
	call LoadTxRam3
	ldtx hl, ChooseUpToNFromDiscardPileText
	call DrawWideTextBox_WaitForInput
	; call CreateEnergyCardListFromDiscardPile_OnlyBasic
	; jr ChooseUpToNCards_PlayerDiscardPileSelectionLoop
	; fallthrough

; input:
;  [wDuelTempList]: list of cards to choose from
;  [wCardListNumberOfCardsToChoose]: number of cards to choose
;  [hCurSelectionItem]: current index (normally zero)
ChooseUpToNCards_PlayerDiscardPileSelectionLoop:
	bank1call InitAndDrawCardListScreenLayout
	ldtx hl, PleaseSelectCardText
	ldtx de, PlayerDiscardPileText
	; jr ChooseUpToNCardsFromCardList_PlayerSelectionLoop
	; fallthrough

; input:
;  hl: instruction text to display (e.g. PleaseSelectCardText)
;  de: location text (e.g. PlayerDiscardPileText)
;  [wDuelTempList]: list of cards to choose from
;  [wCardListNumberOfCardsToChoose]: number of cards to choose
;  [hCurSelectionItem]: current index (normally zero)
ChooseUpToNCardsFromCardList_PlayerSelectionLoop:
	bank1call SetCardListHeaderText
; loop
	ld a, [wDuelTempList]
	cp $ff
	jr z, .done  ; no more cards to choose from
	bank1call DisplayCardList
	jr nc, .store_selected_card
	; B pressed
	ld a, [wCardListNumberOfCardsToChoose]
	call AskWhetherToQuitSelectingCards
	jr c, ChooseUpToNCards_PlayerDiscardPileSelectionLoop ; chose to continue
	jr .done

.store_selected_card
	call GetNextPositionInTempList
	ldh a, [hTempCardIndex_ff98]
	ld [hl], a ; store selected card
	call RemoveCardFromDuelTempList
	jr c, .done
	ld a, [wCardListNumberOfCardsToChoose]
	ld b, a
	ldh a, [hCurSelectionItem]
	cp b
	jr c, ChooseUpToNCards_PlayerDiscardPileSelectionLoop

.done
; insert terminating byte
	call GetNextPositionInTempList
	ld [hl], $ff
	or a
	ret


SuperRod_AddToDeckEffect:
SelectedDiscardPileCards_ShuffleIntoDeckEffect:
; return selected cards to the deck
	ld hl, hTempList
	ld de, wDuelTempList
.loop
	ld a, [hli]
	ld [de], a
	inc de
	cp $ff
	jr z, .done
	; this is kinda dumb and can probably be abbreviated
	call MoveDiscardPileCardToHand
	call AddCardToHand
	call RemoveCardFromHand
	call ReturnCardToDeck
	jr .loop

.done
	call SyncShuffleDeck
; if Player played the card, exit
	call IsPlayerTurn
	ret c
; if not, show card list selected by Opponent
	bank1call DisplayCardListDetails
	ret


Giovanni_PlayerSelection:
	ldtx hl, ChooseAPokemonToSwitchWithActivePokemonText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	call HandlePlayerSelectionPokemonInBench_AllowCancel
	ldh [hTemp_ffa0], a
	jp SwapTurn


Giovanni_SwitchEffect:
; play whirlwind animation
	ld a, ATK_ANIM_GUST_OF_WIND
	bank1call PlayAdhocAnimationOnPlayAreaArena_NoEffectiveness

; switch Arena card
	call SwapTurn
	ldh a, [hTemp_ffa0]
	ld e, a
	call SwapArenaWithBenchPokemon
	call SwapTurn
	call ClearDamageReductionSubstatus2
	xor a
	ld [wDuelDisplayedScreen], a
	ret


Helper_ChooseAPokemonInPlayArea_EmptyScreen:
	call EmptyScreen
Helper_ChooseAPokemonInPlayArea:
	ldtx hl, ChoosePokemonToAttachEnergyCardText
	call DrawWideTextBox_WaitForInput
	jp HandlePlayerSelectionPokemonInPlayArea

Helper_ShowAttachedEnergyToPokemon:
; show detail screen and which Pokemon was chosen to attach Energy
	ldh a, [hTempPlayAreaLocation_ffa1]
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer1_FromDeckIndex
	ld hl, wLoadedCard1Name
	ld de, wTxRam2_b
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ldh a, [hEnergyTransEnergyCard]
	ldtx hl, AttachedEnergyToPokemonText
	bank1call DisplayCardDetailScreen
	ret

Helper_GenericShowAttachedEnergyToPokemon:
; show detail screen and which Pokemon was chosen to attach Energy
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD
.got_play_area_location
	call GetTurnDuelistVariable
	ld c, a  ; deck index of Pokémon card
	call LoadCardDataToBuffer1_FromDeckIndex
	ld hl, wLoadedCard1Name
	ld de, wTxRam2
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, c
	ldtx hl, GenericAttachedEnergyToPokemonText
	bank1call DisplayCardDetailScreen
	ret
