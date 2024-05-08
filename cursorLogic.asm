include "defines.inc"

SECTION FRAGMENT "subroutine ROM", rom0

;data:

	;indexes for the cursor array
	CursorArray::
	dw .cs0, .cs1, .cs2, .cs3, .cs4

	;tilemap offset, inc routine, dec routine, left routine, right routine
	.cs0:
	dw $9800 + $102, nop_function, nop_function, nop_function, nop_function
	.cs1:
	dw $9800 + $103, CursorNumberInc, CursorNumberDec, nop_function, nop_function
	.cs2:
	dw $9800 + $109, CursorOperatorInc, CursorOperatorDec, nop_function, nop_function
	.cs3:
	dw $9800 + $10B, nop_function, nop_function, nop_function, nop_function
	.cs4:
	dw $9800 + $10C, CursorNumberInc, CursorNumberDec, nop_function, nop_function


; code:
nop_function:
ret

; this subroutine jumps to a subroutine defined in an array thats indexed by the cursor state and the A register
; E: function selector
CursorHandler::
	push af
	push hl
	push bc
	push de


	; note: 
	; [CursorArray+CursorState]->CursorData
	; [CursorData-+offset]->functionPointer

	ld hl,CursorArray ; base adress

	;bc = wCursorState (used as an offset)
	ld b, 0
	ld a,[wCursorState] 
	ld c,a


	add hl,bc ; combine base adress with the offset
	add hl,bc ; do it twice, since the data is 2 byte big

	; get pointer to new base adress
	ld c,[hl] ;load lower part of the new base adress
	inc hl
	ld b,[hl] ;load upper part

	;transfer to hl
	ld h,b
	ld l,c

	;load tilemap adress into bc
	ld c,[hl] ; load lower part
	inc hl
	ld b,[hl] ; load upper part
	dec hl
	push bc ; save tilemap address

	ld d,0

	; e * 2 (since the data is 2 bytes long)
	SLA e 

	add hl,de ; apply offset parameter to new base adress

	; get the pointer thats behind the new adress
	ld c,[hl] ;load lower part of the pointer
	inc hl
	ld b,[hl] ;load upper part

	;transfer to hl
	ld h,b
	ld l,c

	;HL now contains the pointer.

	;get the tilemap adress into de
	pop de
	;call the function
	ld bc,.CursorHanlderReturnAdress
	push bc ; push return adress onto the stack
	jp hl ; call the function pased on the pointer we got

	.CursorHanlderReturnAdress
	pop de
	pop bc 
	pop hl
	pop af
	ret


; DE: tilemap adress
CursorNumberInc:
	ld h,d
	ld l,e
	inc [hl]

	ld a,tile_nine
	cp a,[hl]
	jr c, .overflow ; if the tile is bigger than the tile displaying 9
	ret

	.overflow: 
	ld [hl],tile_zero ; set to the tile that displays 0
	ret


; DE: tilemap adress
CursorNumberDec::
	ld h,d
	ld l,e
	dec [hl]

	jr z, .underflow ; if its an empy tile now
	ret

	.underflow:
	ld [hl],tile_nine ; set to the tile that displays 9
	ret



; DE: tilemap adress
CursorOperatorInc:
	ld h,d
	ld l,e
	inc [hl]

	ld a,tile_modulus
	cp a,[hl]
	jr c, .overflow ; if the tile is bigger than the tile displaying %
	ret

	.overflow: 
	ld [hl],tile_add ; set to the tile that displays +
	ret


; DE: tilemap adress
CursorOperatorDec::
	ld h,d
	ld l,e
	dec [hl]

	ld a,tile_add
	jr c, .underflow ; if its under a +
	ret

	.underflow:
	ld [hl],tile_modulus ; set to the tile that displays %
	ret

;todo