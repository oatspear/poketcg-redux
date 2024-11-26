; ------------------------------------------------------------------------------
; Building Blocks
; ------------------------------------------------------------------------------


; overwrites in wDamage, wAIMinDamage and wAIMaxDamage with the value in a
; resets wDamageFlags
SetDefiniteDamage:
	ld [wDamage], a
	ld [wAIMinDamage], a
	ld [wAIMaxDamage], a
	xor a
	ld [wDamageFlags], a
	ret


; overwrites wAIMinDamage and wAIMaxDamage with value in wDamage
SetDefiniteAIDamage:
	ld a, [wDamage]
	ld [wAIMinDamage], a
	ld [wAIMaxDamage], a
	ret


; subtract the value in a from wDamage
SubtractFromDamageCapZero:
	call SubtractFromDamage
	rla
	ret nc
; cap it to 0 damage
	xor a
	jr SetDefiniteDamage


; doubles the damage output
DoubleDamage_DamageBoostEffect:
  ld a, [wDamage]
  add a
  jr nc, .got_damage
; cap damage at 250
	ld a, MAX_DAMAGE
.got_damage
  ld [wDamage], a
  ret


; ------------------------------------------------------------------------------
; Based on Energy Cards
; ------------------------------------------------------------------------------


; +10 damage for each attached energy, +20 if Fighting
Steamroller_DamageBoostEffect:
  ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
; +10 for each attached Energy
	ld a, [wTotalAttachedEnergies]
	or a
	ret z
; +10 on top for each Fighting Energy
  ld hl, wAttachedEnergies + FIGHTING
  add [hl]
	call ATimes10
	jp AddToDamage

Steamroller_AIEffect:
	call Steamroller_DamageBoostEffect
	jp SetDefiniteAIDamage


; 20 extra damage for each Water Energy
HydroPumpEffect:
  call GetNumAttachedWaterEnergy
	add a  ; x2
	call ATimes10
	; call AddToDamage ; add 10 * a to damage
	call SetDefiniteDamage ; damage = 20 * Water Energy
; set attack damage
	jp SetDefiniteAIDamage


; 10 damage for each Water Energy
WaterGunEffect:
  call GetNumAttachedWaterEnergy
	call ATimes10
	call SetDefiniteDamage ; damage = 10 * Water Energy
; set attack damage
	jp SetDefiniteAIDamage


; 10 damage for each Grass Energy
EnergyBallEffect:
  call GetNumAttachedGrassEnergy
	call ATimes10
	call SetDefiniteDamage ; damage = 10 * Water Energy
; set attack damage
	jp SetDefiniteAIDamage


; 10 damage for each Fire Energy
FireSpin_DamageMultiplierEffect:
  call GetNumAttachedFireEnergy
	call ATimes10
	call SetDefiniteDamage ; damage = 10 * Fire Energy
; set attack damage
	jp SetDefiniteAIDamage


GigaDrain_DamageMultiplierEffect:
	ld e, PLAY_AREA_ARENA
	call GetEnergyAttachedMultiplierDamage
	call SetDefiniteDamage
	jp SetDefiniteAIDamage


;
DragonRage_DamageBoostEffect:
	xor a  ; PLAY_AREA_ARENA
	ld e, a
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride

; count how many types of Energy there are (colorless does not count)
	ld b, 0
	ld c, NUM_TYPES - 1
	ld hl, wAttachedEnergies
.loop
	ld a, [hli]
	or a
	jr z, .next
	inc b
.next
	dec c
	jr nz, .loop
	ld a, b
	call ATimes10
	jp AddToDamage

DragonRage_AIEffect:
	call DragonRage_DamageBoostEffect
	jp SetDefiniteAIDamage


SpeedImpact_DamageSubtractionEffect:
	xor a  ; PLAY_AREA_ARENA
	ld e, a
	call SwapTurn
	call GetPlayAreaCardAttachedEnergies
	call SwapTurn
	ld a, [wTotalAttachedEnergies]
	or a
	ret z
	call ATimes10
	add a  ; x20
	jp SubtractFromDamageCapZero

SpeedImpact_AIEffect:
	call SpeedImpact_DamageSubtractionEffect
	jp SetDefiniteAIDamage


Psychic_DamageBoostEffect:
	call SwapTurn
	ld e, PLAY_AREA_ARENA
	call GetEnergyAttachedMultiplierDamage
	call SwapTurn
	jp AddToDamage

Psychic_AIEffect:
	call Psychic_DamageBoostEffect
	jp SetDefiniteAIDamage


; input:
;   e: PLAY_AREA_* of the target Pokémon
; output:
;   a: the number of energies attached to the
;      turn holder's Pokémon times 10.
; assume:
;   - call SwapTurn
GetEnergyAttachedMultiplierDamage:
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
; cap if number of energies >= 25
	cp 26
	jp c, ATimes10
	ld a, 25
	jp ATimes10


Solarbeam_DamageBoostEffect:
	ldh a, [hEnergyTransEnergyCard]
	cp $ff
	ret z
.got_energy
	jp DoubleDamage_DamageBoostEffect


;
TropicalStorm_DamageBoostEffect:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	ld d, a
	ld e, PLAY_AREA_ARENA
	ld c, 0

; go through every Pokemon in the Play Area and boost damage based on energy
.loop_play_area
; check its attached energies
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
	or a
	jr z, .next_pkmn
	inc c
.next_pkmn
	inc e
	dec d
	jr nz, .loop_play_area
	ld a, c
	or a
	ret z  ; done if zero
	rla            ; a = a * 2
	call ATimes10  ; a = a * 10
	jp SetDefiniteDamage  ; a == c * 20

TropicalStorm_AIEffect:
	call TropicalStorm_DamageBoostEffect
	jp SetDefiniteAIDamage



; Deal 10 damage for each energy attached to both Active Pokémon.
; cap at 200 damage
DamagePerEnergyAttachedToBothActive_MultiplierEffect:
; get energies attached to self
	ld e, PLAY_AREA_ARENA
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
	ld d, a
; get energies attached to opponent
	call SwapTurn
	call GetPlayAreaCardAttachedEnergies
	call SwapTurn
	ld a, [wTotalAttachedEnergies]
; add both
	add d
	jr c, .cap  ; overflow
; cap if number of energies >= 20
	cp 21
	jr c, .got_energies
.cap
	ld a, 20
.got_energies
	call ATimes10
	jp SetDefiniteDamage

DamagePerEnergyAttachedToBothActive_AIEffect:
	call DamagePerEnergyAttachedToBothActive_MultiplierEffect
	jp SetDefiniteAIDamage


; +20 damage if this Pokémon has less energies than the opponent
Plus20DamageIfLessEnergyThanOpponent_DamageBoostEffect:
; get energies attached to opponent
	ld e, PLAY_AREA_ARENA
	call SwapTurn
	call GetPlayAreaCardAttachedEnergies
	call SwapTurn
	ld a, [wTotalAttachedEnergies]
	ld d, a
; get energies attached to self
	call GetPlayAreaCardAttachedEnergies
	ld a, [wTotalAttachedEnergies]
; bonus damage if this has less energies
	cp d
	ret nc
	ld a, 20
	jp AddToDamage


Plus20DamageIfLessEnergyThanOpponent_AIEffect:
	call Plus20DamageIfLessEnergyThanOpponent_DamageBoostEffect
	jp SetDefiniteAIDamage


; +10 for each selected energy to recover from discard
Riptide_DamageBoostEffect:
	call TempListLength
	call ATimes10
	jp SetDefiniteDamage

Riptide_AIEffect:
	call CreateEnergyCardListFromDiscardPile_AllEnergy
	call CountCardsInDuelTempList
	cp 4
	jr c, .cap
	ld a, 4
.cap
	call ATimes10
	call SetDefiniteDamage
	jp SetDefiniteAIDamage


IfAttachedEnergy10BonusDamage_DamageBoostEffect:
	call CheckPlayedEnergyThisTurn
	ret c  ; no energy
	ld a, 10
	jp AddToDamage

IfAttachedEnergy10BonusDamage_AIEffect:
	call IfAttachedEnergy10BonusDamage_DamageBoostEffect
	jp SetDefiniteAIDamage


Thunderstorm_MultiplierEffect:
	ldh a, [hTemp_ffa0]
	call ATimes10
	jp SetDefiniteDamage


Wildfire_DamageBoostEffect:
	ldh a, [hTemp_ffa0]
	call ATimes10
	jp AddToDamage


Psyburn_MultiplierEffect:
SheerCold_MultiplierEffect:
ScorchingColumn_MultiplierEffect:
Discharge_MultiplierEffect:
	ldh a, [hTemp_ffa0]
	add a  ; x2
	call ATimes10
	jp SetDefiniteDamage

Discharge_AIEffect:
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ld a, [wAttachedEnergies + LIGHTNING]
	add a  ; x2
	call ATimes10
	; ld d, 0
	; ld e, a
	; jp UpdateExpectedAIDamage
	call SetDefiniteDamage
	jp SetDefiniteAIDamage


Psyburn_AIEffect:
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ld a, [wAttachedEnergies + PSYCHIC]
	add a  ; x2
	call ATimes10
	; ld d, 0
	; ld e, a
	; jp UpdateExpectedAIDamage
	call SetDefiniteDamage
	jp SetDefiniteAIDamage


SheerCold_AIEffect:
WaterPulse_AIEffect:
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ld a, [wAttachedEnergies + WATER]
	add a  ; x2
	call ATimes10
	; ld d, 0
	; ld e, a
	; jp UpdateExpectedAIDamage
	call SetDefiniteDamage
	jp SetDefiniteAIDamage


Wildfire_AIEffect:
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ld a, [wAttachedEnergies + FIRE]
	call ATimes10
	; ld d, 0
	; ld e, a
	; jp UpdateExpectedAIDamage
	call AddToDamage
	jp SetDefiniteAIDamage


ScorchingColumn_AIEffect:
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ld a, [wAttachedEnergies + FIRE]
	add a  ; x2
	call ATimes10
	; ld d, 0
	; ld e, a
	; jp UpdateExpectedAIDamage
	call SetDefiniteDamage
	jp SetDefiniteAIDamage


Thunderstorm_AIEffect:
	call GetPlayAreaCardAttachedEnergies
	call HandleEnergyColorOverride
	ld a, [wAttachedEnergies + LIGHTNING]
	call ATimes10
	; ld d, 0
	; ld e, a
	; jp UpdateExpectedAIDamage
	call SetDefiniteDamage
	jp SetDefiniteAIDamage


; ------------------------------------------------------------------------------
; Based on Trainer Cards
; ------------------------------------------------------------------------------


IfPlayedSupporter20BonusDamage_DamageBoostEffect:
	ld a, [wOncePerTurnActions]
	and PLAYED_SUPPORTER_THIS_TURN
	ret z  ; did not play Supporter
	ld a, 20
	jp AddToDamage


IfPlayedSupporter20BonusDamage_AIEffect:
	call IfPlayedSupporter20BonusDamage_DamageBoostEffect
	jp SetDefiniteAIDamage


IfOpponentPlayedSupporter20BonusDamage_DamageBoostEffect:
	ld a, [wOpponentOncePerTurnActions]
	and PLAYED_SUPPORTER_THIS_TURN
	ret z  ; did not play Supporter
	ld a, 20
	jp AddToDamage


IfOpponentPlayedSupporter20BonusDamage_AIEffect:
	call IfOpponentPlayedSupporter20BonusDamage_DamageBoostEffect
	jp SetDefiniteAIDamage


IfOpponentHasAttachedToolDoubleDamage_AIEffect:
	ld a, DUELVARS_ARENA_CARD_ATTACHED_TOOL
	call GetNonTurnDuelistVariable
	cp $ff
	ret z  ; no attached tools
	call DoubleDamage_DamageBoostEffect
	jp SetDefiniteAIDamage


; ------------------------------------------------------------------------------
; Based on Hand Cards
; ------------------------------------------------------------------------------


; 20 damage for each card in opponent's hand
MindRuler_DamageBoostEffect:
  ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetNonTurnDuelistVariable
	cp (MAX_DAMAGE / 20) + 1
	jr c, .capped
	ld a, MAX_DAMAGE
	jp SetDefiniteDamage
.capped
	call ATimes10
  add a  ; double
	jp SetDefiniteDamage

MindRuler_AIEffect:
  call MindRuler_DamageBoostEffect
  jp SetDefiniteAIDamage


; +10 damage for each card in both players' hands
MindBlast_DamageBoostEffect:
  ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	ld c, a
  ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetNonTurnDuelistVariable
	add c
	cp (MAX_DAMAGE / 10)
	jr c, .capped
	ld a, MAX_DAMAGE
	jp SetDefiniteDamage
.capped
	call ATimes10
  jp AddToDamage

MindBlast_AIEffect:
  call MindBlast_DamageBoostEffect
  jp SetDefiniteAIDamage


; +damage if player's hand is greater than opponent's
HandPress_DamageBoostEffect:
  call CheckHandSizeGreaterThanOpponents
  ret c
	ld a, 20
	jp AddToDamage

HandPress_AIEffect:
  call HandPress_DamageBoostEffect
  jp SetDefiniteAIDamage


; +10 damage for each Trainer card in opponent's hand
InvadeMind_DamageBoostEffect:
  call SwapTurn
  call CreateHandCardList
  jp c, SwapTurn  ; no cards, early return

  ld c, 0
  ld hl, wDuelTempList
.loop
  ld a, [hli]
  cp $ff  ; terminating byte
  jr z, .tally
  call GetCardIDFromDeckIndex
  call GetCardType
; only count Trainer cards
  cp TYPE_TRAINER
  jr c, .loop
  inc c
  jr .loop

.tally
  call SwapTurn  ; restore turn order
	ld a, c
  call ATimes10
	jp AddToDamage

InvadeMind_AIEffect:
  call InvadeMind_DamageBoostEffect
  jp SetDefiniteAIDamage


; ------------------------------------------------------------------------------
; Based on Prize Cards
; ------------------------------------------------------------------------------


; double damage if the opponent has less Prize cards than the user
DoubleDamageIfMorePrizes_DamageBoostEffect:
	call CheckOpponentHasMorePrizeCardsRemaining
	ret nc  ; opponent Prizes >= user Prizes
	jp DoubleDamage_DamageBoostEffect

DoubleDamageIfMorePrizes_AIEffect:
  call DoubleDamageIfMorePrizes_DamageBoostEffect
  jp SetDefiniteAIDamage


; +10 damage for each Prize the opponent has taken
RageFist_DamageBoostEffect:
	call SwapTurn
	call CountPrizesTaken
	call SwapTurn
	call ATimes10
	jp AddToDamage

RageFist_AIEffect:
	call RageFist_DamageBoostEffect
	jp SetDefiniteAIDamage


; ------------------------------------------------------------------------------
; Based on Discard Pile
; ------------------------------------------------------------------------------

; +10 damage per Pokémon in discard pile (up to 5)
Vengeance_DamageBoostEffect:
	call CreatePokemonCardListFromDiscardPile
	ret c  ; return if there are no Pokémon in discard pile
  ld a, c
  cp 5
  jr c, .cap
  ld a, 5
.cap
	call ATimes10
	jp AddToDamage

Vengeance_AIEffect:
	call Vengeance_DamageBoostEffect
	jp SetDefiniteAIDamage


; +30 damage if 10 or more Items in both discard piles
ToxicWaste_DamageBoostEffect:
	call CreateItemCardListFromDiscardPile
	call CountCardsInDuelTempList
	cp 10
	jr nc, .enough
	ld c, a
	push bc
	call SwapTurn
	call CreateItemCardListFromDiscardPile
	call CountCardsInDuelTempList
	call SwapTurn
	pop bc
	add c
	cp 10
	ret c  ; not enough cards
.enough
  ld a, 30
	jp AddToDamage

ToxicWaste_AIEffect:
	call ToxicWaste_DamageBoostEffect
	jp SetDefiniteAIDamage


; ------------------------------------------------------------------------------
; Based on Play Area
; ------------------------------------------------------------------------------


DoTheWave_DamageBoostEffect:
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	dec a ; don't count arena card
	call ATimes10
	jp AddToDamage

DoTheWave_AIEffect:
  call DoTheWave_DamageBoostEffect
  jp SetDefiniteAIDamage


Swarm_DamageBoostEffect:
	call CheckBenchIsNotFull
	ret nc
	ld a, 10
	jp AddToDamage

Swarm_AIEffect:
  call Swarm_DamageBoostEffect
  jp SetDefiniteAIDamage


; 10 damage for each (C) in the retreat costs of the turn holder's Pokémon
Avalanche_DamageBoostEffect:
  ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
  call GetTurnDuelistVariable
  ld d, a
  ld e, PLAY_AREA_ARENA
  ld c, 0
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld b, a

; go through every Pokémon in the Play Area and boost damage based on retreat cost
.loop_play_area
; check its retreat cost
	ld a, e
	ldh [hTempPlayAreaLocation_ff9d], a
	push bc
	push de
	call GetPlayAreaCardRetreatCost
	pop de
	pop bc
; add to total and store
	add c
	ld c, a
; next Pokémon
  inc e
  dec d
  jr nz, .loop_play_area
; restore backed up variables
	ld a, b
	ldh [hTempPlayAreaLocation_ff9d], a
; tally damage boost
  ld a, c
  or a
  ret z  ; done if zero
  call ATimes10
  jp SetDefiniteDamage

Avalanche_AIEffect:
  call Avalanche_DamageBoostEffect
  jp SetDefiniteAIDamage


; +20 damage for each Evolved Pokémon in Bench
PowerLariat_DamageBoostEffect:
  ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
  call GetTurnDuelistVariable
  dec a
  ret z  ; no Benched Pokémon
  ld d, a
  ld e, PLAY_AREA_BENCH_1
  ld c, 0

; go through every Pokemon in the Play Area and boost damage based on Stage
.loop_play_area
; check its Stage
  ld a, DUELVARS_ARENA_CARD_STAGE
  add e
  call GetTurnDuelistVariable
  or a
  jr z, .next_pkmn  ; it's a BASIC Pokémon
  inc c
.next_pkmn
  inc e
  dec d
  jr nz, .loop_play_area
; tally damage boost
  ld a, c
  or a
  ret z  ; done if zero
  rla            ; a = a * 2
  call ATimes10  ; a = a * 10
  jp SetDefiniteDamage  ; a == c * 20

PowerLariat_AIEffect:
  call PowerLariat_DamageBoostEffect
  jp SetDefiniteAIDamage


; +20 damage for each Nidoran family card on Bench
; assumes card IDS for these Pokémon are sequential
FamilyPower_DamageBoostEffect:
	ld a, DUELVARS_BENCH
	call GetTurnDuelistVariable
	ld c, 0
.loop
	ld a, [hli]
	cp $ff
	jr z, .done
	call GetCardIDFromDeckIndex
	ld a, e
  cp NIDORANF
	jr c, .loop  ; not a Nidoran family card
	cp NIDOKING + 1
	jr nc, .loop  ; not a Nidoran family card
; plus 20 damage
  inc c
	inc c
	jr .loop
.done
; c holds number of Nidoran family bonus found in Play Area
	ld a, c
	call ATimes10
	jp AddToDamage

FamilyPower_AIEffect:
  call FamilyPower_DamageBoostEffect
  jp SetDefiniteAIDamage


; +10 damage for each of the opponent's Benched Pokémon
Rout_DamageBoostEffect:
  ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
  call GetNonTurnDuelistVariable
  dec a  ; don't count arena card
  call ATimes10
  jp AddToDamage

Rout_AIEffect:
  call Rout_DamageBoostEffect
  jp SetDefiniteAIDamage


; +10 damage for each of the opponent's Pokémon with a Pokémon Power
TerrorStrike_DamageBoostEffect:
  call SwapTurn
  ld a, DUELVARS_ARENA_CARD
  call GetTurnDuelistVariable
  ld c, 0
.loop_play_area
  ld a, [hli]
  cp $ff
  jr z, .done
  call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Atk1Category]
	cp POKEMON_POWER
  jr nz, .loop_play_area
  inc c
  jr .loop_play_area
.done
  call SwapTurn
  ld a, c
  ; add a  ; x20
  call ATimes10
  jp AddToDamage

TerrorStrike_AIEffect:
  call TerrorStrike_DamageBoostEffect
  jp SetDefiniteAIDamage


; ------------------------------------------------------------------------------
; Based on Defending Pokémon
; ------------------------------------------------------------------------------


; return in a 10x damage per Energy in the Opponent's Retreat Cost.
_DamagePerOpponentRetreatCost:
	call SwapTurn
	xor a ; PLAY_AREA_ARENA
	ldh [hTempPlayAreaLocation_ff9d], a
	call GetPlayAreaCardRetreatCost  ; retreat cost in a
	call SwapTurn
	jp ATimes10


; +10 damage per retreat cost of opponent
Constrict_DamageBoostEffect:
	call _DamagePerOpponentRetreatCost
	jp AddToDamage

; this runs before applying the retreat cost increase, so add 10
Constrict_AIEffect:
	call _DamagePerOpponentRetreatCost
	add 10
	call AddToDamage
	jp SetDefiniteAIDamage


; ------------------------------------------------------------------------------
; Based on Status Conditions
; ------------------------------------------------------------------------------

; bonus damage for each status condition on the Defending Pokémon
ReactivePoison_DamageBoostEffect:
  ld a, DUELVARS_ARENA_CARD_STATUS
  call GetNonTurnDuelistVariable
	or a
	ret z  ; no status
	ld bc, $00
; confusion, sleep, paralysis
  and CNF_SLP_PRZ
  jr z, .poison
  ld b, 20
.poison
	ld a, [hl]
  and DOUBLE_POISONED
  jr z, .burn
  ld c, 20
.burn
	ld a, [hl]
  and BURNED
	ld a, 0
  jr z, .tally
  ld a, 20
.tally
	add b
	add c
  jp AddToDamage

ReactivePoison_AIEffect:
  call ReactivePoison_DamageBoostEffect
  jp SetDefiniteAIDamage


; +20 damage if the Defending Pokémon has a status condition
Pester_DamageBoostEffect:
  call CheckDefendingPokemonHasStatus
  ret c
  ld a, 20
  jp AddToDamage

Pester_AIEffect:
  call Pester_DamageBoostEffect
  jp SetDefiniteAIDamage


; +20 damage if the Defending Pokémon is Poisoned
DeadlyPoison_DamageBoostEffect:
  ld a, DUELVARS_ARENA_CARD_STATUS
  call GetNonTurnDuelistVariable
  and DOUBLE_POISONED
  ret z  ; not Poisoned
  ld a, 20
  jp AddToDamage

DeadlyPoison_AIEffect:
  call DeadlyPoison_DamageBoostEffect
  jp SetDefiniteAIDamage


; ------------------------------------------------------------------------------
; Based on Damage Counters
; ------------------------------------------------------------------------------

SwallowUp_DamageBoostEffect:
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	ld e, a
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	cp e
	ld a, 50
	jp c, AddToDamage
	ret

SwallowUp_AIEffect:
	call SwallowUp_DamageBoostEffect
	jp SetDefiniteAIDamage


ChopDown_DamageBoostEffect:
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	ld e, a
	ld a, DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	cp e
	jp c, DoubleDamage_DamageBoostEffect
	ret

ChopDown_AIEffect:
	call ChopDown_DamageBoostEffect
	jp SetDefiniteAIDamage


KarateChop_DamageSubtractionEffect:
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	jp SubtractFromDamageCapZero

KarateChop_AIEffect:
	call KarateChop_DamageSubtractionEffect
	jp SetDefiniteAIDamage


; double damage if user is damaged
DoubleDamageIfUserIsDamaged_DamageBoostEffect:
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
  or a
  ret z  ; not damaged
	jp DoubleDamage_DamageBoostEffect

DoubleDamageIfUserIsDamaged_AIEffect:
  call DoubleDamageIfUserIsDamaged_DamageBoostEffect
  jp SetDefiniteAIDamage


; add damage taken to damage output
Rage_DamageBoostEffect:
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	jp AddToDamage

Rage_AIEffect:
	call Rage_DamageBoostEffect
	jp SetDefiniteAIDamage



; set damage output equal to damage taken
Flail_HPCheck:
  ld e, PLAY_AREA_ARENA
  call GetCardDamageAndMaxHP
  jp SetDefiniteDamage

Flail_AIEffect:
	call Flail_HPCheck
	jp SetDefiniteAIDamage


; add damage of Defending card to damage output
PsychicAssault_DamageBoostEffect:
	call SwapTurn
	ld e, PLAY_AREA_ARENA
	call GetCardDamageAndMaxHP
	call SwapTurn
	jp AddToDamage

PsychicAssault_AIEffect:
  call PsychicAssault_DamageBoostEffect
  jp SetDefiniteAIDamage


; +10 damage for each damaged Benched Pokémon on turn holder's play area
VengefulHorn_DamageBoostEffect:
  ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
  call GetTurnDuelistVariable
	dec a  ; discount arena
	ret z  ; no Bench
  ld d, a
  ld e, PLAY_AREA_BENCH_1
  ld c, 0
.loop_play_area
  ; input in e
  push bc
  call GetCardDamageAndMaxHP
  pop bc
  or a
  jr z, .next_pkmn  ; no damage
  inc c
.next_pkmn
  inc e
  dec d
  jr nz, .loop_play_area
; tally damage boost
  ld a, c
  call ATimes10
  jp AddToDamage

VengefulHorn_AIEffect:
  call VengefulHorn_DamageBoostEffect
  jp SetDefiniteAIDamage


; add 20 damage if the Defending Pokémon has damage counters
Rend_DamageBoostEffect:
	call CheckOpponentArenaPokemonHasAnyDamage
	ret c  ; no damage
	ld a, 20
	jp AddToDamage

Rend_AIEffect:
	call Rend_DamageBoostEffect
	jp SetDefiniteAIDamage


; add 20 damage if the Defending Pokémon has no damage counters
Frustration_DamageBoostEffect:
	call CheckOpponentArenaPokemonHasAnyDamage
	ret nc  ; is damaged
	ld a, 20
	jp AddToDamage

Frustration_AIEffect:
	call Frustration_DamageBoostEffect
	jp SetDefiniteAIDamage


; ------------------------------------------------------------------------------
; Miscellaneous
; ------------------------------------------------------------------------------

; +30 damage if a card was selected (hTemp_ffa0 is not $ff)
IfSelectedCard30BonusDamage_DamageBoostEffect:
	ld d, 30
	; jr IfSelectedCardBonusDamage_DamageBoostEffect
	; fallthrough

; +d damage if a card was selected (hTemp_ffa0 is not $ff)
; input:
;   d: bonus damage to add
IfSelectedCardBonusDamage_DamageBoostEffect:
	ldh a, [hTemp_ffa0]
	cp $ff
	ret z
	ld a, d
	jp AddToDamage


; double damage if some stored value is true
DoubleDamageIfCondition_DamageBoostEffect:
	ldh a, [hTemp_ffa0]
	or a
	ret z
	jp DoubleDamage_DamageBoostEffect

DoubleDamageIfCondition_AIEffect:
	ld a, [wDamage]
	ld d, a  ; min damage
	add a
	ld e, a  ; max damage
	ld a, d
	; srl a
	; add d    ; avg damage
	jp SetExpectedAIDamage


; bonus damage if the Pokémon became Active this turn
IfActiveThisTurn10BonusDamage_DamageBoostEffect:
	ld d, 10
	jr IfActiveThisTurnBonusDamage_DamageBoostEffect

IfActiveThisTurn10BonusDamage_AIEffect:
  call IfActiveThisTurn10BonusDamage_DamageBoostEffect
  jp SetDefiniteAIDamage


; bonus damage if the Pokémon became Active this turn
IfActiveThisTurn20BonusDamage_DamageBoostEffect:
	ld d, 20
	jr IfActiveThisTurnBonusDamage_DamageBoostEffect

IfActiveThisTurn20BonusDamage_AIEffect:
  call IfActiveThisTurn20BonusDamage_DamageBoostEffect
  jp SetDefiniteAIDamage


; bonus damage if the Pokémon became Active this turn
IfActiveThisTurn30BonusDamage_DamageBoostEffect:
	ld d, 30
	jr IfActiveThisTurnBonusDamage_DamageBoostEffect

IfActiveThisTurn30BonusDamage_AIEffect:
  call IfActiveThisTurn30BonusDamage_DamageBoostEffect
  jp SetDefiniteAIDamage


; bonus damage if the Pokémon became Active this turn
IfActiveThisTurn40BonusDamage_DamageBoostEffect:
	ld d, 40
	jr IfActiveThisTurnBonusDamage_DamageBoostEffect

IfActiveThisTurn40BonusDamage_AIEffect:
  call IfActiveThisTurn40BonusDamage_DamageBoostEffect
  jp SetDefiniteAIDamage


; bonus damage if the Pokémon became Active this turn
IfActiveThisTurn50BonusDamage_DamageBoostEffect:
	ld d, 50
	jr IfActiveThisTurnBonusDamage_DamageBoostEffect

IfActiveThisTurn50BonusDamage_AIEffect:
  call IfActiveThisTurn50BonusDamage_DamageBoostEffect
  jp SetDefiniteAIDamage


; bonus damage if the Pokémon became Active this turn
; input:
;   d: amount of bonus damage
IfActiveThisTurnBonusDamage_DamageBoostEffect:
	call CheckEnteredActiveSpotThisTurn
	ret c  ; did not move to active spot this turn
	ld a, d
	jp AddToDamage


AquaticRescue_DamageMultiplierEffect:
	xor a
	call SetDefiniteDamage
	ld a, CARDTEST_POKEMON
	call CountMatchingCardsInTempList
	ret z  ; none
	call ATimes10
	call SetDefiniteDamage
	ld a, ATK_ANIM_HIT
	ld [wLoadedAttackAnimation], a
	ret


AquaticRescue_AIEffect:
	call CreatePokemonCardListFromDiscardPile
	jr nc, .damage
; no damage
	xor a
	lb de, 0, 0
	jp SetExpectedAIDamage
.damage
	ld a, 20
	lb de, 10, 30
	jp SetExpectedAIDamage


Rototiller_DamageBoostEffect:
	xor a
	call SetDefiniteDamage
	ld hl, hTempList
.loop
	ld a, [hli]
	cp $ff
	jr z, .check_damage
	call .BoostIfPokemonOrEnergy
	jr .loop
; switch animation if this attack deals damage
.check_damage
	ld a, [wDamage]
	or a
	ret z
	ld a, ATK_ANIM_HIT
	ld [wLoadedAttackAnimation], a
	ret

; input:
;   a: deck index of selected card
.BoostIfPokemonOrEnergy:
	call GetCardIDFromDeckIndex  ; preserves af, hl, bc
	call GetCardType  ; preserves hl, bc
	cp TYPE_TRAINER
	ret nc
; Pokémon or Energy card
	ld a, 10
	jp AddToDamage  ; preserves hl


Rototiller_AIEffect:
	call CreateEnergyCardListFromDiscardPile_AllEnergy
	jr nc, .damage
	call CreatePokemonCardListFromDiscardPile
	jr nc, .damage
; no damage
	xor a
	lb de, 0, 0
	jp SetExpectedAIDamage
.damage
	ld a, 20
	lb de, 10, 30
	jp SetExpectedAIDamage
