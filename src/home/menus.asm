; similar to HandleMenuInput, but conveniently returns parameters related to the
; state of the list in a, d, and e if A or B were pressed. also returns carry
; if A or B were pressed, nc otherwise. returns -1 in a if B was pressed.
; used for example in the Hand card list and Discard Pile card list screens.
HandleCardListInput:
	call HandleMenuInput
	ret nc
	ld a, [wListScrollOffset]
	ld d, a
	ld a, [wCurMenuItem]
	ld e, a
	ldh a, [hCurMenuItem]
	scf
	ret

; initializes parameters for a menu, given the 8 bytes starting at hl,
; which are loaded to the following addresses:
;	wCursorXPosition, wCursorYPosition, wYDisplacementBetweenMenuItems, wNumMenuItems,
;	wCursorTile, wTileBehindCursor, wMenuFunctionPointer.
; also sets the current menu item (wCurMenuItem) to the one specified in register a.
InitializeMenuParameters:
	ld [wCurMenuItem], a
	ldh [hCurMenuItem], a
	ld de, wCursorXPosition
	ld b, wMenuFunctionPointer + $2 - wCursorXPosition
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
	xor a
	ld [wCursorBlinkCounter], a
	ret

; returns with the carry flag set if A or B were pressed
; returns a = 0 if A was pressed, a = -1 if B was pressed
; note: return values still subject to those of the function at [wMenuFunctionPointer] if any
HandleMenuInput:
	xor a
	ld [wRefreshMenuCursorSFX], a
	ldh a, [hDPadHeld]
	or a
	jr z, .up_down_done
	ld b, a
	ld a, [wNumMenuItems]
	ld c, a
	ld a, [wCurMenuItem]
	bit D_UP_F, b
	jr z, .not_up
	dec a
	bit 7, a
	jr z, .handle_up_or_down
	ld a, [wNumMenuItems]
	dec a ; wrapping around, so load the bottommost item
	jr .handle_up_or_down
.not_up
	bit D_DOWN_F, b
	jr z, .up_down_done
	inc a
	cp c
	jr c, .handle_up_or_down
	xor a ; wrapping around, so load the topmost item
.handle_up_or_down
	push af
	ld a, $1
	ld [wRefreshMenuCursorSFX], a ; buffer sound for up/down
	call EraseCursor
	pop af
	ld [wCurMenuItem], a
	xor a
	ld [wCursorBlinkCounter], a
.up_down_done
	ld a, [wCurMenuItem]
	ldh [hCurMenuItem], a
	ld hl, wMenuFunctionPointer ; call the function if non-0 (periodically)
	ld a, [hli]
	or [hl]
	jr z, .check_A_or_B
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ldh a, [hCurMenuItem]
	call CallHL
	jr nc, RefreshMenuCursor_CheckPlaySFX
.A_pressed_draw_cursor
	call DrawCursor2
.A_pressed
	call PlayOpenOrExitScreenSFX
	ld a, [wCurMenuItem]
	ld e, a
	ldh a, [hCurMenuItem]
	scf
	ret
.check_A_or_B
	ldh a, [hKeysPressed]
	and A_BUTTON | B_BUTTON
	jr z, RefreshMenuCursor_CheckPlaySFX
	and A_BUTTON
	jr nz, .A_pressed_draw_cursor
	; B button pressed
	ld a, [wCurMenuItem]
	ld e, a
	ld a, $ff
	ldh [hCurMenuItem], a
	call PlayOpenOrExitScreenSFX
	scf
	ret

; plays an "open screen" sound (SFX_02) if [hCurMenuItem] != 0xff
; plays an "exit screen" sound (SFX_03) if [hCurMenuItem] == 0xff
PlayOpenOrExitScreenSFX:
	push af
	ldh a, [hCurMenuItem]
	inc a
	jr z, .play_exit_sfx
	ld a, SFX_02
	jr .play_sfx
.play_exit_sfx
	ld a, SFX_03
.play_sfx
	call PlaySFX
	pop af
	ret

; called once per frame when a menu is open
; play the sound effect at wRefreshMenuCursorSFX if non-0 and blink the
; cursor when wCursorBlinkCounter hits 16 (i.e. every 16 frames)
RefreshMenuCursor_CheckPlaySFX:
	ld a, [wRefreshMenuCursorSFX]
	or a
	jr z, RefreshMenuCursor
	call PlaySFX
;	fallthrough

RefreshMenuCursor:
	ld hl, wCursorBlinkCounter
	ld a, [hl]
	inc [hl]
; blink the cursor every 16 frames
	and $f
	ret nz
	ld a, [wCursorTile]
	bit 4, [hl]
	jr z, DrawCursor
;	fallthrough

; set the tile at [wCursorXPosition],[wCursorYPosition] to [wTileBehindCursor]
EraseCursor:
	ld a, [wTileBehindCursor]
;	fallthrough

; set the tile at [wCursorXPosition],[wCursorYPosition] to a
DrawCursor:
	ld c, a
	ld a, [wYDisplacementBetweenMenuItems]
	ld l, a
	ld a, [wCurMenuItem]
	ld h, a
	call HtimesL
	ld a, l
	ld hl, wCursorXPosition
	ld d, [hl]
	inc hl
	add [hl]
	ld e, a
	call AdjustCoordinatesForBGScroll
	ld a, c
	ld c, e
	ld b, d
	call WriteByteToBGMap0
	or a
	ret

; set the tile at [wCursorXPosition],[wCursorYPosition] to [wCursorTile]
DrawCursor2:
	ld a, [wCursorTile]
	jr DrawCursor


; translate the TYPE_* constant in wLoadedCard1Type to an index for CardSymbolTable
CardTypeToSymbolID:
	ld a, [wLoadedCard1Type]
	cp TYPE_TRAINER
	jr nc, .trainer_card
	cp TYPE_ENERGY
	jr c, .pokemon_card
	; energy card
	and 7 ; convert energy constant to type constant
	ret
.trainer_card
	ld a, 11
	ret
.pokemon_card
	ld a, [wLoadedCard1Stage] ; different symbol for each evolution stage
	add 8
	ret

; return the entry in CardSymbolTable of the TYPE_* constant in wLoadedCard1Type
; also return the first byte of said entry (starting tile number) in a
GetCardSymbolData:
	call CardTypeToSymbolID
	add a
	ld c, a
	ld b, 0
	ld hl, CardSymbolTable
	add hl, bc
	ld a, [hl]
	ret

; draw, at de, the 2x2 tile card symbol associated to the TYPE_* constant in wLoadedCard1Type
DrawCardSymbol:
	push hl
	push de
	push bc
	call GetCardSymbolData
	dec d
	dec d
	dec e
	ld a, [wConsole]
	cp CONSOLE_CGB
	jr nz, .tiles
	; CGB-only attrs (palette)
	push hl
	inc hl
	ld a, [hl]
	lb bc, 2, 2
	lb hl, 0, 0
	call BankswitchVRAM1
	call FillRectangle
	call BankswitchVRAM0
	pop hl
.tiles
	ld a, [hl]
	lb hl, 1, 2
	lb bc, 2, 2
	call FillRectangle
	pop bc
	pop de
	pop hl
	ret

CardSymbolTable:
; starting tile number, cgb palette (grey, yellow/red, green/blue, pink/orange)
	db $e0, $01 ; TYPE_ENERGY_FIRE
	db $e4, $02 ; TYPE_ENERGY_GRASS
	db $e8, $01 ; TYPE_ENERGY_LIGHTNING
	db $ec, $02 ; TYPE_ENERGY_WATER
	db $f0, $03 ; TYPE_ENERGY_PSYCHIC
	db $f4, $03 ; TYPE_ENERGY_FIGHTING
	db $f8, $00 ; TYPE_ENERGY_DARKNESS
	db $fc, $02 ; TYPE_ENERGY_DOUBLE_COLORLESS
	db $d0, $02 ; TYPE_PKMN_*, Basic
	db $d4, $02 ; TYPE_PKMN_*, Stage 1
	db $d8, $01 ; TYPE_PKMN_*, Stage 2
	db $dc, $02 ; TYPE_TRAINER

; copy the name and level of the card at wLoadedCard1 to wDefaultText
; a = length in number of tiles (the resulting string will be padded with spaces to match it)
CopyCardNameAndLevel:
	farcall _CopyCardNameAndLevel
	ret

; sets cursor parameters for navigating in a text box, but using
; default values for the cursor tile (SYM_CURSOR_R) and the tile behind it (SYM_SPACE).
; d,e: coordinates of the cursor
SetCursorParametersForTextBox_Default:
	lb bc, SYM_CURSOR_R, SYM_SPACE ; cursor tile, tile behind cursor
	call SetCursorParametersForTextBox
;	fallthrough

; wait until A or B is pressed.
; return carry if A is pressed, nc if B is pressed. erase the cursor either way
WaitForButtonAorB:
	call IsCinematicDuel
	jr nc, _WaitForButtonAorB
; cinematic duel (delayed text)
	ld d, 48
.wait_A_or_B_loop
	call DoFrame
	push de
	call RefreshMenuCursor
	pop de
	dec d
	jr nz, .wait_A_or_B_loop
	jr _WaitForButtonAorB.a_pressed

_WaitForButtonAorB:
	call DoFrame
	call RefreshMenuCursor
	ldh a, [hKeysPressed]
	bit A_BUTTON_F, a
	jr nz, .a_pressed
	bit B_BUTTON_F, a
	jr z, _WaitForButtonAorB
	call EraseCursor
	scf
	ret
.a_pressed
	call EraseCursor
	or a
	ret

; sets cursor parameters for navigating in a text box
; d,e: coordinates of the cursor
; b,c: tile numbers of the cursor and of the tile behind it
SetCursorParametersForTextBox:
	xor a
	ld hl, wCurMenuItem
	ld [hli], a
	ld [hl], d ; wCursorXPosition
	inc hl
	ld [hl], e ; wCursorYPosition
	inc hl
	ld [hl], 0 ; wYDisplacementBetweenMenuItems
	inc hl
	ld [hl], 1 ; wNumMenuItems
	inc hl
	ld [hl], b ; wCursorTile
	inc hl
	ld [hl], c ; wTileBehindCursor
	ld [wCursorBlinkCounter], a
	ret

; draw a 20x6 text box aligned to the bottom of the screen,
; print the text at hl without letter delay, and wait for A or B pressed
DrawWideTextBox_PrintTextNoDelay_Wait:
	call DrawWideTextBox_PrintTextNoDelay
	jp WaitForWideTextBoxInput

; draw a 20x6 text box aligned to the bottom of the screen
; and print the text at hl without letter delay
DrawWideTextBox_PrintTextNoDelay:
	push hl
	call DrawWideTextBox
	ld a, 19
	jr DrawTextBox_PrintTextNoDelay

; draw a 12x6 text box aligned to the bottom left of the screen
; and print the text at hl without letter delay
DrawNarrowTextBox_PrintTextNoDelay:
	push hl
	call DrawNarrowTextBox
	ld a, 11
;	fallthrough

DrawTextBox_PrintTextNoDelay:
	lb de, 1, 14
	call AdjustCoordinatesForBGScroll
	call InitTextPrintingInTextbox
	pop hl
	ld a, l
	or h
	jp nz, PrintTextNoDelay
	ld hl, wDefaultText
	jp ProcessText

; draw a 20x6 text box aligned to the bottom of the screen
; and print the text at hl with letter delay
DrawWideTextBox_PrintText:
	push hl
	call DrawWideTextBox
	ld a, 19
	lb de, 1, 14
	call AdjustCoordinatesForBGScroll
	call InitTextPrintingInTextbox
	call EnableLCD
	pop hl
	jp PrintText

; draw a 12x6 text box aligned to the bottom left of the screen
DrawNarrowTextBox:
	lb de, 0, 12
	lb bc, 12, 6
	call AdjustCoordinatesForBGScroll
	call DrawRegularTextBox
	ret

; draw a 12x6 text box aligned to the bottom left of the screen,
; print the text at hl without letter delay, and wait for A or B pressed
DrawNarrowTextBox_WaitForInput:
	call DrawNarrowTextBox_PrintTextNoDelay
	xor a
	ld hl, NarrowTextBoxMenuParameters
	call InitializeMenuParameters
	call EnableLCD
.wait_A_or_B_loop
	call DoFrame
	call RefreshMenuCursor
	ldh a, [hKeysPressed]
	and A_BUTTON | B_BUTTON
	jr z, .wait_A_or_B_loop
	ret

NarrowTextBoxMenuParameters:
	db 10, 17 ; cursor x, cursor y
	db 1 ; y displacement between items
	db 1 ; number of items
	db SYM_CURSOR_D ; cursor tile number
	db SYM_BOX_BOTTOM ; tile behind cursor
	dw NULL ; function pointer if non-0


IsCinematicDuel:
	ld a, [wIsInDuel]
	or a
	ret z
; currently in a duel
	ld a, [wAnimationsDisabled]
	and DEBUG_AI_VS_AI_F
	ret z
; it is an AI vs AI duel
	ld a, [wTextSpeed]
	cp TEXT_SPEED_5
	ret z
; cinematic duel (delayed text)
	scf
	ret


; draw a 20x6 text box aligned to the bottom of the screen
DrawWideTextBox:
	lb de, 0, 12
	lb bc, 20, 6
	call AdjustCoordinatesForBGScroll
	jp DrawRegularTextBox

; draw a 20x6 text box aligned to the bottom of the screen,
; print the text at hl with letter delay, and wait for A or B pressed
DrawWideTextBox_WaitForInput:
	call DrawWideTextBox_PrintText
;	fallthrough

; wait for A or B to be pressed on a wide (20x6) text box
WaitForWideTextBoxInput:
	call IsCinematicDuel
	jr nc, _WaitForWideTextBoxInput
; cinematic duel (delayed text)
	xor a
	ld hl, WideTextBoxMenuParameters
	call InitializeMenuParameters
	call EnableLCD
	ld d, 48
.wait_A_or_B_loop
	call DoFrame
	push de
	call RefreshMenuCursor
	pop de
	dec d
	jr nz, .wait_A_or_B_loop
	jp EraseCursor

_WaitForWideTextBoxInput:
	xor a
	ld hl, WideTextBoxMenuParameters
	call InitializeMenuParameters
	call EnableLCD
.wait_A_or_B_loop
	call DoFrame
	call RefreshMenuCursor
	ldh a, [hKeysPressed]
	and A_BUTTON | B_BUTTON
	jr z, .wait_A_or_B_loop
	jp EraseCursor

WideTextBoxMenuParameters:
	db 18, 17 ; cursor x, cursor y
	db 1 ; y displacement between items
	db 1 ; number of items
	db SYM_CURSOR_D ; cursor tile number
	db SYM_BOX_BOTTOM ; tile behind cursor
	dw NULL ; function pointer if non-0

; display a two-item horizontal menu with custom text provided in hl and handle input
TwoItemHorizontalMenu:
	call DrawWideTextBox_PrintText
	lb de, 6, 16 ; x, y
	ld a, d
	ld [wLeftmostItemCursorX], a
	lb bc, SYM_CURSOR_R, SYM_SPACE ; cursor tile, tile behind cursor
	call SetCursorParametersForTextBox
	ld a, 1
	ld [wCurMenuItem], a
	call EnableLCD
	jp HandleYesOrNoMenu.refresh_menu

YesOrNoMenuWithText_SetCursorToYes:
	ld a, $01
	ld [wDefaultYesOrNo], a
;	fallthrough

; display a yes / no menu in a 20x8 textbox with custom text provided in hl and handle input
; wDefaultYesOrNo determines whether the cursor initially points to YES or to NO
; returns carry if "no" selected
YesOrNoMenuWithText:
	call DrawWideTextBox_PrintText
;	fallthrough

; prints the YES / NO menu items at coordinates x,y = 7,16 and handles input
; input: wDefaultYesOrNo. returns carry if "no" selected
YesOrNoMenu:
	lb de, 7, 16 ; x, y
	call PrintYesOrNoItems
	lb de, 6, 16 ; x, y
	; jr HandleYesOrNoMenu
	;	fallthrough

HandleYesOrNoMenu:
	ld a, d
	ld [wLeftmostItemCursorX], a
	lb bc, SYM_CURSOR_R, SYM_SPACE ; cursor tile, tile behind cursor
	call SetCursorParametersForTextBox
	ld a, [wDefaultYesOrNo]
	ld [wCurMenuItem], a
	call EnableLCD
	jr .refresh_menu
.wait_button_loop
	call DoFrame
	call RefreshMenuCursor
	ldh a, [hKeysPressed]
	bit A_BUTTON_F, a
	jr nz, .a_pressed
	ldh a, [hDPadHeld]
	and D_RIGHT | D_LEFT
	jr z, .wait_button_loop
	; left or right pressed, so switch to the other menu item
	ld a, SFX_01
	call PlaySFX
	call EraseCursor
.refresh_menu
	ld a, [wLeftmostItemCursorX]
	ld c, a
	; default to the second option (NO)
	ld hl, wCurMenuItem
	ld a, [hl]
	xor $1
	ld [hl], a
	; x separation between left and right items is 4 tiles
	add a
	add a
	add c
	ld [wCursorXPosition], a
	xor a
	ld [wCursorBlinkCounter], a
	jr .wait_button_loop
.a_pressed
	ld a, [wCurMenuItem]
	ldh [hCurMenuItem], a
	or a
	jr nz, .no
;.yes
	ld [wDefaultYesOrNo], a ; 0
	ret
.no
	xor a
	ld [wDefaultYesOrNo], a ; 0
	ld a, 1
	ldh [hCurMenuItem], a
	scf
	ret

; prints "YES NO" at de
PrintYesOrNoItems:
	call AdjustCoordinatesForBGScroll
	ldtx hl, YesOrNoText
	call InitTextPrinting_ProcessTextFromID
	ret

ContinueDuel:
	ld a, BANK(_ContinueDuel)
	call BankswitchROM
	jp _ContinueDuel


; sets variables at:
;   wCursorXPosition, wCursorYPosition
;   wYDisplacementBetweenMenuItems
;   wNumMenuItems
;	  wCursorTile
;   wTileBehindCursor
;   wMenuFunctionPointer
; in newer codebases these are named as:
;   wMenuCursorXOffset, wMenuCursorYOffset
;   wMenuYSeparation
;   wNumMenuItems
;   wMenuVisibleCursorTile
;   wMenuInvisibleCursorTile
;   wMenuUpdateFunc
NumberSliderMenuParameters::
	db 17, 16 ; cursor x, cursor y
	db 0 ; y displacement between items
	db 1 ; number of items
	db SYM_0 ; cursor tile number
	db SYM_SPACE ; tile behind cursor
	dw NumberSliderMenuFunction ; function pointer if non-0


; currently only handles 0 to 9
; for double digits, see CopyCardNameAndLevel and how it is printed
; input:
;   a: maximum selectable number (0 < a < $ff)
;   hl: pointer to callback function
; output:
;   a: selected number | $ff
;   [wCurMenuItem]: selected number | $ff
;   [hCurMenuItem]: selected number | $ff
;   carry: set if B was pressed
HandleNumberSlider:
	push hl
	push af
	; xor a
	ld hl, NumberSliderMenuParameters
	call InitializeMenuParameters
	pop af
	pop hl
; overwrite number of options from input value
	inc a  ; add zero as an option
	ld [wNumMenuItems], a
; move user callback function to wListFunctionPointer
	ld de, wListFunctionPointer
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
; draw frames and handle user input
	call EnableLCD
	ld a, SYM_CURSOR_U
	lb bc, 18, 16
	call WriteByteToBGMap0
	ld a, SYM_CURSOR_D
	lb bc, 15, 16
	call WriteByteToBGMap0
.wait_for_input
	call DoFrame
	call HandleMenuInput
	jr nc, .wait_for_input
	cp $ff
	ccf
	jr c, .b_pressed
; A pressed, invert selection
	ld c, a
	ld a, [wNumMenuItems]
	dec a
	sub c  ; no carry
.b_pressed
	ld [wCurMenuItem], a
	ldh [hCurMenuItem], a
	ret


; called after automatic handling of UP/DOWN in HandleMenuInput
; treat the current menu index as the amount to subtract from max
; this way, UP increases and DOWN decreases
; input:
;   a: index at [hCurMenuItem]
NumberSliderMenuFunction:
	ld c, a
	ld a, [wNumMenuItems]
	dec a
	sub c
	ld c, a
; overwrite the cursor symbol
	add SYM_0
	ld [wCursorTile], a
; execute the function at wListFunctionPointer, if any
	ld hl, wListFunctionPointer
	ld a, [hli]
	or [hl]
	ret z  ; no custom function
	ld a, [hld]
	ld l, [hl]
	ld h, a
	ld a, c
	; jp hl
	call CallHL
	jp HandleMenuInput.check_A_or_B
