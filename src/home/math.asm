; returns a *= 10
ATimes10:
	push de
	ld e, a
	add a
	add a
	add e
	add a
	pop de
	ret

; returns hl *= 10
HLTimes10:
	push de
	ld l, a
	ld e, a
	ld h, $00
	ld d, h
	add hl, hl
	add hl, hl
	add hl, de
	add hl, hl
	pop de
	ret

; returns h * l in hl
HtimesL:
	push de
	ld a, h
	ld e, l
	ld d, $0
	ld l, d
	ld h, d
	jr .asm_887
.asm_882
	add hl, de
.asm_883
	sla e
	rl d
.asm_887
	srl a
	jr c, .asm_882
	jr nz, .asm_883
	pop de
	ret


; returns a /= 10
; returns carry if a % 10 >= 5
ADividedBy10:
	push de
	ld e, -1
.asm_c62
	inc e
	sub 10
	jr nc, .asm_c62
	add 5
	ld a, e
	pop de
	ret


; returns a /= 2 rounded up
HalfARoundedUp:
	srl a
	bit 0, a
	ret z  ; rounded
	add 5  ; round up to nearest 10
	ret


; returns a /= 2 rounded down
HalfARoundedDown:
	srl a
	bit 0, a
	ret z  ; rounded
	sub 5  ; round down to nearest 10
	ret


; Doubles the current value at de
DoubleDE:
	ld a, e
	or d
	ret z
	sla e
	rl d
	ret


; cp de, bc
CompareDEtoBC:
	ld a, d
	cp b
	ret nz
	ld a, e
	cp c
	ret


PowersOf2:
	db $01, $02, $04, $08, $10, $20, $40, $80

; uses the PowersOf2 table to return in a the a-th power of 2
; input: a = 0-7
; preserves: bc
GetPowerOf2:
	ld e, a
	ld d, 0
	ld hl, PowersOf2
	add hl, de
	ld a, [hl]
	ret
