; ------------------------------------------------------------------------------
; Recoil
; ------------------------------------------------------------------------------

Recoil10Effect:
	ld a, 10
	jr TakeRecoilDamageEffect

Recoil20Effect:
	ld a, 20
	jr TakeRecoilDamageEffect


Recoil30UnlessActiveThisTurnEffect:
	call CheckEnteredActiveSpotThisTurn
	ret nc  ; entered the Active Spot this turn
	; fallthrough

Recoil30Effect:
	ld a, 30
	jr TakeRecoilDamageEffect

Recoil40Effect:
	ld a, 40
	jr TakeRecoilDamageEffect

Recoil50Effect:
	ld a, 50
	jr TakeRecoilDamageEffect


TakeRecoilDamageEffect:
	bank1call DealRecoilDamageToSelf
	ret


; ------------------------------------------------------------------------------
; Area Damage
; ------------------------------------------------------------------------------


; deal 10 damage to each of the opponent's Pokémon
DamageAllOpponentPokemon10Effect_ThunderAnim:
	ld a, ATK_ANIM_THUNDER_PLAY_AREA
	ld [wLoadedAttackAnimation], a
	ld de, 10
	jr DamageAllOpponentPokemon_DE

; deal 10 damage to each of the opponent's Pokémon
DamageAllOpponentPokemon10Effect:
	ld a, ATK_ANIM_BENCH_HIT
	ld [wLoadedAttackAnimation], a
	ld de, 10
	; jr DamageAllOpponentPokemon_DE
	; fallthrough

; deal 10 damage to each of the opponent's Pokémon
; input:
;   de: amount of damage to deal
;   [wLoadedAttackAnimation]: the animation of the effect
DamageAllOpponentPokemon_DE:
	call SwapTurn
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	ld b, PLAY_AREA_ARENA
.loop
	; use the animation loaded into [wLoadedAttackAnimation]
	call DealDamageToPlayAreaPokemon  ; preserves bc, de
	inc b
	dec c
	jr nz, .loop
	jp SwapTurn


; deal 10 damage to each of the opponent's benched Pokémon
DamageAllOpponentBenched10Effect:
	ld de, 10
	jr DamageAllOpponentBenchedPokemon

; deal 20 damage to each of the opponent's benched Pokémon
DamageAllOpponentBenched20Effect:
	ld de, 20
	; jr DamageAllOpponentBenchedPokemon
	; fallthrough

; input:
;   de: amount of damage to deal to each Pokémon
DamageAllOpponentBenchedPokemon:
	call SwapTurn
	xor a
	ld [wIsDamageToSelf], a
	call DamageAllBenchedPokemon
	jp SwapTurn


; deal 10 damage to each of the turn holder's benched Pokémon
DamageAllFriendlyPokemon10Effect:
	ld de, 10
	jr DamageAllFriendlyPokemon

; deal 20 damage to each of the turn holder's benched Pokémon
DamageAllFriendlyPokemon20Effect:
	ld de, 20
	jr DamageAllFriendlyPokemon

; deal 30 damage to each of the turn holder's benched Pokémon
DamageAllFriendlyPokemon30Effect:
	ld de, 30
	; jr DamageAllFriendlyPokemon
	; fallthrough

; input:
;   de: amount of damage to deal to each Pokémon
DamageAllFriendlyPokemon:
	ld a, TRUE
	ld [wIsDamageToSelf], a
	; jr DamageAllBenchedPokemon
	; fallthrough


; deal damage to all the turn holder's benched Pokémon
; input:
;   de: amount of damage to deal to each Pokémon
DamageAllBenchedPokemon:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld c, a
	ld b, PLAY_AREA_ARENA
	jr .skip_to_bench
.loop
	call DealDamageToPlayAreaPokemon_RegularAnim  ; preserves hl, bc, de
.skip_to_bench
	inc b
	dec c
	jr nz, .loop
	ret


IfAttachedToolDamageOpponentBench10Effect:
	xor a  ; PLAY_AREA_ARENA
	call CheckPokemonHasNoToolsAttached
	ret nc  ; no Tool
	jp DamageAllOpponentBenched10Effect


; IfActiveThisTurnDamageOpponentBench10Effect:
; 	call CheckEnteredActiveSpotThisTurn
; 	ret c  ; not Active this turn
; 	jp DamageAllOpponentBenched10Effect


; ------------------------------------------------------------------------------
; Targeted Damage
; ------------------------------------------------------------------------------


Deal10DamageToTarget_DamageEffect:
	ld de, 10
	jr DealDamageToTarget_DE_DamageEffect

Deal20DamageToTarget_DamageEffect:
	ld de, 20
	jr DealDamageToTarget_DE_DamageEffect

Deal40DamageToTarget_DamageEffect:
	ld de, 40
	jr DealDamageToTarget_DE_DamageEffect

Deal50DamageToTarget_DamageEffect:
	ld de, 50
	jr DealDamageToTarget_DE_DamageEffect

Deal30DamageToTarget_DamageEffect:
	ld de, 30
	; jr DealDamageToTarget_DE_DamageEffect
	; fallthrough

; Deals DE damage to 1 of the opponent's Pokémon
DealDamageToTarget_DE_DamageEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	cp $ff
	ret z
	; fallthrough

; Deals DE damage to 1 of the opponent's Pokémon
; in play area location A
DealDamageToTargetA_DE_DamageEffect:
	call SwapTurn
	; ldh a, [hTempPlayAreaLocation_ffa1]
	ld b, a
	; ld de, 30
	call DealDamageToPlayAreaPokemon_RegularAnim
	jp SwapTurn


Snowstorm_DamageEffect:
	ldh a, [hTemp_ffa0]
	or a
	ret z
	call ATimes10
	ld e, a
	ld d, 0
	jr DealDamageToTarget_DE_DamageEffect


ThunderSpear_DamageEffect:
	ld a, ATK_ANIM_THUNDER_PLAY_AREA
	ld [wLoadedAttackAnimation], a
	ldh a, [hTemp_ffa0]
	add a
	ret z
	call ATimes10
	ld e, a
	ld d, 0
	jr DealDamageToTarget_DE_DamageEffect


LickingShot_DamageEffect:
	ld e, PLAY_AREA_ARENA
	call GetEnergyAttachedMultiplierDamage
	ld e, a
	ld d, 0
	jr DealDamageToTarget_DE_DamageEffect


; input:
;   a: ATK_ANIM_* constant
;   de: amount of damage
DealDamageToArenaPokemon_CustomAnim:
	ld [wLoadedAttackAnimation], a
	call SwapTurn
	; ld de, 30
	ld b, PLAY_AREA_ARENA
	call DealDamageToPlayAreaPokemon
	jp SwapTurn


;
TrampleEffect:
DealExcessDamageToTarget_DamageEffect:
	ld a, [wOverkillDamage]
	or a
	ret z
	ld d, 0
	ld e, a  ; excess damage
; refresh screen to show new Active Pokémon
	push de
	; xor a  ; REFRESH_DUEL_SCREEN
	; ld [wDuelDisplayedScreen], a
	; bank1call DrawDuelMainScene
	ldtx hl, DoExcessDamageToTheNewActivePokemonText
	call DrawWideTextBox_WaitForInput
	pop de
	xor a  ; PLAY_AREA_ARENA
	jr DealDamageToTargetA_DE_DamageEffect


Deal10DamageToFriendlyTarget_DamageEffect:
	ld de, 10
	jr DealDamageToFriendlyTarget_DE_DamageEffect

Deal20DamageToFriendlyTarget_DamageEffect:
	ld de, 20
	jr DealDamageToFriendlyTarget_DE_DamageEffect

Deal30DamageToFriendlyTarget_DamageEffect:
	ld de, 30
	; jr DealDamageToFriendlyTarget_DE_DamageEffect
	; fallthrough

; Deals DE damage to 1 of the turn holder's Pokémon
DealDamageToFriendlyTarget_DE_DamageEffect:
	ldh a, [hTempPlayAreaLocation_ffa1]
	cp $ff
	ret z
	ld b, a
	ld a, TRUE
	ld [wIsDamageToSelf], a
	jp DealDamageToPlayAreaPokemon_RegularAnim


; ------------------------------------------------------------------------------
; Targeted Damage - Damage Counters
; ------------------------------------------------------------------------------


; input:
;   d: damage to deal (direct damage)
;   e: PLAY_AREA_* of the target
; preserves: hl, bc, de
PutDamageCounters_NoAnim_Unchecked:
	ld a, e
	or a  ; cp PLAY_AREA_ARENA
	jr nz, .skip_no_damage_or_effect_check  ; .bench
; arena
	ld a, [wNoDamageOrEffect]
	or a
	ret nz  ; no damage
; .bench
	; call IsBodyguardActive
	; ccf
	; ret nc  ; no damage
.skip_no_damage_or_effect_check
	xor a
	ld [wNoDamageOrEffect], a
	ld a, e
	ld e, d
	ld d, 0
	add DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	or a
	ret z  ; already KO
	call SubtractHP  ; preserves hl, bc, de
	ld a, [hl]
	or a
	ret nz  ; no KO
	scf  ; signal KO
	ret


; Put 1 damage counter and Poison a selected target.
SneakyBite_DamageEffect:
; store trigger, just to reuse code below
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTemp_ffa0], a
; check duelist type
	ld a, DUELVARS_DUELIST_TYPE
	call GetTurnDuelistVariable
	cp DUELIST_TYPE_LINK_OPP
	jr z, .link_opp
	and DUELIST_TYPE_AI_OPP
	jr nz, .ai_opp

; player
	call MayDamageTargetPokemon_PlayerSelectEffect
	call SerialSend8Bytes
	jr .damage

.link_opp
	call SerialRecv8Bytes
	jr .damage

.ai_opp
; AI just selects the Active Pokémon
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	; fallthrough

.damage
	ldh a, [hTempPlayAreaLocation_ffa1]
	ld e, a
	call PoisonEffect_OpponentPlayArea
	; jr Curse_DamageEffect
	; fallthrough


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
	call SetFlag_KnockedOutOpponentPokemon
	bank1call ClearKnockedOutPokemon_TakePrizes_CheckGameOutcome
	ret


; ------------------------------------------------------------------------------
; Targeted Damage - Player Selection
; ------------------------------------------------------------------------------


MayDamageTargetPokemon_PlayerSelectEffect:
	ld a, $ff
	ldh [hTempPlayAreaLocation_ffa1], a
	ldtx hl, ChoosePokemonToGiveDamageText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	call HandlePlayerSelectionPokemonInPlayArea_AllowCancel
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	jp SwapTurn


; can choose any Pokémon in Play Area
DamageTargetPokemon_PlayerSelectEffect:
	xor a  ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	cp 2
	jr c, .done ; has no Bench Pokemon

	ldtx hl, ChoosePokemonToGiveDamageText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	bank1call HasAlivePokemonInPlayArea
	call DamageTargetBenchedPokemon_PlayerSelectEffect.loop_input
.done
	or a
	ret


DamageTargetBenchedPokemonIfAny_PlayerSelectEffect:
	ld a, $ff
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	cp 2
	ret c ; has no Bench Pokemon
	; fallthrough

DamageTargetBenchedPokemon_PlayerSelectEffect:
	ldtx hl, ChoosePokemonInTheBenchToGiveDamageText
	call DrawWideTextBox_WaitForInput
	call SwapTurn
	bank1call HasAlivePokemonInBench

.loop_input
	bank1call OpenPlayAreaScreenForSelection
	jr c, .loop_input
	ldh a, [hTempPlayAreaLocation_ff9d]
	ldh [hTempPlayAreaLocation_ffa1], a
	jp SwapTurn


DamageFriendlyBenchedPokemonIfAny_PlayerSelectEffect:
	call SwapTurn
	call DamageTargetBenchedPokemonIfAny_PlayerSelectEffect
	jp SwapTurn


;
GetMad_PlayerSelectEffect:
; store the current HP of the user
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	ldh [hTemp_ffa0], a
; menu prompt
	ldtx hl, PutHowManyDamageCountersMenuText
	call DrawWideTextBox_PrintText
; set up menu parameters
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	ld d, a  ; damage
	ld a, c  ; max HP
	sub d    ; current HP
	; sub 10
	call ADividedBy10  ; max damage counters
	; dec a
	ld hl, GetMad_NumberSliderHandler
; handle input
	call HandleNumberSlider
	push af
	; ret c  ; cancelled
	; cp 1
	; ret c  ; zero equals cancelled
; restore HP to what it was
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable  ; preserves nc flag
	ldh a, [hTemp_ffa0]
	ld [hl], a
; return if the player cancelled
	pop af
	ret c
; store selected number of damage counters
	ldh a, [hCurMenuItem]
	ldh [hTemp_ffa0], a
	ret


; input:
;   a: current slider number (already inverted)
GetMad_NumberSliderHandler:
; convert damage counters into actual damage
	call ATimes10
	ld c, a  ; temp storage
; blink the HP bar every 16 frames
	ld hl, wCursorBlinkCounter
	ld a, [hl]
	and $f
	ret nz
	bit 4, [hl]
	ldh a, [hTemp_ffa0]  ; initial HP
	ld b, a  ; final HP value to draw
	jr nz, .draw_unchanged_hp
	sub c  ; not supposed to underflow
	ld b, a
.draw_unchanged_hp
; change current HP based on user input
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	ld a, b
	cp [hl]
	ret z  ; no change
	ld [hl], a
	bank1call DrawDuelHUDs
	ret


; ------------------------------------------------------------------------------
; Targeted Damage - AI Selection
; ------------------------------------------------------------------------------


; can choose any Pokémon in Play Area
; output:
;   a: PLAY_AREA_* of the selected Pokémon
;   [hTempPlayAreaLocation_ffa1]: PLAY_AREA_* of the selected Pokémon
;   z: set if Arena is selected
;   nz: set if Bench is selected
DamageTargetPokemon_AISelectEffect:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	cp 2
	jr c, .arena  ; has no Bench Pokemon
; AI always picks Pokemon with lowest HP remaining
	call GetOpponentBenchPokemonWithLowestHP
; amount of HP remaining is in e
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	ld a, e
	cp [hl]
	jr c, .done  ; got minimum
.arena
	xor a
	ldh [hTempPlayAreaLocation_ffa1], a
.done
	or a
	ret


DamageTargetBenchedPokemonIfAny_AISelectEffect:
	ld a, $ff
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetNonTurnDuelistVariable
	cp 2
	ret c ; has no Bench Pokemon
	; fallthrough

DamageTargetBenchedPokemon_AISelectEffect:
; AI always picks Pokemon with lowest HP remaining
	call GetOpponentBenchPokemonWithLowestHP
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


DamageFriendlyBenchedPokemonIfAny_AISelectEffect:
	ld a, $ff
	ldh [hTempPlayAreaLocation_ffa1], a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	cp 2
	ret c ; has no Bench Pokemon
	; fallthrough

DamageFriendlyBenchedPokemon_AISelectEffect:
; AI always picks Pokemon with highest HP remaining
	call GetBenchPokemonWithHighestHP
	ldh [hTempPlayAreaLocation_ffa1], a
	ret


; ------------------------------------------------------------------------------
; Passive Damage - Pokémon Powers
; ------------------------------------------------------------------------------

SpikesDamageEffect:
	call SwapTurn
	call IsSpikesActive
	call SwapTurn
	ret nc  ; Spikes is not active

	; ld a, [wDuelDisplayedScreen]
	; cp DUEL_MAIN_SCENE
	; jr z, .main_scene
	; bank1call DrawDuelMainScene
; .main_scene
	ld e, PLAY_AREA_ARENA
	jp Put1DamageCounterOnTarget

	; ld a, DUELVARS_ARENA_CARD
	; call LoadCardNameAndLevelFromVarToRam2
	; ldtx hl, Received10DamageDueToSpikesText
	; jp DrawWideTextBox_WaitForInput


; ------------------------------------------------------------------------------
; Other Forms of Damage
; ------------------------------------------------------------------------------

; assume:
;   - this is called after dealing damage, to have [wNoDamageOrEffect] set
KnockOutDefendingPokemonEffect:
	call CheckDefendingPokemonAffectedByEffects
	jp c, DrawWideTextBox_WaitForInput
; affected by effects
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	or a
	ret z
; not Knocked Out previously
	ld [hl], 0
	; push hl
	; call DrawDuelMainScene
	; call DrawDuelHUDs
	; pop hl
	ld l, DUELVARS_ARENA_CARD
	ld a, [hl]
	call SwapTurn
	call LoadCardDataToBuffer2_FromDeckIndex
	call SwapTurn
	call LoadCard2NameToRamText
	ldtx hl, WasKnockedOutText
	jp DrawWideTextBox_WaitForInput
