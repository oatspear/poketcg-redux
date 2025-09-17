; return carry if the count in sCardCollection plus the count in each deck (sDeck*)
; of the card with id given in a is 0 (if card not owned).
; also return the count (total owned amount) in a.
GetCardCountInCollectionAndDecks:
	push hl
	push de
	push bc
	call EnableSRAM
	ld c, a
	ld b, $0
	ld hl, sDeck1Cards
	ld d, NUM_DECKS
.next_deck
	ld a, [hl]
	or a
	jr z, .deck_done ; jump if deck empty
	push hl
	ld e, DECK_SIZE
.next_card
	ld a, [hli]
	cp c
	jr nz, .no_match
	inc b ; this deck card matches card c
.no_match
	dec e
	jr nz, .next_card
	pop hl
.deck_done
	push de
	ld de, sDeck2Cards - sDeck1Cards
	add hl, de
	pop de
	dec d
	jr nz, .next_deck
; all decks done
	ld h, HIGH(sCardCollection)
	ld l, c
	ld a, [hl]
	bit CARD_NOT_OWNED_F, a
	jr nz, .done
	add b ; if card seen, add b to count
.done
	and CARD_COUNT_MASK
	call DisableSRAM
	pop bc
	pop de
	pop hl
	or a
	ret nz
	scf
	ret


; if de > 0, increases de by 10 for each Pluspower found in location b
ApplyAttachedPluspower:
	ld a, e
	or d
	ret z
	push de
	ld de, PLUSPOWER
	call CountCardIDInLocation
	pop de
	call ATimes10
	ld l, a
	ld h, 0
	jp AddToDamage_DE

; reduces de by 20 for each Defender found in location b
ApplyAttachedDefender:
	ld a, e
	or d
	ret z
	push de
	ld de, DEFENDER
	call CountCardIDInLocation
	pop de
	add a  ; x2
	call ATimes10
	ld l, a
	ld h, 0
	jp SubtractFromDamage_DE



; move the turn holder's card with ID at de to the discard pile
; if it's currently in the play area.
MoveCardToDiscardPileIfInPlayArea:
	ld c, e
	ld b, d
	ld l, DUELVARS_CARD_LOCATIONS
.next_card
	ld a, [hl]
	and CARD_LOCATION_PLAY_AREA
	jr z, .skip ; jump if card not in arena
	ld a, l
	call GetCardIDFromDeckIndex
	ld a, c
	cp e
	jr nz, .skip ; jump if not the card id provided in c
	ld a, b
	cp d ; card IDs are 8-bit so d is always 0
	jr nz, .skip
	ld a, l
	push bc
	call PutCardInDiscardPile
	pop bc
.skip
	inc l
	ld a, l
	cp DECK_SIZE
	jr c, .next_card
	ret


; begin the execution of an attack and handle the attack being
; possibly unsuccessful due to Sand Attack or Smokescreen
OppAction_BeginUseAttack:
	ldh a, [hTempCardIndex_ff9f]
	ld d, a
	ldh a, [hTemp_ffa0]
	ld e, a
	call CopyAttackDataAndDamage_FromDeckIndex
	call Func_16f6
	ld a, $01
	ld [wSkipDuelistIsThinkingDelay], a

; OATS different logic for the first turn of the game:
; either attack or Supporter
	ld a, [wDuelTurns]
	or a
	jr nz, .not_first_turn
	ld a, [wOncePerTurnActions]
	and PLAYED_SUPPORTER_THIS_TURN
	jr nz, .failed

.not_first_turn
	call CheckReducedAccuracySubstatus
	jr c, .has_status
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	and CNF_SLP_PRZ
	cp CONFUSED
	jr z, .has_status
IF SLEEP_WITH_COIN_FLIP
; OATS sleep also requires a coin flip
	cp ASLEEP
	jr z, .has_status
ENDC
	jp ExchangeRNG

; we make it here is attacker is affected by
; Sand Attack, Smokescreen, or confusion
; OATS: or sleep
.has_status
	call DrawDuelMainScene
	call PrintPokemonsAttackText
	call WaitForWideTextBoxInput
	call ExchangeRNG
IF SLEEP_WITH_COIN_FLIP
	call HandleSleepCheck
	jr c, .failed
ENDC
	call HandleReducedAccuracySubstatus
	ret nc ; return if attack is successful (won the coin toss)
.failed
	call ClearNonTurnTemporaryDuelvars
	; end the turn if the attack fails
	ld a, 1
	ld [wOpponentTurnEnded], a
	ret



; Use an attack (from DuelMenu_Attack) or a Pokemon Power (from DuelMenu_PkmnPower)
; Returns carry if the effect failed (e.g. smokescreen or prerequisites not met).
UseAttackOrPokemonPower:
	ld a, [wSelectedAttack]
	ld [wPlayerAttackingAttackIndex], a
	ldh a, [hTempCardIndex_ff9f]
	ld [wPlayerAttackingCardIndex], a
	ld a, [wTempCardID_ccc2]
	ld [wPlayerAttackingCardID], a
	ld a, [wLoadedAttackCategory]
	cp POKEMON_POWER
	jp z, UsePokemonPower

	call Func_16f6
	ld a, EFFECTCMDTYPE_INITIAL_EFFECT_1
	call TryExecuteEffectCommandFunction
	jp c, DrawWideTextBox_WaitForInput_ReturnCarry
	call CheckReducedAccuracySubstatus
	jr c, .sand_attack_smokescreen
	ld a, EFFECTCMDTYPE_INITIAL_EFFECT_2
	call TryExecuteEffectCommandFunction
	ret c
	call SendAttackDataToLinkOpponent
	jr .next
.sand_attack_smokescreen
	call SendAttackDataToLinkOpponent
	call HandleReducedAccuracySubstatus
	jp c, ClearNonTurnTemporaryDuelvars_ResetCarry
	ld a, EFFECTCMDTYPE_INITIAL_EFFECT_2
	call TryExecuteEffectCommandFunction
	ret c
.next
	ld a, OPPACTION_USE_ATTACK
	call SetOppAction_SerialSendDuelData
	ld a, EFFECTCMDTYPE_DISCARD_ENERGY
	call TryExecuteEffectCommandFunction
	call CheckSelfConfusionDamage
	jp c, HandleConfusionDamageToSelf
	call DrawDuelMainScene
	call PrintPokemonsAttackText
	call WaitForWideTextBoxInput
	call ExchangeRNG
	ld a, EFFECTCMDTYPE_REQUIRE_SELECTION
	call TryExecuteEffectCommandFunction
	ld a, OPPACTION_ATTACK_ANIM_AND_DAMAGE
	call SetOppAction_SerialSendDuelData
;	fallthrough





;
VampiricAuraDescription:
	text "If your Active Pokémon has any"
	line "attached <DARKNESS> Energy, its attacks"
	line "that do damage to the Defending"
	line "Pokémon also heal your Active"
	line "Pokémon for up to 20 damage (10 if"
	line "the attack only did 10 damage)."
	done

LeechHalfDamageEffect:
	ld hl, wDealtDamage
	ld a, [hli]  ; wDamageEffectiveness
	or a
	ret z  ; no damage
	call HalfARoundedUp
	ld e, a
	ld d, [hl]
	jr ApplyAndAnimateHPRecovery


;
LeechUpTo20DamageEffect:
	ld hl, wDealtDamage
	ld a, [hli]
	or a
	ret z ; return if no damage dealt
	cp 20
	jr c, Heal10DamageEffect
	jr Heal20DamageEffect


HandleOnAttackEffects:
	call IsVampiricAuraActive
	jr nc, .splashing_attacks
	; farcall Leech10DamageEffect
	; farcall LeechHalfDamageEffect
	farcall LeechUpTo20DamageEffect
.splashing_attacks
	call IsSplashingAttacksActive
	jr nc, HandleBurnDiscardEnergy
	farcall SplashingAttacks_DamageEffect
	; jp HandleBurnDiscardEnergy
	; fallthrough


; returns carry if the turn holder's Active Pokémon benefits
; from Splashing Attacks
; output:
;   carry: set if Splashing Attacks is active
IsSplashingAttacksActive:
	ld b, PLAY_AREA_ARENA
	ld c, WATER
	ld e, POLIWHIRL
	jr IsSpecialEnergyPowerActive



; return, in a, the retreat cost of the card in wLoadedCard1,
; adjusting for any Pokémon Power that is active
GetLoadedCard1RetreatCost:
	call ArePokemonPowersDisabled
	jr c, .powers_disabled
	ld c, 0
	ld a, DUELVARS_BENCH
	call GetTurnDuelistVariable
.check_bench_loop
	ld a, [hli]
	cp $ff
	jr z, .no_more_bench
	call GetCardIDFromDeckIndex  ; preserves bc
	ld a, e
	cp DODRIO
	jr nz, .check_bench_loop  ; not Dodrio
	inc c
	jr .check_bench_loop

; handle Rock and Roll Power
.no_more_bench
	ld a, GRAVELER
	call GetFirstPokemonWithAvailablePower  ; preserves bc
	ld a, 0  ; preserve carry flag
	adc a
	ld b, a  ; stores 1 if Graveler was found
	or c
	jr nz, .modified_cost
.powers_disabled
	ld a, [wLoadedCard1RetreatCost] ; return regular retreat cost
	ret
.modified_cost
	ld a, [wLoadedCard1RetreatCost]
	add b  ; apply Rock and Roll if there is a Pkmn Power-capable Graveler
	sub c  ; apply Retreat Aid for each Pkmn Power-capable Dodrio
	ret nc
	xor a
	ret


;
HandleDamageRelatedPowers:
	call ArePokemonPowersDisabled  ; preserves de
	ret c  ; Powers are disabled
; Badge of Discipline
	ld a, MACHOKE
	call GetFirstPokemonWithAvailablePower  ; preserves de
	; jr nc, .rock_and_roll
	ret nc
	; call GetArenaCardColor  ; preserves de
	; cp FIGHTING
	; ret nz
	ld hl, wDamageFlags
	set UNAFFECTED_BY_WEAKNESS_F, [hl]
	set UNAFFECTED_BY_RESISTANCE_F, [hl]
	ret

; .rock_and_roll
; 	ld a, GRAVELER
; 	call GetFirstPokemonWithAvailablePower  ; preserves de
; 	ret nc
; 	ld hl, 10
; 	jp AddToDamage_DE
