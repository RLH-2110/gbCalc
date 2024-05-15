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
	; if number 0
	cp a,cursorState_Number0
	jr z, .Number0

	cp a,cursorState_Number0Sign
	jr z, .Number0

	; if number 1
	cp a,cursorState_Number1
	jr z, .Number1

	cp a,cursorState_Number1Sign
	jr z, .Number1

	; if not a number
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


ConvertInputs::
	push af
	push bc
	push hl
	push de

	; set number0 to 0
	xor a,a ; a = 0
	ld [wNumber0],a
	ld [wNumber0+1],a

	ld c,0 ; digit counter/index
	ld hl, screen + num0I + 4; load last digit from number0 (tilemap)
	.Number0Loop:
		
		ld a,[hl]
		dec a ; convert grapical number into real number (grapical 0 = 1, actuall 0 = 0)

		; de = number
		ld d,0
		ld e,a

		ld b,c ; counter for how many times we want to multiply

		;
		; now we (multiply the number by 10) x times, where x is the position of the number - 1 (positions: for a number 43210)
		;

			push hl

			; hl = number
			ld h,d
			ld l,e

		.number0Mul
			ld a,b
			cp a,0
			jr z, .number0Mul_Done

			call u16_times10			

			dec b
			jr .number0Mul 
		.number0Mul_Done
		
			; number = hl
			ld d,h
			ld e,l
			pop hl
			
		dec hl
		inc c

		; load number in hl 	(little endian)
		push hl

		ld a, [wNumber0+1]
		ld h, a 
		ld a, [wNumber0]
		ld l, a

		; add numbers
		add hl,de

		; store number (little endian)
		ld a,h
		ld [wNumber0+1], a 
		ld a, l
		ld [wNumber0], a

		pop hl

		ld a,c
		cp a,5
		jr nz, .Number0Loop




		; TODO number1!

	pop de
	pop hl
	pop bc
	pop af
	ret

