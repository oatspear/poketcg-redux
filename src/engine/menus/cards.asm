; handles the screen showing all the player's cards
HandlePlayersCardsScreen:
	call WriteCardListsTerminatorBytes
	call PrintPlayersCardsHeaderInfo
	xor a
	ld [wCardListVisibleOffset], a
	ld [wCurCardTypeFilter], a
	call PrintFilteredCardSelectionList
	call EnableLCD
	xor a
	ld hl, FiltersCardSelectionParams
	call InitCardSelectionParams
.wait_input
	call DoFrame
	ld a, [wCurCardTypeFilter]
	ld b, a
	ld a, [wTempCardTypeFilter]
	cp b
	jr z, .check_d_down
	ld [wCurCardTypeFilter], a
	ld hl, wCardListVisibleOffset
	ld [hl], $00
	call PrintFilteredCardSelectionList

	ld hl, hffb0
	ld [hl], $01
	call PrintPlayersCardsText
	ld hl, hffb0
	ld [hl], $00

	ld a, NUM_FILTERS
	ld [wCardListNumCursorPositions], a
.check_d_down
	ldh a, [hDPadHeld]
	and D_DOWN
	jr z, .no_d_down
	call ConfirmSelectionAndReturnCarry
	jr .jump_to_list

.no_d_down
	call HandleCardSelectionInput
	jr nc, .wait_input
	ld a, [hffb3]
	cp $ff ; operation cancelled
	jr nz, .jump_to_list
	ret

.jump_to_list
	ld a, [wNumEntriesInCurFilter]
	or a
	jr z, .wait_input

	xor a
	ld hl, Data_a396
	call InitCardSelectionParams
	ld a, [wNumEntriesInCurFilter]
	ld [wNumCardListEntries], a
	ld hl, wNumVisibleCardListEntries
	cp [hl]
	jr nc, .asm_a300
	ld [wCardListNumCursorPositions], a
.asm_a300
	ld hl, PrintCardSelectionList
	ld d, h
	ld a, l
	ld hl, wCardListUpdateFunction
	ld [hli], a
	ld [hl], d
	xor a
	ld [wced2], a

.loop_input
	call DoFrame
	call HandleSelectUpAndDownInList
	jr c, .loop_input
	call HandleDeckCardSelectionList
	jr c, .asm_a36a
	ldh a, [hDPadHeld]
	and START
	jr z, .loop_input
	; start btn pressed

.open_card_page
	ld a, $01
	call PlaySFXConfirmOrCancel
	ld a, [wCardListNumCursorPositions]
	ld [wTempCardListNumCursorPositions], a
	ld a, [wCardListCursorPos]
	ld [wTempCardListCursorPos], a

	; set wFilteredCardList as current card list
	; and show card page screen
	ld de, wFilteredCardList
	ld hl, wCurCardListPtr
	ld [hl], e
	inc hl
	ld [hl], d
	call OpenCardPageFromCardList
	call PrintPlayersCardsHeaderInfo

	ld hl, FiltersCardSelectionParams
	call InitCardSelectionParams
	ld a, [wCurCardTypeFilter]
	ld [wTempCardTypeFilter], a
	call DrawHorizontalListCursor_Visible
	call PrintCardSelectionList
	call EnableLCD
	ld hl, Data_a396
	call InitCardSelectionParams
	ld a, [wTempCardListNumCursorPositions]
	ld [wCardListNumCursorPositions], a
	ld a, [wTempCardListCursorPos]
	ld [wCardListCursorPos], a
	jr .loop_input

.asm_a36a
	call DrawListCursor_Invisible
	ld a, [wCardListCursorPos]
	ld [wTempCardListCursorPos], a
	ld a, [hffb3]
	cp $ff
	jr nz, .open_card_page
	ld hl, FiltersCardSelectionParams
	call InitCardSelectionParams
	ld a, [wCurCardTypeFilter]
	ld [wTempCardTypeFilter], a
	ld hl, hffb0
	ld [hl], $01
	call PrintPlayersCardsText
	ld hl, hffb0
	ld [hl], $00
	jp .wait_input


Data_a396:
	db 1 ; x pos
	db 5 ; y pos
	db 2 ; y spacing
	db 0 ; x spacing
	db 7 ; num entries
	db SYM_CURSOR_R ; visible cursor tile
	db SYM_SPACE ; invisible cursor tile
	dw NULL ; wCardListHandlerFunction


; a = which card type filter
PrintFilteredCardSelectionList:
	push af
	ld hl, CardTypeFilters
	ld b, $00
	ld c, a
	add hl, bc
	ld a, [hl]
	push af
	ld a, ALL_DECKS
	call CreateCardCollectionListWithDeckCards
	pop af
	call CreateFilteredCardList

	ld a, NUM_DECK_CONFIRMATION_VISIBLE_CARDS
	ld [wNumVisibleCardListEntries], a
	lb de, 2, 5
	ld hl, wCardListCoords
	ld [hl], e
	inc hl
	ld [hl], d
	ld a, SYM_SPACE
	ld [wCursorAlternateTile], a
	call PrintCardSelectionList
	pop af
	ret


; print header info (card count and player name)
PrintPlayersCardsHeaderInfo:
	call Set_OBJ_8x8
	call Func_8d78
.skip_empty_screen
	lb bc, 0, 4
	ld a, SYM_BOX_TOP
	call FillBGMapLineWithA
	call PrintTotalNumberOfCardsInCollection
	call PrintPlayersCardsText
	jp DrawCardTypeIcons


PrintTotalNumberOfCardsInCollection:
	ld a, ALL_DECKS
	call CreateCardCollectionListWithDeckCards

; count all the cards in collection
	ld de, wTempCardCollection + 1
	ld b, 0
	ld hl, 0
.loop_all_cards
	ld a, [de]
	inc de
	and $7f
	push bc
	ld b, $00
	ld c, a
	add hl, bc
	pop bc
	inc b
	ld a, NUM_CARDS
	cp b
	jr nz, .loop_all_cards

; hl = total number of cards in collection
	call .GetTotalCountDigits
	ld hl, wTempCardCollection
	ld de, wOnesAndTensPlace
	ld b, $00
	call .PlaceNumericalChar
	call .PlaceNumericalChar
	call .PlaceNumericalChar
	call .PlaceNumericalChar
	call .PlaceNumericalChar
	ld a, $07
	ld [hli], a
	ld [hl], TX_END
	lb de, 13, 0
	call InitTextPrinting
	ld hl, wTempCardCollection
	jp ProcessText

; places a numerical character in hl from de
; doesn't place a 0 if no non-0
; numerical character has been placed before
; this makes it so that there are no
; 0s in more significant digits
.PlaceNumericalChar
	ld [hl], TX_SYMBOL
	inc hl
	ld a, b
	or a
	jr z, .leading_num
	ld a, [de]
	inc de
	ld [hli], a
	ret
.leading_num
; don't place a 0 as a leading number
	ld a, [de]
	inc de
	cp SYM_0
	jr z, .space_char
	ld [hli], a
	ld b, $01 ; at least one non-0 char was placed
	ret
.space_char
	xor a ; SYM_SPACE
	ld [hli], a
	ret

; gets the digits in decimal form
; of value stored in hl
; stores the result in wOnesAndTensPlace
.GetTotalCountDigits
	ld de, wOnesAndTensPlace
	ld bc, -10000
	call .GetDigit
	ld bc, -1000
	call .GetDigit
	ld bc, -100
	call .GetDigit
	ld bc, -10
	call .GetDigit
	ld bc, -1
	; jr .GetDigit
	; fallthrough

.GetDigit
	ld a, SYM_0 - 1
.loop
	inc a
	add hl, bc
	jr c, .loop
	ld [de], a
	inc de
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
	ret


; prints "<PLAYER>'s cards"
PrintPlayersCardsText:
	lb de, 1, 0
	call InitTextPrinting
	ld de, wDefaultText
	call CopyPlayerName
	ld hl, wDefaultText
	call ProcessText
	ld hl, wDefaultText
	call GetTextLengthInTiles
	inc b
	ld d, b
	ld e, 0
	call InitTextPrinting
	ldtx hl, SCardsText
	jp ProcessTextFromID


; prints the name, level and storage count of the cards
; that are visible in the list window
; in the form:
; CARD NAME/LEVEL X
; where X is the current count of that card
PrintCardSelectionList:
	push bc
	ld hl, wCardListCoords
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld b, 19 ; x coord
	ld c, e
	ld a, [wCardListVisibleOffset]
	or a
	jr z, .alternate_cursor_tile
	ld a, SYM_CURSOR_U
	jr .got_cursor_tile_1
.alternate_cursor_tile
	ld a, [wCursorAlternateTile]
.got_cursor_tile_1
	call WriteByteToBGMap0

; iterates by decreasing value in wNumVisibleCardListEntries
; by 1 until it reaches 0
	ld a, [wCardListVisibleOffset]
	ld c, a
	ld b, $0
	ld hl, wFilteredCardList
	add hl, bc
	ld a, [wNumVisibleCardListEntries]
.loop_filtered_cards
	push de
	or a
	jr z, .exit_loop
	ld b, a
	ld a, [hli]
	or a
	jr z, .invalid_card ; card ID of 0
	ld e, a
	call AddCardIDToVisibleList
	call LoadCardDataToBuffer1_FromCardID
	; places in wDefaultText the card's name and level
	; then appends at the end the count of that card
	; in the card storage
	ld a, 14
	push bc
	push hl
	push de
	call CopyCardNameAndLevel
	pop de
	call AppendOwnedCardCountNumber
	pop hl
	pop bc
	pop de
	push hl
	call InitTextPrinting
	ld hl, wDefaultText
	jr .process_text
.invalid_card
	pop de
	push hl
	call InitTextPrinting
	ld hl, Text_9a36
.process_text
	call ProcessText
	pop hl

	ld a, b
	dec a
	inc e
	inc e
	jr .loop_filtered_cards

.exit_loop
	ld a, [hli]
	or a
	jr z, .cannot_scroll
	pop de
; draw down cursor because
; there are still more cards
; to be scrolled down
	xor a ; FALSE
	ld [wUnableToScrollDown], a
	ld a, SYM_CURSOR_D
	jr .got_cursor_tile_2
.cannot_scroll
	pop de
	ld a, TRUE
	ld [wUnableToScrollDown], a
	ld a, [wCursorAlternateTile]
.got_cursor_tile_2
	ld b, 19 ; x coord
	ld c, e
	dec c
	dec c
	call WriteByteToBGMap0
	pop bc
	ret


; appends the card count given in register e
; to the list in hl, in numerical form
; (i.e. its numeric symbol representation)
AppendOwnedCardCountNumber:
	push af
	push bc
	push de
	push hl
; increment hl until end is reached ($00 byte)
.loop
	ld a, [hl]
	or a
	jr z, .end
	inc hl
	jr .loop
.end
	; ld [hl], TX_SYMBOL
	; inc hl
	; ld [hl], SYM_CROSS
	; inc hl
	call GetOwnedCardCount
	call ConvertToNumericalDigits
	ld [hl], $00 ; insert byte terminator
	pop hl
	pop de
	pop bc
	pop af
	ret
