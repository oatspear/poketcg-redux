; [wDamage] += a
AddToDamage:
	push hl
	ld l, a
	ld a, [wDamage]
	add l
	ld [wDamage], a
	pop hl
	ret nc  ; no overflow
	ld a, MAX_DAMAGE
	ld [wDamage], a
	ret

; [wDamage] -= a
SubtractFromDamage:
	push hl
	ld l, a
	ld a, [wDamage]
	sub l
	ld [wDamage], a
	pop hl
	ret nc  ; no underflow
	xor a
	ld [wDamage], a
	ret


CapMaximumDamage_DE:
	ld a, d
	or a
	ret z  ; no overflow
	ld de, MAX_DAMAGE
	ret


CapMinimumDamage_DE:
	ld a, d
	or a
	ret z  ; no underflow
	ld de, 0
	ret


; Weakness doubles damage if de < 30.
; Otherwise, it adds 20 damage.
; preserves: bc
ApplyWeaknessToDamage_DE:
IF WEAKNESS_IS_CAPPED
	ld a, d
	or a
	jr nz, .add_20
; d is zero
	ld a, e
	cp 20
	jr nc, .add_20  ; damage >= 20
; double damage if de < 20
	add e
	ld e, a
	ret  ; no overflow, a <= 40
ENDC
.add_20
	ld hl, 20
	; fallthrough

; Adds the value in hl to damage at de.
; preserves: bc
AddToDamage_DE:
	add hl, de
	ld e, l
	ld d, h
	ret


; Subtract 10 from damage at de.
; preserves: bc
ReduceDamageBy10_DE:
	ld hl, -10
	jr AddToDamage_DE


; Resistance subtracts 20 damage, but always ensures at least 10 damage.
; preserves: bc
ApplyResistanceToDamage_DE:
IF RESISTANCE_IS_CAPPED
	ld a, d
	or a
	jr nz, ReduceDamageBy20_DE  ; very high damage
; d is zero
	ld a, e
	cp 30 + 1
	jr nc, ReduceDamageBy20_DE  ; damage > 30
; just set damage to 10 for damage <= 30
	ld e, 10
	ret
ELSE
	; fallthrough to ReduceDamageBy20_DE
ENDC

; Subtract 20 from damage at de.
; preserves: bc
ReduceDamageBy20_DE:
	ld hl, -20
	jr AddToDamage_DE

; Subtract 30 from damage at de.
; preserves: bc
ReduceDamageBy30_DE:
	ld hl, -30
	jr AddToDamage_DE

; Halves the amount of damage at de.
; preserves: bc
HalveDamage_DE:
	sla d
	rr e
	bit 0, e
	ret z
	ld hl, -5
	jr AddToDamage_DE


; Subtracts the (positive) value in hl from damage at de.
; preserves: bc
SubtractFromDamage_DE:
	ld a, e
	sub l
	ld e, a
	ld a, d
	sbc h
	ld d, a
	ret
