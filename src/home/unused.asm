

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
	ld a, [wAlreadyPlayedEnergyOrSupporter]
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
	call DrawDuelMainScene_PrintPokemonsAttackText
	call WaitForWideTextBoxInput
	call ExchangeRNG
	ld a, EFFECTCMDTYPE_REQUIRE_SELECTION
	call TryExecuteEffectCommandFunction
	ld a, OPPACTION_ATTACK_ANIM_AND_DAMAGE
	call SetOppAction_SerialSendDuelData
;	fallthrough




; return carry if the turn holder's attack was unsuccessful due to reduced accuracy effect
HandleReducedAccuracySubstatus:
	call CheckReducedAccuracySubstatus
	ret nc
	call TossCoin
	ld [wGotHeadsFromAccuracyCheck], a
	ccf
	ret nc
	ldtx hl, AttackUnsuccessfulText
	call DrawWideTextBox_WaitForInput
	scf
	ret



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
