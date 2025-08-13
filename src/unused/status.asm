; ------------------------------------------------------------------------------
; Status Effects
; ------------------------------------------------------------------------------

ParalysisIfSelectedCardEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z  ; nothing to do
	jr ParalysisEffect


ParalysisIfDamagedSinceLastTurnEffect:
	ld a, DUELVARS_ARENA_CARD_FLAGS
	call GetTurnDuelistVariable
	bit DAMAGED_SINCE_LAST_TURN_F, a
	ret z
	jr ParalysisEffect


PoisonEffect:
	ld a, ATK_ANIM_POISON
	ld [wLoadedAttackAnimation], a
	ld c, POISONED
IF REAPPLY_DOT_DOES_DAMAGE
	ld a, DUEL_ANIM_POISON
	ld [wDynamicFunctionArgument], a
	ldtx hl, ReceivedDamageDueToPoisonText
ENDC
	jr InflictDamageOverTimeStatusEffect

IF DOUBLE_POISON_EXISTS
DoublePoisonEffect:
	ld a, ATK_ANIM_POISON
	ld [wLoadedAttackAnimation], a
	ld c, DOUBLE_POISONED
IF REAPPLY_DOT_DOES_DAMAGE
	ld a, DUEL_ANIM_POISON
	ld [wDynamicFunctionArgument], a
	ldtx hl, ReceivedDamageDueToPoisonText
ENDC
	jr InflictDamageOverTimeStatusEffect
ENDC

BurnEffect:
	ld a, ATK_ANIM_BURN
	ld [wLoadedAttackAnimation], a
	ld c, BURNED
IF REAPPLY_DOT_DOES_DAMAGE
	ld a, DUEL_ANIM_SMALL_FLAME
	ld [wDynamicFunctionArgument], a
	ldtx hl, ReceivedDamageDueToBurnText
ENDC
	jr InflictDamageOverTimeStatusEffect


; input:
;   c: Damage Over Time status (POISONED, BURNED)
;   hl: text pointer
;   wDynamicFunctionArgument: DUEL_ANIM_* for instant damage
InflictDamageOverTimeStatusEffect:
IF REAPPLY_DOT_DOES_DAMAGE
	push hl
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetNonTurnDuelistVariable
	pop hl
	and c
	jr z, .apply_status
	call CheckNotImmuneToAttackEffects
	jr c, ApplyStatusEffectToArenaPokemon.cant_induce_status
	ld a, 10
	ld [wDuelAnimDamage], a
	xor a
	ld [wDuelAnimDamage + 1], a
; deal damage and play animation
	ld a, [wDynamicFunctionArgument]
	call SwapTurn
	bank1call HandleStatusEffectDamage
	jp SwapTurn

.apply_status
ENDC
	ld b, $ff
	jr ApplyStatusEffectToDefendingPokemon


ParalysisEffect:
	ld a, ATK_ANIM_PARALYSIS
	ld [wLoadedAttackAnimation], a
	ld c, PARALYZED
	jr InflictCrowdControlStatusEffect

ConfusionEffect:
	ld a, ATK_ANIM_CONFUSION
	ld [wLoadedAttackAnimation], a
	ld c, CONFUSED
	jr InflictCrowdControlStatusEffect

SleepEffect:
	ld a, ATK_ANIM_SLEEP
	ld [wLoadedAttackAnimation], a
	ld c, ASLEEP
	jr InflictCrowdControlStatusEffect


; input:
;   c: Crowd Control status (PARALYZED, CONFUSED, SLEEP)
InflictCrowdControlStatusEffect:
	ld b, PSN_BRN
IF CC_UPGRADES_TO_FLINCH
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetNonTurnDuelistVariable
	and CNF_SLP_PRZ
	cp FLINCHED
	jr z, FlinchEffect
	cp c
	jr z, FlinchEffect
ENDC
	jr ApplyStatusEffectToDefendingPokemon


IF CC_IS_COIN_FLIP
; assumes animation is already loaded in wLoadedAttackAnimation
FlinchEffect:
	lb bc, PSN_BRN, FLINCHED
	jr ApplyStatusEffectToDefendingPokemon
ENDC


CheckNotImmuneToAttackEffects:
	ld a, [wLoadedAttackCategory]
	cp POKEMON_POWER
	ret z
	ld a, [wNoDamageOrEffect]
	cp 1
	ccf  ; carry if non-zero
	ret


; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
; outputs:
;   [wNoEffectFromWhichStatus]: set with the input status condition
;   carry: set if able to apply status
; preserves: bc, de
ApplyStatusEffectToDefendingPokemon:
	call CheckNotImmuneToAttackEffects
	jr c, ApplyStatusEffectToArenaPokemon.cant_induce_status
	call SwapTurn
	call ApplyStatusEffectToArenaPokemon
	jp SwapTurn


; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
; outputs:
;   [wNoEffectFromWhichStatus]: set with the input status condition
;   carry: set if able to apply status
; preserves: bc, de
ApplyStatusEffectToArenaPokemon:
	ld e, PLAY_AREA_ARENA
	call CanBeAffectedByStatus  ; preserves bc, de
	jr c, .can_induce_status
.cant_induce_status
	ld a, c
	ld [wNoEffectFromWhichStatus], a
	call SetNoEffectFromStatus
	or a
	ret
.can_induce_status
	call UpdateArenaStatusCondition  ; preserves: bc, de
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
	call CheckCannotUseDueToStatus_PlayArea  ; preserves bc, de
	ret nc  ; Pokémon Power is active

.safeguard
	ld a, e
	push bc
	push de
	call IsSafeguardActive
	pop de
	pop bc
	ccf
	ret  ; nc if safeguarded


SelfConfusionEffect:
	ld a, ATK_ANIM_SELF_CONFUSION
	ld [wLoadedAttackAnimation], a
	ld c, CONFUSED
	jr SelfInflictCrowdControlStatusEffect


; input:
;   c: Crowd Control status (PARALYZED, CONFUSED, SLEEP)
SelfInflictCrowdControlStatusEffect:
	ld b, PSN_BRN
IF CC_UPGRADES_TO_FLINCH
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	and CNF_SLP_PRZ
	cp FLINCHED
	jr z, SelfFlinchEffect
	cp c
	jr z, SelfFlinchEffect
ENDC
	jr ApplyStatusEffectToArenaPokemon


IF CC_IS_COIN_FLIP
; assumes animation is already loaded in wLoadedAttackAnimation
SelfFlinchEffect:
	lb bc, PSN_BRN, FLINCHED
	jr ApplyStatusEffectToArenaPokemon
ENDC


; ------------------------------------------------------------------------------
; Status Attacks
; ------------------------------------------------------------------------------


PoisonConfusionEffect:
	call PoisonEffect
	call ConfusionEffect
	ret c
	ld a, CONFUSED | POISONED
	ld [wNoEffectFromWhichStatus], a
	ret


PoisonSleep_StatusEffect:
	call PoisonEffect
	jp SleepEffect


PollenBurstEffect:
PollenBurst_StatusEffect:
	call PoisonEffect
	call BurnEffect
	jp ParalysisIfDamagedSinceLastTurnEffect


FragranceTrap_StatusEffect:
	call PoisonEffect
	call CheckArenaPokemonHas3OrMoreEnergiesAttached
	jp c, ApplyStatusAndPlayAnimationAdhoc
	call BurnEffect
	call ConfusionEffect
	jp ApplyStatusAndPlayAnimationAdhoc


SilverWhirlwind_StatusEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	cp $ff
	jr z, .arena
	call PoisonEffect_PlayArea  ; preserves de
	call ConfusionEffect_PlayArea
.arena
	call PoisonEffect
	call BurnEffect
	call SleepEffect
	jp ApplyStatusAndPlayAnimationAdhoc


; Poison and Burn.
AcidicDrain_PoisonBurnEffect:
	call PoisonEffect
	jp BurnEffect


SelfConfusionEffect:
	call SwapTurn
	call ConfusionEffect
	jp SwapTurn

SelfPoisonEffect:
	call SwapTurn
	call PoisonEffect
	jp SwapTurn


; Poisons the Defending Pokémon if an evolution card was chosen.
PoisonEvolution_PoisonEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z ; skip if no evolution card was chosen
	jp PoisonEffect


; ------------------------------------------------------------------------------
; Play Area Status Effects
; ------------------------------------------------------------------------------

TargetedPoisonEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	cp $ff
	ret z
	ld e, a
	call SwapTurn
	call PoisonEffect_PlayArea
	jp SwapTurn


; input e: PLAY_AREA_* of the target Pokémon
PoisonEffect_PlayArea:
	lb bc, $ff, POISONED
	jr ApplyStatusEffectToPlayAreaPokemon

IF DOUBLE_POISON_EXISTS
; input e: PLAY_AREA_* of the target Pokémon
DoublePoisonEffect_PlayArea:
	lb bc, $ff, DOUBLE_POISONED
	jr ApplyStatusEffectToPlayAreaPokemon
ENDC


; input e: PLAY_AREA_* of the target Pokémon
BurnEffect_PlayArea:
	lb bc, $ff, BURNED
	jr ApplyStatusEffectToPlayAreaPokemon

; input e: PLAY_AREA_* of the target Pokémon
ParalysisEffect_PlayArea:
	lb bc, PSN_BRN, PARALYZED
	jr ApplyStatusEffectToPlayAreaPokemon

; input e: PLAY_AREA_* of the target Pokémon
ConfusionEffect_PlayArea:
	lb bc, PSN_BRN, CONFUSED
	jr ApplyStatusEffectToPlayAreaPokemon

; input e: PLAY_AREA_* of the target Pokémon
SleepEffect_PlayArea:
	lb bc, PSN_BRN, ASLEEP
	jr ApplyStatusEffectToPlayAreaPokemon


; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
;   e: PLAY_AREA_* of the target Pokémon
; outputs:
;   [wNoEffectFromWhichStatus]: set with the input status condition
;   carry: set if able to apply status
; preserves: de
ApplyStatusEffectToPlayAreaPokemon:
	xor a  ; PLAY_AREA_ARENA
	cp e
	jr nz, .skip_no_damage_or_effect
	ld a, [wLoadedAttackCategory]
	cp POKEMON_POWER
	jr z, .skip_no_damage_or_effect
	ld a, [wNoDamageOrEffect]
	or a
	jr nz, .cant_induce_status
.skip_no_damage_or_effect
	call CanBeAffectedByStatus  ; preserves bc, de
	jr c, .can_induce_status
.cant_induce_status
	ld a, c
	ld [wNoEffectFromWhichStatus], a
	call SetNoEffectFromStatus  ; preserves hl, bc, de
	or a
	ret
.can_induce_status
	ld a, DUELVARS_ARENA_CARD_STATUS
	add e
	call GetTurnDuelistVariable  ; current status
	and b  ; status condition to preserve
	or c  ; status to apply on top
	ld [hl], a
	scf
	ret


; unused
; NOTE: needs to run the prelude from ApplyStatusEffectToDefendingPokemon
; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
; ApplyStatusEffectToAllPlayAreaPokemon:
; 	call ApplyStatusEffectToArenaPokemon
; 	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
; 	call GetTurnDuelistVariable
; 	ld d, a
; 	ld e, PLAY_AREA_ARENA
; 	jr .next
; .loop_play_area
; 	call ApplyStatusEffectToPlayAreaPokemon
; .next
; 	inc e
; 	dec d
; 	ret z
; 	jr .loop_play_area


; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
ApplyStatusEffectToAllBenchedPokemon:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA
	jr .next
.loop_play_area
	call ApplyStatusEffectToPlayAreaPokemon
.next
	inc e
	dec d
	ret z
	jr .loop_play_area


; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
ApplyStatusEffectToAllOpponentBenchedPokemon:
	call SwapTurn
	call ApplyStatusEffectToAllBenchedPokemon
	jp SwapTurn


; ------------------------------------------------------------------------------
; Pokémon Powers
; ------------------------------------------------------------------------------


HayFever_ParalysisEffect:
	; ld a, [wGarbageEaterDamageToHeal]  ; used an item?
	; or a
	; ret z  ; nothing to do
	call IsHayFeverActive
	ret nc  ; nothing to do

	ld e, PLAY_AREA_ARENA
	call CanBeAffectedByStatus
	jp nc, ApplyStatusEffectToPlayAreaPokemon.cant_induce_status

; play initial animation
	bank1call DrawDuelMainScene
	ld a, ATK_ANIM_HAY_FEVER
	ld b, PLAY_AREA_ARENA
	bank1call PlayAdhocAnimationOnDuelScene_NoEffectiveness
; play animation and paralyze card
	ld a, ATK_ANIM_SELF_PARALYSIS
	bank1call PlayAdhocAnimationOnPlayAreaArena_NoEffectiveness
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
; if the status depends on card type...
	; ld a, [wLastPlayedCardType]
	; cp TYPE_TRAINER_SUPPORTER
	and PSN_BRN
	or PARALYZED
	or BURNED
	ld [hl], a
	bank1call DrawDuelHUDs
	ret


NoxiousScalesEffect:
	ldh a, [hWhoseTurn]
	ld hl, wWhoseTurn
	cp [hl]
	ret nz  ; it is the opponent's turn
; check for Venomoth in the Active Spot
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call GetCardIDFromDeckIndex
	ld a, e
	cp VENOMOTH
	ret nz  ; not Venomoth
; check whether Pokémon Powers can be used
	call CheckCannotUseDueToStatus
	ret c  ; unable to use Power
; check whether the opponent's Active Pokémon is still alive
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	or a
	ret z  ; already Knocked Out
; reset status queue
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ff9d], a
; check whether additional status should be applied
	call CheckArenaPokemonHas3OrMoreEnergiesAttached
	jr c, .just_poison

IF DOUBLE_POISON_EXISTS
	call DoublePoisonEffect
ELSE
	call PoisonEffect
ENDC
	call ConfusionEffect
	jr ApplyStatusAndPlayAnimationAdhoc

.just_poison
	call PoisonEffect
	jr ApplyStatusAndPlayAnimationAdhoc


; ------------------------------------------------------------------------------
; Utility Functions
; ------------------------------------------------------------------------------

; input:
;   b: mask of status conditions to preserve on the target
;   c: status condition to inflict to the target
ApplyStatusAndPlayAnimationAdhoc:
	push bc
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld b, a
	ld c, $00
	ldh a, [hWhoseTurn]
	ld h, a
	bank1call PlayInflictStatusAnimation
	pop bc
	ldh a, [hTempPlayAreaLocation_ff9d]
	call UpdatePlayAreaStatusCondition
	bank1call DrawDuelHUDs
	bank1call PrintNoEffectTextOrUnsuccessfulText
	call c, WaitForWideTextBoxInput
	ret


; returns in a the number of Asleep Pokémon
; in the turn holder's Play Area
; sets carry if there is at least one
; preserves: de
; outputs:
;   b: 0
;   c: number of sleeping Pokémon in Play Area
;   a: number of sleeping Pokémon in Play Area
CountSleepingPokemonInPlayArea:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld b, a
	ld c, 0
	or a
	ret z

; status conditions are all stored consecutively; just use hl to loop
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
.loop_play_area
	ld a, [hli]  ; get status and move to next
	and CNF_SLP_PRZ
	cp ASLEEP
	jr nz, .next
	inc c
.next
	dec b
	jr nz, .loop_play_area
	ld a, c
	cp 1
	ccf
	ret


; returns in a the number of Poisoned Pokémon
; in the turn holder's Play Area
; sets carry if there is at least one
; preserves: de
; outputs:
;   b: 0
;   c: number of poisoned Pokémon in Play Area
;   a: number of poisoned Pokémon in Play Area
CountPoisonedPokemonInPlayArea:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld b, a
	ld c, 0
	or a
	ret z

; status conditions are all stored consecutively; just use hl to loop
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
.loop_play_area
	ld a, [hli]  ; get status and move to next
IF DOUBLE_POISON_EXISTS
	and MAX_POISON
ELSE
	and POISONED
ENDC
	jr z, .next
	inc c
.next
	dec b
	jr nz, .loop_play_area
	ld a, c
	cp 1
	ccf
	ret
