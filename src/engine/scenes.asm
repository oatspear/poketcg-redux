; input:
; a = scene ID (SCENE_* constant)
; b = base X position of scene in tiles
; c = base Y position of scene in tiles
_LoadScene:
	push hl
	push bc
	push de
	ld e, a
	ld a, [wCurTilemap]
	push af
	ld a, [wd291]
	push af
	ld a, e
	push bc
	push af
	ld a, b
	add a
	add a
	add a
	add $08
	ld [wSceneBaseX], a
	ld a, c
	add a
	add a
	add a
	add $10
	ld [wSceneBaseY], a
	pop af
	add a
	ld c, a
	ld b, 0
	ld hl, ScenePointers
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, %11100100
	ld [wBGP], a
	ld a, [hli]
	push af ; palette
	xor a
	ld [wd4ca], a
	ld a, [hli]
	ld [wd4cb], a ; palette offset
	ld [wd291], a ; palette offset
	pop af ; palette
	farcall SetBGPAndLoadedPal ; load palette
	ld a, [hli]
	ld [wCurTilemap], a
	pop bc
	push bc
	farcall LoadTilemap_ToVRAM
	pop bc ; base x,y
	ld a, [hli]
	ld [wd4ca], a ; tile offset
	ld a, [hli]
	ld [wd4cb], a ; vram0 or vram1
	farcall LoadTilesetGfx
.next_sprite
	ld a, [hli]
	or a
	jr z, .done ; no sprite
	ld [wSceneSprite], a
	ld a, [hli]
	push af ; sprite palette
	xor a
	ld [wd4ca], a
	ld a, [hli]
	ld [wd4cb], a ; palette offset
	pop af ; sprite palette
	farcall LoadPaletteData
.next_animation
	ld a, [hli]
	or a
	jr z, .next_sprite
	dec hl
	ld a, [hli]
	ld [wSceneSpriteAnimation], a
	ld a, [wSceneSprite]
	call CreateSpriteAndAnimBufferEntry
	ld a, [wWhichSprite]
	ld [wSceneSpriteIndex], a
	push hl
	ld c, SPRITE_ANIM_COORD_X
	call GetSpriteAnimBufferProperty
	ld e, l
	ld d, h
	pop hl
	ld a, [wSceneBaseX]
	add [hl]
	ld [de], a
	inc hl
	inc de
	ld a, [wSceneBaseY]
	add [hl]
	ld [de], a
	inc hl
	ld a, [wSceneSpriteAnimation]
	cp $ff
	call nz, StartSpriteAnimation
.no_animation
	jr .next_animation
.done
	pop af
	ld [wd291], a
	pop af
	ld [wCurTilemap], a
	pop de
	pop bc
	pop hl
	ret

INCLUDE "data/scenes.asm"

_DrawPortrait::
	ld a, [wd291]
	push af
	push de
	push bc
	lb de, $d0, $07
	ld a, [wCurTilemap]
	cp TILEMAP_PLAYER
	jr z, .asm_12fd9
	lb de, $a0, $06
.asm_12fd9
	ld a, e
	ld [wd291], a
	farcall LoadTilemap_ToVRAM
	ld a, [wd61e]
	add a
	ld c, a
	ld b, $00
	ld hl, PortraitGfxData
	add hl, bc
	ld a, [hli]
	push hl
	ld [wCurTileset], a
	ld a, d
	ld [wd4ca], a
	xor a
	ld [wd4cb], a
	farcall LoadTilesetGfx
	pop hl
	xor a
	ld [wd4ca], a
	ld a, [wd291]
	ld [wd4cb], a
	ld a, [hli]
	farcall SetBGPAndLoadedPal
	pop bc
	pop de
	pop af
	ld [wd291], a
	ret

PortraitGfxData:
	table_width 2, PortraitGfxData
	db TILESET_PLAYER, PALETTE_119
	db TILESET_PLAYER, PALETTE_119
	db TILESET_RONALD, PALETTE_121
	db TILESET_SAM, PALETTE_122
	db TILESET_IMAKUNI, PALETTE_123
	db TILESET_NIKKI, PALETTE_124
	db TILESET_RICK, PALETTE_125
	db TILESET_KEN, PALETTE_126
	db TILESET_AMY, PALETTE_127
	db TILESET_ISAAC, PALETTE_128
	db TILESET_MITCH, PALETTE_129
	db TILESET_GENE, PALETTE_130
	db TILESET_MURRAY, PALETTE_131
	db TILESET_COURTNEY, PALETTE_132
	db TILESET_STEVE, PALETTE_133
	db TILESET_JACK, PALETTE_134
	db TILESET_ROD, PALETTE_135
	db TILESET_JOSEPH, PALETTE_136
	db TILESET_DAVID, PALETTE_137
	db TILESET_ERIK, PALETTE_138
	db TILESET_JOHN, PALETTE_139
	db TILESET_ADAM, PALETTE_140
	db TILESET_JONATHAN, PALETTE_141
	db TILESET_JOSHUA, PALETTE_142
	db TILESET_NICHOLAS, PALETTE_143
	db TILESET_BRANDON, PALETTE_144
	db TILESET_MATTHEW, PALETTE_145
	db TILESET_RYAN, PALETTE_146
	db TILESET_ANDREW, PALETTE_147
	db TILESET_CHRIS, PALETTE_148
	db TILESET_MICHAEL, PALETTE_149
	db TILESET_DANIEL, PALETTE_150
	db TILESET_ROBERT, PALETTE_151
	db TILESET_BRITTANY, PALETTE_152
	db TILESET_KRISTIN, PALETTE_153
	db TILESET_HEATHER, PALETTE_154
	db TILESET_SARA, PALETTE_155
	db TILESET_AMANDA, PALETTE_156
	db TILESET_JENNIFER, PALETTE_157
	db TILESET_JESSICA, PALETTE_158
	db TILESET_STEPHANIE, PALETTE_159
	db TILESET_AARON, PALETTE_160
	db TILESET_PLAYER, PALETTE_120
	assert_table_length NUM_PICS

LoadBoosterGfx:
	push hl
	push bc
	push de
	ld e, a
	ld a, [wCurTilemap]
	push af
	push bc
	ld a, e
	call _LoadScene
	call FlushAllPalettes
	call SetBoosterLogoOAM
	pop bc
	pop af
	ld [wCurTilemap], a
	pop de
	pop bc
	pop hl
	ret

SetBoosterLogoOAM:
	push hl
	push bc
	push de
	push bc
	xor a
	ld [wd4cb], a
	ld [wd4ca], a
	ld a, SPRITE_BOOSTER_PACK_OAM
	farcall Func_8025b
	pop bc
	call ZeroObjectPositions
	ld hl, BoosterLogoOAM
	ld c, [hl]
	inc hl
.oam_loop
	push bc
	ldh a, [hSCX]
	ld d, a
	ldh a, [hSCY]
	ld e, a
	ld a, [wSceneBaseY]
	sub e
	add [hl]
	ld e, a
	inc hl
	ld a, [wSceneBaseX]
	sub d
	add [hl]
	ld d, a
	inc hl
	ld a, [wd61f]
	add [hl]
	ld c, a
	inc hl
	ld b, [hl]
	inc hl
	call SetOneObjectAttributes
	pop bc
	dec c
	jr nz, .oam_loop
	ld hl, wVBlankOAMCopyToggle
	inc [hl]
	pop de
	pop bc
	pop hl
	ret

BoosterLogoOAM:
	db $20
	db $00, $00, $00, $00
	db $00, $08, $01, $00
	db $00, $10, $02, $00
	db $00, $18, $03, $00
	db $00, $20, $04, $00
	db $00, $28, $05, $00
	db $00, $30, $06, $00
	db $00, $38, $07, $00
	db $08, $00, $10, $00
	db $08, $08, $11, $00
	db $08, $10, $12, $00
	db $08, $18, $13, $00
	db $08, $20, $14, $00
	db $08, $28, $15, $00
	db $08, $30, $16, $00
	db $08, $38, $17, $00
	db $10, $00, $08, $00
	db $10, $08, $09, $00
	db $10, $10, $0a, $00
	db $10, $18, $0b, $00
	db $10, $20, $0c, $00
	db $10, $28, $0d, $00
	db $10, $30, $0e, $00
	db $10, $38, $0f, $00
	db $18, $00, $18, $00
	db $18, $08, $19, $00
	db $18, $10, $1a, $00
	db $18, $18, $1b, $00
	db $18, $20, $1c, $00
	db $18, $28, $1d, $00
	db $18, $30, $1e, $00
	db $18, $38, $1f, $00
