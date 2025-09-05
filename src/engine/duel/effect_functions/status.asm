; ------------------------------------------------------------------------------
; Status Effects vs Defending Pokémon
; ------------------------------------------------------------------------------

PoisonEffect:
	ld a, ATK_ANIM_POISON
	ld c, POISONED
	; ldtx hl, ReceivedDamageDueToPoisonText
	jr InflictDamageOverTimeStatusEffect

IF DOUBLE_POISON_EXISTS
DoublePoisonEffect:
	ld a, ATK_ANIM_POISON
	ld c, DOUBLE_POISONED
	; ldtx hl, ReceivedDamageDueToPoisonText
	jr InflictDamageOverTimeStatusEffect
ENDC

BurnEffect:
	ld a, ATK_ANIM_BURN
	ld c, BURNED
	; ldtx hl, ReceivedDamageDueToBurnText
	jr InflictDamageOverTimeStatusEffect


; input:
;   a: ATK_ANIM_* to play
;   c: Damage Over Time status (POISONED, BURNED)
InflictDamageOverTimeStatusEffect:
	ld b, a
	call CheckNotImmuneToAttackEffects  ; preserves: hl, bc, de
	jp c, SetNoEffectFromStatus  ; preserves hl, bc, de
; not immune to attack effects
	ld a, b
	ld [wLoadedAttackAnimation], a
	; ld a, l
	; ld [wDynamicTextPointer], a
	; ld a, h
	; ld [wDynamicTextPointer + 1], a
	ld b, $ff
	ld e, PLAY_AREA_ARENA
	call SwapTurn
	bank1call InflictDamageOverTimeStatus
	call SwapTurn
	jr c, .knock_out
	or a
	ret nz  ; affected, but no KO
	jp SetNoEffectFromStatus

.knock_out  ; affected by status
	ld a, DUELVARS_MISC_TURN_FLAGS
	call GetTurnDuelistVariable
	set TURN_FLAG_KO_OPPONENT_POKEMON_F, [hl]
	ret


ParalysisEffect:
	ld a, ATK_ANIM_PARALYSIS
	ld c, PARALYZED
	jr InflictCrowdControlStatusEffect

ConfusionEffect:
	ld a, ATK_ANIM_CONFUSION
	ld c, CONFUSED
	jr InflictCrowdControlStatusEffect

SleepEffect:
	ld a, ATK_ANIM_SLEEP
	ld c, ASLEEP
	jr InflictCrowdControlStatusEffect


IF CC_IS_COIN_FLIP
FlinchEffect:
	ld a, ATK_ANIM_POT_SMASH
	ld c, FLINCHED
	; jr InflictCrowdControlStatusEffect
	; fallthrough
ENDC


; input:
;   a: ATK_ANIM_* to play
;   c: Crowd Control status (PARALYZED, CONFUSED, ASLEEP)
InflictCrowdControlStatusEffect:
	ld b, a
	call CheckNotImmuneToAttackEffects  ; preserves: hl, bc, de
	jp c, SetNoEffectFromStatus  ; preserves hl, bc, de
; not immune to attack effects
	ld a, b
	ld [wLoadedAttackAnimation], a
	ld b, PSN_BRN
	ld e, PLAY_AREA_ARENA
	call SwapTurn
	bank1call InflictCrowdControlStatus
	call SwapTurn
	or a
	jp z, SetNoEffectFromStatus
; affected by status
	ret


; ------------------------------------------------------------------------------
; Self-Inflicted Status Effects
; ------------------------------------------------------------------------------


SelfConfusionEffect:
	ld a, ATK_ANIM_SELF_CONFUSION
	ld c, CONFUSED
	jr SelfInflictCrowdControlStatusEffect


IF CC_IS_COIN_FLIP
SelfFlinchEffect:
	ld a, ATK_ANIM_SELF_CONFUSION
	ld c, FLINCHED
	; jr SelfInflictCrowdControlStatusEffect
	; fallthrough
ENDC


; input:
;   a: ATK_ANIM_* to play
;   c: Crowd Control status (PARALYZED, CONFUSED, SLEEP)
SelfInflictCrowdControlStatusEffect:
	ld [wLoadedAttackAnimation], a
	ld b, PSN_BRN
	ld e, PLAY_AREA_ARENA
	bank1call InflictCrowdControlStatus
	ret


; ------------------------------------------------------------------------------
; Play Area Status Effects
; ------------------------------------------------------------------------------


; input e: PLAY_AREA_* of the target Pokémon
; preserves: de
PoisonEffect_OpponentPlayArea:
	call SwapTurn
	call PoisonEffect_PlayArea
	call SwapTurn
; Knocked Out a Pokémon
	ld a, DUELVARS_MISC_TURN_FLAGS
	call GetTurnDuelistVariable
	set TURN_FLAG_KO_OPPONENT_POKEMON_F, [hl]
	ret


; input e: PLAY_AREA_* of the target Pokémon
; preserves: de
BurnEffect_OpponentPlayArea:
	call SwapTurn
	call BurnEffect_PlayArea
	call SwapTurn
; Knocked Out a Pokémon
	ld a, DUELVARS_MISC_TURN_FLAGS
	call GetTurnDuelistVariable
	set TURN_FLAG_KO_OPPONENT_POKEMON_F, [hl]
	ret


; input e: PLAY_AREA_* of the target Pokémon
; preserves: de
PoisonEffect_PlayArea:
	xor a  ; ATK_ANIM_NONE
	ld c, POISONED
	jr InflictDamageOverTimeStatusEffect_PlayArea

IF DOUBLE_POISON_EXISTS
; input e: PLAY_AREA_* of the target Pokémon
; preserves: de
DoublePoisonEffect_PlayArea:
	xor a  ; ATK_ANIM_NONE
	ld c, DOUBLE_POISONED
	jr InflictDamageOverTimeStatusEffect_PlayArea
ENDC

; input e: PLAY_AREA_* of the target Pokémon
; preserves: de
BurnEffect_PlayArea:
	xor a  ; ATK_ANIM_NONE
	ld c, BURNED
	jr InflictDamageOverTimeStatusEffect_PlayArea


; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   a: ATK_ANIM_* to play
;   c: status condition to inflict (POISONED, BURNED)
;	  e: PLAY_AREA_* of the target Pokémon
; preserves: c, de
InflictDamageOverTimeStatusEffect_PlayArea:
	ld [wLoadedAttackAnimation], a
	ld b, $ff
	; input b: mask of status conditions to preserve on the target
	; input c: status condition to inflict (POISONED, BURNED)
	; input e: PLAY_AREA_* of the target Pokémon
	bank1call InflictDamageOverTimeStatus  ; preserves: bc, de
	; TODO error message
	; or a
	; jp z, SetNoEffectFromStatus
; affected by status
	ret


; input e: PLAY_AREA_* of the target Pokémon
; preserves: de
ParalysisEffect_PlayArea:
	xor a  ; ATK_ANIM_NONE
	ld c, PARALYZED
	jr InflictCrowdControlStatusEffect_PlayArea

; input e: PLAY_AREA_* of the target Pokémon
; preserves: de
ConfusionEffect_PlayArea:
	xor a  ; ATK_ANIM_NONE
	ld c, CONFUSED
	jr InflictCrowdControlStatusEffect_PlayArea

; input e: PLAY_AREA_* of the target Pokémon
; preserves: de
SleepEffect_PlayArea:
	xor a  ; ATK_ANIM_NONE
	ld c, ASLEEP
	jr InflictCrowdControlStatusEffect_PlayArea

IF CC_IS_COIN_FLIP
; input e: PLAY_AREA_* of the target Pokémon
; preserves: de
FlinchEffect_PlayArea:
	xor a  ; ATK_ANIM_NONE
	ld c, FLINCHED
	; jr InflictCrowdControlStatusEffect_PlayArea
	; fallthrough
ENDC


; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   a: ATK_ANIM_* to play
;   c: status condition to inflict (PARALYZED, CONFUSED, ASLEEP)
;   e: PLAY_AREA_* of the target Pokémon
; preserves: c, de
InflictCrowdControlStatusEffect_PlayArea:
	ld [wLoadedAttackAnimation], a
	ld b, PSN_BRN
	; input b: mask of status conditions to preserve on the target
	; input c: status condition to inflict (PARALYZED, CONFUSED, ASLEEP)
	; input e: PLAY_AREA_* of the target Pokémon
	bank1call InflictCrowdControlStatus  ; preserves: bc, de
	; or a
	; TODO error message
	; jp z, SetNoEffectFromStatus
; affected by status
	ret


; ------------------------------------------------------------------------------
; Spread Status Effects
; ------------------------------------------------------------------------------


PoisonAllOpponentPokemonEffect:
	call PoisonEffect
	ld a, ATK_ANIM_BENCH_HIT
	ld c, POISONED
	call SwapTurn
	call InflictDamageOverTimeStatusEffect_AllBenchedPokemon
	call SwapTurn
	ret nc
; Knocked Out at least one Pokémon
	ld a, DUELVARS_MISC_TURN_FLAGS
	call GetTurnDuelistVariable
	set TURN_FLAG_KO_OPPONENT_POKEMON_F, [hl]
	ret


BurnAllOpponentPokemonEffect:
	call BurnEffect
	ld a, ATK_ANIM_BENCH_HIT
	ld c, BURNED
	call SwapTurn
	call InflictDamageOverTimeStatusEffect_AllBenchedPokemon
	call SwapTurn
	ret nc
; Knocked Out at least one Pokémon
	ld a, DUELVARS_MISC_TURN_FLAGS
	call GetTurnDuelistVariable
	set TURN_FLAG_KO_OPPONENT_POKEMON_F, [hl]
	ret


; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   a: ATK_ANIM_* to play
;   c: status condition to inflict (POISONED, BURNED)
; output:
;   a: number of Pokémon that were Knocked Out
;   carry: set if a Pokémon was Knocked Out
InflictDamageOverTimeStatusEffect_AllBenchedPokemon:
	ld [wLoadedAttackAnimation], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA
	ld b, 0  ; KO counter
	jr .next
.loop_play_area
	push bc
	ld b, $ff
	; input b: mask of status conditions to preserve on the target
	; input c: status condition to inflict (POISONED, BURNED)
	; input e: PLAY_AREA_* of the target Pokémon
	bank1call InflictDamageOverTimeStatus
	; TODO error message
	pop bc
	jr nc, .next
	inc b
.next
	inc e
	dec d
	jr nz, .loop_play_area
	ld a, b
	cp 1
	ccf  ; carry if >= 1
	ret


; assumes:
;   - SwapTurn if needed to change to the correct play area
; input:
;   a: ATK_ANIM_* to play
;   c: status condition to inflict (PARALYZED, CONFUSED, ASLEEP)
InflictCrowdControlStatusEffect_AllBenchedPokemon:
	ld [wLoadedAttackAnimation], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA
	ld b, PSN_BRN
	jr .next
.loop_play_area
	; input b: mask of status conditions to preserve on the target
	; input c: status condition to inflict (PARALYZED, CONFUSED, ASLEEP)
	; input e: PLAY_AREA_* of the target Pokémon
	bank1call InflictCrowdControlStatus
	; TODO error message
.next
	inc e
	dec d
	ret z
	jr .loop_play_area


; ------------------------------------------------------------------------------
; Status Attacks
; ------------------------------------------------------------------------------


BurnIfDamagedEffect:
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	or a
	ret z  ; nothing to do
	jp BurnEffect


ParalysisIfSelectedCardEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z  ; nothing to do
	jp ParalysisEffect

ParalysisIfDamagedSinceLastTurnEffect:
	ld a, DUELVARS_ARENA_CARD_FLAGS
	call GetTurnDuelistVariable
	bit DAMAGED_SINCE_LAST_TURN_F, a
	ret z
	jp ParalysisEffect


PoisonConfusionEffect:
	call PoisonEffect
	jp ConfusionEffect


PoisonSleepEffect:
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
	ret c
	call BurnEffect
	jp ConfusionEffect


SilverWhirlwind_StatusEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	cp $ff
	jr z, .arena
	call PoisonEffect_PlayArea  ; preserves: de
	call ConfusionEffect_PlayArea
.arena
	call PoisonEffect
	call BurnEffect
	jp SleepEffect


Snowstorm_SleepEffect:
; check target Benched Pokémon
	ldh a, [hTemp_ffa0]
	ld c, a
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	call SwapTurn
	call GetPlayAreaCardAttachedEnergies  ; preserves bc, de
	call SwapTurn
	ld a, [wTotalAttachedEnergies]
	cp c
	call c, SleepEffect_PlayArea
; check Defending Pokémon
	ldh a, [hTemp_ffa0]
	ld c, a
	ld e, PLAY_AREA_ARENA
	call SwapTurn
	call GetPlayAreaCardAttachedEnergies  ; preserves bc, de
	call SwapTurn
	ld a, [wTotalAttachedEnergies]
	cp c
	jp c, SleepEffect
	ret


WickedTentacle_PoisonEffect:
	call TargetedPoisonEffect
	jp PoisonEffect


TargetedPoisonEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	cp $ff
	ret z
	ld e, a
	call SwapTurn
	call PoisonEffect_PlayArea
	jp SwapTurn


; ------------------------------------------------------------------------------
; Pokémon Powers
; ------------------------------------------------------------------------------


HayFever_ParalysisEffect:
	call IsHayFeverActive
	ret nc  ; nothing to do

; play initial animation
	bank1call DrawDuelMainScene
	ld a, ATK_ANIM_HAY_FEVER
	ld b, PLAY_AREA_ARENA
	bank1call PlayAdhocAnimationOnDuelScene_NoEffectiveness

; play animation and paralyze card
	ld a, ATK_ANIM_SELF_PARALYSIS
	ld [wLoadedAttackAnimation], a
	ld b, PSN_BRN
	ld c, PARALYZED
	ld e, PLAY_AREA_ARENA
	bank1call InflictCrowdControlStatus
	or a
	call z, SetNoEffectFromStatus

	xor a  ; ATK_ANIM_NONE
	ld [wLoadedAttackAnimation], a
	ld b, $ff
	ld c, BURNED
	ld e, PLAY_AREA_ARENA
	bank1call InflictDamageOverTimeStatus
	or a
	call z, SetNoEffectFromStatus
	bank1call PrintNoEffectTextOrUnsuccessfulText
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
; check whether Poké-Bodies can be used
	call CheckCannotUsePokeBody
	ret c  ; unable to use ability
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
	ld e, PLAY_AREA_ARENA
	push af
	call PoisonEffect_PlayArea
	pop af
	ret c  ; just poison
	ld e, PLAY_AREA_ARENA
	jp ConfusionEffect_PlayArea


; ------------------------------------------------------------------------------
; Utility Functions
; ------------------------------------------------------------------------------

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
