include "defines.inc"

SECTION FRAGMENT "subroutine ROM", rom0

; max 32.767
; min -32.768
ValidNumberLookup:
db tile_three, tile_two, tile_seven, tile_six, tile_empty ; last byte will either be 7 or 8, we can modify it when we need to actually check the byte.

;! assumes that all registers are free to use. !
; uses HL,A,BC, (ram)tmpL, (ram)tmpH
validateInput::

	ld hl,screen + num0I ; loads adress of number 0(in tilemap) 
	xor a,a ; a = 0
	ld c,a ;counter in number
	ld [tmpL],a ; number counter
	ld [tmpH],a ; boolean, overwrite all
	jr .CheckNumber


	.nextNumber:
		ld hl,screen + num1I ; loads adress of number 1 (in tilemap) 
		ld c,0 ;counter
		ld a,1
		ld [tmpL],a ; number counter
		xor a,a ; a = 0
		ld [tmpH],a ; boolean, overwrite all

	.CheckNumber:

		ld b,[hl] ; get the current tile

		;get the expected tile
			push hl
			ld hl,ValidNumberLookup
			
			; add ValidNumberLookup and c
			ld a,l
			add a,c
			ld l,a

			ld a,h
			adc a,0
			ld h,a

			; check if tile is empty

			ld a,[hl]
			cp tile_empty
			jr nz,.CheckTile

			;tile is empty

				;check if number is positive
				call CheckSign_TileMap

				; z = positive, nz = negative
				cp a,0
				jr nz, .numberNegative

				; positive number
				ld a,tile_seven
				jr .CheckTile

				.numberNegative:
				ld a,tile_eight

			.CheckTile:
			pop hl

		; check if we are in overwrite mode (the entire number must be overwritten)
		push af
		ld a,[tmpH]
		cp a,1
		jr z, .OverwriteAll ; if we are in overwerite mode, jump to it.
		pop af
		
		
		; we are still in check mode

		cp a,b ; a = expected tile, b = current tile
		jr z, .nextTile ; if we equal, then we need to check the next part of the number. (b == a)
		jr nc,.CheckNextNumber ; if we are below the max num, check next number (b <= a)
		
		;tiles dont match! ( b > a)
		push af
		ld a,1
		ld [tmpH],a
		
		jr .OverwriteAll

		.nextTile:
		inc c
		inc hl

		; checks if c is outside the number
		ld a,c
		cp a,5 ;(out of bounds after increment)
		jr z,.CheckNextNumber

		jr .CheckNumber

		.OverwriteAll:
		pop af
		ld [hl],a 	; set to expected tile tile
		jr .nextTile


		.CheckNextNumber:
		ld a,[tmpL]
		cp a,0
		jp z,.nextNumber

		ret


; tmpL: number (0 = number0, not zero = number1)
; a: 0 = positive, $ff = negative
CheckSign_TileMap::

	;check if we are in number 0
	ld a,[tmpL]
	cp a,0
	jr z,.Number0

	;number1
	ld a,[screen + num1_prefixI]
	jr .NumberEnd
	.Number0
	ld a,[screen + num0_prefixI]
	.NumberEnd:

	; a contains the tile that indicates if a number is positive or negative
	cp a,tile_add
	jr nz, .numberNegative

	; positive number
	ld a,0

	ret

	.numberNegative:
	ld a,$ff

	ret


clearSelectedNumber::

	ld a,[wCursorState]
	cp a,cursorState_Number0
	jr z, .Number0
	cp a,cursorState_Number1
	jr z, .Number1

	ret

	.Number0:
	ld hl,screen + num0I ; DESTINATION
	jr .setMemory

	.Number1:
	ld hl,screen + num1I ; DESTINATION

	.setMemory:

	ld bc,5 ; BYTES
	ld d,tile_zero ; VALUE
	call SetMem
	ret